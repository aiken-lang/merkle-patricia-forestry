//// @hidden
////
//// This module contains internal functions used by the library. They are only
//// exposed for internal testing and module splitting.

use aiken/merkle_patricia_forestry/helpers.{combine}

/// By convention, the hash of a null tree/trie is the null hash.
///
/// Note that we also cache trees made of empty trees to short-circuit the
/// neighbor sparse-merkle tree calculation.
pub const null_hash =
  #"0000000000000000000000000000000000000000000000000000000000000000"

/// null_hash_2 = combine(null_hash, null_hash)
pub const null_hash_2 = combine(null_hash, null_hash)

/// null_hash_4 = combine(null_hash_2, null_hash_2)
pub const null_hash_4 = combine(null_hash_2, null_hash_2)

/// null_hash_8 = combine(null_hash_4, null_hash_4)
pub const null_hash_8 = combine(null_hash_4, null_hash_4)

// -----------------------------------------------------------------------------
// ------------------------------------------------------------------- merkle_xx
// -----------------------------------------------------------------------------

pub fn merkle_16(
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

pub fn merkle_8(
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

pub fn merkle_4(
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

pub fn merkle_2(branch: Int, root: ByteArray, neighbor: ByteArray) -> ByteArray {
  if branch <= 0 {
    combine(root, neighbor)
  } else {
    combine(neighbor, root)
  }
}

// -----------------------------------------------------------------------------
// ------------------------------------------------------------ sparse_merkle_xx
// -----------------------------------------------------------------------------

pub fn sparse_merkle_16(
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

pub fn sparse_merkle_8(
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

pub fn sparse_merkle_4(
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
