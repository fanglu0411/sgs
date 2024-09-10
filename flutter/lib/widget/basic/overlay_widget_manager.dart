import 'package:flutter/material.dart';

class OverlayWidgetManager {
  List<OverlayEntry> _overlayEntryList = [];

  OverlayEntry createOverlay(BuildContext context, Widget widget) {
    OverlayState overlayState = Overlay.of(context);
    var _overlayEntry = OverlayEntry(
      maintainState: true,
      builder: (BuildContext context) => widget,
    );
    overlayState.insert(_overlayEntry);
    _overlayEntryList.add(_overlayEntry);
    return _overlayEntry;
  }

  removeAll(BuildContext context) {
    _overlayEntryList.forEach((v) => v.remove());
    _overlayEntryList.clear();
  }
}
