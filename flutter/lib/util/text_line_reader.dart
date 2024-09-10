class BinaryFileReader {
  late int offset;

  late int _lineSeparatorCode;

  late int _length;

  late List<int> bytes;

  BinaryFileReader(List<int> bytes, {int start = 0, String lineSeparator = '\n'}) {
    this.bytes = bytes;
    _length = bytes.length;
    this._lineSeparatorCode = lineSeparator.codeUnitAt(0);
    this.offset = start;
  }

  String readLine() {
    var bytes = this.bytes;
    var i = this.offset;

    var line = [];
    while (i < _length) {
      var c1 = bytes[i], c2, c3;
      if (c1 < 128) {
        i++;
        if (c1 == _lineSeparatorCode) {
          this.offset = i;
          return line.join('');
        }
        line.add(String.fromCharCode(c1));
      } else if (c1 > 191 && c1 < 224) {
        c2 = bytes[i + 1];
        line.add(String.fromCharCode(((c1 & 31) << 6) | (c2 & 63)));
        i += 2;
      } else {
        c2 = bytes[i + 1];
        c3 = bytes[i + 2];
        line.add(String.fromCharCode(((c1 & 15) << 12) | ((c2 & 63) << 6) | (c3 & 63)));
        i += 3;
      }
    }

    // did not get a full line
    this.offset = i;
    // return our partial line if we are set to return partial records
    return line.join('');
  }
}