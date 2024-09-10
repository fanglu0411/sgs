import 'dart:ui';

import 'package:flutter/material.dart';

enum TrackBioCategory {
  GENOME,
  Transcript,
  ATAC,
}

TrackBioCategory trackCategoryFromType(String type) {
  if (type == "sc_atac") {
    return TrackBioCategory.ATAC;
  }
  if (type == "sc_transcript") {
    return TrackBioCategory.Transcript;
  }

  return TrackBioCategory.GENOME;
}

extension TrackCategoryExtension on TrackBioCategory {
  String get name => this.toString().split(".").last;

  Color get color {
    if (this == TrackBioCategory.GENOME) {
      return Colors.green;
    }
    if (this == TrackBioCategory.ATAC) {
      return Colors.pink;
    }
    if (this == TrackBioCategory.Transcript) {
      return Colors.deepOrange;
    }
    return Colors.grey;
  }

  double get fontSize {
    if (this == TrackBioCategory.GENOME) {
      return 10;
    }
    if (this == TrackBioCategory.ATAC) {
      return 12;
    }
    if (this == TrackBioCategory.Transcript) {
      return 10;
    }
    return 10;
  }
}