import 'package:flutter/material.dart';

mixin EfpPageMixin<T extends StatefulWidget> on State<T> {
  final Map<int, Widget> anaTypes = const <int, Widget>{
    0: Text('Trans Exp'),
    1: Text('Sample Statics'),
    2: Text('DEGs Analysis'),
  };

  int currentSegment = 0;

  @override
  void initState() {
    super.initState();
  }

  void onValueChanged(int? newValue) {
    setState(() {
      currentSegment = newValue!;
    });
  }

  String chartType = 'heatmap';

  Widget buildChartWidget() {
    return Container(
      constraints: BoxConstraints.expand(),
//      color: Colors.lightGreen,
      child: Text('chart'),
    );
  }

  Widget buildDataWidget() {
    return Container(
      child: Text('data'),
    );
  }
}