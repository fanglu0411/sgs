import 'package:flutter/material.dart';

class DataCategory {
  String name;
  dynamic value;
  Color color;
  bool focused = false;
  bool checked = true;
  int? count;

  Color get drawColor => focused ? Colors.black87 : (checked ? color : Colors.grey[300]!);

  Color get showColor => (checked ? color : Colors.grey[300]!);

  DataCategory({required this.name, this.value, required this.color, this.checked = true, this.focused = false, this.count});

  @override
  String toString() {
    return 'DataCategory{name: $name, value: $value, color: $color, focused: $focused， count: $count}';
  }

  @override
  bool operator ==(Object other) => identical(this, other) || other is DataCategory && runtimeType == other.runtimeType && name == other.name && value == other.value;

  @override
  int get hashCode => name.hashCode ^ value.hashCode ^ color.hashCode;
}
