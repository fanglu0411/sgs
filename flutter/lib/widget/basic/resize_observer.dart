import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// A callback to be invoked when the size of the observed widget changes.
typedef ResizeCallback = void Function(Size? oldSize, Size newSize);

/// A widget that calls a callback when the size of its [child] changes.
class ResizeObserver extends SingleChildRenderObjectWidget {
  /// The callback to be called when the size of [child] changes.
  final ResizeCallback onResized;

  const ResizeObserver({
    super.key,
    required this.onResized,
    super.child,
  });

  @override
  RenderObject createRenderObject(BuildContext context) => _RenderResizeObserver(onLayoutChangedCallback: onResized);
}

class _RenderResizeObserver extends RenderProxyBox {
  final ResizeCallback onLayoutChangedCallback;

  _RenderResizeObserver({
    RenderBox? child,
    required this.onLayoutChangedCallback,
  }) : super(child);

  Size? _oldSize;

  @override
  void performLayout() {
    super.performLayout();
    if (size != _oldSize) {
      onLayoutChangedCallback(_oldSize, size);
      _oldSize = size;
    }
  }
}