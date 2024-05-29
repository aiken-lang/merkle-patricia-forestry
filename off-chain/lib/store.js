export class Store {
  #nodes;

  constructor() {
    this.#nodes = new Map();
  }

  async get(key, deserialise) {
    return deserialise(key, await this.#nodes.get(key.toString('hex')), this);
  }

  async put(key, value) {
    this.#nodes.set(key.toString('hex'), value.serialise());
  }

  async del(key) {
    this.#nodes.delete(key.toString('hex'));
  }

  get size() {
    return this.#nodes.size;
  }
}
