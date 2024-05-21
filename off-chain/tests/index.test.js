import test from 'ava';
import { Leaf, BranchNode, Proof, Tree, digest } from '../lib/index.js';
import * as helpers from '../lib/helpers.js';
import { inspect } from 'node:util';

const FRUITS_LIST = [
    'apple',
    'banana',
    'blackberry',
    'blueberry',
    'cherry',
    'coconut',
    'cranberry',
    'durian',
    'fig',
    'grape',
    'grapefruit',
    'guava',
    'kiwi',
    'kumquat',
    'lemon',
    'lime',
    'mango',
    'orange',
    'papaya',
    'passionfruit',
    'peach',
    'pear',
    'pineapple',
    'plum',
    'pomegranate',
    'raspberry',
    'strawberry',
    'watermelon',
];

// ------------------------------------------------------------------------ Leaf

test('Leaf: a new Leaf is a Leaf', t => {
  const tree = new Leaf('00000000', 'value');
  t.true(tree instanceof Leaf);
});

test('Leaf: inspect with human-readable key', t => {
  const tree = new Leaf('00000000', 'value');
  t.is(inspect(tree), '00000000 → value');
});


// ------------------------------------------------------------------------ BranchNode

test('BranchNode: is not empty', t => {
  const tree = new BranchNode('', {
    1: new Leaf('01', '14'),
    2: new Leaf('02', '42'),
  });
  t.false(tree.isEmpty());
});

test('BranchNode: inspect a simple one-level tree', t => {
  const tree = new BranchNode('', {
    1: new Leaf('01', '14'),
    2: new Leaf('02', '42'),
  });
  t.is(inspect(tree), unindent`
    ╔═══════════════════════════════════════════════════════════════════╗
    ║ #2781af6c16c2da267d64825c0348ade4ab73927d602fd1c9459f317e63841fb8 ║
    ╚═══════════════════════════════════════════════════════════════════╝
     ┌─ 101 → 14
     └─ 202 → 42
  `);
});

test('BranchNode: inspect complex trees', t => {
  const tree = new BranchNode('0000', {
      1: new BranchNode('01', {
        0: new Leaf('00', '14'),
        'f': new Leaf('ff', '1337'),
      }),
      2: new Leaf('02', '42'),
      9: new Leaf('09', '999'),
  });
  t.is(inspect(tree), unindent`
    ╔═══════════════════════════════════════════════════════════════════╗
    ║ #0e5435b5bde2452c7357a6fb2f1bce9b3c43a648c04a2f0498c07c1146bc1f6b ║
    ╚═══════════════════════════════════════════════════════════════════╝
     0000
     ├─ 101 #a8048fe39838
     │  ├─ 000 → 14
     │  └─ fff → 1337
     ├─ 202 → 42
     └─ 909 → 999
  `);
});


// ------------------------------------------------------------------------- Tree

test('Tree: a new Tree is always empty', t => {
  const tree = new Tree();
  t.true(tree.isEmpty());
});

test('Tree: inspect an empty tree', t => {
  const tree = new Tree();
  t.is(inspect(tree), 'ø');
});

test('Tree: can construct from an empty list', t => {
  t.deepEqual(Tree.fromList([]), new Tree());
});

test('Tree: can be constructed from a single value', t => {
  const values = [ 'foo' ]
  const tree = Tree.fromList(values);

  t.true(tree instanceof Leaf);
  t.is(tree.prefix.length, 64);
  t.is(tree.value.toString(), values[0]);
});

test('Tree: can be constructed from two values', t => {
  const values = [ 'foo', 'bar' ];

  const tree = Tree.fromList(values);

  t.is(tree.size, 2);
  t.false(tree instanceof Leaf);

  const foo = tree.children[11];
  t.true(foo instanceof Leaf);
  t.is(foo.prefix.length, 63);
  t.is(foo.value.toString(), values[0]);

  const bar = tree.children[8];
  t.true(bar instanceof Leaf);
  t.is(bar.prefix.length, 63);
  t.is(bar.value.toString(), values[1]);
});

test('Tree: can create proof for leaf-tree for existing element', t => {
  const tree = Tree.fromList(['foo']);
  const proof = tree.prove('foo');

  t.deepEqual(proof.steps, []);

  t.is(
    proof.verify().toString('hex'),
    tree.hash.toString('hex'),
  );
});

test('Tree: cannot create proof for leaf-tree for non-existing elements', t => {
  const tree = Tree.fromList(['foo']);
  t.throws(() => tree.prove('bar'));
});

test('Tree: can create proof for simple trees', t => {
  const values = [ 'foo', 'bar' ].map(Buffer.from);

  /*
  ╔═══════════════════════════════════════════════════════════════════╗
  ║ #6d9a495a9352061d331fd6039e97297aec9591b291b61f4d46d28c6a9b302577 ║
  ╚═══════════════════════════════════════════════════════════════════╝
   ┌─ 84418..[55 digits]..e71d → bar
   └─ b8fe9..[55 digits]..49fd → foo
  */
  const tree = Tree.fromList(values);

  t.is(tree.size, 2);

  const proofs = {
    foo: tree.prove('foo'),
    bar: tree.prove('bar'),
  };

  t.true(proofs.foo.verify().equals(tree.hash));
  t.is(proofs.foo.steps.length, 1);

  t.true(proofs.bar.verify().equals(tree.hash));
  t.is(proofs.bar.steps.length, 1);

  t.throws(() => tree.prove('fo'));
  t.throws(() => tree.prove('ba'));
  t.throws(() => tree.prove('foobar'));
});

test('Tree: can create proof for complex trees', t => {
  const values = FRUITS_LIST.map(Buffer.from);

  /*
  ╔═══════════════════════════════════════════════════════════════════╗
  ║ #18c56d4fb717703237c19903ca4c58e94e66dd49ccaad1b20665d8a0fec7e081 ║
  ╚═══════════════════════════════════════════════════════════════════╝
   ┌─ 09ad7..[55 digits]..19d9 → apple
   ├─ 12b59..[55 digits]..9386 → durian
   ├─ 2 #98cd7528f92a
   │  ├─ 36e5e..[54 digits]..97f6 → cranberry
   │  └─ 9d848..[54 digits]..e47b → grapefruit
   ├─ 3 #6f923a110c88
   │  ├─ 70a5c..[54 digits]..bd36 → orange
   │  └─ 9cd47..[54 digits]..9e65 → blueberry
   ├─ 4c4ce..[55 digits]..8230 → watermelon
   ├─ 5 #4b5ee2d337f1
   │  ├─ 4d444..[54 digits]..9f76 → banana
   │  └─ acb40..[54 digits]..7a07 → grape
   ├─ 7 #dbfd99280a60
   │  ├─ 0abba..[54 digits]..81c3 → lime
   │  └─ 548bb..[54 digits]..f3a9 → lemon
   ├─ 8 #6fcc4950bc99
   │  ├─ c0dfd..[54 digits]..ae0e → pineapple
   │  ├─ dafdb..[54 digits]..00ca → blackberry
   │  └─ f #e1231b489fe6
   │     ├─ 04b7b..[53 digits]..adc6 → cherry
   │     └─ 7033a..[53 digits]..6a64 → fig
   ├─ a #d9447ec94c48
   │  ├─ 3d7d4..[54 digits]..f988 → kumquat
   │  └─ a2fb0..[54 digits]..4587 → coconut
   ├─ b8 #e9f8df4e5ca0
   │  ├─ 884aa..[53 digits]..ad80 → raspberry
   │  └─ aad88..[53 digits]..fcf0 → pear
   ├─ c49a4..[55 digits]..3565 → peach
   ├─ d #4a8837353ceb
   │  ├─ 4a3ea..[54 digits]..7bd9 → passionfruit
   │  └─ 8bf23..[54 digits]..eca7 → strawberry
   ├─ e #3b6f7a6c29e1
   │  ├─ 5a02a..[54 digits]..37b6 → papaya
   │  └─ 6 #ba86887bf06b
   │     ├─ 4d91f..[53 digits]..0cfe → guava
   │     └─ 7e298..[53 digits]..d9d1 → mango
   └─ f #177cab65ae5d
      ├─ 3 #9a4b2591979d
      │  ├─ 2e49b..[53 digits]..9728 → pomegranate
      │  └─ 7d2a6..[53 digits]..d578 → kiwi
      └─ a3c8d..[54 digits]..52ff → plum
  */
  const tree = Tree.fromList(values);

  const proofs = FRUITS_LIST.reduce((acc, fruit) => {
    acc[fruit.toString()] = tree.prove(fruit);
    return acc;
  }, {});

  // digest('apple') = 09ad...
  assertProof(
    t,
    tree.hash,
    proofs.apple,
    [
      {
        skip: 0,
        neighbors: Array.from('12345678abcdef').map(x => tree.childAt(x)),
      }
    ]
  );

  // digest('lime') = 70ab...
  assertProof(
    t,
    tree.hash,
    proofs.lime,
    [
      {
        skip: 0,
        neighbors: Array.from('01234568abcdef').map(x => tree.childAt(x)),
      },
      {
        skip: 0,
        neighbors: [
          tree.childAt('75'),
        ]
      },
    ]
  );

  // digest('raspberry') = b888...
  assertProof(
    t,
    tree.hash,
    proofs.raspberry,
    [
      {
        skip: 0,
        neighbors: Array.from('012345678acdef').map(x => tree.childAt(x)),
      },
      {
        skip: 1,
        neighbors: [
          tree.childAt('ba'),
        ]
      }
    ]
  );

  // digest('kiwi') = f37d...
  assertProof(
    t,
    tree.hash,
    proofs.kiwi,
    [
      {
        skip: 0,
        neighbors: Array.from('012345678abcde').map(x => tree.childAt(x)),
      },
      {
        skip: 0,
        neighbors: [
          tree.childAt('fa'),
        ]
      },
      {
        skip: 0,
        neighbors: [
          tree.childAt('f32'),
        ]
      }
    ]
  );

  // digest('mulberry') = b62c...
  t.throws(() => tree.prove('mulberry'));
});

test('Tree: checking for insertion', t => {
  /*
   ╔═══════════════════════════════════════════════════════════════════╗
   ║ #28264c9e300e2ec8433c07d839042b7681fe85df6ab6a83b39d5f4dbf51b3ae7 ║
   ╚═══════════════════════════════════════════════════════════════════╝
    ┌─ 09ad7..[55 digits]..19d9 → apple
    └─ fa3c8..[55 digits]..52ff → plum
  */
  const st0 = Tree.fromList([ 'apple', 'plum' ]);

  /*
   ╔═══════════════════════════════════════════════════════════════════╗
   ║ #a694e4b261e7650bdc9f99279ea092b3be9e6e7eb5d1bb4836ca64c9784c8259 ║
   ╚═══════════════════════════════════════════════════════════════════╝
    ┌─ 09ad7..[55 digits]..19d9 → apple
    └─ f #9c0875c21f33
       ├─ 37d2a..[54 digits]..d578 → kiwi
       └─ a3c8d..[54 digits]..52ff → plum
  */
  const st1 = Tree.fromList([ 'apple', 'kiwi', 'plum' ]);

  /*
   ╔═══════════════════════════════════════════════════════════════════╗
   ║ #b3ea3161299926db3326f74edaea9f5bc4879f2ff46eea251eeb11e60010b4c5 ║
   ╚═══════════════════════════════════════════════════════════════════╝
    ┌─ 09ad7..[55 digits]..19d9 → apple
    └─ f #eb2355dcead1
       ├─ 3 #843cadeff6b7
       │  ├─ 2e49b..[53 digits]..9728 → pomegranate
       │  └─ 7d2a6..[53 digits]..d578 → kiwi
       └─ a3c8d..[54 digits]..52ff → plum
  */
  const st2 = Tree.fromList([ 'apple', 'pomegranate', 'kiwi', 'plum' ]);

  // Insert 'kiwi' into st0
  t.true(st1.prove('kiwi').verify(false).equals(st0.hash));

  // Doesn't work if one tries to add extra elements.
  t.false(st2.prove('kiwi').verify(false).equals(st0.hash));

  // Doesn't work with proof of another element
  t.false(st2.prove('plum').verify(false).equals(st0.hash));

  // Insert 'pomegranate' into st1
  t.true(st2.prove('pomegranate').verify(false).equals(st1.hash));
})


// ---------------------------------------------------------------------- Helpers

test('commonPrefix: empty words', t => {
  t.throws(() => helpers.commonPrefix([]));
});

test('commonPrefix: empty word', t => {
  t.throws(() => helpers.commonPrefix(['merkle-patricia-tree', '']));
});

test('commonPrefix: two identical strings', t => {
  const prefix = helpers.commonPrefix([
    'merkle-patricia-tree',
    'merkle-patricia-tree',
  ]);

  t.is(prefix, 'merkle-patricia-tree');
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


// ----------------------------------------------------------------- Test Helpers

function unindent(str) {
  const lines = str[0].split('\n').filter(n => n.length > 0);
  const n = (lines[0] || '').length - (lines[0] || '').trimStart().length;
  return lines.map(s => s.slice(n)).join('\n').trimEnd();
}

function assertProof(t, root, proof, expected) {
  t.is(proof.verify().toString('hex'), root.toString('hex'));
  proof.steps.forEach((step, k) => {
    t.is(step.skip, expected[k].skip);
    t.deepEqual(
      step.neighbors.flatMap(x => {
        return x === undefined
          ? []
          : [x.toString('hex')]
      }),
      expected[k].neighbors.flatMap(x => {
        return x === undefined
          ? []
          : [x.hash.toString('hex')];
      }),
    );
  });
}
