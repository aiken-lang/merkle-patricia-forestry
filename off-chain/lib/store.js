import assert from 'node:assert';
import { Level } from 'level';

export class Store {
  #batch;
  #db;

  constructor(filename) {
    if (filename === undefined) {
      this.#db = inMemoryMap();
    } else {
      this.#db = new Level(filename, { valueEncoding: 'json' });
    }
  }

  async ready() {
    return this.#db.open ? this.#db.open() : Promise.resolve();
  }

  async batch(callback) {
    assert(this.#batch === undefined, 'batch already ongoing');

    this.#batch = [];

    let result;
    try {
      result = await callback();
    } catch (e) {
      this.#batch = undefined;
      throw e;
    }

    await this.#db.batch(this.#batch);

    this.#batch = undefined;

    return result;
  }

  async get(key, deserialise) {
    return deserialise(key, await this.#db.get(key.toString('hex')), this);
  }

  async put(key, value) {
    key = key.toString('hex'),
    value = value.serialise();

    if (this.#batch !== undefined) {
      this.#batch.push({ type: 'put', key, value });
    } else {
      this.#db.put(key, value);
    }
  }

  async del(key) {
    key = key.toString('hex');

    if (this.#batch !== undefined) {
      this.#batch.push({ type: 'del', key });
    } else {
      this.#db.del(key);
    }
  }

  async size() {
    return this.#db.size !== undefined
      ? this.#db.size
      : this.#db.keys().all().then(it => it.length);
  }
}

function inMemoryMap() {
  const db = new Map();

  return {
    get(k) {
      return db.get(k);
    },

    put(k, v) {
      db.set(k, v);
    },

    del(k) {
      db.delete(k);
    },

    batch(ops) {
      ops.forEach(({ type, key, value }) => {
        this[type](key, value);
      });
    },

    get size() {
      return db.size;
    },
  }
}
