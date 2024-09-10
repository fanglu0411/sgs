import 'package:flutter_smart_genome/page/cell/cell_page/cell_layers.dart';
import 'package:flutter_smart_genome/page/cell/cell_page/cell_page_mixin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/page/cell/cell_data_table/cell_data_table_view.dart';
import 'package:flutter_smart_genome/page/cell/container/cell_scatter_container.dart';
import 'package:flutter_smart_genome/widget/split_widget.dart';
import 'package:flutter_smart_genome/widget/track/base/track_data.dart';

import 'package:get/get.dart';

import 'cell_page_logic.dart';

class CellPage extends BaseCellPageWidget {
  const CellPage({
    Key? key,
    Track? track,
    bool asPage = false,
    bool showTitleBar = false,
  }) : super(key: key, track: track, asPage: asPage, showTitleBar: showTitleBar);

  @override
  _CellPageState createState() => _CellPageState();
}

class _CellPageState extends State<CellPage> with CellPageMixin<CellPage> {
  bool _showDataTable = false;

  late RxDouble _popTableHeight;
  late double _minTableHeight;
  late double _maxTableHeight;
  bool? _tableCanHide;

  Key _dataTable1Key = Key('data-table-1');
  Key _dataTable2Key = Key('data-table-2');

  @override
  Widget buildSingleCell(BuildContext context, BoxConstraints constraints, CellPageLogic logic) {
    final _height = constraints.maxHeight;
    double _width = constraints.maxWidth;

    if (_width > _height) {
      _width = _height;
    }

    var miHeight = _width + 180;

    bool _horizontal = constraints.maxWidth > 1000 && constraints.maxWidth / constraints.maxHeight >= 2;
    bool dataTablePop = !_horizontal && _height < miHeight;

    _minTableHeight = dataTablePop ? 180 : _height - _width - 8;
    _maxTableHeight = _height - 80;
    _popTableHeight = dataTablePop ? (constraints.maxHeight * .382).obs : _minTableHeight.obs;
    if (!dataTablePop) {
      _showDataTable = true;
    }
    _tableCanHide = dataTablePop;

    // Widget _body =  CellScatterChartView(
    //   showDataPop: !_horizontal,
    //   tag: CellPageLogic.CHART_TAG_1,
    //   focused: true,
    //   size: Size.fromWidth(_width),
    // );

    Widget _body = CellScatterContainer(showDataPop: !_horizontal);

    if (_horizontal) {
      _body = Row(
        children: [
          Expanded(child: _body, flex: 3),
          VerticalDivider(thickness: 1),
          Expanded(
            flex: 2,
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 10),
              child: GetBuilder<CellPageLogic>(
                id: CellLayer.dataTableLayer,
                autoRemove: false,
                builder: (c) {
                  return CellDataTableView(
                    key: logic.currentChartTag == CellPageLogic.CHART_TAG_1 ? _dataTable1Key : _dataTable2Key,
                    tag: logic.currentChartTag,
                    pop: false,
                    onHide: logic.toggleDataTable,
                  );
                },
              ),
            ),
          ),
        ],
      );
    } else {}

    return _body;
  }

  Widget buildDataTablePop(double height) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MouseRegion(
            cursor: SystemMouseCursors.resizeRow,
            child: GestureDetector(
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(6), topRight: Radius.circular(6)),
                ),
                clipBehavior: Clip.hardEdge,
                child: DefaultSplitter(isHorizontal: false, splitterWidth: 8),
              ),
              onPanUpdate: (event) {
                var _h = _popTableHeight.value - event.delta.dy;
                if (_h < _minTableHeight) _h = _minTableHeight;
                if (_h > _maxTableHeight) _h = _maxTableHeight;
                _popTableHeight.value = _h;
              },
            ),
          ),
          ObxValue<RxDouble>(
            (h) => Container(
              color: Theme.of(context).cardColor,
              constraints: BoxConstraints.expand(height: h.value),
              child: CellDataTableView(
                tag: logic!.currentChartTag,
                pop: _tableCanHide!,
                onHide: _tableCanHide!
                    ? () {
                        setState(() {
                          _showDataTable = !_showDataTable;
                        });
                      }
                    : null,
              ),
            ),
            _popTableHeight,
          ),
        ],
      ),
    );
  }
}
