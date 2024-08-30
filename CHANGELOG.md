# Changelog

## v2.0.0 - 2024-09-06

### Added

N/A

### Changed

#### on-chain

- Requires `aiken >= 1.1.0`.

- Requires `aiken-lang/stdlib >= 2.0.0` && `aiken-lang/stdlib < 3.0.0`.

- Creating an empty trie is no longer a function `empty()` but a constant `empty`.

#### off-chain

N/A

### Removed

N/A

## v1.1.0 - 2024-07-23

### Added

- Two new functions to the on-chain API:
  - [`root(MerklePatriciaForestry) -> ByteArray`](https://aiken-lang.github.io/merkle-patricia-forestry/aiken/merkle_patricia_forestry.html#root)
  - [`update(self, key, proof, old_value, new_value) -> MerklePatriciaForestry`](https://aiken-lang.github.io/merkle-patricia-forestry/aiken/merkle_patricia_forestry.html#update)

### Changed

N/A

### Removed

N/A

## v1.0.1 - 2024-06-02

### Added

- Initial implementation of _Merkle-Patricia Forestry_, with an on-chain (Aiken) and off-chain (Node.js) backend.

  - Provides a simple on-chain API.
    - **Constructing**
      - [`empty() -> MerklePatriciaForestry`](https://aiken-lang.github.io/merkle-patricia-forestry/aiken/merkle_patricia_forestry.html#empty)
      - [`from_root(root) -> MerklePatriciaForestry`](https://aiken-lang.github.io/merkle-patricia-forestry/aiken/merkle_patricia_forestry.html#from_root)
    - **Modifying**
      - [`insert(self, key, value, proof) -> MerklePatriciaForestry`](https://aiken-lang.github.io/merkle-patricia-forestry/aiken/merkle_patricia_forestry.html#insert)
      - [`delete(self, key, value, proof) -> MerklePatriciaForestry`](https://aiken-lang.github.io/merkle-patricia-forestry/aiken/merkle_patricia_forestry.html#delete)
    - **Inspecting**
      - [`has(self, key, value, proof) -> Bool`](https://aiken-lang.github.io/merkle-patricia-forestry/aiken/merkle_patricia_forestry.html#has)

  - And a companion off-chain backend on top of [level.js](https://leveljs.org/) with an option to run in-memory:
    - **Constructing**
      - [`new Trie(store?: Store): Trie`](https://github.com/aiken-lang/merkle-patricia-forestry/tree/main/off-chain#new-triestore-store-trie)
      - [`Trie.fromList(items: Array<Item>, store?: Store): Promise<Trie>`](https://github.com/aiken-lang/merkle-patricia-forestry/tree/main/off-chain#triefromlistitems-arrayitem-store-store-promisetrie)
      - [`Trie.load(store: Store): Promise<Trie>`](https://github.com/aiken-lang/merkle-patricia-forestry/tree/main/off-chain#trieloadstore-store-promisetrie)
      - [`trie.save(): Promise<(Trie)>`](https://github.com/aiken-lang/merkle-patricia-forestry/tree/main/off-chain#triesave-promisetrie)
    - **Modifying**
      - [`trie.insert(key: string|Buffer, value: string|Buffer) -> Promise<Trie>`](https://github.com/aiken-lang/merkle-patricia-forestry/tree/main/off-chain#trieinsertkey-stringbuffer-value-stringbuffer---promisetrie)
      - [`trie.delete(key: string|Buffer) -> Promise<Trie>`](https://github.com/aiken-lang/merkle-patricia-forestry/tree/main/off-chain#triedeletekey-stringbuffer---promisetrie)
    - **Inspecting**
      - [`trie[inspect.custom]`](https://github.com/aiken-lang/merkle-patricia-forestry/tree/main/off-chain#inspecting)
      - [`trie.fetchChildren(depth?: number = 0): Promise<()>`](https://github.com/aiken-lang/merkle-patricia-forestry/tree/main/off-chain#triefetchchildrendepth-number--0-promise)
      - [`trie.childAt(path: string): Promise<Trie|undefined>`](https://github.com/aiken-lang/merkle-patricia-forestry/tree/main/off-chain#triechildatpath-string-promisetrieundefined)
    - **Proving**
      - [`trie.prove(key: string|Buffer): Promise<Proof>`](https://github.com/aiken-lang/merkle-patricia-forestry/tree/main/off-chain#trieprovekey-stringbuffer-promiseproof)
      - [`proof.verify(includingItem?: bool = true): Buffer`](https://github.com/aiken-lang/merkle-patricia-forestry/tree/main/off-chain#proofverifyincludingitem-bool--true-buffer)
      - [`proof.toJSON(): object`](https://github.com/aiken-lang/merkle-patricia-forestry/tree/main/off-chain#prooftojson-object)
      - [`proof.toCBOR(): Buffer`](https://github.com/aiken-lang/merkle-patricia-forestry/tree/main/off-chain#prooftocbor-buffer)
      - [`proof.toAiken(): string`](https://github.com/aiken-lang/merkle-patricia-forestry/tree/main/off-chain#prooftoaiken-string)

### Changed

N/A

### Removed

N/A
