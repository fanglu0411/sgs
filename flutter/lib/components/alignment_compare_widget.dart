import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/components/blaster.dart';

import 'alignment_widget.dart';

class AlignmentCompareWidget extends StatefulWidget {
  final ValueChanged<int>? onTap;
  final Blaster blaster;

  final EdgeInsets? padding;

  const AlignmentCompareWidget({Key? key, required this.blaster, this.onTap, this.padding}) : super(key: key);

  @override
  _AlignmentCompareWidgetState createState() => _AlignmentCompareWidgetState();
}

class _AlignmentCompareWidgetState extends State<AlignmentCompareWidget> {
  @override
  Widget build(BuildContext context) {
    Blaster _blaster = widget.blaster;
    List<BlastAlignment> currentAlignments = _blaster.currentAlignments;
    int queryLength = _blaster.getQueryLength(_blaster.queryList[_blaster.currentQueryIndex]);
    List<Widget> aw = [
      headerLabel(),
      colorTicker(),
      SizedBox(height: 10),
      queryItem(),
      numberTicker(queryLength),
    ];

    for (int i = 0; i < currentAlignments.length; i++) {
      Color color = _blaster.getColor(
        widget.blaster.colored,
        true,
        double.parse(currentAlignments[i].hsps[0].score),
        double.parse(currentAlignments[i].hsps[0].eValue),
      );
      Widget alignmentWidget = AlignmentWidget(
        blastAlignment: currentAlignments[i],
        hpsWithoutOverlapping: _blaster.getHSPWithoutOverlapping(currentAlignments[i].hsps),
        queryLength: queryLength,
        color: color,
      );
      alignmentWidget = InkWell(
        hoverColor: Colors.lightGreen,
        onTap: () => widget.onTap?.call(i),
        child: alignmentWidget,
      );
      aw.add(alignmentWidget);
    }
    return Container(
//      color: Colors.grey[200],
      padding: widget.padding,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: aw,
        ),
      ),
    );
  }

  Widget headerLabel() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Text(
        'COLOR KEY FOR ALIGNMENT SCORES',
        style: TextStyle(fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget colorTicker() {
    List<Widget> children = List.generate(
      5,
      (index) => Container(
        color: widget.blaster.getDivColor(widget.blaster.colored, index + 1),
        height: 20,
        alignment: Alignment.center,
        child: Text(
          widget.blaster.getDivColorText(widget.blaster.colored, index + 1),
          textScaleFactor: 1.2,
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
    return Row(
      children: children.map((e) => Expanded(child: e)).toList(),
    );
  }

  Widget queryItem() {
    return Container(
      height: 20,
      color: widget.blaster.colored ? Color(0xffc0392b) : Color(0xff343434),
    );
  }

  Widget numberTicker(queryLength) {
    return LayoutBuilder(
      builder: (context, contrainst) {
        int tickerCount;

        if (queryLength > 4) {
          tickerCount = 5;
        } else {
          tickerCount = queryLength;
        }

        double pixValue = queryLength / contrainst.maxWidth;
        double valuePixels = contrainst.maxWidth / queryLength;

        int tickerSize = queryLength ~/ tickerCount;

        int extra = queryLength % tickerCount;

        double tickerWidth = tickerSize * valuePixels;

        List<Widget> tickerItems = [];

        for (int i = 0; i < tickerCount; i++) {
          tickerItems.add(Container(
            alignment: Alignment.centerRight,
            width: tickerWidth,
            child: Text('${tickerSize * (i + 1)}'),
          ));
        }

//        if (extra > 0) {
//          tickerItems.add(Container(
//            alignment: Alignment.centerRight,
//            width: extra * valuePixels,
//            child: Text('${queryLength}'),
//          ));
//        }
        return Container(
          height: 20,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: tickerItems,
          ),
        );
      },
    );
  }
}