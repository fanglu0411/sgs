import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/page/maincontainer/track_container.dart';

enum PanelPosition {
  left,
  top,
  center,
  right,
  bottom;

  bool get isHor => this == left || this == right;

  bool get isVer => this == top || this == bottom;

  String get nameForTabBar => 'edge-Tab-bar-${name}';
}

class HotKey {
  bool ctrl = false;
  bool alt = false;
  bool shift = false;
  String key = '';

  HotKey(this.alt, this.ctrl, this.shift, this.key);

  HotKey.alt(this.key) {
    alt = true;
  }

  HotKey.ctrl(this.key) {
    ctrl = true;
  }

  HotKey.key(this.key) {}

  HotKey.all(this.key) {
    alt = true;
    ctrl = true;
    shift = true;
  }

  HotKey.ctrlShift(this.key) {
    ctrl = true;
    shift = true;
  }

  HotKey.altShift(this.key) {
    alt = true;
    shift = true;
  }

  bool equalWith(HotKey hotKey, {bool ignoreAlt = false, bool ignoreCtrl = false, bool ignoreShift = false}) {
    bool keyEqual = hotKey.key == key;
    bool altEqual = ignoreAlt ? true : hotKey.alt == alt;
    bool ctrlEqual = ignoreCtrl ? true : hotKey.ctrl == ctrl;
    bool shiftEqual = ignoreShift ? true : hotKey.shift == shift;
    return keyEqual && altEqual && ctrlEqual && shiftEqual;
  }

  bool equalWithKey(HotKey hotKey) {
    return equalWith(hotKey, ignoreAlt: true, ignoreCtrl: true, ignoreShift: true);
  }

  String print() {
    return [ctrl ? 'Ctrl' : '', alt ? 'Alt' : '', shift ? 'Shift' : '', key].where((e) => e.length > 0).join(' + ');
  }

  @override
  String toString() {
    return 'HotKey{ctrl: $ctrl, alt: $alt, key: $key}';
  }

  @override
  bool operator ==(Object other) => identical(this, other) || other is HotKey && runtimeType == other.runtimeType && ctrl == other.ctrl && alt == other.alt && shift == other.shift && key == other.key;

  @override
  int get hashCode => ctrl.hashCode ^ alt.hashCode ^ shift.hashCode ^ key.hashCode;
}

class TabItem {
  bool selected;
  PanelPosition panelPosition;
  PanelPosition tabPosition;
  String title;
  SideModel type;
  Widget icon;
  HotKey? hotKey;
  double fraction;
  double? minWidth;
  double? verMinWidth;
  Function2<TabItem, BuildContext, Widget>? extraBuilder;
  Function2<TabItem, BuildContext, Widget>? titleBuilder;
  Function2<TabItem, BuildContext, Widget>? builder;

  TabItem({
    required this.type,
    required this.panelPosition,
    required this.tabPosition,
    required this.title,
    required this.icon,
    this.selected = false,
    this.hotKey,
    this.fraction = .2,
    this.minWidth = 360,
    this.verMinWidth = 200,
    this.extraBuilder,
    this.titleBuilder,
    this.builder,
  });

  double get viewFraction => selected ? fraction : 0;

  @override
  bool operator ==(Object other) => identical(this, other) || other is TabItem && runtimeType == other.runtimeType && panelPosition == other.panelPosition && title == other.title;

  @override
  int get hashCode => panelPosition.hashCode ^ type.hashCode;

  @override
  String toString() {
    return 'TabItem{selected: $selected, position: $panelPosition, title: $title, type: $type}';
  }
}
