import 'package:flutter/material.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:flutter_smart_genome/bloc/sgs_context/sgs_browse_logic.dart';
import 'package:flutter_smart_genome/page/cell/cell_page/cell_page_logic.dart';
import 'package:flutter_smart_genome/page/cell/cell_page/cell_page_view.dart';
import 'package:flutter_smart_genome/page/maincontainer/track_container.dart';
import 'package:flutter_smart_genome/page/track/theme/track_theme_selector_widget.dart';
import 'package:flutter_smart_genome/side/data_viewer_side.dart';
import 'package:flutter_smart_genome/side/track_list_side.dart';
import 'package:flutter_smart_genome/widget/navigation_bar.dart';
import 'package:flutter_smart_genome/widget/track/base/track_data.dart';
import 'package:get/get.dart';

class EndDrawerLogic extends GetxController {
  static EndDrawerLogic? safe() {
    if (Get.isRegistered<EndDrawerLogic>()) {
      return Get.find<EndDrawerLogic>();
    }
    return null;
  }

  int _sideIndex = 0;

  int get sideIndex => _sideIndex;

  List<NavigationBarItem> _sideItems = [
    NavigationBarItem(
      icon: Icon(Icons.format_list_numbered),
//        title: Text('Home'),
      tooltip: 'Tracks',
      activeIcon: Icon(Icons.format_list_numbered),
      type: "Track",
    ),
    NavigationBarItem(
      icon: Icon(Icons.format_color_fill_outlined),
//        title: Text('Favor'),
      tooltip: 'Theme',
      activeIcon: Icon(Icons.format_color_fill),
      type: SideModel.track_theme.toString(),
    ),
    NavigationBarItem(
      icon: Icon(MaterialCommunityIcons.chart_scatter_plot),
//        title: Text('Favor'),
      tooltip: 'Cell',
      activeIcon: Icon(MaterialCommunityIcons.chart_scatter_plot),
      type: SideModel.cell.toString(),
    ),
    NavigationBarItem(
      icon: Icon(MaterialCommunityIcons.table),
      tooltip: 'Data',
      activeIcon: Icon(MaterialCommunityIcons.table),
      type: SideModel.data.toString(),
    ),
  ];

  void onSelectionChange(int index) {
    if (index == _sideIndex) return;
    _sideIndex = index;
    update();
  }

  void openCell(Track cellTrack) {
    onSelectionChange(_sideItems.indexWhere((e) => e.type == SideModel.cell.toString()));
    Future.delayed(Duration(milliseconds: 300)).then((value) {
      CellPageLogic.safe()?.changeTrack(cellTrack);
    });
  }

  void openTrackTheme(Track track) {
    onSelectionChange(_sideItems.indexWhere((e) => e.type == SideModel.track_theme.toString()));
  }

  void openDataView(Track track) {
    onSelectionChange(_sideItems.indexWhere((e) => e.type == SideModel.data.toString()));
  }
}

class HomeDrawerEnd extends StatefulWidget {
  const HomeDrawerEnd({Key? key}) : super(key: key);

  @override
  State<HomeDrawerEnd> createState() => _HomeDrawerEndState();
}

class _HomeDrawerEndState extends State<HomeDrawerEnd> {
  EndDrawerLogic? logic;

  @override
  void initState() {
    logic = EndDrawerLogic.safe();
    if (logic == null) {
      logic = Get.put(EndDrawerLogic());
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<EndDrawerLogic>(
      init: logic,
      autoRemove: false,
      builder: (logic) => _builder(context, logic),
    );
  }

  Widget _builder(BuildContext context, EndDrawerLogic logic) {
    return Material(
      child: Container(
        constraints: BoxConstraints.expand(width: logic.sideIndex == 2 || logic.sideIndex == 3 ? 800 : 450),
        decoration: BoxDecoration(
          border: Border(left: BorderSide(color: Theme.of(context).colorScheme.primary.withAlpha(50), width: 2)),
        ),
        child: Row(
          children: [
            Expanded(
              child: IndexedStack(
                index: logic.sideIndex,
                children: [
                  TrackListSide(),
                  TrackThemeSelectorWidget(
                    smallSize: true,
                    onThemeChange: (trackTheme, trackType) {
                      trackTheme..brightness = Theme.of(context).brightness;
                      SgsBrowseLogic.safe()!.changeTheme(trackTheme, trackType);
                    },
                  ),
                  CellPage(showTitleBar: true),
                  DataViewerSide(),
                ],
              ),
            ),
            _buildMenuBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuBar() {
    return Container(
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: Theme.of(context).dividerTheme.color!, width: 1)),
      ),
      child: NavigationRail(
        selectedIndex: logic!.sideIndex,
        selectedIconTheme: Theme.of(context).iconTheme,
        selectedLabelTextStyle: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w400),
        extended: false,
        minWidth: 30,
        minExtendedWidth: 30,
        labelType: NavigationRailLabelType.selected,
        onDestinationSelected: logic!.onSelectionChange,
        destinations: logic!._sideItems.map((e) {
          return NavigationRailDestination(icon: e.icon!, selectedIcon: e.activeIcon, label: Text(e.tooltip!));
        }).toList(),
      ),
    );
  }
}
