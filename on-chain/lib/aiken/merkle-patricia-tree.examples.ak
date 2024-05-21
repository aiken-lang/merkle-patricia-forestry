use aiken/merkle_patricia_tree.{MerklePatriciaTree, Proof, ProofStep} as mpt

/// An example tree made from a list of fruits.
///
/// ╔═══════════════════════════════════════════════════════════════════╗
/// ║ #18c56d4fb717703237c19903ca4c58e94e66dd49ccaad1b20665d8a0fec7e081 ║
/// ╚═══════════════════════════════════════════════════════════════════╝
///  ┌─ 09ad7..[55 digits]..19d9 → apple
///  ├─ 12b59..[55 digits]..9386 → durian
///  ├─ 2 #98cd7528f92a
///  │  ├─ 36e5e..[54 digits]..97f6 → cranberry
///  │  └─ 9d848..[54 digits]..e47b → grapefruit
///  ├─ 3 #6f923a110c88
///  │  ├─ 70a5c..[54 digits]..bd36 → orange
///  │  └─ 9cd47..[54 digits]..9e65 → blueberry
///  ├─ 4c4ce..[55 digits]..8230 → watermelon
///  ├─ 5 #4b5ee2d337f1
///  │  ├─ 4d444..[54 digits]..9f76 → banana
///  │  └─ acb40..[54 digits]..7a07 → grape
///  ├─ 7 #dbfd99280a60
///  │  ├─ 0abba..[54 digits]..81c3 → lime
///  │  └─ 548bb..[54 digits]..f3a9 → lemon
///  ├─ 8 #6fcc4950bc99
///  │  ├─ c0dfd..[54 digits]..ae0e → pineapple
///  │  ├─ dafdb..[54 digits]..00ca → blackberry
///  │  └─ f #e1231b489fe6
///  │     ├─ 04b7b..[53 digits]..adc6 → cherry
///  │     └─ 7033a..[53 digits]..6a64 → fig
///  ├─ a #d9447ec94c48
///  │  ├─ 3d7d4..[54 digits]..f988 → kumquat
///  │  └─ a2fb0..[54 digits]..4587 → coconut
///  ├─ b8 #e9f8df4e5ca0
///  │  ├─ 884aa..[53 digits]..ad80 → raspberry
///  │  └─ aad88..[53 digits]..fcf0 → pear
///  ├─ c49a4..[55 digits]..3565 → peach
///  ├─ d #4a8837353ceb
///  │  ├─ 4a3ea..[54 digits]..7bd9 → passionfruit
///  │  └─ 8bf23..[54 digits]..eca7 → strawberry
///  ├─ e #3b6f7a6c29e1
///  │  ├─ 5a02a..[54 digits]..37b6 → papaya
///  │  └─ 6 #ba86887bf06b
///  │     ├─ 4d91f..[53 digits]..0cfe → guava
///  │     └─ 7e298..[53 digits]..d9d1 → mango
///  └─ f #177cab65ae5d
///     ├─ 3 #9a4b2591979d
///     │  ├─ 2e49b..[53 digits]..9728 → pomegranate
///     │  └─ 7d2a6..[53 digits]..d578 → kiwi
///     └─ a3c8d..[54 digits]..52ff → plum
///
fn tree_with_kiwi() -> MerklePatriciaTree {
  mpt.from_root(
    #"18c56d4fb717703237c19903ca4c58e94e66dd49ccaad1b20665d8a0fec7e081",
  )
}

fn tree_without_kiwi() -> MerklePatriciaTree {
  mpt.from_root(
    #"1448c2aebf38a8118b2423a61e85536e5ea9bcacc1e401a20b1d790f1b94d1e4",
  )
}

fn proof_kiwi() -> Proof {
  [
    ProofStep {
      skip: 0,
      neighbors: #"09ad7de5023dec71b2b4d5dc28d296327c6bbd6d47f199cbb9afafc8967d19d912b5969e1ac00e14b24403e65838ffc69ea7e1852ab9155c030d75c66864938698cd7528f92ae3b936e76ccf4309b7c7f02fc0408005610e5c44a7efcf1b32106f923a110c885fc5f1f493764b1f446b57675da3931dffb76b142927bfd6e16e4c4ce1cb3b280c654d8f136bce11607013e35d7e853550cd4f8987a7f70482304b5ee2d337f10321a41e7ba2607571b383c96c1089bcff777402173f866121ebdbfd99280a6080d514445c45a12235c57c0d656d3f737d41f604023f24102b086fcc4950bc9914dd38a49fafbde122dde4b53ff9137462d43914116f114776b5d9447ec94c483b00d9bef9971b95b28fab482fa167d327728af38dbc172a2593e9f8df4e5ca0e5f92c524b901a8af33646c380f264380bfc232dcccffa4d98c8c49a44004794781b41c932a445b517d1089fce5254f60706ad98a1177d3c35654a8837353cebd25ea77b0ec640be317343f75de8c85c766b88f9ca3b0edbe4bb3b6f7a6c29e1898e6986ff0d03e76d41b89cba349d7dc51a2639bce2a695e157",
      lookup: #"0001020304050606070808090a0b0c",
    },
    ProofStep {
      skip: 0,
      neighbors: #"fa3c8defcf0755e85df163420a3eb3cda6ed18b7a5a19b1444c4a34a061852ff",
      lookup: #"000000000000000000000101010101",
    },
    ProofStep {
      skip: 0,
      neighbors: #"f32e49bd278eca612c0f3d876109d58377359a3b04df7a1d68c1fd252a2a9728",
      lookup: #"000000010101010101010101010101",
    },
  ]
}

test example_has_kiwi() {
  mpt.has(tree_with_kiwi(), "kiwi", proof_kiwi())
}

test example_insert_kiwi() {
  mpt.insert(tree_without_kiwi(), "kiwi", proof_kiwi()) == tree_with_kiwi()
}

test example_remove_kiwi() {
  mpt.delete(tree_with_kiwi(), "kiwi", proof_kiwi()) == tree_without_kiwi()
}

test example_already_inserted() fail {
  let root = mpt.insert(tree_with_kiwi(), "kiwi", proof_kiwi())
  root == root
}

test example_delete_non_existing() fail {
  let root = mpt.delete(tree_without_kiwi(), "kiwi", proof_kiwi())
  root == root
}

test example_insert_invalid_proof() fail {
  let root = mpt.delete(tree_without_kiwi(), "pomegranate", proof_kiwi())
  root == root
}
