// import 'package:flutter/material.dart';
// import 'package:flutter_smart_genome/d3/color/schemes.dart';
// import 'package:graphx/graphx.dart';
// import 'dart:math' as math;
//
// class GraphicPlotWidget extends StatefulWidget {
//   const GraphicPlotWidget({Key key}) : super(key: key);
//
//   @override
//   State<GraphicPlotWidget> createState() => _GraphicPlotWidgetState();
// }
//
// class _GraphicPlotWidgetState extends State<GraphicPlotWidget> {
//   final scene = SimpleZoomScene();
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onScaleStart: scene.onScaleStart,
//       onScaleUpdate: scene.onScaleUpdate,
//       // onScaleEnd: scene.onScaleEnd,
//       child: SceneBuilderWidget(
//         builder: () => SceneController(front: scene),
//       ),
//     );
//   }
// }
//
// class SimpleZoomScene extends GSprite {
//   GSprite content;
//   List<GShape> boxes;
//   GIcon pivotIcon;
//
//   GPoint dragPoint = GPoint();
//   GPoint grabPoint = GPoint();
//   double grabRotation = 0.0;
//   double grabScale = 1.0;
//
//   @override
//   void addedToStage() {
//     super.addedToStage();
//     stage.maskBounds = true;
//     stage.color = Colors.grey.shade700;
//
//     /// a reference icon to understand how the pivot is assign for the
//     /// effect.
//     pivotIcon = GIcon(Icons.add_circle_outline, Colors.black45, 20);
//     pivotIcon.alignPivot(Alignment.center);
//
//     content = GSprite();
//     content.graphics.beginFill(Colors.grey.shade400).lineStyle(3, Colors.white).drawGRect(stage.stageRect).endFill();
//     addChild(content);
//
//     List<Color> _colors = schemeRainbow(_groups.length);
//     int i = 0;
//     for (var group in _groups) {
//       _addGroupDots(group, _colors[i]);
//       i++;
//     }
//
//     content.addChild(pivotIcon);
//     stage.onMouseScroll.add(_onMouseScroll);
//   }
//
//   List<String> _groups = [
//     'group1',
//     'group2',
//     'group3',
//     'group4',
//     'group5',
//     'group6',
//     'group7',
//     'group8',
//     'group9',
//     'group10',
//   ];
//
//   void _addGroupDots(String group, Color color) {
//     var random = math.Random();
//     GShape box = GShape();
//     box.graphics.beginFill(color);
//     for (int i = 0; i < 10000; i++) {
//       // box = GShape();
//       box.graphics.drawCircle(random.nextDouble() * width, random.nextDouble() * height, .5);
//
//       // box.setPosition(random.nextDouble() * width, random.nextDouble() * height);
//     }
//
//     box.graphics.endFill();
//     content.addChild(box);
//   }
//
//   void _onMouseScroll(MouseInputData event) {
//     dragPoint = event.stagePosition;
//     adjustContentTransform();
//
//     /// use mouse scroll wheel as incrementer for zoom.
//     var _scale = content.scale;
//     _scale += -event.scrollDelta.y * .001;
//     setZoom(_scale);
//
//     // content.children.forEach((box) {
//     //   box.x += box.x * (-event.scrollDelta.y * .001);
//     //   box.y += box.y * (-event.scrollDelta.y * .001);
//     // });
//   }
//
//   void onScaleStart(ScaleStartDetails details) {
//     /// If you need, you can detect 1 or more fingers here.
//     /// for move vs zoom.
//     if (details.pointerCount == 1) {}
//     dragPoint = GPoint.fromNative(details.localFocalPoint);
//     adjustContentTransform();
//     grabRotation = content.rotation;
//     grabScale = content.scale;
//   }
//
//   void adjustContentTransform() {
//     final pivotPoint = content.globalToLocal(dragPoint);
//     pivotIcon.x = content.pivotX = pivotPoint.x;
//     pivotIcon.y = content.pivotY = pivotPoint.y;
//     globalToLocal(dragPoint, grabPoint);
//     content.setPosition(grabPoint.x, grabPoint.y);
//   }
//
//   void onScaleUpdate(ScaleUpdateDetails details) {
//     final focalPoint = GPoint.fromNative(details.localFocalPoint);
//     final deltaX = focalPoint.x - dragPoint.x;
//     final deltaY = focalPoint.y - dragPoint.y;
//     content.setPosition(grabPoint.x + deltaX, grabPoint.y + deltaY);
//
//     /// use touch scale ratio for zoom.
//     final _scale = details.scale * grabScale;
//     setZoom(_scale);
//     content.rotation = details.rotation + grabRotation;
//   }
//
//   void setZoom(double zoom) {
//     content.scale = zoom.clamp(.5, 20.0);
//   }
//
//   void resetTransform() {
//     content.pivotX = content.pivotY = content.rotation = 0;
//     content.scale = 1;
//     content.setPosition(0, 0);
//     pivotIcon.setPosition(0, 0);
//     // content.transformationMatrix.identity();
//     // pivotIcon.transformationMatrix.identity();
//   }
// }
