import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/base/ticker_provider_impl.dart';

class SideDrawer {
  OverlayEntry? _overlayEntry;
  AnimationController? _controller;

  void showSideDrawer(
    BuildContext context, {
    required Widget child,
    Alignment alignment = Alignment.centerRight,
    Animatable<Alignment>? animate,
  }) {
    OverlayState overlayState = Overlay.of(context);

    _controller = AnimationController(duration: Duration(milliseconds: 250), vsync: TickerProviderImpl());

    var _child;
    Animation<Alignment>? _animation = animate?.animate(_controller!);
    if (_animation != null) {
      _child = AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Container(
            alignment: _animation.value,
            child: child,
          );
        },
        child: child,
      );
    } else {
      _child = Container(
        alignment: alignment,
        child: child,
      );
    }

    Animation<Color?> backgroundAnimation = ColorTween(
      begin: Colors.transparent,
      end: Colors.black.withAlpha(150),
    ).animate(_controller!);

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Stack(
          children: <Widget>[
            Listener(
              onPointerDown: (_) => remove(),
              behavior: HitTestBehavior.translucent,
              child: const SizedBox.expand(),
            ),
            IgnorePointer(
              child: AnimatedBuilder(
                animation: backgroundAnimation,
                builder: (context, child) {
                  return Container(color: backgroundAnimation.value);
                },
              ),
            ),
            IgnorePointer(ignoring: false, child: _child),
          ],
        );
      },
      maintainState: true,
    );
    overlayState.insert(_overlayEntry!);
    _controller?.forward();
  }

  remove() async {
    await _controller?.reverse();
    _controller?.dispose();
    _controller = null;
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}
