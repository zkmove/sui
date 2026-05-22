---
title: Module `sui::halo2_kzg`
---

<a name="sui_halo2_kzg"></a>

Verifies Halo2 proofs over BN254 with KZG commitments.

The verifier accepts serialized KZG parameters, a serialized Halo2 verifying key, serialized
circuit metadata, public inputs, and proof bytes produced by the matching Halo2 toolchain. The
large static inputs are accompanied by 32-byte Blake2b-256 digests; the native verifier checks
those digests before attempting proof verification.

Both GWC and Shplonk KZG multi-opening variants are supported. Verification returns <code><b>true</b></code> for
a valid proof and <code><b>false</b></code> for a proof or digest mismatch. Malformed verifier inputs, oversized
inputs, unsupported protocol configuration, or native verifier failures may abort.


-  [Struct `SerializedParams`](#sui_halo2_kzg_SerializedParams)
-  [Struct `SerializedVK`](#sui_halo2_kzg_SerializedVK)
-  [Struct `SerializedCircuit`](#sui_halo2_kzg_SerializedCircuit)
-  [Struct `PublicInputs`](#sui_halo2_kzg_PublicInputs)
-  [Struct `ArtifactBuilder`](#sui_halo2_kzg_ArtifactBuilder)
-  [Struct `BuilderCreated`](#sui_halo2_kzg_BuilderCreated)
-  [Struct `ChunkAppended`](#sui_halo2_kzg_ChunkAppended)
-  [Struct `ArtifactFinalized`](#sui_halo2_kzg_ArtifactFinalized)
-  [Constants](#@Constants_0)
-  [Function `abi_version`](#sui_halo2_kzg_abi_version)
-  [Function `artifact_version`](#sui_halo2_kzg_artifact_version)
-  [Function `kzg_gwc`](#sui_halo2_kzg_kzg_gwc)
-  [Function `kzg_shplonk`](#sui_halo2_kzg_kzg_shplonk)
-  [Function `native_abi_version`](#sui_halo2_kzg_native_abi_version)
-  [Function `max_params_bytes`](#sui_halo2_kzg_max_params_bytes)
-  [Function `max_vk_bytes`](#sui_halo2_kzg_max_vk_bytes)
-  [Function `max_circuit_info_bytes`](#sui_halo2_kzg_max_circuit_info_bytes)
-  [Function `max_proof_bytes`](#sui_halo2_kzg_max_proof_bytes)
-  [Function `max_public_inputs_bytes`](#sui_halo2_kzg_max_public_inputs_bytes)
-  [Function `max_chunk_bytes`](#sui_halo2_kzg_max_chunk_bytes)
-  [Function `kind_params`](#sui_halo2_kzg_kind_params)
-  [Function `kind_vk`](#sui_halo2_kzg_kind_vk)
-  [Function `kind_circuit_info`](#sui_halo2_kzg_kind_circuit_info)
-  [Function `public_inputs_from_bytes`](#sui_halo2_kzg_public_inputs_from_bytes)
-  [Function `public_inputs_to_bytes`](#sui_halo2_kzg_public_inputs_to_bytes)
-  [Function `public_inputs_to_bcs_bytes`](#sui_halo2_kzg_public_inputs_to_bcs_bytes)
-  [Function `new_serialized_params`](#sui_halo2_kzg_new_serialized_params)
-  [Function `publish_serialized_params`](#sui_halo2_kzg_publish_serialized_params)
-  [Function `serialized_params_version`](#sui_halo2_kzg_serialized_params_version)
-  [Function `assert_supported_params_version`](#sui_halo2_kzg_assert_supported_params_version)
-  [Function `get_serialized_params`](#sui_halo2_kzg_get_serialized_params)
-  [Function `get_serialized_params_digest`](#sui_halo2_kzg_get_serialized_params_digest)
-  [Function `destroy_serialized_params`](#sui_halo2_kzg_destroy_serialized_params)
-  [Function `new_serialized_vk`](#sui_halo2_kzg_new_serialized_vk)
-  [Function `publish_serialized_vk`](#sui_halo2_kzg_publish_serialized_vk)
-  [Function `serialized_vk_version`](#sui_halo2_kzg_serialized_vk_version)
-  [Function `get_serialized_vk`](#sui_halo2_kzg_get_serialized_vk)
-  [Function `get_serialized_vk_digest`](#sui_halo2_kzg_get_serialized_vk_digest)
-  [Function `destroy_serialized_vk`](#sui_halo2_kzg_destroy_serialized_vk)
-  [Function `new_serialized_circuit`](#sui_halo2_kzg_new_serialized_circuit)
-  [Function `publish_serialized_circuit`](#sui_halo2_kzg_publish_serialized_circuit)
-  [Function `serialized_circuit_version`](#sui_halo2_kzg_serialized_circuit_version)
-  [Function `get_serialized_circuit`](#sui_halo2_kzg_get_serialized_circuit)
-  [Function `get_serialized_circuit_digest`](#sui_halo2_kzg_get_serialized_circuit_digest)
-  [Function `destroy_serialized_circuit`](#sui_halo2_kzg_destroy_serialized_circuit)
-  [Function `new_params_builder`](#sui_halo2_kzg_new_params_builder)
-  [Function `new_vk_builder`](#sui_halo2_kzg_new_vk_builder)
-  [Function `new_circuit_info_builder`](#sui_halo2_kzg_new_circuit_info_builder)
-  [Function `publish_params_builder`](#sui_halo2_kzg_publish_params_builder)
-  [Function `publish_vk_builder`](#sui_halo2_kzg_publish_vk_builder)
-  [Function `publish_circuit_info_builder`](#sui_halo2_kzg_publish_circuit_info_builder)
-  [Function `append_chunk`](#sui_halo2_kzg_append_chunk)
-  [Function `finalize_params`](#sui_halo2_kzg_finalize_params)
-  [Function `finalize_vk`](#sui_halo2_kzg_finalize_vk)
-  [Function `finalize_circuit_info`](#sui_halo2_kzg_finalize_circuit_info)
-  [Function `finalize_params_to_sender`](#sui_halo2_kzg_finalize_params_to_sender)
-  [Function `finalize_vk_to_sender`](#sui_halo2_kzg_finalize_vk_to_sender)
-  [Function `finalize_circuit_info_to_sender`](#sui_halo2_kzg_finalize_circuit_info_to_sender)
-  [Function `finalize_params_and_freeze`](#sui_halo2_kzg_finalize_params_and_freeze)
-  [Function `finalize_vk_and_freeze`](#sui_halo2_kzg_finalize_vk_and_freeze)
-  [Function `finalize_circuit_info_and_freeze`](#sui_halo2_kzg_finalize_circuit_info_and_freeze)
-  [Function `builder_kind`](#sui_halo2_kzg_builder_kind)
-  [Function `builder_len`](#sui_halo2_kzg_builder_len)
-  [Function `destroy_builder`](#sui_halo2_kzg_destroy_builder)
-  [Function `verify_proof`](#sui_halo2_kzg_verify_proof)
-  [Function `verify_proof_bytes`](#sui_halo2_kzg_verify_proof_bytes)
-  [Function `verify_artifact_proof`](#sui_halo2_kzg_verify_artifact_proof)
-  [Function `verify_with_artifacts`](#sui_halo2_kzg_verify_with_artifacts)
-  [Function `assert_supported_vk_version`](#sui_halo2_kzg_assert_supported_vk_version)
-  [Function `assert_supported_circuit_version`](#sui_halo2_kzg_assert_supported_circuit_version)
-  [Function `assert_params_size`](#sui_halo2_kzg_assert_params_size)
-  [Function `assert_vk_size`](#sui_halo2_kzg_assert_vk_size)
-  [Function `assert_circuit_info_size`](#sui_halo2_kzg_assert_circuit_info_size)
-  [Function `assert_proof_size`](#sui_halo2_kzg_assert_proof_size)
-  [Function `assert_public_inputs_size`](#sui_halo2_kzg_assert_public_inputs_size)
-  [Function `assert_chunk_size`](#sui_halo2_kzg_assert_chunk_size)
-  [Function `assert_total_size`](#sui_halo2_kzg_assert_total_size)
-  [Function `new_builder`](#sui_halo2_kzg_new_builder)
-  [Function `finish`](#sui_halo2_kzg_finish)
-  [Function `emit_finalized`](#sui_halo2_kzg_emit_finalized)
-  [Function `verify_proof_internal`](#sui_halo2_kzg_verify_proof_internal)


<pre><code><b>use</b> <a href="../std/address.md#std_address">std::address</a>;
<b>use</b> <a href="../std/ascii.md#std_ascii">std::ascii</a>;
<b>use</b> <a href="../std/bcs.md#std_bcs">std::bcs</a>;
<b>use</b> <a href="../std/option.md#std_option">std::option</a>;
<b>use</b> <a href="../std/string.md#std_string">std::string</a>;
<b>use</b> <a href="../std/type_name.md#std_type_name">std::type_name</a>;
<b>use</b> <a href="../std/vector.md#std_vector">std::vector</a>;
<b>use</b> <a href="../sui/accumulator.md#sui_accumulator">sui::accumulator</a>;
<b>use</b> <a href="../sui/accumulator_settlement.md#sui_accumulator_settlement">sui::accumulator_settlement</a>;
<b>use</b> <a href="../sui/address.md#sui_address">sui::address</a>;
<b>use</b> <a href="../sui/bcs.md#sui_bcs">sui::bcs</a>;
<b>use</b> <a href="../sui/dynamic_field.md#sui_dynamic_field">sui::dynamic_field</a>;
<b>use</b> <a href="../sui/event.md#sui_event">sui::event</a>;
<b>use</b> <a href="../sui/hash.md#sui_hash">sui::hash</a>;
<b>use</b> <a href="../sui/hex.md#sui_hex">sui::hex</a>;
<b>use</b> <a href="../sui/object.md#sui_object">sui::object</a>;
<b>use</b> <a href="../sui/party.md#sui_party">sui::party</a>;
<b>use</b> <a href="../sui/transfer.md#sui_transfer">sui::transfer</a>;
<b>use</b> <a href="../sui/tx_context.md#sui_tx_context">sui::tx_context</a>;
<b>use</b> <a href="../sui/vec_map.md#sui_vec_map">sui::vec_map</a>;
</code></pre>



<a name="sui_halo2_kzg_SerializedParams"></a>

## Struct `SerializedParams`



<pre><code><b>public</b> <b>struct</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_SerializedParams">SerializedParams</a> <b>has</b> key, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>id: <a href="../sui/object.md#sui_object_UID">sui::object::UID</a></code>
</dt>
<dd>
</dd>
<dt>
<code>version: u16</code>
</dt>
<dd>
</dd>
<dt>
<code>params_bytes: vector&lt;u8&gt;</code>
</dt>
<dd>
</dd>
<dt>
<code>params_digest: vector&lt;u8&gt;</code>
</dt>
<dd>
</dd>
</dl>


</details>

<a name="sui_halo2_kzg_SerializedVK"></a>

## Struct `SerializedVK`



<pre><code><b>public</b> <b>struct</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_SerializedVK">SerializedVK</a> <b>has</b> key, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>id: <a href="../sui/object.md#sui_object_UID">sui::object::UID</a></code>
</dt>
<dd>
</dd>
<dt>
<code>version: u16</code>
</dt>
<dd>
</dd>
<dt>
<code>vk_bytes: vector&lt;u8&gt;</code>
</dt>
<dd>
</dd>
<dt>
<code>vk_digest: vector&lt;u8&gt;</code>
</dt>
<dd>
</dd>
</dl>


</details>

<a name="sui_halo2_kzg_SerializedCircuit"></a>

## Struct `SerializedCircuit`



<pre><code><b>public</b> <b>struct</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_SerializedCircuit">SerializedCircuit</a> <b>has</b> key, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>id: <a href="../sui/object.md#sui_object_UID">sui::object::UID</a></code>
</dt>
<dd>
</dd>
<dt>
<code>version: u16</code>
</dt>
<dd>
</dd>
<dt>
<code>circuit_bytes: vector&lt;u8&gt;</code>
</dt>
<dd>
</dd>
<dt>
<code>circuit_digest: vector&lt;u8&gt;</code>
</dt>
<dd>
</dd>
</dl>


</details>

<a name="sui_halo2_kzg_PublicInputs"></a>

## Struct `PublicInputs`



<pre><code><b>public</b> <b>struct</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_PublicInputs">PublicInputs</a> <b>has</b> drop
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>columns: vector&lt;vector&lt;vector&lt;u8&gt;&gt;&gt;</code>
</dt>
<dd>
</dd>
</dl>


</details>

<a name="sui_halo2_kzg_ArtifactBuilder"></a>

## Struct `ArtifactBuilder`



<pre><code><b>public</b> <b>struct</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_ArtifactBuilder">ArtifactBuilder</a> <b>has</b> key, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>id: <a href="../sui/object.md#sui_object_UID">sui::object::UID</a></code>
</dt>
<dd>
</dd>
<dt>
<code>kind: u8</code>
</dt>
<dd>
</dd>
<dt>
<code>bytes: vector&lt;u8&gt;</code>
</dt>
<dd>
</dd>
<dt>
<code>max_bytes: u64</code>
</dt>
<dd>
</dd>
</dl>


</details>

<a name="sui_halo2_kzg_BuilderCreated"></a>

## Struct `BuilderCreated`



<pre><code><b>public</b> <b>struct</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_BuilderCreated">BuilderCreated</a> <b>has</b> <b>copy</b>, drop
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>builder_id: <a href="../sui/object.md#sui_object_ID">sui::object::ID</a></code>
</dt>
<dd>
</dd>
<dt>
<code>kind: u8</code>
</dt>
<dd>
</dd>
<dt>
<code>max_bytes: u64</code>
</dt>
<dd>
</dd>
<dt>
<code>owner: <b>address</b></code>
</dt>
<dd>
</dd>
</dl>


</details>

<a name="sui_halo2_kzg_ChunkAppended"></a>

## Struct `ChunkAppended`



<pre><code><b>public</b> <b>struct</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_ChunkAppended">ChunkAppended</a> <b>has</b> <b>copy</b>, drop
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>builder_id: <a href="../sui/object.md#sui_object_ID">sui::object::ID</a></code>
</dt>
<dd>
</dd>
<dt>
<code>kind: u8</code>
</dt>
<dd>
</dd>
<dt>
<code>chunk_len: u64</code>
</dt>
<dd>
</dd>
<dt>
<code>total_len: u64</code>
</dt>
<dd>
</dd>
</dl>


</details>

<a name="sui_halo2_kzg_ArtifactFinalized"></a>

## Struct `ArtifactFinalized`



<pre><code><b>public</b> <b>struct</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_ArtifactFinalized">ArtifactFinalized</a> <b>has</b> <b>copy</b>, drop
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>builder_id: <a href="../sui/object.md#sui_object_ID">sui::object::ID</a></code>
</dt>
<dd>
</dd>
<dt>
<code>artifact_id: <a href="../sui/object.md#sui_object_ID">sui::object::ID</a></code>
</dt>
<dd>
</dd>
<dt>
<code>kind: u8</code>
</dt>
<dd>
</dd>
<dt>
<code>total_len: u64</code>
</dt>
<dd>
</dd>
<dt>
<code>digest: vector&lt;u8&gt;</code>
</dt>
<dd>
</dd>
<dt>
<code>owner: <b>address</b></code>
</dt>
<dd>
</dd>
</dl>


</details>

<a name="@Constants_0"></a>

## Constants


<a name="sui_halo2_kzg_KZG_GWC"></a>

KZG proof using the GWC multi-opening scheme.


<pre><code><b>const</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_KZG_GWC">KZG_GWC</a>: u8 = 0;
</code></pre>



<a name="sui_halo2_kzg_KZG_SHPLONK"></a>

KZG proof using the Shplonk multi-opening scheme.


<pre><code><b>const</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_KZG_SHPLONK">KZG_SHPLONK</a>: u8 = 1;
</code></pre>



<a name="sui_halo2_kzg_ABI_VERSION"></a>

Version of the byte-level verifier ABI exposed by this module.


<pre><code><b>const</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_ABI_VERSION">ABI_VERSION</a>: u64 = 1;
</code></pre>



<a name="sui_halo2_kzg_ARTIFACT_VERSION"></a>

Version of the object-backed artifact format exposed by this module.


<pre><code><b>const</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_ARTIFACT_VERSION">ARTIFACT_VERSION</a>: u16 = 1;
</code></pre>



<a name="sui_halo2_kzg_MAX_PARAMS_BYTES"></a>



<pre><code><b>const</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_MAX_PARAMS_BYTES">MAX_PARAMS_BYTES</a>: u64 = 245760;
</code></pre>



<a name="sui_halo2_kzg_MAX_VK_BYTES"></a>



<pre><code><b>const</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_MAX_VK_BYTES">MAX_VK_BYTES</a>: u64 = 245760;
</code></pre>



<a name="sui_halo2_kzg_MAX_CIRCUIT_INFO_BYTES"></a>



<pre><code><b>const</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_MAX_CIRCUIT_INFO_BYTES">MAX_CIRCUIT_INFO_BYTES</a>: u64 = 245760;
</code></pre>



<a name="sui_halo2_kzg_MAX_PROOF_BYTES"></a>



<pre><code><b>const</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_MAX_PROOF_BYTES">MAX_PROOF_BYTES</a>: u64 = 98304;
</code></pre>



<a name="sui_halo2_kzg_MAX_PUBLIC_INPUTS_BYTES"></a>



<pre><code><b>const</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_MAX_PUBLIC_INPUTS_BYTES">MAX_PUBLIC_INPUTS_BYTES</a>: u64 = 16384;
</code></pre>



<a name="sui_halo2_kzg_MAX_CHUNK_BYTES"></a>



<pre><code><b>const</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_MAX_CHUNK_BYTES">MAX_CHUNK_BYTES</a>: u64 = 15360;
</code></pre>



<a name="sui_halo2_kzg_KIND_PARAMS"></a>



<pre><code><b>const</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_KIND_PARAMS">KIND_PARAMS</a>: u8 = 0;
</code></pre>



<a name="sui_halo2_kzg_KIND_VK"></a>



<pre><code><b>const</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_KIND_VK">KIND_VK</a>: u8 = 1;
</code></pre>



<a name="sui_halo2_kzg_KIND_CIRCUIT_INFO"></a>



<pre><code><b>const</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_KIND_CIRCUIT_INFO">KIND_CIRCUIT_INFO</a>: u8 = 2;
</code></pre>



<a name="sui_halo2_kzg_EUnsupportedKzgVariant"></a>

The supplied KZG opening variant is not supported by this module.


<pre><code><b>const</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_EUnsupportedKzgVariant">EUnsupportedKzgVariant</a>: u64 = 1;
</code></pre>



<a name="sui_halo2_kzg_EInvalidDigestLength"></a>

<code>params_digest</code>, <code>vk_digest</code>, and <code>circuit_info_digest</code> must each be exactly 32 bytes.


<pre><code><b>const</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_EInvalidDigestLength">EInvalidDigestLength</a>: u64 = 2;
</code></pre>



<a name="sui_halo2_kzg_EUnsupportedVersion"></a>

Serialized proof artifacts must be created by the supported artifact format version.


<pre><code><b>const</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_EUnsupportedVersion">EUnsupportedVersion</a>: u64 = 3;
</code></pre>



<a name="sui_halo2_kzg_EVerifyProof"></a>

Object-backed verification entry point returned <code><b>false</b></code>.


<pre><code><b>const</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_EVerifyProof">EVerifyProof</a>: u64 = 4;
</code></pre>



<a name="sui_halo2_kzg_EInputTooLarge"></a>

A serialized verifier input exceeds the framework API limit.


<pre><code><b>const</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_EInputTooLarge">EInputTooLarge</a>: u64 = 5;
</code></pre>



<a name="sui_halo2_kzg_EChunkTooLarge"></a>

A chunk exceeds Sui's pure argument limit allowance.


<pre><code><b>const</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_EChunkTooLarge">EChunkTooLarge</a>: u64 = 6;
</code></pre>



<a name="sui_halo2_kzg_EWrongArtifactKind"></a>

A chunk builder was finalized as the wrong artifact type.


<pre><code><b>const</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_EWrongArtifactKind">EWrongArtifactKind</a>: u64 = 7;
</code></pre>



<a name="sui_halo2_kzg_EDigestMismatch"></a>

The finalized artifact digest does not match the expected digest.


<pre><code><b>const</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_EDigestMismatch">EDigestMismatch</a>: u64 = 8;
</code></pre>



<a name="sui_halo2_kzg_EEmptyArtifact"></a>

Empty chunk builders cannot be finalized into verifier artifacts.


<pre><code><b>const</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_EEmptyArtifact">EEmptyArtifact</a>: u64 = 9;
</code></pre>



<a name="sui_halo2_kzg_abi_version"></a>

## Function `abi_version`

Returns the byte-level verifier ABI version.


<pre><code><b>public</b> <b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_abi_version">abi_version</a>(): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_abi_version">abi_version</a>(): u64 { <a href="../sui/halo2_kzg.md#sui_halo2_kzg_ABI_VERSION">ABI_VERSION</a> }
</code></pre>



</details>

<a name="sui_halo2_kzg_artifact_version"></a>

## Function `artifact_version`

Returns the object-backed artifact format version.


<pre><code><b>public</b> <b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_artifact_version">artifact_version</a>(): u16
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_artifact_version">artifact_version</a>(): u16 { <a href="../sui/halo2_kzg.md#sui_halo2_kzg_ARTIFACT_VERSION">ARTIFACT_VERSION</a> }
</code></pre>



</details>

<a name="sui_halo2_kzg_kzg_gwc"></a>

## Function `kzg_gwc`

Returns the KZG variant identifier for GWC proofs.


<pre><code><b>public</b> <b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_kzg_gwc">kzg_gwc</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_kzg_gwc">kzg_gwc</a>(): u8 { <a href="../sui/halo2_kzg.md#sui_halo2_kzg_KZG_GWC">KZG_GWC</a> }
</code></pre>



</details>

<a name="sui_halo2_kzg_kzg_shplonk"></a>

## Function `kzg_shplonk`

Returns the KZG variant identifier for Shplonk proofs.


<pre><code><b>public</b> <b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_kzg_shplonk">kzg_shplonk</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_kzg_shplonk">kzg_shplonk</a>(): u8 { <a href="../sui/halo2_kzg.md#sui_halo2_kzg_KZG_SHPLONK">KZG_SHPLONK</a> }
</code></pre>



</details>

<a name="sui_halo2_kzg_native_abi_version"></a>

## Function `native_abi_version`



<pre><code><b>public</b> <b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_native_abi_version">native_abi_version</a>(): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_native_abi_version">native_abi_version</a>(): u64 { <a href="../sui/halo2_kzg.md#sui_halo2_kzg_ABI_VERSION">ABI_VERSION</a> }
</code></pre>



</details>

<a name="sui_halo2_kzg_max_params_bytes"></a>

## Function `max_params_bytes`



<pre><code><b>public</b> <b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_max_params_bytes">max_params_bytes</a>(): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_max_params_bytes">max_params_bytes</a>(): u64 { <a href="../sui/halo2_kzg.md#sui_halo2_kzg_MAX_PARAMS_BYTES">MAX_PARAMS_BYTES</a> }
</code></pre>



</details>

<a name="sui_halo2_kzg_max_vk_bytes"></a>

## Function `max_vk_bytes`



<pre><code><b>public</b> <b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_max_vk_bytes">max_vk_bytes</a>(): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_max_vk_bytes">max_vk_bytes</a>(): u64 { <a href="../sui/halo2_kzg.md#sui_halo2_kzg_MAX_VK_BYTES">MAX_VK_BYTES</a> }
</code></pre>



</details>

<a name="sui_halo2_kzg_max_circuit_info_bytes"></a>

## Function `max_circuit_info_bytes`



<pre><code><b>public</b> <b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_max_circuit_info_bytes">max_circuit_info_bytes</a>(): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_max_circuit_info_bytes">max_circuit_info_bytes</a>(): u64 { <a href="../sui/halo2_kzg.md#sui_halo2_kzg_MAX_CIRCUIT_INFO_BYTES">MAX_CIRCUIT_INFO_BYTES</a> }
</code></pre>



</details>

<a name="sui_halo2_kzg_max_proof_bytes"></a>

## Function `max_proof_bytes`



<pre><code><b>public</b> <b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_max_proof_bytes">max_proof_bytes</a>(): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_max_proof_bytes">max_proof_bytes</a>(): u64 { <a href="../sui/halo2_kzg.md#sui_halo2_kzg_MAX_PROOF_BYTES">MAX_PROOF_BYTES</a> }
</code></pre>



</details>

<a name="sui_halo2_kzg_max_public_inputs_bytes"></a>

## Function `max_public_inputs_bytes`



<pre><code><b>public</b> <b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_max_public_inputs_bytes">max_public_inputs_bytes</a>(): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_max_public_inputs_bytes">max_public_inputs_bytes</a>(): u64 { <a href="../sui/halo2_kzg.md#sui_halo2_kzg_MAX_PUBLIC_INPUTS_BYTES">MAX_PUBLIC_INPUTS_BYTES</a> }
</code></pre>



</details>

<a name="sui_halo2_kzg_max_chunk_bytes"></a>

## Function `max_chunk_bytes`



<pre><code><b>public</b> <b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_max_chunk_bytes">max_chunk_bytes</a>(): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_max_chunk_bytes">max_chunk_bytes</a>(): u64 { <a href="../sui/halo2_kzg.md#sui_halo2_kzg_MAX_CHUNK_BYTES">MAX_CHUNK_BYTES</a> }
</code></pre>



</details>

<a name="sui_halo2_kzg_kind_params"></a>

## Function `kind_params`



<pre><code><b>public</b> <b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_kind_params">kind_params</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_kind_params">kind_params</a>(): u8 { <a href="../sui/halo2_kzg.md#sui_halo2_kzg_KIND_PARAMS">KIND_PARAMS</a> }
</code></pre>



</details>

<a name="sui_halo2_kzg_kind_vk"></a>

## Function `kind_vk`



<pre><code><b>public</b> <b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_kind_vk">kind_vk</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_kind_vk">kind_vk</a>(): u8 { <a href="../sui/halo2_kzg.md#sui_halo2_kzg_KIND_VK">KIND_VK</a> }
</code></pre>



</details>

<a name="sui_halo2_kzg_kind_circuit_info"></a>

## Function `kind_circuit_info`



<pre><code><b>public</b> <b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_kind_circuit_info">kind_circuit_info</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_kind_circuit_info">kind_circuit_info</a>(): u8 { <a href="../sui/halo2_kzg.md#sui_halo2_kzg_KIND_CIRCUIT_INFO">KIND_CIRCUIT_INFO</a> }
</code></pre>



</details>

<a name="sui_halo2_kzg_public_inputs_from_bytes"></a>

## Function `public_inputs_from_bytes`



<pre><code><b>public</b> <b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_public_inputs_from_bytes">public_inputs_from_bytes</a>(bytes: vector&lt;vector&lt;vector&lt;u8&gt;&gt;&gt;): <a href="../sui/halo2_kzg.md#sui_halo2_kzg_PublicInputs">sui::halo2_kzg::PublicInputs</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_public_inputs_from_bytes">public_inputs_from_bytes</a>(bytes: vector&lt;vector&lt;vector&lt;u8&gt;&gt;&gt;): <a href="../sui/halo2_kzg.md#sui_halo2_kzg_PublicInputs">PublicInputs</a> {
    <a href="../sui/halo2_kzg.md#sui_halo2_kzg_PublicInputs">PublicInputs</a> { columns: bytes }
}
</code></pre>



</details>

<a name="sui_halo2_kzg_public_inputs_to_bytes"></a>

## Function `public_inputs_to_bytes`



<pre><code><b>public</b> <b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_public_inputs_to_bytes">public_inputs_to_bytes</a>(public_inputs: &<a href="../sui/halo2_kzg.md#sui_halo2_kzg_PublicInputs">sui::halo2_kzg::PublicInputs</a>): vector&lt;vector&lt;vector&lt;u8&gt;&gt;&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_public_inputs_to_bytes">public_inputs_to_bytes</a>(public_inputs: &<a href="../sui/halo2_kzg.md#sui_halo2_kzg_PublicInputs">PublicInputs</a>): vector&lt;vector&lt;vector&lt;u8&gt;&gt;&gt; {
    public_inputs.columns
}
</code></pre>



</details>

<a name="sui_halo2_kzg_public_inputs_to_bcs_bytes"></a>

## Function `public_inputs_to_bcs_bytes`



<pre><code><b>public</b> <b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_public_inputs_to_bcs_bytes">public_inputs_to_bcs_bytes</a>(public_inputs: &<a href="../sui/halo2_kzg.md#sui_halo2_kzg_PublicInputs">sui::halo2_kzg::PublicInputs</a>): vector&lt;u8&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_public_inputs_to_bcs_bytes">public_inputs_to_bcs_bytes</a>(public_inputs: &<a href="../sui/halo2_kzg.md#sui_halo2_kzg_PublicInputs">PublicInputs</a>): vector&lt;u8&gt; {
    <a href="../sui/bcs.md#sui_bcs_to_bytes">bcs::to_bytes</a>(&public_inputs.columns)
}
</code></pre>



</details>

<a name="sui_halo2_kzg_new_serialized_params"></a>

## Function `new_serialized_params`



<pre><code><b>public</b> <b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_new_serialized_params">new_serialized_params</a>(params_bytes: vector&lt;u8&gt;, ctx: &<b>mut</b> <a href="../sui/tx_context.md#sui_tx_context_TxContext">sui::tx_context::TxContext</a>): <a href="../sui/halo2_kzg.md#sui_halo2_kzg_SerializedParams">sui::halo2_kzg::SerializedParams</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_new_serialized_params">new_serialized_params</a>(
    params_bytes: vector&lt;u8&gt;,
    ctx: &<b>mut</b> TxContext,
): <a href="../sui/halo2_kzg.md#sui_halo2_kzg_SerializedParams">SerializedParams</a> {
    <a href="../sui/halo2_kzg.md#sui_halo2_kzg_assert_params_size">assert_params_size</a>(&params_bytes);
    <b>let</b> params_digest = <a href="../sui/hash.md#sui_hash_blake2b256">hash::blake2b256</a>(&params_bytes);
    <a href="../sui/halo2_kzg.md#sui_halo2_kzg_SerializedParams">SerializedParams</a> {
        id: <a href="../sui/object.md#sui_object_new">object::new</a>(ctx),
        version: <a href="../sui/halo2_kzg.md#sui_halo2_kzg_ARTIFACT_VERSION">ARTIFACT_VERSION</a>,
        params_bytes,
        params_digest,
    }
}
</code></pre>



</details>

<a name="sui_halo2_kzg_publish_serialized_params"></a>

## Function `publish_serialized_params`



<pre><code><b>entry</b> <b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_publish_serialized_params">publish_serialized_params</a>(params_bytes: vector&lt;u8&gt;, ctx: &<b>mut</b> <a href="../sui/tx_context.md#sui_tx_context_TxContext">sui::tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>entry</b> <b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_publish_serialized_params">publish_serialized_params</a>(
    params_bytes: vector&lt;u8&gt;,
    ctx: &<b>mut</b> TxContext,
) {
    <a href="../sui/transfer.md#sui_transfer_transfer">transfer::transfer</a>(
        <a href="../sui/halo2_kzg.md#sui_halo2_kzg_new_serialized_params">new_serialized_params</a>(params_bytes, ctx),
        ctx.sender(),
    )
}
</code></pre>



</details>

<a name="sui_halo2_kzg_serialized_params_version"></a>

## Function `serialized_params_version`



<pre><code><b>public</b> <b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_serialized_params_version">serialized_params_version</a>(params: &<a href="../sui/halo2_kzg.md#sui_halo2_kzg_SerializedParams">sui::halo2_kzg::SerializedParams</a>): u16
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_serialized_params_version">serialized_params_version</a>(params: &<a href="../sui/halo2_kzg.md#sui_halo2_kzg_SerializedParams">SerializedParams</a>): u16 {
    params.version
}
</code></pre>



</details>

<a name="sui_halo2_kzg_assert_supported_params_version"></a>

## Function `assert_supported_params_version`



<pre><code><b>public</b> <b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_assert_supported_params_version">assert_supported_params_version</a>(params: &<a href="../sui/halo2_kzg.md#sui_halo2_kzg_SerializedParams">sui::halo2_kzg::SerializedParams</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_assert_supported_params_version">assert_supported_params_version</a>(params: &<a href="../sui/halo2_kzg.md#sui_halo2_kzg_SerializedParams">SerializedParams</a>) {
    <b>assert</b>!(params.version == <a href="../sui/halo2_kzg.md#sui_halo2_kzg_ARTIFACT_VERSION">ARTIFACT_VERSION</a>, <a href="../sui/halo2_kzg.md#sui_halo2_kzg_EUnsupportedVersion">EUnsupportedVersion</a>)
}
</code></pre>



</details>

<a name="sui_halo2_kzg_get_serialized_params"></a>

## Function `get_serialized_params`



<pre><code><b>public</b> <b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_get_serialized_params">get_serialized_params</a>(params: &<a href="../sui/halo2_kzg.md#sui_halo2_kzg_SerializedParams">sui::halo2_kzg::SerializedParams</a>): vector&lt;u8&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_get_serialized_params">get_serialized_params</a>(params: &<a href="../sui/halo2_kzg.md#sui_halo2_kzg_SerializedParams">SerializedParams</a>): vector&lt;u8&gt; {
    params.params_bytes
}
</code></pre>



</details>

<a name="sui_halo2_kzg_get_serialized_params_digest"></a>

## Function `get_serialized_params_digest`



<pre><code><b>public</b> <b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_get_serialized_params_digest">get_serialized_params_digest</a>(params: &<a href="../sui/halo2_kzg.md#sui_halo2_kzg_SerializedParams">sui::halo2_kzg::SerializedParams</a>): vector&lt;u8&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_get_serialized_params_digest">get_serialized_params_digest</a>(params: &<a href="../sui/halo2_kzg.md#sui_halo2_kzg_SerializedParams">SerializedParams</a>): vector&lt;u8&gt; {
    params.params_digest
}
</code></pre>



</details>

<a name="sui_halo2_kzg_destroy_serialized_params"></a>

## Function `destroy_serialized_params`



<pre><code><b>public</b> <b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_destroy_serialized_params">destroy_serialized_params</a>(params: <a href="../sui/halo2_kzg.md#sui_halo2_kzg_SerializedParams">sui::halo2_kzg::SerializedParams</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_destroy_serialized_params">destroy_serialized_params</a>(params: <a href="../sui/halo2_kzg.md#sui_halo2_kzg_SerializedParams">SerializedParams</a>) {
    <b>let</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_SerializedParams">SerializedParams</a> { id, version: _, params_bytes: _, params_digest: _ } = params;
    <a href="../sui/object.md#sui_object_delete">object::delete</a>(id)
}
</code></pre>



</details>

<a name="sui_halo2_kzg_new_serialized_vk"></a>

## Function `new_serialized_vk`



<pre><code><b>public</b> <b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_new_serialized_vk">new_serialized_vk</a>(vk_bytes: vector&lt;u8&gt;, ctx: &<b>mut</b> <a href="../sui/tx_context.md#sui_tx_context_TxContext">sui::tx_context::TxContext</a>): <a href="../sui/halo2_kzg.md#sui_halo2_kzg_SerializedVK">sui::halo2_kzg::SerializedVK</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_new_serialized_vk">new_serialized_vk</a>(
    vk_bytes: vector&lt;u8&gt;,
    ctx: &<b>mut</b> TxContext,
): <a href="../sui/halo2_kzg.md#sui_halo2_kzg_SerializedVK">SerializedVK</a> {
    <a href="../sui/halo2_kzg.md#sui_halo2_kzg_assert_vk_size">assert_vk_size</a>(&vk_bytes);
    <b>let</b> vk_digest = <a href="../sui/hash.md#sui_hash_blake2b256">hash::blake2b256</a>(&vk_bytes);
    <a href="../sui/halo2_kzg.md#sui_halo2_kzg_SerializedVK">SerializedVK</a> {
        id: <a href="../sui/object.md#sui_object_new">object::new</a>(ctx),
        version: <a href="../sui/halo2_kzg.md#sui_halo2_kzg_ARTIFACT_VERSION">ARTIFACT_VERSION</a>,
        vk_bytes,
        vk_digest,
    }
}
</code></pre>



</details>

<a name="sui_halo2_kzg_publish_serialized_vk"></a>

## Function `publish_serialized_vk`



<pre><code><b>entry</b> <b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_publish_serialized_vk">publish_serialized_vk</a>(vk_bytes: vector&lt;u8&gt;, ctx: &<b>mut</b> <a href="../sui/tx_context.md#sui_tx_context_TxContext">sui::tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>entry</b> <b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_publish_serialized_vk">publish_serialized_vk</a>(
    vk_bytes: vector&lt;u8&gt;,
    ctx: &<b>mut</b> TxContext,
) {
    <a href="../sui/transfer.md#sui_transfer_transfer">transfer::transfer</a>(<a href="../sui/halo2_kzg.md#sui_halo2_kzg_new_serialized_vk">new_serialized_vk</a>(vk_bytes, ctx), ctx.sender())
}
</code></pre>



</details>

<a name="sui_halo2_kzg_serialized_vk_version"></a>

## Function `serialized_vk_version`



<pre><code><b>public</b> <b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_serialized_vk_version">serialized_vk_version</a>(vk: &<a href="../sui/halo2_kzg.md#sui_halo2_kzg_SerializedVK">sui::halo2_kzg::SerializedVK</a>): u16
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_serialized_vk_version">serialized_vk_version</a>(vk: &<a href="../sui/halo2_kzg.md#sui_halo2_kzg_SerializedVK">SerializedVK</a>): u16 {
    vk.version
}
</code></pre>



</details>

<a name="sui_halo2_kzg_get_serialized_vk"></a>

## Function `get_serialized_vk`



<pre><code><b>public</b> <b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_get_serialized_vk">get_serialized_vk</a>(vk: &<a href="../sui/halo2_kzg.md#sui_halo2_kzg_SerializedVK">sui::halo2_kzg::SerializedVK</a>): vector&lt;u8&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_get_serialized_vk">get_serialized_vk</a>(vk: &<a href="../sui/halo2_kzg.md#sui_halo2_kzg_SerializedVK">SerializedVK</a>): vector&lt;u8&gt; {
    vk.vk_bytes
}
</code></pre>



</details>

<a name="sui_halo2_kzg_get_serialized_vk_digest"></a>

## Function `get_serialized_vk_digest`



<pre><code><b>public</b> <b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_get_serialized_vk_digest">get_serialized_vk_digest</a>(vk: &<a href="../sui/halo2_kzg.md#sui_halo2_kzg_SerializedVK">sui::halo2_kzg::SerializedVK</a>): vector&lt;u8&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_get_serialized_vk_digest">get_serialized_vk_digest</a>(vk: &<a href="../sui/halo2_kzg.md#sui_halo2_kzg_SerializedVK">SerializedVK</a>): vector&lt;u8&gt; {
    vk.vk_digest
}
</code></pre>



</details>

<a name="sui_halo2_kzg_destroy_serialized_vk"></a>

## Function `destroy_serialized_vk`



<pre><code><b>public</b> <b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_destroy_serialized_vk">destroy_serialized_vk</a>(vk: <a href="../sui/halo2_kzg.md#sui_halo2_kzg_SerializedVK">sui::halo2_kzg::SerializedVK</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_destroy_serialized_vk">destroy_serialized_vk</a>(vk: <a href="../sui/halo2_kzg.md#sui_halo2_kzg_SerializedVK">SerializedVK</a>) {
    <b>let</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_SerializedVK">SerializedVK</a> { id, version: _, vk_bytes: _, vk_digest: _ } = vk;
    <a href="../sui/object.md#sui_object_delete">object::delete</a>(id)
}
</code></pre>



</details>

<a name="sui_halo2_kzg_new_serialized_circuit"></a>

## Function `new_serialized_circuit`



<pre><code><b>public</b> <b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_new_serialized_circuit">new_serialized_circuit</a>(circuit_bytes: vector&lt;u8&gt;, ctx: &<b>mut</b> <a href="../sui/tx_context.md#sui_tx_context_TxContext">sui::tx_context::TxContext</a>): <a href="../sui/halo2_kzg.md#sui_halo2_kzg_SerializedCircuit">sui::halo2_kzg::SerializedCircuit</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_new_serialized_circuit">new_serialized_circuit</a>(
    circuit_bytes: vector&lt;u8&gt;,
    ctx: &<b>mut</b> TxContext,
): <a href="../sui/halo2_kzg.md#sui_halo2_kzg_SerializedCircuit">SerializedCircuit</a> {
    <a href="../sui/halo2_kzg.md#sui_halo2_kzg_assert_circuit_info_size">assert_circuit_info_size</a>(&circuit_bytes);
    <b>let</b> circuit_digest = <a href="../sui/hash.md#sui_hash_blake2b256">hash::blake2b256</a>(&circuit_bytes);
    <a href="../sui/halo2_kzg.md#sui_halo2_kzg_SerializedCircuit">SerializedCircuit</a> {
        id: <a href="../sui/object.md#sui_object_new">object::new</a>(ctx),
        version: <a href="../sui/halo2_kzg.md#sui_halo2_kzg_ARTIFACT_VERSION">ARTIFACT_VERSION</a>,
        circuit_bytes,
        circuit_digest,
    }
}
</code></pre>



</details>

<a name="sui_halo2_kzg_publish_serialized_circuit"></a>

## Function `publish_serialized_circuit`



<pre><code><b>entry</b> <b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_publish_serialized_circuit">publish_serialized_circuit</a>(circuit_bytes: vector&lt;u8&gt;, ctx: &<b>mut</b> <a href="../sui/tx_context.md#sui_tx_context_TxContext">sui::tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>entry</b> <b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_publish_serialized_circuit">publish_serialized_circuit</a>(
    circuit_bytes: vector&lt;u8&gt;,
    ctx: &<b>mut</b> TxContext,
) {
    <a href="../sui/transfer.md#sui_transfer_transfer">transfer::transfer</a>(<a href="../sui/halo2_kzg.md#sui_halo2_kzg_new_serialized_circuit">new_serialized_circuit</a>(circuit_bytes, ctx), ctx.sender())
}
</code></pre>



</details>

<a name="sui_halo2_kzg_serialized_circuit_version"></a>

## Function `serialized_circuit_version`



<pre><code><b>public</b> <b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_serialized_circuit_version">serialized_circuit_version</a>(circuit: &<a href="../sui/halo2_kzg.md#sui_halo2_kzg_SerializedCircuit">sui::halo2_kzg::SerializedCircuit</a>): u16
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_serialized_circuit_version">serialized_circuit_version</a>(circuit: &<a href="../sui/halo2_kzg.md#sui_halo2_kzg_SerializedCircuit">SerializedCircuit</a>): u16 {
    circuit.version
}
</code></pre>



</details>

<a name="sui_halo2_kzg_get_serialized_circuit"></a>

## Function `get_serialized_circuit`



<pre><code><b>public</b> <b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_get_serialized_circuit">get_serialized_circuit</a>(circuit: &<a href="../sui/halo2_kzg.md#sui_halo2_kzg_SerializedCircuit">sui::halo2_kzg::SerializedCircuit</a>): vector&lt;u8&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_get_serialized_circuit">get_serialized_circuit</a>(circuit: &<a href="../sui/halo2_kzg.md#sui_halo2_kzg_SerializedCircuit">SerializedCircuit</a>): vector&lt;u8&gt; {
    circuit.circuit_bytes
}
</code></pre>



</details>

<a name="sui_halo2_kzg_get_serialized_circuit_digest"></a>

## Function `get_serialized_circuit_digest`



<pre><code><b>public</b> <b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_get_serialized_circuit_digest">get_serialized_circuit_digest</a>(circuit: &<a href="../sui/halo2_kzg.md#sui_halo2_kzg_SerializedCircuit">sui::halo2_kzg::SerializedCircuit</a>): vector&lt;u8&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_get_serialized_circuit_digest">get_serialized_circuit_digest</a>(circuit: &<a href="../sui/halo2_kzg.md#sui_halo2_kzg_SerializedCircuit">SerializedCircuit</a>): vector&lt;u8&gt; {
    circuit.circuit_digest
}
</code></pre>



</details>

<a name="sui_halo2_kzg_destroy_serialized_circuit"></a>

## Function `destroy_serialized_circuit`



<pre><code><b>public</b> <b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_destroy_serialized_circuit">destroy_serialized_circuit</a>(circuit: <a href="../sui/halo2_kzg.md#sui_halo2_kzg_SerializedCircuit">sui::halo2_kzg::SerializedCircuit</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_destroy_serialized_circuit">destroy_serialized_circuit</a>(circuit: <a href="../sui/halo2_kzg.md#sui_halo2_kzg_SerializedCircuit">SerializedCircuit</a>) {
    <b>let</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_SerializedCircuit">SerializedCircuit</a> { id, version: _, circuit_bytes: _, circuit_digest: _ } = circuit;
    <a href="../sui/object.md#sui_object_delete">object::delete</a>(id)
}
</code></pre>



</details>

<a name="sui_halo2_kzg_new_params_builder"></a>

## Function `new_params_builder`



<pre><code><b>public</b> <b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_new_params_builder">new_params_builder</a>(ctx: &<b>mut</b> <a href="../sui/tx_context.md#sui_tx_context_TxContext">sui::tx_context::TxContext</a>): <a href="../sui/halo2_kzg.md#sui_halo2_kzg_ArtifactBuilder">sui::halo2_kzg::ArtifactBuilder</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_new_params_builder">new_params_builder</a>(ctx: &<b>mut</b> TxContext): <a href="../sui/halo2_kzg.md#sui_halo2_kzg_ArtifactBuilder">ArtifactBuilder</a> {
    <a href="../sui/halo2_kzg.md#sui_halo2_kzg_new_builder">new_builder</a>(<a href="../sui/halo2_kzg.md#sui_halo2_kzg_KIND_PARAMS">KIND_PARAMS</a>, <a href="../sui/halo2_kzg.md#sui_halo2_kzg_MAX_PARAMS_BYTES">MAX_PARAMS_BYTES</a>, ctx)
}
</code></pre>



</details>

<a name="sui_halo2_kzg_new_vk_builder"></a>

## Function `new_vk_builder`



<pre><code><b>public</b> <b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_new_vk_builder">new_vk_builder</a>(ctx: &<b>mut</b> <a href="../sui/tx_context.md#sui_tx_context_TxContext">sui::tx_context::TxContext</a>): <a href="../sui/halo2_kzg.md#sui_halo2_kzg_ArtifactBuilder">sui::halo2_kzg::ArtifactBuilder</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_new_vk_builder">new_vk_builder</a>(ctx: &<b>mut</b> TxContext): <a href="../sui/halo2_kzg.md#sui_halo2_kzg_ArtifactBuilder">ArtifactBuilder</a> {
    <a href="../sui/halo2_kzg.md#sui_halo2_kzg_new_builder">new_builder</a>(<a href="../sui/halo2_kzg.md#sui_halo2_kzg_KIND_VK">KIND_VK</a>, <a href="../sui/halo2_kzg.md#sui_halo2_kzg_MAX_VK_BYTES">MAX_VK_BYTES</a>, ctx)
}
</code></pre>



</details>

<a name="sui_halo2_kzg_new_circuit_info_builder"></a>

## Function `new_circuit_info_builder`



<pre><code><b>public</b> <b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_new_circuit_info_builder">new_circuit_info_builder</a>(ctx: &<b>mut</b> <a href="../sui/tx_context.md#sui_tx_context_TxContext">sui::tx_context::TxContext</a>): <a href="../sui/halo2_kzg.md#sui_halo2_kzg_ArtifactBuilder">sui::halo2_kzg::ArtifactBuilder</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_new_circuit_info_builder">new_circuit_info_builder</a>(ctx: &<b>mut</b> TxContext): <a href="../sui/halo2_kzg.md#sui_halo2_kzg_ArtifactBuilder">ArtifactBuilder</a> {
    <a href="../sui/halo2_kzg.md#sui_halo2_kzg_new_builder">new_builder</a>(<a href="../sui/halo2_kzg.md#sui_halo2_kzg_KIND_CIRCUIT_INFO">KIND_CIRCUIT_INFO</a>, <a href="../sui/halo2_kzg.md#sui_halo2_kzg_MAX_CIRCUIT_INFO_BYTES">MAX_CIRCUIT_INFO_BYTES</a>, ctx)
}
</code></pre>



</details>

<a name="sui_halo2_kzg_publish_params_builder"></a>

## Function `publish_params_builder`



<pre><code><b>entry</b> <b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_publish_params_builder">publish_params_builder</a>(ctx: &<b>mut</b> <a href="../sui/tx_context.md#sui_tx_context_TxContext">sui::tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>entry</b> <b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_publish_params_builder">publish_params_builder</a>(ctx: &<b>mut</b> TxContext) {
    <a href="../sui/transfer.md#sui_transfer_transfer">transfer::transfer</a>(<a href="../sui/halo2_kzg.md#sui_halo2_kzg_new_params_builder">new_params_builder</a>(ctx), ctx.sender())
}
</code></pre>



</details>

<a name="sui_halo2_kzg_publish_vk_builder"></a>

## Function `publish_vk_builder`



<pre><code><b>entry</b> <b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_publish_vk_builder">publish_vk_builder</a>(ctx: &<b>mut</b> <a href="../sui/tx_context.md#sui_tx_context_TxContext">sui::tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>entry</b> <b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_publish_vk_builder">publish_vk_builder</a>(ctx: &<b>mut</b> TxContext) {
    <a href="../sui/transfer.md#sui_transfer_transfer">transfer::transfer</a>(<a href="../sui/halo2_kzg.md#sui_halo2_kzg_new_vk_builder">new_vk_builder</a>(ctx), ctx.sender())
}
</code></pre>



</details>

<a name="sui_halo2_kzg_publish_circuit_info_builder"></a>

## Function `publish_circuit_info_builder`



<pre><code><b>entry</b> <b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_publish_circuit_info_builder">publish_circuit_info_builder</a>(ctx: &<b>mut</b> <a href="../sui/tx_context.md#sui_tx_context_TxContext">sui::tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>entry</b> <b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_publish_circuit_info_builder">publish_circuit_info_builder</a>(ctx: &<b>mut</b> TxContext) {
    <a href="../sui/transfer.md#sui_transfer_transfer">transfer::transfer</a>(<a href="../sui/halo2_kzg.md#sui_halo2_kzg_new_circuit_info_builder">new_circuit_info_builder</a>(ctx), ctx.sender())
}
</code></pre>



</details>

<a name="sui_halo2_kzg_append_chunk"></a>

## Function `append_chunk`



<pre><code><b>public</b> <b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_append_chunk">append_chunk</a>(builder: &<b>mut</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_ArtifactBuilder">sui::halo2_kzg::ArtifactBuilder</a>, chunk: vector&lt;u8&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_append_chunk">append_chunk</a>(builder: &<b>mut</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_ArtifactBuilder">ArtifactBuilder</a>, chunk: vector&lt;u8&gt;) {
    <b>let</b> chunk_len = chunk.length();
    <a href="../sui/halo2_kzg.md#sui_halo2_kzg_assert_chunk_size">assert_chunk_size</a>(&chunk);
    <a href="../sui/halo2_kzg.md#sui_halo2_kzg_assert_total_size">assert_total_size</a>(builder.bytes.length() + chunk.length(), builder.max_bytes);
    builder.bytes.append(chunk);
    <a href="../sui/event.md#sui_event_emit">event::emit</a>(<a href="../sui/halo2_kzg.md#sui_halo2_kzg_ChunkAppended">ChunkAppended</a> {
        builder_id: <a href="../sui/object.md#sui_object_uid_to_inner">object::uid_to_inner</a>(&builder.id),
        kind: builder.kind,
        chunk_len,
        total_len: builder.bytes.length(),
    })
}
</code></pre>



</details>

<a name="sui_halo2_kzg_finalize_params"></a>

## Function `finalize_params`



<pre><code><b>public</b> <b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_finalize_params">finalize_params</a>(builder: <a href="../sui/halo2_kzg.md#sui_halo2_kzg_ArtifactBuilder">sui::halo2_kzg::ArtifactBuilder</a>, expected_digest: vector&lt;u8&gt;, ctx: &<b>mut</b> <a href="../sui/tx_context.md#sui_tx_context_TxContext">sui::tx_context::TxContext</a>): <a href="../sui/halo2_kzg.md#sui_halo2_kzg_SerializedParams">sui::halo2_kzg::SerializedParams</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_finalize_params">finalize_params</a>(
    builder: <a href="../sui/halo2_kzg.md#sui_halo2_kzg_ArtifactBuilder">ArtifactBuilder</a>,
    expected_digest: vector&lt;u8&gt;,
    ctx: &<b>mut</b> TxContext,
): <a href="../sui/halo2_kzg.md#sui_halo2_kzg_SerializedParams">SerializedParams</a> {
    <b>let</b> (builder_id, bytes) = <a href="../sui/halo2_kzg.md#sui_halo2_kzg_finish">finish</a>(builder, <a href="../sui/halo2_kzg.md#sui_halo2_kzg_KIND_PARAMS">KIND_PARAMS</a>, expected_digest);
    <b>let</b> params = <a href="../sui/halo2_kzg.md#sui_halo2_kzg_new_serialized_params">new_serialized_params</a>(bytes, ctx);
    <a href="../sui/halo2_kzg.md#sui_halo2_kzg_emit_finalized">emit_finalized</a>(
        builder_id,
        <a href="../sui/object.md#sui_object_id">object::id</a>(&params),
        <a href="../sui/halo2_kzg.md#sui_halo2_kzg_KIND_PARAMS">KIND_PARAMS</a>,
        <a href="../sui/halo2_kzg.md#sui_halo2_kzg_get_serialized_params_digest">get_serialized_params_digest</a>(&params),
        <a href="../sui/halo2_kzg.md#sui_halo2_kzg_get_serialized_params">get_serialized_params</a>(&params).length(),
        ctx,
    );
    params
}
</code></pre>



</details>

<a name="sui_halo2_kzg_finalize_vk"></a>

## Function `finalize_vk`



<pre><code><b>public</b> <b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_finalize_vk">finalize_vk</a>(builder: <a href="../sui/halo2_kzg.md#sui_halo2_kzg_ArtifactBuilder">sui::halo2_kzg::ArtifactBuilder</a>, expected_digest: vector&lt;u8&gt;, ctx: &<b>mut</b> <a href="../sui/tx_context.md#sui_tx_context_TxContext">sui::tx_context::TxContext</a>): <a href="../sui/halo2_kzg.md#sui_halo2_kzg_SerializedVK">sui::halo2_kzg::SerializedVK</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_finalize_vk">finalize_vk</a>(
    builder: <a href="../sui/halo2_kzg.md#sui_halo2_kzg_ArtifactBuilder">ArtifactBuilder</a>,
    expected_digest: vector&lt;u8&gt;,
    ctx: &<b>mut</b> TxContext,
): <a href="../sui/halo2_kzg.md#sui_halo2_kzg_SerializedVK">SerializedVK</a> {
    <b>let</b> (builder_id, bytes) = <a href="../sui/halo2_kzg.md#sui_halo2_kzg_finish">finish</a>(builder, <a href="../sui/halo2_kzg.md#sui_halo2_kzg_KIND_VK">KIND_VK</a>, expected_digest);
    <b>let</b> vk = <a href="../sui/halo2_kzg.md#sui_halo2_kzg_new_serialized_vk">new_serialized_vk</a>(bytes, ctx);
    <a href="../sui/halo2_kzg.md#sui_halo2_kzg_emit_finalized">emit_finalized</a>(
        builder_id,
        <a href="../sui/object.md#sui_object_id">object::id</a>(&vk),
        <a href="../sui/halo2_kzg.md#sui_halo2_kzg_KIND_VK">KIND_VK</a>,
        <a href="../sui/halo2_kzg.md#sui_halo2_kzg_get_serialized_vk_digest">get_serialized_vk_digest</a>(&vk),
        <a href="../sui/halo2_kzg.md#sui_halo2_kzg_get_serialized_vk">get_serialized_vk</a>(&vk).length(),
        ctx,
    );
    vk
}
</code></pre>



</details>

<a name="sui_halo2_kzg_finalize_circuit_info"></a>

## Function `finalize_circuit_info`



<pre><code><b>public</b> <b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_finalize_circuit_info">finalize_circuit_info</a>(builder: <a href="../sui/halo2_kzg.md#sui_halo2_kzg_ArtifactBuilder">sui::halo2_kzg::ArtifactBuilder</a>, expected_digest: vector&lt;u8&gt;, ctx: &<b>mut</b> <a href="../sui/tx_context.md#sui_tx_context_TxContext">sui::tx_context::TxContext</a>): <a href="../sui/halo2_kzg.md#sui_halo2_kzg_SerializedCircuit">sui::halo2_kzg::SerializedCircuit</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_finalize_circuit_info">finalize_circuit_info</a>(
    builder: <a href="../sui/halo2_kzg.md#sui_halo2_kzg_ArtifactBuilder">ArtifactBuilder</a>,
    expected_digest: vector&lt;u8&gt;,
    ctx: &<b>mut</b> TxContext,
): <a href="../sui/halo2_kzg.md#sui_halo2_kzg_SerializedCircuit">SerializedCircuit</a> {
    <b>let</b> (builder_id, bytes) = <a href="../sui/halo2_kzg.md#sui_halo2_kzg_finish">finish</a>(builder, <a href="../sui/halo2_kzg.md#sui_halo2_kzg_KIND_CIRCUIT_INFO">KIND_CIRCUIT_INFO</a>, expected_digest);
    <b>let</b> circuit = <a href="../sui/halo2_kzg.md#sui_halo2_kzg_new_serialized_circuit">new_serialized_circuit</a>(bytes, ctx);
    <a href="../sui/halo2_kzg.md#sui_halo2_kzg_emit_finalized">emit_finalized</a>(
        builder_id,
        <a href="../sui/object.md#sui_object_id">object::id</a>(&circuit),
        <a href="../sui/halo2_kzg.md#sui_halo2_kzg_KIND_CIRCUIT_INFO">KIND_CIRCUIT_INFO</a>,
        <a href="../sui/halo2_kzg.md#sui_halo2_kzg_get_serialized_circuit_digest">get_serialized_circuit_digest</a>(&circuit),
        <a href="../sui/halo2_kzg.md#sui_halo2_kzg_get_serialized_circuit">get_serialized_circuit</a>(&circuit).length(),
        ctx,
    );
    circuit
}
</code></pre>



</details>

<a name="sui_halo2_kzg_finalize_params_to_sender"></a>

## Function `finalize_params_to_sender`



<pre><code><b>entry</b> <b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_finalize_params_to_sender">finalize_params_to_sender</a>(builder: <a href="../sui/halo2_kzg.md#sui_halo2_kzg_ArtifactBuilder">sui::halo2_kzg::ArtifactBuilder</a>, expected_digest: vector&lt;u8&gt;, ctx: &<b>mut</b> <a href="../sui/tx_context.md#sui_tx_context_TxContext">sui::tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>entry</b> <b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_finalize_params_to_sender">finalize_params_to_sender</a>(
    builder: <a href="../sui/halo2_kzg.md#sui_halo2_kzg_ArtifactBuilder">ArtifactBuilder</a>,
    expected_digest: vector&lt;u8&gt;,
    ctx: &<b>mut</b> TxContext,
) {
    <a href="../sui/transfer.md#sui_transfer_public_transfer">transfer::public_transfer</a>(<a href="../sui/halo2_kzg.md#sui_halo2_kzg_finalize_params">finalize_params</a>(builder, expected_digest, ctx), ctx.sender())
}
</code></pre>



</details>

<a name="sui_halo2_kzg_finalize_vk_to_sender"></a>

## Function `finalize_vk_to_sender`



<pre><code><b>entry</b> <b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_finalize_vk_to_sender">finalize_vk_to_sender</a>(builder: <a href="../sui/halo2_kzg.md#sui_halo2_kzg_ArtifactBuilder">sui::halo2_kzg::ArtifactBuilder</a>, expected_digest: vector&lt;u8&gt;, ctx: &<b>mut</b> <a href="../sui/tx_context.md#sui_tx_context_TxContext">sui::tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>entry</b> <b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_finalize_vk_to_sender">finalize_vk_to_sender</a>(
    builder: <a href="../sui/halo2_kzg.md#sui_halo2_kzg_ArtifactBuilder">ArtifactBuilder</a>,
    expected_digest: vector&lt;u8&gt;,
    ctx: &<b>mut</b> TxContext,
) {
    <a href="../sui/transfer.md#sui_transfer_public_transfer">transfer::public_transfer</a>(<a href="../sui/halo2_kzg.md#sui_halo2_kzg_finalize_vk">finalize_vk</a>(builder, expected_digest, ctx), ctx.sender())
}
</code></pre>



</details>

<a name="sui_halo2_kzg_finalize_circuit_info_to_sender"></a>

## Function `finalize_circuit_info_to_sender`



<pre><code><b>entry</b> <b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_finalize_circuit_info_to_sender">finalize_circuit_info_to_sender</a>(builder: <a href="../sui/halo2_kzg.md#sui_halo2_kzg_ArtifactBuilder">sui::halo2_kzg::ArtifactBuilder</a>, expected_digest: vector&lt;u8&gt;, ctx: &<b>mut</b> <a href="../sui/tx_context.md#sui_tx_context_TxContext">sui::tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>entry</b> <b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_finalize_circuit_info_to_sender">finalize_circuit_info_to_sender</a>(
    builder: <a href="../sui/halo2_kzg.md#sui_halo2_kzg_ArtifactBuilder">ArtifactBuilder</a>,
    expected_digest: vector&lt;u8&gt;,
    ctx: &<b>mut</b> TxContext,
) {
    <a href="../sui/transfer.md#sui_transfer_public_transfer">transfer::public_transfer</a>(<a href="../sui/halo2_kzg.md#sui_halo2_kzg_finalize_circuit_info">finalize_circuit_info</a>(builder, expected_digest, ctx), ctx.sender())
}
</code></pre>



</details>

<a name="sui_halo2_kzg_finalize_params_and_freeze"></a>

## Function `finalize_params_and_freeze`



<pre><code><b>entry</b> <b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_finalize_params_and_freeze">finalize_params_and_freeze</a>(builder: <a href="../sui/halo2_kzg.md#sui_halo2_kzg_ArtifactBuilder">sui::halo2_kzg::ArtifactBuilder</a>, expected_digest: vector&lt;u8&gt;, ctx: &<b>mut</b> <a href="../sui/tx_context.md#sui_tx_context_TxContext">sui::tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>entry</b> <b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_finalize_params_and_freeze">finalize_params_and_freeze</a>(
    builder: <a href="../sui/halo2_kzg.md#sui_halo2_kzg_ArtifactBuilder">ArtifactBuilder</a>,
    expected_digest: vector&lt;u8&gt;,
    ctx: &<b>mut</b> TxContext,
) {
    <a href="../sui/transfer.md#sui_transfer_public_freeze_object">transfer::public_freeze_object</a>(<a href="../sui/halo2_kzg.md#sui_halo2_kzg_finalize_params">finalize_params</a>(builder, expected_digest, ctx))
}
</code></pre>



</details>

<a name="sui_halo2_kzg_finalize_vk_and_freeze"></a>

## Function `finalize_vk_and_freeze`



<pre><code><b>entry</b> <b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_finalize_vk_and_freeze">finalize_vk_and_freeze</a>(builder: <a href="../sui/halo2_kzg.md#sui_halo2_kzg_ArtifactBuilder">sui::halo2_kzg::ArtifactBuilder</a>, expected_digest: vector&lt;u8&gt;, ctx: &<b>mut</b> <a href="../sui/tx_context.md#sui_tx_context_TxContext">sui::tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>entry</b> <b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_finalize_vk_and_freeze">finalize_vk_and_freeze</a>(
    builder: <a href="../sui/halo2_kzg.md#sui_halo2_kzg_ArtifactBuilder">ArtifactBuilder</a>,
    expected_digest: vector&lt;u8&gt;,
    ctx: &<b>mut</b> TxContext,
) {
    <a href="../sui/transfer.md#sui_transfer_public_freeze_object">transfer::public_freeze_object</a>(<a href="../sui/halo2_kzg.md#sui_halo2_kzg_finalize_vk">finalize_vk</a>(builder, expected_digest, ctx))
}
</code></pre>



</details>

<a name="sui_halo2_kzg_finalize_circuit_info_and_freeze"></a>

## Function `finalize_circuit_info_and_freeze`



<pre><code><b>entry</b> <b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_finalize_circuit_info_and_freeze">finalize_circuit_info_and_freeze</a>(builder: <a href="../sui/halo2_kzg.md#sui_halo2_kzg_ArtifactBuilder">sui::halo2_kzg::ArtifactBuilder</a>, expected_digest: vector&lt;u8&gt;, ctx: &<b>mut</b> <a href="../sui/tx_context.md#sui_tx_context_TxContext">sui::tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>entry</b> <b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_finalize_circuit_info_and_freeze">finalize_circuit_info_and_freeze</a>(
    builder: <a href="../sui/halo2_kzg.md#sui_halo2_kzg_ArtifactBuilder">ArtifactBuilder</a>,
    expected_digest: vector&lt;u8&gt;,
    ctx: &<b>mut</b> TxContext,
) {
    <a href="../sui/transfer.md#sui_transfer_public_freeze_object">transfer::public_freeze_object</a>(<a href="../sui/halo2_kzg.md#sui_halo2_kzg_finalize_circuit_info">finalize_circuit_info</a>(builder, expected_digest, ctx))
}
</code></pre>



</details>

<a name="sui_halo2_kzg_builder_kind"></a>

## Function `builder_kind`



<pre><code><b>public</b> <b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_builder_kind">builder_kind</a>(builder: &<a href="../sui/halo2_kzg.md#sui_halo2_kzg_ArtifactBuilder">sui::halo2_kzg::ArtifactBuilder</a>): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_builder_kind">builder_kind</a>(builder: &<a href="../sui/halo2_kzg.md#sui_halo2_kzg_ArtifactBuilder">ArtifactBuilder</a>): u8 {
    builder.kind
}
</code></pre>



</details>

<a name="sui_halo2_kzg_builder_len"></a>

## Function `builder_len`



<pre><code><b>public</b> <b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_builder_len">builder_len</a>(builder: &<a href="../sui/halo2_kzg.md#sui_halo2_kzg_ArtifactBuilder">sui::halo2_kzg::ArtifactBuilder</a>): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_builder_len">builder_len</a>(builder: &<a href="../sui/halo2_kzg.md#sui_halo2_kzg_ArtifactBuilder">ArtifactBuilder</a>): u64 {
    builder.bytes.length()
}
</code></pre>



</details>

<a name="sui_halo2_kzg_destroy_builder"></a>

## Function `destroy_builder`



<pre><code><b>public</b> <b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_destroy_builder">destroy_builder</a>(builder: <a href="../sui/halo2_kzg.md#sui_halo2_kzg_ArtifactBuilder">sui::halo2_kzg::ArtifactBuilder</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_destroy_builder">destroy_builder</a>(builder: <a href="../sui/halo2_kzg.md#sui_halo2_kzg_ArtifactBuilder">ArtifactBuilder</a>) {
    <b>let</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_ArtifactBuilder">ArtifactBuilder</a> { id, kind: _, bytes: _, max_bytes: _ } = builder;
    <a href="../sui/object.md#sui_object_delete">object::delete</a>(id)
}
</code></pre>



</details>

<a name="sui_halo2_kzg_verify_proof"></a>

## Function `verify_proof`

Verifies a Halo2 KZG proof.

@param params Serialized KZG verifier parameters.
@param params_digest Blake2b-256 digest of <code>params</code>.
@param vk Serialized Halo2 verifying key.
@param vk_digest Blake2b-256 digest of <code>vk</code>.
@param circuit_info Serialized circuit metadata used to reconstruct the verifier constraint system.
@param circuit_info_digest Blake2b-256 digest of <code>circuit_info</code>.
@param public_inputs Serialized public inputs for the proof.
@param proof Serialized Halo2 proof bytes.
@param kzg_variant KZG opening variant. Use <code><a href="../sui/halo2_kzg.md#sui_halo2_kzg_kzg_gwc">kzg_gwc</a></code> or <code><a href="../sui/halo2_kzg.md#sui_halo2_kzg_kzg_shplonk">kzg_shplonk</a></code>.
@param k_present Whether to downsize the serialized parameters to <code>k</code> before verification.
@param k Target parameter size when <code>k_present</code> is <code><b>true</b></code>. When <code>k_present</code> is <code><b>false</b></code>, <code>k</code> is ignored and may be any <code>u32</code>.

Returns <code><b>true</b></code> when the proof verifies and <code><b>false</b></code> when the proof is invalid or any supplied
digest does not match its corresponding byte vector.

Aborts if a digest is not 32 bytes, <code>kzg_variant</code> is unsupported, the native verifier is not
enabled by protocol config, input byte limits are exceeded, or the native verifier cannot
interpret the supplied bytes.


<pre><code><b>public</b> <b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_verify_proof">verify_proof</a>(params: vector&lt;u8&gt;, params_digest: vector&lt;u8&gt;, vk: vector&lt;u8&gt;, vk_digest: vector&lt;u8&gt;, circuit_info: vector&lt;u8&gt;, circuit_info_digest: vector&lt;u8&gt;, public_inputs: vector&lt;u8&gt;, proof: vector&lt;u8&gt;, kzg_variant: u8, k_present: bool, k: u32): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_verify_proof">verify_proof</a>(
    params: vector&lt;u8&gt;,
    params_digest: vector&lt;u8&gt;,
    vk: vector&lt;u8&gt;,
    vk_digest: vector&lt;u8&gt;,
    circuit_info: vector&lt;u8&gt;,
    circuit_info_digest: vector&lt;u8&gt;,
    public_inputs: vector&lt;u8&gt;,
    proof: vector&lt;u8&gt;,
    kzg_variant: u8,
    k_present: bool,
    k: u32,
): bool {
    <a href="../sui/halo2_kzg.md#sui_halo2_kzg_assert_params_size">assert_params_size</a>(&params);
    <a href="../sui/halo2_kzg.md#sui_halo2_kzg_assert_vk_size">assert_vk_size</a>(&vk);
    <a href="../sui/halo2_kzg.md#sui_halo2_kzg_assert_circuit_info_size">assert_circuit_info_size</a>(&circuit_info);
    <a href="../sui/halo2_kzg.md#sui_halo2_kzg_assert_public_inputs_size">assert_public_inputs_size</a>(&public_inputs);
    <a href="../sui/halo2_kzg.md#sui_halo2_kzg_assert_proof_size">assert_proof_size</a>(&proof);
    <b>assert</b>!(params_digest.length() == 32, <a href="../sui/halo2_kzg.md#sui_halo2_kzg_EInvalidDigestLength">EInvalidDigestLength</a>);
    <b>assert</b>!(vk_digest.length() == 32, <a href="../sui/halo2_kzg.md#sui_halo2_kzg_EInvalidDigestLength">EInvalidDigestLength</a>);
    <b>assert</b>!(circuit_info_digest.length() == 32, <a href="../sui/halo2_kzg.md#sui_halo2_kzg_EInvalidDigestLength">EInvalidDigestLength</a>);
    <b>assert</b>!(
        kzg_variant == <a href="../sui/halo2_kzg.md#sui_halo2_kzg_KZG_GWC">KZG_GWC</a> || kzg_variant == <a href="../sui/halo2_kzg.md#sui_halo2_kzg_KZG_SHPLONK">KZG_SHPLONK</a>,
        <a href="../sui/halo2_kzg.md#sui_halo2_kzg_EUnsupportedKzgVariant">EUnsupportedKzgVariant</a>,
    );
    <a href="../sui/halo2_kzg.md#sui_halo2_kzg_verify_proof_internal">verify_proof_internal</a>(
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
</code></pre>



</details>

<a name="sui_halo2_kzg_verify_proof_bytes"></a>

## Function `verify_proof_bytes`



<pre><code><b>public</b> <b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_verify_proof_bytes">verify_proof_bytes</a>(params: vector&lt;u8&gt;, params_digest: vector&lt;u8&gt;, vk: vector&lt;u8&gt;, vk_digest: vector&lt;u8&gt;, circuit_info: vector&lt;u8&gt;, circuit_info_digest: vector&lt;u8&gt;, public_inputs: vector&lt;u8&gt;, proof: vector&lt;u8&gt;, kzg_variant: u8, k_present: bool, k: u32): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_verify_proof_bytes">verify_proof_bytes</a>(
    params: vector&lt;u8&gt;,
    params_digest: vector&lt;u8&gt;,
    vk: vector&lt;u8&gt;,
    vk_digest: vector&lt;u8&gt;,
    circuit_info: vector&lt;u8&gt;,
    circuit_info_digest: vector&lt;u8&gt;,
    public_inputs: vector&lt;u8&gt;,
    proof: vector&lt;u8&gt;,
    kzg_variant: u8,
    k_present: bool,
    k: u32,
): bool {
    <a href="../sui/halo2_kzg.md#sui_halo2_kzg_verify_proof">verify_proof</a>(
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
</code></pre>



</details>

<a name="sui_halo2_kzg_verify_artifact_proof"></a>

## Function `verify_artifact_proof`



<pre><code><b>public</b> <b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_verify_artifact_proof">verify_artifact_proof</a>(params: &<a href="../sui/halo2_kzg.md#sui_halo2_kzg_SerializedParams">sui::halo2_kzg::SerializedParams</a>, vk: &<a href="../sui/halo2_kzg.md#sui_halo2_kzg_SerializedVK">sui::halo2_kzg::SerializedVK</a>, circuit: &<a href="../sui/halo2_kzg.md#sui_halo2_kzg_SerializedCircuit">sui::halo2_kzg::SerializedCircuit</a>, public_inputs: <a href="../sui/halo2_kzg.md#sui_halo2_kzg_PublicInputs">sui::halo2_kzg::PublicInputs</a>, proof: vector&lt;u8&gt;, kzg_variant: u8, k_present: bool, k: u32): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_verify_artifact_proof">verify_artifact_proof</a>(
    params: &<a href="../sui/halo2_kzg.md#sui_halo2_kzg_SerializedParams">SerializedParams</a>,
    vk: &<a href="../sui/halo2_kzg.md#sui_halo2_kzg_SerializedVK">SerializedVK</a>,
    circuit: &<a href="../sui/halo2_kzg.md#sui_halo2_kzg_SerializedCircuit">SerializedCircuit</a>,
    public_inputs: <a href="../sui/halo2_kzg.md#sui_halo2_kzg_PublicInputs">PublicInputs</a>,
    proof: vector&lt;u8&gt;,
    kzg_variant: u8,
    k_present: bool,
    k: u32,
): bool {
    <a href="../sui/halo2_kzg.md#sui_halo2_kzg_assert_supported_params_version">assert_supported_params_version</a>(params);
    <a href="../sui/halo2_kzg.md#sui_halo2_kzg_assert_supported_vk_version">assert_supported_vk_version</a>(vk);
    <a href="../sui/halo2_kzg.md#sui_halo2_kzg_assert_supported_circuit_version">assert_supported_circuit_version</a>(circuit);
    <a href="../sui/halo2_kzg.md#sui_halo2_kzg_assert_proof_size">assert_proof_size</a>(&proof);
    <b>let</b> public_inputs_bytes = <a href="../sui/halo2_kzg.md#sui_halo2_kzg_public_inputs_to_bcs_bytes">public_inputs_to_bcs_bytes</a>(&public_inputs);
    <a href="../sui/halo2_kzg.md#sui_halo2_kzg_assert_public_inputs_size">assert_public_inputs_size</a>(&public_inputs_bytes);
    <a href="../sui/halo2_kzg.md#sui_halo2_kzg_verify_proof">verify_proof</a>(
        <a href="../sui/halo2_kzg.md#sui_halo2_kzg_get_serialized_params">get_serialized_params</a>(params),
        <a href="../sui/halo2_kzg.md#sui_halo2_kzg_get_serialized_params_digest">get_serialized_params_digest</a>(params),
        <a href="../sui/halo2_kzg.md#sui_halo2_kzg_get_serialized_vk">get_serialized_vk</a>(vk),
        <a href="../sui/halo2_kzg.md#sui_halo2_kzg_get_serialized_vk_digest">get_serialized_vk_digest</a>(vk),
        <a href="../sui/halo2_kzg.md#sui_halo2_kzg_get_serialized_circuit">get_serialized_circuit</a>(circuit),
        <a href="../sui/halo2_kzg.md#sui_halo2_kzg_get_serialized_circuit_digest">get_serialized_circuit_digest</a>(circuit),
        public_inputs_bytes,
        proof,
        kzg_variant,
        k_present,
        k,
    )
}
</code></pre>



</details>

<a name="sui_halo2_kzg_verify_with_artifacts"></a>

## Function `verify_with_artifacts`



<pre><code><b>entry</b> <b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_verify_with_artifacts">verify_with_artifacts</a>(params: &<a href="../sui/halo2_kzg.md#sui_halo2_kzg_SerializedParams">sui::halo2_kzg::SerializedParams</a>, vk: &<a href="../sui/halo2_kzg.md#sui_halo2_kzg_SerializedVK">sui::halo2_kzg::SerializedVK</a>, circuit: &<a href="../sui/halo2_kzg.md#sui_halo2_kzg_SerializedCircuit">sui::halo2_kzg::SerializedCircuit</a>, public_inputs: vector&lt;vector&lt;vector&lt;u8&gt;&gt;&gt;, proof: vector&lt;u8&gt;, kzg_variant: u8, k_present: bool, k: u32)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>entry</b> <b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_verify_with_artifacts">verify_with_artifacts</a>(
    params: &<a href="../sui/halo2_kzg.md#sui_halo2_kzg_SerializedParams">SerializedParams</a>,
    vk: &<a href="../sui/halo2_kzg.md#sui_halo2_kzg_SerializedVK">SerializedVK</a>,
    circuit: &<a href="../sui/halo2_kzg.md#sui_halo2_kzg_SerializedCircuit">SerializedCircuit</a>,
    public_inputs: vector&lt;vector&lt;vector&lt;u8&gt;&gt;&gt;,
    proof: vector&lt;u8&gt;,
    kzg_variant: u8,
    k_present: bool,
    k: u32,
) {
    <b>let</b> public_inputs = <a href="../sui/halo2_kzg.md#sui_halo2_kzg_public_inputs_from_bytes">public_inputs_from_bytes</a>(public_inputs);
    <b>assert</b>!(
        <a href="../sui/halo2_kzg.md#sui_halo2_kzg_verify_artifact_proof">verify_artifact_proof</a>(
            params,
            vk,
            circuit,
            public_inputs,
            proof,
            kzg_variant,
            k_present,
            k,
        ),
        <a href="../sui/halo2_kzg.md#sui_halo2_kzg_EVerifyProof">EVerifyProof</a>,
    )
}
</code></pre>



</details>

<a name="sui_halo2_kzg_assert_supported_vk_version"></a>

## Function `assert_supported_vk_version`



<pre><code><b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_assert_supported_vk_version">assert_supported_vk_version</a>(vk: &<a href="../sui/halo2_kzg.md#sui_halo2_kzg_SerializedVK">sui::halo2_kzg::SerializedVK</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_assert_supported_vk_version">assert_supported_vk_version</a>(vk: &<a href="../sui/halo2_kzg.md#sui_halo2_kzg_SerializedVK">SerializedVK</a>) {
    <b>assert</b>!(vk.version == <a href="../sui/halo2_kzg.md#sui_halo2_kzg_ARTIFACT_VERSION">ARTIFACT_VERSION</a>, <a href="../sui/halo2_kzg.md#sui_halo2_kzg_EUnsupportedVersion">EUnsupportedVersion</a>)
}
</code></pre>



</details>

<a name="sui_halo2_kzg_assert_supported_circuit_version"></a>

## Function `assert_supported_circuit_version`



<pre><code><b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_assert_supported_circuit_version">assert_supported_circuit_version</a>(circuit: &<a href="../sui/halo2_kzg.md#sui_halo2_kzg_SerializedCircuit">sui::halo2_kzg::SerializedCircuit</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_assert_supported_circuit_version">assert_supported_circuit_version</a>(circuit: &<a href="../sui/halo2_kzg.md#sui_halo2_kzg_SerializedCircuit">SerializedCircuit</a>) {
    <b>assert</b>!(circuit.version == <a href="../sui/halo2_kzg.md#sui_halo2_kzg_ARTIFACT_VERSION">ARTIFACT_VERSION</a>, <a href="../sui/halo2_kzg.md#sui_halo2_kzg_EUnsupportedVersion">EUnsupportedVersion</a>)
}
</code></pre>



</details>

<a name="sui_halo2_kzg_assert_params_size"></a>

## Function `assert_params_size`



<pre><code><b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_assert_params_size">assert_params_size</a>(bytes: &vector&lt;u8&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_assert_params_size">assert_params_size</a>(bytes: &vector&lt;u8&gt;) {
    <b>assert</b>!(bytes.length() &lt;= <a href="../sui/halo2_kzg.md#sui_halo2_kzg_MAX_PARAMS_BYTES">MAX_PARAMS_BYTES</a>, <a href="../sui/halo2_kzg.md#sui_halo2_kzg_EInputTooLarge">EInputTooLarge</a>)
}
</code></pre>



</details>

<a name="sui_halo2_kzg_assert_vk_size"></a>

## Function `assert_vk_size`



<pre><code><b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_assert_vk_size">assert_vk_size</a>(bytes: &vector&lt;u8&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_assert_vk_size">assert_vk_size</a>(bytes: &vector&lt;u8&gt;) {
    <b>assert</b>!(bytes.length() &lt;= <a href="../sui/halo2_kzg.md#sui_halo2_kzg_MAX_VK_BYTES">MAX_VK_BYTES</a>, <a href="../sui/halo2_kzg.md#sui_halo2_kzg_EInputTooLarge">EInputTooLarge</a>)
}
</code></pre>



</details>

<a name="sui_halo2_kzg_assert_circuit_info_size"></a>

## Function `assert_circuit_info_size`



<pre><code><b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_assert_circuit_info_size">assert_circuit_info_size</a>(bytes: &vector&lt;u8&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_assert_circuit_info_size">assert_circuit_info_size</a>(bytes: &vector&lt;u8&gt;) {
    <b>assert</b>!(bytes.length() &lt;= <a href="../sui/halo2_kzg.md#sui_halo2_kzg_MAX_CIRCUIT_INFO_BYTES">MAX_CIRCUIT_INFO_BYTES</a>, <a href="../sui/halo2_kzg.md#sui_halo2_kzg_EInputTooLarge">EInputTooLarge</a>)
}
</code></pre>



</details>

<a name="sui_halo2_kzg_assert_proof_size"></a>

## Function `assert_proof_size`



<pre><code><b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_assert_proof_size">assert_proof_size</a>(bytes: &vector&lt;u8&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_assert_proof_size">assert_proof_size</a>(bytes: &vector&lt;u8&gt;) {
    <b>assert</b>!(bytes.length() &lt;= <a href="../sui/halo2_kzg.md#sui_halo2_kzg_MAX_PROOF_BYTES">MAX_PROOF_BYTES</a>, <a href="../sui/halo2_kzg.md#sui_halo2_kzg_EInputTooLarge">EInputTooLarge</a>)
}
</code></pre>



</details>

<a name="sui_halo2_kzg_assert_public_inputs_size"></a>

## Function `assert_public_inputs_size`



<pre><code><b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_assert_public_inputs_size">assert_public_inputs_size</a>(bytes: &vector&lt;u8&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_assert_public_inputs_size">assert_public_inputs_size</a>(bytes: &vector&lt;u8&gt;) {
    <b>assert</b>!(bytes.length() &lt;= <a href="../sui/halo2_kzg.md#sui_halo2_kzg_MAX_PUBLIC_INPUTS_BYTES">MAX_PUBLIC_INPUTS_BYTES</a>, <a href="../sui/halo2_kzg.md#sui_halo2_kzg_EInputTooLarge">EInputTooLarge</a>)
}
</code></pre>



</details>

<a name="sui_halo2_kzg_assert_chunk_size"></a>

## Function `assert_chunk_size`



<pre><code><b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_assert_chunk_size">assert_chunk_size</a>(bytes: &vector&lt;u8&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_assert_chunk_size">assert_chunk_size</a>(bytes: &vector&lt;u8&gt;) {
    <b>assert</b>!(bytes.length() &lt;= <a href="../sui/halo2_kzg.md#sui_halo2_kzg_MAX_CHUNK_BYTES">MAX_CHUNK_BYTES</a>, <a href="../sui/halo2_kzg.md#sui_halo2_kzg_EChunkTooLarge">EChunkTooLarge</a>)
}
</code></pre>



</details>

<a name="sui_halo2_kzg_assert_total_size"></a>

## Function `assert_total_size`



<pre><code><b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_assert_total_size">assert_total_size</a>(total_bytes: u64, max_bytes: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_assert_total_size">assert_total_size</a>(total_bytes: u64, max_bytes: u64) {
    <b>assert</b>!(total_bytes &lt;= max_bytes, <a href="../sui/halo2_kzg.md#sui_halo2_kzg_EInputTooLarge">EInputTooLarge</a>)
}
</code></pre>



</details>

<a name="sui_halo2_kzg_new_builder"></a>

## Function `new_builder`



<pre><code><b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_new_builder">new_builder</a>(kind: u8, max_bytes: u64, ctx: &<b>mut</b> <a href="../sui/tx_context.md#sui_tx_context_TxContext">sui::tx_context::TxContext</a>): <a href="../sui/halo2_kzg.md#sui_halo2_kzg_ArtifactBuilder">sui::halo2_kzg::ArtifactBuilder</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_new_builder">new_builder</a>(kind: u8, max_bytes: u64, ctx: &<b>mut</b> TxContext): <a href="../sui/halo2_kzg.md#sui_halo2_kzg_ArtifactBuilder">ArtifactBuilder</a> {
    <b>let</b> builder = <a href="../sui/halo2_kzg.md#sui_halo2_kzg_ArtifactBuilder">ArtifactBuilder</a> {
        id: <a href="../sui/object.md#sui_object_new">object::new</a>(ctx),
        kind,
        bytes: vector[],
        max_bytes,
    };
    <a href="../sui/event.md#sui_event_emit">event::emit</a>(<a href="../sui/halo2_kzg.md#sui_halo2_kzg_BuilderCreated">BuilderCreated</a> {
        builder_id: <a href="../sui/object.md#sui_object_id">object::id</a>(&builder),
        kind,
        max_bytes,
        owner: ctx.sender(),
    });
    builder
}
</code></pre>



</details>

<a name="sui_halo2_kzg_finish"></a>

## Function `finish`



<pre><code><b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_finish">finish</a>(builder: <a href="../sui/halo2_kzg.md#sui_halo2_kzg_ArtifactBuilder">sui::halo2_kzg::ArtifactBuilder</a>, expected_kind: u8, expected_digest: vector&lt;u8&gt;): (<a href="../sui/object.md#sui_object_ID">sui::object::ID</a>, vector&lt;u8&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_finish">finish</a>(
    builder: <a href="../sui/halo2_kzg.md#sui_halo2_kzg_ArtifactBuilder">ArtifactBuilder</a>,
    expected_kind: u8,
    expected_digest: vector&lt;u8&gt;,
): (ID, vector&lt;u8&gt;) {
    <b>let</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_ArtifactBuilder">ArtifactBuilder</a> { id, kind, bytes, max_bytes: _ } = builder;
    <b>let</b> builder_id = <a href="../sui/object.md#sui_object_uid_to_inner">object::uid_to_inner</a>(&id);
    <a href="../sui/object.md#sui_object_delete">object::delete</a>(id);
    <b>assert</b>!(kind == expected_kind, <a href="../sui/halo2_kzg.md#sui_halo2_kzg_EWrongArtifactKind">EWrongArtifactKind</a>);
    <b>assert</b>!(!bytes.is_empty(), <a href="../sui/halo2_kzg.md#sui_halo2_kzg_EEmptyArtifact">EEmptyArtifact</a>);
    <b>assert</b>!(<a href="../sui/hash.md#sui_hash_blake2b256">hash::blake2b256</a>(&bytes) == expected_digest, <a href="../sui/halo2_kzg.md#sui_halo2_kzg_EDigestMismatch">EDigestMismatch</a>);
    (builder_id, bytes)
}
</code></pre>



</details>

<a name="sui_halo2_kzg_emit_finalized"></a>

## Function `emit_finalized`



<pre><code><b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_emit_finalized">emit_finalized</a>(builder_id: <a href="../sui/object.md#sui_object_ID">sui::object::ID</a>, artifact_id: <a href="../sui/object.md#sui_object_ID">sui::object::ID</a>, kind: u8, digest: vector&lt;u8&gt;, total_len: u64, ctx: &<a href="../sui/tx_context.md#sui_tx_context_TxContext">sui::tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_emit_finalized">emit_finalized</a>(
    builder_id: ID,
    artifact_id: ID,
    kind: u8,
    digest: vector&lt;u8&gt;,
    total_len: u64,
    ctx: &TxContext,
) {
    <a href="../sui/event.md#sui_event_emit">event::emit</a>(<a href="../sui/halo2_kzg.md#sui_halo2_kzg_ArtifactFinalized">ArtifactFinalized</a> {
        builder_id,
        artifact_id,
        kind,
        total_len,
        digest,
        owner: ctx.sender(),
    })
}
</code></pre>



</details>

<a name="sui_halo2_kzg_verify_proof_internal"></a>

## Function `verify_proof_internal`

Native verifier entry point. Call <code><a href="../sui/halo2_kzg.md#sui_halo2_kzg_verify_proof">verify_proof</a></code> instead so cheap argument checks happen in Move
before entering the native verifier.


<pre><code><b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_verify_proof_internal">verify_proof_internal</a>(params: vector&lt;u8&gt;, params_digest: vector&lt;u8&gt;, vk: vector&lt;u8&gt;, vk_digest: vector&lt;u8&gt;, circuit_info: vector&lt;u8&gt;, circuit_info_digest: vector&lt;u8&gt;, public_inputs: vector&lt;u8&gt;, proof: vector&lt;u8&gt;, kzg_variant: u8, k_present: bool, k: u32): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>native</b> <b>fun</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_verify_proof_internal">verify_proof_internal</a>(
    params: vector&lt;u8&gt;,
    params_digest: vector&lt;u8&gt;,
    vk: vector&lt;u8&gt;,
    vk_digest: vector&lt;u8&gt;,
    circuit_info: vector&lt;u8&gt;,
    circuit_info_digest: vector&lt;u8&gt;,
    public_inputs: vector&lt;u8&gt;,
    proof: vector&lt;u8&gt;,
    kzg_variant: u8,
    k_present: bool,
    k: u32,
): bool;
</code></pre>



</details>
