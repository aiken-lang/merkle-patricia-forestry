import test from 'ava';
import { Leaf, Branch, Proof, Trie, digest, merkleRoot } from '../lib/index.js';
import * as helpers from '../lib/helpers.js';
import { inspect } from 'node:util';

const FRUITS_LIST = [
  'apple (0)',
  'apricot (0)',
  'banana (328)',
  'blackberry (0)',
  'blueberry (92383)',
  'cherry (0)',
  'coconut (0)',
  'cranberry (0)',
  'durian (0)',
  'fig (0)',
  'grape (110606)',
  'grapefruit (0)',
  'guava (0)',
  'kiwi (0)',
  'kumquat (0)',
  'lemon (37694)',
  'lime (0)',
  'mango (0)',
  'orange (36703)',
  'papaya (0)',
  'passionfruit (0)',
  'peach (0)',
  'pear (0)',
  'pineapple (0)',
  'plum (0)',
  'pomegranate (113)',
  'raspberry (0)',
  'strawberry (0)',
  'watermelon (20)',
  'yuzu (0)',
];

// ------------------------------------------------------------------------ Trie

test('Trie: a new Trie is always empty', t => {
  const trie = new Trie();
  t.true(trie.isEmpty());
});

test('Trie: inspect an empty trie', t => {
  const trie = new Trie();
  t.is(inspect(trie), 'ø');
});

test('Trie: can construct from an empty list', t => {
  t.deepEqual(Trie.fromList([]), new Trie());
});

test('Trie: can be constructed from a single value', t => {
  const values = [ 'foo' ]
  const trie = Trie.fromList(values);

  t.true(trie instanceof Leaf);
  t.is(trie.prefix.length, 64);
  t.is(trie.value.toString(), values[0]);
});

test('Trie: can be constructed from two values', t => {
  const values = [ 'foo', 'bar' ];

  const trie = Trie.fromList(values);

  t.is(trie.size, 2);
  t.false(trie instanceof Leaf);

  const foo = trie.children[11];
  t.true(foo instanceof Leaf);
  t.is(foo.prefix.length, 63);
  t.is(foo.value.toString(), values[0]);

  const bar = trie.children[8];
  t.true(bar instanceof Leaf);
  t.is(bar.prefix.length, 63);
  t.is(bar.value.toString(), values[1]);
});

test('Trie: can create proof for leaf-trie for existing element', t => {
  const trie = Trie.fromList(['foo']);
  const proof = trie.prove('foo');

  t.deepEqual(proof.steps, []);

  t.is(
    proof.verify().toString('hex'),
    trie.hash.toString('hex'),
  );
});

test('Trie: cannot create proof for leaf-trie for non-existing elements', t => {
  const trie = Trie.fromList(['foo']);
  t.throws(() => trie.prove('bar'));
});

test('Trie: can create proof for simple tries', t => {
  const values = [ 'foo', 'bar' ].map(Buffer.from);

  const trie = Trie.fromList(values);
  t.is(trie.size, 2);
  t.is(inspect(trie), unindent`
    ╔═══════════════════════════════════════════════════════════════════╗
    ║ #b654ab8233d11434a115369eafaee571d10c01c615e9fd41c37c0bbc62e0b1a4 ║
    ╚═══════════════════════════════════════════════════════════════════╝
     ┌─ 84418..[55 digits]..e71d #80980aea9d27 → bar
     └─ b8fe9..[55 digits]..49fd #9cadc73321de → foo
  `);

  const proofs = {
    foo: trie.prove('foo'),
    bar: trie.prove('bar'),
  };

  t.true(proofs.foo.verify().equals(trie.hash));
  t.is(proofs.foo.steps.length, 1);

  t.true(proofs.bar.verify().equals(trie.hash));
  t.is(proofs.bar.steps.length, 1);

  t.throws(() => trie.prove('fo'));
  t.throws(() => trie.prove('ba'));
  t.throws(() => trie.prove('foobar'));
});

test('Trie: checking for membership & insertion on complex trie', t => {
  const trie = Trie.fromList(FRUITS_LIST);

  t.is(inspect(trie), unindent`
    ╔═══════════════════════════════════════════════════════════════════╗
    ║ #8a66b5d3cde7b9fb5370b9fcfcd0acd12a045423ecff85b439738b6a0796d9b7 ║
    ╚═══════════════════════════════════════════════════════════════════╝
     ┌─ 066d2..[55 digits]..c160 #f25d1f3e731b → cranberry (0)
     ├─ 138b #4e814491dc50
     │  ├─ 407b7..[51 digits]..c445 #919e613fe7b9 → fig (0)
     │  └─ c45c2..[51 digits]..769a #48ad7766c6f8 → orange (36703)
     ├─ 3 #a5631e5347a6
     │  ├─ 378b5..[54 digits]..d05e #e9eca31fe449 → blackberry (0)
     │  └─ f6cea..[54 digits]..9059 #4932e8645de3 → grapefruit (0)
     ├─ 45708..[55 digits]..d238 #ff0edb5bcd46 → strawberry (0)
     ├─ 55 #7ff262d84793
     │  ├─ 258d0..[53 digits]..5fd1 #723a329d15c8 → pear (0)
     │  └─ d5551..[53 digits]..719c #9f1649f013cf → banana (328)
     ├─ 6 #d6f002e80af7
     │  ├─ 29347..[54 digits]..996e #5ff4152c6c64 → plum (0)
     │  ├─ 7642e..[54 digits]..e791 #d984adaf73f7 → guava (0)
     │  ├─ a9150..[54 digits]..f64e #e124d5f9f4b6 → cherry (0)
     │  └─ f4ea6..[54 digits]..473f #01a804893a0a → lime (0)
     ├─ 7cf7b..[55 digits]..eb70 #6f90ba97b215 → apple (0)
     ├─ 993e2..[55 digits]..b3af #a87398cb4efe → mango (0)
     ├─ a #f622b17984c8
     │  ├─ 120d7..[54 digits]..5b19 #d823212af2c8 → pineapple (0)
     │  ├─ 454a2..[54 digits]..6a37 #fd19d19f2f77 → durian (0)
     │  ├─ 8bf57..[54 digits]..2fca #c7d47f4ec10a → papaya (0)
     │  ├─ 909ba..[54 digits]..1e87 #386409826e4a → apricot (0)
     │  ├─ af5cb..[54 digits]..15c6 #064a8065a738 → kumquat (0)
     │  └─ f7cd6..[54 digits]..b859 #8f69234c7851 → coconut (0)
     ├─ b #58fd96cee52e
     │  ├─ a830d..[54 digits]..da75 #4663aa5b8efe → raspberry (0)
     │  └─ d0f99..[54 digits]..4595 #dc420faa3237 → yuzu (0)
     ├─ c8553..[55 digits]..aad3 #5361d160bd0f → peach (0)
     ├─ e #51255842cc98
     │  ├─ 0d9ff..[54 digits]..e35d #50e1bef1f340 → kiwi (0)
     │  └─ 385 #635706e95792
     │     ├─ 22318..[51 digits]..7814 #c9002066f807 → lemon (37694)
     │     └─ 64f70..[51 digits]..3c0b #7bdba6df08a5 → grape (110606)
     └─ f #27d1f4677013
        ├─ 6 #7bbac624e21f
        │  ├─ 74 #2e2cf893f8cd
        │  │  ├─ 60e1a..[51 digits]..d432 #4ee055982ee3 → passionfruit (0)
        │  │  └─ b9b0c..[51 digits]..5b98 #1d16215a4fb8 → blueberry (92383)
        │  └─ d8c90..[53 digits]..df1a #a54def540220 → pomegranate (113)
        └─ 77af1..[54 digits]..ce06 #415dcee4a96c → watermelon (20)
  `);

  FRUITS_LIST.forEach(fruit => {
    const proof = trie.prove(fruit);

    // Prove membership
    t.true(proof.verify(true).equals(trie.hash), fruit);

    const trieWithout = Trie.fromList(FRUITS_LIST.filter(x => x !== fruit));

    // Prove insertion
    t.true(proof.verify(false).equals(trieWithout.hash), fruit);

    // For (re-)generating Aiken code for proofs.
    //
    // const fruit_name = fruit.split(' (')[0];
    //
    // console.log(`// ---------- ${fruit_name}\n`);
    // console.log(`fn proof_${fruit_name}() {\n${proof.toAiken()}\n}\n`);
    // console.log(`fn trie_without_${fruit_name}() {\n  mpt.from_root(#"${trieWithout.hash.toString('hex')}")\n}\n\n`);
  });
});


// --------------------------------------------------------------------- Helpers

test('commonPrefix: empty words', t => {
  t.throws(() => helpers.commonPrefix([]));
});

test('commonPrefix: empty word', t => {
  t.throws(() => helpers.commonPrefix(['merkle-patricia-trie', '']));
});

test('commonPrefix: two identical strings', t => {
  const prefix = helpers.commonPrefix([
    'merkle-patricia-trie',
    'merkle-patricia-trie',
  ]);

  t.is(prefix, 'merkle-patricia-trie');
});

test('commonPrefix: first word is prefix', t => {
  const prefix = helpers.commonPrefix([
    'do',
    'dog',
    'dogs',
  ]);

  t.is(prefix, 'do');
});

test('commonPrefix: last word is prefix', t => {
  const prefix = helpers.commonPrefix([
    'dogs',
    'dog',
    'do',
  ]);

  t.is(prefix, 'do');
});

test('commonPrefix: prefix is anywhere', t => {
  const prefix = helpers.commonPrefix([
    'carda',
    'cardano',
    'card',
    'cardinal',
  ]);

  t.is(prefix, 'card');
});

test('commonPrefix: no common prefix', t => {
  const prefix = helpers.commonPrefix([
    'dog',
    'cat',
    'bird',
  ]);

  t.is(prefix, '');
});


const NULL_HASH = Buffer.alloc(32);

test('merkleRoot: null hashes', t => {
  t.is(
    merkleRoot([NULL_HASH], 1).toString('hex'),
    "0000000000000000000000000000000000000000000000000000000000000000"
  );

  t.is(
    merkleRoot([NULL_HASH, NULL_HASH], 2).toString('hex'),
    "0eb923b0cbd24df54401d998531feead35a47a99f4deed205de4af81120f9761",
  );

  t.is(
    merkleRoot((new Array(4)).fill(NULL_HASH), 4).toString('hex'),
    "85c09af929492a871e4fae32d9d5c36e352471cd659bcdb61de08f1722acc3b1",
  );

  t.is(
    merkleRoot((new Array(8)).fill(NULL_HASH), 8).toString('hex'),
    "b22df1a126b5ba4e33c16fd6157507610e55ffce20dae7ac44cae168a463612a",
  );
});


// ----------------------------------------------------------------- Test Helpers

function unindent(str) {
  const lines = str[0].split('\n').filter(n => n.length > 0);
  const n = (lines[0] || '').length - (lines[0] || '').trimStart().length;
  return lines.map(s => s.slice(n)).join('\n').trimEnd();
}

function stringifyNeighbor(x) {
  if (x == undefined || x instanceof Buffer) {
    return x?.toString('hex');
  }

  return { ...x, value: x.value.toString('hex') };
}


function assertProof(t, root, proof, expected) {
  proof.steps.forEach((step, k) => {
    t.is(step.skip, expected[k].skip);
    t.deepEqual(
      step.neighbors.map(stringifyNeighbor),
      expected[k].neighbors.map(stringifyNeighbor),
    );
  });

  t.is(proof.steps.length, expected.length);

  t.is(proof.verify().toString('hex'), root.toString('hex'));
}
