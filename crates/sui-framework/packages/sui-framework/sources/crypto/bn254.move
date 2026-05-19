// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

/// Group operations of BN254.
module sui::bn254;

use sui::group_ops::{Self, Element};

/////////////////////////////////////////////
////// Elliptic curve operations //////

public struct Scalar {}
public struct G1 {}
public struct G2 {}
public struct GT {}

// Scalars are encoded using big-endian byte order and are always 32 bytes,
// matching fastcrypto's BN254 group API. G1, G2, and GT encodings are defined
// by the corresponding native `group_ops` implementation for these BN254 type
// identifiers.

// Const scalar elements.
const SCALAR_ZERO_BYTES: vector<u8> =
    x"0000000000000000000000000000000000000000000000000000000000000000";
const SCALAR_ONE_BYTES: vector<u8> =
    x"0000000000000000000000000000000000000000000000000000000000000001";

// Const G1 elements.
const G1_GENERATOR_BYTES: vector<u8> =
    x"0100000000000000000000000000000000000000000000000000000000000000";
const G1_IDENTITY_BYTES: vector<u8> =
    x"0000000000000000000000000000000000000000000000000000000000000040";

// Const G2 elements.
const G2_GENERATOR_BYTES: vector<u8> =
    x"edf692d95cbdde46ddda5ef7d422436779445c5e66006a42761e1f12efde0018c212f3aeb785e49712e7a9353349aaf1255dfb31b7bf60723a480d9293938e19";
const G2_IDENTITY_BYTES: vector<u8> =
    x"00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000040";

// Internal types used by group_ops' native functions. Keep these aligned with
// sui-move-natives' `Groups` enum when BN254 native support is enabled.
const SCALAR_TYPE: u8 = 7;
const G1_TYPE: u8 = 8;
const G2_TYPE: u8 = 9;
const GT_TYPE: u8 = 10;

///////////////////////////////
////// Scalar operations //////

public fun scalar_from_bytes(bytes: &vector<u8>): Element<Scalar> {
    group_ops::from_bytes(SCALAR_TYPE, *bytes, false)
}

public fun scalar_from_u64(x: u64): Element<Scalar> {
    let mut bytes = SCALAR_ZERO_BYTES;
    group_ops::set_as_prefix(x, true, &mut bytes);
    group_ops::from_bytes(SCALAR_TYPE, bytes, true)
}

public fun scalar_zero(): Element<Scalar> {
    group_ops::from_bytes(SCALAR_TYPE, SCALAR_ZERO_BYTES, true)
}

public fun scalar_one(): Element<Scalar> {
    group_ops::from_bytes(SCALAR_TYPE, SCALAR_ONE_BYTES, true)
}

public fun scalar_add(e1: &Element<Scalar>, e2: &Element<Scalar>): Element<Scalar> {
    group_ops::add(SCALAR_TYPE, e1, e2)
}

public fun scalar_sub(e1: &Element<Scalar>, e2: &Element<Scalar>): Element<Scalar> {
    group_ops::sub(SCALAR_TYPE, e1, e2)
}

public fun scalar_mul(e1: &Element<Scalar>, e2: &Element<Scalar>): Element<Scalar> {
    group_ops::mul(SCALAR_TYPE, e1, e2)
}

/// Returns e2/e1, fails if a is zero.
public fun scalar_div(e1: &Element<Scalar>, e2: &Element<Scalar>): Element<Scalar> {
    group_ops::div(SCALAR_TYPE, e1, e2)
}

public fun scalar_neg(e: &Element<Scalar>): Element<Scalar> {
    scalar_sub(&scalar_zero(), e)
}

// Fails if e is zero.
public fun scalar_inv(e: &Element<Scalar>): Element<Scalar> {
    scalar_div(e, &scalar_one())
}

/////////////////////////////////
////// G1 group operations //////

public fun g1_from_bytes(bytes: &vector<u8>): Element<G1> {
    group_ops::from_bytes(G1_TYPE, *bytes, false)
}

public fun g1_generator(): Element<G1> {
    group_ops::from_bytes(G1_TYPE, G1_GENERATOR_BYTES, true)
}

public fun g1_identity(): Element<G1> {
    group_ops::from_bytes(G1_TYPE, G1_IDENTITY_BYTES, true)
}

public fun g1_neg(e: &Element<G1>): Element<G1> {
    g1_sub(&g1_identity(), e)
}

public fun g1_add(e1: &Element<G1>, e2: &Element<G1>): Element<G1> {
    group_ops::add(G1_TYPE, e1, e2)
}

public fun g1_sub(e1: &Element<G1>, e2: &Element<G1>): Element<G1> {
    group_ops::sub(G1_TYPE, e1, e2)
}

public fun g1_mul(e1: &Element<Scalar>, e2: &Element<G1>): Element<G1> {
    group_ops::mul(G1_TYPE, e1, e2)
}

/// Returns e2 / e1, fails if scalar is zero.
public fun g1_div(e1: &Element<Scalar>, e2: &Element<G1>): Element<G1> {
    group_ops::div(G1_TYPE, e1, e2)
}

/// Let 'scalars' be the vector [s1, s2, ..., sn] and 'elements' be the vector [e1, e2, ..., en].
/// Returns s1*e1 + s2*e2 + ... + sn*en.
public fun g1_multi_scalar_multiplication(
    scalars: &vector<Element<Scalar>>,
    elements: &vector<Element<G1>>,
): Element<G1> {
    group_ops::multi_scalar_multiplication(G1_TYPE, scalars, elements)
}

/////////////////////////////////
////// G2 group operations //////

public fun g2_from_bytes(bytes: &vector<u8>): Element<G2> {
    group_ops::from_bytes(G2_TYPE, *bytes, false)
}

public fun g2_generator(): Element<G2> {
    group_ops::from_bytes(G2_TYPE, G2_GENERATOR_BYTES, true)
}

public fun g2_identity(): Element<G2> {
    group_ops::from_bytes(G2_TYPE, G2_IDENTITY_BYTES, true)
}

public fun g2_neg(e: &Element<G2>): Element<G2> {
    g2_sub(&g2_identity(), e)
}

public fun g2_add(e1: &Element<G2>, e2: &Element<G2>): Element<G2> {
    group_ops::add(G2_TYPE, e1, e2)
}

public fun g2_sub(e1: &Element<G2>, e2: &Element<G2>): Element<G2> {
    group_ops::sub(G2_TYPE, e1, e2)
}

public fun g2_mul(e1: &Element<Scalar>, e2: &Element<G2>): Element<G2> {
    group_ops::mul(G2_TYPE, e1, e2)
}

/// Returns e2 / e1, fails if scalar is zero.
public fun g2_div(e1: &Element<Scalar>, e2: &Element<G2>): Element<G2> {
    group_ops::div(G2_TYPE, e1, e2)
}

/// Let 'scalars' be the vector [s1, s2, ..., sn] and 'elements' be the vector [e1, e2, ..., en].
/// Returns s1*e1 + s2*e2 + ... + sn*en.
public fun g2_multi_scalar_multiplication(
    scalars: &vector<Element<Scalar>>,
    elements: &vector<Element<G2>>,
): Element<G2> {
    group_ops::multi_scalar_multiplication(G2_TYPE, scalars, elements)
}

/////////////////////////////////
////// Gt group operations //////

public fun gt_from_bytes(bytes: &vector<u8>): Element<GT> {
    group_ops::from_bytes(GT_TYPE, *bytes, false)
}

public fun gt_generator(): Element<GT> {
    pairing(&g1_generator(), &g2_generator())
}

public fun gt_identity(): Element<GT> {
    pairing(&g1_identity(), &g2_generator())
}

public fun gt_neg(e: &Element<GT>): Element<GT> {
    gt_sub(&gt_identity(), e)
}

public fun gt_add(e1: &Element<GT>, e2: &Element<GT>): Element<GT> {
    group_ops::add(GT_TYPE, e1, e2)
}

public fun gt_sub(e1: &Element<GT>, e2: &Element<GT>): Element<GT> {
    group_ops::sub(GT_TYPE, e1, e2)
}

public fun gt_mul(e1: &Element<Scalar>, e2: &Element<GT>): Element<GT> {
    group_ops::mul(GT_TYPE, e1, e2)
}

/// Returns e2 / e1, fails if scalar is zero.
public fun gt_div(e1: &Element<Scalar>, e2: &Element<GT>): Element<GT> {
    group_ops::div(GT_TYPE, e1, e2)
}

/////////////////////
////// Pairing //////

public fun pairing(e1: &Element<G1>, e2: &Element<G2>): Element<GT> {
    group_ops::pairing(G1_TYPE, e1, e2)
}
