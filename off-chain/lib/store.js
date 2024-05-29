import { Level } from 'level';

export class Store {
  #db;

  constructor(filename) {
    if (filename === undefined) {
      this.#db = inMemoryMap();
    } else {
      this.#db = new Level(filename, { valueEncoding: 'json' });
    }
  }

  async get(key, deserialise) {
    return deserialise(key, await this.#db.get(key.toString('hex')), this);
  }

  async put(key, value) {
    this.#db.put(key.toString('hex'), value.serialise());
  }

  async del(key) {
    this.#db.del(key.toString('hex'));
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

    get size() {
      return db.size;
    },
  }
}
