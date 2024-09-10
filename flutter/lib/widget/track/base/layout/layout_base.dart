import 'package:flutter/material.dart';

class BlockPosition {
  int? row;
  int rowCount;
  Rect rect;
  bool group;
  String featureId;

  BlockPosition({this.row, required this.rowCount, required this.rect, this.group = false, required this.featureId});

  BlockPosition copy({int? row, int? rowCount, Rect? rect, bool? group, String? featureId}) {
    return BlockPosition(
      row: row ?? this.row,
      rowCount: rowCount ?? this.rowCount,
      rect: rect ?? this.rect,
      group: group ?? this.group,
      featureId: featureId ?? this.featureId,
    );
  }

  @override
  String toString() {
    return 'BlockPosition{row: $row, featureId: $featureId}';
  }
}

class FeaturePosition {
  int row;
  Rect rect;
  String featureId;

  FeaturePosition({required this.row, required this.rect, required this.featureId});

  FeaturePosition copy({int? row, Rect? rect, String? featureId}) {
    return FeaturePosition(
      row: row ?? this.row,
      rect: rect ?? this.rect,
      featureId: featureId ?? this.featureId,
    );
  }

  @override
  String toString() {
    return 'FeaturePosition{row: $row, featureId: $featureId}';
  }
}