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

use std::bcs;
use sui::event;
use sui::hash;

/// KZG proof using the GWC multi-opening scheme.
const KZG_GWC: u8 = 0;

/// KZG proof using the Shplonk multi-opening scheme.
const KZG_SHPLONK: u8 = 1;

/// Version of the byte-level verifier ABI exposed by this module.
const ABI_VERSION: u64 = 1;

/// Version of the object-backed artifact format exposed by this module.
const ARTIFACT_VERSION: u16 = 1;

/// Oldest object-backed artifact format version still accepted by this module.
const MIN_SUPPORTED_ARTIFACT_VERSION: u16 = 1;

/// Version of the event schemas emitted by this module.
const EVENT_VERSION: u16 = 1;

const MAX_PARAMS_BYTES: u64 = 240 * 1024;
const MAX_VK_BYTES: u64 = 240 * 1024;
const MAX_CIRCUIT_INFO_BYTES: u64 = 240 * 1024;
const MAX_PROOF_BYTES: u64 = 96 * 1024;
const MAX_PUBLIC_INPUTS_BYTES: u64 = 16 * 1024;
// Keep each pure vector<u8> below Sui's 16 KiB max_pure_argument_size,
// leaving BCS length-prefix headroom.
const MAX_CHUNK_BYTES: u64 = 15 * 1024;
const HALO2_PUBLIC_INPUT_SCALAR_BYTES: u64 = 32;

const KIND_PARAMS: u8 = 0;
const KIND_VK: u8 = 1;
const KIND_CIRCUIT_INFO: u8 = 2;

/// The supplied KZG opening variant is not supported by this module.
const EUnsupportedKzgVariant: u64 = 1;

/// `params_digest`, `vk_digest`, and `circuit_info_digest` must each be exactly 32 bytes.
const EInvalidDigestLength: u64 = 2;

/// Serialized proof artifacts must be created by the supported artifact format version.
const EUnsupportedVersion: u64 = 3;

/// Object-backed verification entry point returned `false`.
const EVerifyProof: u64 = 4;

/// A serialized verifier input exceeds the framework API limit.
const EInputTooLarge: u64 = 5;

/// A chunk exceeds Sui's pure argument limit allowance.
const EChunkTooLarge: u64 = 6;

/// A chunk builder was finalized as the wrong artifact type.
const EWrongArtifactKind: u64 = 7;

/// The finalized artifact digest does not match the expected digest.
const EDigestMismatch: u64 = 8;

/// Empty chunk builders cannot be finalized into verifier artifacts.
const EEmptyArtifact: u64 = 9;

/// Every serialized public input scalar must be exactly 32 bytes.
const EInvalidPublicInputScalarLength: u64 = 10;

public struct SerializedParams has key, store {
    id: UID,
    version: u16,
    params_bytes: vector<u8>,
    params_digest: vector<u8>,
}

public struct SerializedVK has key, store {
    id: UID,
    version: u16,
    vk_bytes: vector<u8>,
    vk_digest: vector<u8>,
}

public struct SerializedCircuit has key, store {
    id: UID,
    version: u16,
    circuit_bytes: vector<u8>,
    circuit_digest: vector<u8>,
}

public struct PublicInputs has drop {
    columns: vector<vector<vector<u8>>>,
}

public struct ArtifactBuilder has key, store {
    id: UID,
    kind: u8,
    bytes: vector<u8>,
    max_bytes: u64,
}

public struct BuilderCreated has copy, drop {
    version: u16,
    builder_id: ID,
    kind: u8,
    max_bytes: u64,
    owner: address,
}

public struct ChunkAppended has copy, drop {
    version: u16,
    builder_id: ID,
    kind: u8,
    chunk_len: u64,
    total_len: u64,
}

public struct ArtifactFinalized has copy, drop {
    version: u16,
    builder_id: ID,
    artifact_id: ID,
    kind: u8,
    total_len: u64,
    digest: vector<u8>,
    owner: address,
}

/// Returns the byte-level verifier ABI version.
public fun abi_version(): u64 { ABI_VERSION }

/// Returns the object-backed artifact format version.
public fun artifact_version(): u16 { ARTIFACT_VERSION }

/// Returns the version of event schemas emitted by this module.
public fun event_version(): u16 { EVENT_VERSION }

/// Returns the KZG variant identifier for GWC proofs.
public fun kzg_gwc(): u8 { KZG_GWC }

/// Returns the KZG variant identifier for Shplonk proofs.
public fun kzg_shplonk(): u8 { KZG_SHPLONK }

public fun max_params_bytes(): u64 { MAX_PARAMS_BYTES }

public fun max_vk_bytes(): u64 { MAX_VK_BYTES }

public fun max_circuit_info_bytes(): u64 { MAX_CIRCUIT_INFO_BYTES }

public fun max_proof_bytes(): u64 { MAX_PROOF_BYTES }

public fun max_public_inputs_bytes(): u64 { MAX_PUBLIC_INPUTS_BYTES }

public fun max_chunk_bytes(): u64 { MAX_CHUNK_BYTES }

public fun kind_params(): u8 { KIND_PARAMS }

public fun kind_vk(): u8 { KIND_VK }

public fun kind_circuit_info(): u8 { KIND_CIRCUIT_INFO }

public fun public_inputs_from_bytes(bytes: vector<vector<vector<u8>>>): PublicInputs {
    assert_public_inputs_shape(&bytes);
    assert_public_inputs_size(&bcs::to_bytes(&bytes));
    PublicInputs { columns: bytes }
}

public fun public_inputs_to_bytes(public_inputs: &PublicInputs): vector<vector<vector<u8>>> {
    public_inputs.columns
}

public fun public_inputs_to_bcs_bytes(public_inputs: &PublicInputs): vector<u8> {
    bcs::to_bytes(&public_inputs.columns)
}

public fun new_serialized_params(
    params_bytes: vector<u8>,
    ctx: &mut TxContext,
): SerializedParams {
    assert_params_size(&params_bytes);
    let params_digest = hash::blake2b256(&params_bytes);
    SerializedParams {
        id: object::new(ctx),
        version: ARTIFACT_VERSION,
        params_bytes,
        params_digest,
    }
}

entry fun publish_serialized_params(
    params_bytes: vector<u8>,
    ctx: &mut TxContext,
) {
    transfer::transfer(
        new_serialized_params(params_bytes, ctx),
        ctx.sender(),
    )
}

public fun serialized_params_version(params: &SerializedParams): u16 {
    params.version
}

fun assert_supported_params_version(params: &SerializedParams) {
    assert_supported_artifact_version(params.version)
}

#[test_only]
public fun set_serialized_params_version_for_test(params: &mut SerializedParams, version: u16) {
    params.version = version
}

public fun get_serialized_params(params: &SerializedParams): vector<u8> {
    params.params_bytes
}

public fun get_serialized_params_digest(params: &SerializedParams): vector<u8> {
    params.params_digest
}

public fun destroy_serialized_params(params: SerializedParams) {
    let SerializedParams { id, version: _, params_bytes: _, params_digest: _ } = params;
    object::delete(id)
}

public fun new_serialized_vk(
    vk_bytes: vector<u8>,
    ctx: &mut TxContext,
): SerializedVK {
    assert_vk_size(&vk_bytes);
    let vk_digest = hash::blake2b256(&vk_bytes);
    SerializedVK {
        id: object::new(ctx),
        version: ARTIFACT_VERSION,
        vk_bytes,
        vk_digest,
    }
}

entry fun publish_serialized_vk(
    vk_bytes: vector<u8>,
    ctx: &mut TxContext,
) {
    transfer::transfer(new_serialized_vk(vk_bytes, ctx), ctx.sender())
}

public fun serialized_vk_version(vk: &SerializedVK): u16 {
    vk.version
}

#[test_only]
public fun set_serialized_vk_version_for_test(vk: &mut SerializedVK, version: u16) {
    vk.version = version
}

public fun get_serialized_vk(vk: &SerializedVK): vector<u8> {
    vk.vk_bytes
}

public fun get_serialized_vk_digest(vk: &SerializedVK): vector<u8> {
    vk.vk_digest
}

public fun destroy_serialized_vk(vk: SerializedVK) {
    let SerializedVK { id, version: _, vk_bytes: _, vk_digest: _ } = vk;
    object::delete(id)
}

public fun new_serialized_circuit(
    circuit_bytes: vector<u8>,
    ctx: &mut TxContext,
): SerializedCircuit {
    assert_circuit_info_size(&circuit_bytes);
    let circuit_digest = hash::blake2b256(&circuit_bytes);
    SerializedCircuit {
        id: object::new(ctx),
        version: ARTIFACT_VERSION,
        circuit_bytes,
        circuit_digest,
    }
}

entry fun publish_serialized_circuit(
    circuit_bytes: vector<u8>,
    ctx: &mut TxContext,
) {
    transfer::transfer(new_serialized_circuit(circuit_bytes, ctx), ctx.sender())
}

public fun serialized_circuit_version(circuit: &SerializedCircuit): u16 {
    circuit.version
}

#[test_only]
public fun set_serialized_circuit_version_for_test(circuit: &mut SerializedCircuit, version: u16) {
    circuit.version = version
}

public fun get_serialized_circuit(circuit: &SerializedCircuit): vector<u8> {
    circuit.circuit_bytes
}

public fun get_serialized_circuit_digest(circuit: &SerializedCircuit): vector<u8> {
    circuit.circuit_digest
}

public fun destroy_serialized_circuit(circuit: SerializedCircuit) {
    let SerializedCircuit { id, version: _, circuit_bytes: _, circuit_digest: _ } = circuit;
    object::delete(id)
}

public fun new_params_builder(ctx: &mut TxContext): ArtifactBuilder {
    new_builder(KIND_PARAMS, MAX_PARAMS_BYTES, ctx)
}

public fun new_vk_builder(ctx: &mut TxContext): ArtifactBuilder {
    new_builder(KIND_VK, MAX_VK_BYTES, ctx)
}

public fun new_circuit_info_builder(ctx: &mut TxContext): ArtifactBuilder {
    new_builder(KIND_CIRCUIT_INFO, MAX_CIRCUIT_INFO_BYTES, ctx)
}

entry fun publish_params_builder(ctx: &mut TxContext) {
    transfer::transfer(new_params_builder(ctx), ctx.sender())
}

entry fun publish_vk_builder(ctx: &mut TxContext) {
    transfer::transfer(new_vk_builder(ctx), ctx.sender())
}

entry fun publish_circuit_info_builder(ctx: &mut TxContext) {
    transfer::transfer(new_circuit_info_builder(ctx), ctx.sender())
}

public fun append_chunk(builder: &mut ArtifactBuilder, chunk: vector<u8>) {
    let chunk_len = chunk.length();
    assert_chunk_size(&chunk);
    assert_total_size(builder.bytes.length() + chunk.length(), builder.max_bytes);
    builder.bytes.append(chunk);
    event::emit(ChunkAppended {
        version: EVENT_VERSION,
        builder_id: object::uid_to_inner(&builder.id),
        kind: builder.kind,
        chunk_len,
        total_len: builder.bytes.length(),
    })
}

public fun finalize_params(
    builder: ArtifactBuilder,
    expected_digest: vector<u8>,
    ctx: &mut TxContext,
): SerializedParams {
    let (builder_id, bytes) = finish(builder, KIND_PARAMS, expected_digest);
    let params = new_serialized_params(bytes, ctx);
    emit_finalized(
        builder_id,
        object::id(&params),
        KIND_PARAMS,
        get_serialized_params_digest(&params),
        get_serialized_params(&params).length(),
        ctx,
    );
    params
}

public fun finalize_vk(
    builder: ArtifactBuilder,
    expected_digest: vector<u8>,
    ctx: &mut TxContext,
): SerializedVK {
    let (builder_id, bytes) = finish(builder, KIND_VK, expected_digest);
    let vk = new_serialized_vk(bytes, ctx);
    emit_finalized(
        builder_id,
        object::id(&vk),
        KIND_VK,
        get_serialized_vk_digest(&vk),
        get_serialized_vk(&vk).length(),
        ctx,
    );
    vk
}

public fun finalize_circuit_info(
    builder: ArtifactBuilder,
    expected_digest: vector<u8>,
    ctx: &mut TxContext,
): SerializedCircuit {
    let (builder_id, bytes) = finish(builder, KIND_CIRCUIT_INFO, expected_digest);
    let circuit = new_serialized_circuit(bytes, ctx);
    emit_finalized(
        builder_id,
        object::id(&circuit),
        KIND_CIRCUIT_INFO,
        get_serialized_circuit_digest(&circuit),
        get_serialized_circuit(&circuit).length(),
        ctx,
    );
    circuit
}

entry fun finalize_params_to_sender(
    builder: ArtifactBuilder,
    expected_digest: vector<u8>,
    ctx: &mut TxContext,
) {
    transfer::public_transfer(finalize_params(builder, expected_digest, ctx), ctx.sender())
}

entry fun finalize_vk_to_sender(
    builder: ArtifactBuilder,
    expected_digest: vector<u8>,
    ctx: &mut TxContext,
) {
    transfer::public_transfer(finalize_vk(builder, expected_digest, ctx), ctx.sender())
}

entry fun finalize_circuit_info_to_sender(
    builder: ArtifactBuilder,
    expected_digest: vector<u8>,
    ctx: &mut TxContext,
) {
    transfer::public_transfer(finalize_circuit_info(builder, expected_digest, ctx), ctx.sender())
}

entry fun finalize_params_and_freeze(
    builder: ArtifactBuilder,
    expected_digest: vector<u8>,
    ctx: &mut TxContext,
) {
    transfer::public_freeze_object(finalize_params(builder, expected_digest, ctx))
}

entry fun finalize_vk_and_freeze(
    builder: ArtifactBuilder,
    expected_digest: vector<u8>,
    ctx: &mut TxContext,
) {
    transfer::public_freeze_object(finalize_vk(builder, expected_digest, ctx))
}

entry fun finalize_circuit_info_and_freeze(
    builder: ArtifactBuilder,
    expected_digest: vector<u8>,
    ctx: &mut TxContext,
) {
    transfer::public_freeze_object(finalize_circuit_info(builder, expected_digest, ctx))
}

public fun builder_kind(builder: &ArtifactBuilder): u8 {
    builder.kind
}

public fun builder_len(builder: &ArtifactBuilder): u64 {
    builder.bytes.length()
}

public fun destroy_builder(builder: ArtifactBuilder) {
    let ArtifactBuilder { id, kind: _, bytes: _, max_bytes: _ } = builder;
    object::delete(id)
}

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
    assert_params_size(&params);
    assert_vk_size(&vk);
    assert_circuit_info_size(&circuit_info);
    assert_public_inputs_size(&public_inputs);
    assert_proof_size(&proof);

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

public fun verify_artifact_proof(
    params: &SerializedParams,
    vk: &SerializedVK,
    circuit: &SerializedCircuit,
    public_inputs: PublicInputs,
    proof: vector<u8>,
    kzg_variant: u8,
    k_present: bool,
    k: u32,
): bool {
    assert_supported_params_version(params);
    assert_supported_vk_version(vk);
    assert_supported_circuit_version(circuit);
    assert_proof_size(&proof);

    let public_inputs_bytes = public_inputs_to_bcs_bytes(&public_inputs);
    assert_public_inputs_size(&public_inputs_bytes);

    verify_proof(
        get_serialized_params(params),
        get_serialized_params_digest(params),
        get_serialized_vk(vk),
        get_serialized_vk_digest(vk),
        get_serialized_circuit(circuit),
        get_serialized_circuit_digest(circuit),
        public_inputs_bytes,
        proof,
        kzg_variant,
        k_present,
        k,
    )
}

entry fun verify_with_artifacts(
    params: &SerializedParams,
    vk: &SerializedVK,
    circuit: &SerializedCircuit,
    public_inputs: vector<vector<vector<u8>>>,
    proof: vector<u8>,
    kzg_variant: u8,
    k_present: bool,
    k: u32,
) {
    let public_inputs = public_inputs_from_bytes(public_inputs);
    assert!(
        verify_artifact_proof(
            params,
            vk,
            circuit,
            public_inputs,
            proof,
            kzg_variant,
            k_present,
            k,
        ),
        EVerifyProof,
    )
}

fun assert_supported_vk_version(vk: &SerializedVK) {
    assert_supported_artifact_version(vk.version)
}

fun assert_supported_circuit_version(circuit: &SerializedCircuit) {
    assert_supported_artifact_version(circuit.version)
}

fun assert_supported_artifact_version(version: u16) {
    assert!(
        MIN_SUPPORTED_ARTIFACT_VERSION <= version && version <= ARTIFACT_VERSION,
        EUnsupportedVersion,
    )
}

fun assert_params_size(bytes: &vector<u8>) {
    assert!(bytes.length() <= MAX_PARAMS_BYTES, EInputTooLarge)
}

fun assert_vk_size(bytes: &vector<u8>) {
    assert!(bytes.length() <= MAX_VK_BYTES, EInputTooLarge)
}

fun assert_circuit_info_size(bytes: &vector<u8>) {
    assert!(bytes.length() <= MAX_CIRCUIT_INFO_BYTES, EInputTooLarge)
}

fun assert_proof_size(bytes: &vector<u8>) {
    assert!(bytes.length() <= MAX_PROOF_BYTES, EInputTooLarge)
}

fun assert_public_inputs_size(bytes: &vector<u8>) {
    assert!(bytes.length() <= MAX_PUBLIC_INPUTS_BYTES, EInputTooLarge)
}

fun assert_public_inputs_shape(columns: &vector<vector<vector<u8>>>) {
    let mut i = 0;
    while (i < columns.length()) {
        let column = &columns[i];
        let mut j = 0;
        while (j < column.length()) {
            assert!(
                column[j].length() == HALO2_PUBLIC_INPUT_SCALAR_BYTES,
                EInvalidPublicInputScalarLength,
            );
            j = j + 1;
        };
        i = i + 1;
    }
}

fun assert_chunk_size(bytes: &vector<u8>) {
    assert!(bytes.length() <= MAX_CHUNK_BYTES, EChunkTooLarge)
}

fun assert_total_size(total_bytes: u64, max_bytes: u64) {
    assert!(total_bytes <= max_bytes, EInputTooLarge)
}

fun new_builder(kind: u8, max_bytes: u64, ctx: &mut TxContext): ArtifactBuilder {
    let builder = ArtifactBuilder {
        id: object::new(ctx),
        kind,
        bytes: vector[],
        max_bytes,
    };
    event::emit(BuilderCreated {
        version: EVENT_VERSION,
        builder_id: object::id(&builder),
        kind,
        max_bytes,
        owner: ctx.sender(),
    });
    builder
}

fun finish(
    builder: ArtifactBuilder,
    expected_kind: u8,
    expected_digest: vector<u8>,
): (ID, vector<u8>) {
    let ArtifactBuilder { id, kind, bytes, max_bytes: _ } = builder;
    let builder_id = object::uid_to_inner(&id);
    object::delete(id);
    assert!(kind == expected_kind, EWrongArtifactKind);
    assert!(!bytes.is_empty(), EEmptyArtifact);
    assert!(hash::blake2b256(&bytes) == expected_digest, EDigestMismatch);
    (builder_id, bytes)
}

fun emit_finalized(
    builder_id: ID,
    artifact_id: ID,
    kind: u8,
    digest: vector<u8>,
    total_len: u64,
    ctx: &TxContext,
) {
    event::emit(ArtifactFinalized {
        version: EVENT_VERSION,
        builder_id,
        artifact_id,
        kind,
        total_len,
        digest,
        owner: ctx.sender(),
    })
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
