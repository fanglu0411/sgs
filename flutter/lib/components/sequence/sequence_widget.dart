import 'dart:typed_data';
import 'dart:ui';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter_smart_genome/components/sequence/seq_color_schema.dart';
import 'package:flutter_smart_genome/widget/basic/custom_spin.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:math' show min;

import 'package:flutter/services.dart' show Clipboard, ClipboardData, rootBundle;
import 'package:flutter_smart_genome/widget/basic/custom_bot_widget.dart';

class SequenceWidget extends StatefulWidget {
  final String sequence;
  final Animation? animation;
  final double? width;
  final double seqSize;
  final bool colored;
  final TextStyle style;
  final bool showActions;
  final String? header;

  const SequenceWidget({
    Key? key,
    required this.sequence,
    this.style = const TextStyle(),
    this.animation,
    this.width,
    this.seqSize = 20,
    this.colored = true,
    this.showActions = true,
    this.header,
  }) : super(key: key);

  @override
  _SequenceWidgetState createState() => _SequenceWidgetState();
}

class _SequenceWidgetState extends State<SequenceWidget> {
  ValueChanged<Size>? onResizeCallback;

  Map<String, ui.Image> _seqImages = {};

  String? _colorSchema;

  @override
  void initState() {
    super.initState();
    _colorSchema = 'simple';
    _loadAssets();
  }

  Future<ui.Image> getImage(String asset) async {
    ByteData data = await rootBundle.load(asset);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    ui.FrameInfo fi = await codec.getNextFrame();
    return fi.image;
  }

  void _loadAssets() async {
    ui.Image a = await getImage('assets/images/seq_a.png');
    ui.Image t = await getImage('assets/images/seq_t.png');
    ui.Image c = await getImage('assets/images/seq_c.png');
    ui.Image g = await getImage('assets/images/seq_g.png');

    setState(() {
      _seqImages.addAll({
        'a': a,
        't': t,
        'c': c,
        'g': g,
        'A': a,
        'T': t,
        'C': c,
        'G': g,
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_seqImages.length == 0) return Center(child: CustomSpin(color: Theme.of(context).colorScheme.primary));

    if (widget.width != null && widget.width! > 0) {
      return _buildWidthWidth(widget.width!);
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        return _buildWidthWidth(constraints.maxWidth);
      },
    );
  }

  Widget _buildWidthWidth(double width) {
    String sequence = widget.sequence;

    Size _seqSize = Size(widget.seqSize, widget.seqSize);
//    if (!widget.colored) {
//      var textPainter = TextPainter(
//        text: TextSpan(text: 'A', style: widget.style),
//        textDirection: TextDirection.ltr,
//      )..layout();
//      _seqSize = Size(textPainter.width, widget.style.height ?? widget.style.fontSize);
//    }

    int rowLength = width ~/ _seqSize.width;
    int rowCount = sequence.length ~/ rowLength;
    if (sequence.length % rowLength > 0) {
      rowCount++;
    }

    int page = rowCount ~/ 5;
    if (rowCount % 5 > 0) page++;

    Widget listView = ListView.builder(
      key: Key(_colorSchema!),
      itemCount: page,
      // itemExtent: _seqSize.height * _rowCount,
      itemBuilder: (context, index) {
        int start = index * rowLength * 5;
        int end = min(start + rowLength * 5, sequence.length);

        String _sequence = sequence.substring(start, end);

        int _rowLength = width ~/ _seqSize.width;
        int _rowCount = _sequence.length ~/ rowLength;
        if (_sequence.length % rowLength > 0) {
          _rowCount++;
        }

        return CustomPaint(
          size: Size(width, _seqSize.height * _rowCount),
          painter: SequencePainter(
            sequence: _sequence,
            rowLength: _rowLength,
            rowCount: _rowCount,
            seqImages: _seqImages,
            colored: widget.colored,
            colorSchema: _colorSchema!,
          ),
        );
      },
    );
    // listView = Container(
    //   child: Scrollbar(child: listView),
    //   color: Colors.white,
    // );

    if (!widget.showActions) return listView;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          constraints: BoxConstraints.expand(height: 30),
          child: Row(
            children: [
              Text('Color Schema:'),
              Builder(
                builder: (context) {
                  return MaterialButton(
                    minWidth: 20,
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    onPressed: () => _showColorSchemaWidget(context),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [Text(_colorSchema!), Icon(Icons.arrow_drop_down)],
                    ),
                  );
                },
              ),
              Spacer(),
              IconButton(
                iconSize: 14,
                icon: Icon(Icons.content_copy),
                tooltip: 'Copy',
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: widget.sequence));
                  showToast(text: 'Sequence Copied');
                },
              ),
            ],
          ),
        ),
        if (widget.header != null) Text(widget.header!, style: TextStyle(fontFamily: 'Courier New', fontSize: 16)),
        Expanded(child: listView),
      ],
    );
  }

  void _showColorSchemaWidget(BuildContext context) {
    showAttachedWidget(
        targetContext: context,
        preferDirection: PreferDirection.bottomLeft,
        attachedBuilder: (cancel) {
          var children = seqColorSchemas.keys.map((e) => ListTile(
                title: Text(e),
                selected: e == _colorSchema,
                trailing: e == _colorSchema ? Icon(Icons.check) : null,
                onTap: () {
                  cancel();
                  setState(() {
                    _colorSchema = e;
                  });
                },
              ));
          return Material(
            elevation: 8,
            shadowColor: Theme.of(context).colorScheme.primary,
            child: Container(
              constraints: BoxConstraints.tightFor(width: 240, height: 300),
              child: Scrollbar(
                child: ListView(
                  children: ListTile.divideTiles(tiles: children, context: context).toList(),
                ),
              ),
            ),
          );
        });
  }
}

class SequencePainter extends CustomPainter {
  String sequence;
  bool _animation = false;
  double seqWidth;
  double? _fixedSeqWidth;
  bool? colored;

  int? rowLength;
  int? rowCount;

  String _colorSchema = 'aa';

  Paint? _paint;
  Map? colorSchema;

  Map<String, ui.Image>? seqImages;

  SequencePainter({
    required this.sequence,
    this.seqWidth = 20.0,
    required this.rowLength,
    required this.rowCount,
    required this.seqImages,
    this.colored = true,
    required String colorSchema,
  }) {
    _colorSchema = colorSchema;
    _paint = Paint();
    this.colorSchema = seqColorSchemas[_colorSchema];
  }

  @override
  void paint(Canvas canvas, Size size) {
    _fixedSeqWidth = size.width / rowLength!;

    String rowSeq;
    int start, end;
    for (int row = 0; row < rowCount!; row++) {
      start = row * rowLength!;
      end = min(start + rowLength!, sequence.length);
      rowSeq = sequence.substring(start, end);
      drawRow(canvas, rowSeq, _paint!, row, size);
    }
  }

  void drawRow(Canvas canvas, String seq, Paint paint, int row, Size size) {
    Rect rect;
    String chr;
    Color color;
    var _colorValue;
    for (int i = 0; i < seq.length; i++) {
      chr = seq[i];
      rect = Rect.fromLTWH(i * _fixedSeqWidth!, row * seqWidth, _fixedSeqWidth!, seqWidth);

      if (colored!) {
        _colorValue = colorSchema![chr.toUpperCase()] ?? colorSchema!['basic'];
        if (_colorValue != null) {
          color = Color(_colorValue);
          canvas.drawRect(rect, paint..color = color);
        }
      }

      drawImage(canvas, seqImages![chr]!, rect);
    }
  }

  @override
  bool shouldRepaint(SequencePainter oldDelegate) {
    return oldDelegate.sequence != sequence;
  }

  void drawText(
    Canvas canvas, {
    required String text,
    Offset offset = Offset.zero,
    TextStyle style = const TextStyle(),
    TextAlign textAlign = TextAlign.start,
    ui.TextDirection textDirection = ui.TextDirection.ltr,
    double? width,
  }) {
    TextPainter labelPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textAlign: textAlign,
      textDirection: textDirection,
    );
    labelPainter.layout(minWidth: width!, maxWidth: width);
    labelPainter.paint(canvas, offset);
  }

  void drawImage(Canvas canvas, ui.Image image, Rect rect) {
    canvas.drawImageRect(image, Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()), rect, _paint!);
  }
}
