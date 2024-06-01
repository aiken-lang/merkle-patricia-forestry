<div align="center">

  <h1 align="center">Merkle Patricia Forestry</h1>
  <img alt="Merkle Patricia Forestry" src=".github/logo.png" height="250">
  <p align="center" style="border-bottom: none">A set of (on-chain & off-chain) libraries for working with <strong>Merkle Patricia Tries</strong> on Cardano.</p>

  <hr/>

[![Licence](https://img.shields.io/github/license/aiken-lang/merkle-patricia-forestry?style=for-the-badge)](https://github.com/aiken-lang/merkle-patricia-forestry/blob/main/LICENSE)
[![Continuous Integration](https://img.shields.io/github/actions/workflow/status/aiken-lang/merkle-patricia-forestry/continuous-integration.yml?style=for-the-badge&label=continuous%20integration)](https://github.com/aiken-lang/merkle-patricia-forestry/actions/workflows/continuous-integration.yml)
[![NPM](https://img.shields.io/npm/v/%40aiken-lang%2Fmerkle-patricia-forestry?style=for-the-badge)](https://www.npmjs.com/package/@aiken-lang/merkle-patricia-forestry)

  <hr/>
</div>

## Overview

A Merkle Patricia Trie is a persistent & authenticated data-structure to map between arbitrary keys and values. It's like a hashmap on steroids which isn't temperable with. The item are represented in a space-optimized trie (a.k.a prefix tree) of radix 16. The path to values in the trie is given by the hash digest of their keys.

The use-cases are numerous such as maintaining large on-chain registries (e.g. domains), or providing unreasonably large oracled datasets of intrinsic data (e.g. a map of delegators/delegatee) or extrinsic data (e.g. GitHub data pertaining to an ecosystem of projects). It's also perfectly suited for long-running datasets which grow at a _slow_ rate (e.g. another blockchain).

### Features

Using only a root hash digest (32 bytes) and a succinct proof (<1KB), Merkle Patricia Tries provides rapid:

- [x] membership
- [x] insertion
- [x] deletion

of any key/value item in a large (billions) store.

## Getting Started

### Off-chain (JavaScript / Node.js)

```bash
yarn add @aiken-lang/merkle-patricia-forestry
```

See [off-chain](./off-chain) for usage.

### On-chain (Aiken)

```bash
aiken use aiken-lang/merkle-patricia-forestry --version 1.0.0
```

See [on-chain](./on-chain) for usage.

## Performances

This library implements few optimizations. We borrow ideas from the [Ethereum's Modified Merkle Patricia Trie (MPT)](https://ethereum.org/en/developers/docs/data-structures-and-encoding/patricia-merkle-trie/) and also introduce a novel approach for organizing nodes as tiny [Sparse Merkle Trees](https://eprint.iacr.org/2016/683.pdf) that result in much smaller proof sizes, and gives the name to the structure: Merkle Patricia Forestry. This optimization and overall approach are covered in more details [in the wiki](https://github.com/aiken-lang/merkle-patricia-forestry/wiki/Technical-analysis).

While this optimization sacrifices some memory and cpu execution units in favor of smaller proof sizes, the library ends up with a good trade-off overall. The table below summarizes the proof size, memory units and cpu units for various sizes of tries. Note that the numbers in the table correspond to _one proof verification_ (e.g. membership). Insertion and deletion in the trie both require _two proof verifications_; so double the numbers!

trie size | avg proof size (bytes) | avg proof mem units | avg proof cpu units |
---:      | -------------:         | ------------:       | ------------:       |
 10²      | 250                    | 70K                 | 28M                 |
 10³      | 350                    | 100K                | 42M                 |
 10⁴      | 460                    | 130K                | 56M                 |
 10⁵      | 560                    | 160K                | 70M                 |
 10⁶      | 670                    | 190K                | 84M                 |
 10⁷      | 780                    | 220K                | 98M                 |
 10⁸      | 880                    | 250K                | 112M                |
 10⁹      | 990                    | 280K                | 126M                |

 > [!NOTE]
 >
 > On current mainnet, 140K mem units and 100M cpu units corresponds respectively to 1% of the maximum transaction mem and cpu budgets.
