import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/bean/feature_beans.dart';
import 'package:flutter_smart_genome/mixin/selectable_mixin.dart';
import 'package:flutter_smart_genome/widget/table/base_data_table_source.dart';
import 'dart:math' show min;

import 'package:uuid/uuid.dart';

class RowDataItem<T> with SelectableMixin {
  T? item;
  String? id;

  RowDataItem(this.item, {this.id}) {
    id ??= Uuid().v1();
  }

  bool get isEmpty => item == null;

  RowDataItem.empty() {
    id = Uuid().v1();
  }
}

class ColumnKey with SelectableMixin {
  String key;

  ColumnKey(this.key) {
    selected = true;
  }

  @override
  bool operator ==(Object other) => identical(this, other) || other is ColumnKey && runtimeType == other.runtimeType && key == other.key;

  @override
  int get hashCode => key.hashCode;
}

typedef CellItemBuilder<T> = DataCell Function(dynamic rowData, dynamic cellItem, ColumnKey columnKey);

class SimpleDataTableSource extends BaseDataTableSource<RowDataItem> {
  List<ColumnKey> columnKeys;
  Function? onCellTap;
  CellItemBuilder? cellItemBuilder;

  SimpleDataTableSource(
    List<RowDataItem> data,
    this.columnKeys, {
    this.onCellTap,
    this.cellItemBuilder,
    OnRowSelectChanged<RowDataItem>? onRowSelectChanged,
  }) : super(data: data, onRowSelectChanged: onRowSelectChanged);

  List<ColumnKey> get selectedColumns => columnKeys.where((e) => e.selected).toList();

  @override
  List<DataCell> getRowCells(int index, RowDataItem rowItem) {
    var _data = rowItem.item;
    var selectedColumns = this.selectedColumns;
    if (_data is Map || _data is Feature) {
      return selectedColumns.map((k) => (cellItemBuilder ?? _cellItem).call(_data, _data[k.key], k)).toList();
    }
    if (_data is List) {
      var rowMap = Map.fromIterables(columnKeys, _data);
      return selectedColumns.map((k) => (cellItemBuilder ?? _cellItem).call(_data, rowMap[k], k)).toList();
    }
    return List.generate(selectedColumns.length, (index) {
      if (index == 0) return DataCell(Text('${_data}'));
      return DataCell(Text('-'));
    });
  }

  DataCell _cellItem(data, item, ColumnKey columnKey) {
    var v = _formatValue.call(item);
    return DataCell(
        Text('$v',
            style: TextStyle(
              overflow: TextOverflow.ellipsis,
            )),
        onTap: () => onCellTap?.call(data, item, columnKey));
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
