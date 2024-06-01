//// A Merkle Patricia Forestry (MPF) is a key:value structure which stores
//// elements in a radix trie folowing a key, and where nodes also contains a
//// cryptographic hash digest of the sub-trie or value they hold.
////
//// This library enforces (through hashing) that we use trie of radix 16
//// (hexadecimal alphabet). This means that each level in the trie has up to
//// 16 branches.
////
//// An MPF allows for checking membership, insertion and deletion in the trie
//// using only root hashes and a succinct proofs. They are quite efficient in
//// both cpu and mem units. And they also provide proofs that are a / lot smaller
//// than traditional Merkle Patricia Trie; proofs remain however the / main
//// limiting factor.
////
//// Here's a little table that summarizes the average proof's sizes in bytes
//// given a number of elements.
////
//// We also consider the average memory and CPU execution units for verifying
//// a proof for various sizes. Note that [`insert`](#insert) and
//// [`delete`](#delete) require **two** proofs verifications.
////
//// size | avg proof size | avg proof mem | avg proof cpu |
//// ---: | -------------: | ------------: | ------------: |
////  10² |          250   | 70K           | 28M           |
////  10³ |          350   | 100K          | 42M           |
////  10⁴ |          460   | 130K          | 56M           |
////  10⁵ |          560   | 160K          | 70M           |
////  10⁶ |          670   | 190K          | 84M           |
////  10⁷ |          780   | 220K          | 98M           |
////  10⁸ |          880   | 250K          | 112M          |
////  10⁹ |          990   | 280K          | 126M          |

use aiken/builtin.{blake2b_256, index_bytearray, slice_bytearray}
use aiken/bytearray
use aiken/fuzz.{both, int_between, list_between}

// -----------------------------------------------------------------------------
// ------------------------------------------------------------------- Constants
// -----------------------------------------------------------------------------

/// # of bytes
const blake2b_256_digest_size = 32

/// By convention, the hash of a null tree/trie is the null hash.
///
/// Note that we also cache trees made of empty trees to short-circuit the
/// neighbor sparse-merkle tree calculation.
const null_hash =
  #"0000000000000000000000000000000000000000000000000000000000000000"

/// null_hash_2 = combine(null_hash, null_hash)
const null_hash_2 =
  #"0eb923b0cbd24df54401d998531feead35a47a99f4deed205de4af81120f9761"

/// null_hash_4 = combine(null_hash_2, null_hash_2)
const null_hash_4 =
  #"85c09af929492a871e4fae32d9d5c36e352471cd659bcdb61de08f1722acc3b1"

/// null_hash_8 = combine(null_hash_4, null_hash_4)
const null_hash_8 =
  #"b22df1a126b5ba4e33c16fd6157507610e55ffce20dae7ac44cae168a463612a"

// -----------------------------------------------------------------------------
// ------------------------------------------------------ Merkle Patricia Forest
// -----------------------------------------------------------------------------

/// A Merkle Patricia Forestry, typically constructed from a root hash digest
/// using [`from_root`](#from_root).
///
/// ```aiken
/// let trie =
///   mpf.from_root(
///     #"225a4599b804ba53745538c83bfa699ecf8077201b61484c91171f5910a4a8f9",
///   )
/// ```
pub opaque type MerklePatriciaForestry {
  root: ByteArray,
}

/// Construct a new [MerklePatriciaForestry](#MerklePatriciaForestry) from its
/// root. On-chain, we actually only need the / root
///
/// The root MUST be 32-bytes long. For an empty trie, see [empty](#empty).
pub fn from_root(root: ByteArray) -> MerklePatriciaForestry {
  expect bytearray.length(root) == blake2b_256_digest_size
  MerklePatriciaForestry { root }
}

/// Construct a new empty [MerklePatriciaForestry](#MerklePatriciaForestry).
pub fn empty() -> MerklePatriciaForestry {
  MerklePatriciaForestry { root: null_hash }
}

/// Check whether a [MerklePatriciaForestry](#MerklePatriciaForestry) is empty.
///
/// ```aiken
/// mpf.is_empty(mpf.empty()) == True
/// ```
pub fn is_empty(self: MerklePatriciaForestry) -> Bool {
  self.root == null_hash
}

/// Test whether an element is present in the trie with a specific value. This
/// requires a [Proof](#Proof) of inclusion for the element. The latter can be
/// obtained off-chain from the whole trie containing the element.
///
/// Returns `False` when the element isn't in the tree.
pub fn has(
  self: MerklePatriciaForestry,
  key: ByteArray,
  value: ByteArray,
  proof: Proof,
) -> Bool {
  including(key, value, proof) == self.root
}

/// **fails** when | the [Proof](#Proof) is invalid
/// ---            | ---
///
/// **fails** when | there's already an element in the trie at the given key
/// ---            | ---
///
/// Insert an element in the trie. This requires a [Proof](#Proof) of inclusion
/// for the element. The latter can be obtained off-chain from the whole trie
/// containing the element.
pub fn insert(
  self: MerklePatriciaForestry,
  key: ByteArray,
  value: ByteArray,
  proof: Proof,
) -> MerklePatriciaForestry {
  expect excluding(key, proof) == self.root
  MerklePatriciaForestry { root: including(key, value, proof) }
}

/// **fails** when | the [Proof](#Proof) is invalid
/// ---            | ---
///
/// **fails** when | there's already an element in the trie at the given key
/// ---            | ---
///
/// Remove an element from the trie. This requires a [Proof](#Proof) of
/// inclusion for the element. The latter can be obtained off-chain from the
/// whole trie containing the element.
pub fn delete(
  self: MerklePatriciaForestry,
  key: ByteArray,
  value: ByteArray,
  proof: Proof,
) -> MerklePatriciaForestry {
  expect including(key, value, proof) == self.root
  MerklePatriciaForestry { root: excluding(key, proof) }
}

// -----------------------------------------------------------------------------
// ----------------------------------------------------------------------- Proof
// -----------------------------------------------------------------------------

/// A Proof is a list of [Step](#Step) which is processed from left to right,
/// which corresponds to the neighbor nodes along the _path_ to the element being
/// proved.
///
/// See [merkle-patricia-forestry/off-chain :: Proving](https://github.com/aiken-lang/merkle-patricia-forestry/tree/main/off-chain#proving)
/// for details about generating a proof.
pub type Proof =
  List<ProofStep>

/// We distinguish three kind of proof steps: Branch, Fork and Leaf. Each step
/// contains a `skip` value which corresponds to the length of the common prefix
/// at that particular level.
///
/// The details of each level is documented [in the wiki :: Proof Format](https://github.com/aiken-lang/merkle-patricia-forestry/wiki/Proof-format).
pub type ProofStep {
  Branch { skip: Int, neighbors: ByteArray }
  Fork { skip: Int, neighbor: Neighbor }
  Leaf { skip: Int, key: ByteArray, value: ByteArray }
}

/// A neighbor node used in a proof. See [Proof](#Proof) for details.
pub type Neighbor {
  nibble: Int,
  prefix: ByteArray,
  root: ByteArray,
}

// -----------------------------------------------------------------------------
// ------------------------------------------------------------------- including
// -----------------------------------------------------------------------------

/// Compute the resulting hash digest from a 'Proof' associated with an
/// arbitrary value. If the proof is valid, the result is the root hash of
/// the target trie.
///
/// This can be used to check for membership of an element in a trie.
fn including(key: ByteArray, value: ByteArray, proof: Proof) -> ByteArray {
  do_including(blake2b_256(key), blake2b_256(value), 0, proof)
}

fn do_including(
  path: ByteArray,
  value: ByteArray,
  cursor: Int,
  proof: Proof,
) -> ByteArray {
  when proof is {
    [] -> combine(suffix(path, cursor), value)

    [Branch { skip, neighbors }, ..steps] -> {
      let nextCursor = cursor + 1 + skip
      let root = do_including(path, value, nextCursor, steps)
      do_branch(path, cursor, nextCursor, root, neighbors)
    }

    [Fork { skip, neighbor }, ..steps] -> {
      let nextCursor = cursor + 1 + skip
      let root = do_including(path, value, nextCursor, steps)
      do_fork(path, cursor, nextCursor, root, neighbor)
    }

    [Leaf { skip, key, value: neighborValue }, ..steps] -> {
      let nextCursor = cursor + 1 + skip
      let root = do_including(path, value, nextCursor, steps)

      let neighbor =
        Neighbor {
          prefix: suffix(key, nextCursor),
          nibble: nibble(key, nextCursor - 1),
          root: neighborValue,
        }

      do_fork(path, cursor, nextCursor, root, neighbor)
    }
  }
}

// -----------------------------------------------------------------------------
// ------------------------------------------------------------------- excluding
// -----------------------------------------------------------------------------

/// Similar to [including](#including), but computes the root obtained from walking
/// the proof without including the element.
///
/// So this mainly changes the last step.
fn excluding(key: ByteArray, proof: Proof) -> ByteArray {
  do_excluding(blake2b_256(key), 0, proof)
}

fn do_excluding(path: ByteArray, cursor: Int, proof: Proof) -> ByteArray {
  when proof is {
    [] -> null_hash

    [Branch { skip, neighbors }, ..steps] -> {
      let nextCursor = cursor + 1 + skip
      let root = do_excluding(path, nextCursor, steps)
      do_branch(path, cursor, nextCursor, root, neighbors)
    }

    [Fork { neighbor, .. }] -> {
      let prefix = bytearray.push(neighbor.prefix, neighbor.nibble)
      combine(prefix, neighbor.root)
    }

    [Fork { skip, neighbor }, ..steps] -> {
      let nextCursor = cursor + 1 + skip
      let root = do_excluding(path, nextCursor, steps)
      do_fork(path, cursor, nextCursor, root, neighbor)
    }

    [Leaf { key, value, .. }] -> combine(suffix(key, cursor), value)

    [Leaf { skip, key, value }, ..steps] -> {
      let nextCursor = cursor + 1 + skip
      let root = do_excluding(path, nextCursor, steps)

      let neighbor =
        Neighbor {
          prefix: suffix(key, nextCursor),
          nibble: nibble(key, cursor),
          root: value,
        }

      do_fork(path, cursor, nextCursor, root, neighbor)
    }
  }
}

// -----------------------------------------------------------------------------
// --------------------------------------------------------- do_branch / do_fork
// -----------------------------------------------------------------------------

fn do_branch(
  path: ByteArray,
  cursor: Int,
  nextCursor: Int,
  root: ByteArray,
  neighbors: ByteArray,
) -> ByteArray {
  let branch = nibble(path, nextCursor - 1)

  let prefix = nibbles(path, cursor, nextCursor - 1)

  combine(
    prefix,
    merkle_16(
      branch,
      root,
      slice_bytearray(0, blake2b_256_digest_size, neighbors),
      slice_bytearray(32, blake2b_256_digest_size, neighbors),
      slice_bytearray(64, blake2b_256_digest_size, neighbors),
      slice_bytearray(96, blake2b_256_digest_size, neighbors),
    ),
  )
}

fn do_fork(
  path: ByteArray,
  cursor: Int,
  nextCursor: Int,
  root: ByteArray,
  neighbor: Neighbor,
) -> ByteArray {
  let branch = nibble(path, nextCursor - 1)

  let prefix = nibbles(path, cursor, nextCursor - 1)

  expect branch != neighbor.nibble

  combine(
    prefix,
    sparse_merkle_16(
      branch,
      root,
      neighbor.nibble,
      combine(neighbor.prefix, neighbor.root),
    ),
  )
}

// -----------------------------------------------------------------------------
// --------------------------------------------------------------------- combine
// -----------------------------------------------------------------------------

fn combine(left: ByteArray, right: ByteArray) -> ByteArray {
  blake2b_256(bytearray.concat(left, right))
}

test combine_null_hash() {
  and {
    combine(null_hash, null_hash) == null_hash_2,
    combine(null_hash_2, null_hash_2) == null_hash_4,
    combine(null_hash_4, null_hash_4) == null_hash_8,
  }
}

// -----------------------------------------------------------------------------
// ------------------------------------------------------------------- merkle_xx
// -----------------------------------------------------------------------------

fn merkle_16(
  branch: Int,
  root: ByteArray,
  neighbor_8: ByteArray,
  neighbor_4: ByteArray,
  neighbor_2: ByteArray,
  neighbor_1: ByteArray,
) -> ByteArray {
  if branch <= 7 {
    combine(
      merkle_8(branch, root, neighbor_4, neighbor_2, neighbor_1),
      neighbor_8,
    )
  } else {
    combine(
      neighbor_8,
      merkle_8(branch - 8, root, neighbor_4, neighbor_2, neighbor_1),
    )
  }
}

fn merkle_8(
  branch: Int,
  root: ByteArray,
  neighbor_4: ByteArray,
  neighbor_2: ByteArray,
  neighbor_1: ByteArray,
) -> ByteArray {
  if branch <= 3 {
    combine(merkle_4(branch, root, neighbor_2, neighbor_1), neighbor_4)
  } else {
    combine(neighbor_4, merkle_4(branch - 4, root, neighbor_2, neighbor_1))
  }
}

fn merkle_4(
  branch: Int,
  root: ByteArray,
  neighbor_2: ByteArray,
  neighbor_1: ByteArray,
) -> ByteArray {
  if branch <= 1 {
    combine(merkle_2(branch, root, neighbor_1), neighbor_2)
  } else {
    combine(neighbor_2, merkle_2(branch - 2, root, neighbor_1))
  }
}

fn merkle_2(branch: Int, root: ByteArray, neighbor: ByteArray) -> ByteArray {
  if branch <= 0 {
    combine(root, neighbor)
  } else {
    combine(neighbor, root)
  }
}

test prop_merkle_4(nodes via list_between(fuzz.bytearray(), 4, 4)) {
  expect [a, b, c, d] = nodes

  let root = combine(combine(a, b), combine(c, d))

  and {
    merkle_4(0, a, combine(c, d), b) == root,
    merkle_4(1, b, combine(c, d), a) == root,
    merkle_4(2, c, combine(a, b), d) == root,
    merkle_4(3, d, combine(a, b), c) == root,
  }
}

// -----------------------------------------------------------------------------
// ------------------------------------------------------------ sparse_merkle_xx
// -----------------------------------------------------------------------------

fn sparse_merkle_16(
  me: Int,
  meHash: ByteArray,
  neighbor: Int,
  neighborHash: ByteArray,
) -> ByteArray {
  if me < 8 {
    if neighbor < 8 {
      combine(sparse_merkle_8(me, meHash, neighbor, neighborHash), null_hash_8)
    } else {
      combine(
        merkle_8(me, meHash, null_hash_4, null_hash_2, null_hash),
        merkle_8(
          neighbor - 8,
          neighborHash,
          null_hash_4,
          null_hash_2,
          null_hash,
        ),
      )
    }
  } else {
    if neighbor >= 8 {
      combine(
        null_hash_8,
        sparse_merkle_8(me - 8, meHash, neighbor - 8, neighborHash),
      )
    } else {
      combine(
        merkle_8(neighbor, neighborHash, null_hash_4, null_hash_2, null_hash),
        merkle_8(me - 8, meHash, null_hash_4, null_hash_2, null_hash),
      )
    }
  }
}

fn sparse_merkle_8(
  me: Int,
  meHash: ByteArray,
  neighbor: Int,
  neighborHash: ByteArray,
) -> ByteArray {
  if me < 4 {
    if neighbor < 4 {
      combine(sparse_merkle_4(me, meHash, neighbor, neighborHash), null_hash_4)
    } else {
      combine(
        merkle_4(me, meHash, null_hash_2, null_hash),
        merkle_4(neighbor - 4, neighborHash, null_hash_2, null_hash),
      )
    }
  } else {
    if neighbor >= 4 {
      combine(
        null_hash_4,
        sparse_merkle_4(me - 4, meHash, neighbor - 4, neighborHash),
      )
    } else {
      combine(
        merkle_4(neighbor, neighborHash, null_hash_2, null_hash),
        merkle_4(me - 4, meHash, null_hash_2, null_hash),
      )
    }
  }
}

fn sparse_merkle_4(
  me: Int,
  meHash: ByteArray,
  neighbor: Int,
  neighborHash: ByteArray,
) -> ByteArray {
  if me < 2 {
    if neighbor < 2 {
      combine(merkle_2(me, meHash, neighborHash), null_hash_2)
    } else {
      combine(
        merkle_2(me, meHash, null_hash),
        merkle_2(neighbor - 2, neighborHash, null_hash),
      )
    }
  } else {
    if neighbor >= 2 {
      combine(null_hash_2, merkle_2(me - 2, meHash, neighborHash))
    } else {
      combine(
        merkle_2(neighbor, neighborHash, null_hash),
        merkle_2(me - 2, meHash, null_hash),
      )
    }
  }
}

// -----------------------------------------------------------------------------
// ---------------------------------------------------------------------- suffix
// -----------------------------------------------------------------------------

fn suffix(path, cursor) {
  if cursor % 2 == 0 {
    bytearray.drop(path, cursor / 2)
      |> bytearray.push(0xff)
  } else {
    bytearray.drop(path, ( cursor + 1 ) / 2)
      |> bytearray.push(nibble(path, cursor))
      |> bytearray.push(0)
  }
}

test examples_suffix() {
  and {
    suffix(#"abcd456789", 0) == #"ffabcd456789",
    suffix(#"abcd456789", 1) == #"000bcd456789",
    suffix(#"abcd456789", 2) == #"ffcd456789",
    suffix(#"abcd456789", 4) == #"ff456789",
    suffix(#"abcd456789", 5) == #"00056789",
    suffix(#"abcd456789", 10) == #"ff",
  }
}

test prop_suffix_prefix(params via both(fuzz.bytearray(), int_between(0, 31))) {
  let str = suffix(params.1st, params.2nd)
  let head = index_bytearray(str, 0)

  if head == 0 {
    index_bytearray(str, 1) < 16
  } else {
    head == 255
  }
}

// -----------------------------------------------------------------------------
// --------------------------------------------------------------------- nibbles
// -----------------------------------------------------------------------------

/// Computes nibbles for a given branch node, from the start and end
/// location of two position in a path.
fn nibbles(path: ByteArray, start: Int, end: Int) -> ByteArray {
  if start >= end {
    #[]
  } else {
    bytearray.push(nibbles(path, start + 1, end), nibble(path, start))
  }
}

test examples_nibbles() {
  and {
    nibbles(#"0123456789", 2, 2) == #[],
    nibbles(#"0123456789", 2, 3) == #[2],
    nibbles(#"0123456789", 4, 8) == #[4, 5, 6, 7],
    nibbles(#"0123456789", 3, 6) == #[3, 4, 5],
    nibbles(#"0123456789", 1, 7) == #[1, 2, 3, 4, 5, 6],
  }
}

// -----------------------------------------------------------------------------
// ---------------------------------------------------------------------- nibble
// -----------------------------------------------------------------------------

fn nibble(self: ByteArray, index: Int) -> Int {
  if index % 2 == 0 {
    index_bytearray(self, index / 2) / 16
  } else {
    index_bytearray(self, index / 2) % 16
  }
}

test examples_nibble() {
  and {
    nibble(#"ab", 0) == 10,
    nibble(#"ab", 1) == 11,
  }
}

test prop_nearby_nibble(params via both(fuzz.bytearray(), int_between(0, 31))) {
  let (bytes, index) = params

  let msb = nibble(bytes, index * 2)
  let lsb = nibble(bytes, index * 2 + 1)

  msb * 16 + lsb == index_bytearray(bytes, index)
}

test prop_nibble_size(params via both(fuzz.bytearray(), int_between(0, 63))) {
  let (bytes, index) = params
  let digit = nibble(bytes, index)
  and {
    digit >= 0,
    digit <= 15,
  }
}
