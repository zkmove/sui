---
title: Module `sui::halo2_kzg`
---

Verifies Halo2 proofs over BN254 with KZG commitments.

The verifier accepts serialized KZG parameters, a serialized Halo2 verifying key, serialized
circuit metadata, public inputs, and proof bytes produced by the matching Halo2 toolchain. The
large static inputs are accompanied by 32-byte Blake2b-256 digests; the native verifier checks
those digests before attempting proof verification.

Both GWC and Shplonk KZG multi-opening variants are supported. Verification returns <code><b>true</b></code> for
a valid proof and <code><b>false</b></code> for a proof or digest mismatch. Malformed verifier inputs, oversized
inputs, unsupported protocol configuration, or native verifier failures may abort.


-  [Constants](#@Constants_0)
-  [Function `abi_version`](#sui_halo2_kzg_abi_version)
-  [Function `kzg_gwc`](#sui_halo2_kzg_kzg_gwc)
-  [Function `kzg_shplonk`](#sui_halo2_kzg_kzg_shplonk)
-  [Function `verify_proof`](#sui_halo2_kzg_verify_proof)
-  [Function `verify_proof_internal`](#sui_halo2_kzg_verify_proof_internal)


<pre><code></code></pre>



<a name="@Constants_0"></a>

## Constants


<a name="sui_halo2_kzg_EUnsupportedKzgVariant"></a>

The supplied KZG opening variant is not supported by this module.


<pre><code><b>const</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_EUnsupportedKzgVariant">EUnsupportedKzgVariant</a>: u64 = 1;
</code></pre>



<a name="sui_halo2_kzg_EInvalidDigestLength"></a>

<code>params_digest</code>, <code>vk_digest</code>, and <code>circuit_info_digest</code> must each be exactly 32 bytes.


<pre><code><b>const</b> <a href="../sui/halo2_kzg.md#sui_halo2_kzg_EInvalidDigestLength">EInvalidDigestLength</a>: u64 = 2;
</code></pre>



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
