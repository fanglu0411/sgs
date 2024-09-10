import 'dart:math' show max, min;

import 'package:intl/intl.dart';

class TrackUIConfig {
  static const double MIN_SEQ_SIZE = 14;
}

NumberFormat numFormat = NumberFormat.decimalPatternDigits(decimalDigits: 0);

class Range {
  late double start;
  late double end;

  Range({required num start, required num end}) {
    this.start = start.toDouble();
    this.end = end.toDouble();
  }

  Range.fromSize({required this.start, required num width}) {
    this.end = this.start + width;
  }

  double get size => (end - start) + 1; //start with 1, so

  String get lengthStr => numFormat.format(size);

  bool contains(num v) {
    return v >= start && v <= end;
  }

  Range inflate(double value) {
    return Range(start: start - value, end: end + value);
  }

  // Range get fix1StartRange => Range(start: start - 1, end: end);

  String print([String split = ' - ']) {
    return '${start.floor()}${split}${end.floor()}';
  }

  String print2([String split = ' - ']) {
    return '${numFormat.format(start)}${split}${numFormat.format(end)}';
  }

  int get intStart => start.round();

  int get intEnd => end.round();

  String store() {
    return '$start-$end';
  }

  bool get isValid => end > start;

  bool collideRange(num left, num right) {
    if (right <= this.start || left >= this.end) return false;
    return true;
  }

  bool collide(Range range) {
    if (range.end <= start || range.start >= end) return false;
    return true;
  }

  Range? intersection(Range range) {
    if (range.start >= start && range.end <= end) {
      return range.copy();
    }
    if (range.start <= start) {
      if (range.end <= end && range.end >= start) {
        return Range(start: start, end: range.end);
      } else if (range.end > end) {
        return this.copy();
      }
    }
    if (range.end >= end) {
      if (range.start >= start && range.start <= end) {
        return Range(start: range.start, end: end);
      }
    }
    return null;
  }

  Range floatRange() {
    return Range(start: start.toDouble(), end: end.toDouble());
  }

  Range union(Range target) {
    return Range(start: min(target.start, start), end: max(end, target.end));
  }

  double get center => start + size / 2;

  copy({num? start, num? end}) {
    return Range(start: start ?? this.start, end: end ?? this.end);
  }

  @override
  bool operator ==(Object other) => identical(this, other) || other is Range && runtimeType == other.runtimeType && start == other.start && end == other.end;

  @override
  int get hashCode => start.hashCode ^ end.hashCode;

  @override
  String toString() {
    return 'start: $start, end: $end';
  }

  Map toJson() {
    return <String, num>{
      'start': start,
      'end': end,
    };
  }

  static Range? lerp(Range? a, Range? b, double? t) {
    assert(t != null);
    if (b == null) {
      if (a == null) {
        return null;
      } else {
        final double k = 1.0 - t!;
        return Range(start: a.start * k, end: a.end * k);
      }
    } else {
      if (a == null) {
        return Range(start: b.start * t!, end: b.end * t);
      } else {
        return Range(start: _lerpDouble(a.start, b.start, t!), end: _lerpDouble(a.end, b.end, t));
      }
    }
  }

  static double _lerpDouble(num a, num b, double t) {
    return a * (1.0 - t) + b * t;
  }

  Range clamp(Range edgeRange) {
    Range _range = this;
    if (start < edgeRange.start) {
      _range = Range(start: edgeRange.start, end: edgeRange.start + size);
    }
    if (_range.end > edgeRange.end) {
      _range = Range(start: edgeRange.end - size, end: edgeRange.end);
    }
    return _range;
  }
}
