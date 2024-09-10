import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/page/expression/expression_page_mixin.dart';
import 'package:flutter_smart_genome/widget/basic/simple_meu_widget.dart';

import 'efp_page_mixin.dart';

class EfpPageMobile extends StatefulWidget {
  @override
  _EfpPageMobileState createState() => _EfpPageMobileState();
}

class _EfpPageMobileState extends State<EfpPageMobile> with ExpressionPageMixin, EfpPageMixin<EfpPageMobile>, SingleTickerProviderStateMixin {
  TabController? _controller;

  @override
  void initState() {
    chartTypeMenus = [
      SMenuItem(type: 'heatmap', label: 'Heatmap'),
      SMenuItem(type: 'histogram', label: 'Histogram'),
      SMenuItem(type: 'broken-line', label: 'Broken Line Groph'),
    ];
    super.initState();
    _controller = TabController(length: anaTypes.length, vsync: this, initialIndex: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Multi Analysis eFP'),
        bottom: TabBar(tabs: anaTypes.values.map((e) => Tab(child: e)).toList(), controller: _controller),
        actions: buildActions(),
      ),
//      bottomNavigationBar: mobileBottomBar(),
      body: Container(
        constraints: BoxConstraints.expand(),
        child: buildTabletBody(),
      ),
    );
  }
}
