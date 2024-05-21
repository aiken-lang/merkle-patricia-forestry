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
  skip: Int,
  neighbors: ByteArray,
  lookup: ByteArray,
}

/// Compute the resulting hash digest from a 'Proof' associated with an
/// arbitrary value. If the proof is valid, the result is the root hash of
/// the target tree.
///
/// This can be used to check for membership of an element in a tree.
pub fn including(value: ByteArray, proof: Proof) -> ByteArray {
  when proof is {
    [] -> blake2b_256(value)
    [step, ..steps] ->
      walk(
        blake2b_256(value),
        0,
        step,
        steps,
        fn(path, cursor, step) {
          // NOTE
          // The `[step]` argument given is only to bypass the empty case check
          // on 'do_walk', and ensure we execute the logic for that particular step.
          // It is effectively ignored just below with `_step` as a termination case.
          walk(path, cursor, step, [step], fn(path, _cursor, _st) { path })
        },
      )
  }
}

/// Similar to [including](#including), but computes the root obtained from walking
/// the proof without including the element.
///
/// So this mainly changes the last step.
fn excluding(value: ByteArray, proof: Proof) -> ByteArray {
  when proof is {
    [] -> null_hash
    [step, ..steps] ->
      walk(
        blake2b_256(value),
        0,
        step,
        steps,
        fn(path, cursor, step) {
          // Now, when the last branch node had only two elements (i.e. neighbors.length === 1),
          // we must treat this node as a leaf instead and take its hash directly.
          //
          // Otherwise, we can simply perform a normal walk considering an
          // empty root for out element. The extra [step] is only there to bypass the first check
          // in do_walk.
          if bytearray.length(step.neighbors) == blake2b_256_digest_size {
            step.neighbors
          } else {
            walk(path, cursor, step, [step], fn(_path, _cursor, _st) { "" })
          }
        },
      )
  }
}

fn walk(
  path: ByteArray,
  cursor: Int,
  step: ProofStep,
  steps: List<ProofStep>,
  on_last_step: fn(ByteArray, Int, ProofStep) -> ByteArray,
) -> ByteArray {
  when steps is {
    [] -> on_last_step(path, cursor, step)

    [nextStep, ..nextSteps] -> {
      let nextCursor = cursor + 1 + step.skip

      let root = walk(path, nextCursor, nextStep, nextSteps, on_last_step)

      let branch = nibble(path, cursor)

      let node =
        // The lookup table contains only 15 elements (the neighbors) that are
        // 0-based index. So in case where our element is at the end:
        //
        // (1) There's no need to lookup, so we can shortcircuit.
        // (2) And more importantly, we *cannot* lookup without causing
        //     an out-of-bound index access.
        if branch >= 15 {
          prefix(path, cursor + 1, nextCursor)
            |> bytearray.concat(step.neighbors)
            |> bytearray.concat(root)
        } else {
          let pivot =
            index_bytearray(step.lookup, branch) * blake2b_256_digest_size

          prefix(path, cursor + 1, nextCursor)
            |> bytearray.concat(bytearray.take(step.neighbors, pivot))
            |> bytearray.concat(root)
            |> bytearray.concat(bytearray.drop(step.neighbors, pivot))
        }

      blake2b_256(node)
    }
  }
}

test example_leaf() {
  including("foo", []) == #"b8fe9f7f6255a6fa08f668ab632a8d081ad87983c77cd274e48ce450f0b349fd"
}

test example_simple_tree() {
  // ╔═══════════════════════════════════════════════════════════════════╗
  // ║ #6d9a495a9352061d331fd6039e97297aec9591b291b61f4d46d28c6a9b302577 ║
  // ╚═══════════════════════════════════════════════════════════════════╝
  //  ┌─ 84418..[55 digits]..e71d → bar
  //  └─ b8fe9..[55 digits]..49fd → foo
  let root = #"6d9a495a9352061d331fd6039e97297aec9591b291b61f4d46d28c6a9b302577"
  let foo = #"b8fe9f7f6255a6fa08f668ab632a8d081ad87983c77cd274e48ce450f0b349fd"
  let bar = #"844181b39a1b15b417243e6231381b447a3f8b44aa15fbeb845c5d716696e71d"

  let proofFoo =
    [
      ProofStep {
        skip: 0,
        neighbors: bar,
        lookup: #"000000000000000000010101010101",
      },
    ]

  let proofBar =
    [
      ProofStep {
        skip: 0,
        neighbors: foo,
        lookup: #"000000000000000000000001010101",
      },
    ]

  and {
    including("foo", proofFoo) == root,
    excluding("foo", proofFoo) == bar,
    including("bar", proofBar) == root,
    excluding("bar", proofBar) == foo,
  }
}

/// Computes the prefix for a given branch node, from the start and end
/// location of two nibbles.
fn prefix(path: ByteArray, start: Int, end: Int) -> ByteArray {
  if start >= end {
    ""
  } else {
    bytearray.push(prefix(path, start + 1, end), nibble(path, start))
  }
}

test examples_prefix() {
  and {
    prefix(#"0123456789", 2, 2) == #[],
    prefix(#"0123456789", 2, 3) == #[2],
    prefix(#"0123456789", 4, 8) == #[4, 5, 6, 7],
  }
}

fn nibble(self: ByteArray, index: Int) -> Int {
  if index % 2 == 0 {
    index_bytearray(self, index / 2) / 16
  } else {
    index_bytearray(self, index / 2) % 16
  }
}

test examples_nibbles() {
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
