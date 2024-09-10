import 'package:flutter/material.dart';

typedef InteractiveViewChildBuilder(TransformationController controller);

class EnhancedInteractiveViewer extends StatefulWidget {
  final TransformationController? controller;
  final double maxScale;
  final double minScale;
  final Widget? child;
  final ValueChanged<TransformationController>? onTransformEnd;
  final ValueChanged<TransformationController>? onTransformUpdate;
  final InteractiveViewChildBuilder? builder;

  const EnhancedInteractiveViewer({
    super.key,
    this.minScale = 0.1,
    this.maxScale = 100,
    this.controller,
    this.onTransformUpdate,
    this.onTransformEnd,
    this.child,
    this.builder,
  });

  @override
  State<EnhancedInteractiveViewer> createState() => EnhancedInteractiveViewerState();
}

class EnhancedInteractiveViewerState extends State<EnhancedInteractiveViewer> with SingleTickerProviderStateMixin {
  AnimationController? _animationController;
  Animation<Matrix4>? _animation;

  TapDownDetails? _doubleTapDetails;

  final GlobalKey _parentKey = GlobalKey();

  late TransformationController _transformationController;

  @override
  void initState() {
    super.initState();
    _transformationController = widget.controller ?? TransformationController();
    _transformationController.addListener(() {
      // setState(() {});
    });
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400),
    )..addListener(() {
        _transformationController.value = _animation!.value;
      });
  }

  void _handleDoubleTap() {
    Offset _position = _doubleTapDetails!.localPosition;
    double currentScale = _transformationController.value.row0.x;
    _scaleTo(currentScale * 2, _position);
  }

  void doubleTap() {
    _handleDoubleTap();
  }

  void zoomIn() {
    double currentScale = _transformationController.value.row0.x;
    // var translation = _transformationController.value.getTranslation();

    Offset center = _viewport.center;
    _scaleTo(currentScale * 2, center);
  }

  void zoomOut() {
    double currentScale = _transformationController.value.row0.x;
    // var translation = _transformationController.value.getTranslation();
    Offset center = _viewport.center;
    _scaleTo(currentScale / 2, center);
  }

  void _scaleTo(double targetScale, Offset anchor) {
    Matrix4 matrix = _transformationController.value.clone();
    double currentScale = matrix.row0.x;

    if (targetScale > widget.maxScale || targetScale < widget.minScale) {
      return;
    }
    print('scale to : $targetScale');

    var translation = _transformationController.value.getTranslation();

    double offSetX = targetScale == 1.0 ? 0.0 : -anchor.dx * (targetScale - 1) - translation.x / currentScale;
    double offSetY = targetScale == 1.0 ? 0.0 : -anchor.dy * (targetScale - 1) - translation.y / currentScale;

    // matrix = Matrix4.fromList([targetScale, matrix.row1.x, matrix.row2.x, matrix.row3.x, matrix.row0.y, targetScale, matrix.row2.y, matrix.row3.y, matrix.row0.z, matrix.row1.z, targetScale, matrix.row3.z, offSetX, offSetY, matrix.row2.w, matrix.row3.w]);

    final double scale = _transformationController.value.getMaxScaleOnAxis();
    final double scaleChange = targetScale / scale;
    // _transformationController!.value = _matrixScale(
    //   _transformationController!.value,
    //   scaleChange,
    // );

    _animation = Matrix4Tween(
      begin: _transformationController.value,
      end: matrix,
    ).animate(
      CurveTween(curve: Curves.easeOut).animate(_animationController!),
    );
    _animation!..addListener(_scaleAnimateUpdate);
    _animationController!.forward(from: 0).whenComplete(_onScaleComplete);
  }

  void _scaleAnimateUpdate() {
    _transformationController.value = _animation!.value;
    widget.onTransformUpdate?.call(_transformationController);
  }

  void _onScaleComplete() {
    widget.onTransformEnd?.call(_transformationController);
  }

  void _handleDoubleTapDown(TapDownDetails details) {
    _doubleTapDetails = details;
  }

  Rect get _viewport {
    assert(_parentKey.currentContext != null);
    final RenderBox parentRenderBox = _parentKey.currentContext!.findRenderObject()! as RenderBox;
    return Offset.zero & parentRenderBox.size;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: _parentKey,
      onDoubleTapDown: _handleDoubleTapDown,
      onDoubleTap: _handleDoubleTap,
      child: widget.builder?.call(_transformationController),
    );
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }
}