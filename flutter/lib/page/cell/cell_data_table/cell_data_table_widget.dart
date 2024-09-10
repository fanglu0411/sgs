import 'dart:math';

import 'package:dartx/dartx.dart' as dx;
import 'package:flutter_smart_genome/widget/basic/custom_spin.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter_smart_genome/network/http_response.dart';
import 'package:flutter_smart_genome/service/sgs_config_service.dart';
import 'package:flutter_smart_genome/widget/table/base_data_table_source.dart';
import 'package:flutter_smart_genome/widget/table/simple_data_table_source.dart';

typedef PageDataLoader = Future<HttpResponseBean?> Function(int startIndex, int pageSize);
typedef HeaderBuilder = DataColumn Function(ColumnKey value);
typedef CellValueFormatter<T> = T Function(dynamic rowData, dynamic cellItem);
typedef CellItemBuilder<T> = DataCell Function(dynamic rowData, dynamic cellItem, ColumnKey columnKey);

class CellDataTableWidget extends StatefulWidget {
  final List? headers;
  final List<RowDataItem> data;

  final HeaderBuilder? headerBuilder;

  // final CellValueFormatter cellValueFormatter;
  final CellItemBuilder? cellItemBuilder;
  final OnRowSelectChanged<RowDataItem>? onRowSelectChanged;
  final bool showCheckBox;
  final double rowHeight;
  final double headerHeight;
  final String? message;
  final PageDataLoader? pageDataLoader;
  final int? total;
  final bool asyncPaginated;

  const CellDataTableWidget({
    Key? key,
    this.headers,
    this.data = const [],
    this.headerBuilder,
    this.cellItemBuilder,
    this.onRowSelectChanged,
    this.showCheckBox = true,
    this.rowHeight = 30,
    this.headerHeight = 30,
    this.pageDataLoader,
    this.message = "Data is Empty",
    this.total,
    this.asyncPaginated = false,
  }) : super(key: key);

  @override
  _CellDataTableWidgetState createState() => _CellDataTableWidgetState();
}

class _CellDataTableWidgetState extends State<CellDataTableWidget> {
  List<ColumnKey> _columnKeys = [];

  List<ColumnKey> get selectedColumns => _columnKeys.where((e) => e.selected).toList();

  ScrollController? _tableHorScrollController;

  _AsyncDataTableSource? _dataSource;

  @override
  void initState() {
    super.initState();
    _tableHorScrollController = ScrollController();
    _initColumnKeys(widget.headers);
    _initDataSource();
    // _autoScroll();
  }

  void _autoScroll() async {
    if (SgsConfigService.get()!.cellTableScrolled) return;
    await Future.delayed(Duration(milliseconds: 800));
    if (selectedColumns.length <= 5) return;
    _tableHorScrollController!.animateTo(300, duration: Duration(milliseconds: 500), curve: Curves.decelerate);
    await Future.delayed(Duration(milliseconds: 500));
    _tableHorScrollController!.animateTo(0, duration: Duration(milliseconds: 500), curve: Curves.decelerate);
    SgsConfigService.get()!.cellTableScrolled = true;
  }

  _initColumnKeys(List? headers) {
    List _headers = headers ?? [];
    if (_headers.length == 0 && widget.data.length > 0) {
      var first = widget.data.first.item;
      if (first is Map) {
        _headers = first.keys.toList();
      } else if (first is List) {
        _headers = List.generate(first.length, (index) => 'column ${index + 1}');
      }
    }
    _columnKeys = _headers.map((e) => ColumnKey(e)).toList();
  }

  _initDataSource() {
    if (widget.asyncPaginated)
      _dataSource = _AsyncDataTableSource(
        columnKeys: selectedColumns,
        cellItemBuilder: widget.cellItemBuilder,
        onRowSelectChange: widget.onRowSelectChanged,
        pageDataLoader: widget.pageDataLoader,
        totalCount: widget.total,
      );
  }

  @override
  void didUpdateWidget(covariant CellDataTableWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(widget.headers, oldWidget.headers)) {
      _initColumnKeys(widget.headers);
      _initDataSource();
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: widget.asyncPaginated ? _paginatedBuilder : _builder);
  }

  Widget _builder(BuildContext context, BoxConstraints constraints) {
    var columns = selectedColumns.map(_headerColumn).toList();
    List<RowDataItem> _data = widget.data;

    if (columns.isEmpty) {
      return Center(
        child: Text('${widget.message}'),
      );
    }
    int rows = ((constraints.biggest.height - 64 - widget.headerHeight) / widget.rowHeight).floor();
    var les = selectedColumns.map((e) => e.key.length);
    var maxLength = les.max();
    var avgLength = les.sum() / columns.length;
    double minWidth = (avgLength * 13) * columns.length;
    if (minWidth < constraints.maxWidth) minWidth = constraints.maxWidth;
    Color borderColor = Theme.of(context).dividerTheme.color!;

    // return SimplePaginatedDataTable2(data: _data.map((e) => e.item).toList(), columnKeys: selectedColumns);

    return PaginatedDataTable2(
      // controller: _tableHorScrollController!,
      columns: columns,
      wrapInCard: false,
      dataRowHeight: widget.rowHeight,
      headingRowHeight: widget.headerHeight,
      minWidth: minWidth,
      columnSpacing: 12,
      horizontalMargin: 10,
      checkboxHorizontalMargin: 10,
      showFirstLastButtons: true,
      showCheckboxColumn: widget.showCheckBox,
      rowsPerPage: rows.clamp(1, 100),
      onPageChanged: (i) {},
      border: TableBorder.all(color: borderColor),
      source: _DataTableSource(
        _data,
        selectedColumns,
        cellItemBuilder: widget.cellItemBuilder!,
        onRowSelectChanged: widget.onRowSelectChanged,
      ),
      empty: _emptyWidget(),
    );
  }

  Widget _paginatedBuilder(BuildContext context, BoxConstraints constraints) {
    List<DataColumn> columns = selectedColumns.map(_headerColumn).toList();
    if (columns.isEmpty) {
      return Center(
        child: Text('${widget.message}'),
      );
    }

    var les = selectedColumns.map((e) => e.key.length);
    var maxLength = les.max();
    var avgLength = les.sum() / columns.length;
    double minWidth = (avgLength * 14 + 20.0) * columns.length;
    int rows = 20; // ((constraints.biggest.height - 64 - widget.headerHeight) / widget.rowHeight).floor();
    Color borderColor = Theme.of(context).dividerTheme.color!;
    return AsyncPaginatedDataTable2(
      // horizontalController: _tableHorScrollController,
      columns: columns,
      dataRowHeight: widget.rowHeight,
      headingRowHeight: widget.headerHeight,
      columnSpacing: 20,
      wrapInCard: false,
      horizontalMargin: 10,
      checkboxHorizontalMargin: 5,
      showFirstLastButtons: true,
      showCheckboxColumn: widget.showCheckBox,
      minWidth: minWidth,
      autoRowsToHeight: false,
      // fixedLeftColumns: 2,
      rowsPerPage: rows.clamp(1, 100),
      lmRatio: 1.5,
      source: _dataSource!,
      border: TableBorder(
        bottom: BorderSide(color: borderColor),
        left: BorderSide(color: borderColor),
        verticalInside: BorderSide(color: borderColor),
        // horizontalInside: BorderSide(color: borderColor),
      ),
      empty: _emptyWidget(),
      loading: _loadingWidget(),
      errorBuilder: _errorBuilder,
    );
  }

  Widget _emptyWidget() {
    return Center(
      child: Text('${widget.message}'),
    );
  }

  Widget _loadingWidget() {
    return Center(
      child: CustomSpin(color: Theme.of(context).colorScheme.primary),
    );
  }

  Widget _errorBuilder(e) {
    return Center(
      child: Container(
        child: Text('${e}'),
      ),
    );
  }

  DataColumn _headerColumn(ColumnKey columnKey) {
    var label = '${columnKey.key}';
    return widget.headerBuilder?.call(columnKey) ??
        DataColumn2(
          label: Text(label, style: Theme.of(context).textTheme.labelMedium),
          size: ColumnSize.L,
          // fixedWidth: 400, // label.length * 14.0 + 20,
        );
  }

  @override
  void dispose() {
    super.dispose();
    _tableHorScrollController?.dispose();
  }
}

@immutable
class DataColumn3 extends DataColumn2 {
  final double width;

  DataColumn3({required this.width, required Widget label, String? tooltip, bool numeric = false, Function(int, bool)? onSort})
      : super(label: label, tooltip: tooltip, numeric: numeric, onSort: onSort);
}

class _DataTableSource extends BaseDataTableSource<RowDataItem> {
  List<ColumnKey> columnKeys;
  Function? onCellTap;
  CellItemBuilder cellItemBuilder;

  _DataTableSource(
    List<RowDataItem> data,
    this.columnKeys, {
    this.onCellTap,
    required this.cellItemBuilder,
    OnRowSelectChanged<RowDataItem>? onRowSelectChanged,
  }) : super(data: data, onRowSelectChanged: onRowSelectChanged);

  @override
  List<DataCell> getRowCells(int index, RowDataItem rowItem) {
    var _data = rowItem.item;
    if (_data is Map) {
      return columnKeys.map((k) => (cellItemBuilder).call(_data, _data[k.key], k)).toList();
    }
    if (_data is List) {
      var rowMap = Map.fromIterables(columnKeys, _data);
      return columnKeys.map((k) => (cellItemBuilder).call(_data, rowMap[k], k)).toList();
    }
    return [
      DataCell(Text('${_data}')),
    ];
  }

  DataCell _cellItem(data, item, ColumnKey columnKey) {
    var v = _formatValue.call(item);
    return DataCell(Text('$v'), onTap: () => onCellTap?.call(data, item));
  }

  dynamic _formatValue(dynamic item) {
    if (item is Map) {
      return '{${item.entries.first.key}: ${item.entries.first.value}, ...more}';
    }
    if (item is List) {
      return '${item.sublist(0, min(item.length, 3))}';
    }
    return item;
  }
}

class _AsyncDataTableSource extends AsyncDataTableSource {
  _AsyncDataTableSource({
    required this.pageDataLoader,
    this.cellItemBuilder,
    this.onCellTap,
    this.columnKeys,
    int? totalCount,
    this.onRowSelectChange,
  }) {
    _totalCount = totalCount ?? 0;
  }

  OnRowSelectChanged<RowDataItem>? onRowSelectChange;
  List<ColumnKey>? columnKeys;

  Function? onCellTap;
  CellItemBuilder? cellItemBuilder;
  PageDataLoader? pageDataLoader;
  int _totalCount = 0;

  RangeValues? _caloriesFilter;

  RangeValues? get caloriesFilter => _caloriesFilter;

  set caloriesFilter(RangeValues? calories) {
    _caloriesFilter = calories;
    refreshDatasource();
  }

  String _sortColumn = "name";
  bool _sortAscending = true;

  void sort(String columnName, bool ascending) {
    _sortColumn = columnName;
    _sortAscending = ascending;
    refreshDatasource();
  }

  Future<int> getTotalRecords() {
    return Future<int>.value(_totalCount);
  }

  _initColumnKeys(var firstItem) {
    List? _headers;
    var first = firstItem;
    if (first is Map) {
      _headers = first.keys.toList();
    } else if (first is List) {
      _headers = List.generate(first.length, (index) => 'column ${index + 1}');
    }
    columnKeys = _headers!.map((e) => ColumnKey(e)).toList();
  }

  @override
  Future<AsyncRowsResponse> getRows(int startIndex, int count) async {
    print('getRows($startIndex, $count)');
    var index = startIndex;
    assert(index >= 0);

    var resp = await pageDataLoader?.call(startIndex, count);
    if (!resp!.success) {
      // await Future.delayed(Duration(milliseconds: 1000));
      throw '${resp.error}';
    }

    Map body = resp.body;

    List<RowDataItem> items = body['data'] ?? <RowDataItem>[];
    _totalCount = body['total'] ?? 0;
    if (null == columnKeys && items.length > 0) {
      _initColumnKeys(items.first.item);
    }

    if (items.length < count) {
      items.addAll(List.generate(count - items.length, (index) => RowDataItem.empty()));
    }

    var r = AsyncRowsResponse(
        _totalCount,
        items.mapIndexed<DataRow>((i, item) {
          return DataRow(
            key: ValueKey<String>(item.id!),
            selected: item.selected,
            onSelectChanged: item.isEmpty
                ? null
                : (value) {
                    if (value != null) setRowSelection(ValueKey<String>(item.id!), value);
                    onRowSelectChange?.call(i, item..selected = value ?? false);
                  },
            cells: getRowCells(i, item),
          );
        }).toList());
    return r;
  }

  List<DataCell> getRowCells(int index, RowDataItem rowItem) {
    if (rowItem.isEmpty) {
      return columnKeys!.map((k) => DataCell.empty).toList();
    }
    var _data = rowItem.item;
    if (_data is Map) {
      return columnKeys!.map((k) => (cellItemBuilder ?? _cellItem).call(_data, _data[k.key], k)).toList();
    }
    if (_data is List) {
      var rowMap = Map.fromIterables(columnKeys!, _data);
      return columnKeys!.map((k) => (cellItemBuilder ?? _cellItem).call(_data, rowMap[k], k)).toList();
    }
    return [
      DataCell(Text('${_data}')),
    ];
  }

  DataCell _cellItem(data, item, ColumnKey columnKey) {
    var v = _formatValue.call(item);
    return DataCell(Text('$v'), onTap: () => onCellTap?.call(data, item));
  }

  dynamic _formatValue(dynamic item) {
    if (item is Map) {
      return '{${item.entries.first.key}: ${item.entries.first.value}, ...more}';
    }
    if (item is List) {
      return '${item.sublist(0, min(item.length, 3))}';
    }
    return item;
  }
}
