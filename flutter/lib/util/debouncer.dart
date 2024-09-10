import 'package:flutter/foundation.dart';
import 'dart:async';


class Debounce {
  final int milliseconds;
  VoidCallback? action;
  Timer? _timer;

  Debounce({ this.milliseconds = 1000});

  run(VoidCallback action, {int? milliseconds}) {
    if (_timer != null) {
      _timer!.cancel();
    }

    if (milliseconds == 0) {
      action.call();
      return;
    }

    _timer = Timer(Duration(milliseconds: milliseconds ?? this.milliseconds), action);
  }

  dispose() {
    _timer?.cancel();
    _timer = null;
  }
}