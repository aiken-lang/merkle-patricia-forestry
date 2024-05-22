use aiken/fuzz
use aiken/list
use aiken/merkle_patricia_tree.{
  Branch, Fork, Leaf, MerklePatriciaTree, Neighbor, Proof, ProofStep,
} as mpt

/// An example tree made from a list of fruits.
///
///  ╔═══════════════════════════════════════════════════════════════════╗
///  ║ #4282aa63cc66d6161d949719b6b13448b6ce3256fc741898fed791316c204648 ║
///  ╚═══════════════════════════════════════════════════════════════════╝
///   ┌─ 066d2..[55 digits]..c160 #f25d1f3e731b → cranberry (0)
///   ├─ 138b #f2f43e90f41e
///   │  ├─ 407b7..[51 digits]..c445 #919e613fe7b9 → fig (0)
///   │  └─ c45c2..[51 digits]..769a #48ad7766c6f8 → orange (36703)
///   ├─ 3 #617f1700cff5
///   │  ├─ 378b5..[54 digits]..d05e #e9eca31fe449 → blackberry (0)
///   │  └─ f6cea..[54 digits]..9059 #4932e8645de3 → grapefruit (0)
///   ├─ 45708..[55 digits]..d238 #ff0edb5bcd46 → strawberry (0)
///   ├─ 55 #7bb9c1501ab5
///   │  ├─ 258d0..[53 digits]..5fd1 #723a329d15c8 → pear (0)
///   │  └─ d5551..[53 digits]..719c #9f1649f013cf → banana (328)
///   ├─ 6 #07593bf01598
///   │  ├─ 29347..[54 digits]..996e #5ff4152c6c64 → plum (0)
///   │  ├─ 7642e..[54 digits]..e791 #d984adaf73f7 → guava (0)
///   │  ├─ a9150..[54 digits]..f64e #e124d5f9f4b6 → cherry (0)
///   │  └─ f4ea6..[54 digits]..473f #01a804893a0a → lime (0)
///   ├─ 7cf7b..[55 digits]..eb70 #6f90ba97b215 → apple (0)
///   ├─ 993e2..[55 digits]..b3af #a87398cb4efe → mango (0)
///   ├─ a #2c587fdcfef2
///   │  ├─ 120d7..[54 digits]..5b19 #d823212af2c8 → pineapple (0)
///   │  ├─ 454a2..[54 digits]..6a37 #fd19d19f2f77 → durian (0)
///   │  ├─ 8bf57..[54 digits]..2fca #c7d47f4ec10a → papaya (0)
///   │  ├─ 909ba..[54 digits]..1e87 #386409826e4a → apricot (0)
///   │  ├─ af5cb..[54 digits]..15c6 #064a8065a738 → kumquat (0)
///   │  └─ f7cd6..[54 digits]..b859 #8f69234c7851 → coconut (0)
///   ├─ b #176b94ba40db
///   │  ├─ a830d..[54 digits]..da75 #4663aa5b8efe → raspberry (0)
///   │  └─ d0f99..[54 digits]..4595 #dc420faa3237 → yuzu (0)
///   ├─ c8553..[55 digits]..aad3 #5361d160bd0f → peach (0)
///   ├─ e #4569ef9ae5aa
///   │  ├─ 0d9ff..[54 digits]..e35d #50e1bef1f340 → kiwi (0)
///   │  └─ 385 #32cb5b6de7fd
///   │     ├─ 22318..[51 digits]..7814 #c9002066f807 → lemon (37694)
///   │     └─ 64f70..[51 digits]..3c0b #7bdba6df08a5 → grape (110606)
///   └─ f #0f2a6b71c3cf
///      ├─ 6 #5c6a63e872c6
///      │  ├─ 74 #82c2eb613436
///      │  │  ├─ 60e1a..[51 digits]..d432 #4ee055982ee3 → passionfruit (0)
///      │  │  └─ b9b0c..[51 digits]..5b98 #1d16215a4fb8 → blueberry (92383)
///      │  └─ d8c90..[53 digits]..df1a #a54def540220 → pomegranate (113)
///      └─ 77af1..[54 digits]..ce06 #415dcee4a96c → watermelon (20)
///
fn tree() -> MerklePatriciaTree {
  mpt.from_root(
    #"4282aa63cc66d6161d949719b6b13448b6ce3256fc741898fed791316c204648",
  )
}

// test example_has_fig() {
//   mpt.has(tree(), "fig (0)", proof_fig())
// }

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
          Some(Branch { skip, neighbors, mask }) ->
            Branch { skip: skip + 1, neighbors, mask }
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
      neighbors: #"f25d1f3e731bff861c0d1b0299dfef46f88165c6b4b39c41e0d7d139ab2d4a15f2f43e90f41eda69546ea927d0dfebcda244213b7ad2b95bd30eefce057979df617f1700cff559c28af9041300667344d44cc39f3d811d5580ec0332ed84a957ff0edb5bcd46eed5d27013c751ad8df9c2a8d73031586403eda51eeddd716fda7bb9c1501ab5663b0544368897a717228e98a6500608df956c1ecc1e6e88e94b07593bf015988ad4f318319cc252200c900b9e55da582a8afd7a4ffa79949fcda87398cb4efe5dc59dbea4d0d75c0b329b2dc21380f35049f44bcb7baee8cbbd2c587fdcfef29afb8387e21e97045c4d01228063caa505c792f5a3d789ae28b7176b94ba40db83a3955cc06758735711dea8b710f8f70ebcb9cab10fbdad7e8e5361d160bd0f38a385efeb1befbf1aa68256cf6cda7405e0d0c9486ffbdbdb414569ef9ae5aa3219f054e21ffa99a4ada4efce44020a0c1e909a727a049dbed40f2a6b71c3cf9185955d8a1f46d70ff47d62d1c17ad78d3775b31358efc624c0",
      mask: #"0001020203040506060708090a0a0b",
    },
  ]
}

fn tree_without_apple() {
  mpt.from_root(
    #"d82559b42b60b5bbadef09ffea9296c7d70d3bf5ae13fdc93975ca1d4fc52c2e",
  )
}

// ---------- apricot

fn proof_apricot() {
  [
    Branch {
      skip: 0,
      neighbors: #"f25d1f3e731bff861c0d1b0299dfef46f88165c6b4b39c41e0d7d139ab2d4a15f2f43e90f41eda69546ea927d0dfebcda244213b7ad2b95bd30eefce057979df617f1700cff559c28af9041300667344d44cc39f3d811d5580ec0332ed84a957ff0edb5bcd46eed5d27013c751ad8df9c2a8d73031586403eda51eeddd716fda7bb9c1501ab5663b0544368897a717228e98a6500608df956c1ecc1e6e88e94b07593bf015988ad4f318319cc252200c900b9e55da582a8afd7a4ffa79949fcd6f90ba97b2157d5679504c6e99e07a2c59685ae1f5e1a88304a5d7305aede366a87398cb4efe5dc59dbea4d0d75c0b329b2dc21380f35049f44bcb7baee8cbbd176b94ba40db83a3955cc06758735711dea8b710f8f70ebcb9cab10fbdad7e8e5361d160bd0f38a385efeb1befbf1aa68256cf6cda7405e0d0c9486ffbdbdb414569ef9ae5aa3219f054e21ffa99a4ada4efce44020a0c1e909a727a049dbed40f2a6b71c3cf9185955d8a1f46d70ff47d62d1c17ad78d3775b31358efc624c0",
      mask: #"0001020203040506070708090a0a0b",
    },
    Branch {
      skip: 0,
      neighbors: #"d823212af2c89804301a8b6cac4e23e652734b56e69899e73dbe6f9fe2c3c725fd19d19f2f770ad06c31a90458edd030c5f3760f148804f3992e7789ccba5bd3c7d47f4ec10a674ec0f78631f9d8cfb43846a3b4a1ec1b837b4c047ad681a732064a8065a738f5a3cb8cc255d32ce61658b5c09b2c8dc0965d1d2bf761bcbfa98f69234c7851104edebfb49e7c2c57f1821d6c27752d50b249f6d4d73d356cbf",
      mask: #"000001010102020202030404040404",
    },
  ]
}

fn tree_without_apricot() {
  mpt.from_root(
    #"78946b167e45a2bc4f5810319869a7945fb80045d4b813b6759fe7588822de69",
  )
}

// ---------- banana

fn proof_banana() {
  [
    Branch {
      skip: 0,
      neighbors: #"f25d1f3e731bff861c0d1b0299dfef46f88165c6b4b39c41e0d7d139ab2d4a15f2f43e90f41eda69546ea927d0dfebcda244213b7ad2b95bd30eefce057979df617f1700cff559c28af9041300667344d44cc39f3d811d5580ec0332ed84a957ff0edb5bcd46eed5d27013c751ad8df9c2a8d73031586403eda51eeddd716fda07593bf015988ad4f318319cc252200c900b9e55da582a8afd7a4ffa79949fcd6f90ba97b2157d5679504c6e99e07a2c59685ae1f5e1a88304a5d7305aede366a87398cb4efe5dc59dbea4d0d75c0b329b2dc21380f35049f44bcb7baee8cbbd2c587fdcfef29afb8387e21e97045c4d01228063caa505c792f5a3d789ae28b7176b94ba40db83a3955cc06758735711dea8b710f8f70ebcb9cab10fbdad7e8e5361d160bd0f38a385efeb1befbf1aa68256cf6cda7405e0d0c9486ffbdbdb414569ef9ae5aa3219f054e21ffa99a4ada4efce44020a0c1e909a727a049dbed40f2a6b71c3cf9185955d8a1f46d70ff47d62d1c17ad78d3775b31358efc624c0",
      mask: #"0001020203040506060708090a0a0b",
    },
    Leaf {
      skip: 1,
      neighbor: #"55258d0d33eb0e7f216812f406d2b25e5010157ff0919c86e471cb922ff65fd1",
    },
  ]
}

fn tree_without_banana() {
  mpt.from_root(
    #"aa598881ac4a9117a14a63eb4df846044afd7fd0fad412f9d85c3d454cc87f15",
  )
}

// ---------- blackberry

fn proof_blackberry() {
  [
    Branch {
      skip: 0,
      neighbors: #"f25d1f3e731bff861c0d1b0299dfef46f88165c6b4b39c41e0d7d139ab2d4a15f2f43e90f41eda69546ea927d0dfebcda244213b7ad2b95bd30eefce057979dfff0edb5bcd46eed5d27013c751ad8df9c2a8d73031586403eda51eeddd716fda7bb9c1501ab5663b0544368897a717228e98a6500608df956c1ecc1e6e88e94b07593bf015988ad4f318319cc252200c900b9e55da582a8afd7a4ffa79949fcd6f90ba97b2157d5679504c6e99e07a2c59685ae1f5e1a88304a5d7305aede366a87398cb4efe5dc59dbea4d0d75c0b329b2dc21380f35049f44bcb7baee8cbbd2c587fdcfef29afb8387e21e97045c4d01228063caa505c792f5a3d789ae28b7176b94ba40db83a3955cc06758735711dea8b710f8f70ebcb9cab10fbdad7e8e5361d160bd0f38a385efeb1befbf1aa68256cf6cda7405e0d0c9486ffbdbdb414569ef9ae5aa3219f054e21ffa99a4ada4efce44020a0c1e909a727a049dbed40f2a6b71c3cf9185955d8a1f46d70ff47d62d1c17ad78d3775b31358efc624c0",
      mask: #"0001020203040506060708090a0a0b",
    },
    Leaf {
      skip: 0,
      neighbor: #"3f6ceadf0a21a7a754b9c796a18e83df1da75e59c2f88d09011995ba8dab9059",
    },
  ]
}

fn tree_without_blackberry() {
  mpt.from_root(
    #"ba85eda373365ca249cb4b2f86f753704e916d32b5a5d0fae420a5fcf7ee9c40",
  )
}

// ---------- blueberry

fn proof_blueberry() {
  [
    Branch {
      skip: 0,
      neighbors: #"f25d1f3e731bff861c0d1b0299dfef46f88165c6b4b39c41e0d7d139ab2d4a15f2f43e90f41eda69546ea927d0dfebcda244213b7ad2b95bd30eefce057979df617f1700cff559c28af9041300667344d44cc39f3d811d5580ec0332ed84a957ff0edb5bcd46eed5d27013c751ad8df9c2a8d73031586403eda51eeddd716fda7bb9c1501ab5663b0544368897a717228e98a6500608df956c1ecc1e6e88e94b07593bf015988ad4f318319cc252200c900b9e55da582a8afd7a4ffa79949fcd6f90ba97b2157d5679504c6e99e07a2c59685ae1f5e1a88304a5d7305aede366a87398cb4efe5dc59dbea4d0d75c0b329b2dc21380f35049f44bcb7baee8cbbd2c587fdcfef29afb8387e21e97045c4d01228063caa505c792f5a3d789ae28b7176b94ba40db83a3955cc06758735711dea8b710f8f70ebcb9cab10fbdad7e8e5361d160bd0f38a385efeb1befbf1aa68256cf6cda7405e0d0c9486ffbdbdb414569ef9ae5aa3219f054e21ffa99a4ada4efce44020a0c1e909a727a049dbed4",
      mask: #"0001020203040506070708090a0b0b",
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
    #"d1a84726c1be03d4ea9c6b9c5e227455c91dcbc9a0558dedee1697b3d078c117",
  )
}

// ---------- cherry

fn proof_cherry() {
  [
    Branch {
      skip: 0,
      neighbors: #"f25d1f3e731bff861c0d1b0299dfef46f88165c6b4b39c41e0d7d139ab2d4a15f2f43e90f41eda69546ea927d0dfebcda244213b7ad2b95bd30eefce057979df617f1700cff559c28af9041300667344d44cc39f3d811d5580ec0332ed84a957ff0edb5bcd46eed5d27013c751ad8df9c2a8d73031586403eda51eeddd716fda7bb9c1501ab5663b0544368897a717228e98a6500608df956c1ecc1e6e88e94b6f90ba97b2157d5679504c6e99e07a2c59685ae1f5e1a88304a5d7305aede366a87398cb4efe5dc59dbea4d0d75c0b329b2dc21380f35049f44bcb7baee8cbbd2c587fdcfef29afb8387e21e97045c4d01228063caa505c792f5a3d789ae28b7176b94ba40db83a3955cc06758735711dea8b710f8f70ebcb9cab10fbdad7e8e5361d160bd0f38a385efeb1befbf1aa68256cf6cda7405e0d0c9486ffbdbdb414569ef9ae5aa3219f054e21ffa99a4ada4efce44020a0c1e909a727a049dbed40f2a6b71c3cf9185955d8a1f46d70ff47d62d1c17ad78d3775b31358efc624c0",
      mask: #"0001020203040506060708090a0a0b",
    },
    Branch {
      skip: 0,
      neighbors: #"5ff4152c6c64cfd4fb7e651c29ebcf90c7e114bebaad54cfb70f9de18f8012c0d984adaf73f7dd1aa641ef784b65bf54c86bf838185ca477ab56191d600ec96401a804893a0a8c2ab5fef321fbe1bd6d521afca7bd9f78fe3bc1ccdd148c4ec2",
      mask: #"000000010101010102020202020202",
    },
  ]
}

fn tree_without_cherry() {
  mpt.from_root(
    #"a01ed103f4f0a12dcdd0b06a012454e4e9eaa2e097e18706a954914ee61f2681",
  )
}

// ---------- coconut

fn proof_coconut() {
  [
    Branch {
      skip: 0,
      neighbors: #"f25d1f3e731bff861c0d1b0299dfef46f88165c6b4b39c41e0d7d139ab2d4a15f2f43e90f41eda69546ea927d0dfebcda244213b7ad2b95bd30eefce057979df617f1700cff559c28af9041300667344d44cc39f3d811d5580ec0332ed84a957ff0edb5bcd46eed5d27013c751ad8df9c2a8d73031586403eda51eeddd716fda7bb9c1501ab5663b0544368897a717228e98a6500608df956c1ecc1e6e88e94b07593bf015988ad4f318319cc252200c900b9e55da582a8afd7a4ffa79949fcd6f90ba97b2157d5679504c6e99e07a2c59685ae1f5e1a88304a5d7305aede366a87398cb4efe5dc59dbea4d0d75c0b329b2dc21380f35049f44bcb7baee8cbbd176b94ba40db83a3955cc06758735711dea8b710f8f70ebcb9cab10fbdad7e8e5361d160bd0f38a385efeb1befbf1aa68256cf6cda7405e0d0c9486ffbdbdb414569ef9ae5aa3219f054e21ffa99a4ada4efce44020a0c1e909a727a049dbed40f2a6b71c3cf9185955d8a1f46d70ff47d62d1c17ad78d3775b31358efc624c0",
      mask: #"0001020203040506070708090a0a0b",
    },
    Branch {
      skip: 0,
      neighbors: #"d823212af2c89804301a8b6cac4e23e652734b56e69899e73dbe6f9fe2c3c725fd19d19f2f770ad06c31a90458edd030c5f3760f148804f3992e7789ccba5bd3c7d47f4ec10a674ec0f78631f9d8cfb43846a3b4a1ec1b837b4c047ad681a732386409826e4aa8b71c1de4eeeb2b798f892f08041de9c886150e15039c8cbb51064a8065a738f5a3cb8cc255d32ce61658b5c09b2c8dc0965d1d2bf761bcbfa9",
      mask: #"000001010102020202030405050505",
    },
  ]
}

fn tree_without_coconut() {
  mpt.from_root(
    #"3572772578d4aaa3374b7f21171a7df00d7e85d9053377f56f5d4ee0fdc967cb",
  )
}

// ---------- cranberry

fn proof_cranberry() {
  [
    Branch {
      skip: 0,
      neighbors: #"f2f43e90f41eda69546ea927d0dfebcda244213b7ad2b95bd30eefce057979df617f1700cff559c28af9041300667344d44cc39f3d811d5580ec0332ed84a957ff0edb5bcd46eed5d27013c751ad8df9c2a8d73031586403eda51eeddd716fda7bb9c1501ab5663b0544368897a717228e98a6500608df956c1ecc1e6e88e94b07593bf015988ad4f318319cc252200c900b9e55da582a8afd7a4ffa79949fcd6f90ba97b2157d5679504c6e99e07a2c59685ae1f5e1a88304a5d7305aede366a87398cb4efe5dc59dbea4d0d75c0b329b2dc21380f35049f44bcb7baee8cbbd2c587fdcfef29afb8387e21e97045c4d01228063caa505c792f5a3d789ae28b7176b94ba40db83a3955cc06758735711dea8b710f8f70ebcb9cab10fbdad7e8e5361d160bd0f38a385efeb1befbf1aa68256cf6cda7405e0d0c9486ffbdbdb414569ef9ae5aa3219f054e21ffa99a4ada4efce44020a0c1e909a727a049dbed40f2a6b71c3cf9185955d8a1f46d70ff47d62d1c17ad78d3775b31358efc624c0",
      mask: #"0001010203040506060708090a0a0b",
    },
  ]
}

fn tree_without_cranberry() {
  mpt.from_root(
    #"2126d254272505aba0e83e56a4cfd3221be697f937dbce33fff65dc4e1057852",
  )
}

// ---------- durian

fn proof_durian() {
  [
    Branch {
      skip: 0,
      neighbors: #"f25d1f3e731bff861c0d1b0299dfef46f88165c6b4b39c41e0d7d139ab2d4a15f2f43e90f41eda69546ea927d0dfebcda244213b7ad2b95bd30eefce057979df617f1700cff559c28af9041300667344d44cc39f3d811d5580ec0332ed84a957ff0edb5bcd46eed5d27013c751ad8df9c2a8d73031586403eda51eeddd716fda7bb9c1501ab5663b0544368897a717228e98a6500608df956c1ecc1e6e88e94b07593bf015988ad4f318319cc252200c900b9e55da582a8afd7a4ffa79949fcd6f90ba97b2157d5679504c6e99e07a2c59685ae1f5e1a88304a5d7305aede366a87398cb4efe5dc59dbea4d0d75c0b329b2dc21380f35049f44bcb7baee8cbbd176b94ba40db83a3955cc06758735711dea8b710f8f70ebcb9cab10fbdad7e8e5361d160bd0f38a385efeb1befbf1aa68256cf6cda7405e0d0c9486ffbdbdb414569ef9ae5aa3219f054e21ffa99a4ada4efce44020a0c1e909a727a049dbed40f2a6b71c3cf9185955d8a1f46d70ff47d62d1c17ad78d3775b31358efc624c0",
      mask: #"0001020203040506070708090a0a0b",
    },
    Branch {
      skip: 0,
      neighbors: #"d823212af2c89804301a8b6cac4e23e652734b56e69899e73dbe6f9fe2c3c725c7d47f4ec10a674ec0f78631f9d8cfb43846a3b4a1ec1b837b4c047ad681a732386409826e4aa8b71c1de4eeeb2b798f892f08041de9c886150e15039c8cbb51064a8065a738f5a3cb8cc255d32ce61658b5c09b2c8dc0965d1d2bf761bcbfa98f69234c7851104edebfb49e7c2c57f1821d6c27752d50b249f6d4d73d356cbf",
      mask: #"000001010101010102030404040404",
    },
  ]
}

fn tree_without_durian() {
  mpt.from_root(
    #"b5a840406a961daaa708c28bbf961e01c61fb5e7580c9dcd4903d488d37650f7",
  )
}

// ---------- fig

fn proof_fig() {
  [
    Branch {
      skip: 0,
      neighbors: #"f25d1f3e731bff861c0d1b0299dfef46f88165c6b4b39c41e0d7d139ab2d4a15617f1700cff559c28af9041300667344d44cc39f3d811d5580ec0332ed84a957ff0edb5bcd46eed5d27013c751ad8df9c2a8d73031586403eda51eeddd716fda7bb9c1501ab5663b0544368897a717228e98a6500608df956c1ecc1e6e88e94b07593bf015988ad4f318319cc252200c900b9e55da582a8afd7a4ffa79949fcd6f90ba97b2157d5679504c6e99e07a2c59685ae1f5e1a88304a5d7305aede366a87398cb4efe5dc59dbea4d0d75c0b329b2dc21380f35049f44bcb7baee8cbbd2c587fdcfef29afb8387e21e97045c4d01228063caa505c792f5a3d789ae28b7176b94ba40db83a3955cc06758735711dea8b710f8f70ebcb9cab10fbdad7e8e5361d160bd0f38a385efeb1befbf1aa68256cf6cda7405e0d0c9486ffbdbdb414569ef9ae5aa3219f054e21ffa99a4ada4efce44020a0c1e909a727a049dbed40f2a6b71c3cf9185955d8a1f46d70ff47d62d1c17ad78d3775b31358efc624c0",
      mask: #"0001010203040506060708090a0a0b",
    },
    Leaf {
      skip: 3,
      neighbor: #"138bc45c2fcafeb234075bf16851f58c4d5549c2b9e915099950ebf299b6769a",
    },
  ]
}

fn tree_without_fig() {
  mpt.from_root(
    #"66b138a3fcba4ea692ed41847d14c27838e36f4436450c3ceab8f9bd85f0446f",
  )
}

// ---------- grape

fn proof_grape() {
  [
    Branch {
      skip: 0,
      neighbors: #"f25d1f3e731bff861c0d1b0299dfef46f88165c6b4b39c41e0d7d139ab2d4a15f2f43e90f41eda69546ea927d0dfebcda244213b7ad2b95bd30eefce057979df617f1700cff559c28af9041300667344d44cc39f3d811d5580ec0332ed84a957ff0edb5bcd46eed5d27013c751ad8df9c2a8d73031586403eda51eeddd716fda7bb9c1501ab5663b0544368897a717228e98a6500608df956c1ecc1e6e88e94b07593bf015988ad4f318319cc252200c900b9e55da582a8afd7a4ffa79949fcd6f90ba97b2157d5679504c6e99e07a2c59685ae1f5e1a88304a5d7305aede366a87398cb4efe5dc59dbea4d0d75c0b329b2dc21380f35049f44bcb7baee8cbbd2c587fdcfef29afb8387e21e97045c4d01228063caa505c792f5a3d789ae28b7176b94ba40db83a3955cc06758735711dea8b710f8f70ebcb9cab10fbdad7e8e5361d160bd0f38a385efeb1befbf1aa68256cf6cda7405e0d0c9486ffbdbdb410f2a6b71c3cf9185955d8a1f46d70ff47d62d1c17ad78d3775b31358efc624c0",
      mask: #"0001020203040506070708090a0b0b",
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
    #"b80a8d8e551b0e5b01824776ab1a4afe67c1fe24f04daa144721ae50942d8b4d",
  )
}

// ---------- grapefruit

fn proof_grapefruit() {
  [
    Branch {
      skip: 0,
      neighbors: #"f25d1f3e731bff861c0d1b0299dfef46f88165c6b4b39c41e0d7d139ab2d4a15f2f43e90f41eda69546ea927d0dfebcda244213b7ad2b95bd30eefce057979dfff0edb5bcd46eed5d27013c751ad8df9c2a8d73031586403eda51eeddd716fda7bb9c1501ab5663b0544368897a717228e98a6500608df956c1ecc1e6e88e94b07593bf015988ad4f318319cc252200c900b9e55da582a8afd7a4ffa79949fcd6f90ba97b2157d5679504c6e99e07a2c59685ae1f5e1a88304a5d7305aede366a87398cb4efe5dc59dbea4d0d75c0b329b2dc21380f35049f44bcb7baee8cbbd2c587fdcfef29afb8387e21e97045c4d01228063caa505c792f5a3d789ae28b7176b94ba40db83a3955cc06758735711dea8b710f8f70ebcb9cab10fbdad7e8e5361d160bd0f38a385efeb1befbf1aa68256cf6cda7405e0d0c9486ffbdbdb414569ef9ae5aa3219f054e21ffa99a4ada4efce44020a0c1e909a727a049dbed40f2a6b71c3cf9185955d8a1f46d70ff47d62d1c17ad78d3775b31358efc624c0",
      mask: #"0001020203040506060708090a0a0b",
    },
    Leaf {
      skip: 0,
      neighbor: #"3378b5c960257ffe7c3e86d00563739bdf7db730e10732f6b943a4c1802fd05e",
    },
  ]
}

fn tree_without_grapefruit() {
  mpt.from_root(
    #"73c56ee70fabc9d6ccadda1b63ae3cb0ec5b47fcbf957e97549ce58ec40e3e41",
  )
}

// ---------- guava

fn proof_guava() {
  [
    Branch {
      skip: 0,
      neighbors: #"f25d1f3e731bff861c0d1b0299dfef46f88165c6b4b39c41e0d7d139ab2d4a15f2f43e90f41eda69546ea927d0dfebcda244213b7ad2b95bd30eefce057979df617f1700cff559c28af9041300667344d44cc39f3d811d5580ec0332ed84a957ff0edb5bcd46eed5d27013c751ad8df9c2a8d73031586403eda51eeddd716fda7bb9c1501ab5663b0544368897a717228e98a6500608df956c1ecc1e6e88e94b6f90ba97b2157d5679504c6e99e07a2c59685ae1f5e1a88304a5d7305aede366a87398cb4efe5dc59dbea4d0d75c0b329b2dc21380f35049f44bcb7baee8cbbd2c587fdcfef29afb8387e21e97045c4d01228063caa505c792f5a3d789ae28b7176b94ba40db83a3955cc06758735711dea8b710f8f70ebcb9cab10fbdad7e8e5361d160bd0f38a385efeb1befbf1aa68256cf6cda7405e0d0c9486ffbdbdb414569ef9ae5aa3219f054e21ffa99a4ada4efce44020a0c1e909a727a049dbed40f2a6b71c3cf9185955d8a1f46d70ff47d62d1c17ad78d3775b31358efc624c0",
      mask: #"0001020203040506060708090a0a0b",
    },
    Branch {
      skip: 0,
      neighbors: #"5ff4152c6c64cfd4fb7e651c29ebcf90c7e114bebaad54cfb70f9de18f8012c0e124d5f9f4b661711e227c3641ba55688209fbe2436556451740fc5029354c9e01a804893a0a8c2ab5fef321fbe1bd6d521afca7bd9f78fe3bc1ccdd148c4ec2",
      mask: #"000000010101010101010202020202",
    },
  ]
}

fn tree_without_guava() {
  mpt.from_root(
    #"75dcb58dae3f62b342096d7e3bd6d32f51038d1c6fd80d08b89b4cba69ac54a6",
  )
}

// ---------- kiwi

fn proof_kiwi() {
  [
    Branch {
      skip: 0,
      neighbors: #"f25d1f3e731bff861c0d1b0299dfef46f88165c6b4b39c41e0d7d139ab2d4a15f2f43e90f41eda69546ea927d0dfebcda244213b7ad2b95bd30eefce057979df617f1700cff559c28af9041300667344d44cc39f3d811d5580ec0332ed84a957ff0edb5bcd46eed5d27013c751ad8df9c2a8d73031586403eda51eeddd716fda7bb9c1501ab5663b0544368897a717228e98a6500608df956c1ecc1e6e88e94b07593bf015988ad4f318319cc252200c900b9e55da582a8afd7a4ffa79949fcd6f90ba97b2157d5679504c6e99e07a2c59685ae1f5e1a88304a5d7305aede366a87398cb4efe5dc59dbea4d0d75c0b329b2dc21380f35049f44bcb7baee8cbbd2c587fdcfef29afb8387e21e97045c4d01228063caa505c792f5a3d789ae28b7176b94ba40db83a3955cc06758735711dea8b710f8f70ebcb9cab10fbdad7e8e5361d160bd0f38a385efeb1befbf1aa68256cf6cda7405e0d0c9486ffbdbdb410f2a6b71c3cf9185955d8a1f46d70ff47d62d1c17ad78d3775b31358efc624c0",
      mask: #"0001020203040506070708090a0b0b",
    },
    Fork {
      skip: 0,
      neighbor: Neighbor {
        nibble: 3,
        value: #"0f4ee8fa98978797ff859639cbc8de0d4ce31bdc18cb68c1974b1b1c9e653fc3",
        prefix: #"0805",
      },
    },
  ]
}

fn tree_without_kiwi() {
  mpt.from_root(
    #"bc80cf03a0968107f3ae445811a6658ec7e1b1d69798bab4b9098c66f20ca477",
  )
}

// ---------- kumquat

fn proof_kumquat() {
  [
    Branch {
      skip: 0,
      neighbors: #"f25d1f3e731bff861c0d1b0299dfef46f88165c6b4b39c41e0d7d139ab2d4a15f2f43e90f41eda69546ea927d0dfebcda244213b7ad2b95bd30eefce057979df617f1700cff559c28af9041300667344d44cc39f3d811d5580ec0332ed84a957ff0edb5bcd46eed5d27013c751ad8df9c2a8d73031586403eda51eeddd716fda7bb9c1501ab5663b0544368897a717228e98a6500608df956c1ecc1e6e88e94b07593bf015988ad4f318319cc252200c900b9e55da582a8afd7a4ffa79949fcd6f90ba97b2157d5679504c6e99e07a2c59685ae1f5e1a88304a5d7305aede366a87398cb4efe5dc59dbea4d0d75c0b329b2dc21380f35049f44bcb7baee8cbbd176b94ba40db83a3955cc06758735711dea8b710f8f70ebcb9cab10fbdad7e8e5361d160bd0f38a385efeb1befbf1aa68256cf6cda7405e0d0c9486ffbdbdb414569ef9ae5aa3219f054e21ffa99a4ada4efce44020a0c1e909a727a049dbed40f2a6b71c3cf9185955d8a1f46d70ff47d62d1c17ad78d3775b31358efc624c0",
      mask: #"0001020203040506070708090a0a0b",
    },
    Branch {
      skip: 0,
      neighbors: #"d823212af2c89804301a8b6cac4e23e652734b56e69899e73dbe6f9fe2c3c725fd19d19f2f770ad06c31a90458edd030c5f3760f148804f3992e7789ccba5bd3c7d47f4ec10a674ec0f78631f9d8cfb43846a3b4a1ec1b837b4c047ad681a732386409826e4aa8b71c1de4eeeb2b798f892f08041de9c886150e15039c8cbb518f69234c7851104edebfb49e7c2c57f1821d6c27752d50b249f6d4d73d356cbf",
      mask: #"000001010102020202030404040404",
    },
  ]
}

fn tree_without_kumquat() {
  mpt.from_root(
    #"1bc3ec48ea558d0d58693cdd6b68c045c55dbc6cb4b11fb49be4528e8a2ea1fd",
  )
}

// ---------- lemon

fn proof_lemon() {
  [
    Branch {
      skip: 0,
      neighbors: #"f25d1f3e731bff861c0d1b0299dfef46f88165c6b4b39c41e0d7d139ab2d4a15f2f43e90f41eda69546ea927d0dfebcda244213b7ad2b95bd30eefce057979df617f1700cff559c28af9041300667344d44cc39f3d811d5580ec0332ed84a957ff0edb5bcd46eed5d27013c751ad8df9c2a8d73031586403eda51eeddd716fda7bb9c1501ab5663b0544368897a717228e98a6500608df956c1ecc1e6e88e94b07593bf015988ad4f318319cc252200c900b9e55da582a8afd7a4ffa79949fcd6f90ba97b2157d5679504c6e99e07a2c59685ae1f5e1a88304a5d7305aede366a87398cb4efe5dc59dbea4d0d75c0b329b2dc21380f35049f44bcb7baee8cbbd2c587fdcfef29afb8387e21e97045c4d01228063caa505c792f5a3d789ae28b7176b94ba40db83a3955cc06758735711dea8b710f8f70ebcb9cab10fbdad7e8e5361d160bd0f38a385efeb1befbf1aa68256cf6cda7405e0d0c9486ffbdbdb410f2a6b71c3cf9185955d8a1f46d70ff47d62d1c17ad78d3775b31358efc624c0",
      mask: #"0001020203040506070708090a0b0b",
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
    #"36cea9906d47b7e6966ea79bd973c0c9a095822c45ec71caf11f051fdd4452b6",
  )
}

// ---------- lime

fn proof_lime() {
  [
    Branch {
      skip: 0,
      neighbors: #"f25d1f3e731bff861c0d1b0299dfef46f88165c6b4b39c41e0d7d139ab2d4a15f2f43e90f41eda69546ea927d0dfebcda244213b7ad2b95bd30eefce057979df617f1700cff559c28af9041300667344d44cc39f3d811d5580ec0332ed84a957ff0edb5bcd46eed5d27013c751ad8df9c2a8d73031586403eda51eeddd716fda7bb9c1501ab5663b0544368897a717228e98a6500608df956c1ecc1e6e88e94b6f90ba97b2157d5679504c6e99e07a2c59685ae1f5e1a88304a5d7305aede366a87398cb4efe5dc59dbea4d0d75c0b329b2dc21380f35049f44bcb7baee8cbbd2c587fdcfef29afb8387e21e97045c4d01228063caa505c792f5a3d789ae28b7176b94ba40db83a3955cc06758735711dea8b710f8f70ebcb9cab10fbdad7e8e5361d160bd0f38a385efeb1befbf1aa68256cf6cda7405e0d0c9486ffbdbdb414569ef9ae5aa3219f054e21ffa99a4ada4efce44020a0c1e909a727a049dbed40f2a6b71c3cf9185955d8a1f46d70ff47d62d1c17ad78d3775b31358efc624c0",
      mask: #"0001020203040506060708090a0a0b",
    },
    Branch {
      skip: 0,
      neighbors: #"5ff4152c6c64cfd4fb7e651c29ebcf90c7e114bebaad54cfb70f9de18f8012c0d984adaf73f7dd1aa641ef784b65bf54c86bf838185ca477ab56191d600ec964e124d5f9f4b661711e227c3641ba55688209fbe2436556451740fc5029354c9e",
      mask: #"000000010101010102020203030303",
    },
  ]
}

fn tree_without_lime() {
  mpt.from_root(
    #"2b2d1c783f6912a8239dc1cde9f285d91c9b73c2f34c7afadb054cdfa6de0b73",
  )
}

// ---------- mango

fn proof_mango() {
  [
    Branch {
      skip: 0,
      neighbors: #"f25d1f3e731bff861c0d1b0299dfef46f88165c6b4b39c41e0d7d139ab2d4a15f2f43e90f41eda69546ea927d0dfebcda244213b7ad2b95bd30eefce057979df617f1700cff559c28af9041300667344d44cc39f3d811d5580ec0332ed84a957ff0edb5bcd46eed5d27013c751ad8df9c2a8d73031586403eda51eeddd716fda7bb9c1501ab5663b0544368897a717228e98a6500608df956c1ecc1e6e88e94b07593bf015988ad4f318319cc252200c900b9e55da582a8afd7a4ffa79949fcd6f90ba97b2157d5679504c6e99e07a2c59685ae1f5e1a88304a5d7305aede3662c587fdcfef29afb8387e21e97045c4d01228063caa505c792f5a3d789ae28b7176b94ba40db83a3955cc06758735711dea8b710f8f70ebcb9cab10fbdad7e8e5361d160bd0f38a385efeb1befbf1aa68256cf6cda7405e0d0c9486ffbdbdb414569ef9ae5aa3219f054e21ffa99a4ada4efce44020a0c1e909a727a049dbed40f2a6b71c3cf9185955d8a1f46d70ff47d62d1c17ad78d3775b31358efc624c0",
      mask: #"0001020203040506070708090a0a0b",
    },
  ]
}

fn tree_without_mango() {
  mpt.from_root(
    #"46d8ea17829b0d50693dab9f97be8aeae2ca54a0aedc23c3ede45ee2a880de8b",
  )
}

// ---------- orange

fn proof_orange() {
  [
    Branch {
      skip: 0,
      neighbors: #"f25d1f3e731bff861c0d1b0299dfef46f88165c6b4b39c41e0d7d139ab2d4a15617f1700cff559c28af9041300667344d44cc39f3d811d5580ec0332ed84a957ff0edb5bcd46eed5d27013c751ad8df9c2a8d73031586403eda51eeddd716fda7bb9c1501ab5663b0544368897a717228e98a6500608df956c1ecc1e6e88e94b07593bf015988ad4f318319cc252200c900b9e55da582a8afd7a4ffa79949fcd6f90ba97b2157d5679504c6e99e07a2c59685ae1f5e1a88304a5d7305aede366a87398cb4efe5dc59dbea4d0d75c0b329b2dc21380f35049f44bcb7baee8cbbd2c587fdcfef29afb8387e21e97045c4d01228063caa505c792f5a3d789ae28b7176b94ba40db83a3955cc06758735711dea8b710f8f70ebcb9cab10fbdad7e8e5361d160bd0f38a385efeb1befbf1aa68256cf6cda7405e0d0c9486ffbdbdb414569ef9ae5aa3219f054e21ffa99a4ada4efce44020a0c1e909a727a049dbed40f2a6b71c3cf9185955d8a1f46d70ff47d62d1c17ad78d3775b31358efc624c0",
      mask: #"0001010203040506060708090a0a0b",
    },
    Leaf {
      skip: 3,
      neighbor: #"138b407b7cc00a52955272bfd7d66b47c8965066bb6ff93b51ad4f9b34e2c445",
    },
  ]
}

fn tree_without_orange() {
  mpt.from_root(
    #"dcf276be431db47057540b06ed74cd2e92cbd79fd4a9b0229f19dbb1f2f75ede",
  )
}

// ---------- papaya

fn proof_papaya() {
  [
    Branch {
      skip: 0,
      neighbors: #"f25d1f3e731bff861c0d1b0299dfef46f88165c6b4b39c41e0d7d139ab2d4a15f2f43e90f41eda69546ea927d0dfebcda244213b7ad2b95bd30eefce057979df617f1700cff559c28af9041300667344d44cc39f3d811d5580ec0332ed84a957ff0edb5bcd46eed5d27013c751ad8df9c2a8d73031586403eda51eeddd716fda7bb9c1501ab5663b0544368897a717228e98a6500608df956c1ecc1e6e88e94b07593bf015988ad4f318319cc252200c900b9e55da582a8afd7a4ffa79949fcd6f90ba97b2157d5679504c6e99e07a2c59685ae1f5e1a88304a5d7305aede366a87398cb4efe5dc59dbea4d0d75c0b329b2dc21380f35049f44bcb7baee8cbbd176b94ba40db83a3955cc06758735711dea8b710f8f70ebcb9cab10fbdad7e8e5361d160bd0f38a385efeb1befbf1aa68256cf6cda7405e0d0c9486ffbdbdb414569ef9ae5aa3219f054e21ffa99a4ada4efce44020a0c1e909a727a049dbed40f2a6b71c3cf9185955d8a1f46d70ff47d62d1c17ad78d3775b31358efc624c0",
      mask: #"0001020203040506070708090a0a0b",
    },
    Branch {
      skip: 0,
      neighbors: #"d823212af2c89804301a8b6cac4e23e652734b56e69899e73dbe6f9fe2c3c725fd19d19f2f770ad06c31a90458edd030c5f3760f148804f3992e7789ccba5bd3386409826e4aa8b71c1de4eeeb2b798f892f08041de9c886150e15039c8cbb51064a8065a738f5a3cb8cc255d32ce61658b5c09b2c8dc0965d1d2bf761bcbfa98f69234c7851104edebfb49e7c2c57f1821d6c27752d50b249f6d4d73d356cbf",
      mask: #"000001010102020202030404040404",
    },
  ]
}

fn tree_without_papaya() {
  mpt.from_root(
    #"50ad2c6741a9c141a57b351638de709355bb8ab7834c7f8dedc74b54ddb4d412",
  )
}

// ---------- passionfruit

fn proof_passionfruit() {
  [
    Branch {
      skip: 0,
      neighbors: #"f25d1f3e731bff861c0d1b0299dfef46f88165c6b4b39c41e0d7d139ab2d4a15f2f43e90f41eda69546ea927d0dfebcda244213b7ad2b95bd30eefce057979df617f1700cff559c28af9041300667344d44cc39f3d811d5580ec0332ed84a957ff0edb5bcd46eed5d27013c751ad8df9c2a8d73031586403eda51eeddd716fda7bb9c1501ab5663b0544368897a717228e98a6500608df956c1ecc1e6e88e94b07593bf015988ad4f318319cc252200c900b9e55da582a8afd7a4ffa79949fcd6f90ba97b2157d5679504c6e99e07a2c59685ae1f5e1a88304a5d7305aede366a87398cb4efe5dc59dbea4d0d75c0b329b2dc21380f35049f44bcb7baee8cbbd2c587fdcfef29afb8387e21e97045c4d01228063caa505c792f5a3d789ae28b7176b94ba40db83a3955cc06758735711dea8b710f8f70ebcb9cab10fbdad7e8e5361d160bd0f38a385efeb1befbf1aa68256cf6cda7405e0d0c9486ffbdbdb414569ef9ae5aa3219f054e21ffa99a4ada4efce44020a0c1e909a727a049dbed4",
      mask: #"0001020203040506070708090a0b0b",
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
    #"62b3f02e62b8972d2d70f57e7ea4a82805d1f1bab34d4d0870649116eea1b662",
  )
}

// ---------- peach

fn proof_peach() {
  [
    Branch {
      skip: 0,
      neighbors: #"f25d1f3e731bff861c0d1b0299dfef46f88165c6b4b39c41e0d7d139ab2d4a15f2f43e90f41eda69546ea927d0dfebcda244213b7ad2b95bd30eefce057979df617f1700cff559c28af9041300667344d44cc39f3d811d5580ec0332ed84a957ff0edb5bcd46eed5d27013c751ad8df9c2a8d73031586403eda51eeddd716fda7bb9c1501ab5663b0544368897a717228e98a6500608df956c1ecc1e6e88e94b07593bf015988ad4f318319cc252200c900b9e55da582a8afd7a4ffa79949fcd6f90ba97b2157d5679504c6e99e07a2c59685ae1f5e1a88304a5d7305aede366a87398cb4efe5dc59dbea4d0d75c0b329b2dc21380f35049f44bcb7baee8cbbd2c587fdcfef29afb8387e21e97045c4d01228063caa505c792f5a3d789ae28b7176b94ba40db83a3955cc06758735711dea8b710f8f70ebcb9cab10fbdad7e8e4569ef9ae5aa3219f054e21ffa99a4ada4efce44020a0c1e909a727a049dbed40f2a6b71c3cf9185955d8a1f46d70ff47d62d1c17ad78d3775b31358efc624c0",
      mask: #"0001020203040506070708090a0a0b",
    },
  ]
}

fn tree_without_peach() {
  mpt.from_root(
    #"63e2a1de17c328c63572ad91e47f6b885b8da96c21f5480db049a72cb7c39bab",
  )
}

// ---------- pear

fn proof_pear() {
  [
    Branch {
      skip: 0,
      neighbors: #"f25d1f3e731bff861c0d1b0299dfef46f88165c6b4b39c41e0d7d139ab2d4a15f2f43e90f41eda69546ea927d0dfebcda244213b7ad2b95bd30eefce057979df617f1700cff559c28af9041300667344d44cc39f3d811d5580ec0332ed84a957ff0edb5bcd46eed5d27013c751ad8df9c2a8d73031586403eda51eeddd716fda07593bf015988ad4f318319cc252200c900b9e55da582a8afd7a4ffa79949fcd6f90ba97b2157d5679504c6e99e07a2c59685ae1f5e1a88304a5d7305aede366a87398cb4efe5dc59dbea4d0d75c0b329b2dc21380f35049f44bcb7baee8cbbd2c587fdcfef29afb8387e21e97045c4d01228063caa505c792f5a3d789ae28b7176b94ba40db83a3955cc06758735711dea8b710f8f70ebcb9cab10fbdad7e8e5361d160bd0f38a385efeb1befbf1aa68256cf6cda7405e0d0c9486ffbdbdb414569ef9ae5aa3219f054e21ffa99a4ada4efce44020a0c1e909a727a049dbed40f2a6b71c3cf9185955d8a1f46d70ff47d62d1c17ad78d3775b31358efc624c0",
      mask: #"0001020203040506060708090a0a0b",
    },
    Leaf {
      skip: 1,
      neighbor: #"55d5551e8e1323d35afe53cf8698867c9de9a408e97ee968dc8414d527cc719c",
    },
  ]
}

fn tree_without_pear() {
  mpt.from_root(
    #"430623852c766b6269003361948825ec5caacda978d443cdd8bc7e85af34d219",
  )
}

// ---------- pineapple

fn proof_pineapple() {
  [
    Branch {
      skip: 0,
      neighbors: #"f25d1f3e731bff861c0d1b0299dfef46f88165c6b4b39c41e0d7d139ab2d4a15f2f43e90f41eda69546ea927d0dfebcda244213b7ad2b95bd30eefce057979df617f1700cff559c28af9041300667344d44cc39f3d811d5580ec0332ed84a957ff0edb5bcd46eed5d27013c751ad8df9c2a8d73031586403eda51eeddd716fda7bb9c1501ab5663b0544368897a717228e98a6500608df956c1ecc1e6e88e94b07593bf015988ad4f318319cc252200c900b9e55da582a8afd7a4ffa79949fcd6f90ba97b2157d5679504c6e99e07a2c59685ae1f5e1a88304a5d7305aede366a87398cb4efe5dc59dbea4d0d75c0b329b2dc21380f35049f44bcb7baee8cbbd176b94ba40db83a3955cc06758735711dea8b710f8f70ebcb9cab10fbdad7e8e5361d160bd0f38a385efeb1befbf1aa68256cf6cda7405e0d0c9486ffbdbdb414569ef9ae5aa3219f054e21ffa99a4ada4efce44020a0c1e909a727a049dbed40f2a6b71c3cf9185955d8a1f46d70ff47d62d1c17ad78d3775b31358efc624c0",
      mask: #"0001020203040506070708090a0a0b",
    },
    Branch {
      skip: 0,
      neighbors: #"fd19d19f2f770ad06c31a90458edd030c5f3760f148804f3992e7789ccba5bd3c7d47f4ec10a674ec0f78631f9d8cfb43846a3b4a1ec1b837b4c047ad681a732386409826e4aa8b71c1de4eeeb2b798f892f08041de9c886150e15039c8cbb51064a8065a738f5a3cb8cc255d32ce61658b5c09b2c8dc0965d1d2bf761bcbfa98f69234c7851104edebfb49e7c2c57f1821d6c27752d50b249f6d4d73d356cbf",
      mask: #"000000000101010102030404040404",
    },
  ]
}

fn tree_without_pineapple() {
  mpt.from_root(
    #"a7030f9555ec27042e4710967d3c8b5a66a2c96e7cf4042698bbaea5064b6a38",
  )
}

// ---------- plum

fn proof_plum() {
  [
    Branch {
      skip: 0,
      neighbors: #"f25d1f3e731bff861c0d1b0299dfef46f88165c6b4b39c41e0d7d139ab2d4a15f2f43e90f41eda69546ea927d0dfebcda244213b7ad2b95bd30eefce057979df617f1700cff559c28af9041300667344d44cc39f3d811d5580ec0332ed84a957ff0edb5bcd46eed5d27013c751ad8df9c2a8d73031586403eda51eeddd716fda7bb9c1501ab5663b0544368897a717228e98a6500608df956c1ecc1e6e88e94b6f90ba97b2157d5679504c6e99e07a2c59685ae1f5e1a88304a5d7305aede366a87398cb4efe5dc59dbea4d0d75c0b329b2dc21380f35049f44bcb7baee8cbbd2c587fdcfef29afb8387e21e97045c4d01228063caa505c792f5a3d789ae28b7176b94ba40db83a3955cc06758735711dea8b710f8f70ebcb9cab10fbdad7e8e5361d160bd0f38a385efeb1befbf1aa68256cf6cda7405e0d0c9486ffbdbdb414569ef9ae5aa3219f054e21ffa99a4ada4efce44020a0c1e909a727a049dbed40f2a6b71c3cf9185955d8a1f46d70ff47d62d1c17ad78d3775b31358efc624c0",
      mask: #"0001020203040506060708090a0a0b",
    },
    Branch {
      skip: 0,
      neighbors: #"d984adaf73f7dd1aa641ef784b65bf54c86bf838185ca477ab56191d600ec964e124d5f9f4b661711e227c3641ba55688209fbe2436556451740fc5029354c9e01a804893a0a8c2ab5fef321fbe1bd6d521afca7bd9f78fe3bc1ccdd148c4ec2",
      mask: #"000000000000000101010202020202",
    },
  ]
}

fn tree_without_plum() {
  mpt.from_root(
    #"7b51a04d8cc3a6833f075d2a7b7d13561708e1092b62c68d07e81d95be9d95df",
  )
}

// ---------- pomegranate

fn proof_pomegranate() {
  [
    Branch {
      skip: 0,
      neighbors: #"f25d1f3e731bff861c0d1b0299dfef46f88165c6b4b39c41e0d7d139ab2d4a15f2f43e90f41eda69546ea927d0dfebcda244213b7ad2b95bd30eefce057979df617f1700cff559c28af9041300667344d44cc39f3d811d5580ec0332ed84a957ff0edb5bcd46eed5d27013c751ad8df9c2a8d73031586403eda51eeddd716fda7bb9c1501ab5663b0544368897a717228e98a6500608df956c1ecc1e6e88e94b07593bf015988ad4f318319cc252200c900b9e55da582a8afd7a4ffa79949fcd6f90ba97b2157d5679504c6e99e07a2c59685ae1f5e1a88304a5d7305aede366a87398cb4efe5dc59dbea4d0d75c0b329b2dc21380f35049f44bcb7baee8cbbd2c587fdcfef29afb8387e21e97045c4d01228063caa505c792f5a3d789ae28b7176b94ba40db83a3955cc06758735711dea8b710f8f70ebcb9cab10fbdad7e8e5361d160bd0f38a385efeb1befbf1aa68256cf6cda7405e0d0c9486ffbdbdb414569ef9ae5aa3219f054e21ffa99a4ada4efce44020a0c1e909a727a049dbed4",
      mask: #"0001020203040506070708090a0b0b",
    },
    Leaf {
      skip: 0,
      neighbor: #"f77af1bd3cda91f714144491553c8e33de144689eaacb75e080808c97b5bce06",
    },
    Fork {
      skip: 0,
      neighbor: Neighbor {
        nibble: 7,
        value: #"dacb64d142decbb6ec7828ccdfff185b9ac23bad910ce232b88dca3b00285aca",
        prefix: #"04",
      },
    },
  ]
}

fn tree_without_pomegranate() {
  mpt.from_root(
    #"5f27831579ca558c89991c3f49c4ca4321380e89b1376530833343266c73b49c",
  )
}

// ---------- raspberry

fn proof_raspberry() {
  [
    Branch {
      skip: 0,
      neighbors: #"f25d1f3e731bff861c0d1b0299dfef46f88165c6b4b39c41e0d7d139ab2d4a15f2f43e90f41eda69546ea927d0dfebcda244213b7ad2b95bd30eefce057979df617f1700cff559c28af9041300667344d44cc39f3d811d5580ec0332ed84a957ff0edb5bcd46eed5d27013c751ad8df9c2a8d73031586403eda51eeddd716fda7bb9c1501ab5663b0544368897a717228e98a6500608df956c1ecc1e6e88e94b07593bf015988ad4f318319cc252200c900b9e55da582a8afd7a4ffa79949fcd6f90ba97b2157d5679504c6e99e07a2c59685ae1f5e1a88304a5d7305aede366a87398cb4efe5dc59dbea4d0d75c0b329b2dc21380f35049f44bcb7baee8cbbd2c587fdcfef29afb8387e21e97045c4d01228063caa505c792f5a3d789ae28b75361d160bd0f38a385efeb1befbf1aa68256cf6cda7405e0d0c9486ffbdbdb414569ef9ae5aa3219f054e21ffa99a4ada4efce44020a0c1e909a727a049dbed40f2a6b71c3cf9185955d8a1f46d70ff47d62d1c17ad78d3775b31358efc624c0",
      mask: #"0001020203040506070708090a0a0b",
    },
    Leaf {
      skip: 0,
      neighbor: #"bd0f991572aef335da6ea31786aa8f147f5a4a1d374251548b2d03c008274595",
    },
  ]
}

fn tree_without_raspberry() {
  mpt.from_root(
    #"be6b8e5931704fe765558a232e7a0ce9eb867549493bdb214588987f8dbf3eb5",
  )
}

// ---------- strawberry

fn proof_strawberry() {
  [
    Branch {
      skip: 0,
      neighbors: #"f25d1f3e731bff861c0d1b0299dfef46f88165c6b4b39c41e0d7d139ab2d4a15f2f43e90f41eda69546ea927d0dfebcda244213b7ad2b95bd30eefce057979df617f1700cff559c28af9041300667344d44cc39f3d811d5580ec0332ed84a9577bb9c1501ab5663b0544368897a717228e98a6500608df956c1ecc1e6e88e94b07593bf015988ad4f318319cc252200c900b9e55da582a8afd7a4ffa79949fcd6f90ba97b2157d5679504c6e99e07a2c59685ae1f5e1a88304a5d7305aede366a87398cb4efe5dc59dbea4d0d75c0b329b2dc21380f35049f44bcb7baee8cbbd2c587fdcfef29afb8387e21e97045c4d01228063caa505c792f5a3d789ae28b7176b94ba40db83a3955cc06758735711dea8b710f8f70ebcb9cab10fbdad7e8e5361d160bd0f38a385efeb1befbf1aa68256cf6cda7405e0d0c9486ffbdbdb414569ef9ae5aa3219f054e21ffa99a4ada4efce44020a0c1e909a727a049dbed40f2a6b71c3cf9185955d8a1f46d70ff47d62d1c17ad78d3775b31358efc624c0",
      mask: #"0001020203040506060708090a0a0b",
    },
  ]
}

fn tree_without_strawberry() {
  mpt.from_root(
    #"5e40c3267c305b3f88c207d57a014686228899a9253b1a122f1f9271acbd80f2",
  )
}

// ---------- yuzu

fn proof_yuzu() {
  [
    Branch {
      skip: 0,
      neighbors: #"f25d1f3e731bff861c0d1b0299dfef46f88165c6b4b39c41e0d7d139ab2d4a15f2f43e90f41eda69546ea927d0dfebcda244213b7ad2b95bd30eefce057979df617f1700cff559c28af9041300667344d44cc39f3d811d5580ec0332ed84a957ff0edb5bcd46eed5d27013c751ad8df9c2a8d73031586403eda51eeddd716fda7bb9c1501ab5663b0544368897a717228e98a6500608df956c1ecc1e6e88e94b07593bf015988ad4f318319cc252200c900b9e55da582a8afd7a4ffa79949fcd6f90ba97b2157d5679504c6e99e07a2c59685ae1f5e1a88304a5d7305aede366a87398cb4efe5dc59dbea4d0d75c0b329b2dc21380f35049f44bcb7baee8cbbd2c587fdcfef29afb8387e21e97045c4d01228063caa505c792f5a3d789ae28b75361d160bd0f38a385efeb1befbf1aa68256cf6cda7405e0d0c9486ffbdbdb414569ef9ae5aa3219f054e21ffa99a4ada4efce44020a0c1e909a727a049dbed40f2a6b71c3cf9185955d8a1f46d70ff47d62d1c17ad78d3775b31358efc624c0",
      mask: #"0001020203040506070708090a0a0b",
    },
    Leaf {
      skip: 0,
      neighbor: #"ba830de32503d8941eee8b8689332e8903841663d99c4442434858b1a147da75",
    },
  ]
}

fn tree_without_yuzu() {
  mpt.from_root(
    #"13afc7a2dcc29e971f6b072e1ab55389dc82baf8af4f02e06356ea2262753cd0",
  )
}

// ---------- watermelon

fn proof_watermelon() {
  [
    Branch {
      skip: 0,
      neighbors: #"f25d1f3e731bff861c0d1b0299dfef46f88165c6b4b39c41e0d7d139ab2d4a15f2f43e90f41eda69546ea927d0dfebcda244213b7ad2b95bd30eefce057979df617f1700cff559c28af9041300667344d44cc39f3d811d5580ec0332ed84a957ff0edb5bcd46eed5d27013c751ad8df9c2a8d73031586403eda51eeddd716fda7bb9c1501ab5663b0544368897a717228e98a6500608df956c1ecc1e6e88e94b07593bf015988ad4f318319cc252200c900b9e55da582a8afd7a4ffa79949fcd6f90ba97b2157d5679504c6e99e07a2c59685ae1f5e1a88304a5d7305aede366a87398cb4efe5dc59dbea4d0d75c0b329b2dc21380f35049f44bcb7baee8cbbd2c587fdcfef29afb8387e21e97045c4d01228063caa505c792f5a3d789ae28b7176b94ba40db83a3955cc06758735711dea8b710f8f70ebcb9cab10fbdad7e8e5361d160bd0f38a385efeb1befbf1aa68256cf6cda7405e0d0c9486ffbdbdb414569ef9ae5aa3219f054e21ffa99a4ada4efce44020a0c1e909a727a049dbed4",
      mask: #"0001020203040506070708090a0b0b",
    },
    Fork {
      skip: 0,
      neighbor: Neighbor {
        nibble: 6,
        value: #"229b9040851bc987d1463275fb3e15e91500ae723b9b4518d4515223b6f15e04",
        prefix: #"",
      },
    },
  ]
}

fn tree_without_watermelon() {
  mpt.from_root(
    #"bb931e8f080d5f20f7403bf6431d53f8a9e3578666ef27da51c19965d2867ffd",
  )
}
