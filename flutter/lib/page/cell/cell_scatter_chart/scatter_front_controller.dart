import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/page/cell/cell_scatter_chart/scatter_label_position.dart';

class ScatterFrontController extends ChangeNotifier {
  double? maxScale;
  Rect? selectedRect;

  late bool showAxis;

  String? tapedCluster;
  Color? tapedClusterColor;

  late Matrix4 matrix;

  Offset? cursor;

  bool isDrawing;
  Path? drawingPath;

  Map<String, Float32List>? selectedPoints;

  double? pointSize;
  bool isSpatial;
  ScatterLabel? linkedCluster;

  ScatterFrontController({
    required this.matrix,
    this.tapedCluster,
    this.showAxis = false,
    this.selectedRect,
    this.cursor,
    this.isDrawing = false,
    this.drawingPath,
    this.selectedPoints,
    this.maxScale = 10.0,
    this.pointSize,
    this.isSpatial = false,
    this.tapedClusterColor,
    this.linkedCluster,
  });

  void update({
    Rect? selectedRect,
    Matrix4? matrix,
    String? tapedCluster,
    bool? showAxis,
    Offset? cursor,
    bool? isDrawing = false,
    Path? drawingPath,
    Map<String, Float32List>? selectedPoints,
    double? maxScale,
    double? pointSize,
    bool? isSpatial,
    Color? tapedClusterColor = null,
    ScatterLabel? linkedCluster,
  }) {
    this.selectedRect = selectedRect ?? this.selectedRect;
    this.showAxis = showAxis ?? this.showAxis;
    this.tapedCluster = tapedCluster;
    this.matrix = matrix ?? this.matrix;
    this.cursor = cursor ?? this.cursor;
    this.isDrawing = isDrawing ?? this.isDrawing;
    this.drawingPath = drawingPath;
    this.selectedPoints = selectedPoints ?? this.selectedPoints;
    this.maxScale = maxScale ?? this.maxScale;
    this.pointSize = pointSize ?? this.pointSize;
    this.isSpatial = isSpatial ?? this.isSpatial;
    this.tapedClusterColor = tapedClusterColor;
    this.linkedCluster = linkedCluster;
    notifyListeners();
  }

  clear({Map<String, Float32List>? selectedPoints}) {
    this.selectedPoints = selectedPoints;
    notifyListeners();
  }

  double get currentPointSize => isSpatial
      ? pointSize! //
      : (pointSize! + (matrix.getMaxScaleOnAxis() - 1) / (maxScale! - 1) * 10) / matrix.getMaxScaleOnAxis();

  double get pointScaledSize => 1.5 * (pointSize! + (matrix.getMaxScaleOnAxis() - 1) / (maxScale! - 1) * 10) / matrix.getMaxScaleOnAxis();
}
