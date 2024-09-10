import 'package:flutter/services.dart';
import 'package:flutter_smart_genome/widget/quick_data_grid/sort_button.dart';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';

typedef DataGridColumnSortCallback = void Function(DataGridColumn column, SortState state);

class DataGridColumn {
  String? dataKey;
  late String label;
  late int index;
  TableSpanExtent widthExtent;
  DataGridColumnSortCallback? onSort;
  bool numeric;
  MouseCursor? cursor = MouseCursor.defer;

  bool isCheckbox;

  DataGridColumn({
    required this.index,
    this.widthExtent = const FixedTableSpanExtent(120),
    this.dataKey,
    required this.label,
    this.onSort,
    this.isCheckbox = false,
    this.numeric = false,
    this.cursor = MouseCursor.defer,
  });

  @override
  String toString() {
    return 'DataColumn{dataKey: $dataKey, label: $label, index: $index, widthExtent: $widthExtent}';
  }
}
