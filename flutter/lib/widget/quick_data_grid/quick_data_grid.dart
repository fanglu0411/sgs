import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' hide DataTable, DataColumn;
import 'package:flutter_smart_genome/widget/basic/custom_spin.dart';
import 'package:flutter_smart_genome/widget/loading_widget.dart';
import 'package:dartx/dartx.dart' as dx;
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';

import 'pagination_widget.dart';
import 'sort_button.dart';
import 'data_column.dart';
import 'data_grid_selection.dart';
import 'row_checkbox.dart';

typedef ColumnBuilder = Widget Function(BuildContext context, DataGridColumn column);
typedef CellBuilder<D> = Widget Function(BuildContext context, D row, TableVicinity vicinity, DataGridColumn column);
typedef DataItemMapper<D> = dynamic Function(BuildContext context, D item, DataGridColumn column);
typedef PaginationDataLoader<D> = Future<(List<D>? data, String? error, int totalCount)> Function(int page, int pageSize);
typedef OnRowSelectChanged<D> = void Function(int row, D rowData, bool checked);
typedef WidgetBuilder = Widget Function(BuildContext context);
typedef OnCellTap<D> = void Function(D rowData, int row, DataGridColumn column);
typedef CursorBuilder = MouseCursor Function(DataGridColumn column);

class QuickDataGrid<D> extends StatefulWidget {
  final List<D> data;
  final double rowHeight;

  final List<DataGridColumn>? columns;

  final ColumnBuilder? columnBuilder;
  final CellBuilder<D>? cellBuilder;
  final DataItemMapper<D>? itemMapper;
  final TextStyle? headerStyle;
  final TextStyle? cellStyle;
  final TableSpanPadding cellPadding;
  final DataGridColumnSortCallback? onSort;
  final PaginationDataLoader<D>? paginationDataLoader;
  final OnCellTap<D>? onCellTap;
  final bool paginated;
  final bool showCheckbox;
  final OnRowSelectChanged<D>? onRowSelectChanged;
  final List<String>? headers;
  final WidgetBuilder? errorBuilder;
  final double? minWidth;
  final List<int> pageSizeList;
  final int pageSize;
  final WidgetBuilder? headBuilder;
  final CursorBuilder? cursorBuilder;
  final int? totalCount;
  final String emptyMessage;

  QuickDataGrid({
    super.key,
    required this.data,
    this.columns,
    this.headers,
    this.rowHeight = 32,
    this.columnBuilder,
    this.cellBuilder,
    this.itemMapper,
    this.onCellTap,
    this.headerStyle,
    this.cellStyle,
    this.cellPadding = const TableSpanPadding.all(8),
    this.onSort,
    this.paginated = true,
    this.paginationDataLoader,
    this.showCheckbox = false,
    this.onRowSelectChanged,
    this.errorBuilder,
    this.headBuilder,
    this.minWidth,
    this.pageSize = 20,
    this.pageSizeList = const [10, 20, 50, 100],
    this.cursorBuilder,
    this.totalCount,
    this.emptyMessage = 'Data is empty!',
  }) {}

  @override
  State<QuickDataGrid<D>> createState() => _QuickDataGridState<D>();
}

class _QuickDataGridState<D> extends State<QuickDataGrid<D>> {
  static final String CHECKBOX_COLUMN_KEY = '__data_grid_check';

  ScrollController? _verticalController;
  ScrollController? _horizontalController;

  int get dataCount => widget.data.length;

  List<DataGridColumn>? _columns;

  TextStyle get headerStyle => widget.headerStyle ?? TextStyle(fontSize: 14);

  TextStyle get cellStyle => widget.cellStyle ?? TextStyle(fontSize: 13);

  late PaginationState _paginationState;

  Map<int, List<D>?> _paginatedData = {};
  late DataGridSelection _dataSelection;

  bool _loading = false;
  String? _error;

  String? _sortByColumn;

  List<D>? _sortedData;

  List<D>? get currentPageData {
    if (!widget.paginated && widget.paginationDataLoader == null) return widget.data;

    if (widget.paginationDataLoader == null) {
      if (widget.data.length > 0) return widget.data.sublist(_paginationState.pageStart, _paginationState.pageEnd);
      return [];
    }
    var data = _paginatedData[_paginationState.currentPage];
    if ((data == null || data.length == 0) && _paginationState.currentPage == 1) return widget.data;
    return data;
  }

  int get currentPageCount => currentPageData?.length ?? 0;

  List<D>? get _showData => _sortedData ?? currentPageData;

  DataGridColumn? _onEnterColumn;

  @override
  void initState() {
    super.initState();
    _horizontalController = ScrollController();
    _verticalController = ScrollController();
    _paginationState = PaginationState(
      totalCount: widget.totalCount ?? widget.data.length,
      pageSize: widget.pageSize,
      pageSizeList: widget.pageSizeList,
    );
    _columns = widget.columns ?? _guessColumns(widget.data);
    _dataSelection = DataGridSelection(isPaginated: widget.paginated || widget.paginationDataLoader != null);

    if ((widget.paginationDataLoader != null || widget.paginated) && widget.data.length == 0) {
      Future.delayed(Duration(milliseconds: 200)).then((e) {
        _onPageChange(_paginationState.currentPage);
      });
    }
  }

  @override
  void didUpdateWidget(covariant QuickDataGrid<D> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.data.length != oldWidget.data.length || widget.totalCount != oldWidget.totalCount) {
      _paginationState.update(totalCount: widget.totalCount ?? widget.data.length);
      _dataSelection
        ..clear()
        ..isPaginated = widget.paginated;
    }
    if (null == _columns || _columns!.length == 0 || widget.headers != oldWidget.headers || widget.columns != oldWidget.columns) {
      _columns = _guessColumns(widget.data);
    }
  }

  void _onPageChange(int page) async {
    if (!this.mounted) return;
    if (widget.paginationDataLoader == null) {
      // 没有分页加载数据
      _dataSelection.setCurrentPage(page, currentPageCount);
      setState(() {});
      return;
    }

    _loading = true;
    setState(() {});

    var (List<D>? data, String? error, int totalCount) = await widget.paginationDataLoader!.call(_paginationState.currentPage, _paginationState.pageSize);
    if (!mounted) return;
    _loading = false;
    if (error != null && data == null) {
      _error = error;
    } else {
      _paginatedData[page] = data;
      _paginationState.update(totalCount: totalCount, currentPage: page);
      _columns ??= _guessColumns(data ?? []);
      _dataSelection.setCurrentPage(page, data!.length);
    }
    setState(() {});
  }

  List<DataGridColumn>? _guessColumns(List<D> data) {
    if (widget.headers != null) {
      return _buildByHeaders(widget.headers!, data.length > 0 ? data.first : null);
    }

    if (data.length == 0) return null;
    var first = data.first;

    List keys = switch (first) {
      Map() => first.keys.toList(),
      List() => List.generate(first.length, (index) => 'Column ${index + 1}'),
      Object() => [],
    };
    return _buildByHeaders(keys, first);
  }

  List<DataGridColumn> _buildByHeaders(List headers, D? first) {
    List _headers = [
      if (widget.showCheckbox) CHECKBOX_COLUMN_KEY,
      ...headers,
    ];
    double totalWidth = 0;
    var cols = List.generate(
      _headers.length,
      (index) {
        var col = DataGridColumn(
          index: index,
          dataKey: _headers[index],
          label: _headers[index],
          isCheckbox: _headers[index] == CHECKBOX_COLUMN_KEY,
        );
        if (col.isCheckbox) {
          totalWidth += 40;
          col.widthExtent = FixedTableSpanExtent(40);
        } else {
          var v = first == null ? null : (widget.itemMapper ?? _valueMapper).call(context, first, col);
          bool numeric = (v != null && v is num || num.tryParse('${v}') != null);
          double labelWidth = measureTextWidth(col.label, headerStyle) + 20;
          double valueWidth = v == null ? 0 : measureTextWidth('${v}', headerStyle);
          double sortWidth = numeric ? 40 : 0;
          double _width = max(labelWidth, valueWidth) + sortWidth + 10;
          col
            ..widthExtent = FixedTableSpanExtent(_width)
            ..numeric = numeric;
          totalWidth += _width;
        }
        return col;
      },
    );
    totalWidth += (widget.cellPadding.leading + widget.cellPadding.trailing) * cols.length;
    if (widget.minWidth != null && totalWidth < widget.minWidth! && cols.length > 0) {
      double _add = (widget.minWidth! - totalWidth) / (widget.showCheckbox ? (cols.length - 1) : cols.length);
      for (var c in cols) {
        var widthExtent = c.widthExtent;
        if (!c.isCheckbox && widthExtent is FixedTableSpanExtent) {
          c.widthExtent = FixedTableSpanExtent(widthExtent.pixels + _add);
        }
      }
      // cols.last.widthExtent = RemainingTableSpanExtent();
    }
    return cols;
  }

  String? _valueMapper(BuildContext context, D item, DataGridColumn column) {
    if (item is Map) {
      return '${item[column.dataKey]}';
    } else if (item is List) {
      return '${item[column.index]}';
    }
    return null;
  }

  bool get isColumnEmpty => _columns == null || _columns!.length == 0;

  @override
  Widget build(BuildContext context) {
    if (!_loading && currentPageCount == 0 && !widget.paginated)
      return Container(
        child: Center(child: Text(widget.emptyMessage, style: Theme.of(context).textTheme.headlineSmall)),
      );
    if (!_loading && isColumnEmpty)
      return Container(
        child: Center(child: widget.errorBuilder?.call(context) ?? Text('Data columns is empty!')),
      );
    return Stack(
      fit: StackFit.expand,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.headBuilder != null) widget.headBuilder!.call(context),
            if (!_loading && isColumnEmpty)
              Container(
                child: Center(child: widget.errorBuilder?.call(context) ?? Text('Data columns is empty!')),
              ),
            if (!isColumnEmpty)
              Expanded(
                child: TableView.builder(
                  cellBuilder: _buildCell,
                  columnCount: _columns!.length,
                  columnBuilder: _buildColumnSpan,
                  rowCount: (widget.paginationDataLoader != null || widget.paginated) ? currentPageCount + 1 : dataCount + 1,
                  pinnedRowCount: 1,
                  rowBuilder: _buildRowSpan,
                  verticalDetails: ScrollableDetails.vertical(
                    controller: _verticalController,
                    physics: ClampingScrollPhysics(),
                  ),
                  horizontalDetails: ScrollableDetails.horizontal(
                    controller: _horizontalController,
                    physics: ClampingScrollPhysics(),
                  ),
                ),
              ),
            if (!isColumnEmpty && (widget.paginated || widget.paginationDataLoader != null))
              PaginationWidget(
                paginationState: _paginationState,
                onPageChange: _onPageChange,
              ),
          ],
        ),
        if (_loading)
          Container(
            alignment: Alignment.center,
            color: Theme.of(context).colorScheme.tertiaryContainer.withOpacity(.2),
            child: CustomSpin(color: Theme.of(context).colorScheme.primary),
          ),
        if (_error != null)
          Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            alignment: Alignment.center,
            child: LoadingWidget(
              loadingState: LoadingState.error,
              onErrorClick: (s) {
                _onPageChange(_paginationState.currentPage);
              },
            ),
          ),
      ],
    );
  }

  TableViewCell _buildHeader(BuildContext context, TableVicinity vicinity) {
    DataGridColumn column = _columns!.firstWhere((c) => c.index == vicinity.column);

    Widget child = column.isCheckbox
        ? RowCheckbox(
            value: _dataSelection.isSelectAll,
            onChanged: (v) {
              _dataSelection.toggleAll(v);
              _paginationState.update(selectedCount: _dataSelection.totalSelectedCount);
              setState(() {});
            })
        : Container(
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                (widget.columnBuilder ?? __buildHeader).call(context, column),
                if (column.numeric) Spacer(),
                if (column.numeric) SortButton(state: column.dataKey == _sortByColumn ? null : SortState.none, onSort: (s) => _onSort(column, s)),
              ],
            ),
          );
    return TableViewCell(child: child);
  }

  void _onSort(DataGridColumn column, SortState sortType) {
    _sortByColumn = column.dataKey;

    if (sortType == SortState.desc) {
      _sortedData = currentPageData?.sortedByDescending((e) => (widget.itemMapper ?? _valueMapper).call(context, e, column));
    } else if (sortType == SortState.asc) {
      _sortedData = currentPageData?.sortedBy((e) => (widget.itemMapper ?? _valueMapper).call(context, e, column));
    } else {
      _sortedData = null;
    }
    setState(() {});
    (column.onSort ?? widget.onSort)?.call(column, sortType);
    _paginationState.update(currentPage: 1);
    if (widget.paginationDataLoader != null) {
      _onPageChange(_paginationState.currentPage);
    }
  }

  Widget __buildHeader(BuildContext context, DataGridColumn column) {
    return Text('${column.label}', style: headerStyle);
  }

  TableViewCell _buildCell(BuildContext context, TableVicinity vicinity) {
    if (vicinity.row == 0) return _buildHeader(context, vicinity);
    DataGridColumn column = _columns!.firstWhere((c) => c.index == vicinity.column);
    Widget child = column.isCheckbox
        ? Center(
            child: RowCheckbox(
                value: _dataSelection.isSelectRow(vicinity.row),
                onChanged: (v) {
                  _dataSelection.onSelectionChange(vicinity.row, v);
                  _paginationState.update(selectedCount: _dataSelection.totalSelectedCount);
                  setState(() {});
                  widget.onRowSelectChanged?.call(vicinity.row - 1, _showData![vicinity.row - 1], v);
                }),
          )
        : Container(
            child: widget.cellBuilder?.call(context, _showData![vicinity.row - 1], vicinity, column) ?? __buildCell(context, _showData![vicinity.row - 1], vicinity, column),
            alignment: Alignment.centerLeft,
          );
    return TableViewCell(child: child);
  }

  Widget? __buildCell(BuildContext context, D rowData, TableVicinity vicinity, DataGridColumn column) {
    var value = (widget.itemMapper ?? _valueMapper).call(context, rowData, column);
    return Text('${value ?? ''}', style: cellStyle);
  }

  TableSpan _buildColumnSpan(int column) {
    DataGridColumn _column = _columns!.firstWhere((c) => c.index == column);
    TableSpanDecoration decoration = TableSpanDecoration(
      border: TableSpanBorder(
        leading: column == 0 ? BorderSide(color: Theme.of(context).dividerColor) : BorderSide.none,
        trailing: BorderSide(color: Theme.of(context).dividerColor),
      ),
    );
    return TableSpan(
      foregroundDecoration: decoration,
      cursor: widget.cursorBuilder?.call(_column) ?? SystemMouseCursors.basic,
      padding: widget.cellPadding,
      extent: _column.widthExtent,
      onEnter: (e) {
        _onEnterColumn = _column;
      },
      recognizerFactories: <Type, GestureRecognizerFactory>{
        TapGestureRecognizer: GestureRecognizerFactoryWithHandlers<TapGestureRecognizer>(
          () => TapGestureRecognizer(),
          (TapGestureRecognizer t) => t.onTap = () => print('Tap column $column'),
        ),
      },
    );
  }

  TableSpan _buildRowSpan(int index) {
    bool selected = _dataSelection.isSelectRow(index);
    final TableSpanDecoration decoration = TableSpanDecoration(
      color: selected ? Theme.of(context).colorScheme.secondaryContainer.withOpacity(.21) : null,
      border: TableSpanBorder(
        leading: index == 0 ? BorderSide(width: 1, color: Theme.of(context).dividerColor) : BorderSide.none,
        trailing: BorderSide(width: 1, color: Theme.of(context).dividerColor),
      ),
    );
    return TableSpan(
      backgroundDecoration: decoration,
      extent: FixedTableSpanExtent(widget.rowHeight), // row height;
      recognizerFactories: <Type, GestureRecognizerFactory>{
        TapGestureRecognizer: GestureRecognizerFactoryWithHandlers<TapGestureRecognizer>(
          () => TapGestureRecognizer(),
          (TapGestureRecognizer t) => t.onTap = () {
            if (index == 0) return; //tap header
            widget.onCellTap?.call(_showData![index - 1], index - 1, _onEnterColumn!);
          },
        ),
        HorizontalDragGestureRecognizer: GestureRecognizerFactoryWithHandlers<HorizontalDragGestureRecognizer>(
          () => HorizontalDragGestureRecognizer(),
          (HorizontalDragGestureRecognizer t) => t.onUpdate = (d) {
            var po = (_horizontalController!.position.pixels - d.delta.dx).clamp(0.0, _horizontalController!.position.maxScrollExtent);
            _horizontalController!.jumpTo(po);
          },
        )
      },
    );
  }

  TextPainter? labelPainter;

  double measureTextWidth(String text, TextStyle style) {
    labelPainter ??= TextPainter(textAlign: TextAlign.start, textDirection: TextDirection.ltr);
    labelPainter!.text = TextSpan(text: text, style: style);
    labelPainter!.layout();
    return labelPainter!.width;
  }

  @override
  void dispose() {
    super.dispose();
    _horizontalController?.dispose();
    _verticalController?.dispose();
  }
}
