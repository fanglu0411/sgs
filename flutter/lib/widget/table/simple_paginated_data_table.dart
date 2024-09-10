import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/bean/feature_beans.dart';
import 'package:flutter_smart_genome/widget/table/simple_data_table_source.dart';

class SimplePaginatedDataTable extends StatefulWidget {
  final List<RowDataItem> data;
  final List<ColumnKey>? columnKeys;
  final CellItemBuilder? cellBuilder;

  const SimplePaginatedDataTable({
    Key? key,
    required this.data,
    this.columnKeys,
    this.cellBuilder,
  }) : super(key: key);

  @override
  State<SimplePaginatedDataTable> createState() => _SimpleDataTableState();
}

class _SimpleDataTableState extends State<SimplePaginatedDataTable> {
  late List<DataColumn> _columns;
  late List<ColumnKey> _columnKeys;

  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() {
    _columnKeys = widget.columnKeys ?? _initColumnKeys(widget.data.first);
    _columns = _columnKeys.map((e) {
      return DataColumn2(
        label: Text('${e.key}', style: TextStyle(fontSize: 12)),
        size: ColumnSize.M,
      );
    }).toList();
  }

  @override
  void didUpdateWidget(SimplePaginatedDataTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    _init();
  }

  List<ColumnKey> _initColumnKeys(RowDataItem _item) {
    var item = _item.item;
    List<ColumnKey> _keyList;
    if (item == null) {
      _keyList = [ColumnKey('value')];
    } else if (item is Feature) {
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

  @override
  Widget build(BuildContext context) {
    Color borderColor = Theme.of(context).dividerTheme.color!;
    return PaginatedDataTable2(
      columns: _columns,
      source: SimpleDataTableSource(
        widget.data,
        _columnKeys,
        cellItemBuilder: widget.cellBuilder,
      ),
      wrapInCard: false,
      horizontalMargin: 10,
      dataRowHeight: 30,
      headingRowHeight: 30,
      columnSpacing: 20,
      showCheckboxColumn: false,
      autoRowsToHeight: false,
      border: TableBorder(
        top: BorderSide(color: borderColor),
        bottom: BorderSide(color: borderColor),
        // left: BorderSide(color: borderColor),
        verticalInside: BorderSide(color: borderColor),
      ),
      smRatio: .5,
      // minWidth: _columnKeys.length <= 4 ? null : _columnKeys.length * 50.0,
      showFirstLastButtons: true,
    );
  }
}
