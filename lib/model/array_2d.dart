class Array2d<T> {
  late List<List<T?>> _array;
  T? defaultValue;
  late int _width;
  late int _height;

  Array2d(int width, int height, {this.defaultValue}) {
    _array = List<List<T?>>.filled(0, [], growable: true);

    this.width = width;
    this.height = height;
  }

  operator [](int x) => _array[x];

  set width(int v) {
    _width = v;
    while (_array.length > v) {
      _array.removeLast();
    }
    while (_array.length < v) {
      List<T?> newList = List<T?>.empty(growable: true);
      if (_array.isNotEmpty) {
        for (int y = 0; y < _array.first.length; y++) {
          newList.add(defaultValue);
        }
      }
      _array.add(newList);
    }
  }

  set height(int v) {
    _height = v;
    while (_array.first.length > v) {
      for (int x = 0; x < _array.length; x++) {
        _array[x].removeLast();
      }
    }
    while (_array.first.length < v) {
      for (int x = 0; x < _array.length; x++) {
        _array[x].add(defaultValue);
      }
    }
  }

  int get width => _width;
  int get height => _height;

  /// Clone this Array2d
  Array2d<T> clone() {
    Array2d<T> newArray2d = Array2d<T>(_height, _width);

    for (int row = 0; row < _height; row++) {
      for (int col = 0; col < _width; col++) {
        newArray2d[row][col] = _array[row][col];
      }
    }

    return newArray2d;
  }
}
