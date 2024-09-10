import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/page/maincontainer/track_container.dart';

final GlobalKey serverShowCase = GlobalKey();
GlobalKey searchShowCase = GlobalKey();
GlobalKey trackShowCase = GlobalKey();
GlobalKey speciesShowCase = GlobalKey();
GlobalKey singleCellShowCase = GlobalKey();
GlobalKey trackThemeShowCase = GlobalKey();
GlobalKey adminShowCase = GlobalKey();

final Map showCaseMap = {
  SideModel.server: ShowCaseItem(key: serverShowCase, info: 'Tap here to change server/species'),
  SideModel.search: ShowCaseItem(key: searchShowCase, info: 'Tap here to search'),
  SideModel.track_list: ShowCaseItem(key: trackShowCase, info: 'Tap here to toggle track list'),
  SideModel.track_theme: ShowCaseItem(key: trackThemeShowCase, info: 'Tap here to change track theme'),
  SideModel.cell: ShowCaseItem(key: singleCellShowCase, info: 'Tap here to toggle single cell'),
};

class ShowCaseItem {
  final GlobalKey key;
  final String info;

  const ShowCaseItem({required this.key, required this.info});
}
