import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_smart_genome/page/compare/compare_logic.dart';
import 'package:flutter_smart_genome/page/compare/compare_view.dart';
import 'package:flutter_smart_genome/widget/basic/draggable_window.dart';
import 'package:flutter_smart_genome/widget/track/base/track_data.dart';
import 'package:get/get.dart';

class CompareWindowManager {
  static final CompareWindowManager _instance = CompareWindowManager._();

  factory CompareWindowManager() {
    return _instance;
  }

  static CompareWindowManager get() => CompareWindowManager();

  CompareWindowManager._() {}

  Map<String, CancelFunc> _windowCancels = {};
  Map<String, Function> _restoreCallbacks = {};

  Map<String, Rect> _windowPositionCache = {};

  void _cacheWindowPosition(String group, Rect rect) {
    _windowPositionCache[group] = rect;
  }

  void showOrUpdateCompareWindow(List<Map> features, MatrixBean matrix) {
    String groupKey = 'compare-window';
    if (_windowCancels[groupKey] == null) {
      Rect? rect = _windowPositionCache[groupKey];
      _windowCancels[groupKey] = showDraggableWindow(
        builder: (context, size, dragging, resizing, cancel) {
          return CompareView(features: features, matrix: matrix);
        },
        title: 'scMultiView',
        shortTitle: 'scMultiView',
        group: 'compare-window',
        initialSize: Size(Get.width * .85, Get.height * .85),
        minimizable: true,
      );
    } else {
      _restoreCallbacks[groupKey]?.call();
      CompareLogic.get()?.setFeatures(features, matrix);
    }
  }

  CancelFunc showDraggableWindow({
    required DraggableChildBuilderWithCancel builder,
    String? title,
    String? shortTitle,
    bool minimizable = false,
    String? group,
    Size? initialSize,
  }) {
    String groupKey = group ?? 'draggable-window';
    _windowCancels[groupKey]?.call();

    Rect? rect = _windowPositionCache[groupKey];
    return BotToast.showAnimationWidget(
      // backgroundColor: Colors.black.withOpacity(.2),
      groupKey: groupKey,
      toastBuilder: (cancel) {
        return DraggableWindow(
            builder: (context, size, dragging, resizing) => builder.call(context, size, dragging, resizing, cancel),
            offset: rect?.topLeft,
            minimizable: minimizable,
            groupKey: groupKey,
            onPositionChange: _cacheWindowPosition,
            title: Text(
              title ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            shortTitle: shortTitle ?? title ?? 'Float Window',
            constraints: BoxConstraints.tightFor(
              width: rect?.width ?? initialSize?.width ?? Get.width * .55,
              height: rect?.height ?? initialSize?.height ?? Get.height * .65,
            ),
            onClose: () {
              cancel.call();
              _windowCancels.remove(groupKey);
            },
            onRestoreCallback: (restoreFunc) {
              _restoreCallbacks[groupKey] = restoreFunc;
            });
      },
      onlyOne: true,
      ignoreContentClick: false,
      animationDuration: Duration(milliseconds: 50),
      onClose: () {
        _windowCancels.remove(groupKey);
      },
      // wrapToastAnimation: (controller, cancel, child) => ,
    );
  }

  destroy() {
    _restoreCallbacks.clear();
    _windowCancels.clear();
  }
}
