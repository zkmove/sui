// Copyright (c) zkMove Authors
// SPDX-License-Identifier: Apache-2.0

/// Verifies Halo2 proofs over BN254 with KZG commitments.
///
/// The verifier accepts serialized KZG parameters, a serialized Halo2 verifying key, serialized
/// circuit metadata, public inputs, and proof bytes produced by the matching Halo2 toolchain. The
/// large static inputs are accompanied by 32-byte Blake2b-256 digests; the native verifier checks
/// those digests before attempting proof verification.
///
/// Both GWC and Shplonk KZG multi-opening variants are supported. Verification returns `true` for
/// a valid proof and `false` for a proof or digest mismatch. Malformed verifier inputs, oversized
/// inputs, unsupported protocol configuration, or native verifier failures may abort.
module sui::halo2_kzg;

/// The supplied KZG opening variant is not supported by this module.
const EUnsupportedKzgVariant: u64 = 1;

/// `params_digest`, `vk_digest`, and `circuit_info_digest` must each be exactly 32 bytes.
const EInvalidDigestLength: u64 = 2;

/// KZG proof using the GWC multi-opening scheme.
const KZG_GWC: u8 = 0;

/// KZG proof using the Shplonk multi-opening scheme.
const KZG_SHPLONK: u8 = 1;

/// Version of the byte-level verifier ABI exposed by this module.
const ABI_VERSION: u64 = 1;

/// Returns the byte-level verifier ABI version.
public fun abi_version(): u64 { ABI_VERSION }

/// Returns the KZG variant identifier for GWC proofs.
public fun kzg_gwc(): u8 { KZG_GWC }

/// Returns the KZG variant identifier for Shplonk proofs.
public fun kzg_shplonk(): u8 { KZG_SHPLONK }

/// Verifies a Halo2 KZG proof.
///
/// @param params Serialized KZG verifier parameters.
/// @param params_digest Blake2b-256 digest of `params`.
/// @param vk Serialized Halo2 verifying key.
/// @param vk_digest Blake2b-256 digest of `vk`.
/// @param circuit_info Serialized circuit metadata used to reconstruct the verifier constraint system.
/// @param circuit_info_digest Blake2b-256 digest of `circuit_info`.
/// @param public_inputs Serialized public inputs for the proof.
/// @param proof Serialized Halo2 proof bytes.
/// @param kzg_variant KZG opening variant. Use `kzg_gwc` or `kzg_shplonk`.
/// @param k_present Whether to downsize the serialized parameters to `k` before verification.
/// @param k Target parameter size when `k_present` is `true`. When `k_present` is `false`, `k` is ignored and may be any `u32`.
///
/// Returns `true` when the proof verifies and `false` when the proof is invalid or any supplied
/// digest does not match its corresponding byte vector.
///
/// Aborts if a digest is not 32 bytes, `kzg_variant` is unsupported, the native verifier is not
/// enabled by protocol config, input byte limits are exceeded, or the native verifier cannot
/// interpret the supplied bytes.
public fun verify_proof(
    params: vector<u8>,
    params_digest: vector<u8>,
    vk: vector<u8>,
    vk_digest: vector<u8>,
    circuit_info: vector<u8>,
    circuit_info_digest: vector<u8>,
    public_inputs: vector<u8>,
    proof: vector<u8>,
    kzg_variant: u8,
    k_present: bool,
    k: u32,
): bool {
    assert!(params_digest.length() == 32, EInvalidDigestLength);
    assert!(vk_digest.length() == 32, EInvalidDigestLength);
    assert!(circuit_info_digest.length() == 32, EInvalidDigestLength);
    assert!(
        kzg_variant == KZG_GWC || kzg_variant == KZG_SHPLONK,
        EUnsupportedKzgVariant,
    );

    verify_proof_internal(
        params,
        params_digest,
        vk,
        vk_digest,
        circuit_info,
        circuit_info_digest,
        public_inputs,
        proof,
        kzg_variant,
        k_present,
        k,
    )
}

/// Native verifier entry point. Call `verify_proof` instead so cheap argument checks happen in Move
/// before entering the native verifier.
native fun verify_proof_internal(
    params: vector<u8>,
    params_digest: vector<u8>,
    vk: vector<u8>,
    vk_digest: vector<u8>,
    circuit_info: vector<u8>,
    circuit_info_digest: vector<u8>,
    public_inputs: vector<u8>,
    proof: vector<u8>,
    kzg_variant: u8,
    k_present: bool,
    k: u32,
): bool;
