import test from 'ava';
import { Store } from '../lib/store.js';
import { Leaf, Branch, Proof, Trie } from '../lib/index.js';
import * as helpers from '../lib/helpers.js';
import { inspect } from 'node:util';

const FRUITS_LIST = [
  { key: 'apple[uid: 58]', value: '🍎' },
  { key: 'apricot[uid: 0]', value: '🤷' },
  { key: 'banana[uid: 218]', value: '🍌' },
  { key: 'blueberry[uid: 0]', value: '🫐' },
  { key: 'cherry[uid: 0]', value: '🍒' },
  { key: 'coconut[uid: 0]', value: '🥥' },
  { key: 'cranberry[uid: 0]', value: '🤷' },
  { key: 'fig[uid: 68267]', value: '🤷' },
  { key: 'grapefruit[uid: 0]', value: '🤷' },
  { key: 'grapes[uid: 0]', value: '🍇' },
  { key: 'guava[uid: 344]', value: '🤷' },
  { key: 'kiwi[uid: 0]', value: '🥝' },
  { key: 'kumquat[uid: 0]', value: '🤷' },
  { key: 'lemon[uid: 0]', value: '🍋' },
  { key: 'lime[uid: 0]', value: '🤷' },
  { key: 'mango[uid: 0]', value: '🥭' },
  { key: 'orange[uid: 0]', value: '🍊' },
  { key: 'papaya[uid: 0]', value: '🤷' },
  { key: 'passionfruit[uid: 0]', value: '🤷' },
  { key: 'peach[uid: 0]', value: '🍑' },
  { key: 'pear[uid: 0]', value: '🍐' },
  { key: 'pineapple[uid: 12577]', value: '🍍' },
  { key: 'plum[uid: 15492]', value: '🤷' },
  { key: 'pomegranate[uid: 0]', value: '🤷' },
  { key: 'raspberry[uid: 0]', value: '🤷' },
  { key: 'strawberry[uid: 2532]', value: '🍓' },
  { key: 'tangerine[uid: 11]', value: '🍊' },
  { key: 'tomato[uid: 83468]', value: '🍅' },
  { key: 'watermelon[uid: 0]', value: '🍉' },
  { key: 'yuzu[uid: 0]', value: '🤷' },
];


// -----------------------------------------------------------------------------
// ------------------------------------------------------------------------ Trie
// -----------------------------------------------------------------------------

test('Trie: a new Trie is always empty', t => {
  const trie = new Trie();
  t.true(trie.isEmpty());
});

test('Trie: inspect an empty trie', t => {
  const trie = new Trie();
  t.is(inspect(trie), 'ø');
});

test('Trie: can construct from an empty list', async t => {
  t.deepEqual(await Trie.fromList([]), new Trie());
});

test('Trie: can be constructed from a single value', async t => {
  const pairs = [{ key: 'foo', value: 'bar' }]
  const trie = await Trie.fromList(pairs);

  t.true(trie instanceof Leaf);
  t.is(trie.prefix.length, 64);
  t.is(trie.key.toString(), pairs[0].key);
  t.is(trie.value.toString(), pairs[0].value);
});

test('Trie: can be constructed from two values', async t => {
  const pairs = [
    { key: 'foo', value: '14' },
    { key: 'bar', value: '42' },
  ];

  const trie = await Trie.fromList(pairs);

  t.is(trie.size, 2);
  t.false(trie instanceof Leaf);

  await trie.fetchChildren();

  const foo = await trie.childAt('b');
  t.true(foo instanceof Leaf);
  t.is(foo.prefix.length, 63);
  t.is(foo.key.toString(), pairs[0].key);
  t.is(foo.value.toString(), pairs[0].value);

  const bar = await trie.childAt('8');
  t.true(bar instanceof Leaf);
  t.is(bar.prefix.length, 63);
  t.is(bar.key.toString(), pairs[1].key);
  t.is(bar.value.toString(), pairs[1].value);
});


// -----------------------------------------------------------------------------
// ----------------------------------------------------------------- Trie.insert
// -----------------------------------------------------------------------------

test('Trie.insert: into empty', async t => {
  let trie = new Trie();
  await trie.insert('foo', '14');
  t.true(trie instanceof Leaf);
  t.deepEqual(trie, await Trie.fromList([{ key: 'foo', value: '14' }]));
});

test('Trie.insert: into leaf', async t => {
  const foo = { key: 'foo', value: '14' };
  const bar = { key: 'bar', value: '42' };

  let trie = await Trie.fromList([foo]);
  await trie.insert(bar.key, bar.value);
  t.true(trie instanceof Branch);

  t.deepEqual(trie, await Trie.fromList([foo, bar]));
});

test('Trie.insert: arbitrary', async t => {
  const trie = await FRUITS_LIST.reduce(async (trie, fruit) => {
    return (await trie).insert(fruit.key, fruit.value);
  }, new Trie());

  t.false(trie.children.some(node => node !== undefined && node instanceof Trie))
  t.is(inspect(trie), unindent`
    ╔═══════════════════════════════════════════════════════════════════╗
    ║ #ee57de5169e7be3f32ce7a486e8816c808d7751e7df0a27ab576bf18ef1afbdd ║
    ╚═══════════════════════════════════════════════════════════════════╝
     ┌─ 0 #a8b499ebb15a
     ├─ 1 #ea27de91b695
     ├─ 2 #33df330965d7
     ├─ 3 #5a5985680607
     ├─ 4 #8187d8a3f1cf
     ├─ 5 #630f527d86d1
     ├─ 7 #84301478aa70
     ├─ 8 #a3721b3311f1
     ├─ a #a13acbf54844
     ├─ b #ed869762c74c
     ├─ c #d653df9bae61
     ├─ d #17d9adcb708f
     ├─ e #5f1fd0952856
     └─ f #209a78c802ca
  `);

  const sameTrie = await Trie.fromList(FRUITS_LIST);
  t.deepEqual(trie, sameTrie);

  await Promise.all([
    trie.fetchChildren(Number.MAX_SAFE_INTEGER),
    sameTrie.fetchChildren(Number.MAX_SAFE_INTEGER),
  ]);
  t.deepEqual(trie, sameTrie);
  t.is(inspect(trie), unindent`
    ╔═══════════════════════════════════════════════════════════════════╗
    ║ #ee57de5169e7be3f32ce7a486e8816c808d7751e7df0a27ab576bf18ef1afbdd ║
    ╚═══════════════════════════════════════════════════════════════════╝
     ┌─ 0 #a8b499ebb15a
     │  ├─ 389fd..[54 digits]..1abc #96d6ae0847f4 { mango[uid: 0] → 🥭 }
     │  └─ 9d230..[54 digits]..9ecc #48071b791174 { lemon[uid: 0] → 🍋 }
     ├─ 16a4 #ea27de91b695
     │  ├─ 3a30b..[51 digits]..a968 #2da4e1ef108c { cherry[uid: 0] → 🍒 }
     │  ├─ 8584c..[51 digits]..d4a5 #4c83b85745f7 { tomato[uid: 83468] → 🍅 }
     │  └─ b7ce0..[51 digits]..f157 #522f6b664982 { plum[uid: 15492] → 🤷 }
     ├─ 245 #33df330965d7
     │  ├─ 4c787..[52 digits]..c20e #0f6146c21bf4 { pineapple[uid: 12577] → 🍍 }
     │  ├─ a4f81..[52 digits]..90a3 #4796c959657c { pomegranate[uid: 0] → 🤷 }
     │  └─ e3fc8..[52 digits]..e7c3 #f50a2aad6560 { strawberry[uid: 2532] → 🍓 }
     ├─ 3e #5a5985680607
     │  ├─ d002d..[53 digits]..f3ac #dbf6004ed27d { lime[uid: 0] → 🤷 }
     │  └─ e659e..[53 digits]..b3b9 #83f30b498ad4 { banana[uid: 218] → 🍌 }
     ├─ 4 #8187d8a3f1cf
     │  ├─ 07 #4790f8833717
     │  │  ├─ 6d8ab..[52 digits]..73ef #561a4637b19a { guava[uid: 344] → 🤷 }
     │  │  └─ c5847..[52 digits]..4a22 #f285ef1fbb7f { kiwi[uid: 0] → 🥝 }
     │  └─ a522f..[54 digits]..20cd #c6473b214164 { kumquat[uid: 0] → 🤷 }
     ├─ 5 #630f527d86d1
     │  ├─ cddcd..[54 digits]..aa9e #ebe7d10d20a2 { watermelon[uid: 0] → 🍉 }
     │  └─ e #9b87e6b900b4
     │     ├─ 7ccfe..[53 digits]..4440 #2b33ecc11e12 { yuzu[uid: 0] → 🤷 }
     │     └─ d71f9..[53 digits]..26d2 #bd6f8f57f1c1 { apple[uid: 58] → 🍎 }
     ├─ 78666..[55 digits]..7292 #84301478aa70 { raspberry[uid: 0] → 🤷 }
     ├─ 8af48..[55 digits]..04a8 #a3721b3311f1 { tangerine[uid: 11] → 🍊 }
     ├─ a #a13acbf54844
     │  ├─ 4b927..[54 digits]..3c69 #96e92f4f2632 { peach[uid: 0] → 🍑 }
     │  └─ f12 #de6db29c4829
     │     ├─ a1017..[51 digits]..50e7 #89756ed0f250 { fig[uid: 68267] → 🤷 }
     │     └─ ec412..[51 digits]..71fe #51ae27cca144 { passionfruit[uid: 0] → 🤷 }
     ├─ b #ed869762c74c
     │  ├─ 67e71..[54 digits]..c48b #c2e5213cceec { grapefruit[uid: 0] → 🤷 }
     │  └─ 88701..[54 digits]..949e #64f57b688d7b { blueberry[uid: 0] → 🫐 }
     ├─ c #d653df9bae61
     │  ├─ 5dc3c..[54 digits]..a3f3 #0f186942cf0d { cranberry[uid: 0] → 🤷 }
     │  └─ 8cac1..[54 digits]..c3ca #4bb4b456122b { orange[uid: 0] → 🍊 }
     ├─ d #17d9adcb708f
     │  ├─ b3047..[54 digits]..502a #e6c8d47be96a { coconut[uid: 0] → 🥥 }
     │  └─ f779e..[54 digits]..678a #9f8acb081242 { pear[uid: 0] → 🍐 }
     ├─ e5993..[55 digits]..c9ec #5f1fd0952856 { apricot[uid: 0] → 🤷 }
     └─ f #209a78c802ca
        ├─ 63c88..[54 digits]..21ca #da480b0fea67 { papaya[uid: 0] → 🤷 }
        └─ b69c0..[54 digits]..2145 #88850a4e3205 { grapes[uid: 0] → 🍇 }
  `);

  t.is(trie.store.size, 45);
});


// -----------------------------------------------------------------------------
// ------------------------------------------------------------------ Trie.prove
// -----------------------------------------------------------------------------

test('Trie: can create proof for leaf-trie for existing element', async t => {
  const trie = await Trie.fromList([{ key: 'foo', value: '14' }]);
  const proof = await trie.prove('foo');
  t.is(
    proof.verify().toString('hex'),
    trie.hash.toString('hex'),
  );
});

test('Trie: cannot create proof for leaf-trie for non-existing elements', async t => {
  const trie = await Trie.fromList([{ key: 'foo', value: '14' }]);
  const proof = await trie.prove('bar');
  t.throws(() => proof.verify());
});

test('Trie: can create proof for simple tries', async t => {
  const pairs = [
    { key: 'foo', value: '14' },
    { key: 'bar', value: '42' },
  ];

  const trie = await Trie.fromList(pairs);
  t.is(trie.size, 2);
  await trie.fetchChildren(1);
  t.is(inspect(trie), unindent`
    ╔═══════════════════════════════════════════════════════════════════╗
    ║ #5e68dce55d03ea2ff4093cb88e6a6c5ad5fca7943800683cfebef6007787d04c ║
    ╚═══════════════════════════════════════════════════════════════════╝
     ┌─ 84418..[55 digits]..e71d #96eed322c80b { bar → 42 }
     └─ b8fe9..[55 digits]..49fd #6fbcdcf84771 { foo → 14 }
  `);

  const proofs = {
    foo: await trie.prove('foo'),
    bar: await trie.prove('bar'),
  };

  t.true(proofs.foo.verify().equals(trie.hash));
  t.true(proofs.bar.verify().equals(trie.hash));

  await t.throwsAsync(() => trie.prove('fo'));
  await t.throwsAsync(() => trie.prove('ba'));
  await t.throwsAsync(() => trie.prove('foobar'));
});

test('Trie: checking for membership & insertion on complex trie', async t => {
  const trie = await Trie.fromList(FRUITS_LIST);

  t.is(trie.size, 30);

  FRUITS_LIST.forEach(async fruit => {
    const proof = await trie.prove(fruit.key);

    // Prove membership
    t.true(proof.verify(true).equals(trie.hash), fruit.key);

    const trieWithout = await Trie.fromList(FRUITS_LIST.filter(x => x.key !== fruit.key));

    // Prove insertion
    t.true(proof.verify(false).equals(trieWithout.hash), fruit.key);

    // For (re-)generating Aiken code for proofs.
    //
    // const fruitName = fruit.key.split("[")[0];
    // console.log(`// ---------- ${fruitName}\n`);
    // console.log(`const ${fruitName} = "${fruit.key}"`);
    // console.log(`fn proof_${fruitName}() {\n${proof.toAiken()}\n}\n`);
    // console.log(`fn without_${fruitName}() {\n  mpf.from_root(#"${trieWithout.hash.toString('hex')}")\n}\n\n`);
  });
});


// -----------------------------------------------------------------------------
// ---------------------------------------------------------------- Test Helpers
// -----------------------------------------------------------------------------

function unindent(str) {
  const lines = str[0].split('\n').filter(n => n.length > 0);
  const n = (lines[0] || '').length - (lines[0] || '').trimStart().length;
  return lines.map(s => s.slice(n)).join('\n').trimEnd();
}

function shuffle(xs) {
  return xs
    .map(origin => ({ origin, score: Math.random() }))
    .sort((a, b) => a.score - b.score)
    .map(({ origin }) => origin);
}
