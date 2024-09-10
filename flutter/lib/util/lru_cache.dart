class LruCache<K, T> {
  late Map<K, T> _cache;

  late int size;

  LruCache([this.size = 1000]) {
    _cache = {};
  }

  Iterable<K> get keys => _cache.keys;

  T? get(K key) {
    return _cache[key];
  }

  T? operator [](K key) {
    return _cache[key];
  }

  operator []=(K key, T value) {
    save(key, value);
  }

  save(K key, T value) {
    if (_cache.length > size) {
      K _key = _cache.keys.first;
      remove(_key);
    }
    _cache[key] = value;
  }

  Iterable<T> get values => _cache.values;

  remove(K key) {
    _cache.remove(key);
  }

  int get length => _cache.length;

  void clear() {
    _cache.clear();
  }
}