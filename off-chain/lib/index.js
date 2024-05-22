import blake2b from 'blake2b';
import assert from 'node:assert';
import { inspect } from 'node:util';
import {
  assertInstanceOf,
  commonPrefix,
  eachLine,
  intoVector,
  nibbles,
  withEllipsis,
} from './helpers.js'

export * as helpers from './helpers.js';

// ------------------------------------------------------------------- Constants

/* Size of the digest of the underlying hash algorithm.
 * @private
 */
const DIGEST_LENGTH = 32; // # of bytes

/* Number of nibbles (i.e. hex-digits) to display for intermediate hashes when inspecting a {@link Tree}.
 * @private
 */
const DIGEST_SUMMARY_LENGTH = 12; // # of nibbles

/* Maximum number of nibbles (i.e. hex-digits) to display for prefixes before adding an ellipsis
 * @private
 */
const PREFIX_CUTOFF = 8; // # of nibbles

// ------------------------------------------------------------------------ Tree

/** A Merkle Patricia Tree of radix 16.
 *
 *  The class {@link Tree} is used as a super-class for {@link BranchNode} and
 *  {@link Leaf}. One shouldn't use the latters directly and prefer methods from
 *  {@link Tree}.
 */
export class Tree {
  /** The root hash of the tree.
   *
   * @type {Buffer}
   */
  hash;

  /** The size of the tree; corresponds to the number of nodes (incl. leaves)
   * in the tree
   *
   * @type {number}
   */
  size;

  /** A hex-encoded string prefix, if any.
   *
   * @type {string}
   */
  prefix;

  /** Construct a new empty tree. This constructor is mostly useless. See
   * {@link Tree.fromList} for constructing trees instead.
   */
  constructor() {
    this.size = 0;
    this.hash = Buffer.alloc(DIGEST_LENGTH);
    this.prefix = '';
  }

  /**
   * Test whether a tree is empty (i.e. holds no branch nodes or leaves).
   * @return {bool}
   */
  isEmpty() {
    return this.size == 0;
  }

  /**
   * Construct a Merkle-Patricia {@link Tree} from a list of serialized values.
   *
   * @param {Array<Buffer|string>} values Serialized values.
   * @return {Tree}
   */
  static fromList(values) {
    function loop(branch, keyValues) {
      // ------------------- An empty tree
      if (keyValues.length === 0) {
        return new Tree();
      }

      const prefix = commonPrefix(keyValues.map(kv => kv.key));

      // ------------------- A leaf
      if (keyValues.length === 1) {
        const [kv] = keyValues;
        return new Leaf(
          prefix,
          kv.value,
        );
      }

      // ------------------- A branch node

      // Remove the prefix from all children.
      const stripped = keyValues.map(kv => {
        return { ...kv, key: kv.key.slice(prefix.length) };
      });

      // Construct sub-trees recursively, for each remainining digits.
      //
      // NOTE(1): We have just removed the common prefix from all children, so it
      // safe to look at the first digit of each remaining key and route values
      // based on that. Some branches may be empty, which we replace with 'undefined'.
      //
      // NOTE(2): Because we have at least 2 values at this point, the resulting
      // BranchNode is guaranted to have at least 2 children. They cannot be under the
      // same branch since we have stripped their common prefix!
      const children = Array
        .from('0123456789abcdef')
        .map(digit => loop(digit, stripped.reduce((acc, kv) => {
          assert(kv.key[0] !== undefined, `empty key for node ${kv}`);

          if (kv.key[0] === digit) {
            acc.push({ ...kv, key: kv.key.slice(1) });
          }

          return acc;
        }, [])))
        .map(tree => tree.isEmpty() ? undefined : tree);

      return new BranchNode(prefix, children);
    }

    return loop('', values.map(value => ({ key: intoKey(value), value })));
  }


  /** Conveniently access a child in the tree at the given path. A path is
   * sequence of nibbles, as an hex-encoded string.
   *
   * @param {string} path A sequence of nibbles.
   * @return {Tree|undefined} A sub-tree at the given path, or nothing.
   */
  childAt(path) {
    return Array.from(path).reduce((tree, branch) => {
      const nibble = Number.parseInt(branch, 16);
      return tree?.children[nibble];
    }, this);
  }

  /**
   * Creates a proof of inclusion of a given value in the tree.
   *
   * @param {Buffer|string} value A serialized value from the tree.
   * @return {Proof}
   * @throws {AssertionError} When the value is not in the tree.
   */
  prove(value) {
    return this.walk(intoKey(value));
  }

  /** Walk a tree down a given path, accumulating neighboring nodes along the
   * way to build a proof.
   *
   * @param {string} path A sequence of nibbles.
   * @return {Proof}
   * @throws {AssertionError} When there's no value at the given path in the tree.
   * @private
   */
  walk(path) {
    throw new Error(`cannot walk empty tree with path ${path}`);
  }

  /** Format a sub-tree. This is mostly used in conjunction with inspect.
   * @private
   */
  format(options, body, nibble, join, vertical = ' ') {
    const hash = !(this instanceof Leaf)
      ? options.stylize(
          `#${this.hash.toString('hex').slice(0, DIGEST_SUMMARY_LENGTH)}`,
          'special',
        )
      : '';

    return this instanceof Leaf
      ? `\n ${join}─ ${nibble}${body}`
      : `\n${eachLine(
          body,
          (s, ix) =>
            (ix === 0
                ? ` ${join}─ ${nibble}${this.prefix} ${hash}`
                : ` ${vertical} `
            ) + s
        )}`;
  }

  /** A custom function for inspecting an (empty) Tree.
   * @private
   */
  [inspect.custom](_depth, _options, _inspect) {
    return 'ø';
  }
}


// ------------------------------------------------------------------------ Leaf

/**
 * A {@link Leaf} materializes a {@link Tree} with a **single** node. Leaves
 * are also the only nodes to hold values.
 */
export class Leaf extends Tree {
  /** A serialized value.
   *
   * @type {Buffer}
   */
  value;


  /** Create a new {@link Leaf} from a prefix and a value.
   *
   * @param {string} prefix A sequence of nibble, possibly (albeit rarely) empty. In the
   *                        case of leaves, the prefix should rather be called 'suffix'
   *                        as it describes what remains of the original key.
   *
   * @param {Buffer|string} value A serialized value. Raw strings are treated as UTF-8
   *                              byte buffers.
   * @private
   */
  constructor(prefix, value) {
    super();

    value = typeof value === 'string' ? Buffer.from(value) : value;
    assertInstanceOf(Buffer, { value });
    assertInstanceOf('string', prefix, (what, type) => typeof what === type);

    this.size = 1;
    this.value = value;
    this.setPrefix(prefix, digest(value));
  }


  /** Set the prefix on a Leaf, and computes its corresponding hash. Both steps
   * are done in lock-step because the node's hash crucially includes its prefix.
   *
   * @param {string} prefix A sequence of nibbles.
   * @param {Buffer} hash A hash digest of the value.
   * @return {Tree} A reference to the underlying tree with its prefix modified.
   * @private
   */
  setPrefix(prefix, hash) {
    // NOTE:
    // We append the remaining prefix to the value. However, to make this
    // step more efficient on-chain, we append it as a raw bytestring instead of
    // an array of nibbles.
    //
    // If the prefix's length is odd however, we do still add one nibble, and
    // then the rest.
    const isOdd = prefix.length % 2 > 0;

    const head = isOdd
      ? nibbles(prefix.slice(0, 1))
      : Buffer.from([]);

    const tail = Buffer.from(isOdd
      ? prefix.slice(1)
      : prefix,
      'hex'
    );

    assert(
      hash.length === DIGEST_LENGTH,
      `hash must be a ${DIGEST_LENGTH}-byte digest in 'setPrefix' but it is ${hash?.toString('hex')}`
    );

    this.hash = digest(Buffer.concat([head, tail, hash]));
    this.prefix = prefix;

    return this;
  }


  /**
   * A custom function for inspecting a Leaf, with colors and nice formatting.
   * See {@link https://nodejs.org/api/util.html#utilinspectobject-showhidden-depth-colors}
   * for details.
   *
   * @private
   */
  [inspect.custom](depth, options, _inspect) {
    const hash = options.stylize(
      `#${this.hash.toString('hex').slice(0, DIGEST_SUMMARY_LENGTH)}`,
      'special'
    );

    const prefix = withEllipsis(this.prefix, PREFIX_CUTOFF, options);

    const value = options.stylize(this.value, 'string');

    return `${prefix} ${hash} → ${value}`;
  }


  /** See {@link Tree.walk}
   * @private
   */
  walk(path) {
    assert(
      path.startsWith(this.prefix),
      `element at remaining path ${path} not in tree: non-matching prefix ${this.prefix}`,
    );
    return new Proof(this.value);
  }
}


// ------------------------------------------------------------------------ BranchNode

/**
 * A {@link BranchNode} materializes a {@link Tree} with **at least two** nodes
 * and **at most** 16 nodes.
 *
 */
export class BranchNode extends Tree {
  /** A sparse array of child sub-trees.
   *
   * @type {Array<Tree|undefined>}
   */
  children;

  /**
   * Create a new branch node from a (hex-encoded) prefix and 16 children.
   *
   * @param {string} prefix The accumulated prefix, if any.
   * @param {Array<Tree>|object} children A vector of ordered children, or a
   *                                      key:value map of nibbles to sub-trees.
   *                                      When specifying a vector, there must be
   *                                      exactly 16 elements, with 'undefined' for
   *                                      empty branches.
   * @return {BranchNode}
   * @private
   */
  constructor(prefix = '', children) {
    super();

    children = typeof children === 'object' && children !== null && !Array.isArray(children)
      ? intoVector(children)
      : children;

    // NOTE: We use 'undefined' to represent empty sub-trees mostly because
    //
    // (1) It is convenient.
    // (2) It saves spaces/memory.
    //
    // But this is easy to get wrong due to duck and dynamic typing in JS. So
    // the constructor is extra careful in checking that children are what they
    // should be.
    children.forEach((node, ix) => {
      if (node !== undefined) {
        assertInstanceOf(Tree, { [`children[${ix}]`]: node });
        assert(
          !node.isEmpty(),
          `BranchNode cannot contain empty trees; but children[${ix}] is empty.`
        );
      }
    })

    // NOTE: There are special behaviours associated with trees that contains a
    // single node and this is captured as {@link Leaf}.
    assert(
      children.filter(node => node !== undefined).length > 1,
      'BranchNode must have at *at least 2* children. A BranchNode with a single child is a Leaf.',
    );

    assert(
      children.length === 16,
      'children must be a vector of *exactly 16* elements (possibly undefined)',
    );

    this.size = children.reduce((size, child) => size + (child?.size || 0), 0);
    this.children = children;
    this.setPrefix(
      prefix,
      digest(Buffer.concat(this.children.flatMap(
        node => node === undefined ? [] : [node.hash]
      ))),
    );
  }


  /** Set the prefix on a branch, and computes its corresponding hash. Both steps
   * are done in lock-step because the node's hash crucially includes its prefix.
   *
   * @param {string} prefix A sequence of nibbles.
   * @param {Buffer} hash A hash digest of the value.
   * @return {Tree} A reference to the underlying tree with its prefix modified.
   * @private
   */
  setPrefix(prefix, hash) {
    assert(
      hash.length === DIGEST_LENGTH,
      `hash must be a ${DIGEST_LENGTH}-byte digest in 'setPrefix' but it is ${hash?.toString('hex')}`
    );

    this.hash = digest(Buffer.concat([nibbles(prefix), hash]));
    this.prefix = prefix;

    return this;
  }


  /**
   * See {@link Tree.walk}
   * @private
   */
  walk(path) {
    assert(
      path.startsWith(this.prefix),
      `element at remaining path ${path} not in tree: non-matching prefix ${this.prefix}`,
    );

    const skip = this.prefix.length;

    path = path.slice(skip);

    const branch = Number.parseInt(path[0], 16);
    const child = this.children[branch];

    assert(
      child !== undefined,
      `element at remaining path ${path} not in tree: no child at branch ${branch}`,
    );

    return child.walk(path.slice(1)).rewind(child, skip, this.children);
  }

  /** A custom function for inspecting a BranchNode, with colors and nice formatting.
   * @private
   */
  [inspect.custom](depth, options, inspect) {
    let [head, ...tail] = this.children.filter(node => node !== undefined);

    const branches = this.children.reduce((acc, node, branch) => {
      if (node !== undefined) {
        acc[node.hash] = '0123456789abcdef'[branch];
      }
      return acc;
    }, {});

    // ----- First
    let first = head.format(
      options,
      inspect(head, { ...options, depth: depth + 1 }),
      branches[head.hash],
      depth === 2 && this.prefix.length === 0 ? '┌' : '├',
      '│'
    );
    if (depth === 2 && this.prefix.length > 0) {
      first = `\n ${this.prefix}${first}`
    }

    // ----- In-between
    let between = [];
    tail.slice(0, -1).forEach(node => {
      between.push(node.format(
        options,
        inspect(node, { ...options, depth: depth + 1 }),
        branches[node.hash],
        '├',
        '│',
      ));
    })
    between = between.join('');

    // ----- Last
    let last = tail[tail.length - 1];
    last = last.format(
      options,
      inspect(last, { ...options, depth: depth + 1 }),
      branches[last.hash],
      '└',
    );

    const rootHash = options.stylize(`#${this.hash.toString('hex')}`, 'special');
    const wall = ''.padStart(3 + DIGEST_LENGTH * 2, '═')

    return depth == 2
      ? `╔${wall}╗\n║ ${rootHash} ║\n╚${wall}╝${first}${between}${last}`
      : `${first}${between}${last}`;
  }
}


// ----------------------------------------------------------------------- Proof

/** A self-contained proof of inclusion for a value in a {@link Tree}. A proof
 * holds onto a *specific* value and is only valid for a *specific* {@link Tree}.
 */
export class Proof {
  static #TYPE_LEAF = Symbol('leaf');
  static #TYPE_FORK = Symbol('fork');
  static #TYPE_BRANCH = Symbol('branch');

  /** The value for which this proof is for.
   * @type {Buffer}
   */
  value;

  /** Proof steps, containing neighboring nodes at each level in the tree as well
   * as the size of the prefix for this level. we need not to provide the actual
   * nibbles because they are given by the value's key already.
   *
   * Step's neighbors contains root hashes of neighbors subtrees.
   *
   * @type {Array<{skip: number, neighbors: Array<Buffer|undefined>}>}
   */
  steps;

  /** Construct a new proof from a serialised value. This is mostly useful for
   * proving a {@link Leaf}.
   *
   * @param {Buffer} value
   * @return {Proof}
   * @private
   */
  constructor(value) {
    this.value = value;
    this.steps = [];
  }

  /** Add a step in front of the proof. The proof is built recursively from the
   * bottom-up (from the leaves to the root). At each step in the proof, we
   * rewind one level until we reach the root. At each level, we record the
   * neighbors nodes as well as the length of the prefix.
   *
   * @param {Tree} target Sub-tree on the path we are proving. Excluded from neighbors.
   * @param {number} skip The size of the prefix
   * @param {Array<Tree>} children A list of sub-trees.
   * @return {Proof} The proof itself, with an extra step pre-pended.
   * @private
   */
  rewind(target, skip, children) {
    const neighbors = children.filter(x => !x?.hash.equals(target.hash));

    const nonEmptyNeighbors = neighbors.filter(x => x !== undefined);

    if (nonEmptyNeighbors.length === 1) {
      const neighbor = nonEmptyNeighbors[0];

      this.steps.unshift(neighbor instanceof Leaf
        ? {
            type: Proof.#TYPE_LEAF,
            skip,
            neighbor: digest(neighbor.value),
          }
        : {
            type: Proof.#TYPE_FORK,
            skip,
            neighbor: {
              prefix: nibbles(neighbor.prefix),
              nibble: children.indexOf(neighbor),
              value: digest(Buffer.concat(neighbor.children.flatMap(child =>
                child === undefined ? [] : [child.hash]
              ))),
            }
          }
      );
    } else {
      this.steps.unshift({
        type: Proof.#TYPE_BRANCH,
        skip,
        neighbors: neighbors.map(x => x?.hash),
      });
    }

    return this;
  }


  /** Compute the resulting root hash from this proof. This methods has two modes:
   *
   * - One that includes the value leaf in the proof and computes the
   * - One that computes the root without the element.
   *
   * The second mode is useful to prove insertion and removal of an element in
   * a tree. Consider a tree T0 that doesn't contain an element e, and a tree T1
   * that is T0 with e inserted. Then, one can provide a proof for e in T1.
   *
   * Computing the proof without e will yield T0's hash, whereas computing it
   * with e will yield T1.
   *
   * @param {bool} [withElement=true] When set, computes the resulting root hash
   *                                  considering the underlying value is in the
   *                                  tree.
   * @return {Buffer} A resulting hash as a byte buffer, to be compared with a known
   *                  root.
   */
  verify(withElement = true) {
    const path = intoKey(this.value);

    function merge(cursor, nextCursor, root, neighbors) {
        const nibble = Number.parseInt(path[nextCursor - 1], 16);

        const nodes = neighbors.slice(0, nibble)
          .concat(root)
          .concat(neighbors.slice(nibble));

        const value = Buffer.concat(nodes.filter(x => x !== undefined));

        const prefix = path.slice(cursor, nextCursor - 1);

        return BranchNode.prototype.setPrefix.call({}, prefix, digest(value)).hash;
    }

    if (!withElement && this.steps.length == 0) {
      return (new Tree).hash;
    }

    const loop = (cursor, ix) => {
      const step = this.steps[ix];

      // Terminal case (or first case, depending how we look at it).
      if (step === undefined) {
        const suffix = path.slice(cursor);
        return withElement
          ? Leaf.prototype.setPrefix.call({}, suffix, digest(this.value)).hash
          : Buffer.from([]);
      }

      const isLastStep = this.steps[ix + 1] === undefined;

      const nextCursor = cursor + 1 + step.skip;

      const root = loop(nextCursor, ix + 1);

      switch (step.type) {
        case Proof.#TYPE_BRANCH: {
          return merge(cursor, nextCursor, root, step.neighbors);
        }

        case Proof.#TYPE_FORK: {
          if (!withElement && isLastStep) {
            const prefix = Buffer.concat([Buffer.from([step.neighbor.nibble]), step.neighbor.prefix]);
            return digest(Buffer.concat([prefix, step.neighbor.value]));
          }

          const neighbors = intoVector({
            [step.neighbor.nibble.toString(16)]: digest(Buffer.concat([
              step.neighbor.prefix,
              step.neighbor.value
            ]))
          }, 15);

          return merge(cursor, nextCursor, root, neighbors);
        }

        case Proof.#TYPE_LEAF: {
          const path = step.neighbor.toString('hex');

          if (!withElement && isLastStep) {
            const suffix = path.slice(cursor);
            return Leaf.prototype.setPrefix.call({}, suffix, step.neighbor).hash;
          }

          const suffix = path.slice(nextCursor);
          const nibble = path[nextCursor - 1];
          const neighbors = intoVector({
            [nibble]: Leaf.prototype.setPrefix.call({}, suffix, step.neighbor).hash,
          }, 15);

          return merge(cursor, nextCursor, root, neighbors);
        }

        default:
          throw new Error(`unknown step type ${step.type}`);
      }
    };

    return loop(0, 0);
  }


  /** Serialise the proof as a portable JSON.
   *
   * @return {object}
   */
  toJSON() {
    const serialisers = {
      [Proof.#TYPE_LEAF](step) {
        return {
          ...step,
          type: step.type.description,
          neighbor: step.neighbor.toString('hex'),
        };
      },

      [Proof.#TYPE_FORK](step) {
        return {
          ...step,
          type: step.type.description,
          neighbor: {
            ...step.neighbor,
            prefix: step.neighbor.prefix.toString('hex'),
            value: step.neighbor.value.toString('hex'),
          }
        };
      },

      [Proof.#TYPE_BRANCH](step) {
        let nextDefined = 0;

        const mask = step.neighbors.map((x, ix) => {
          const current = nextDefined
          if (x !== undefined) {
            nextDefined += 1;
          }
          return current;
        }, {});

        const neighbors = step.neighbors.map(x => x == undefined ? '' : x.toString('hex')).join('');

        return {
          ...step,
          type: step.type.description,
          neighbors,
          mask: Buffer.from(mask).toString('hex'),
        };
      },
    };

    return this.steps.map(step => serialisers[step.type](step));
  }


  /** Serialise the proof as Aiken code. Mainly for debugging / testing.
   *
   * @return {string}
   */
  toAiken() {
    const steps = this.toJSON().map(step => {
      switch (step.type) {
        case Proof.#TYPE_BRANCH.description: {
          return `  Branch { skip: ${step.skip}, neighbors: #"${step.neighbors}", mask: #"${step.mask}" },\n`
        }
        case Proof.#TYPE_FORK.description: {
          const neighbor = `Neighbor { nibble: ${step.neighbor.nibble}, value: #"${step.neighbor.value}", prefix: #"${step.neighbor.prefix}" }`;
          return `  Fork { skip: ${step.skip}, neighbor: ${neighbor} },\n`
        }
        case Proof.#TYPE_LEAF.description: {
          return `  Leaf { skip: ${step.skip}, neighbor: #"${step.neighbor}" },\n`
        }
        default:
          throw new Error(`unknown step type ${step.type}`);
      }
    });

    return `[ \n ${steps.join('')} ]`;
  }

  toCBOR() {
    throw new Error('toCBOR: TODO');
  }
}


// --------------------------------------------------------------------- Helpers

/** Compute a hash digest of the given msg buffer.
 *
 * @param {Buffer} msg Payload to hash
 * @return {Buffer} The (blake2b) hash digest
 * @private
 */
export function digest(msg) {
  return Buffer.from(
    blake2b(DIGEST_LENGTH)
      .update(msg)
      .digest()
  );
}


/** Turn any serialised value into a key. A key is a hex-encoded string that
 * uniquely identifies the value.
 *
 * @param {string|Buffer} value Also accepts raw 'strings' treated as UTF-8 byte buffers.
 * @return {string}
 * @private
 */
function intoKey(value) {
  value = typeof value === 'string' ? Buffer.from(value) : value;
  return digest(value).toString('hex');
}
