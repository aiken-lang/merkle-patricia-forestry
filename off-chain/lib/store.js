export class Store {
  #nodes;

  constructor() {
    this.#nodes = new Map();
  }

  async get(key) {
    return this.#nodes.get(key.toString('hex'));
  }

  async put(key, value) {
    this.#nodes.set(key.toString('hex'), value);
  }

  async del(key) {
    this.#nodes.delete(key.toString('hex'));
  }

  get size() {
    return this.#nodes.size;
  }
}
