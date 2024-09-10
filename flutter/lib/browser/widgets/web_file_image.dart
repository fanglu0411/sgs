import 'package:flutter/material.dart';
import 'dart:html' as html;

import 'package:flutter_smart_genome/util/logger.dart';
import 'package:flutter_smart_genome/widget/basic/custom_spin.dart';

class WebImage extends StatefulWidget {
  final html.File file;

  const WebImage({Key? key, required this.file}) : super(key: key);

  @override
  _WebImageState createState() => _WebImageState();
}

class _WebImageState extends State<WebImage> {
  _readFile(html.File file) async {
    final html.FileReader _reader = new html.FileReader();
    _reader
      ..onProgress.listen((e) {
        logger.i('reading ... ${e.loaded! * 1.0 / e.total!}');
      })
      ..onLoadEnd.listen((e) async {
        _onFileRead(_reader.result);
      });
    _reader.readAsArrayBuffer(file);
  }

  dynamic _fileContent;

  _onFileRead(result) {
    setState(() {
      _fileContent = result;
    });
  }

  @override
  void initState() {
    super.initState();

    _readFile(widget.file);
  }

  @override
  Widget build(BuildContext context) {
    var child;
    if (_fileContent == null) {
    child = CustomSpin(color: Theme.of(context).colorScheme.primary);
  } else {
    child = Image.memory(_fileContent);
  }
    return Container(
      alignment: Alignment.center,
      child: child,
    );
  }
}
