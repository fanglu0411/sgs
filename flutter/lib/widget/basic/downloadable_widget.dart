import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_smart_genome/util/file_util.dart';
import 'package:flutter_smart_genome/util/widget_util.dart';

class DownloadAbleWidget extends StatelessWidget {
  final Widget child;
  final Widget? icon;
  final String fileName;

  DownloadAbleWidget({
    Key? key,
    required this.child,
    this.icon,
    required this.fileName,
  }) : super(key: key);

  GlobalKey _repaintBoundaryKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        RepaintBoundary(
          key: _repaintBoundaryKey,
          child: child,
        ),
        Align(
          alignment: Alignment.topRight,
          child: IconButton(
            icon: icon ?? Icon(Icons.download),
            tooltip: 'Export Image',
            onPressed: _download,
          ),
        ),
      ],
    );
  }

  _download() async {
    await WidgetUtil.widget2Image(_repaintBoundaryKey, fileName: fileName);
  }
}
