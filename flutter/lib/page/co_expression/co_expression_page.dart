import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/base/ui_config.dart';
import 'package:flutter_smart_genome/page/expression/expression_page_mixin.dart';

class CoExpressionPage extends StatefulWidget {
  @override
  _CoExpressionPageState createState() => _CoExpressionPageState();
}

class _CoExpressionPageState extends State<CoExpressionPage> with ExpressionPageMixin<CoExpressionPage>, SingleTickerProviderStateMixin {
  late TabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TabController(length: 2, vsync: this, initialIndex: 0);
  }

  @override
  Widget build(BuildContext context) {
    bool _isMobile = isMobile(context);
    return Scaffold(
      appBar: _isMobile ? AppBar(title: Text('Co-expression'), actions: buildActions()) : null,
      body: buildTabletBody(),
    );
  }

  @override
  Widget buildChartWidget() {
    return Container(
      constraints: BoxConstraints.expand(),
      child: Text('chart'),
    );
  }

  @override
  Widget buildDataWidget() {
    return Container(
      constraints: BoxConstraints.expand(),
      child: Text('data'),
    );
  }
}