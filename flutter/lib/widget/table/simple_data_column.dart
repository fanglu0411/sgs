import 'package:flutter/material.dart';

@immutable
class SimpleDataColumn extends DataColumn {
  /// Creates the configuration for a column of a [DataTable2].
  ///
  /// The [label] argument must not be null.
  const SimpleDataColumn({
    required Widget label,
    String? tooltip,
    bool numeric = false,
    Function(int, bool)? onSort,
    required this.columnKey,
  }) : super(label: label, tooltip: tooltip, numeric: numeric, onSort: onSort);

  final String columnKey;
}