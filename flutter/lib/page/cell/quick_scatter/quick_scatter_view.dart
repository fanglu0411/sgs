import 'package:flutter/material.dart';
import 'package:ditredi/ditredi.dart';
import 'package:flutter_smart_genome/page/cell/quick_scatter/quick_scatter_draggable.dart';
import 'package:vector_math/vector_math_64.dart' as vm;

class QuickScatterView extends StatelessWidget {
  // final Map<String, List<vm.Vector3>> points;
  final Map<String, Color> colors;

  final _controller = DiTreDiController(
    rotationX: 0,
    rotationY: 0,
    maxUserScale: 150,
    minUserScale: .1,
    light: vm.Vector3(-0.5, -0.5, 0.5),
  );

  Map<String, List<Point3D>> _points = {};

  QuickScatterView({super.key, required this.colors, required Map<String, List<vm.Vector3>> points}) {
    _points = points.map((k, value) => MapEntry(k, value.map((e) => Point3D(e, width: 2, color: colors[k])).toList()));
  }

  @override
  Widget build(BuildContext context) {
    return QuickDiTreDiDraggable(
        rotationEnabled: false,
        controller: _controller,
        child: Stack(
          children: [
            ..._points.keys.mapIndexed((k, i) {
              if (i > 20) return SizedBox();
              return DiTreDi(
                controller: _controller,
                figures: _points[k]!,
                bounds: vm.Aabb3.minMax(vm.Vector3.zero(), vm.Vector3(65535, 65535, 0)),
              );
            }),
            // CustomPaint(
            //   painter: ,
            // ),
          ],
        ));
  }
}
