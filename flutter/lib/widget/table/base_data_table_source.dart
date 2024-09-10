import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/mixin/selectable_mixin.dart';

typedef OnRowSelectChanged<T> = void Function(int row, T);

abstract class BaseDataTableSource<T extends SelectableMixin> extends DataTableSource {
  final List<T> data;

  int _selectedCount = 0;
  OnRowSelectChanged<T>? onRowSelectChanged;

  BaseDataTableSource({
    this.data = const [],
    this.onRowSelectChanged,
  }) {}

  @override
  DataRow getRow(int index) {
    T item = data[index];
    return DataRow.byIndex(
      index: index,
      selected: item.selected,
      onSelectChanged: (bool? checked) {
        if (item.selected != checked) {
          _selectedCount += checked! ? 1 : -1;
          // logger.d(_selectedCount);
          assert(_selectedCount >= 0);
          item.selected = checked;
          notifyListeners();
          onRowSelectChanged?.call(index, item);
        }
      },
      cells: getRowCells(index, item),
    );
  }

  List<DataCell> getRowCells(int index, T item);

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => data.length;

  @override
  int get selectedRowCount => _selectedCount;

  void selectAll(bool checked) {
    for (T dessert in data) dessert.selected = checked;
    _selectedCount = checked ? data.length : 0;
    notifyListeners();
  }
}
