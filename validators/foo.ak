use aiken/cbor
use aiken/merkle_patricia_forestry as mpf

type Bucket {
  low: Int,
  high: Int,
  delta: Int,
}

test foo() {
  let trie =
    mpf.from_root(
      #"359b8a5d3e5da644700a82c279a4a7e1d75438ef00f2cae39e823168c1f658e4",
    )
  let bucket_1 = Bucket { low: -100, high: 100, delta: 77 }

  let bucket_2 = Bucket { low: -100, high: 25, delta: 77 }

  let bucket_3 = Bucket { low: 25, high: 100, delta: 42 }

  let proof_bucket_1 =
    []

  let proof_bucket_2 =
    []

  let proof_bucket_3 =
    [
      mpf.Leaf {
        skip: 0,
        key: #"43a8b24a6d4cdc8d55f7bb9e7e1c50cf2ea7f6fb865334139c3974ca6fd605c7",
        value: #"21e05df1a16c798570eb7c5a2dbf50f94201e05dd60e539278f855d8576fca3d",
      },
    ]

  let new_trie =
    trie
      |> mpf.delete("-100", cbor.serialise(bucket_1), proof_bucket_1)
      |> mpf.insert("-100", cbor.serialise(bucket_2), proof_bucket_2)
      |> mpf.insert("25", cbor.serialise(bucket_3), proof_bucket_3)

  mpf.from_root(
    #"9303e77c5759a8b3c8412b2e15e3ffeed31c72839d2f5a99e57c1f4a0f13e568",
  ) == new_trie
}
