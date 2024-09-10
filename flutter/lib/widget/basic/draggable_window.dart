import 'package:bot_toast/bot_toast.dart';
import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:flutter_smart_genome/base/ui_config.dart';
import 'package:rotated_corner_decoration/rotated_corner_decoration.dart';

typedef Widget DraggableChildBuilderWithCancel(BuildContext context, Size size, bool dragging, bool resizing, CancelFunc cancel);
typedef Widget DraggableChildBuilder(BuildContext context, Size size, bool dragging, bool resizing);

class DraggableWindow extends StatefulWidget {
  final DraggableChildBuilder builder;
  final Widget title;
  final String shortTitle;
  final BoxConstraints constraints;
  final VoidCallback? onClose;
  final bool minimizable;
  final String groupKey;
  final Offset? offset;
  final Function2<String, Rect, void>? onPositionChange;
  final ValueChanged<VoidCallback>? onRestoreCallback;

  const DraggableWindow({
    Key? key,
    required this.builder,
    required this.title,
    this.shortTitle = 'Window',
    required this.constraints,
    this.onClose,
    this.minimizable = true,
    this.groupKey = 'def-window-group',
    this.offset,
    this.onPositionChange,
    this.onRestoreCallback,
  }) : super(key: key);

  @override
  _DraggableWindowState createState() => _DraggableWindowState();
}

class _DraggableWindowState extends State<DraggableWindow> with SingleTickerProviderStateMixin {
  late Offset _offset;
  Offset? _restoreOffset;
  Size? _restoreSize;
  Rect? _rect;
  bool _minimized = false;
  bool _maximized = false;
  bool _dragging = false, _resizing = false;

  double windowTitleHeight = 30;

  AnimationController? _animationController;

  Tween<Offset>? _tween;

  late Size _windowSize;

  @override
  void initState() {
    super.initState();
    _offset = widget.offset ?? Offset(100, 100);
    _windowSize = widget.constraints.biggest;
    _animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 200))
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
        } else if (status == AnimationStatus.reverse) {}
      })
      ..addListener(() {
        _offset = _tween!.transform(_animationController!.value);
        setState(() {});
      });
    widget.onRestoreCallback?.call(_restore);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    _rect = Rect.fromLTRB(-(_windowSize.width - 60), HORIZONTAL_TOOL_BAR_HEIGHT, size.width - 30, size.height - windowTitleHeight);
    return CustomMultiChildLayout(
      delegate: ResizableWidowLayoutDelegate(offset: _offset, size: _windowSize),
      children: [
        // LayoutId(
        //   id: ResizeWindowPosition.title,
        //   child: Material(child: _buildHeader()),
        // ),
        if (widget.minimizable && _minimized)
          LayoutId(
            id: ResizeWindowPosition.minimize,
            child: Material(
              child: IconButton(
                tooltip: widget.shortTitle,
                padding: EdgeInsets.zero,
                constraints: BoxConstraints.tightFor(width: 20, height: 20),
                icon: Icon(Icons.grid_view_rounded),
                onPressed: _toggleMinimize,
              ),
            ),
          ),
        // LayoutId(
        //   id: ResizeWindowPosition.center,
        //   child: SingleChildScrollView(child: widget.child),
        // ),
        LayoutId(
          id: ResizeWindowPosition.center,
          child: Material(
            shape: RoundedRectangleBorder(
              side: BorderSide(color: Theme.of(context).colorScheme.primary),
              borderRadius: BorderRadius.circular(5),
            ),
            elevation: 6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.max,
              children: [
                _buildHeader(),
                Expanded(child: widget.builder(context, Size(_windowSize.width, _windowSize.height - 30), _dragging, _resizing)),
              ],
            ),
          ),
        ),
        _resizeArea(ResizeWindowPosition.bottomRight),
        // _resizeArea(ResizeWindowPosition.topRight),
      ],
    );
  }

  Widget _resizeArea(ResizeWindowPosition position) {
    var theme = Theme.of(context);
    var _primaryColor = theme.primaryColor;
    return LayoutId(
      id: position,
      child: GestureDetector(
        onPanUpdate: (details) {
          if (position == ResizeWindowPosition.bottomRight || position == ResizeWindowPosition.topRight) {
            setState(() {
              _resizing = true;
              _windowSize = Size((_windowSize.width + details.delta.dx).clamp(500.0, 2000.0), (_windowSize.height + details.delta.dy).clamp(300.0, 2000.0));
              widget.onPositionChange?.call(widget.groupKey, Rect.fromLTWH(_offset.dx, _offset.dy, _windowSize.width, _windowSize.height));
            });
          }
        },
        onPanCancel: () {
          _resizing = false;
          setState(() {});
        },
        onPanEnd: (d) {
          _resizing = false;
          setState(() {});
        },
        child: MouseRegion(
          cursor: position == ResizeWindowPosition.bottomRight ? SystemMouseCursors.grab : SystemMouseCursors.resizeUpRight,
          child: Container(
            margin: EdgeInsets.only(right: 2, bottom: 2),
            decoration: RotatedCornerDecoration.withColor(
              badgeSize: Size(12, 12),
              color: theme.colorScheme.primaryContainer,
              badgePosition: BadgePosition.bottomEnd,
              badgeCornerRadius: Radius.circular(3),
              // badgeCornerRadius: Radius.circular(5),
            ),
            width: 24,
            height: 24,
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(5), topRight: Radius.circular(5)),
      ),
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(width: 6),
          Expanded(
            child: GestureDetector(
              onPanUpdate: (details) {
                _dragging = true;
                _offset += details.delta;
                _offset = Offset(_offset.dx.clamp(_rect!.left, _rect!.right), _offset.dy.clamp(_rect!.top, _rect!.bottom));
                setState(() {});
                widget.onPositionChange?.call(widget.groupKey, Rect.fromLTWH(_offset.dx, _offset.dy, _windowSize.width, _windowSize.height));
              },
              onDoubleTap: () {
                _toggleMaximize();
              },
              onPanCancel: () {
                _dragging = false;
                setState(() {});
              },
              onPanEnd: (d) {
                _dragging = false;
                setState(() {});
              },
              child: Container(
                child: widget.title,
              ),
            ),
          ),
          if (widget.minimizable)
            IconButton(
              padding: EdgeInsets.zero,
              constraints: BoxConstraints.tightFor(width: 24, height: 24),
              splashRadius: 15,
              onPressed: _toggleMinimize,
              iconSize: 16,
              // splashColor: Colors.white70,
              // color: Colors.white,
              tooltip: _minimized ? 'Restore' : 'Minimize',
              icon: Icon(_minimized ? MaterialCommunityIcons.window_open : MaterialCommunityIcons.window_minimize),
            ),
          IconButton(
            padding: EdgeInsets.zero,
            constraints: BoxConstraints.tightFor(width: 32, height: 24),
            splashRadius: 15,
            onPressed: _toggleMaximize,
            iconSize: 16,
            // splashColor: Colors.white70,
            // color: Colors.white,
            tooltip: _maximized ? 'Restore' : 'Maximize',
            icon: Icon(_maximized ? MaterialCommunityIcons.window_restore : MaterialCommunityIcons.window_maximize),
          ),
          IconButton(
            padding: EdgeInsets.zero,
            constraints: BoxConstraints.tightFor(width: 24, height: 24),
            splashRadius: 15,
            onPressed: () => widget.onClose?.call(),
            iconSize: 16,
            // splashColor: Colors.white70,
            // color: Colors.white,
            icon: Icon(Icons.close),
            tooltip: 'Close',
          ),
          SizedBox(width: 4),
        ],
      ),
    );
  }

  _toggleMaximize() {
    if (_maximized) {
      _offset = _restoreOffset!;
      _windowSize = _restoreSize!;
    } else {
      _restoreOffset = _offset;
      _restoreSize = _windowSize;
      _offset = Offset(0, HORIZONTAL_TOOL_BAR_HEIGHT);
      var __size = MediaQuery.of(context).size;
      _windowSize = Size(__size.width, __size.height - HORIZONTAL_TOOL_BAR_HEIGHT);
    }
    _maximized = !_maximized;
    setState(() {});
  }

  _toggleMinimize() {
    if (_minimized) {
      _restore();
    } else {
      _min();
      _minimized = !_minimized;
    }
  }

  void _min() {
    var size = MediaQuery.of(context).size;
    var target = Offset((size.width - _windowSize.width) / 2, _rect!.bottom);
    _tween = Tween<Offset>(begin: _offset, end: target);
    _tween!.animate(_animationController!);
    _animationController!.forward();
  }

  void _restore() {
    if (_minimized) {
      _animationController!.reverse();
      _minimized = !_minimized;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class WindowLayoutDelegate extends SingleChildLayoutDelegate {
  Offset offset;

  WindowLayoutDelegate({required this.offset}) {}

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    return offset;
    // return super.getPositionForChild(size, childSize);
  }

  @override
  bool shouldRelayout(covariant WindowLayoutDelegate oldDelegate) {
    return offset != oldDelegate.offset;
  }
}

enum ResizeWindowPosition {
  minimize,
  title,
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
  center,
}

class ResizableWidowLayoutDelegate extends MultiChildLayoutDelegate {
  Offset offset;
  Size resizeSize;

  Size size;

  ResizableWidowLayoutDelegate({
    this.offset = Offset.zero,
    required this.size,
    this.resizeSize = const Size(12, 12),
  });

  @override
  void performLayout(Size size) {
    var _size = this.size;

    var minimizeSize = Size.zero;
    if (hasChild(ResizeWindowPosition.minimize)) {
      minimizeSize = layoutChild(ResizeWindowPosition.minimize, BoxConstraints.tightFor(height: 30, width: 30));
      positionChild(ResizeWindowPosition.minimize, offset + Offset((_size.width - 30) / 2, 0));
    }

    var titleSize = Size.zero;
    if (hasChild(ResizeWindowPosition.title)) {
      titleSize = layoutChild(ResizeWindowPosition.title, BoxConstraints.expand(height: 30, width: _size.width));
      positionChild(ResizeWindowPosition.title, offset + Offset(0, minimizeSize.height));
    }

    BoxConstraints resizeConstraints = BoxConstraints.tightFor(width: resizeSize.width, height: resizeSize.height);
    if (hasChild(ResizeWindowPosition.topLeft)) {
      layoutChild(ResizeWindowPosition.topLeft, resizeConstraints);
      positionChild(ResizeWindowPosition.topLeft, offset);
    }
    if (hasChild(ResizeWindowPosition.topRight)) {
      layoutChild(ResizeWindowPosition.topRight, resizeConstraints);
      positionChild(ResizeWindowPosition.topRight, Offset(offset.dx + (_size.width - resizeSize.width), offset.dy + minimizeSize.height));
    }
    if (hasChild(ResizeWindowPosition.bottomLeft)) {
      layoutChild(ResizeWindowPosition.bottomLeft, resizeConstraints);
      positionChild(ResizeWindowPosition.bottomLeft, Offset(offset.dx, offset.dy + (_size.height - resizeSize.height)));
    }
    if (hasChild(ResizeWindowPosition.bottomRight)) {
      layoutChild(ResizeWindowPosition.bottomRight, resizeConstraints);
      positionChild(ResizeWindowPosition.bottomRight, Offset(offset.dx + (_size.width - resizeSize.width), offset.dy + (_size.height - resizeSize.height)));
    }

    if (hasChild(ResizeWindowPosition.center)) {
      layoutChild(ResizeWindowPosition.center, BoxConstraints.expand(width: _size.width, height: _size.height - titleSize.height));
      positionChild(ResizeWindowPosition.center, offset + Offset(0, titleSize.height + minimizeSize.height));
    }
  }

  @override
  bool shouldRelayout(covariant ResizableWidowLayoutDelegate oldDelegate) {
    return offset != oldDelegate.offset || size != oldDelegate.size;
  }
}
