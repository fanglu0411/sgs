import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/page/expression/expression_page_mixin.dart';
import 'package:flutter_smart_genome/widget/basic/simple_meu_widget.dart';

import 'efp_page_mixin.dart';

class EfpPageTablet extends StatefulWidget {
  @override
  _EfpPageTabletState createState() => _EfpPageTabletState();
}

class _EfpPageTabletState extends State<EfpPageTablet> with ExpressionPageMixin, EfpPageMixin<EfpPageTablet>, SingleTickerProviderStateMixin {
  @override
  void initState() {
    chartTypeMenus = [
      SMenuItem(type: 'heatmap', label: 'Heatmap'),
      SMenuItem(type: 'histogram', label: 'Histogram'),
      SMenuItem(type: 'broken-line', label: 'Broken Line Groph'),
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text('Multi Analysis eFP'),
        actions: menuItems
            .map((e) => TextButton.icon(
                  onPressed: () {},
                  icon: e.icon!,
                  label: e.title!,
                ))
            .toList(),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(vertical: 10),
//            color: Theme.of(context).colorScheme.primaryLight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                CupertinoSlidingSegmentedControl<int>(
                  padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  children: anaTypes,
                  onValueChanged: onValueChanged,
                  groupValue: currentSegment,
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: buildTabletBody(),
            ),
          ),
        ],
      ),
    );
  }
}
