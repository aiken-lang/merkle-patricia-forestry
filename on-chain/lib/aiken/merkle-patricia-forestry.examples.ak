use aiken/fuzz
use aiken/list
use aiken/merkle_patricia_forestry.{
  Branch, Fork, Leaf, MerklePatriciaForestry, Neighbor, Proof, ProofStep,
} as mpf

/// An example trie made from a list of fruits.
///
///   ╔═══════════════════════════════════════════════════════════════════╗
///   ║ #4acd78f345a686361df77541b2e0b533f53362e36620a1fdd3a13e0b61a3b078 ║
///   ╚═══════════════════════════════════════════════════════════════════╝
///    ┌─ 0 #520a7f805c5f
///    │  ├─ 389fd..[54 digits]..1abc #56408b9882f8 { mango[uid: 0] → 🥭 }
///    │  └─ 9d230..[54 digits]..9ecc #9ca49c0d73d5 { lemon[uid: 0] → 🍋 }
///    ├─ 16a4 #58c5e4a29601
///    │  ├─ 3a30b..[51 digits]..a968 #86410153344f { cherry[uid: 0] → 🍒 }
///    │  ├─ 8584c..[51 digits]..d4a5 #cda1c8929d05 { tomato[uid: 83468] → 🍅 }
///    │  └─ b7ce0..[51 digits]..f157 #472d5ccbcae8 { plum[uid: 15492] → 🤷 }
///    ├─ 245 #c9431d708d20
///    │  ├─ 4c787..[52 digits]..c20e #e38b422bd7d9 { pineapple[uid: 12577] → 🍍 }
///    │  ├─ a4f81..[52 digits]..90a3 #3e2491668264 { pomegranate[uid: 0] → 🤷 }
///    │  └─ e3fc8..[52 digits]..e7c3 #eda213c9a1ca { strawberry[uid: 2532] → 🍓 }
///    ├─ 3e #070a12b8b349
///    │  ├─ d002d..[53 digits]..f3ac #b40093af0024 { lime[uid: 0] → 🤷 }
///    │  └─ e659e..[53 digits]..b3b9 #242b464043b4 { banana[uid: 218] → 🍌 }
///    ├─ 4 #79519b8cdfbd
///    │  ├─ 07 #fdd60cf1b755
///    │  │  ├─ 6d8ab..[52 digits]..73ef #c538c893306a { guava[uid: 344] → 🤷 }
///    │  │  └─ c5847..[52 digits]..4a22 #785e20425cf9 { kiwi[uid: 0] → 🥝 }
///    │  └─ a522f..[54 digits]..20cd #e0b9d1f525e3 { kumquat[uid: 0] → 🤷 }
///    ├─ 5 #08434fd717ae
///    │  ├─ cddcd..[54 digits]..aa9e #8a1256a87426 { watermelon[uid: 0] → 🍉 }
///    │  └─ e #e26d8409cd76
///    │     ├─ 7ccfe..[53 digits]..4440 #c387ec2e54f6 { yuzu[uid: 0] → 🤷 }
///    │     └─ d71f9..[53 digits]..26d2 #cfcc9c732f50 { apple[uid: 58] → 🍎 }
///    ├─ 78666..[55 digits]..7292 #aeb3a9f2e198 { raspberry[uid: 0] → 🤷 }
///    ├─ 8af48..[55 digits]..04a8 #b27d20a5187a { tangerine[uid: 11] → 🍊 }
///    ├─ a #c2f2115774c1
///    │  ├─ 4b927..[54 digits]..3c69 #a6a35d200876 { peach[uid: 0] → 🍑 }
///    │  └─ f12 #8ee8d620e9d6
///    │     ├─ a1017..[51 digits]..50e7 #a241f4660aa4 { fig[uid: 68267] → 🤷 }
///    │     └─ ec412..[51 digits]..71fe #63c036b16617 { passionfruit[uid: 0] → 🤷 }
///    ├─ b #da0bdb30bf45
///    │  ├─ 67e71..[54 digits]..c48b #f39b1b5089f8 { grapefruit[uid: 0] → 🤷 }
///    │  └─ 88701..[54 digits]..949e #85acec96ac0f { blueberry[uid: 0] → 🫐 }
///    ├─ c #a22a7b4d767a
///    │  ├─ 5dc3c..[54 digits]..a3f3 #4c51531ac9d9 { cranberry[uid: 0] → 🤷 }
///    │  └─ 8cac1..[54 digits]..c3ca #8e27b4cf47de { orange[uid: 0] → 🍊 }
///    ├─ d #0a747d583e2e
///    │  ├─ b3047..[54 digits]..502a #54d9ea3b162d { coconut[uid: 0] → 🥥 }
///    │  └─ f779e..[54 digits]..678a #a82bdd8e07c2 { pear[uid: 0] → 🍐 }
///    ├─ e5993..[55 digits]..c9ec #da1771d107c8 { apricot[uid: 0] → 🤷 }
///    └─ f #117abf0e19fb
///       ├─ 63c88..[54 digits]..21ca #62bda6837164 { papaya[uid: 0] → 🤷 }
///       └─ b69c0..[54 digits]..2145 #c8e795f7b215 { grapes[uid: 0] → 🍇 }
///
fn trie() -> MerklePatriciaForestry {
  mpf.from_root(
    #"4acd78f345a686361df77541b2e0b533f53362e36620a1fdd3a13e0b61a3b078",
  )
}

test example_has() {
  and {
    mpf.has(trie(), apple, "🍎", proof_apple()),
    mpf.has(trie(), apricot, "🤷", proof_apricot()),
    mpf.has(trie(), banana, "🍌", proof_banana()),
    mpf.has(trie(), blueberry, "🫐", proof_blueberry()),
    mpf.has(trie(), cherry, "🍒", proof_cherry()),
    mpf.has(trie(), coconut, "🥥", proof_coconut()),
    mpf.has(trie(), cranberry, "🤷", proof_cranberry()),
    mpf.has(trie(), fig, "🤷", proof_fig()),
    mpf.has(trie(), grapefruit, "🤷", proof_grapefruit()),
    mpf.has(trie(), grapes, "🍇", proof_grapes()),
    mpf.has(trie(), guava, "🤷", proof_guava()),
    mpf.has(trie(), kiwi, "🥝", proof_kiwi()),
    mpf.has(trie(), kumquat, "🤷", proof_kumquat()),
    mpf.has(trie(), lemon, "🍋", proof_lemon()),
    mpf.has(trie(), lime, "🤷", proof_lime()),
    mpf.has(trie(), mango, "🥭", proof_mango()),
    mpf.has(trie(), orange, "🍊", proof_orange()),
    mpf.has(trie(), papaya, "🤷", proof_papaya()),
    mpf.has(trie(), passion, "🤷", proof_passion()),
    mpf.has(trie(), peach, "🍑", proof_peach()),
    mpf.has(trie(), pear, "🍐", proof_pear()),
    mpf.has(trie(), pineapple, "🍍", proof_pineapple()),
    mpf.has(trie(), plum, "🤷", proof_plum()),
    mpf.has(trie(), pomegranate, "🤷", proof_pomegranate()),
    mpf.has(trie(), raspberry, "🤷", proof_raspberry()),
    mpf.has(trie(), strawberry, "🍓", proof_strawberry()),
    mpf.has(trie(), tangerine, "🍊", proof_tangerine()),
    mpf.has(trie(), tomato, "🍅", proof_tomato()),
    mpf.has(trie(), watermelon, "🍉", proof_watermelon()),
    mpf.has(trie(), yuzu, "🤷", proof_yuzu()),
  }
}

test example_insert() {
  and {
    mpf.insert(without_apple(), apple, "🍎", proof_apple()) == trie(),
    mpf.insert(without_apricot(), apricot, "🤷", proof_apricot()) == trie(),
    mpf.insert(without_banana(), banana, "🍌", proof_banana()) == trie(),
    mpf.insert(without_blueberry(), blueberry, "🫐", proof_blueberry()) == trie(),
    mpf.insert(without_cherry(), cherry, "🍒", proof_cherry()) == trie(),
    mpf.insert(without_coconut(), coconut, "🥥", proof_coconut()) == trie(),
    mpf.insert(without_cranberry(), cranberry, "🤷", proof_cranberry()) == trie(),
    mpf.insert(without_fig(), fig, "🤷", proof_fig()) == trie(),
    mpf.insert(without_grapefruit(), grapefruit, "🤷", proof_grapefruit()) == trie(),
    mpf.insert(without_grapes(), grapes, "🍇", proof_grapes()) == trie(),
    mpf.insert(without_guava(), guava, "🤷", proof_guava()) == trie(),
    mpf.insert(without_kiwi(), kiwi, "🥝", proof_kiwi()) == trie(),
    mpf.insert(without_kumquat(), kumquat, "🤷", proof_kumquat()) == trie(),
    mpf.insert(without_lemon(), lemon, "🍋", proof_lemon()) == trie(),
    mpf.insert(without_lime(), lime, "🤷", proof_lime()) == trie(),
    mpf.insert(without_mango(), mango, "🥭", proof_mango()) == trie(),
    mpf.insert(without_orange(), orange, "🍊", proof_orange()) == trie(),
    mpf.insert(without_papaya(), papaya, "🤷", proof_papaya()) == trie(),
    mpf.insert(without_passion(), passion, "🤷", proof_passion()) == trie(),
    mpf.insert(without_peach(), peach, "🍑", proof_peach()) == trie(),
    mpf.insert(without_pear(), pear, "🍐", proof_pear()) == trie(),
    mpf.insert(without_pineapple(), pineapple, "🍍", proof_pineapple()) == trie(),
    mpf.insert(without_plum(), plum, "🤷", proof_plum()) == trie(),
    mpf.insert(without_pomegranate(), pomegranate, "🤷", proof_pomegranate()) == trie(),
    mpf.insert(without_raspberry(), raspberry, "🤷", proof_raspberry()) == trie(),
    mpf.insert(without_strawberry(), strawberry, "🍓", proof_strawberry()) == trie(),
    mpf.insert(without_tangerine(), tangerine, "🍊", proof_tangerine()) == trie(),
    mpf.insert(without_tomato(), tomato, "🍅", proof_tomato()) == trie(),
    mpf.insert(without_watermelon(), watermelon, "🍉", proof_watermelon()) == trie(),
    mpf.insert(without_yuzu(), yuzu, "🤷", proof_yuzu()) == trie(),
  }
}

test example_delete() {
  and {
    mpf.delete(trie(), apple, "🍎", proof_apple()) == without_apple(),
    mpf.delete(trie(), apricot, "🤷", proof_apricot()) == without_apricot(),
    mpf.delete(trie(), banana, "🍌", proof_banana()) == without_banana(),
    mpf.delete(trie(), blueberry, "🫐", proof_blueberry()) == without_blueberry(),
    mpf.delete(trie(), cherry, "🍒", proof_cherry()) == without_cherry(),
    mpf.delete(trie(), coconut, "🥥", proof_coconut()) == without_coconut(),
    mpf.delete(trie(), cranberry, "🤷", proof_cranberry()) == without_cranberry(),
    mpf.delete(trie(), fig, "🤷", proof_fig()) == without_fig(),
    mpf.delete(trie(), grapefruit, "🤷", proof_grapefruit()) == without_grapefruit(),
    mpf.delete(trie(), grapes, "🍇", proof_grapes()) == without_grapes(),
    mpf.delete(trie(), guava, "🤷", proof_guava()) == without_guava(),
    mpf.delete(trie(), kiwi, "🥝", proof_kiwi()) == without_kiwi(),
    mpf.delete(trie(), kumquat, "🤷", proof_kumquat()) == without_kumquat(),
    mpf.delete(trie(), lemon, "🍋", proof_lemon()) == without_lemon(),
    mpf.delete(trie(), lime, "🤷", proof_lime()) == without_lime(),
    mpf.delete(trie(), mango, "🥭", proof_mango()) == without_mango(),
    mpf.delete(trie(), orange, "🍊", proof_orange()) == without_orange(),
    mpf.delete(trie(), papaya, "🤷", proof_papaya()) == without_papaya(),
    mpf.delete(trie(), passion, "🤷", proof_passion()) == without_passion(),
    mpf.delete(trie(), peach, "🍑", proof_peach()) == without_peach(),
    mpf.delete(trie(), pear, "🍐", proof_pear()) == without_pear(),
    mpf.delete(trie(), pineapple, "🍍", proof_pineapple()) == without_pineapple(),
    mpf.delete(trie(), plum, "🤷", proof_plum()) == without_plum(),
    mpf.delete(trie(), pomegranate, "🤷", proof_pomegranate()) == without_pomegranate(),
    mpf.delete(trie(), raspberry, "🤷", proof_raspberry()) == without_raspberry(),
    mpf.delete(trie(), strawberry, "🍓", proof_strawberry()) == without_strawberry(),
    mpf.delete(trie(), tangerine, "🍊", proof_tangerine()) == without_tangerine(),
    mpf.delete(trie(), tomato, "🍅", proof_tomato()) == without_tomato(),
    mpf.delete(trie(), watermelon, "🍉", proof_watermelon()) == without_watermelon(),
    mpf.delete(trie(), yuzu, "🤷", proof_yuzu()) == without_yuzu(),
  }
}

// -------------------- Some notable cases

test example_insert_whatever() {
  let root = mpf.insert(without_kiwi(), kiwi, "foo", proof_kiwi())
  root != trie()
}

test example_already_inserted() fail {
  let root = mpf.insert(trie(), kiwi, "🥝", proof_kiwi())
  root == root
}

test example_delete_different_value() fail {
  let root = mpf.delete(trie(), kiwi, "🤷", proof_kiwi())
  root == root
}

test example_already_inserted_different_value() fail {
  let root = mpf.insert(trie(), kiwi, "foo", proof_kiwi())
  root == root
}

test example_insert_nearby_with_wrong_proof() fail {
  let root = mpf.insert(without_kiwi(), guava, "🤷", proof_kiwi())
  root == root
}

test example_insert_higher_with_wrong_proof() fail {
  let root = mpf.insert(without_kiwi(), kumquat, "🤷", proof_kiwi())
  root == root
}

test example_delete_nearby_with_wrong_proof() fail {
  let root = mpf.delete(trie(), guava, "🤷", proof_kiwi())
  root == root
}

test example_delete_higher_with_wrong_proof() fail {
  let root = mpf.delete(trie(), kumquat, "🤷", proof_kiwi())
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
      let key <- fuzz.and_then(fuzz.bytearray_between(32, 32))
      let value <- fuzz.map(fuzz.bytearray_between(32, 32))
      InsertStepAt(ix, Leaf { skip: 0, key, value })
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
          Some(Leaf { skip, key, value }) -> Leaf { skip: skip + 1, key, value }
          _ -> fail @"invalid 'IncrementSkipAt' mutation generated"
        }
      list.concat(list.take(proof, ix - 1), [step, ..list.drop(proof, ix + 1)])
    }
  }
}

// NOTE: ideally, we do want a _fail all_ here, or a negative property. But
// that's not doable just yet, so it's important to control that this test
// fails after *exactly one* test. No mutation should lead to a valid proof.
test example_mutate_proof(mutation via fuzz_proof_mutation(proof_apple())) fail {
  let proof = proof_apple() |> mutate(mutation)
  mpf.has(trie(), apple, "🍎", proof)
}

// -------------------- Fruits

// ---------- apricot

const apricot = "apricot[uid: 0]"

fn proof_apricot() {
  [
    Branch {
      skip: 0,
      neighbors: #"4be28f4839135e1f8f5372a90b54bb7bfaf997a5d13711bb4d7d93f9d4e04fbe280ada5ef30d55433934bbc73c89d550ee916f62822c34645e04bb66540c120f965c07fa815b86794e8703cee7e8f626c88d7da639258d2466aae67d5d041c5a117abf0e19fb78e0535891d82e5ece1310a1cf11674587dbba304c395769a988",
    },
  ]
}

fn without_apricot() {
  mpf.from_root(
    #"c08452d768160cd0fcdf5cad3d181cd36055eaf364d0eb7c49a01936bacf7b1f",
  )
}

// ---------- raspberry

const raspberry = "raspberry[uid: 0]"

fn proof_raspberry() {
  [
    Branch {
      skip: 0,
      neighbors: #"c7bfa4472f3a98ebe0421e8f3f03adf0f7c4340dec65b4b92b1c9f0bed209eb47238ba5d16031b6bace4aee22156f5028b0ca56dc24f7247d6435292e82c039cc9e7ff03faba170e98cd3c24338b95b1ce1b8a621d1016418f1494bbeb9e4a4a0000000000000000000000000000000000000000000000000000000000000000",
    },
  ]
}

fn without_raspberry() {
  mpf.from_root(
    #"4c9d89603cb1a25361777b8ed7f7c80f71b1dea66603872feea2b34a83d34453",
  )
}

// ---------- tangerine

const tangerine = "tangerine[uid: 11]"

fn proof_tangerine() {
  [
    Branch {
      skip: 0,
      neighbors: #"4be28f4839135e1f8f5372a90b54bb7bfaf997a5d13711bb4d7d93f9d4e04fbefa63eb4576001d8658219f928172eccb5448b4d7d62cd6d95228e13ebcbd5350c1e96bcc431893eef34e03989814375d439faa592edf75c9e5dc10b3c30766700000000000000000000000000000000000000000000000000000000000000000",
    },
  ]
}

fn without_tangerine() {
  mpf.from_root(
    #"826a0c030ad675740b83a33653fd3fc32b1021233f709759292151abdcd37f8d",
  )
}

// ---------- banana

const banana = "banana[uid: 218]"

fn proof_banana() {
  [
    Branch {
      skip: 0,
      neighbors: #"c7bfa4472f3a98ebe0421e8f3f03adf0f7c4340dec65b4b92b1c9f0bed209eb45fdf82687b1ab133324cebaf46d99d49f92720c5ded08d5b02f57530f2cc5a5fcf22cbaac4ab605dd13dbde57080661b53d8a7e23534c733acf50125cf0e5bcac9431d708d20021f1fa3f4f03468b8de194398072a402e7877376d06f747575a",
    },
    Leaf {
      skip: 1,
      key: #"3ed002d6885ab5d92e1307fccd1d021c32ec429192aea10cb2fd688b92aef3ac",
      value: #"7c3715aba2db74d565a6ce6cc72f20d9cb4652ddb29efe6268be15b105e40911",
    },
  ]
}

fn without_banana() {
  mpf.from_root(
    #"557990b1257679f2b8e09c507f2582b0566579a2fc26d0d8a6b59a4a88ef16db",
  )
}

// ---------- blueberry

const blueberry = "blueberry[uid: 0]"

fn proof_blueberry() {
  [
    Branch {
      skip: 0,
      neighbors: #"4be28f4839135e1f8f5372a90b54bb7bfaf997a5d13711bb4d7d93f9d4e04fbefa63eb4576001d8658219f928172eccb5448b4d7d62cd6d95228e13ebcbd5350be527bcfc7febe3c560057d97f4190bd24b537a322315f84daafab3ada562b50c2f2115774c117f184b58dba7a23d2c93968aa40387ceb0c9a9f53e4f594e881",
    },
    Leaf {
      skip: 0,
      key: #"b67e71b092e6a54576fa23b0eb48c5e5794a3fb5480983e48b40e453596cc48b",
      value: #"7c3715aba2db74d565a6ce6cc72f20d9cb4652ddb29efe6268be15b105e40911",
    },
  ]
}

fn without_blueberry() {
  mpf.from_root(
    #"e2025bb26dae9291d4eeb58817b5c7eb84ab2e47a27c994cc04369fffe8bc842",
  )
}

// ---------- cherry

const cherry = "cherry[uid: 0]"

fn proof_cherry() {
  [
    Branch {
      skip: 0,
      neighbors: #"c7bfa4472f3a98ebe0421e8f3f03adf0f7c4340dec65b4b92b1c9f0bed209eb45fdf82687b1ab133324cebaf46d99d49f92720c5ded08d5b02f57530f2cc5a5f1508f13471a031a21277db8817615e62a50a7427d5f8be572746aa5f0d498417520a7f805c5f674e2deca5230b6942bbc71586dc94a783eebe1ed58c9a864e53",
    },
    Branch {
      skip: 3,
      neighbors: #"2549707d84ecc2fa100fd85bf15f2ec99da70d4b3a39588c1138331eb0e00d3e85c09af929492a871e4fae32d9d5c36e352471cd659bcdb61de08f1722acc3b10eb923b0cbd24df54401d998531feead35a47a99f4deed205de4af81120f97610000000000000000000000000000000000000000000000000000000000000000",
    },
  ]
}

fn without_cherry() {
  mpf.from_root(
    #"968b14e351704108f00325985ab0cd81af8617bb131e31607b6bcd3f96d7c4c2",
  )
}

// ---------- coconut

const coconut = "coconut[uid: 0]"

fn proof_coconut() {
  [
    Branch {
      skip: 0,
      neighbors: #"4be28f4839135e1f8f5372a90b54bb7bfaf997a5d13711bb4d7d93f9d4e04fbe280ada5ef30d55433934bbc73c89d550ee916f62822c34645e04bb66540c120f323def78732eace937391fc626efcd062552ebcf5e93f00352b86cb0f89daca0a22a7b4d767ada48673a4a9313a02a35ff47d2f55bcf10ae294127f590a4327c",
    },
    Leaf {
      skip: 0,
      key: #"df779e7f171b7299c2cede28bb898c1ee3456d98657b95e8082cd375704b678a",
      value: #"9e3d695f13a7292b8859d2ba0113e305825a8af8ba886d2ae73e73f2d35c6afe",
    },
  ]
}

fn without_coconut() {
  mpf.from_root(
    #"4888f3b72e475510bc0bb78c5f3706c0520a4294a41f8c05b5561776369d9d5d",
  )
}

// ---------- cranberry

const cranberry = "cranberry[uid: 0]"

fn proof_cranberry() {
  [
    Branch {
      skip: 0,
      neighbors: #"4be28f4839135e1f8f5372a90b54bb7bfaf997a5d13711bb4d7d93f9d4e04fbe280ada5ef30d55433934bbc73c89d550ee916f62822c34645e04bb66540c120f323def78732eace937391fc626efcd062552ebcf5e93f00352b86cb0f89daca00a747d583e2e3db49524add1eea3063421fc04547e19c4e807810a537a63b379",
    },
    Leaf {
      skip: 0,
      key: #"c8cac1a325376bbc49936988b4c720d7806e99c878bc645ad90cebb98302c3ca",
      value: #"ccfd71674a4dca5f252690588b24bebffa36068206414b1575c0f7f7f8103839",
    },
  ]
}

fn without_cranberry() {
  mpf.from_root(
    #"c80ac1ba6f8a6437562b25fe4a110f1c0013f26c7209f699df46493ce85e0081",
  )
}

// ---------- grapefruit

const grapefruit = "grapefruit[uid: 0]"

fn proof_grapefruit() {
  [
    Branch {
      skip: 0,
      neighbors: #"4be28f4839135e1f8f5372a90b54bb7bfaf997a5d13711bb4d7d93f9d4e04fbefa63eb4576001d8658219f928172eccb5448b4d7d62cd6d95228e13ebcbd5350be527bcfc7febe3c560057d97f4190bd24b537a322315f84daafab3ada562b50c2f2115774c117f184b58dba7a23d2c93968aa40387ceb0c9a9f53e4f594e881",
    },
    Leaf {
      skip: 0,
      key: #"b88701c48c6abd03dfc5f4538bb585102ddc2e4640c55c8c3c9bb7e0093d949e",
      value: #"6d96ccb103b14005c17b3c17d45e0df0bab5dd1fb2276197a89ed1aeedaad7a0",
    },
  ]
}

fn without_grapefruit() {
  mpf.from_root(
    #"68125b51606cc784d3ed2010a2bc297776ce7442669a5072220f5e6911e5be84",
  )
}

// ---------- grapes

const grapes = "grapes[uid: 0]"

fn proof_grapes() {
  [
    Branch {
      skip: 0,
      neighbors: #"4be28f4839135e1f8f5372a90b54bb7bfaf997a5d13711bb4d7d93f9d4e04fbe280ada5ef30d55433934bbc73c89d550ee916f62822c34645e04bb66540c120f965c07fa815b86794e8703cee7e8f626c88d7da639258d2466aae67d5d041c5ada1771d107c86c8e68da458063a47f9cdb63ddb9e922ab6ccb18d9e6d4b7aaf9",
    },
    Leaf {
      skip: 0,
      key: #"f63c88d1bc9695dfc39eaf90a11248964311383a95345e5b04d6d8f25d5121ca",
      value: #"7c3715aba2db74d565a6ce6cc72f20d9cb4652ddb29efe6268be15b105e40911",
    },
  ]
}

fn without_grapes() {
  mpf.from_root(
    #"a5a405950c2aaf7da30abbfa969fdecccd4ed19077f751b1de641b2bfc2df957",
  )
}

// ---------- kumquat

const kumquat = "kumquat[uid: 0]"

fn proof_kumquat() {
  [
    Branch {
      skip: 0,
      neighbors: #"c7bfa4472f3a98ebe0421e8f3f03adf0f7c4340dec65b4b92b1c9f0bed209eb47238ba5d16031b6bace4aee22156f5028b0ca56dc24f7247d6435292e82c039c3490a825d2e8deddf8679ce2f95f7e3a59d9c3e1af4a49b410266d21c9344d6d08434fd717aea47d156185d589f44a59fc2e0158eab7ff035083a2a66cd3e15b",
    },
    Fork {
      skip: 0,
      neighbor: Neighbor {
        nibble: 0,
        prefix: #"07",
        root: #"a1ffbc0e72342b41129e2d01d289809079b002e54b123860077d2d66added281",
      },
    },
  ]
}

fn without_kumquat() {
  mpf.from_root(
    #"4dd6d57ca8cb7ac8c3b219366754a392ba9e4e43b6b3ae59d89be3f878ba8fb6",
  )
}

// ---------- lemon

const lemon = "lemon[uid: 0]"

fn proof_lemon() {
  [
    Branch {
      skip: 0,
      neighbors: #"c7bfa4472f3a98ebe0421e8f3f03adf0f7c4340dec65b4b92b1c9f0bed209eb45fdf82687b1ab133324cebaf46d99d49f92720c5ded08d5b02f57530f2cc5a5f1508f13471a031a21277db8817615e62a50a7427d5f8be572746aa5f0d49841758c5e4a29601399a5bd916e5f3b34c38e13253f4de2a3477114f1b2b8f9f2f4d",
    },
    Leaf {
      skip: 0,
      key: #"0389fd2d655e31dac50b00f3113aa327e36680e9df509d48eb255446d4891abc",
      value: #"001fb475e73fee4611a4350ae793d7dca387bcc1e199eabf498002a173378cc5",
    },
  ]
}

fn without_lemon() {
  mpf.from_root(
    #"6a7c7950e3718263c3f6d0b5cec7d7724c2394d62053692132c2ffebf8b8e4bd",
  )
}

// ---------- lime

const lime = "lime[uid: 0]"

fn proof_lime() {
  [
    Branch {
      skip: 0,
      neighbors: #"c7bfa4472f3a98ebe0421e8f3f03adf0f7c4340dec65b4b92b1c9f0bed209eb45fdf82687b1ab133324cebaf46d99d49f92720c5ded08d5b02f57530f2cc5a5fcf22cbaac4ab605dd13dbde57080661b53d8a7e23534c733acf50125cf0e5bcac9431d708d20021f1fa3f4f03468b8de194398072a402e7877376d06f747575a",
    },
    Leaf {
      skip: 1,
      key: #"3ee659e1fddc70f61cc65eb61478cd92a09fd7787ea4f913047469339f26b3b9",
      value: #"356a8eb7e12e71400ef0f2e305a89c643ec8cad60506ca9057201a5e36fb01ab",
    },
  ]
}

fn without_lime() {
  mpf.from_root(
    #"cc11203c785e808fc0555562dd9fef4b9c161d2ed64ff16df47080325862f4a7",
  )
}

// ---------- mango

const mango = "mango[uid: 0]"

fn proof_mango() {
  [
    Branch {
      skip: 0,
      neighbors: #"c7bfa4472f3a98ebe0421e8f3f03adf0f7c4340dec65b4b92b1c9f0bed209eb45fdf82687b1ab133324cebaf46d99d49f92720c5ded08d5b02f57530f2cc5a5f1508f13471a031a21277db8817615e62a50a7427d5f8be572746aa5f0d49841758c5e4a29601399a5bd916e5f3b34c38e13253f4de2a3477114f1b2b8f9f2f4d",
    },
    Leaf {
      skip: 0,
      key: #"09d23032e6edc0522c00bc9b74edd3af226d1204a079640a367da94c84b69ecc",
      value: #"c29c35ad67a5a55558084e634ab0d98f7dd1f60070b9ce2a53f9f305fd9d9795",
    },
  ]
}

fn without_mango() {
  mpf.from_root(
    #"c683f99382df709f322b957c3ff828ab10cb2b6a855458e4b3d23fbea83e7a0e",
  )
}

// ---------- orange

const orange = "orange[uid: 0]"

fn proof_orange() {
  [
    Branch {
      skip: 0,
      neighbors: #"4be28f4839135e1f8f5372a90b54bb7bfaf997a5d13711bb4d7d93f9d4e04fbe280ada5ef30d55433934bbc73c89d550ee916f62822c34645e04bb66540c120f323def78732eace937391fc626efcd062552ebcf5e93f00352b86cb0f89daca00a747d583e2e3db49524add1eea3063421fc04547e19c4e807810a537a63b379",
    },
    Leaf {
      skip: 0,
      key: #"c5dc3c068b45ce9dbf42d07fd86fc2dac165fd1b81ce73267b2aee242afba3f3",
      value: #"7c3715aba2db74d565a6ce6cc72f20d9cb4652ddb29efe6268be15b105e40911",
    },
  ]
}

fn without_orange() {
  mpf.from_root(
    #"59854171e5e36247499d82747754ca56eb7ced82fa27edc95f7c102fbcbee3f0",
  )
}

// ---------- papaya

const papaya = "papaya[uid: 0]"

fn proof_papaya() {
  [
    Branch {
      skip: 0,
      neighbors: #"4be28f4839135e1f8f5372a90b54bb7bfaf997a5d13711bb4d7d93f9d4e04fbe280ada5ef30d55433934bbc73c89d550ee916f62822c34645e04bb66540c120f965c07fa815b86794e8703cee7e8f626c88d7da639258d2466aae67d5d041c5ada1771d107c86c8e68da458063a47f9cdb63ddb9e922ab6ccb18d9e6d4b7aaf9",
    },
    Leaf {
      skip: 0,
      key: #"fb69c0d60ec9bfb6cafa5cf54675edfbb0017b873ee92a5dbb6bdabcfb352145",
      value: #"b5898c51c32083e91b8c18c735d0ba74e08f964a20b1639c189d1e8704b78a09",
    },
  ]
}

fn without_papaya() {
  mpf.from_root(
    #"97a6f166b2c5f5a46776e1b471d7855a3e876e95d1eff34c5df3734e70d3fcf5",
  )
}

// ---------- peach

const peach = "peach[uid: 0]"

fn proof_peach() {
  [
    Branch {
      skip: 0,
      neighbors: #"4be28f4839135e1f8f5372a90b54bb7bfaf997a5d13711bb4d7d93f9d4e04fbefa63eb4576001d8658219f928172eccb5448b4d7d62cd6d95228e13ebcbd5350be527bcfc7febe3c560057d97f4190bd24b537a322315f84daafab3ada562b50da0bdb30bf45c76153418a634f1bcecba8c601ca985fbca14b57582920d82acb",
    },
    Fork {
      skip: 0,
      neighbor: Neighbor {
        nibble: 15,
        prefix: #"0102",
        root: #"2f6b320212dd98c38a7cd074886d942d9577cdad5ef1c72d32a01df1a63ed88f",
      },
    },
  ]
}

fn without_peach() {
  mpf.from_root(
    #"5d4bfc2613624f54751303e605568337f6f8eb7bd63369d9f780c5be839dbdd1",
  )
}

// ---------- pear

const pear = "pear[uid: 0]"

fn proof_pear() {
  [
    Branch {
      skip: 0,
      neighbors: #"4be28f4839135e1f8f5372a90b54bb7bfaf997a5d13711bb4d7d93f9d4e04fbe280ada5ef30d55433934bbc73c89d550ee916f62822c34645e04bb66540c120f323def78732eace937391fc626efcd062552ebcf5e93f00352b86cb0f89daca0a22a7b4d767ada48673a4a9313a02a35ff47d2f55bcf10ae294127f590a4327c",
    },
    Leaf {
      skip: 0,
      key: #"db30478ecc78451d06c1dfe24a35233a6d448fafa17af644fac693a4ca3f502a",
      value: #"1c8ca3866d1b2ab614bf085c95381adbf7be2c6e8fa628034932fe4a4f54e1c3",
    },
  ]
}

fn without_pear() {
  mpf.from_root(
    #"8f2da0fcfeab12df8b53dd6ea4fe6ff8fbd6f954f1ead8d40b298b86c3716510",
  )
}

// ---------- pineapple

const pineapple = "pineapple[uid: 12577]"

fn proof_pineapple() {
  [
    Branch {
      skip: 0,
      neighbors: #"c7bfa4472f3a98ebe0421e8f3f03adf0f7c4340dec65b4b92b1c9f0bed209eb45fdf82687b1ab133324cebaf46d99d49f92720c5ded08d5b02f57530f2cc5a5fcf22cbaac4ab605dd13dbde57080661b53d8a7e23534c733acf50125cf0e5bca070a12b8b34948fc52296522a0b1816849392f7c2a73b8a25538ccebed176c9f",
    },
    Branch {
      skip: 2,
      neighbors: #"4e1fa8ba9cc8e18bbf0194b41e5fac140d0e58758706545f2354f2e42f7b4b0685c09af929492a871e4fae32d9d5c36e352471cd659bcdb61de08f1722acc3b10eb923b0cbd24df54401d998531feead35a47a99f4deed205de4af81120f97610000000000000000000000000000000000000000000000000000000000000000",
    },
  ]
}

fn without_pineapple() {
  mpf.from_root(
    #"dcb9a2b6aae1477da4409ce8a62235d87a006011bf1dc893948fad9c5be955f7",
  )
}

// ---------- plum

const plum = "plum[uid: 15492]"

fn proof_plum() {
  [
    Branch {
      skip: 0,
      neighbors: #"c7bfa4472f3a98ebe0421e8f3f03adf0f7c4340dec65b4b92b1c9f0bed209eb45fdf82687b1ab133324cebaf46d99d49f92720c5ded08d5b02f57530f2cc5a5f1508f13471a031a21277db8817615e62a50a7427d5f8be572746aa5f0d498417520a7f805c5f674e2deca5230b6942bbc71586dc94a783eebe1ed58c9a864e53",
    },
    Branch {
      skip: 3,
      neighbors: #"1955c87798c9f03af2f38429ebdeeefe0a0c84db8e583df37561abf0c64f46ca85c09af929492a871e4fae32d9d5c36e352471cd659bcdb61de08f1722acc3b1f34025c0e276d328068b15d428480914fd73946ae94a5f45c3530e3decdeefdf0000000000000000000000000000000000000000000000000000000000000000",
    },
  ]
}

fn without_plum() {
  mpf.from_root(
    #"fc7494dec21f1533d8f97677b890ebf3a7954c0b8110895d663a5c78d15daf92",
  )
}

// ---------- pomegranate

const pomegranate = "pomegranate[uid: 0]"

fn proof_pomegranate() {
  [
    Branch {
      skip: 0,
      neighbors: #"c7bfa4472f3a98ebe0421e8f3f03adf0f7c4340dec65b4b92b1c9f0bed209eb45fdf82687b1ab133324cebaf46d99d49f92720c5ded08d5b02f57530f2cc5a5fcf22cbaac4ab605dd13dbde57080661b53d8a7e23534c733acf50125cf0e5bca070a12b8b34948fc52296522a0b1816849392f7c2a73b8a25538ccebed176c9f",
    },
    Branch {
      skip: 2,
      neighbors: #"03c59510714326934442799b6960ed35c11bb26ea47746839d9ab0635887aa13b60d6d31fb16509758290f509e419f55abb79ba2ca63c9b329f97f69f9e5b4f90eb923b0cbd24df54401d998531feead35a47a99f4deed205de4af81120f97610000000000000000000000000000000000000000000000000000000000000000",
    },
  ]
}

fn without_pomegranate() {
  mpf.from_root(
    #"7267243f71e63165e8a697c1282d205352b9534db9902d97eb90b3bd89431ddb",
  )
}

// ---------- strawberry

const strawberry = "strawberry[uid: 2532]"

fn proof_strawberry() {
  [
    Branch {
      skip: 0,
      neighbors: #"c7bfa4472f3a98ebe0421e8f3f03adf0f7c4340dec65b4b92b1c9f0bed209eb45fdf82687b1ab133324cebaf46d99d49f92720c5ded08d5b02f57530f2cc5a5fcf22cbaac4ab605dd13dbde57080661b53d8a7e23534c733acf50125cf0e5bca070a12b8b34948fc52296522a0b1816849392f7c2a73b8a25538ccebed176c9f",
    },
    Branch {
      skip: 2,
      neighbors: #"03c59510714326934442799b6960ed35c11bb26ea47746839d9ab0635887aa13eaf6d47da35b10a0585256dfdb4e5a8456e02d276a6c554842bf3e4148160ba70eb923b0cbd24df54401d998531feead35a47a99f4deed205de4af81120f97610000000000000000000000000000000000000000000000000000000000000000",
    },
  ]
}

fn without_strawberry() {
  mpf.from_root(
    #"c5890dfafc0c0b66d3af7775ae9c5bac6974ec0b38b5a9a635299a9eae7c8823",
  )
}

// ---------- tomato

const tomato = "tomato[uid: 83468]"

fn proof_tomato() {
  [
    Branch {
      skip: 0,
      neighbors: #"c7bfa4472f3a98ebe0421e8f3f03adf0f7c4340dec65b4b92b1c9f0bed209eb45fdf82687b1ab133324cebaf46d99d49f92720c5ded08d5b02f57530f2cc5a5f1508f13471a031a21277db8817615e62a50a7427d5f8be572746aa5f0d498417520a7f805c5f674e2deca5230b6942bbc71586dc94a783eebe1ed58c9a864e53",
    },
    Branch {
      skip: 3,
      neighbors: #"1955c87798c9f03af2f38429ebdeeefe0a0c84db8e583df37561abf0c64f46ca85c09af929492a871e4fae32d9d5c36e352471cd659bcdb61de08f1722acc3b1a93bd84b815df138ab148bfdc2c3ee94f0cdbbb6ab8a38d429a7a8895c470ce70000000000000000000000000000000000000000000000000000000000000000",
    },
  ]
}

fn without_tomato() {
  mpf.from_root(
    #"8329dfa8be59c7e677966a62d3de98944f231c02cc8e97ec049fd1a8e5898474",
  )
}

// ---------- watermelon

const watermelon = "watermelon[uid: 0]"

fn proof_watermelon() {
  [
    Branch {
      skip: 0,
      neighbors: #"c7bfa4472f3a98ebe0421e8f3f03adf0f7c4340dec65b4b92b1c9f0bed209eb47238ba5d16031b6bace4aee22156f5028b0ca56dc24f7247d6435292e82c039c3490a825d2e8deddf8679ce2f95f7e3a59d9c3e1af4a49b410266d21c9344d6d79519b8cdfbd053e5a86cf28a781debae71638cd77f85aad4b88869373d9dcfd",
    },
    Fork {
      skip: 0,
      neighbor: Neighbor {
        nibble: 14,
        prefix: #"",
        root: #"995afcfa89b7430348dbfb6171b944794119ffc0dd003edc18e2fa8d6d6d48bf",
      },
    },
  ]
}

fn without_watermelon() {
  mpf.from_root(
    #"e69c446638ad9ae9654e4e6699954996da1f1256d6df711bcb6a740659dfe470",
  )
}

// ---------- apple

const apple = "apple[uid: 58]"

fn proof_apple() {
  [
    Branch {
      skip: 0,
      neighbors: #"c7bfa4472f3a98ebe0421e8f3f03adf0f7c4340dec65b4b92b1c9f0bed209eb47238ba5d16031b6bace4aee22156f5028b0ca56dc24f7247d6435292e82c039c3490a825d2e8deddf8679ce2f95f7e3a59d9c3e1af4a49b410266d21c9344d6d79519b8cdfbd053e5a86cf28a781debae71638cd77f85aad4b88869373d9dcfd",
    },
    Leaf {
      skip: 0,
      key: #"5cddcd30a0a388cf6feb3fd6e112c96e9daf23e3a9c8a334e7044650471aaa9e",
      value: #"f429821ddf89c9df3c7fbb5aa6fadb6c246d75ceede53173ce59d70dde375d14",
    },
    Leaf {
      skip: 0,
      key: #"5e7ccfedd44c90423b191ecca1eb21dfbac865d561bace8c0f3e94ae7edf4440",
      value: #"7c3715aba2db74d565a6ce6cc72f20d9cb4652ddb29efe6268be15b105e40911",
    },
  ]
}

fn without_apple() {
  mpf.from_root(
    #"cb7812785c2f6b56e3dba69923e37625e94953257915d25f1041f43cefd5cb62",
  )
}

// ---------- fig

const fig = "fig[uid: 68267]"

fn proof_fig() {
  [
    Branch {
      skip: 0,
      neighbors: #"4be28f4839135e1f8f5372a90b54bb7bfaf997a5d13711bb4d7d93f9d4e04fbefa63eb4576001d8658219f928172eccb5448b4d7d62cd6d95228e13ebcbd5350be527bcfc7febe3c560057d97f4190bd24b537a322315f84daafab3ada562b50da0bdb30bf45c76153418a634f1bcecba8c601ca985fbca14b57582920d82acb",
    },
    Leaf {
      skip: 0,
      key: #"a4b927e3735c7dbf9f1846844aad53e82362e47e32223d559333f4d154483c69",
      value: #"5ee6f548bba6d9da3313a23b395efb48b440063a592d8592e73d87b79d1d887a",
    },
    Leaf {
      skip: 2,
      key: #"af12ec41241cb0a5cae2a4a1232a64f3ca68f65342cf2a2f98cd6a00cf7971fe",
      value: #"7c3715aba2db74d565a6ce6cc72f20d9cb4652ddb29efe6268be15b105e40911",
    },
  ]
}

fn without_fig() {
  mpf.from_root(
    #"fde975ef370e50b0d93fd3a766d85e502160b9231e6c4887616459f27e786693",
  )
}

// ---------- guava

const guava = "guava[uid: 344]"

fn proof_guava() {
  [
    Branch {
      skip: 0,
      neighbors: #"c7bfa4472f3a98ebe0421e8f3f03adf0f7c4340dec65b4b92b1c9f0bed209eb47238ba5d16031b6bace4aee22156f5028b0ca56dc24f7247d6435292e82c039c3490a825d2e8deddf8679ce2f95f7e3a59d9c3e1af4a49b410266d21c9344d6d08434fd717aea47d156185d589f44a59fc2e0158eab7ff035083a2a66cd3e15b",
    },
    Leaf {
      skip: 0,
      key: #"4a522f84bcda4bebb725d5f2b92af615b57cc1777bb0d8b2c6c18c3e3e6520cd",
      value: #"7c3715aba2db74d565a6ce6cc72f20d9cb4652ddb29efe6268be15b105e40911",
    },
    Leaf {
      skip: 1,
      key: #"407c58473af4b3e5b24e65481294b0772ed6a7dd793937c6c90179960d154a22",
      value: #"05f6a1db018258657194e930ed49e86cbc3622aeae1c13e92110e28d3635fdca",
    },
  ]
}

fn without_guava() {
  mpf.from_root(
    #"aae08af9abdf11e286ae91c430b81cb306d1f43dcec58ab2f59fe024412e54e2",
  )
}

// ---------- kiwi

const kiwi = "kiwi[uid: 0]"

fn proof_kiwi() {
  [
    Branch {
      skip: 0,
      neighbors: #"c7bfa4472f3a98ebe0421e8f3f03adf0f7c4340dec65b4b92b1c9f0bed209eb47238ba5d16031b6bace4aee22156f5028b0ca56dc24f7247d6435292e82c039c3490a825d2e8deddf8679ce2f95f7e3a59d9c3e1af4a49b410266d21c9344d6d08434fd717aea47d156185d589f44a59fc2e0158eab7ff035083a2a66cd3e15b",
    },
    Leaf {
      skip: 0,
      key: #"4a522f84bcda4bebb725d5f2b92af615b57cc1777bb0d8b2c6c18c3e3e6520cd",
      value: #"7c3715aba2db74d565a6ce6cc72f20d9cb4652ddb29efe6268be15b105e40911",
    },
    Leaf {
      skip: 1,
      key: #"4076d8ab234597ab6a35c03c805381bbc016025b36ff1f7df9c5009e1a8b73ef",
      value: #"7c3715aba2db74d565a6ce6cc72f20d9cb4652ddb29efe6268be15b105e40911",
    },
  ]
}

fn without_kiwi() {
  mpf.from_root(
    #"621815dfdfca61bca13341df5aa32f4133225b5e3b5d9c030001b2298132a0fa",
  )
}

// ---------- passionfruit

const passion = "passionfruit[uid: 0]"

fn proof_passion() {
  [
    Branch {
      skip: 0,
      neighbors: #"4be28f4839135e1f8f5372a90b54bb7bfaf997a5d13711bb4d7d93f9d4e04fbefa63eb4576001d8658219f928172eccb5448b4d7d62cd6d95228e13ebcbd5350be527bcfc7febe3c560057d97f4190bd24b537a322315f84daafab3ada562b50da0bdb30bf45c76153418a634f1bcecba8c601ca985fbca14b57582920d82acb",
    },
    Leaf {
      skip: 0,
      key: #"a4b927e3735c7dbf9f1846844aad53e82362e47e32223d559333f4d154483c69",
      value: #"5ee6f548bba6d9da3313a23b395efb48b440063a592d8592e73d87b79d1d887a",
    },
    Leaf {
      skip: 2,
      key: #"af12a10176ecbb08fc16658069ac132455796c5b62a5ef8985933c76652f50e7",
      value: #"7c3715aba2db74d565a6ce6cc72f20d9cb4652ddb29efe6268be15b105e40911",
    },
  ]
}

fn without_passion() {
  mpf.from_root(
    #"2e45678664ccbcad82eb24e7a77cb199593b47f07feafaa205b089a8dc48461e",
  )
}

// ---------- yuzu

const yuzu = "yuzu[uid: 0]"

fn proof_yuzu() {
  [
    Branch {
      skip: 0,
      neighbors: #"c7bfa4472f3a98ebe0421e8f3f03adf0f7c4340dec65b4b92b1c9f0bed209eb47238ba5d16031b6bace4aee22156f5028b0ca56dc24f7247d6435292e82c039c3490a825d2e8deddf8679ce2f95f7e3a59d9c3e1af4a49b410266d21c9344d6d79519b8cdfbd053e5a86cf28a781debae71638cd77f85aad4b88869373d9dcfd",
    },
    Leaf {
      skip: 0,
      key: #"5cddcd30a0a388cf6feb3fd6e112c96e9daf23e3a9c8a334e7044650471aaa9e",
      value: #"f429821ddf89c9df3c7fbb5aa6fadb6c246d75ceede53173ce59d70dde375d14",
    },
    Leaf {
      skip: 0,
      key: #"5ed71f91166242e8477758810ad103aff35313b175b1762b0efe800fa9a126d2",
      value: #"09d504e02c4e6fa7b66303a456bc8786da3f51e8bf2834eeb9c95ec479f3681a",
    },
  ]
}

fn without_yuzu() {
  mpf.from_root(
    #"366a84bbb2274658080acb85026bba389054782b4681f4cf9e29141ac98de253",
  )
}
