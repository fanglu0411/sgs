import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/cell/point_data_matrix.dart';
import 'package:flutter_smart_genome/chart/scale/point.dart';
import 'package:flutter_smart_genome/chart/scale/vector_scale_ext.dart';
import 'package:flutter_smart_genome/chart/scale/vector_linear_scale.dart';
import 'package:image/image.dart' as ig;
import 'package:flutter_smart_genome/extensions/rect_extension.dart';

class ImageScatterPlot {
  ImageScatterPlot({
    required this.rect,
    required this.dataMatrix,
  }) {
    _srcImage = ig.Image(
      width: rect.width.floor(),
      height: rect.height.floor(),
    );
  }

  DensityCords dataMatrix;

  ui.Rect rect;

  ig.Image? _srcImage;
  ui.Image? _image;
  Uint8List? _imageBytes;
  Rect? _domainRect;

  Vector3LinearScale get scale => dataMatrix.scale!;

  ui.Image? get image => _image;

  update(Matrix4 matrix) async {
    // ig.fill(_srcImage, color: ig.Color(Colors.yellow.value));

    Rect targetRect = rect.transform(matrix);
    _domainRect = scale.revertRect(targetRect);
    // print('targetRect: $targetRect, domain: $_domainRect');

    dataMatrix.transform(matrix);

    dataMatrix.forEach((CordBlock block, int row, int col) {
      Point3<int> _viewDensity = Point3(rect.width ~/ dataMatrix.divisions!.x, rect.height ~/ dataMatrix.divisions!.y, 0);
      int x1 = (col * _viewDensity.x).toInt();
      int y1 = (row * _viewDensity.y).toInt();
      ig.drawRect(
        _srcImage!,
        x1: x1,
        y1: y1,
        x2: (x1 + _viewDensity.x).toInt(),
        y2: (y1 + _viewDensity.y).toInt(),
        color: ig.ColorInt16.rgb(0, 0, 0),
      );
    });

    await _renderImage();
  }

  _renderImage() async {
    // ig.drawString(_srcImage, ig.arial_24, 100, 100, 'hello world', color: Colors.red.value);
    _imageBytes = ig.encodePng(_srcImage!);
    _image = await _toImage();
  }

  Future<ui.Image> _toImage() {
    final Completer<ui.Image> completer = Completer<ui.Image>();
    ui.decodeImageFromPixels(
      _srcImage!.getBytes(),
      _srcImage!.width,
      _srcImage!.height,
      ui.PixelFormat.rgba8888,
      (ui.Image image) => completer.complete(image),
    );
    return completer.future;
  }
}
