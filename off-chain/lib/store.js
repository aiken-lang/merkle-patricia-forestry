export class Store {
  #nodes;

  constructor() {
    this.#nodes = new Map();
  }

  set(key, value) {
    this.#nodes.set(key.toString('hex'), value);
  }

  delete(key) {
    this.#nodes.delete(key.toString('hex'));
  }

  get(key) {
    return this.#nodes.get(key.toString('hex'));
  }

  get size() {
    return this.#nodes.size;
  }
}
