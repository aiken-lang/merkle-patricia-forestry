# Merkle Patricia Forestry

This package provides an Aiken library for working with an authenticated key/value store: a.k.a [Merkle Patricia Forestry](../README.md). It comes with a [companion off-chain package](../off-chain) for generating proofs and actually maintaining the raw data-structure since on-chain, we only ever deal with hashes.

## Installation

```
aiken add aiken-lang/merkle-patricia-forestry --version 1.0.0
```

## Documentation

The documentation is generated from `aiken docs` and [available here](https://aiken-lang.github.io/merkle-patricia-forestry/aiken/merkle_patricia_forestry.html).

### Examples

A non-trivial example of a [fruit map](https://github.com/aiken-lang/merkle-patricia-forestry/blob/main/on-chain/lib/aiken/merkle-patricia-forestry.examples.ak#L90) is available in the source. It illustrate how to use the various `from_root`, `has`, `insert` and `delete` primitives.

The proofs themselves have been generated from a trie built with the [off-chain package](../off-chain). While theoretically possible, the Aiken library doesn't contain any primitives for constructing tries _on-chain_, even for debugging.
