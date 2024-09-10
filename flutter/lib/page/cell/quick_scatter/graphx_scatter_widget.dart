// import 'dart:ui';
//
// import 'package:dartx/dartx.dart';
// import 'package:flutter/material.dart';
// import 'package:graphx/graphx.dart';
// import 'package:vector_math/vector_math_64.dart' as vm;
//
// class GraphxScatter extends StatelessWidget {
//   final Map<String, List<vm.Vector3>>? pointsMap;
//   final Map<String, Color>? colors;
//
//   late GroupScatterSprite scene;
//
//   GraphxScatter({super.key, this.pointsMap, this.colors}) {
//     scene = GroupScatterSprite(pointsMap, colors);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return ConstrainedBox(
//       constraints: BoxConstraints.expand(),
//       child: GestureDetector(
//         onScaleStart: scene.onScaleStart,
//         onScaleUpdate: scene.onScaleUpdate,
//         child: SceneBuilderWidget(
//           autoSize: true,
//           builder: () {
//             return SceneController(
//               back: scene,
//               config: SceneConfig.static,
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
//
// class GroupScatterSprite extends GSprite {
//   final Map<String, List<vm.Vector3>>? pointsMap;
//   final Map<String, Color>? colors;
//
//   GroupScatterSprite(this.pointsMap, this.colors);
//
//   GPoint dragPoint = GPoint();
//   GPoint grabPoint = GPoint();
//   double grabRotation = 0.0;
//   double grabScale = 1.0;
//   late GSprite content = GSprite();
//   GSprite anchor = GSprite();
//
//   @override
//   void addedToStage() {
//     super.addedToStage();
//     stage!.maskBounds = true;
//     stage!.color = Colors.grey.shade700;
//     // content = GSprite();
//     content.graphics.beginFill(Colors.grey.shade400).lineStyle(3, Colors.white).drawGRect(stage!.stageRect).endFill();
//     addChild(content);
//     if (null == pointsMap) return;
//
//     anchor.graphics.beginFill(Colors.green).drawRect(0, 0, 4, 4).endFill();
//     anchor.alignPivot();
//     content.addChild(anchor);
//
//     int i = 0;
//     pointsMap!.keys.forEach((k) {
//       // if (i == 0) return;
//       content.addChild(GraphxScatterSprite(pointsMap![k]!, colors![k]!));
//       i++;
//     });
//
//     resetContentInitialPosition();
//     stage!.onMouseScroll.add(_onMouseScroll);
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
//     anchor.x = content.pivotX = pivotPoint.x;
//     anchor.y = content.pivotY = pivotPoint.y;
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
//     content.scale = zoom.clamp(.5, 100.0);
//   }
//
//   void resetContentInitialPosition() {
//     content.scale = 0.8;
//     content.alignPivot();
//     content.centerInStage();
//   }
// }
//
// class GraphxScatterSprite extends GSprite {
//   final List<vm.Vector3> points;
//   final Color color;
//
//   GraphxScatterSprite(this.points, this.color);
//
//   @override
//   void addedToStage() {
//     super.addedToStage();
//     print('dddd ${stage?.stageWidth}');
//     graphics.beginFill(color);
//
//     var _p;
//     for (var p in points) {
//       _p = p.scaled(stage!.stageWidth / 65535) / parent!.scale;
//       graphics.drawCircle(_p.x, _p.y, 2);
//     }
//     graphics.endFill();
//   }
//
//   @override
//   void $applyPaint(Canvas canvas) {
//     var _scale = stage!.stageWidth / 65535 / parent!.scale;
//     var _points = points.map((e) => e.scaled(_scale)).map((e) => [e.x, e.y]).flatten().toList();
//     print('_scale:$_scale');
//     canvas.drawRawPoints(
//         PointMode.points,
//         Float32List.fromList(_points),
//         Paint()
//           ..color = color
//           ..strokeWidth = 4);
//   }
// }
//
// class CircleShape extends GShape {
//   final double x, y;
//   final Color color;
//
//   CircleShape(this.x, this.y, this.color) {
//     graphics.beginFill(color).drawCircle(x, y, 4).endFill();
//   }
//
//   @override
//   void addedToStage() {}
// }