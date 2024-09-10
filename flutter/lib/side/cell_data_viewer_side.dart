import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/page/cell/cell_data_table/cell_data_table_view.dart';

class CellDataViewerSide extends StatefulWidget {
  const CellDataViewerSide({Key? key}) : super(key: key);

  @override
  State<CellDataViewerSide> createState() => _CellDataViewerSideState();
}

class _CellDataViewerSideState extends State<CellDataViewerSide> {
  @override
  Widget build(BuildContext context) {
    return CellDataTableView(tag: 'chart1');
  }
}
