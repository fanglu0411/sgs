import 'package:flutter_smart_genome/page/cell/cell_page/cell_page_mixin.dart';

import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/page/cell/container/cell_scatter_container.dart';
import 'package:flutter_smart_genome/widget/track/base/track_data.dart';


import 'cell_page_logic.dart';

class CellPageBig extends BaseCellPageWidget {
  const CellPageBig({
    Key? key,
    Track? track,
    bool asPage = false,
    bool showTitleBar = false,
  }) : super(key: key, track: track, asPage: asPage, showTitleBar: showTitleBar);

  @override
  _CellPageState createState() => _CellPageState();
}

class _CellPageState extends State<CellPageBig> with CellPageMixin<CellPageBig> {
  @override
  Widget buildSingleCell(BuildContext context, BoxConstraints constraints, CellPageLogic logic) {
    // return Container(padding: EdgeInsets.all(10), child: CellScatterChartView(tag: 'chart1'));
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: CellScatterContainer(),
    );
  }
}
