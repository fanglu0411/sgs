import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter_smart_genome/components/blaster.dart';

class SingleAlignmentWidget extends StatefulWidget {
  final BlastAlignment blastAlignment;

  const SingleAlignmentWidget({Key? key, required this.blastAlignment}) : super(key: key);

  @override
  _SingleAlignmentWidgetState createState() => _SingleAlignmentWidgetState();
}

class _SingleAlignmentWidgetState extends State<SingleAlignmentWidget> {
  int _hspIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    BlastAlignment blastAlignment = widget.blastAlignment;
    HSP hsp = blastAlignment.hsps[_hspIndex];

    Map<int, Widget> hspSegments = {};
    for (int i = 0; i < blastAlignment.hsps.length; i++) {
      hspSegments[i] = Padding(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Text('Hsp ${i + 1}'),
      );
    }
    Color textColor = Theme.of(context).textTheme.bodyMedium!.color!;

    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(padding: EdgeInsets.symmetric(vertical: 10), child: Text('${blastAlignment.description}')),
          if (blastAlignment.hsps.length > 1)
            CupertinoSegmentedControl(
              padding: EdgeInsets.zero,
              groupValue: _hspIndex,
              children: hspSegments,
              onValueChanged: (v) {
                setState(() {
                  _hspIndex = v as int;
                });
              },
            ),
          Container(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: buildStatics(hsp),
          ),
          SizedBox(height: 10),
          Scrollbar(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: CustomPaint(
                size: Size(1200, 60),
                painter: SingleAlignmentPainter(hsp, textColor),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildStatics(HSP hsp) {
    bool _isMobile = MediaQuery.of(context).size.width <= 800;
    if (_isMobile) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: staticItem('Score:', '${hsp.score}')),
              Expanded(child: staticItem('Expect:', '${hsp.eValue}')),
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: staticItem('Identities:', '${hsp.identities}%')),
              Expanded(child: staticItem('Positives:', '${hsp.positives}%')),
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: staticItem('Gaps:', '${hsp.gaps}%')),
              Expanded(child: SizedBox()),
            ],
          )
        ],
      );
    }
    return Row(
      children: [
        Expanded(child: staticItem('Score:', '${hsp.score}')),
        Expanded(child: staticItem('Expect:', '${hsp.eValue}')),
        Expanded(child: staticItem('Identities:', '${hsp.identities}%')),
        Expanded(child: staticItem('Positives:', '${hsp.positives}%')),
        Expanded(child: staticItem('Gaps:', '${hsp.gaps}%')),
      ],
    );
  }

  Widget staticItem(String label, String value) {
    return Row(
      children: [
        Expanded(child: Text(label)),
        Expanded(child: Text(value)),
      ],
    );
  }
}

class SingleAlignmentPainter extends CustomPainter {
  HSP hsp;

  double labelWidth = 80;
  double startWidth = 60;
  double letterWidth = 20;

  double? width;

  Paint _paint = Paint();

  Color textColor;

  SingleAlignmentPainter(this.hsp, [this.textColor = Colors.black54]) {
    width = hsp.query.length * letterWidth + 2 * startWidth + labelWidth;
  }

  @override
  void paint(Canvas canvas, Size size) {
    double left = labelWidth + startWidth;

    drawText(
      canvas,
      text: 'Query',
      style: TextStyle(fontSize: 16, color: textColor),
      offset: Offset(0, 2),
      width: labelWidth,
    );
    drawText(
      canvas,
      text: '${hsp.queryStart}',
      style: TextStyle(fontSize: 16, color: textColor),
      offset: Offset(labelWidth, 2),
      width: startWidth,
    );
    _drawSequence(canvas, hsp.query, Offset(left, 0));
    _drawSequence(canvas, hsp.comparison, Offset(left, 20));

    drawText(
      canvas,
      text: 'Subject',
      style: TextStyle(fontSize: 16, color: textColor),
      offset: Offset(0, 42),
      width: labelWidth,
    );
    drawText(
      canvas,
      text: '${hsp.subjectStart}',
      style: TextStyle(fontSize: 16, color: textColor),
      offset: Offset(labelWidth, 40),
      width: startWidth,
    );
    _drawSequence(canvas, hsp.subject, Offset(left, 40));
  }

  void _drawSequence(Canvas canvas, String sequence, Offset offset) {
    for (int i = 0; i < sequence.length; i++) {
      canvas.drawRect(
        Rect.fromLTWH(offset.dx + i * letterWidth, offset.dy, letterWidth, 20),
        _paint..color = Blaster.getAminoColor(sequence[i]),
      );
      drawText(
        canvas,
        text: sequence[i],
        textAlign: TextAlign.center,
        offset: Offset(offset.dx + i * letterWidth, offset.dy + 2),
        width: letterWidth,
        style: TextStyle(color: Colors.black87),
      );
    }
  }

  void drawText(
    Canvas canvas, {
    required String text,
    Offset offset = Offset.zero,
    TextStyle style = const TextStyle(),
    TextAlign textAlign = TextAlign.start,
    ui.TextDirection textDirection = ui.TextDirection.ltr,
    required double width,
  }) {
    TextPainter labelPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textAlign: textAlign,
      textDirection: textDirection,
    );
    labelPainter.layout(minWidth: width, maxWidth: width);
    labelPainter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(SingleAlignmentPainter oldDelegate) {
    return oldDelegate.hsp != hsp;
  }
}
