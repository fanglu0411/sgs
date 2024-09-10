import 'package:dartx/dartx.dart' as dx;
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/bean/feature_beans.dart';
import 'package:flutter_smart_genome/components/range_info_widget.dart';
import 'package:flutter_smart_genome/side/vcf/vcf_data_table.dart';
import 'package:flutter_smart_genome/util/debouncer.dart';
import 'package:flutter_smart_genome/widget/loading_widget.dart';
import 'package:flutter_smart_genome/widget/quick_data_grid/data_column.dart';
import 'package:flutter_smart_genome/widget/quick_data_grid/quick_data_grid.dart';
import 'package:flutter_smart_genome/widget/table/simple_data_table_source.dart';
import 'package:flutter_smart_genome/widget/table/simple_paginated_data_table.dart';
import 'package:flutter_smart_genome/widget/track/base/track_data.dart';
import 'package:get/get.dart';

class DataViewerLogic extends GetxController {
  static DataViewerLogic? safe() {
    if (Get.isRegistered<DataViewerLogic>()) {
      return Get.find<DataViewerLogic>();
    }
    return null;
  }

  Track? _track;

  Track? get track => _track;
  List _data = [];

  List get data => _data;

  bool get isEmpty => _data.isEmpty;

  setData(List? data, {Track? track}) {
    _data = data ?? [];
    _track = track;
    update();
  }
}

class DataViewerSide extends StatefulWidget {
  @override
  _DataViewerSideState createState() => _DataViewerSideState();
}

class _DataViewerSideState extends State<DataViewerSide> {
  List<ColumnKey> _columnKeys = [];

  late Debounce _debounce;
  String? _keyword;
  late TextEditingController _textEditingController;

  DataViewerLogic? logic;

  @override
  void initState() {
    super.initState();
    logic = DataViewerLogic.safe() ?? Get.put(DataViewerLogic());
    _debounce = Debounce(milliseconds: 300);
    _textEditingController = TextEditingController();
  }

  List<String> getObjectKeys(obj) {
    if (obj is Feature) return obj.json.keys.map((e) => '${e}').toList();
    if (obj is Map) return obj.keys.map((e) => '${e}').toList();
    return ['${obj.runtimeType}'];
  }

  _initColumnKeys(_data) {
    List<ColumnKey> _keyList;
    if (_data is Feature) {
      _keyList = _data.json.keys.where((value) => value != 'children').map((e) => ColumnKey(e)).toList();
    } else if (_data is Map) {
      _keyList = _data.keys.where((value) => value != 'children').map((e) => ColumnKey(e)).toList();
    } else if (_data is List) {
      _keyList = List.generate(_data.length, (i) => ColumnKey('Cell ${i + 1}'));
    } else {
      _keyList = [ColumnKey('value')];
    }

    if (!listEquals(_keyList, _columnKeys)) {
      _columnKeys = _keyList;
    }
  }

  List<ColumnKey> get selectedColumns => _columnKeys.where((e) => e.selected).toList();

  Widget _header() {
    return Row(
      children: [
        Container(
          height: 32,
          constraints: BoxConstraints(minWidth: 200, maxWidth: 300),
          padding: EdgeInsets.symmetric(vertical: 2),
          child: TextField(
            showCursor: true,
            controller: _textEditingController,
            maxLines: 1,
            minLines: 1,
            style: TextStyle(fontWeight: FontWeight.w300, fontSize: 14),
            decoration: InputDecoration(
                isDense: true,
                prefixIcon: Icon(Icons.search),
                contentPadding: EdgeInsets.zero,
                hintText: 'search keyword',
                border: OutlineInputBorder(
                  borderSide: BorderSide(width: .1),
                ),
                suffixIcon: IconButton(
                  constraints: BoxConstraints.tightFor(width: 30, height: 30),
                  splashRadius: 15,
                  padding: EdgeInsets.zero,
                  iconSize: 16,
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      _keyword = null;
                      _textEditingController.text = '';
                    });
                  },
                )),
            onChanged: (key) => _debounce.run(() => _onSearchKeywordChange(key)),
          ),
        ),
        SizedBox(width: 10),
        Text('Column Filter: ', style: TextStyle(fontSize: 14)),
        Expanded(
          flex: 3,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              // scrollDirection: Axis.horizontal,
              children: (_columnKeys).map((cl) {
                bool selected = cl.selected;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    padding: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                    selectedColor: Theme.of(context).colorScheme.primary.withOpacity(.15),
                    elevation: 0,
                    visualDensity: VisualDensity(horizontal: VisualDensity.minimumDensity, vertical: VisualDensity.minimumDensity),
                    onSelected: (c) {
                      setState(() {
                        cl.selected = c;
                      });
                    },
                    selected: selected,
                    label: Text(cl.key),
                  ),
                );
              }).toList(),
            ),
          ),
        )
      ],
    );
  }

  _onSearchKeywordChange(String keyword) {
    _keyword = keyword;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DataViewerLogic>(
      init: logic,
      autoRemove: false,
      builder: (logic) {
        // if (logic.track?.isVcfCoverage ?? false) {
        //   return VcfDataTableSide(track: logic.track!);
        // }
        if (!logic.isEmpty) _initColumnKeys(logic.data.first);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _header(),
            Expanded(
              child: LayoutBuilder(
                builder: (c, cs) => _tableBuilder(c, cs, logic),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _tableBuilder(BuildContext context, BoxConstraints constraints, DataViewerLogic logic) {
    List data = logic.data;
    if (data.isEmpty) {
      return Center(child: LoadingWidget(loadingState: LoadingState.noData, message: 'Empty data'));
    }
    // var columns = selectedColumns
    //     .map((e) => DataColumn2(
    //           label: Text('${e.key}'),
    //           size: ColumnSize.L,
    //         ))
    //     .toList();

    // if (selectedColumns.isEmpty) {
    //   return Container();
    // }

    if (_keyword != null && _keyword!.isNotEmpty) {
      data = data.where((e) => e.toString().toLowerCase().contains(_keyword!)).toList();
    }

    // List<RowDataItem> _data = data.map((e) => RowDataItem(e, id: '${e.hashCode}')).toList();

    return QuickDataGrid(
      data: data,
      paginated: true,
      headers: selectedColumns.map((e) => e.key).toList(),
      onSort: (col, s) {},
      showCheckbox: false,
      itemMapper: _cellItemValueMapper,
      minWidth: constraints.biggest.width,
    );

    // return SimplePaginatedDataTable(data: _data, columnKeys: selectedColumns);
  }

  dynamic _cellItemValueMapper(BuildContext context, var item, DataGridColumn column) {
    if (item is Map) return item[column.dataKey];
    if (item is Feature) return item[column.dataKey];
    if (item is List) return item[column.index];
    return null;
  }

  void _onCellTap(rowItem, cellItem, ColumnKey columnKey) {
    Map? _data = null;
    if (cellItem is List) {
      _data = {
        'list': cellItem,
      };
    } else if (cellItem is Map) {
      _data = cellItem;
    }
    if (_data == null) return;
    var dialog = AlertDialog(
      title: rowItem is Feature ? Text('${rowItem.name}') : Text('${columnKey.key}'),
      content: Container(
        constraints: BoxConstraints.tightFor(width: MediaQuery.of(context).size.width * .6),
        child: TreeInfoWidget(data: _data, expandedAll: true, skipKeys: ['sub_feature', 'sub_features']),
      ),
    );
    showDialog(context: context, builder: (c) => dialog);
  }
}
