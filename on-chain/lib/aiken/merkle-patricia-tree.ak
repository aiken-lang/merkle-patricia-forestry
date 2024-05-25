use aiken/builtin.{blake2b_256, index_bytearray, slice_bytearray}
use aiken/bytearray
use aiken/fuzz.{both, int_between}

// -----------------------------------------------------------------------------
// ------------------------------------------------------------------- Constants
// -----------------------------------------------------------------------------

/// # of bytes
const blake2b_256_digest_size = 32

/// By convention, the hash of a null tree is the null hash.
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

/// A Merkle Patricia Trie Forest (MP) is a structure which stores elements in a
/// radix-trie, where nodes also contains a cryptographic hash digest of the
/// subtree they hold.
///
/// This library assumes we use trie of radix 16 (hexadecimal alphabet). This
/// means that each level in the tree has up to 16 branches.
///
/// Such MPTs allow for checking membership, insertion and deletion in the tree
/// using only root hashes and a proof of inclusion. They are extremely efficient in
/// both cpu and mem units, but as a counterpart, proofs can be quite large.
///
/// Here's a little table that summarizes the average and maximum size of a
/// proof given / a number of elements, with an _overwhelming probability_.
///
/// size | average proof size |
/// ---: | -----------------: |
///  10² |                    |
///  10³ |                    |
///  10⁴ |                    |
///  10⁵ |                    |
///  10⁶ |                    |
///  10⁷ |                    |
///  10⁸ |                    |
///  10⁹ |                    |
pub opaque type MerklePatriciaTree {
  root: ByteArray,
}

/// Construct a new "tree" from its root. On-chain, we actually only need the
/// root!
///
/// The root MUST be 32-bytes long. For an empty tree, see [empty](#empty).
pub fn from_root(root: ByteArray) -> MerklePatriciaTree {
  expect bytearray.length(root) == blake2b_256_digest_size
  MerklePatriciaTree { root }
}

/// Construct a new empty tree.
pub fn empty() -> MerklePatriciaTree {
  MerklePatriciaTree { root: null_hash }
}

/// Check whether a tree is empty.
///
/// ```aiken
/// mpt.is_empty(mpt.empty()) == True
/// ```
pub fn is_empty(self: MerklePatriciaTree) -> Bool {
  self.root == null_hash
}

/// Test whether an element is present in the tree. This requires a proof of inclusion
/// for the element. The latter can be obtained off-chain from the whole tree
/// containing the element.
pub fn has(self: MerklePatriciaTree, value: ByteArray, proof: Proof) -> Bool {
  including(value, proof) == self.root
}

/// Insert an element in the tree. This requires a proof of inclusion for the element.
/// The latter can be obtained off-chain from the whole tree containing the element.
pub fn insert(
  self: MerklePatriciaTree,
  value: ByteArray,
  proof: Proof,
) -> MerklePatriciaTree {
  expect excluding(value, proof) == self.root
  MerklePatriciaTree { root: including(value, proof) }
}

/// Remove an element from the tree. This requires a proof of inclusion for the element.
/// The latter can be obtained off-chain from the whole tree containing the element.
pub fn delete(
  self: MerklePatriciaTree,
  value: ByteArray,
  proof: Proof,
) -> MerklePatriciaTree {
  expect including(value, proof) == self.root
  MerklePatriciaTree { root: excluding(value, proof) }
}

// -----------------------------------------------------------------------------
// ----------------------------------------------------------------------- Proof
// -----------------------------------------------------------------------------

pub type Proof =
  List<ProofStep>

pub type ProofStep {
  Branch { skip: Int, neighbors: ByteArray }
  Fork { skip: Int, neighbor: Neighbor }
  Leaf { skip: Int, neighbor: ByteArray }
}

pub type Neighbor {
  prefix: ByteArray,
  value: ByteArray,
  nibble: Int,
}

// -----------------------------------------------------------------------------
// ------------------------------------------------------------------- including
// -----------------------------------------------------------------------------

/// Compute the resulting hash digest from a 'Proof' associated with an
/// arbitrary value. If the proof is valid, the result is the root hash of
/// the target tree.
///
/// This can be used to check for membership of an element in a tree.
fn including(value: ByteArray, proof: Proof) -> ByteArray {
  do_including(blake2b_256(value), 0, proof)
}

fn do_including(path: ByteArray, cursor: Int, proof: Proof) -> ByteArray {
  when proof is {
    [] -> combine(suffix(path, cursor), path)

    [Branch { skip, neighbors }, ..steps] -> {
      let nextCursor = cursor + 1 + skip
      let root = do_including(path, nextCursor, steps)
      do_branch(path, cursor, nextCursor, root, neighbors)
    }

    [Fork { skip, neighbor }, ..steps] -> {
      let nextCursor = cursor + 1 + skip
      let root = do_including(path, nextCursor, steps)
      do_fork(path, cursor, nextCursor, root, neighbor)
    }

    [Leaf { skip, neighbor }, ..steps] -> {
      let nextCursor = cursor + 1 + skip
      let root = do_including(path, nextCursor, steps)
      let neighbor =
        Neighbor {
          prefix: suffix(neighbor, nextCursor),
          nibble: nibble(neighbor, nextCursor - 1),
          value: neighbor,
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
fn excluding(value: ByteArray, proof: Proof) -> ByteArray {
  do_excluding(blake2b_256(value), 0, proof)
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
      combine(prefix, neighbor.value)
    }

    [Fork { skip, neighbor }, ..steps] -> {
      let nextCursor = cursor + 1 + skip
      let root = do_excluding(path, nextCursor, steps)
      do_fork(path, cursor, nextCursor, root, neighbor)
    }

    [Leaf { neighbor, .. }] -> combine(suffix(neighbor, cursor), neighbor)

    [Leaf { skip, neighbor }, ..steps] -> {
      let nextCursor = cursor + 1 + skip
      let root = do_excluding(path, nextCursor, steps)
      let neighbor =
        Neighbor {
          prefix: suffix(neighbor, nextCursor),
          nibble: nibble(neighbor, cursor),
          value: neighbor,
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
      combine(neighbor.prefix, neighbor.value),
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
  } else {
    nibble(path, cursor)
      |> bytearray.push(bytearray.drop(path, ( cursor + 1 ) / 2), _)
  }
}

test examples_suffix() {
  and {
    suffix(#"abcd456789", 0) == #"abcd456789",
    suffix(#"abcd456789", 1) == #"0bcd456789",
    suffix(#"abcd456789", 2) == #"cd456789",
    suffix(#"abcd456789", 4) == #"456789",
    suffix(#"abcd456789", 5) == #"056789",
    suffix(#"abcd456789", 10) == #"",
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
