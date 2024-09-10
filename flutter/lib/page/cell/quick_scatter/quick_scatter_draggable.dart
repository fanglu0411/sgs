import 'package:ditredi/ditredi.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// A widget that controls the [DiTreDi] camera with gestures.
class QuickDiTreDiDraggable extends StatefulWidget {
  /// The [DiTreDiController] to control.
  /// Should be the same as the one used in the [DiTreDi] widget.
  final DiTreDiController controller;

  /// The [DiTreDi] widget or its container.
  final Widget child;

  /// If true, the camera will be rotated with the finger.
  final bool rotationEnabled;

  /// If true, the zoom will be changed with the mouse scroll.
  final bool scaleEnabled;

  /// Creates a [DiTreDiDraggable] widget.
  const QuickDiTreDiDraggable({
    Key? key,
    required this.controller,
    required this.child,
    this.rotationEnabled = true,
    this.scaleEnabled = true,
  }) : super(key: key);

  @override
  State<QuickDiTreDiDraggable> createState() => _DiTreDiDraggableState();
}

class _DiTreDiDraggableState extends State<QuickDiTreDiDraggable> {
  var _lastX = 0.0;
  var _lastY = 0.0;
  var _scaleBase = 0.0;
  Offset _translate = Offset.zero;
  Offset? hover = null;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerSignal: (pointerSignal) {
        if (widget.scaleEnabled && pointerSignal is PointerScrollEvent) {
          final scaledDy = pointerSignal.scrollDelta.dy / widget.controller.viewScale;
          widget.controller.update(
            userScale: widget.controller.userScale - scaledDy,
          );
        }
      },
      onPointerHover: (pointerHover) {
        hover = pointerHover.localPosition;
        // print(hover);
      },
      child: GestureDetector(
        onDoubleTap: () {
          final controller = widget.controller;
          controller.update(
            userScale: widget.controller.userScale * 1.2,
            // anchor: hover == null ? null : Vector3(hover!.dx, hover!.dy, 0)
          );
        },
        onScaleStart: (data) {
          _scaleBase = widget.controller.userScale;
          _translate = widget.controller.translation;
          _lastX = data.localFocalPoint.dx;
          _lastY = data.localFocalPoint.dy;
        },
        onScaleUpdate: (data) {
          final controller = widget.controller;

          final dx = data.localFocalPoint.dx - _lastX;
          final dy = data.localFocalPoint.dy - _lastY;

          _lastX = data.localFocalPoint.dx;
          _lastY = data.localFocalPoint.dy;

          double _s = 1;

          controller.update(
            userScale: _scaleBase * data.scale,
            rotationX: widget.rotationEnabled ? (controller.rotationX - dy / 2).clamp(-90, -20) : null,
            rotationY: widget.rotationEnabled ? ((controller.rotationY - dx / 2 + 360) % 360).clamp(0, 360) : null,
            translation: data.scale == 1.0 ? controller.translation + Offset(dx, dy) : null,
            // anchor: Vector3(
            //     data.localFocalPoint.dx * _s, data.localFocalPoint.dy * _s, 0),
          );
        },
        child: widget.child,
      ),
    );
  }
}