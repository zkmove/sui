// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

use crate::{NativesCostTable, get_extension, object_runtime::ObjectRuntime};
use fastcrypto::hash::{Blake2b256, HashFunction};
use move_binary_format::errors::PartialVMResult;
use move_core_types::gas_algebra::InternalGas;
use move_vm_runtime::{
    execution::{Type, values::Value},
    native_charge_gas_early_exit,
    natives::functions::{NativeContext, NativeResult},
    pop_arg,
};
use smallvec::smallvec;
use std::collections::VecDeque;
#[cfg(panic = "unwind")]
use std::panic::AssertUnwindSafe;

pub const E_INPUT_TOO_LARGE: u64 = 1000;
pub const E_INVALID_NATIVE_ARGUMENT: u64 = 1001;
pub const E_NOT_SUPPORTED: u64 = 1002;
pub const E_VERIFIER_INPUT_ERROR: u64 = 1003;
pub const E_VERIFIER_PANICKED: u64 = 1004;
pub const E_VERIFIER_UNSUPPORTED_CONFIG: u64 = 1005;
pub const E_VERIFIER_INTERNAL_ERROR: u64 = 1006;

pub const KZG_GWC: u8 = 0;
pub const KZG_SHPLONK: u8 = 1;

pub const MAX_PARAMS_BYTES: usize = 240 * 1024;
pub const MAX_VK_BYTES: usize = 240 * 1024;
pub const MAX_CIRCUIT_INFO_BYTES: usize = 240 * 1024;
pub const MAX_PROOF_BYTES: usize = 96 * 1024;
pub const MAX_PUBLIC_INPUT_BYTES: usize = 16 * 1024;
pub const MAX_TOTAL_NATIVE_INPUT_BYTES: usize = MAX_PARAMS_BYTES
    + MAX_VK_BYTES
    + MAX_CIRCUIT_INFO_BYTES
    + MAX_PROOF_BYTES
    + MAX_PUBLIC_INPUT_BYTES;
const HALO2_PUBLIC_INPUT_SCALAR_BYTES: usize = 32;

#[derive(Clone)]
pub struct Halo2KzgVerifyProofInternalCostParams {
    pub halo2_kzg_verify_proof_internal_cost_base: InternalGas,
    pub halo2_kzg_verify_proof_internal_params_cost_per_byte: InternalGas,
    pub halo2_kzg_verify_proof_internal_vk_cost_per_byte: InternalGas,
    pub halo2_kzg_verify_proof_internal_circuit_info_cost_per_byte: InternalGas,
    pub halo2_kzg_verify_proof_internal_public_input_cost_per_byte: InternalGas,
    pub halo2_kzg_verify_proof_internal_proof_cost_per_byte: InternalGas,
    pub halo2_kzg_verify_proof_internal_cost_per_public_input: InternalGas,
}

fn is_supported(context: &NativeContext) -> PartialVMResult<bool> {
    Ok(get_extension!(context, ObjectRuntime)?
        .protocol_config
        .enable_halo2_kzg_verifier())
}

pub fn verify_proof_internal(
    context: &mut NativeContext,
    ty_args: Vec<Type>,
    mut args: VecDeque<Value>,
) -> PartialVMResult<NativeResult> {
    debug_assert!(ty_args.is_empty());
    debug_assert!(args.len() == 11);

    if !is_supported(context)? {
        return Ok(NativeResult::err(context.gas_used(), E_NOT_SUPPORTED));
    }

    let cost_params = get_extension!(context, NativesCostTable)?
        .halo2_kzg_verify_proof_internal_cost_params
        .clone();

    let k = pop_arg!(args, u32);
    let k_present = pop_arg!(args, bool);
    let kzg_variant = pop_arg!(args, u8);
    let proof = pop_arg!(args, Vec<u8>);
    let public_inputs = pop_arg!(args, Vec<u8>);
    let circuit_info_digest = pop_arg!(args, Vec<u8>);
    let circuit_info = pop_arg!(args, Vec<u8>);
    let vk_digest = pop_arg!(args, Vec<u8>);
    let vk = pop_arg!(args, Vec<u8>);
    let params_digest = pop_arg!(args, Vec<u8>);
    let params = pop_arg!(args, Vec<u8>);

    let inputs = NativeVerifyInputs {
        params: &params,
        params_digest: &params_digest,
        vk: &vk,
        vk_digest: &vk_digest,
        circuit_info: &circuit_info,
        circuit_info_digest: &circuit_info_digest,
        public_inputs: &public_inputs,
        proof: &proof,
        kzg_variant,
        k: k_present.then_some(k),
    };

    native_charge_gas_early_exit!(
        context,
        halo2_kzg_verify_proof_internal_cost(&cost_params, &inputs)
    );
    let cost = context.gas_used();

    match verify_halo2_kzg(inputs) {
        VerifyOutcome::Valid => Ok(NativeResult::ok(cost, smallvec![Value::bool(true)])),
        VerifyOutcome::Invalid => Ok(NativeResult::ok(cost, smallvec![Value::bool(false)])),
        VerifyOutcome::Abort(code) => Ok(NativeResult::err(cost, code)),
    }
}

fn halo2_kzg_verify_proof_internal_cost(
    cost_params: &Halo2KzgVerifyProofInternalCostParams,
    inputs: &NativeVerifyInputs<'_>,
) -> InternalGas {
    let public_input_count = inputs
        .public_inputs
        .len()
        .div_ceil(HALO2_PUBLIC_INPUT_SCALAR_BYTES);

    cost_params.halo2_kzg_verify_proof_internal_cost_base
        + cost_params.halo2_kzg_verify_proof_internal_params_cost_per_byte
            * (inputs.params.len() as u64).into()
        + cost_params.halo2_kzg_verify_proof_internal_vk_cost_per_byte
            * (inputs.vk.len() as u64).into()
        + cost_params.halo2_kzg_verify_proof_internal_circuit_info_cost_per_byte
            * (inputs.circuit_info.len() as u64).into()
        + cost_params.halo2_kzg_verify_proof_internal_public_input_cost_per_byte
            * (inputs.public_inputs.len() as u64).into()
        + cost_params.halo2_kzg_verify_proof_internal_proof_cost_per_byte
            * (inputs.proof.len() as u64).into()
        + cost_params.halo2_kzg_verify_proof_internal_cost_per_public_input
            * (public_input_count as u64).into()
}

struct NativeVerifyInputs<'a> {
    params: &'a [u8],
    params_digest: &'a [u8],
    vk: &'a [u8],
    vk_digest: &'a [u8],
    circuit_info: &'a [u8],
    circuit_info_digest: &'a [u8],
    public_inputs: &'a [u8],
    proof: &'a [u8],
    kzg_variant: u8,
    k: Option<u32>,
}

enum VerifyOutcome {
    Valid,
    Invalid,
    Abort(u64),
}

fn verify_halo2_kzg(inputs: NativeVerifyInputs<'_>) -> VerifyOutcome {
    if inputs.kzg_variant != KZG_GWC && inputs.kzg_variant != KZG_SHPLONK {
        return VerifyOutcome::Abort(E_INVALID_NATIVE_ARGUMENT);
    }

    if inputs.params_digest.len() != 32
        || inputs.vk_digest.len() != 32
        || inputs.circuit_info_digest.len() != 32
    {
        return VerifyOutcome::Abort(E_INVALID_NATIVE_ARGUMENT);
    }

    let total_input_bytes = inputs.params.len()
        + inputs.vk.len()
        + inputs.circuit_info.len()
        + inputs.public_inputs.len()
        + inputs.proof.len();

    if inputs.params.len() > MAX_PARAMS_BYTES
        || inputs.vk.len() > MAX_VK_BYTES
        || inputs.circuit_info.len() > MAX_CIRCUIT_INFO_BYTES
        || inputs.public_inputs.len() > MAX_PUBLIC_INPUT_BYTES
        || inputs.proof.len() > MAX_PROOF_BYTES
        || total_input_bytes > MAX_TOTAL_NATIVE_INPUT_BYTES
    {
        return VerifyOutcome::Abort(E_INPUT_TOO_LARGE);
    }

    if digest(inputs.params) != inputs.params_digest
        || digest(inputs.vk) != inputs.vk_digest
        || digest(inputs.circuit_info) != inputs.circuit_info_digest
    {
        return VerifyOutcome::Invalid;
    }

    match invoke_halo2_verifier(&inputs) {
        Ok(Ok(())) => VerifyOutcome::Valid,
        Ok(Err(err)) => classify_verifier_error(err),
        Err(_) => VerifyOutcome::Abort(E_VERIFIER_PANICKED),
    }
}

fn invoke_halo2_verifier(
    inputs: &NativeVerifyInputs<'_>,
) -> Result<Result<(), halo2_verifier::error::VerifyError>, ()> {
    let verify = || {
        halo2_verifier::deserialize_circuit_and_verify(
            inputs.params,
            inputs.vk,
            inputs.circuit_info,
            inputs.public_inputs,
            inputs.proof,
            inputs.kzg_variant,
            inputs.k,
        )
    };

    // In Sui's release profile panic=abort means catch_unwind cannot be a safety boundary. It is
    // kept only as a debug/unwind-profile diagnostic fallback while the verifier path itself must
    // remain panic-free for malformed transaction input.
    #[cfg(panic = "unwind")]
    {
        std::panic::catch_unwind(AssertUnwindSafe(verify)).map_err(|_| ())
    }

    #[cfg(not(panic = "unwind"))]
    {
        Ok(verify())
    }
}

fn classify_verifier_error(err: halo2_verifier::error::VerifyError) -> VerifyOutcome {
    match err {
        halo2_verifier::error::VerifyError::InvalidProof(_) => VerifyOutcome::Invalid,
        halo2_verifier::error::VerifyError::MalformedInput(_) => {
            VerifyOutcome::Abort(E_VERIFIER_INPUT_ERROR)
        }
        halo2_verifier::error::VerifyError::UnsupportedConfig(_) => {
            VerifyOutcome::Abort(E_VERIFIER_UNSUPPORTED_CONFIG)
        }
        halo2_verifier::error::VerifyError::Internal(_) => {
            VerifyOutcome::Abort(E_VERIFIER_INTERNAL_ERROR)
        }
    }
}

fn digest(bytes: &[u8]) -> [u8; 32] {
    Blake2b256::digest(bytes).digest
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::{env, process::Command};

    const RAYON_DETERMINISM_CHILD_ENV: &str = "SUI_HALO2_KZG_RAYON_DETERMINISM_CHILD";
    const RAYON_DETERMINISM_OUTPUT_PREFIX: &str = "HALO2_KZG_RAYON_DETERMINISM=";

    fn test_inputs<'a>(
        params: &'a [u8],
        params_digest: &'a [u8],
        vk: &'a [u8],
        vk_digest: &'a [u8],
        circuit_info: &'a [u8],
        circuit_info_digest: &'a [u8],
        public_inputs: &'a [u8],
        proof: &'a [u8],
    ) -> NativeVerifyInputs<'a> {
        NativeVerifyInputs {
            params,
            params_digest,
            vk,
            vk_digest,
            circuit_info,
            circuit_info_digest,
            public_inputs,
            proof,
            kzg_variant: KZG_GWC,
            k: None,
        }
    }

    #[test]
    fn native_abort_codes_do_not_overlap_move_errors() {
        for code in [
            E_INPUT_TOO_LARGE,
            E_INVALID_NATIVE_ARGUMENT,
            E_NOT_SUPPORTED,
            E_VERIFIER_INPUT_ERROR,
            E_VERIFIER_PANICKED,
            E_VERIFIER_UNSUPPORTED_CONFIG,
            E_VERIFIER_INTERNAL_ERROR,
        ] {
            assert!(code >= 1000);
        }
    }

    #[test]
    fn move_and_native_byte_limits_match() {
        const MOVE_SOURCE: &str = include_str!(
            "../../../../../crates/sui-framework/packages/sui-framework/sources/crypto/halo2_kzg.move"
        );

        assert_eq!(
            parse_move_u64_const(MOVE_SOURCE, "MAX_PARAMS_BYTES"),
            Ok(MAX_PARAMS_BYTES as u64)
        );
        assert_eq!(
            parse_move_u64_const(MOVE_SOURCE, "MAX_VK_BYTES"),
            Ok(MAX_VK_BYTES as u64)
        );
        assert_eq!(
            parse_move_u64_const(MOVE_SOURCE, "MAX_CIRCUIT_INFO_BYTES"),
            Ok(MAX_CIRCUIT_INFO_BYTES as u64)
        );
        assert_eq!(
            parse_move_u64_const(MOVE_SOURCE, "MAX_PROOF_BYTES"),
            Ok(MAX_PROOF_BYTES as u64)
        );
        assert_eq!(
            parse_move_u64_const(MOVE_SOURCE, "MAX_PUBLIC_INPUTS_BYTES"),
            Ok(MAX_PUBLIC_INPUT_BYTES as u64)
        );
        assert_eq!(
            parse_move_u64_const(MOVE_SOURCE, "HALO2_PUBLIC_INPUT_SCALAR_BYTES"),
            Ok(HALO2_PUBLIC_INPUT_SCALAR_BYTES as u64)
        );
    }

    fn hex_to_bytes(hex: &str) -> Vec<u8> {
        assert_eq!(hex.len() % 2, 0);
        (0..hex.len())
            .step_by(2)
            .map(|i| u8::from_str_radix(&hex[i..i + 2], 16).expect("valid hex"))
            .collect()
    }

    struct TestFixture {
        params: Vec<u8>,
        vk: Vec<u8>,
        circuit_info: Vec<u8>,
        public_inputs: Vec<u8>,
        proof: Vec<u8>,
        proof_shplonk: Vec<u8>,
    }

    fn vector_mul_fixture() -> TestFixture {
        TestFixture {
            params: hex_to_bytes(
                "0400000042f8cfea72663b7832e47dc1fdeab56f2f1d07b729ce0a67a9f95480067c840de1800642e35c0a9fdd474e873eb42c6ceae6d8d8f43c0e035c9fbfb89bb32728303f01830dc2182d175d38ddb47e6cc2c2063b0831432043ac7994d29438082d9c8e35afccd69c2b897efd50d7ed0e62122388f41326dba4bc0d128ae0d14119",
            ),
            vk: hex_to_bytes(
                "040401000000e8d6a310e68ff8ec0c23b3493ad971f39df348d914b69d900ef6bdb1a9380821a0d18c6d3fddc6df07b88dc384fed028707856b47f2ecf104a733b540541091054c1d5267ffcf0bb4847238fc935dff061a38e0c871a88849cf4d6460563c507b42083b1856a6aeb1c85d9942c94d017daa5a4ff5edfc46cf08ba1d025b0e3285adf9bf0d7ac95bb8db1cff4024ada370ee77158c0b3583d79e829e3445280057d2ddbb5c2d6dbc5f2f4d04cde7990d04398ffe4209787b59d4ca8cf3fdfca083bfafcc40b672a8f5e55f6e5b499cfb0f890dde2b36823a527c2d3eee7a1f52d935240d23b082f3a51d7891bc62a0f7af50b2ea077bf40037610850363338004203b2593d81f79267ccc50a960dd60a4ad849d0d22be1f321318a36a595f2a1542a3c0201d2e6111bb8e7e170542056c37d5e8de34633a62d5c5f1f7f3dd452b",
            ),
            circuit_info: hex_to_bytes(
                "0b0c20acc86b4c84170be1ea86dfb0bf5d284c7bee72808a85412c71eeec572b2fbb0b208effc754694da2cb6df0dc36fe4a9bc7e3ec844490da918c007213c66bf786a38001b61dd63efa2807041eec04d2e53c1dcdef061216ff9f65a22d88b152b8d6559f994768be185bbb68e44116cb6d1017bab8dfe91dc3ddb28ed720139f34ea6505d4b098bb2b6a4f0d5ec7d96d3184666aaecda03d0d83cfe4fb06c7edccb9c5a22f720095cbbf541bd781e9d75cfd01d23ff3ca5674e05d85d001abce9688539e010404010000000403000000080100000000000000080100000000000000030000000001000100030a010000000001000000000a010100000001000000000a01020000000100000000010a03000000000100000000010a020000000001000000000405030000000005010000000005010100000005010200000000010c08020007080300030106030200000000",
            ),
            public_inputs: hex_to_bytes(
                "0103200600000000000000000000000000000000000000000000000000000000000000200600000000000000000000000000000000000000000000000000000000000000200600000000000000000000000000000000000000000000000000000000000000",
            ),
            proof: hex_to_bytes(
                "e9445cc7533f61fff8af036209735753b9276900d0b1812e91405ce65da07d20d8994f4c3db10d08f37a602e0f56258c624c6076d800678adfd0ecbad2fc3a2065db9386aa1d60c6c8ccffb869093fada5eb6797ba9488c8fa8b39f39d88ea0d8b987dbc98354df75153951b34d21fef0ec49e419453aa9eabb8397cf70c4e8945f3d19d0b85a80b1c92dd1f67742a65a1407676aae21846619e7683ba3681074fe0f929405e17fdb6b5457fa2796587349001fc43ee6726ef6473a62d772e270c4f6c0720fbd0cc9b142f6b7019cce18ffbb071348b7252d92c15ed49cb34af5fb50e30a6f2ae37b39bbc5e0f08f511623fc2e347f9dbc241b7676af8c2068f4e424a79cdf9e47d3f81213b7ce0754e22a5900bc034d9ec14eb976f2e4fe68f13a964e497d8550450f29c3d207d1319e41d325463add88986caa6226d3f5a071c1a237da662f8bc7044c930ba01e78ebab10c8f3750ce3875ade4c17613f629d469b3c80240d084f8eb7c00d349f1ec2eb923405d065c45e05972117810750c129a65213a381020350769823427aa691c79b77591373c8c9a19ee97717bda1bd2e5fe1e693cea645a56976dac736f1e4729ffc503392660cff16d21c64679144b8ad3b2f7ffd36e26837178cdd403266fe5ef05eee9eccf87032c2be6327007fad06835aceec94fcd5018e0d7001da60be35da0a23d43f702c6a8da7c40433047344f70808328501fce9f1920c3f54187c36e36c4d3d410fe76295a2f0afe07e040ec38b721e1fdb068c0eea9e5ec3b88579674b13a9471f7e8f2d6e82a5e00bf6c1f64443eaac6a3e772d283e6a35839574d39fa183fa8ed0dbb87beb71e2412fe1918f814d4ad50bb2001a6d0afb2c98bbce25b1d516896fa431853965812000be23e6303955802b8c503385837aaf3a84459d99d426d2723d63a20d74c2c91afafcce1aa44c1faaaa5f088da984c557cd591fa0e8bd3ef31ad1c128b1e21e19032fd9c419d73a070165530851f8ddbfab0c6a0ee795428bbbe6ef74cbd2c99ffe15922ee1a3b9ae82e99d5783ad1d3804b5df5ececa5898a58167a426f0ff534a7c85ca4603eb202f5e6ee2993b5bf74ea2fd930687946ff421e0ed8b40f881fb309f422e050f35184f65e4f719c2f0fb8a68ee5de10fc474532d00c2122657efdc65431f313ec8d02ed8f017b9bb14fff3910dfc58f78c5f8f17f32ca1c8fb4abbcb1978e8c5f1d783025eb19fb8580e4f50bb3755136ff1a2c0ac903296bb6136ecf03ba35e23496dfd4d77b728532cb5b41ba46fc489926ddb5951a26b82e74bf0fd684b4f4a1c4728eedece37c52a970f30e5915fb931d804014992ba09392b14eca34c6a8e3915dac6afc2ef43041ec6691f4c7769bf230b9016614391af4f7d9df348ee7a0005c110e0563a65073f5f7383abc98912d8e249e3a13e0242be684a69ebe87cf7da07ede3ba9fd7041db88f3cba0469bd3b582393a9e",
            ),
            proof_shplonk: hex_to_bytes(
                "92958eeb7e7ea2bcf05806221c0b71b6bb7df5d399c845a15441950bfde594a2326a5f02355ebe69ea546d79c9e89cbc559a1353869f06ad1c5c20a2918570290af9170dd4c3905af9db9dda9291766b803001694313e43e0a144eae46dab2a749175bd1fbc6597cf26d47faea0070c40a20aefaa79cf4c4c7a9cf599fcfd907b0be5b6abb8781dc8a5ce32b12fb113bf9f094b88544c2868ca90e2b9bb25027dfdc033b8233e2bb95fcf573d3c44d3ae1098ee7301ab5e0fe04737c094f4f2812680b7fe973ac056403bfe4e390df8fdf7242aabf8c98951804f1ca86f8a98f034090a1404c4e3e46ec66378e8396e529a458ef4c2df645f4851ff81778f92f5710bd08a962f094e056dab3a8997d1b71e3294157b3a608e3bfe5be09263927ba1b6f0f45977fee8ca4b4f6e4c952ce751e4ccec874207a05a0bcdd25d6228bfb23ff4e5e85f49a54f00a19e37c561399efcb33dea2a1ca436d535e37e1b8064d01ac3fa3e61e3be115d0590b00eda0497628b2db1f377a713becca3afa6405f79640efb9b023e675056c9b1e559de490cbf2af8da39e2db91d01b77b5d6402293868623e5e99ffa1cd6c3e1a410d7d9813ecb577f12290d74130ac4792e01b939dc743e527906747a38fc401bee1eabaadf0a453c27e386d0aec3024a94303f4d1eb2043763044eff4cd1c263b4b823203989050164fcdaed5b62a72743208207f2290a7c204433f4bbb8ff4f5add972432a4d23ded580c37aa1fdd943850af82af1c3a5e2384fbdacb39d6c2341c8a283e1610646479b0fd14acbd26e3411ba6e87981b59b05fcbbe6cfd55d1b3c166f8434cae2a976257fc030b6bf53d069a94a54d253ae0f271c9c6090b50f6e8e0c9bd05187eec0cb0df43f3c1f93b2a53c06bfc404943165aeb4d430a55d0c43696f77080bb95f76b8ceb6dbb74b116fda90e5ba270effa5c0310538550357515c30338b3f0b0d5a04aa538b45758102730d127185c2cf6a2d30faf0f7e35f6580894148ee1b22085f748e0619a361a71871258f94889cf81bcb0ab580541ab26b81ac664e41af4a76babb8e645150195c27f58eb6dbcc34ee690bf2f23b02d3df1437ff8f583d9cf64fea4ef2f8203f6e22b794092d0ff3d540b7d607e661f8e37e91777d1c315470a1941dec237009931329189cde2ff82e98ef5e692f9a9bbe09712d54094f905a06cc59dccc6263e4a40a8c2e1b3c38b5450c3592673250d09cf61f8cf906512801fe87abf9a287baefeea03b07256761986ab93d94250a1c9d0644ef5f8e7b9025399fde6eb055dfed8caa796098a4947c7b10aa2cf0cd128dd1b8cb833ddcbb8615aeb99c7048652402f6102b02083ebabdb97a17e1ca91a638a38f08ed32169d5daf70e570b75fd543fe40647785fcd1522f77426fa1eb2ac4b0f975148dc5d5f04319b8220",
            ),
        }
    }

    #[test]
    fn valid_proof_returns_valid() {
        let fixture = vector_mul_fixture();

        let outcome = verify_halo2_kzg(test_inputs(
            &fixture.params,
            &digest(&fixture.params),
            &fixture.vk,
            &digest(&fixture.vk),
            &fixture.circuit_info,
            &digest(&fixture.circuit_info),
            &fixture.public_inputs,
            &fixture.proof,
        ));

        assert!(matches!(outcome, VerifyOutcome::Valid));
    }

    #[test]
    fn valid_shplonk_proof_returns_valid() {
        let fixture = vector_mul_fixture();
        let params_digest = digest(&fixture.params);
        let vk_digest = digest(&fixture.vk);
        let circuit_info_digest = digest(&fixture.circuit_info);
        let mut inputs = test_inputs(
            &fixture.params,
            &params_digest,
            &fixture.vk,
            &vk_digest,
            &fixture.circuit_info,
            &circuit_info_digest,
            &fixture.public_inputs,
            &fixture.proof_shplonk,
        );
        inputs.kzg_variant = KZG_SHPLONK;

        let outcome = verify_halo2_kzg(inputs);

        assert!(matches!(outcome, VerifyOutcome::Valid));
    }

    #[test]
    fn k_is_only_used_when_present() {
        let fixture = vector_mul_fixture();
        let params_digest = digest(&fixture.params);
        let vk_digest = digest(&fixture.vk);
        let circuit_info_digest = digest(&fixture.circuit_info);
        let invalid_k = 5;

        let mut inputs = test_inputs(
            &fixture.params,
            &params_digest,
            &fixture.vk,
            &vk_digest,
            &fixture.circuit_info,
            &circuit_info_digest,
            &fixture.public_inputs,
            &fixture.proof,
        );
        inputs.k = None;

        assert!(matches!(verify_halo2_kzg(inputs), VerifyOutcome::Valid));

        let mut inputs = test_inputs(
            &fixture.params,
            &params_digest,
            &fixture.vk,
            &vk_digest,
            &fixture.circuit_info,
            &circuit_info_digest,
            &fixture.public_inputs,
            &fixture.proof,
        );
        inputs.k = Some(invalid_k);

        assert!(matches!(
            verify_halo2_kzg(inputs),
            VerifyOutcome::Abort(E_VERIFIER_UNSUPPORTED_CONFIG)
        ));
    }

    #[test]
    fn swapped_vk_and_circuit_info_aborts() {
        let fixture = vector_mul_fixture();

        let outcome = verify_halo2_kzg(test_inputs(
            &fixture.params,
            &digest(&fixture.params),
            &fixture.circuit_info,
            &digest(&fixture.circuit_info),
            &fixture.vk,
            &digest(&fixture.vk),
            &fixture.public_inputs,
            &fixture.proof,
        ));

        assert!(matches!(
            outcome,
            VerifyOutcome::Abort(E_VERIFIER_INPUT_ERROR)
        ));
    }

    #[test]
    fn wrong_digest_returns_invalid() {
        let params = [1u8, 2, 3];
        let vk = [4u8, 5, 6];
        let circuit_info = [7u8, 8, 9];
        let public_inputs = [];
        let proof = [];
        let wrong_digest = [0u8; 32];

        let outcome = verify_halo2_kzg(test_inputs(
            &params,
            &wrong_digest,
            &vk,
            &digest(&vk),
            &circuit_info,
            &digest(&circuit_info),
            &public_inputs,
            &proof,
        ));

        assert!(matches!(outcome, VerifyOutcome::Invalid));
    }

    #[test]
    fn malformed_proof_returns_invalid() {
        let fixture = vector_mul_fixture();
        let mut proof = fixture.proof.clone();
        proof[0] ^= 1;

        let outcome = verify_halo2_kzg(test_inputs(
            &fixture.params,
            &digest(&fixture.params),
            &fixture.vk,
            &digest(&fixture.vk),
            &fixture.circuit_info,
            &digest(&fixture.circuit_info),
            &fixture.public_inputs,
            &proof,
        ));

        assert!(matches!(outcome, VerifyOutcome::Invalid));
    }

    #[test]
    fn malformed_params_with_matching_digest_aborts_without_panic() {
        let fixture = vector_mul_fixture();
        let malformed_params = [0xff, 0x00, 0x00, 0x00];

        let outcome = verify_halo2_kzg(test_inputs(
            &malformed_params,
            &digest(&malformed_params),
            &fixture.vk,
            &digest(&fixture.vk),
            &fixture.circuit_info,
            &digest(&fixture.circuit_info),
            &fixture.public_inputs,
            &fixture.proof,
        ));

        assert!(matches!(
            outcome,
            VerifyOutcome::Abort(E_VERIFIER_INPUT_ERROR)
        ));
    }

    #[test]
    fn malformed_public_inputs_with_matching_digest_aborts_without_panic() {
        let fixture = vector_mul_fixture();
        let malformed_public_inputs = vec![0xff; 32];

        let outcome = verify_halo2_kzg(test_inputs(
            &fixture.params,
            &digest(&fixture.params),
            &fixture.vk,
            &digest(&fixture.vk),
            &fixture.circuit_info,
            &digest(&fixture.circuit_info),
            &malformed_public_inputs,
            &fixture.proof,
        ));

        assert!(matches!(
            outcome,
            VerifyOutcome::Abort(E_VERIFIER_INPUT_ERROR)
        ));
    }

    #[test]
    fn oversized_proof_aborts() {
        let params = [];
        let vk = [];
        let circuit_info = [];
        let public_inputs = [];
        let proof = vec![0; MAX_PROOF_BYTES + 1];

        let outcome = verify_halo2_kzg(test_inputs(
            &params,
            &digest(&params),
            &vk,
            &digest(&vk),
            &circuit_info,
            &digest(&circuit_info),
            &public_inputs,
            &proof,
        ));

        assert!(matches!(outcome, VerifyOutcome::Abort(E_INPUT_TOO_LARGE)));
    }

    #[test]
    fn malformed_inputs_abort_without_unwinding() {
        let corpus = [
            vec![],
            vec![0],
            vec![0xff],
            vec![1, 2, 3, 4],
            vec![0; 31],
            vec![0; 64],
            vec![0, 1, 0, 1, 0, 1, 0, 1],
        ];

        for bytes in corpus {
            let outcome = verify_halo2_kzg(test_inputs(
                &bytes,
                &digest(&bytes),
                &bytes,
                &digest(&bytes),
                &bytes,
                &digest(&bytes),
                &bytes,
                &bytes,
            ));

            assert!(matches!(
                outcome,
                VerifyOutcome::Abort(
                    E_VERIFIER_INPUT_ERROR
                        | E_VERIFIER_UNSUPPORTED_CONFIG
                        | E_VERIFIER_INTERNAL_ERROR
                        | E_VERIFIER_PANICKED
                )
            ));
        }
    }

    #[test]
    fn rayon_thread_count_determinism() {
        let current_exe = env::current_exe().expect("current test binary path");
        let mut baseline = None;

        for threads in ["1", "2", "4", "8", "16", "32", "64"] {
            let output = Command::new(&current_exe)
                .arg("--nocapture")
                .arg("rayon_thread_count_determinism_child")
                .env(RAYON_DETERMINISM_CHILD_ENV, "1")
                .env("RAYON_NUM_THREADS", threads)
                .output()
                .expect("run child determinism test");

            assert!(
                output.status.success(),
                "child test failed for RAYON_NUM_THREADS={threads}\nstdout:\n{}\nstderr:\n{}",
                String::from_utf8_lossy(&output.stdout),
                String::from_utf8_lossy(&output.stderr),
            );

            let stdout = String::from_utf8(output.stdout).expect("child stdout is utf8");
            let fingerprint = stdout
                .lines()
                .find_map(|line| line.strip_prefix(RAYON_DETERMINISM_OUTPUT_PREFIX))
                .unwrap_or_else(|| {
                    panic!("missing determinism fingerprint for RAYON_NUM_THREADS={threads}")
                });

            if let Some(baseline) = &baseline {
                assert_eq!(
                    fingerprint, baseline,
                    "different verifier outcomes with RAYON_NUM_THREADS={threads}",
                );
            } else {
                baseline = Some(fingerprint.to_owned());
            }
        }
    }

    #[test]
    fn rayon_thread_count_determinism_child() {
        if env::var_os(RAYON_DETERMINISM_CHILD_ENV).is_none() {
            return;
        }

        println!(
            "{RAYON_DETERMINISM_OUTPUT_PREFIX}{}",
            determinism_outcome_fingerprint()
        );
    }

    fn determinism_outcome_fingerprint() -> String {
        let fixture = vector_mul_fixture();
        let mut malformed_proof = fixture.proof.clone();
        malformed_proof[0] ^= 1;
        let wrong_digest = [0u8; 32];

        let mut outcomes = vec![
            outcome_code(verify_halo2_kzg(test_inputs(
                &fixture.params,
                &digest(&fixture.params),
                &fixture.vk,
                &digest(&fixture.vk),
                &fixture.circuit_info,
                &digest(&fixture.circuit_info),
                &fixture.public_inputs,
                &fixture.proof,
            ))),
            outcome_code(verify_halo2_kzg(test_inputs(
                &fixture.params,
                &digest(&fixture.params),
                &fixture.vk,
                &digest(&fixture.vk),
                &fixture.circuit_info,
                &digest(&fixture.circuit_info),
                &fixture.public_inputs,
                &malformed_proof,
            ))),
            outcome_code(verify_halo2_kzg(test_inputs(
                &fixture.params,
                &wrong_digest,
                &fixture.vk,
                &digest(&fixture.vk),
                &fixture.circuit_info,
                &digest(&fixture.circuit_info),
                &fixture.public_inputs,
                &fixture.proof,
            ))),
            outcome_code(verify_halo2_kzg(test_inputs(
                &fixture.params,
                &digest(&fixture.params),
                &fixture.circuit_info,
                &digest(&fixture.circuit_info),
                &fixture.vk,
                &digest(&fixture.vk),
                &fixture.public_inputs,
                &fixture.proof,
            ))),
        ];

        let malformed_corpus = [
            vec![],
            vec![0],
            vec![0xff],
            vec![1, 2, 3, 4],
            vec![0; 31],
            vec![0; 64],
            vec![0, 1, 0, 1, 0, 1, 0, 1],
        ];

        for bytes in malformed_corpus {
            outcomes.push(outcome_code(verify_halo2_kzg(test_inputs(
                &bytes,
                &digest(&bytes),
                &bytes,
                &digest(&bytes),
                &bytes,
                &digest(&bytes),
                &bytes,
                &bytes,
            ))));
        }

        outcomes.join(",")
    }

    fn outcome_code(outcome: VerifyOutcome) -> String {
        match outcome {
            VerifyOutcome::Valid => "valid".to_string(),
            VerifyOutcome::Invalid => "invalid".to_string(),
            VerifyOutcome::Abort(code) => format!("abort:{code}"),
        }
    }

    fn parse_move_u64_const(source: &str, name: &str) -> Result<u64, String> {
        let prefix = format!("const {name}: u64 = ");
        let expression = source
            .lines()
            .find_map(|line| line.trim().strip_prefix(&prefix))
            .and_then(|line| line.strip_suffix(';'))
            .ok_or_else(|| format!("missing Move const {name}"))?;

        expression
            .split('*')
            .map(|part| {
                part.trim()
                    .parse::<u64>()
                    .map_err(|_| format!("invalid Move const {name}: {expression}"))
            })
            .product::<Result<u64, _>>()
    }
}
