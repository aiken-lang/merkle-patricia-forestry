use aiken/fuzz
use aiken/list
use aiken/merkle_patricia_forestry.{
  Branch, Fork, Leaf, MerklePatriciaForestry, Neighbor, Proof, ProofStep,
} as mpf

/// An example trie made from a list of fruits.
///
/// ╔═══════════════════════════════════════════════════════════════════╗
/// ║ #ee57de5169e7be3f32ce7a486e8816c808d7751e7df0a27ab576bf18ef1afbdd ║
/// ╚═══════════════════════════════════════════════════════════════════╝
///  ┌─ 0 #a8b499ebb15a
///  │  ├─ 389fd..[54 digits]..1abc #96d6ae0847f4 { mango[uid: 0] → 🥭 }
///  │  └─ 9d230..[54 digits]..9ecc #48071b791174 { lemon[uid: 0] → 🍋 }
///  ├─ 16a4 #ea27de91b695
///  │  ├─ 3a30b..[51 digits]..a968 #2da4e1ef108c { cherry[uid: 0] → 🍒 }
///  │  ├─ 8584c..[51 digits]..d4a5 #4c83b85745f7 { tomato[uid: 83468] → 🍅 }
///  │  └─ b7ce0..[51 digits]..f157 #522f6b664982 { plum[uid: 15492] → 🤷 }
///  ├─ 245 #33df330965d7
///  │  ├─ 4c787..[52 digits]..c20e #0f6146c21bf4 { pineapple[uid: 12577] → 🍍 }
///  │  ├─ a4f81..[52 digits]..90a3 #4796c959657c { pomegranate[uid: 0] → 🤷 }
///  │  └─ e3fc8..[52 digits]..e7c3 #f50a2aad6560 { strawberry[uid: 2532] → 🍓 }
///  ├─ 3e #5a5985680607
///  │  ├─ d002d..[53 digits]..f3ac #dbf6004ed27d { lime[uid: 0] → 🤷 }
///  │  └─ e659e..[53 digits]..b3b9 #83f30b498ad4 { banana[uid: 218] → 🍌 }
///  ├─ 4 #8187d8a3f1cf
///  │  ├─ 07 #4790f8833717
///  │  │  ├─ 6d8ab..[52 digits]..73ef #561a4637b19a { guava[uid: 344] → 🤷 }
///  │  │  └─ c5847..[52 digits]..4a22 #f285ef1fbb7f { kiwi[uid: 0] → 🥝 }
///  │  └─ a522f..[54 digits]..20cd #c6473b214164 { kumquat[uid: 0] → 🤷 }
///  ├─ 5 #630f527d86d1
///  │  ├─ cddcd..[54 digits]..aa9e #ebe7d10d20a2 { watermelon[uid: 0] → 🍉 }
///  │  └─ e #9b87e6b900b4
///  │     ├─ 7ccfe..[53 digits]..4440 #2b33ecc11e12 { yuzu[uid: 0] → 🤷 }
///  │     └─ d71f9..[53 digits]..26d2 #bd6f8f57f1c1 { apple[uid: 58] → 🍎 }
///  ├─ 78666..[55 digits]..7292 #84301478aa70 { raspberry[uid: 0] → 🤷 }
///  ├─ 8af48..[55 digits]..04a8 #a3721b3311f1 { tangerine[uid: 11] → 🍊 }
///  ├─ a #a13acbf54844
///  │  ├─ 4b927..[54 digits]..3c69 #96e92f4f2632 { peach[uid: 0] → 🍑 }
///  │  └─ f12 #de6db29c4829
///  │     ├─ a1017..[51 digits]..50e7 #89756ed0f250 { fig[uid: 68267] → 🤷 }
///  │     └─ ec412..[51 digits]..71fe #51ae27cca144 { passionfruit[uid: 0] → 🤷 }
///  ├─ b #ed869762c74c
///  │  ├─ 67e71..[54 digits]..c48b #c2e5213cceec { grapefruit[uid: 0] → 🤷 }
///  │  └─ 88701..[54 digits]..949e #64f57b688d7b { blueberry[uid: 0] → 🫐 }
///  ├─ c #d653df9bae61
///  │  ├─ 5dc3c..[54 digits]..a3f3 #0f186942cf0d { cranberry[uid: 0] → 🤷 }
///  │  └─ 8cac1..[54 digits]..c3ca #4bb4b456122b { orange[uid: 0] → 🍊 }
///  ├─ d #17d9adcb708f
///  │  ├─ b3047..[54 digits]..502a #e6c8d47be96a { coconut[uid: 0] → 🥥 }
///  │  └─ f779e..[54 digits]..678a #9f8acb081242 { pear[uid: 0] → 🍐 }
///  ├─ e5993..[55 digits]..c9ec #5f1fd0952856 { apricot[uid: 0] → 🤷 }
///  └─ f #209a78c802ca
///     ├─ 63c88..[54 digits]..21ca #da480b0fea67 { papaya[uid: 0] → 🤷 }
///     └─ b69c0..[54 digits]..2145 #88850a4e3205 { grapes[uid: 0] → 🍇 }
///
fn trie() -> MerklePatriciaForestry {
  mpf.from_root(
    #"ee57de5169e7be3f32ce7a486e8816c808d7751e7df0a27ab576bf18ef1afbdd",
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

// ---------- apple

const apple = "apple[uid: 58]"

fn proof_apple() {
  [
    Branch {
      skip: 0,
      neighbors: #"899142f03e13ad2ed401d17d5bac5628a58add60ec8ffcc0b0d7a6eb57aad36c478a46cd59964c246193f91eae0b21617f264a0617910167e6b04fb6994bf99417b670e162c676797a65b28c3d8eb7240944a4db76acfee2cd74d93e4684c4848187d8a3f1cf6ccbfb3a6353704698b8b88030486567ee4e4cf5aa6f5f4e01da",
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
    #"de88fbf9886f44c61f6fec4d11ad8b94907d1e42779f42634ff03f711a43d56f",
  )
}

// ---------- apricot

const apricot = "apricot[uid: 0]"

fn proof_apricot() {
  [
    Branch {
      skip: 0,
      neighbors: #"447bfe8c4bf1ca600d97bc2f6598341c67979d67ca7b3cdaf0a392b80575fc7e646b5405992cba0492ce474312992f1487e29cc3dfeec0a0435b25a379eb8abedc851ded98b63414c014f852aa0c114db1974a9c5bda20795ef0e9f03130426d209a78c802ca1941fe8b491b8f0adc38a281dc457c01c072b804c586378e5560",
    },
  ]
}

fn without_apricot() {
  mpf.from_root(
    #"006943d8c77194247e810640b2a1529b6cc5ae28dbe67983af437878ac302a19",
  )
}

// ---------- banana

const banana = "banana[uid: 218]"

fn proof_banana() {
  [
    Branch {
      skip: 0,
      neighbors: #"899142f03e13ad2ed401d17d5bac5628a58add60ec8ffcc0b0d7a6eb57aad36ca3b77dadcbca90990c16d735e4150bbe5d5d9579839e0d73b1282f7aafb68694dab1505ca7cad09d07a58094b0a5f23dc1fc3d51123989f74f7d9a22813177e733df330965d73e9e04af8f0c33d640199c1fb6feb8c168366b3420198f3aee5f",
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
    #"7c3ebed986e12aca4d235de694ce871ce751778d3ebfac488709624e8158c3f8",
  )
}

// ---------- blueberry

const blueberry = "blueberry[uid: 0]"

fn proof_blueberry() {
  [
    Branch {
      skip: 0,
      neighbors: #"447bfe8c4bf1ca600d97bc2f6598341c67979d67ca7b3cdaf0a392b80575fc7efc64c0e5b5ce77aa905c7a385db5a5ebd5e5cd149d5f3347aec43652116eb00df5440f38c1222ec62adf16ce5101d64ebbc2758c3e1dc8713360790cc3de5c3ba13acbf5484414d7321967167a7ab9234bd9e77428a3c24a4a1da34b0bc5f91b",
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
    #"09ba0c3f99b0d9a7ec69553fff547435b47120db781718dc2702a2402a972391",
  )
}

// ---------- cherry

const cherry = "cherry[uid: 0]"

fn proof_cherry() {
  [
    Branch {
      skip: 0,
      neighbors: #"899142f03e13ad2ed401d17d5bac5628a58add60ec8ffcc0b0d7a6eb57aad36ca3b77dadcbca90990c16d735e4150bbe5d5d9579839e0d73b1282f7aafb6869478da1a8dd3382768d831fd8eb245041dac6e8640fa296a2fc998e827b482f51ba8b499ebb15a73dfeb65f82dff989cfe7f1ed1df191eb9ab6f93decfb8c625f6",
    },
    Branch {
      skip: 3,
      neighbors: #"224fe86e8af76a8a43e29d4bdb9b6b5b21c8e450a5247f1a1d16afd7059c350685c09af929492a871e4fae32d9d5c36e352471cd659bcdb61de08f1722acc3b10eb923b0cbd24df54401d998531feead35a47a99f4deed205de4af81120f97610000000000000000000000000000000000000000000000000000000000000000",
    },
  ]
}

fn without_cherry() {
  mpf.from_root(
    #"1c6ecea0b38814f75d751ab458855638fda807502f17a9fa728351558d96d68f",
  )
}

// ---------- coconut

const coconut = "coconut[uid: 0]"

fn proof_coconut() {
  [
    Branch {
      skip: 0,
      neighbors: #"447bfe8c4bf1ca600d97bc2f6598341c67979d67ca7b3cdaf0a392b80575fc7e646b5405992cba0492ce474312992f1487e29cc3dfeec0a0435b25a379eb8abe26b3f862bd47fab715ec5830f0e88f97a17a48c281d94e3bc7d8e1a105ba9279d653df9bae612b1ccabf95fa85eb9063296f585b6f18c66bb95f00b94f1f7292",
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
    #"57e2a2581d1a2faf52ab53d0bcdc203abb7b1fa9d646029dbff24a4f783ad538",
  )
}

// ---------- cranberry

const cranberry = "cranberry[uid: 0]"

fn proof_cranberry() {
  [
    Branch {
      skip: 0,
      neighbors: #"447bfe8c4bf1ca600d97bc2f6598341c67979d67ca7b3cdaf0a392b80575fc7e646b5405992cba0492ce474312992f1487e29cc3dfeec0a0435b25a379eb8abe26b3f862bd47fab715ec5830f0e88f97a17a48c281d94e3bc7d8e1a105ba927917d9adcb708f54415e219b926a79fdef815a224a675fc5ac08455e7cf145e8ae",
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
    #"79aaed7a2535df048a3568b1a2f0d120e592a947ac65725f68d4029eb094c866",
  )
}

// ---------- fig

const fig = "fig[uid: 68267]"

fn proof_fig() {
  [
    Branch {
      skip: 0,
      neighbors: #"447bfe8c4bf1ca600d97bc2f6598341c67979d67ca7b3cdaf0a392b80575fc7efc64c0e5b5ce77aa905c7a385db5a5ebd5e5cd149d5f3347aec43652116eb00df5440f38c1222ec62adf16ce5101d64ebbc2758c3e1dc8713360790cc3de5c3bed869762c74c40e4c3c123666257d46fea9b213fbfa896a0f9aa4716870c98e1",
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
    #"a7002dc0a63642ee9842267ed7f31448f20c61271d0e7b3040383036f9fabb48",
  )
}

// ---------- grapefruit

const grapefruit = "grapefruit[uid: 0]"

fn proof_grapefruit() {
  [
    Branch {
      skip: 0,
      neighbors: #"447bfe8c4bf1ca600d97bc2f6598341c67979d67ca7b3cdaf0a392b80575fc7efc64c0e5b5ce77aa905c7a385db5a5ebd5e5cd149d5f3347aec43652116eb00df5440f38c1222ec62adf16ce5101d64ebbc2758c3e1dc8713360790cc3de5c3ba13acbf5484414d7321967167a7ab9234bd9e77428a3c24a4a1da34b0bc5f91b",
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
    #"dd23d62570030ea110a04179c7c2e3251a687f51891ec380d1d446096941ab84",
  )
}

// ---------- grapes

const grapes = "grapes[uid: 0]"

fn proof_grapes() {
  [
    Branch {
      skip: 0,
      neighbors: #"447bfe8c4bf1ca600d97bc2f6598341c67979d67ca7b3cdaf0a392b80575fc7e646b5405992cba0492ce474312992f1487e29cc3dfeec0a0435b25a379eb8abedc851ded98b63414c014f852aa0c114db1974a9c5bda20795ef0e9f03130426d5f1fd0952856cadd94dd7faa3b4e7864b2a8074ad19886c8d78a7a0e2ba94be6",
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
    #"9597529514753c206387d0d3504a2377409eddb77c38dc412d6f16dd84717b66",
  )
}

// ---------- guava

const guava = "guava[uid: 344]"

fn proof_guava() {
  [
    Branch {
      skip: 0,
      neighbors: #"899142f03e13ad2ed401d17d5bac5628a58add60ec8ffcc0b0d7a6eb57aad36c478a46cd59964c246193f91eae0b21617f264a0617910167e6b04fb6994bf99417b670e162c676797a65b28c3d8eb7240944a4db76acfee2cd74d93e4684c484630f527d86d14b567a5344b1b5a9227613ca1b57f1eaf69f07db9a578df682cf",
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
    #"dc14f02cbc299e33f53c9481098c7a156bed4ee362febdf817591efc53ef7669",
  )
}

// ---------- kiwi

const kiwi = "kiwi[uid: 0]"

fn proof_kiwi() {
  [
    Branch {
      skip: 0,
      neighbors: #"899142f03e13ad2ed401d17d5bac5628a58add60ec8ffcc0b0d7a6eb57aad36c478a46cd59964c246193f91eae0b21617f264a0617910167e6b04fb6994bf99417b670e162c676797a65b28c3d8eb7240944a4db76acfee2cd74d93e4684c484630f527d86d14b567a5344b1b5a9227613ca1b57f1eaf69f07db9a578df682cf",
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
    #"e5d6d8db38574810f32a692460023bb4d765e4798338e880c804e0a994eaff67",
  )
}

// ---------- kumquat

const kumquat = "kumquat[uid: 0]"

fn proof_kumquat() {
  [
    Branch {
      skip: 0,
      neighbors: #"899142f03e13ad2ed401d17d5bac5628a58add60ec8ffcc0b0d7a6eb57aad36c478a46cd59964c246193f91eae0b21617f264a0617910167e6b04fb6994bf99417b670e162c676797a65b28c3d8eb7240944a4db76acfee2cd74d93e4684c484630f527d86d14b567a5344b1b5a9227613ca1b57f1eaf69f07db9a578df682cf",
    },
    Fork {
      skip: 0,
      neighbor: Neighbor {
        nibble: 0,
        prefix: #"07",
        root: #"8f859c76ce7395be06510f61629ca9090c600d3a31cf9bd55ac89daf2edeb8a3",
      },
    },
  ]
}

fn without_kumquat() {
  mpf.from_root(
    #"e8a8879ae17ca1d2b7c1e2ab79d137f663e480969871f80fe6d4054849af47cf",
  )
}

// ---------- lemon

const lemon = "lemon[uid: 0]"

fn proof_lemon() {
  [
    Branch {
      skip: 0,
      neighbors: #"899142f03e13ad2ed401d17d5bac5628a58add60ec8ffcc0b0d7a6eb57aad36ca3b77dadcbca90990c16d735e4150bbe5d5d9579839e0d73b1282f7aafb6869478da1a8dd3382768d831fd8eb245041dac6e8640fa296a2fc998e827b482f51bea27de91b695e98dc4207f63fffdfcee6210d12c88e086da22f341a69e101bde",
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
    #"946fe9e314a69044fc4a9845fdad262c68abbf73e0420c5a441b2ed3d89448b8",
  )
}

// ---------- lime

const lime = "lime[uid: 0]"

fn proof_lime() {
  [
    Branch {
      skip: 0,
      neighbors: #"899142f03e13ad2ed401d17d5bac5628a58add60ec8ffcc0b0d7a6eb57aad36ca3b77dadcbca90990c16d735e4150bbe5d5d9579839e0d73b1282f7aafb68694dab1505ca7cad09d07a58094b0a5f23dc1fc3d51123989f74f7d9a22813177e733df330965d73e9e04af8f0c33d640199c1fb6feb8c168366b3420198f3aee5f",
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
    #"65c17b5b38bf3548ddb7286ee71f8ea90cd6ed8fb8d9ca564b08cb353c9709b0",
  )
}

// ---------- mango

const mango = "mango[uid: 0]"

fn proof_mango() {
  [
    Branch {
      skip: 0,
      neighbors: #"899142f03e13ad2ed401d17d5bac5628a58add60ec8ffcc0b0d7a6eb57aad36ca3b77dadcbca90990c16d735e4150bbe5d5d9579839e0d73b1282f7aafb6869478da1a8dd3382768d831fd8eb245041dac6e8640fa296a2fc998e827b482f51bea27de91b695e98dc4207f63fffdfcee6210d12c88e086da22f341a69e101bde",
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
    #"1362b038627ab8d62b07b94a42c4a86da1ea35af84b657f8674aa64a3c3e2bf0",
  )
}

// ---------- orange

const orange = "orange[uid: 0]"

fn proof_orange() {
  [
    Branch {
      skip: 0,
      neighbors: #"447bfe8c4bf1ca600d97bc2f6598341c67979d67ca7b3cdaf0a392b80575fc7e646b5405992cba0492ce474312992f1487e29cc3dfeec0a0435b25a379eb8abe26b3f862bd47fab715ec5830f0e88f97a17a48c281d94e3bc7d8e1a105ba927917d9adcb708f54415e219b926a79fdef815a224a675fc5ac08455e7cf145e8ae",
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
    #"6c123876068cd65238bb75c2ae6cc4217e04fd6e61a142e6ad7b9e1a27fad47a",
  )
}

// ---------- papaya

const papaya = "papaya[uid: 0]"

fn proof_papaya() {
  [
    Branch {
      skip: 0,
      neighbors: #"447bfe8c4bf1ca600d97bc2f6598341c67979d67ca7b3cdaf0a392b80575fc7e646b5405992cba0492ce474312992f1487e29cc3dfeec0a0435b25a379eb8abedc851ded98b63414c014f852aa0c114db1974a9c5bda20795ef0e9f03130426d5f1fd0952856cadd94dd7faa3b4e7864b2a8074ad19886c8d78a7a0e2ba94be6",
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
    #"77b82756e5e506c24c110996b6d598285c0147c973b84092d1d5dd587b785a6e",
  )
}

// ---------- passionfruit

const passion = "passionfruit[uid: 0]"

fn proof_passion() {
  [
    Branch {
      skip: 0,
      neighbors: #"447bfe8c4bf1ca600d97bc2f6598341c67979d67ca7b3cdaf0a392b80575fc7efc64c0e5b5ce77aa905c7a385db5a5ebd5e5cd149d5f3347aec43652116eb00df5440f38c1222ec62adf16ce5101d64ebbc2758c3e1dc8713360790cc3de5c3bed869762c74c40e4c3c123666257d46fea9b213fbfa896a0f9aa4716870c98e1",
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
    #"80ac9404038630ce0705c32b3f3266368e05540efc4683dbb7f88b7deba5a69a",
  )
}

// ---------- peach

const peach = "peach[uid: 0]"

fn proof_peach() {
  [
    Branch {
      skip: 0,
      neighbors: #"447bfe8c4bf1ca600d97bc2f6598341c67979d67ca7b3cdaf0a392b80575fc7efc64c0e5b5ce77aa905c7a385db5a5ebd5e5cd149d5f3347aec43652116eb00df5440f38c1222ec62adf16ce5101d64ebbc2758c3e1dc8713360790cc3de5c3bed869762c74c40e4c3c123666257d46fea9b213fbfa896a0f9aa4716870c98e1",
    },
    Fork {
      skip: 0,
      neighbor: Neighbor {
        nibble: 15,
        prefix: #"0102",
        root: #"56750546017adcc3d3c34a83136706cf859a0e4d83ab83c5810bde06d62a249f",
      },
    },
  ]
}

fn without_peach() {
  mpf.from_root(
    #"9e1e8a481362810b1efa5c7f71f7ccab048f7e8656e60787ae987388792893f9",
  )
}

// ---------- pear

const pear = "pear[uid: 0]"

fn proof_pear() {
  [
    Branch {
      skip: 0,
      neighbors: #"447bfe8c4bf1ca600d97bc2f6598341c67979d67ca7b3cdaf0a392b80575fc7e646b5405992cba0492ce474312992f1487e29cc3dfeec0a0435b25a379eb8abe26b3f862bd47fab715ec5830f0e88f97a17a48c281d94e3bc7d8e1a105ba9279d653df9bae612b1ccabf95fa85eb9063296f585b6f18c66bb95f00b94f1f7292",
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
    #"cc61752a598aebc9be796fa831c8052df9b859a6db0a7c6c3b9a457c28f96e28",
  )
}

// ---------- pineapple

const pineapple = "pineapple[uid: 12577]"

fn proof_pineapple() {
  [
    Branch {
      skip: 0,
      neighbors: #"899142f03e13ad2ed401d17d5bac5628a58add60ec8ffcc0b0d7a6eb57aad36ca3b77dadcbca90990c16d735e4150bbe5d5d9579839e0d73b1282f7aafb68694dab1505ca7cad09d07a58094b0a5f23dc1fc3d51123989f74f7d9a22813177e75a59856806074192c6b39d9dc6e33c3ce403745e6ba6b9032dd5df8453669701",
    },
    Branch {
      skip: 2,
      neighbors: #"b7ad6565339d46fb0fa76157416e53d123ebd3f0936f5baa778dda325a512faa85c09af929492a871e4fae32d9d5c36e352471cd659bcdb61de08f1722acc3b10eb923b0cbd24df54401d998531feead35a47a99f4deed205de4af81120f97610000000000000000000000000000000000000000000000000000000000000000",
    },
  ]
}

fn without_pineapple() {
  mpf.from_root(
    #"b947eb25c840299c1f0d024ff931e1ed05ed625da95011659c3a7396be58d690",
  )
}

// ---------- plum

const plum = "plum[uid: 15492]"

fn proof_plum() {
  [
    Branch {
      skip: 0,
      neighbors: #"899142f03e13ad2ed401d17d5bac5628a58add60ec8ffcc0b0d7a6eb57aad36ca3b77dadcbca90990c16d735e4150bbe5d5d9579839e0d73b1282f7aafb6869478da1a8dd3382768d831fd8eb245041dac6e8640fa296a2fc998e827b482f51ba8b499ebb15a73dfeb65f82dff989cfe7f1ed1df191eb9ab6f93decfb8c625f6",
    },
    Branch {
      skip: 3,
      neighbors: #"1662bc10d0087e886b5d2f01c825a8d9f2145ad3f49f402f647f847135dab18185c09af929492a871e4fae32d9d5c36e352471cd659bcdb61de08f1722acc3b1dc3c44304530f63135f400308442328cdbaef8808d070d6435f4002c7e8aa0c60000000000000000000000000000000000000000000000000000000000000000",
    },
  ]
}

fn without_plum() {
  mpf.from_root(
    #"7c7d6699af8aa5aefb74b953ba9c10e4d1b286216e1b896afa29ad8ffcde8d29",
  )
}

// ---------- pomegranate

const pomegranate = "pomegranate[uid: 0]"

fn proof_pomegranate() {
  [
    Branch {
      skip: 0,
      neighbors: #"899142f03e13ad2ed401d17d5bac5628a58add60ec8ffcc0b0d7a6eb57aad36ca3b77dadcbca90990c16d735e4150bbe5d5d9579839e0d73b1282f7aafb68694dab1505ca7cad09d07a58094b0a5f23dc1fc3d51123989f74f7d9a22813177e75a59856806074192c6b39d9dc6e33c3ce403745e6ba6b9032dd5df8453669701",
    },
    Branch {
      skip: 2,
      neighbors: #"4f3aaaa05f8f8c91b931e18abdf87b06309a90082d60b6d24f0988df6b18208ec77f3c552ebcea3511e7dca3e81ab4565df006eb4c1ed0f887a076913e2b6e460eb923b0cbd24df54401d998531feead35a47a99f4deed205de4af81120f97610000000000000000000000000000000000000000000000000000000000000000",
    },
  ]
}

fn without_pomegranate() {
  mpf.from_root(
    #"034143798082fca2291a05f19863a2b6e807071d289afdcf8c21675408349afe",
  )
}

// ---------- raspberry

const raspberry = "raspberry[uid: 0]"

fn proof_raspberry() {
  [
    Branch {
      skip: 0,
      neighbors: #"899142f03e13ad2ed401d17d5bac5628a58add60ec8ffcc0b0d7a6eb57aad36c478a46cd59964c246193f91eae0b21617f264a0617910167e6b04fb6994bf994e51b185a2a629d02baacdf57d1c899c64c1dbf54d0d56a862ba6d7c228728cd90000000000000000000000000000000000000000000000000000000000000000",
    },
  ]
}

fn without_raspberry() {
  mpf.from_root(
    #"940ce5676ce266c43154093d36894f71d1799d85d0a95ca165fd6f73fa45266d",
  )
}

// ---------- strawberry

const strawberry = "strawberry[uid: 2532]"

fn proof_strawberry() {
  [
    Branch {
      skip: 0,
      neighbors: #"899142f03e13ad2ed401d17d5bac5628a58add60ec8ffcc0b0d7a6eb57aad36ca3b77dadcbca90990c16d735e4150bbe5d5d9579839e0d73b1282f7aafb68694dab1505ca7cad09d07a58094b0a5f23dc1fc3d51123989f74f7d9a22813177e75a59856806074192c6b39d9dc6e33c3ce403745e6ba6b9032dd5df8453669701",
    },
    Branch {
      skip: 2,
      neighbors: #"4f3aaaa05f8f8c91b931e18abdf87b06309a90082d60b6d24f0988df6b18208e22e56bbf6c7241b289bb77183a3886e9de14b3128b5d6828b1683fce8101960a0eb923b0cbd24df54401d998531feead35a47a99f4deed205de4af81120f97610000000000000000000000000000000000000000000000000000000000000000",
    },
  ]
}

fn without_strawberry() {
  mpf.from_root(
    #"614c69fd214ea26160b3d01100008ee32d5ec8562da207a34c367084726acbc3",
  )
}

// ---------- tangerine

const tangerine = "tangerine[uid: 11]"

fn proof_tangerine() {
  [
    Branch {
      skip: 0,
      neighbors: #"447bfe8c4bf1ca600d97bc2f6598341c67979d67ca7b3cdaf0a392b80575fc7efc64c0e5b5ce77aa905c7a385db5a5ebd5e5cd149d5f3347aec43652116eb00d6f6f9c4e90449723a793ca0efa177543085092bee776c9f0bb07b55f7ab28c440000000000000000000000000000000000000000000000000000000000000000",
    },
  ]
}

fn without_tangerine() {
  mpf.from_root(
    #"2e8cf977704b57a02751a13b9830db78c2daf53ac0c3118937a33a34c904fc93",
  )
}

// ---------- tomato

const tomato = "tomato[uid: 83468]"

fn proof_tomato() {
  [
    Branch {
      skip: 0,
      neighbors: #"899142f03e13ad2ed401d17d5bac5628a58add60ec8ffcc0b0d7a6eb57aad36ca3b77dadcbca90990c16d735e4150bbe5d5d9579839e0d73b1282f7aafb6869478da1a8dd3382768d831fd8eb245041dac6e8640fa296a2fc998e827b482f51ba8b499ebb15a73dfeb65f82dff989cfe7f1ed1df191eb9ab6f93decfb8c625f6",
    },
    Branch {
      skip: 3,
      neighbors: #"1662bc10d0087e886b5d2f01c825a8d9f2145ad3f49f402f647f847135dab18185c09af929492a871e4fae32d9d5c36e352471cd659bcdb61de08f1722acc3b1bcee113dc2565ad254c77e11a81c023e45b37b4ff5f46f39e1f3124fcbacc30d0000000000000000000000000000000000000000000000000000000000000000",
    },
  ]
}

fn without_tomato() {
  mpf.from_root(
    #"f1d330f03afdd775e6e4f265f1ad8e485bf92dbfce794e9e56581b1b2139a402",
  )
}

// ---------- watermelon

const watermelon = "watermelon[uid: 0]"

fn proof_watermelon() {
  [
    Branch {
      skip: 0,
      neighbors: #"899142f03e13ad2ed401d17d5bac5628a58add60ec8ffcc0b0d7a6eb57aad36c478a46cd59964c246193f91eae0b21617f264a0617910167e6b04fb6994bf99417b670e162c676797a65b28c3d8eb7240944a4db76acfee2cd74d93e4684c4848187d8a3f1cf6ccbfb3a6353704698b8b88030486567ee4e4cf5aa6f5f4e01da",
    },
    Fork {
      skip: 0,
      neighbor: Neighbor {
        nibble: 14,
        prefix: #"",
        root: #"3e23964ec0da6d281eaa6fcd0019c38e73c3f3992a1e1d27708502e32481ac7e",
      },
    },
  ]
}

fn without_watermelon() {
  mpf.from_root(
    #"6ebd18ab09a876693ced1057ff81271ab3381a86365777424e6033c26d36d0c4",
  )
}

// ---------- yuzu

const yuzu = "yuzu[uid: 0]"

fn proof_yuzu() {
  [
    Branch {
      skip: 0,
      neighbors: #"899142f03e13ad2ed401d17d5bac5628a58add60ec8ffcc0b0d7a6eb57aad36c478a46cd59964c246193f91eae0b21617f264a0617910167e6b04fb6994bf99417b670e162c676797a65b28c3d8eb7240944a4db76acfee2cd74d93e4684c4848187d8a3f1cf6ccbfb3a6353704698b8b88030486567ee4e4cf5aa6f5f4e01da",
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
    #"7581769aea592183e35778cda4ed4c663872275ed7e1bd647d4244c4fafacae0",
  )
}
