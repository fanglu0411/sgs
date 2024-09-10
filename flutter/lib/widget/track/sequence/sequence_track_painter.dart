import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/browser/codon_table.dart';
import 'package:d4_scale/d4_scale.dart';
import 'package:flutter_smart_genome/d3/d3_mixin.dart';

import 'package:flutter_smart_genome/widget/track/base/track_data.dart';
import 'package:flutter_smart_genome/widget/track/base/abstract_track_painter.dart';
import 'package:flutter_smart_genome/widget/track/common.dart';
import 'package:flutter_smart_genome/widget/track/sequence/sequence_data.dart';
import 'package:flutter_smart_genome/widget/track/sequence/sequence_style_config.dart';

class SequenceTrackPainter extends AbstractTrackPainter<SequenceData, SequenceStyleConfig> {
  late Paint _paint;
  late Paint _bgPaint;
  late Paint _blockPaint;
  late double pixelOfSeq;

  bool translateProtein;

  late Map _codonTable;

  SequenceTrackPainter({
    required SequenceData trackData, // may be data in a range
    required SequenceStyleConfig styleConfig,
    required ScaleLinear<num> linearScale, // the scale by the hole chromosome
    required this.pixelOfSeq,
    required Range visibleRange,
    Axis? orientation,
    Track? track,
    this.translateProtein = true,
  }) : super(
          trackData: trackData,
          styleConfig: styleConfig,
          scale: linearScale,
          track: track,
          orientation: orientation,
          visibleRange: visibleRange,
        ) {
    _paint = Paint()
      ..color = Colors.green[200]!
      ..strokeWidth = 1;

    _bgPaint = Paint();
    _blockPaint = Paint();

    _codonTable = generateCodonTable(defaultCodonTable);
    maxHeight = translateProtein ? styleConfig.seqHeight + styleConfig.proteinHeight * 3 : styleConfig.seqHeight;
  }

  String codon(String seq) {
    return _codonTable[seq] ?? '*';
  }

  @override
  void onPaint(Canvas canvas, Size size, Rect painterRect) {
    if (styleConfig.backgroundColor != null) {
      canvas.drawRect(rect, _bgPaint..color = styleConfig.backgroundColor!);
    }

    // print('range ${trackData.range}');
    // print('seq range ${trackData.sequenceRange}');
    Range range = trackData.range;

    int _start = range.start.ceil() - 2;
    if (_start < 0) _start = 0;
    int _end = range.end.ceil();

    // print('_start: $_start, _end: $_end');

    double seqSize = pixelOfSeq; // 1 / (sizeOfPixel);

    if (orientation == Axis.vertical) {
      drawVerticalSeq(canvas, size, _start, _end, seqSize);
      if (translateProtein) drawVerticalProtein(canvas, size, _start, _end, seqSize);
    } else {
      drawHorizontalSequence(canvas, size, _start, _end, seqSize);
      if (translateProtein) drawHorizontalProtein(canvas, size, _start, _end, seqSize);
    }
  }

  void drawVerticalSeq(Canvas canvas, Size size, int _start, int _end, double seqHeight) {
    String char;
    double top = scale[_start]!;
    double left = size.width / 2 - styleConfig.seqHeight / 2;
    Color _color;
    bool drawSeq = seqHeight >= TrackUIConfig.MIN_SEQ_SIZE;
    for (int i = _start; i <= _end; i++) {
      char = trackData[i];
      _color = styleConfig.seqColor[char] ?? Colors.grey[100]!;
      canvas.drawRect(Rect.fromLTWH(left, top, styleConfig.seqHeight, seqHeight), _paint..color = _color);
      if (drawSeq)
        drawText(
          canvas,
          text: char,
          offset: Offset(left, top + seqHeight / 2 - 6),
          style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
          textAlign: TextAlign.center,
          width: styleConfig.seqHeight,
        );
      top += seqHeight;
    }
  }

  void drawHorizontalSequence(Canvas canvas, Size size, int _start, int _end, double seqWidth) {
    double left = scale[_start] as double;
    double top = translateProtein ? styleConfig.proteinHeight * 3 : 0; // (size.height - styleConfig.seqHeight) / 2;
    Color _color;
    String char;
    bool drawSeq = seqWidth >= styleConfig.seqFontSize * 1.2;
    Color _defColor = styleConfig.brightness == Brightness.dark ? Colors.grey[600]! : Colors.grey[400]!;

    //range 和 数据 下标关系 有 -1差
    for (int i = _start; i <= _end; i++) {
      if (i < 0) continue;
      char = trackData[i] ?? '-';
      //logger.d('i: $i, left: $left, chr: ${trackData[i]}');
      _color = styleConfig.seqColor[char.toUpperCase()] ?? _defColor;
      canvas.drawRect(Rect.fromLTWH(left, top, seqWidth, styleConfig.seqHeight), _paint..color = _color);
      if (drawSeq)
        drawText(
          canvas,
          text: char,
          offset: Offset(left, top + ((styleConfig.seqHeight - styleConfig.seqFontSize) / 2).floor()),
          style: TextStyle(color: Colors.white, fontSize: styleConfig.seqFontSize, fontWeight: FontWeight.w400),
          textAlign: TextAlign.center,
          width: seqWidth,
        );
      left += seqWidth;
    }
  }

  void drawVerticalProtein(Canvas canvas, Size size, int _start, int _end, double seqHeight) {}

  void drawHorizontalProtein(Canvas canvas, Size size, int _start, int _end, double seqWidth) {
    int __start = (_start % 3) > 0 ? _start - (_start % 3) : _start;
    double left = scale[__start] as double;

    double proteinWidth = seqWidth * 3;
    bool drawSeq = proteinWidth >= TrackUIConfig.MIN_SEQ_SIZE;

    Color color1, color2, color3;
    for (int i = __start; i <= _end; i += 3) {
      color1 = (i / 3) % 2 == 0 ? styleConfig.proteinColor1 : styleConfig.proteinColor2;
      color2 = (i / 3) % 2 == 1 ? styleConfig.proteinColor1 : styleConfig.proteinColor2;
      color3 = (i / 3) % 2 == 0 ? styleConfig.proteinColor1 : styleConfig.proteinColor2;

      _drawProteinRow(canvas, i + 2, 0, color3, proteinWidth, left + seqWidth * 2, 0, drawSeq);
      _drawProteinRow(canvas, i + 1, 1, color2, proteinWidth, left + seqWidth, styleConfig.proteinHeight, drawSeq);
      _drawProteinRow(canvas, i, 2, color1, proteinWidth, left, styleConfig.proteinHeight * 2, drawSeq);

      left += proteinWidth;
    }
  }

  void _drawProteinRow(Canvas canvas, int index, int row, Color color, double proteinWidth, double left, double top, bool drawSeq) {
    canvas.drawRect(Rect.fromLTWH(left, top + .5, proteinWidth, styleConfig.proteinHeight - .5), _paint..color = color);
    if (drawSeq) {
      String protein = codon('${trackData[index]}${trackData[index + 1]}${trackData[index + 2]}');
      drawText(
        canvas,
        text: protein,
        offset: Offset(left, top + (styleConfig.proteinHeight - styleConfig.seqFontSize) / 2),
        style: TextStyle(color: Colors.white, fontSize: styleConfig.seqFontSize, fontWeight: FontWeight.w400),
        textAlign: TextAlign.center,
        width: proteinWidth,
      );
    }
  }

  @override
  bool painterChanged(AbstractTrackPainter painter) {
    SequenceTrackPainter _painter = painter as SequenceTrackPainter;
    return super.painterChanged(_painter) || trackData.range != _painter.trackData.range;
  }

  @override
  bool hitTest(Offset position) {
    return rect.contains(position);
  }
}
