use aiken/fuzz
use aiken/list
use aiken/merkle_patricia_tree.{
  Branch, Fork, Leaf, MerklePatriciaTree, Neighbor, Proof, ProofStep,
} as mpt

/// An example tree made from a list of fruits.
///
/// ╔═══════════════════════════════════════════════════════════════════╗
/// ║ #8a66b5d3cde7b9fb5370b9fcfcd0acd12a045423ecff85b439738b6a0796d9b7 ║
/// ╚═══════════════════════════════════════════════════════════════════╝
///  ┌─ 066d2..[55 digits]..c160 #f25d1f3e731b → cranberry (0)
///  ├─ 138b #4e814491dc50
///  │  ├─ 407b7..[51 digits]..c445 #919e613fe7b9 → fig (0)
///  │  └─ c45c2..[51 digits]..769a #48ad7766c6f8 → orange (36703)
///  ├─ 3 #a5631e5347a6
///  │  ├─ 378b5..[54 digits]..d05e #e9eca31fe449 → blackberry (0)
///  │  └─ f6cea..[54 digits]..9059 #4932e8645de3 → grapefruit (0)
///  ├─ 45708..[55 digits]..d238 #ff0edb5bcd46 → strawberry (0)
///  ├─ 55 #7ff262d84793
///  │  ├─ 258d0..[53 digits]..5fd1 #723a329d15c8 → pear (0)
///  │  └─ d5551..[53 digits]..719c #9f1649f013cf → banana (328)
///  ├─ 6 #d6f002e80af7
///  │  ├─ 29347..[54 digits]..996e #5ff4152c6c64 → plum (0)
///  │  ├─ 7642e..[54 digits]..e791 #d984adaf73f7 → guava (0)
///  │  ├─ a9150..[54 digits]..f64e #e124d5f9f4b6 → cherry (0)
///  │  └─ f4ea6..[54 digits]..473f #01a804893a0a → lime (0)
///  ├─ 7cf7b..[55 digits]..eb70 #6f90ba97b215 → apple (0)
///  ├─ 993e2..[55 digits]..b3af #a87398cb4efe → mango (0)
///  ├─ a #f622b17984c8
///  │  ├─ 120d7..[54 digits]..5b19 #d823212af2c8 → pineapple (0)
///  │  ├─ 454a2..[54 digits]..6a37 #fd19d19f2f77 → durian (0)
///  │  ├─ 8bf57..[54 digits]..2fca #c7d47f4ec10a → papaya (0)
///  │  ├─ 909ba..[54 digits]..1e87 #386409826e4a → apricot (0)
///  │  ├─ af5cb..[54 digits]..15c6 #064a8065a738 → kumquat (0)
///  │  └─ f7cd6..[54 digits]..b859 #8f69234c7851 → coconut (0)
///  ├─ b #58fd96cee52e
///  │  ├─ a830d..[54 digits]..da75 #4663aa5b8efe → raspberry (0)
///  │  └─ d0f99..[54 digits]..4595 #dc420faa3237 → yuzu (0)
///  ├─ c8553..[55 digits]..aad3 #5361d160bd0f → peach (0)
///  ├─ e #51255842cc98
///  │  ├─ 0d9ff..[54 digits]..e35d #50e1bef1f340 → kiwi (0)
///  │  └─ 385 #635706e95792
///  │     ├─ 22318..[51 digits]..7814 #c9002066f807 → lemon (37694)
///  │     └─ 64f70..[51 digits]..3c0b #7bdba6df08a5 → grape (110606)
///  └─ f #27d1f4677013
///     ├─ 6 #7bbac624e21f
///     │  ├─ 74 #2e2cf893f8cd
///     │  │  ├─ 60e1a..[51 digits]..d432 #4ee055982ee3 → passionfruit (0)
///     │  │  └─ b9b0c..[51 digits]..5b98 #1d16215a4fb8 → blueberry (92383)
///     │  └─ d8c90..[53 digits]..df1a #a54def540220 → pomegranate (113)
///     └─ 77af1..[54 digits]..ce06 #415dcee4a96c → watermelon (20)
///
fn tree() -> MerklePatriciaTree {
  mpt.from_root(
    #"8a66b5d3cde7b9fb5370b9fcfcd0acd12a045423ecff85b439738b6a0796d9b7",
  )
}

test example_insert_tmp() {
  mpt.insert(tree_without_apple(), "apple (0)", proof_apple()) == tree()
}

test example_has() {
  and {
    mpt.has(tree(), "apple (0)", proof_apple()),
    mpt.has(tree(), "apricot (0)", proof_apricot()),
    mpt.has(tree(), "banana (328)", proof_banana()),
    mpt.has(tree(), "blackberry (0)", proof_blackberry()),
    mpt.has(tree(), "blueberry (92383)", proof_blueberry()),
    mpt.has(tree(), "cherry (0)", proof_cherry()),
    mpt.has(tree(), "coconut (0)", proof_coconut()),
    mpt.has(tree(), "cranberry (0)", proof_cranberry()),
    mpt.has(tree(), "durian (0)", proof_durian()),
    mpt.has(tree(), "fig (0)", proof_fig()),
    mpt.has(tree(), "grape (110606)", proof_grape()),
    mpt.has(tree(), "grapefruit (0)", proof_grapefruit()),
    mpt.has(tree(), "guava (0)", proof_guava()),
    mpt.has(tree(), "kiwi (0)", proof_kiwi()),
    mpt.has(tree(), "kumquat (0)", proof_kumquat()),
    mpt.has(tree(), "lemon (37694)", proof_lemon()),
    mpt.has(tree(), "lime (0)", proof_lime()),
    mpt.has(tree(), "mango (0)", proof_mango()),
    mpt.has(tree(), "orange (36703)", proof_orange()),
    mpt.has(tree(), "papaya (0)", proof_papaya()),
    mpt.has(tree(), "passionfruit (0)", proof_passionfruit()),
    mpt.has(tree(), "peach (0)", proof_peach()),
    mpt.has(tree(), "pear (0)", proof_pear()),
    mpt.has(tree(), "pineapple (0)", proof_pineapple()),
    mpt.has(tree(), "plum (0)", proof_plum()),
    mpt.has(tree(), "pomegranate (113)", proof_pomegranate()),
    mpt.has(tree(), "raspberry (0)", proof_raspberry()),
    mpt.has(tree(), "strawberry (0)", proof_strawberry()),
    mpt.has(tree(), "watermelon (20)", proof_watermelon()),
    mpt.has(tree(), "yuzu (0)", proof_yuzu()),
  }
}

test example_insert() {
  and {
    mpt.insert(tree_without_apple(), "apple (0)", proof_apple()) == tree(),
    mpt.insert(tree_without_apricot(), "apricot (0)", proof_apricot()) == tree(),
    mpt.insert(tree_without_banana(), "banana (328)", proof_banana()) == tree(),
    mpt.insert(tree_without_blackberry(), "blackberry (0)", proof_blackberry()) == tree(),
    mpt.insert(tree_without_blueberry(), "blueberry (92383)", proof_blueberry()) == tree(),
    mpt.insert(tree_without_cherry(), "cherry (0)", proof_cherry()) == tree(),
    mpt.insert(tree_without_coconut(), "coconut (0)", proof_coconut()) == tree(),
    mpt.insert(tree_without_cranberry(), "cranberry (0)", proof_cranberry()) == tree(),
    mpt.insert(tree_without_durian(), "durian (0)", proof_durian()) == tree(),
    mpt.insert(tree_without_fig(), "fig (0)", proof_fig()) == tree(),
    mpt.insert(tree_without_grape(), "grape (110606)", proof_grape()) == tree(),
    mpt.insert(tree_without_grapefruit(), "grapefruit (0)", proof_grapefruit()) == tree(),
    mpt.insert(tree_without_guava(), "guava (0)", proof_guava()) == tree(),
    mpt.insert(tree_without_kiwi(), "kiwi (0)", proof_kiwi()) == tree(),
    mpt.insert(tree_without_kumquat(), "kumquat (0)", proof_kumquat()) == tree(),
    mpt.insert(tree_without_lemon(), "lemon (37694)", proof_lemon()) == tree(),
    mpt.insert(tree_without_lime(), "lime (0)", proof_lime()) == tree(),
    mpt.insert(tree_without_mango(), "mango (0)", proof_mango()) == tree(),
    mpt.insert(tree_without_orange(), "orange (36703)", proof_orange()) == tree(),
    mpt.insert(tree_without_papaya(), "papaya (0)", proof_papaya()) == tree(),
    mpt.insert(
      tree_without_passionfruit(),
      "passionfruit (0)",
      proof_passionfruit(),
    ) == tree(),
    mpt.insert(tree_without_peach(), "peach (0)", proof_peach()) == tree(),
    mpt.insert(tree_without_pear(), "pear (0)", proof_pear()) == tree(),
    mpt.insert(tree_without_pineapple(), "pineapple (0)", proof_pineapple()) == tree(),
    mpt.insert(tree_without_plum(), "plum (0)", proof_plum()) == tree(),
    mpt.insert(
      tree_without_pomegranate(),
      "pomegranate (113)",
      proof_pomegranate(),
    ) == tree(),
    mpt.insert(tree_without_raspberry(), "raspberry (0)", proof_raspberry()) == tree(),
    mpt.insert(tree_without_strawberry(), "strawberry (0)", proof_strawberry()) == tree(),
    mpt.insert(tree_without_watermelon(), "watermelon (20)", proof_watermelon()) == tree(),
    mpt.insert(tree_without_yuzu(), "yuzu (0)", proof_yuzu()) == tree(),
  }
}

test example_delete() {
  and {
    mpt.delete(tree(), "apple (0)", proof_apple()) == tree_without_apple(),
    mpt.delete(tree(), "apricot (0)", proof_apricot()) == tree_without_apricot(),
    mpt.delete(tree(), "banana (328)", proof_banana()) == tree_without_banana(),
    mpt.delete(tree(), "blackberry (0)", proof_blackberry()) == tree_without_blackberry(),
    mpt.delete(tree(), "blueberry (92383)", proof_blueberry()) == tree_without_blueberry(),
    mpt.delete(tree(), "cherry (0)", proof_cherry()) == tree_without_cherry(),
    mpt.delete(tree(), "coconut (0)", proof_coconut()) == tree_without_coconut(),
    mpt.delete(tree(), "cranberry (0)", proof_cranberry()) == tree_without_cranberry(),
    mpt.delete(tree(), "durian (0)", proof_durian()) == tree_without_durian(),
    mpt.delete(tree(), "fig (0)", proof_fig()) == tree_without_fig(),
    mpt.delete(tree(), "grape (110606)", proof_grape()) == tree_without_grape(),
    mpt.delete(tree(), "grapefruit (0)", proof_grapefruit()) == tree_without_grapefruit(),
    mpt.delete(tree(), "guava (0)", proof_guava()) == tree_without_guava(),
    mpt.delete(tree(), "kiwi (0)", proof_kiwi()) == tree_without_kiwi(),
    mpt.delete(tree(), "kumquat (0)", proof_kumquat()) == tree_without_kumquat(),
    mpt.delete(tree(), "lemon (37694)", proof_lemon()) == tree_without_lemon(),
    mpt.delete(tree(), "lime (0)", proof_lime()) == tree_without_lime(),
    mpt.delete(tree(), "mango (0)", proof_mango()) == tree_without_mango(),
    mpt.delete(tree(), "orange (36703)", proof_orange()) == tree_without_orange(),
    mpt.delete(tree(), "papaya (0)", proof_papaya()) == tree_without_papaya(),
    mpt.delete(tree(), "passionfruit (0)", proof_passionfruit()) == tree_without_passionfruit(),
    mpt.delete(tree(), "peach (0)", proof_peach()) == tree_without_peach(),
    mpt.delete(tree(), "pear (0)", proof_pear()) == tree_without_pear(),
    mpt.delete(tree(), "pineapple (0)", proof_pineapple()) == tree_without_pineapple(),
    mpt.delete(tree(), "plum (0)", proof_plum()) == tree_without_plum(),
    mpt.delete(tree(), "pomegranate (113)", proof_pomegranate()) == tree_without_pomegranate(),
    mpt.delete(tree(), "raspberry (0)", proof_raspberry()) == tree_without_raspberry(),
    mpt.delete(tree(), "strawberry (0)", proof_strawberry()) == tree_without_strawberry(),
    mpt.delete(tree(), "watermelon (20)", proof_watermelon()) == tree_without_watermelon(),
    mpt.delete(tree(), "yuzu (0)", proof_yuzu()) == tree_without_yuzu(),
  }
}

// -------------------- Some negative cases

test example_already_inserted() fail {
  let root = mpt.insert(tree(), "kiwi (0)", proof_kiwi())
  root == root
}

test example_insert_nearby_with_wrong_proof() fail {
  let root = mpt.insert(tree_without_kiwi(), "grape (110606)", proof_kiwi())
  root == root
}

test example_insert_higher_with_wrong_proof() fail {
  let root = mpt.insert(tree_without_lemon(), "kiwi (0)", proof_lemon())
  root == root
}

test example_delete_nearby_with_wrong_proof() fail {
  let root = mpt.delete(tree(), "blackberry (0)", proof_grapefruit())
  root == root
}

test example_delete_higher_with_wrong_proof() fail {
  let root = mpt.delete(tree(), "watermelon (20)", proof_blueberry())
  root == root
}

// -------------------- Mutations

type ProofMutation {
  RemoveStepAt(Int)
  InsertStepAt(Int, ProofStep)
  IncrementSkipAt(Int)
}

fn fuzz_proof_mutation(proof: Proof) -> Fuzzer<ProofMutation> {
  expect !list.is_empty(proof)

  let choice <- fuzz.and_then(fuzz.int_between(0, 1))

  when choice is {
    0 -> {
      let ix <- fuzz.map(fuzz.int_between(0, list.length(proof) - 1))
      RemoveStepAt(ix)
    }

    1 -> {
      let ix <- fuzz.and_then(fuzz.int_between(0, list.length(proof)))
      let neighbor <- fuzz.map(fuzz.bytearray_between(32, 32))
      InsertStepAt(ix, Leaf { skip: 0, neighbor })
    }

    2 -> {
      let ix <- fuzz.map(fuzz.int_between(0, list.length(proof) - 1))
      IncrementSkipAt(ix)
    }

    _ -> fail @"unexpected choice"
  }
}

fn mutate(proof: Proof, mutation: ProofMutation) -> Proof {
  when mutation is {
    RemoveStepAt(ix) ->
      list.concat(list.take(proof, ix - 1), list.drop(proof, ix + 1))

    InsertStepAt(ix, step) ->
      list.concat(list.take(proof, ix), [step, ..list.drop(proof, ix)])

    IncrementSkipAt(ix) -> {
      let step =
        when list.at(proof, ix) is {
          Some(Branch { skip, neighbors }) ->
            Branch { skip: skip + 1, neighbors }
          Some(Fork { skip, neighbor }) -> Fork { skip: skip + 1, neighbor }
          Some(Leaf { skip, neighbor }) -> Leaf { skip: skip + 1, neighbor }
          _ -> fail @"invalid 'IncrementSkipAt' mutation generated"
        }
      list.concat(list.take(proof, ix - 1), [step, ..list.drop(proof, ix + 1)])
    }
  }
}

test example_mutate_proof(
  mutation via fuzz_proof_mutation(proof_pomegranate()),
) fail {
  let proof = proof_pomegranate() |> mutate(mutation)
  mpt.has(tree(), "pomegranate (113)", proof)
}

// -------------------- Fruits

// ---------- apple

fn proof_apple() {
  [
    Branch {
      skip: 0,
      neighbors: #"ba70d69ad506602ca0b19feb97b8c147c2dd61fdcc339d923f63ed5fdc7672024bbeb6ae3f0be7064a421f48c400ce7558b860de83922fc912b5245231390341edbc265edc4566f20d553d756d7883e68fd5782eb048e02f92aa470329e99c81d6f002e80af7a5848a46ce037cfabf85799171eeef8229d415f3979062f428eb",
    },
  ]
}

fn tree_without_apple() {
  mpt.from_root(
    #"9a4d6e6d86e25c936504f75cfdfccecb244f51dbc8779ca8d1fd979ec35eb21f",
  )
}

// ---------- apricot

fn proof_apricot() {
  [
    Branch {
      skip: 0,
      neighbors: #"17d4f4c7df59f1ddbe269b5e96574a1b93db401eca1c7b1a0a7c537a8a57ec3a148ba7cecd29eca1024f3c7c6b70df6535561402460429c8a3c99432ba045deaa6cf2f0fcc8afd0d7fbd9011b3f25c61d2ad5430e6e86018b77407a778bdaa7e58fd96cee52ea33da7e09d5ab8543e0d8d64ebf9a4624c6f30304415282edd63",
    },
    Branch {
      skip: 0,
      neighbors: #"f608aebdd38bd241e54eda1a420b9b24dc71f198ffa1927b08c7723a245ad969b42abb04f1b1d80dc6f55063636d328505cd6141f933ba84ad0f378968fca4bf377da8b8b5dd83a2e770ef6109600c6acc09e10dbcd822975665e5a6ad2ff7b1c7d47f4ec10a674ec0f78631f9d8cfb43846a3b4a1ec1b837b4c047ad681a732",
    },
  ]
}

fn tree_without_apricot() {
  mpt.from_root(
    #"a7218b2c0aed9e6c7c88df6549879b68d9be103d9d4db933f7a5b6a4f7c36619",
  )
}

// ---------- banana

fn proof_banana() {
  [
    Branch {
      skip: 0,
      neighbors: #"ba70d69ad506602ca0b19feb97b8c147c2dd61fdcc339d923f63ed5fdc7672024bbeb6ae3f0be7064a421f48c400ce7558b860de83922fc912b5245231390341d23863fd580376216d328dfaa83075024a81f08a20a3c171e922eae35d7bdc0fff0edb5bcd46eed5d27013c751ad8df9c2a8d73031586403eda51eeddd716fda",
    },
    Leaf {
      skip: 1,
      neighbor: #"55258d0d33eb0e7f216812f406d2b25e5010157ff0919c86e471cb922ff65fd1",
    },
  ]
}

fn tree_without_banana() {
  mpt.from_root(
    #"bff5c6e18ff9f2ef6925fe9d5911df21e7b65f34d8a175d928e89e3c72ba74cf",
  )
}

// ---------- blackberry

fn proof_blackberry() {
  [
    Branch {
      skip: 0,
      neighbors: #"ba70d69ad506602ca0b19feb97b8c147c2dd61fdcc339d923f63ed5fdc76720263d076d60be3e4635c9bee44a2aedae9433c0a4c814a678fa89a477f014bb28f92d5f8ecf8f676d135dfc74395b96a5e57aa35a201af5710feaa086b89f8a9d20000000000000000000000000000000000000000000000000000000000000000",
    },
    Leaf {
      skip: 0,
      neighbor: #"3f6ceadf0a21a7a754b9c796a18e83df1da75e59c2f88d09011995ba8dab9059",
    },
  ]
}

fn tree_without_blackberry() {
  mpt.from_root(
    #"12823ae8014eca373e79344b089e9354de00f1de395e19cd98b54299fea80389",
  )
}

// ---------- blueberry

fn proof_blueberry() {
  [
    Branch {
      skip: 0,
      neighbors: #"17d4f4c7df59f1ddbe269b5e96574a1b93db401eca1c7b1a0a7c537a8a57ec3af10ed85be8ac96e616a51e2acc213f32a712d34555e2fb0af4ccf26163d9412dbf8484657024dbeb42dc41e7ad72534bad5d0612b26c0a0182c1770d70c6c58f51255842cc983058302bd1197948534959862ed80d155833abe0d461674a88c9",
    },
    Leaf {
      skip: 0,
      neighbor: #"f77af1bd3cda91f714144491553c8e33de144689eaacb75e080808c97b5bce06",
    },
    Leaf {
      skip: 0,
      neighbor: #"f6d8c90f4d29710d4b8bda744ea7ab1e0c333d60d0d866cebb90563e6121df1a",
    },
    Leaf {
      skip: 1,
      neighbor: #"f67460e1a00a37cccaf2b135741bdc39b9d67548d8e90caf7021a651b7c1d432",
    },
  ]
}

fn tree_without_blueberry() {
  mpt.from_root(
    #"ec5bee82c48fad1fc5e16134d40574e8a117da19b171f3f9c817f02daa7574f6",
  )
}

// ---------- cherry

fn proof_cherry() {
  [
    Branch {
      skip: 0,
      neighbors: #"ba70d69ad506602ca0b19feb97b8c147c2dd61fdcc339d923f63ed5fdc7672024bbeb6ae3f0be7064a421f48c400ce7558b860de83922fc912b5245231390341edbc265edc4566f20d553d756d7883e68fd5782eb048e02f92aa470329e99c816f90ba97b2157d5679504c6e99e07a2c59685ae1f5e1a88304a5d7305aede366",
    },
    Branch {
      skip: 0,
      neighbors: #"a9f44a136694784f35bc4b3aba25a1d5e6f2b828663c8d0b26d73e62a38104888033e682cea4865bce4455bcf872938f5faa2efd888cafdb487ecf3f845007380eb923b0cbd24df54401d998531feead35a47a99f4deed205de4af81120f97610000000000000000000000000000000000000000000000000000000000000000",
    },
  ]
}

fn tree_without_cherry() {
  mpt.from_root(
    #"2a3889600d992dae52f609ab4273fdf4547f1cd6d389cd2d3acac582130268d7",
  )
}

// ---------- coconut

fn proof_coconut() {
  [
    Branch {
      skip: 0,
      neighbors: #"17d4f4c7df59f1ddbe269b5e96574a1b93db401eca1c7b1a0a7c537a8a57ec3a148ba7cecd29eca1024f3c7c6b70df6535561402460429c8a3c99432ba045deaa6cf2f0fcc8afd0d7fbd9011b3f25c61d2ad5430e6e86018b77407a778bdaa7e58fd96cee52ea33da7e09d5ab8543e0d8d64ebf9a4624c6f30304415282edd63",
    },
    Branch {
      skip: 0,
      neighbors: #"f608aebdd38bd241e54eda1a420b9b24dc71f198ffa1927b08c7723a245ad969308694fb07bb1f7cc4202fa30577f760b2ae3e208d2d41a12dfdb2eef327e2dd0eb923b0cbd24df54401d998531feead35a47a99f4deed205de4af81120f97610000000000000000000000000000000000000000000000000000000000000000",
    },
  ]
}

fn tree_without_coconut() {
  mpt.from_root(
    #"4208a39a14ed18807fbe361a99d147e21c7922d11fb44ae0a54c4edbfce7e705",
  )
}

// ---------- cranberry

fn proof_cranberry() {
  [
    Branch {
      skip: 0,
      neighbors: #"ba70d69ad506602ca0b19feb97b8c147c2dd61fdcc339d923f63ed5fdc76720263d076d60be3e4635c9bee44a2aedae9433c0a4c814a678fa89a477f014bb28fa42a34892ba1a7fb7f5da98290d01696328e3dfec8a403b6c4e5834c1bf7ba164e814491dc507f3271ccb1533108cf4795ecb5a4354b8730996ac10084209b83",
    },
  ]
}

fn tree_without_cranberry() {
  mpt.from_root(
    #"3d353c058003f1d35f79b726dce2b231e71bfb554f9e47ffce2a4b0b1459db57",
  )
}

// ---------- durian

fn proof_durian() {
  [
    Branch {
      skip: 0,
      neighbors: #"17d4f4c7df59f1ddbe269b5e96574a1b93db401eca1c7b1a0a7c537a8a57ec3a148ba7cecd29eca1024f3c7c6b70df6535561402460429c8a3c99432ba045deaa6cf2f0fcc8afd0d7fbd9011b3f25c61d2ad5430e6e86018b77407a778bdaa7e58fd96cee52ea33da7e09d5ab8543e0d8d64ebf9a4624c6f30304415282edd63",
    },
    Branch {
      skip: 0,
      neighbors: #"3b939775a17fa5f5f8b712e3f406d748fc81deeb2de7a62fb2e801e0c0c8dd8530fa7360e43b63387b68532f9618e84e997a0fc7ecc8fc28f7b4384f7305a91d0eb923b0cbd24df54401d998531feead35a47a99f4deed205de4af81120f97610000000000000000000000000000000000000000000000000000000000000000",
    },
  ]
}

fn tree_without_durian() {
  mpt.from_root(
    #"7c2794eaabb8b91d10c4379c460c48554c6d5dce7a6e945d6aa37463aa0d2020",
  )
}

// ---------- fig

fn proof_fig() {
  [
    Branch {
      skip: 0,
      neighbors: #"ba70d69ad506602ca0b19feb97b8c147c2dd61fdcc339d923f63ed5fdc76720263d076d60be3e4635c9bee44a2aedae9433c0a4c814a678fa89a477f014bb28fa42a34892ba1a7fb7f5da98290d01696328e3dfec8a403b6c4e5834c1bf7ba16f25d1f3e731bff861c0d1b0299dfef46f88165c6b4b39c41e0d7d139ab2d4a15",
    },
    Leaf {
      skip: 3,
      neighbor: #"138bc45c2fcafeb234075bf16851f58c4d5549c2b9e915099950ebf299b6769a",
    },
  ]
}

fn tree_without_fig() {
  mpt.from_root(
    #"59de1aa5b12104d1c402721c617a168a57c3a6c2490c505c500ae6d112e6eb0d",
  )
}

// ---------- grape

fn proof_grape() {
  [
    Branch {
      skip: 0,
      neighbors: #"17d4f4c7df59f1ddbe269b5e96574a1b93db401eca1c7b1a0a7c537a8a57ec3af10ed85be8ac96e616a51e2acc213f32a712d34555e2fb0af4ccf26163d9412dbf8484657024dbeb42dc41e7ad72534bad5d0612b26c0a0182c1770d70c6c58f27d1f4677013e827df2dbcd7bf941d3627bd9f7bcb5b38c6224220eead8c1a0e",
    },
    Leaf {
      skip: 0,
      neighbor: #"e0d9ffff534b7c5dad98baa3b5bd143e75ac512243f103c9c7f7da33cf7ce35d",
    },
    Leaf {
      skip: 2,
      neighbor: #"e385223186560a8a8b36a5e829075d4bb8663d5734f1c349f5a63ca424c97814",
    },
  ]
}

fn tree_without_grape() {
  mpt.from_root(
    #"d4d08b7814a7fe9cc30c3c358b896dac3d2bd1ca9cdff6a8ea7db9a905863fab",
  )
}

// ---------- grapefruit

fn proof_grapefruit() {
  [
    Branch {
      skip: 0,
      neighbors: #"ba70d69ad506602ca0b19feb97b8c147c2dd61fdcc339d923f63ed5fdc76720263d076d60be3e4635c9bee44a2aedae9433c0a4c814a678fa89a477f014bb28f92d5f8ecf8f676d135dfc74395b96a5e57aa35a201af5710feaa086b89f8a9d20000000000000000000000000000000000000000000000000000000000000000",
    },
    Leaf {
      skip: 0,
      neighbor: #"3378b5c960257ffe7c3e86d00563739bdf7db730e10732f6b943a4c1802fd05e",
    },
  ]
}

fn tree_without_grapefruit() {
  mpt.from_root(
    #"7de91f7f48795439990a8991c80e6abcebbe09e52ae3a91ca1df1949931bcd48",
  )
}

// ---------- guava

fn proof_guava() {
  [
    Branch {
      skip: 0,
      neighbors: #"ba70d69ad506602ca0b19feb97b8c147c2dd61fdcc339d923f63ed5fdc7672024bbeb6ae3f0be7064a421f48c400ce7558b860de83922fc912b5245231390341edbc265edc4566f20d553d756d7883e68fd5782eb048e02f92aa470329e99c816f90ba97b2157d5679504c6e99e07a2c59685ae1f5e1a88304a5d7305aede366",
    },
    Branch {
      skip: 0,
      neighbors: #"91c959cce4d200911df1ae57ce039a81606c60a722a2b237c6f968c4326a5f6fab197fb96928ac7c77a158fb7c35a43d60f1fc43fe9c94d21d982d988e6e9a5e0eb923b0cbd24df54401d998531feead35a47a99f4deed205de4af81120f97610000000000000000000000000000000000000000000000000000000000000000",
    },
  ]
}

fn tree_without_guava() {
  mpt.from_root(
    #"2720797c205378108dc035d58847f4e53ff6d41109f51e8756420c00b3c3a674",
  )
}

// ---------- kiwi

fn proof_kiwi() {
  [
    Branch {
      skip: 0,
      neighbors: #"17d4f4c7df59f1ddbe269b5e96574a1b93db401eca1c7b1a0a7c537a8a57ec3af10ed85be8ac96e616a51e2acc213f32a712d34555e2fb0af4ccf26163d9412dbf8484657024dbeb42dc41e7ad72534bad5d0612b26c0a0182c1770d70c6c58f27d1f4677013e827df2dbcd7bf941d3627bd9f7bcb5b38c6224220eead8c1a0e",
    },
    Fork {
      skip: 0,
      neighbor: Neighbor {
        nibble: 3,
        value: #"e22d7e6735be3d4cf291e766e732bc18ea1f0c426220b14b251cbbd7c878c8dd",
        prefix: #"0805",
      },
    },
  ]
}

fn tree_without_kiwi() {
  mpt.from_root(
    #"000183ca63d11d325ac92f780fe301e64109ff7b16870d19e5f767698ddbdb0e",
  )
}

// ---------- kumquat

fn proof_kumquat() {
  [
    Branch {
      skip: 0,
      neighbors: #"17d4f4c7df59f1ddbe269b5e96574a1b93db401eca1c7b1a0a7c537a8a57ec3a148ba7cecd29eca1024f3c7c6b70df6535561402460429c8a3c99432ba045deaa6cf2f0fcc8afd0d7fbd9011b3f25c61d2ad5430e6e86018b77407a778bdaa7e58fd96cee52ea33da7e09d5ab8543e0d8d64ebf9a4624c6f30304415282edd63",
    },
    Branch {
      skip: 0,
      neighbors: #"f608aebdd38bd241e54eda1a420b9b24dc71f198ffa1927b08c7723a245ad969b42abb04f1b1d80dc6f55063636d328505cd6141f933ba84ad0f378968fca4bfa0fb1435b770c6dbcb2dbd0472720f5d5c73bf5fc69b7aff644862eb7ba3c75f0000000000000000000000000000000000000000000000000000000000000000",
    },
  ]
}

fn tree_without_kumquat() {
  mpt.from_root(
    #"d6281a90334b6c9cdf00c82cd876629decb40db2314041011436571284fa6e61",
  )
}

// ---------- lemon

fn proof_lemon() {
  [
    Branch {
      skip: 0,
      neighbors: #"17d4f4c7df59f1ddbe269b5e96574a1b93db401eca1c7b1a0a7c537a8a57ec3af10ed85be8ac96e616a51e2acc213f32a712d34555e2fb0af4ccf26163d9412dbf8484657024dbeb42dc41e7ad72534bad5d0612b26c0a0182c1770d70c6c58f27d1f4677013e827df2dbcd7bf941d3627bd9f7bcb5b38c6224220eead8c1a0e",
    },
    Leaf {
      skip: 0,
      neighbor: #"e0d9ffff534b7c5dad98baa3b5bd143e75ac512243f103c9c7f7da33cf7ce35d",
    },
    Leaf {
      skip: 2,
      neighbor: #"e38564f70616708ffcd52bca9e48480f80168c232a9acfe7fa7e469b62f33c0b",
    },
  ]
}

fn tree_without_lemon() {
  mpt.from_root(
    #"14713497ff9fa7d43e77ec49651a40976c0e073ecec74b9fc2eac9568f2831d8",
  )
}

// ---------- lime

fn proof_lime() {
  [
    Branch {
      skip: 0,
      neighbors: #"ba70d69ad506602ca0b19feb97b8c147c2dd61fdcc339d923f63ed5fdc7672024bbeb6ae3f0be7064a421f48c400ce7558b860de83922fc912b5245231390341edbc265edc4566f20d553d756d7883e68fd5782eb048e02f92aa470329e99c816f90ba97b2157d5679504c6e99e07a2c59685ae1f5e1a88304a5d7305aede366",
    },
    Branch {
      skip: 0,
      neighbors: #"a9f44a136694784f35bc4b3aba25a1d5e6f2b828663c8d0b26d73e62a3810488951771f8e23ef1b48a57ecdd4e720df8f8783e3cb5c4343f0e4162d89d2804f60eb923b0cbd24df54401d998531feead35a47a99f4deed205de4af81120f97610000000000000000000000000000000000000000000000000000000000000000",
    },
  ]
}

fn tree_without_lime() {
  mpt.from_root(
    #"cced04e34827c8f5aa3394ba7769952a7f798bc7394cd84f921c8ddb65486405",
  )
}

// ---------- mango

fn proof_mango() {
  [
    Branch {
      skip: 0,
      neighbors: #"17d4f4c7df59f1ddbe269b5e96574a1b93db401eca1c7b1a0a7c537a8a57ec3a148ba7cecd29eca1024f3c7c6b70df6535561402460429c8a3c99432ba045dea16ad59cfce49fddd62bbc60d5e43c5350efa3f791d99ef8297f4f79e2a9d23520000000000000000000000000000000000000000000000000000000000000000",
    },
  ]
}

fn tree_without_mango() {
  mpt.from_root(
    #"677a5fcf4b246af1d46a9d8ae7bcc891731b7bb01ac1068ed808b1fb118cc898",
  )
}

// ---------- orange

fn proof_orange() {
  [
    Branch {
      skip: 0,
      neighbors: #"ba70d69ad506602ca0b19feb97b8c147c2dd61fdcc339d923f63ed5fdc76720263d076d60be3e4635c9bee44a2aedae9433c0a4c814a678fa89a477f014bb28fa42a34892ba1a7fb7f5da98290d01696328e3dfec8a403b6c4e5834c1bf7ba16f25d1f3e731bff861c0d1b0299dfef46f88165c6b4b39c41e0d7d139ab2d4a15",
    },
    Leaf {
      skip: 3,
      neighbor: #"138b407b7cc00a52955272bfd7d66b47c8965066bb6ff93b51ad4f9b34e2c445",
    },
  ]
}

fn tree_without_orange() {
  mpt.from_root(
    #"d76b6f56ccba499f94a7ab4a47553b426b4b64968a515d9d9a018dd58934fab1",
  )
}

// ---------- papaya

fn proof_papaya() {
  [
    Branch {
      skip: 0,
      neighbors: #"17d4f4c7df59f1ddbe269b5e96574a1b93db401eca1c7b1a0a7c537a8a57ec3a148ba7cecd29eca1024f3c7c6b70df6535561402460429c8a3c99432ba045deaa6cf2f0fcc8afd0d7fbd9011b3f25c61d2ad5430e6e86018b77407a778bdaa7e58fd96cee52ea33da7e09d5ab8543e0d8d64ebf9a4624c6f30304415282edd63",
    },
    Branch {
      skip: 0,
      neighbors: #"f608aebdd38bd241e54eda1a420b9b24dc71f198ffa1927b08c7723a245ad969b42abb04f1b1d80dc6f55063636d328505cd6141f933ba84ad0f378968fca4bf377da8b8b5dd83a2e770ef6109600c6acc09e10dbcd822975665e5a6ad2ff7b1386409826e4aa8b71c1de4eeeb2b798f892f08041de9c886150e15039c8cbb51",
    },
  ]
}

fn tree_without_papaya() {
  mpt.from_root(
    #"12ae97c8c500ebb3b0fb9fe209177319757747593b76f67d9e81367e21dec31b",
  )
}

// ---------- passionfruit

fn proof_passionfruit() {
  [
    Branch {
      skip: 0,
      neighbors: #"17d4f4c7df59f1ddbe269b5e96574a1b93db401eca1c7b1a0a7c537a8a57ec3af10ed85be8ac96e616a51e2acc213f32a712d34555e2fb0af4ccf26163d9412dbf8484657024dbeb42dc41e7ad72534bad5d0612b26c0a0182c1770d70c6c58f51255842cc983058302bd1197948534959862ed80d155833abe0d461674a88c9",
    },
    Leaf {
      skip: 0,
      neighbor: #"f77af1bd3cda91f714144491553c8e33de144689eaacb75e080808c97b5bce06",
    },
    Leaf {
      skip: 0,
      neighbor: #"f6d8c90f4d29710d4b8bda744ea7ab1e0c333d60d0d866cebb90563e6121df1a",
    },
    Leaf {
      skip: 1,
      neighbor: #"f674b9b0c22bb6f74dd54716b875e13416a1d270bdf0257c6fd4b864b3cb5b98",
    },
  ]
}

fn tree_without_passionfruit() {
  mpt.from_root(
    #"fbd0f42ec1d31de6eb1efeb5afc446c5eed785228ac7c185693b9451ad039a30",
  )
}

// ---------- peach

fn proof_peach() {
  [
    Branch {
      skip: 0,
      neighbors: #"17d4f4c7df59f1ddbe269b5e96574a1b93db401eca1c7b1a0a7c537a8a57ec3af10ed85be8ac96e616a51e2acc213f32a712d34555e2fb0af4ccf26163d9412dfc1726c3310f5a0c987c7d99003ee61595f7075259c02aae9bb8e15c3a0ce5150000000000000000000000000000000000000000000000000000000000000000",
    },
  ]
}

fn tree_without_peach() {
  mpt.from_root(
    #"ac23b90822fe7e7fe1ce8989faa4155bfd89df2581911f7628efe4fa54deecc2",
  )
}

// ---------- pear

fn proof_pear() {
  [
    Branch {
      skip: 0,
      neighbors: #"ba70d69ad506602ca0b19feb97b8c147c2dd61fdcc339d923f63ed5fdc7672024bbeb6ae3f0be7064a421f48c400ce7558b860de83922fc912b5245231390341d23863fd580376216d328dfaa83075024a81f08a20a3c171e922eae35d7bdc0fff0edb5bcd46eed5d27013c751ad8df9c2a8d73031586403eda51eeddd716fda",
    },
    Leaf {
      skip: 1,
      neighbor: #"55d5551e8e1323d35afe53cf8698867c9de9a408e97ee968dc8414d527cc719c",
    },
  ]
}

fn tree_without_pear() {
  mpt.from_root(
    #"06f2434a0f5b56bea3a94f9daccfa0a5e205ff4cc6afb3818cb1492f698cbfec",
  )
}

// ---------- pineapple

fn proof_pineapple() {
  [
    Branch {
      skip: 0,
      neighbors: #"17d4f4c7df59f1ddbe269b5e96574a1b93db401eca1c7b1a0a7c537a8a57ec3a148ba7cecd29eca1024f3c7c6b70df6535561402460429c8a3c99432ba045deaa6cf2f0fcc8afd0d7fbd9011b3f25c61d2ad5430e6e86018b77407a778bdaa7e58fd96cee52ea33da7e09d5ab8543e0d8d64ebf9a4624c6f30304415282edd63",
    },
    Branch {
      skip: 0,
      neighbors: #"3b939775a17fa5f5f8b712e3f406d748fc81deeb2de7a62fb2e801e0c0c8dd85d970ab1e79b6a138f76797e735555fc5b7a83b1c02ebd3fbb9703f5f0f5144670eb923b0cbd24df54401d998531feead35a47a99f4deed205de4af81120f97610000000000000000000000000000000000000000000000000000000000000000",
    },
  ]
}

fn tree_without_pineapple() {
  mpt.from_root(
    #"8af397621fbcbbed47af8b251e164663f5e0b5076b34b2d3e7ca514d5d5e107a",
  )
}

// ---------- plum

fn proof_plum() {
  [
    Branch {
      skip: 0,
      neighbors: #"ba70d69ad506602ca0b19feb97b8c147c2dd61fdcc339d923f63ed5fdc7672024bbeb6ae3f0be7064a421f48c400ce7558b860de83922fc912b5245231390341edbc265edc4566f20d553d756d7883e68fd5782eb048e02f92aa470329e99c816f90ba97b2157d5679504c6e99e07a2c59685ae1f5e1a88304a5d7305aede366",
    },
    Branch {
      skip: 0,
      neighbors: #"91c959cce4d200911df1ae57ce039a81606c60a722a2b237c6f968c4326a5f6fb7a121e823b4efb9e362c0c886e3381907470beddcc7205cfb25ac63d1d23aa00eb923b0cbd24df54401d998531feead35a47a99f4deed205de4af81120f97610000000000000000000000000000000000000000000000000000000000000000",
    },
  ]
}

fn tree_without_plum() {
  mpt.from_root(
    #"2fa2f6c70db080863cc047d3da74165b91796030d57b052fbe528b674d0315cf",
  )
}

// ---------- pomegranate

fn proof_pomegranate() {
  [
    Branch {
      skip: 0,
      neighbors: #"17d4f4c7df59f1ddbe269b5e96574a1b93db401eca1c7b1a0a7c537a8a57ec3af10ed85be8ac96e616a51e2acc213f32a712d34555e2fb0af4ccf26163d9412dbf8484657024dbeb42dc41e7ad72534bad5d0612b26c0a0182c1770d70c6c58f51255842cc983058302bd1197948534959862ed80d155833abe0d461674a88c9",
    },
    Leaf {
      skip: 0,
      neighbor: #"f77af1bd3cda91f714144491553c8e33de144689eaacb75e080808c97b5bce06",
    },
    Fork {
      skip: 0,
      neighbor: Neighbor {
        nibble: 7,
        value: #"1f4fb05c59a9ba0c216843debdb4850f566c0925043d5188c777639c60c5a34f",
        prefix: #"04",
      },
    },
  ]
}

fn tree_without_pomegranate() {
  mpt.from_root(
    #"ebe783382866d39bee47722f68b16a2e1a1e66b95e9ebf17112f1566f2aaf378",
  )
}

// ---------- raspberry

fn proof_raspberry() {
  [
    Branch {
      skip: 0,
      neighbors: #"17d4f4c7df59f1ddbe269b5e96574a1b93db401eca1c7b1a0a7c537a8a57ec3a148ba7cecd29eca1024f3c7c6b70df6535561402460429c8a3c99432ba045deaa6cf2f0fcc8afd0d7fbd9011b3f25c61d2ad5430e6e86018b77407a778bdaa7ef622b17984c87b7090f592bc0148c1916d887e6b9111914895f96fa3309875fe",
    },
    Leaf {
      skip: 0,
      neighbor: #"bd0f991572aef335da6ea31786aa8f147f5a4a1d374251548b2d03c008274595",
    },
  ]
}

fn tree_without_raspberry() {
  mpt.from_root(
    #"0f619435622f05dbef28bf1d213b84a1fa72d3bcab275bfe9adf6e05f6535084",
  )
}

// ---------- strawberry

fn proof_strawberry() {
  [
    Branch {
      skip: 0,
      neighbors: #"ba70d69ad506602ca0b19feb97b8c147c2dd61fdcc339d923f63ed5fdc7672024bbeb6ae3f0be7064a421f48c400ce7558b860de83922fc912b5245231390341d23863fd580376216d328dfaa83075024a81f08a20a3c171e922eae35d7bdc0f7ff262d84793236812372db076467bf4f2aed52fc0b10ce35a288576b080e162",
    },
  ]
}

fn tree_without_strawberry() {
  mpt.from_root(
    #"a620b703557977a84bdda57bfd8145be0eaa5382611359e5f725dd5c04ac6181",
  )
}

// ---------- watermelon

fn proof_watermelon() {
  [
    Branch {
      skip: 0,
      neighbors: #"17d4f4c7df59f1ddbe269b5e96574a1b93db401eca1c7b1a0a7c537a8a57ec3af10ed85be8ac96e616a51e2acc213f32a712d34555e2fb0af4ccf26163d9412dbf8484657024dbeb42dc41e7ad72534bad5d0612b26c0a0182c1770d70c6c58f51255842cc983058302bd1197948534959862ed80d155833abe0d461674a88c9",
    },
    Fork {
      skip: 0,
      neighbor: Neighbor {
        nibble: 6,
        value: #"e7c2a3368273331faf8e20321abec58ff1c0d26e5837caff99a17b11168f196c",
        prefix: #"",
      },
    },
  ]
}

fn tree_without_watermelon() {
  mpt.from_root(
    #"ee1de2930c35731c833e1d472f34ceaa41cb8874f6f336769742808f7152c2d2",
  )
}

// ---------- yuzu

fn proof_yuzu() {
  [
    Branch {
      skip: 0,
      neighbors: #"17d4f4c7df59f1ddbe269b5e96574a1b93db401eca1c7b1a0a7c537a8a57ec3a148ba7cecd29eca1024f3c7c6b70df6535561402460429c8a3c99432ba045deaa6cf2f0fcc8afd0d7fbd9011b3f25c61d2ad5430e6e86018b77407a778bdaa7ef622b17984c87b7090f592bc0148c1916d887e6b9111914895f96fa3309875fe",
    },
    Leaf {
      skip: 0,
      neighbor: #"ba830de32503d8941eee8b8689332e8903841663d99c4442434858b1a147da75",
    },
  ]
}

fn tree_without_yuzu() {
  mpt.from_root(
    #"c85314075bae704df95bbd5ab74259540463b1552c94a1a6ffce0da22234c522",
  )
}
