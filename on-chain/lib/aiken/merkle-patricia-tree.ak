use aiken/builtin.{blake2b_256, index_bytearray}
use aiken/bytearray
use aiken/fuzz.{both, int_between}

/// # of bytes
const blake2b_256_digest_size = 32

/// By convention, the hash of a null tree is the null hash
const null_hash =
  #"0000000000000000000000000000000000000000000000000000000000000000"

/// A Merkle Patricia Tree (MPT) is a structure which stores elements in a
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
/// size | avg proof size | max proof size
/// ---: | -------------: | -------------:
///  10² |           1569 |           2970
///  10³ |           2299 |           4455
///  10⁴ |           3140 |           5445
///  10⁵ |           4087 |           6930
///  10⁶ |           4793 |           7920
///  10⁷ |           5656 |           9405
///  10⁸ |           6591 |          10395
///  10⁹ |           7302 |          11880
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

pub type Proof =
  List<ProofStep>

pub type ProofStep {
  Branch { skip: Int, neighbors: ByteArray, mask: ByteArray }
  Fork { skip: Int, neighbor: Neighbor }
  Leaf { skip: Int, neighbor: ByteArray }
}

pub type Neighbor {
  prefix: ByteArray,
  value: ByteArray,
  nibble: Int,
}

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
    [] -> suffix(path, cursor) |> bytearray.concat(path) |> blake2b_256

    [Branch { skip, neighbors, mask }, ..steps] -> {
      let nextCursor = cursor + 1 + skip
      let root = do_including(path, nextCursor, steps)
      do_branch(path, cursor, nextCursor, root, neighbors, mask)
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

/// Similar to [including](#including), but computes the root obtained from walking
/// the proof without including the element.
///
/// So this mainly changes the last step.
fn excluding(value: ByteArray, proof: Proof) -> ByteArray {
  when proof is {
    [] -> null_hash
    _ -> do_excluding(blake2b_256(value), 0, proof)
  }
}

fn do_excluding(path: ByteArray, cursor: Int, proof: Proof) -> ByteArray {
  when proof is {
    [] -> ""

    [Branch { skip, neighbors, mask }, ..steps] -> {
      let nextCursor = cursor + 1 + skip
      let root = do_excluding(path, nextCursor, steps)
      do_branch(path, cursor, nextCursor, root, neighbors, mask)
    }

    [Fork { neighbor, .. }] -> {
      let prefix = bytearray.push(neighbor.prefix, neighbor.nibble)
      blake2b_256(bytearray.concat(prefix, neighbor.value))
    }

    [Fork { skip, neighbor }, ..steps] -> {
      let nextCursor = cursor + 1 + skip
      let root = do_excluding(path, nextCursor, steps)
      do_fork(path, cursor, nextCursor, root, neighbor)
    }

    [Leaf { neighbor, .. }] ->
      suffix(neighbor, cursor)
        |> bytearray.concat(neighbor)
        |> blake2b_256

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

fn do_branch(
  path: ByteArray,
  cursor: Int,
  nextCursor: Int,
  root: ByteArray,
  neighbors: ByteArray,
  mask: ByteArray,
) -> ByteArray {
  let branch = nibble(path, nextCursor - 1)

  let prefix = nibbles(path, cursor, nextCursor - 1)

  let value =
    blake2b_256(
      if branch == 15 {
        bytearray.concat(neighbors, root)
      } else {
        let pivot = index_bytearray(mask, branch) * blake2b_256_digest_size
        bytearray.take(neighbors, pivot)
          |> bytearray.concat(root)
          |> bytearray.concat(bytearray.drop(neighbors, pivot))
      },
    )

  blake2b_256(bytearray.concat(prefix, value))
}

fn do_fork(
  path: ByteArray,
  cursor: Int,
  nextCursor: Int,
  root: ByteArray,
  neighbor: Neighbor,
) -> ByteArray {
  let neighbors =
    neighbor.prefix
      |> bytearray.concat(neighbor.value)
      |> blake2b_256

  let branch = nibble(path, nextCursor - 1)

  let prefix = nibbles(path, cursor, nextCursor - 1)

  expect branch != neighbor.nibble

  let value =
    blake2b_256(
      if branch < neighbor.nibble {
        bytearray.concat(root, neighbors)
      } else {
        bytearray.concat(neighbors, root)
      },
    )

  blake2b_256(bytearray.concat(prefix, value))
}

test example_simple_tree() {
  // ╔═══════════════════════════════════════════════════════════════════╗
  // ║ #9929a647ecd24a3080d807d7deffda4b14a48c100dd518d037885e259ae37799 ║
  // ╚═══════════════════════════════════════════════════════════════════╝
  //  ┌─ 84418..[55 digits]..e71d #80980aea9d27 → bar
  //  └─ b8fe9..[55 digits]..49fd #9cadc73321de → foo
  let root = #"9929a647ecd24a3080d807d7deffda4b14a48c100dd518d037885e259ae37799"

  let bar = #"844181b39a1b15b417243e6231381b447a3f8b44aa15fbeb845c5d716696e71d"

  let foo = #"b8fe9f7f6255a6fa08f668ab632a8d081ad87983c77cd274e48ce450f0b349fd"

  let proofBar =
    [Leaf { skip: 0, neighbor: foo }]

  let proofFoo =
    [Leaf { skip: 0, neighbor: bar }]

  and {
    including("foo", proofFoo) == root,
    excluding("foo", proofFoo) == blake2b_256(bytearray.concat(bar, bar)),
    including("bar", proofBar) == root,
    excluding("bar", proofBar) == blake2b_256(bytearray.concat(foo, foo)),
  }
}

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
