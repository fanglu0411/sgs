import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/components/blaster.dart';
import 'package:flutter_smart_genome/util/logger.dart';

class AlignmentWidget extends StatelessWidget {
  final BlastAlignment blastAlignment;
  final List<Map> hpsWithoutOverlapping;
  final Color color;
  final int queryLength;

  const AlignmentWidget({Key? key, required this.color, required this.queryLength, required this.blastAlignment, required this.hpsWithoutOverlapping}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints.expand(height: 20),
      padding: EdgeInsets.symmetric(vertical: 4),
      child: CustomPaint(
        painter: AlignmentPainter(
          blastAlignment,
          hpsWithoutOverlapping: hpsWithoutOverlapping,
          queryLength: queryLength,
          color: color,
        ),
      ),
    );
  }
}

class AlignmentPainter extends CustomPainter {
  List<Map> hpsWithoutOverlapping;
  int queryLength;
  Color color;
  AlignmentPainter(
    BlastAlignment blastAlignment, {
    required this.hpsWithoutOverlapping,
    required this.queryLength,
    required this.color,
  });

  Paint _paint = Paint()..color = Colors.lightGreen;
  @override
  void paint(Canvas canvas, Size size) {
    double width = size.width;
    logger.d('overlaping length: ${hpsWithoutOverlapping.length}');
    double init = 0;
    double offset = 0;
    for (int i = 0; i < hpsWithoutOverlapping.length; i++) {
      if (i == 0) {
        if (hpsWithoutOverlapping[0]['start'] == 1) {
          init = (((width * (hpsWithoutOverlapping[0]['start'] - 1)) / queryLength));
        } else {
          init = (((width * (hpsWithoutOverlapping[0]['start'])) / queryLength));
        }
        offset = (width - init - (width * (queryLength - hpsWithoutOverlapping[0]['end']) / queryLength));
      } else {
        init = init + offset + width * (hpsWithoutOverlapping[i]['start'] - hpsWithoutOverlapping[i - 1]['end']) / queryLength;
        offset = width * (hpsWithoutOverlapping[i]['end'] - hpsWithoutOverlapping[i]['start']) / queryLength;
      }
      Rect rect = Rect.fromLTWH(init, 0, offset, size.height);
      logger.d(rect);
      logger.d(color);
      canvas.drawRect(rect, _paint..color = color);
    }
  }

  @override
  bool shouldRepaint(AlignmentPainter oldDelegate) {
    return false;
  }
}