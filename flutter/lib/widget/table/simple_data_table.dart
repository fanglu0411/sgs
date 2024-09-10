import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/bean/feature_beans.dart';
import 'package:flutter_smart_genome/widget/table/simple_data_table_source.dart';

class SimpleDataTable extends StatefulWidget {
  final List<Map> data;
  final List<ColumnKey>? columnKeys;
  final CellItemBuilder? cellBuilder;
  const SimpleDataTable({
    Key? key,
    required this.data,
    this.columnKeys,
    this.cellBuilder,
  }) : super(key: key);

  @override
  State<SimpleDataTable> createState() => _SimpleDataTableState();
}

class _SimpleDataTableState extends State<SimpleDataTable> {
  late List<DataColumn> _columns;
  late List<ColumnKey> _columnKeys;

  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() {
    Map _item = widget.data.first;
    _columnKeys = widget.columnKeys ?? _initColumnKeys(_item);
    _columns = _columnKeys.map((e) {
      return DataColumn2(
        label: Text('${e.key}', style: TextStyle(fontSize: 12)),
        size: e == 'GT' ? ColumnSize.S : ColumnSize.M,
      );
    }).toList();
  }

  @override
  void didUpdateWidget(SimpleDataTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    _init();
  }

  _initColumnKeys(item) {
    List<ColumnKey> _keyList;
    if (item is Feature) {
      _keyList = item.json.keys.where((value) => value != 'children').map((e) => ColumnKey(e)).toList();
    } else if (item is Map) {
      _keyList = item.keys.where((value) => value != 'children').map((e) => ColumnKey(e)).toList();
    } else if (item is List) {
      _keyList = List.generate(item.length, (i) => ColumnKey('${i + 1}'));
    } else {
      _keyList = [ColumnKey('value')];
    }
    return _keyList;
  }

  DataCell _cellBuilder(
    Map rowData,
    cellData,
    ColumnKey column,
  ) {
    if (widget.cellBuilder != null) return widget.cellBuilder!.call(rowData, cellData, column);
    return DataCell(Text('${cellData}', style: TextStyle(fontSize: 12)));
  }

  @override
  Widget build(BuildContext context) {
    List<DataRow> rows = widget.data.map<DataRow>((e) {
      Map item = e;
      var cells = _columnKeys.map<DataCell>((colKey) => _cellBuilder(item, item[colKey.key], colKey)).toList();
      return DataRow(cells: cells);
    }).toList();
    return DataTable2(
      dataRowHeight: 30,
      headingRowHeight: 30,
      showCheckboxColumn: false,
      columns: _columns,
      rows: rows,
      columnSpacing: 4,
      border: TableBorder.all(width: 1.0, color: Theme.of(context).dividerColor),
      smRatio: .5,
      horizontalMargin: 8,
    );
  }
}