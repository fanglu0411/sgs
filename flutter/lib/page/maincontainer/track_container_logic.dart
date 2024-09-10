import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:flutter_smart_genome/base/app_layout.dart';
import 'package:flutter_smart_genome/components/events/error/logic.dart';
import 'package:flutter_smart_genome/components/events/http_request_event/logic.dart';
import 'package:flutter_smart_genome/page/cell/cell_tool_bar/cell_track_selector_widget.dart';
import 'package:flutter_smart_genome/page/maincontainer/track_container.dart';
import 'package:flutter_smart_genome/routes.dart';
import 'package:flutter_smart_genome/service/sgs_config_service.dart';
import 'package:flutter_smart_genome/widget/split_widget.dart';
import 'package:flutter_smart_genome/widget/splitlayout/side_tab_item.dart';
import 'package:flutter_smart_genome/widget/track/base/track_data.dart';
import 'package:get/get.dart';

class TrackContainerLogic extends GetxController {
  static TrackContainerLogic? safe() {
    if (Get.isRegistered<TrackContainerLogic>()) {
      return Get.find<TrackContainerLogic>();
    }
    return null;
  }

  /// single-cell-only mode excluded side items
  List<SideModel> scOnlyExcludes = [
    SideModel.session_list,
    SideModel.search,
    SideModel.highlight,
    SideModel.track_list,
    SideModel.cell,
    SideModel.data,
    SideModel.cell_data,
    SideModel.feature_info,
    SideModel.track_theme,
    SideModel.event,
  ];

  List<SideModel> scOnlyIncludes = [
    // SideModel.cell_data,
  ];

  late List<TabItem> _tabItems;
  List<TabItem> _footers = [];

  List<TabItem> get tabItems => isScOnlyMode
      ? _tabItems.where((e) => !scOnlyExcludes.contains(e.type)).toList() //
      : _tabItems.where((e) => !scOnlyIncludes.contains(e.type)).toList();

  List<TabItem> get allTabs => [...tabItems, ...footers];

  List<TabItem> get footers => _footers;

  double _iconSize = 20;

  RxString _cellSelectedString = ''.obs;

  late AppLayout appLayout;

  bool get isScOnlyMode => appLayout == AppLayout.SC;

  Key browsePageKey = Key("browse-page");

  TrackContainerLogic() {
    appLayout = SgsConfigService.get()!.appLayout;
    _tabItems = [
      // TabItem(
      //   title: 'SGS',
      //   type: SideModel.home,
      //   icon: Icon(Icons.home, size: _iconSize),
      //   position: EdgeLayoutPosition.left,
      //   hotKey: HotKey.ctrl('0'),
      //   selected: false,
      // ),
      // TabItem(
      //   title: 'Server',
      //   type: SideModel.server,
      //   icon: Icon(Icons.storage, size: _iconSize),
      //   position: EdgeLayoutPosition.left,
      //   hotKey: HotKey.ctrl('1'),
      //   selected: true,
      // ),
      // TabItem(
      //   title: 'Chromosome',
      //   type: SideModel.chromosome,
      //   icon: Icon(Icons.view_list, size: 14),
      //   position: EdgeLayoutPosition.left,
      //   hotKey: HotKey.ctrl('2'),
      // ),

      TabItem(
        title: 'Session',
        type: SideModel.session_list,
        icon: Icon(Icons.history, size: 17),
        panelPosition: PanelPosition.left,
        tabPosition: PanelPosition.left,
        hotKey: HotKey.ctrl('2'),
      ),
      TabItem(
        title: 'Search',
        type: SideModel.search,
        icon: Icon(MaterialCommunityIcons.cloud_search, size: _iconSize),
        panelPosition: PanelPosition.left,
        tabPosition: PanelPosition.left,
        hotKey: HotKey.ctrl('3'),
      ),
      TabItem(
        title: 'Highlights',
        type: SideModel.highlight,
        icon: Icon(Icons.highlight, size: _iconSize),
        panelPosition: PanelPosition.left,
        tabPosition: PanelPosition.left,
        hotKey: HotKey.ctrl('h'),
      ),
      TabItem(
        title: 'Track List',
        type: SideModel.track_list,
        icon: Icon(Icons.format_list_numbered, size: _iconSize),
        panelPosition: PanelPosition.right,
        tabPosition: PanelPosition.right,
        hotKey: HotKey.ctrl('4'),
        selected: true,
      ),
      TabItem(
        title: 'Track Theme',
        type: SideModel.track_theme,
        icon: Icon(Icons.format_color_fill, size: _iconSize),
        panelPosition: PanelPosition.right,
        tabPosition: PanelPosition.right,
        hotKey: HotKey.ctrl('5'),
      ),
      TabItem(
        title: 'Feature Info',
        type: SideModel.feature_info,
        icon: Icon(Icons.info_outlined, size: _iconSize),
        panelPosition: PanelPosition.right,
        tabPosition: PanelPosition.right,
        hotKey: HotKey.ctrl('6'),
        minWidth: 340,
      ),
      // TabItem(
      //   title: 'Updates',
      //   type: SideModel.updates,
      //   icon: Icon(Icons.update, size: _iconSize),
      //   position: EdgeLayoutPosition.right,
      //   // hotKey: HotKey.ctrl('6'),
      //   minWidth: 340,
      // ),
      TabItem(
        title: 'Single Cell',
        type: SideModel.cell,
        icon: Icon(MaterialCommunityIcons.chart_scatter_plot, size: _iconSize),
        panelPosition: PanelPosition.right,
        tabPosition: PanelPosition.right,
        hotKey: HotKey.ctrl('7'),
        fraction: .45,
        minWidth: 580,
        verMinWidth: 300,
        titleBuilder: (item, context) {
          return CellTrackSelectorWidget(prefix: const Text('Single Cell'));
        },
        // extraBuilder: (item, context) {
        //   return IconButton(
        //     icon: Icon(Icons.upload),
        //     tooltip: 'Load local cords',
        //     padding: EdgeInsets.zero,
        //     constraints: BoxConstraints.tightFor(width: 28, height: 28),
        //     splashRadius: 14,
        //     onPressed: () async {
        //       var result = await showCordSelectorDialog(context);
        //       if (result == null) return;
        //       CellPageLogic.safe()?.onNativeFileSelected(result['cord'], result['meta']);
        //     },
        //   );
        // },
      ),
      // TabItem(
      //   title: 'Terminal',
      //   type: SideModel.terminal,
      //   icon: Icon(Icons.code, size: 13),
      //   position: EdgeLayoutPosition.right,
      //   hotKey: HotKey.ctrl('8'),
      //   fraction: .35,
      //   minWidth: 580,
      // ),

      // TabItem(
      //   title: 'Cell Data Table',
      //   type: SideModel.cell_data,
      //   icon: Icon(Icons.view_comfortable, size: _iconSize),
      //   position: EdgeLayoutPosition.bottom,
      //   hotKey: HotKey.ctrl('8'),
      //   fraction: .4,
      // ),
    ];
    _footers = [
      // TabItem(
      //   title: 'Setting',
      //   type: SideModel.extra,
      //   position: EdgeLayoutPosition.left,
      //   icon: IconButton(
      //     tooltip: 'Setting',
      //     icon: Icon(Icons.settings, size: _iconSize + 2),
      //     onPressed: () {},
      //   ),
      //   hotKey: HotKey.ctrl('9'),
      // ),
      TabItem(
        title: 'Deploy',
        type: SideModel.extra,
        panelPosition: PanelPosition.left,
        tabPosition: PanelPosition.left,
        builder: (item, context) {
          return IconButton(
            tooltip: 'New SGS Server',
            icon: Icon(MaterialCommunityIcons.database_plus, size: _iconSize + 2),
            onPressed: _toCreateServer,
          );
        },
        icon: SizedBox(),
        hotKey: HotKey.ctrl('9'),
      ),
      TabItem(
        title: 'Data Table',
        type: SideModel.data,
        icon: Icon(Icons.view_comfortable, size: _iconSize),
        panelPosition: PanelPosition.bottom,
        tabPosition: PanelPosition.left,
        hotKey: HotKey.ctrl('8'),
        fraction: .4,
      ),
      if (!kIsWeb)
        TabItem(
          title: 'Error',
          type: SideModel.message,
          panelPosition: PanelPosition.bottom,
          tabPosition: PanelPosition.left,
          icon: Icon(Icons.message, size: _iconSize),
          hotKey: HotKey.ctrl('e'),
          fraction: .2,
          extraBuilder: (item, context) {
            return IconButton(
              splashRadius: 20,
              iconSize: 16,
              tooltip: 'clear',
              padding: EdgeInsets.zero,
              constraints: BoxConstraints.tightFor(width: 30, height: 30),
              onPressed: () {
                ErrorEventLogic.safe()?.clear();
              },
              icon: Icon(Icons.clear),
            );
          },
        ),
      if (kDebugMode)
        TabItem(
          title: 'Event',
          type: SideModel.event,
          panelPosition: PanelPosition.bottom,
          tabPosition: PanelPosition.left,
          icon: Icon(Icons.event, size: _iconSize),
          hotKey: HotKey.ctrl('9'),
          fraction: .2,
          extraBuilder: (item, context) {
            return IconButton(
              splashRadius: 20,
              iconSize: 16,
              tooltip: 'clear',
              padding: EdgeInsets.zero,
              constraints: BoxConstraints.tightFor(width: 30, height: 30),
              onPressed: () {
                HttpRequestEventLogic.safe()?.clear();
              },
              icon: Icon(Icons.clear),
            );
          },
        ),
    ];
  }

  SplitController? _horSplitController;
  SplitController? _verSplitController;

  SplitController? get horSplitController => _horSplitController;

  SplitController? get verSplitController => _verSplitController;

  @override
  onInit() {
    super.onInit();
    _horSplitController = SplitController();
    _verSplitController = SplitController();
  }

  _toCreateServer() {
    Get.toNamed(RoutePath.server_create);
  }

  void setSelectedCellTrack(Track track) {
    Future.delayed(Duration(milliseconds: 300)).then((value) {
      _cellSelectedString.value = track.scName ?? '';
    });
  }

  setSide(SideModel sideModel, [bool expanded = false]) {
    var targetTab = allTabs.firstWhere((t) => t.type == sideModel);
    bool needExpanded = expanded;
    if (targetTab.selected == needExpanded) return;
    targetTab.selected = needExpanded;
    if (targetTab.selected) {
      allTabs.where((e) => e.panelPosition == targetTab.panelPosition).forEach((e) {
        if (e.type != targetTab.type) e.selected = false;
      });
    }
    __updateSplitFraction(targetTab.panelPosition.isHor);
    update([targetTab.panelPosition, targetTab.panelPosition.nameForTabBar]);
  }

  bool sideOpened(SideModel sideModel) {
    var infoTab = _tabItems.firstWhere((t) => t.type == sideModel);
    return infoTab.selected;
  }

  void resetSideSelected(TabItem tabItem) {
    _tabItems.where((t) => t.panelPosition == tabItem.panelPosition).forEach((t) {
      t.selected = t.type == tabItem.type;
    });
  }

  bool serverOpened() {
    return _tabItems.firstWhereOrNull((t) => t.type == SideModel.server)!.selected;
  }

  void onChangePanelPosition(TabItem item, PanelPosition prePosition) {
    __updateSplitFraction(true);
    __updateSplitFraction(false);
    update([
      PanelPosition.left, //for side panel
      PanelPosition.right,
      PanelPosition.bottom,
      PanelPosition.left.nameForTabBar, //for site tab item
      PanelPosition.right.nameForTabBar,
      PanelPosition.bottom.nameForTabBar,
    ]);
  }

  void __updateSplitFraction(bool hor) {
    if (hor) {
      TabItem? leftItem = allTabs.firstWhereOrNull((e) => e.selected && e.panelPosition == PanelPosition.left);
      TabItem? rightItem = allTabs.firstWhereOrNull((e) => e.selected && e.panelPosition == PanelPosition.right);
      double l = leftItem?.fraction ?? 0;
      double r = rightItem?.fraction ?? 0;
      List<double> minSizes = [leftItem?.minWidth ?? 0, 600, rightItem?.minWidth ?? 0];
      _horSplitController?.updateFractions(fractions: [l, 1 - l - r, r], minSizes: minSizes);
    } else {
      TabItem? bottomItem = allTabs.firstWhereOrNull((e) => e.selected && e.panelPosition == PanelPosition.bottom);
      double b = bottomItem?.fraction ?? 0;
      List<double> vertMinSizes = [0, bottomItem?.minWidth ?? 0];
      _verSplitController?.updateFractions(fractions: [1 - b, b], minSizes: vertMinSizes);
    }
  }

  void toggleTabItem(TabItem item) {
    allTabs.where((e) => e.panelPosition == item.panelPosition).forEach((e) {
      if (item != e) e.selected = false;
    });
    if (item.panelPosition.isHor) {
      __updateSplitFraction(true);
      update([
        PanelPosition.left,
        PanelPosition.right,
        PanelPosition.left.nameForTabBar,
        PanelPosition.right.nameForTabBar,
      ]);
    } else if (item.panelPosition.isVer) {
      __updateSplitFraction(false);
      update([
        item.panelPosition,
        item.panelPosition.nameForTabBar,
      ]);
    }
  }

  changeAppLayout(AppLayout appLayout) {
    if (this.appLayout == appLayout) {
      return;
    }

    final AppLayout preLayout = this.appLayout;
    this.appLayout = appLayout;

    var trackItem = allTabs.firstWhereOrNull((t) => t.type == SideModel.track_list);
    var cellItem = allTabs.firstWhereOrNull((t) => t.type == SideModel.cell);
    bool changeBetweenSC2SG = false; //change from browse to sc or sc to  browse

    switch (appLayout) {
      case AppLayout.gnome:
        trackItem!.selected = true;
        cellItem!.selected = false;
        var others = allTabs.where((t) => t.panelPosition == trackItem.panelPosition && t != trackItem);
        others.forEach((t) => t.selected = false);
        changeBetweenSC2SG = preLayout == AppLayout.SC;
        break;
      case AppLayout.SC:
        //hide all bottom items
        // var others = _tabItems.where((t) => t.panelPosition == PanelPosition.bottom);
        // others.forEach((t) => t.selected = false);
        changeBetweenSC2SG = preLayout != AppLayout.SC;
        break;
      case AppLayout.SG_h:
        cellItem!.selected = true;
        cellItem.panelPosition = PanelPosition.right;
        var others = allTabs.where((t) => t.panelPosition == cellItem.panelPosition && t != cellItem);
        others.forEach((t) => t.selected = false);
        changeBetweenSC2SG = preLayout == AppLayout.SC;
        break;
      case AppLayout.SG_v:
        // trackItem.selected = false;
        cellItem!.selected = true;
        cellItem.panelPosition = PanelPosition.bottom;

        var others = allTabs.where((t) => t.panelPosition == cellItem.panelPosition && t != cellItem);
        others.forEach((t) => t.selected = false);

        var rightItems = allTabs.where((t) => t.panelPosition == PanelPosition.right);
        rightItems.forEach((t) => t.selected = false);
        changeBetweenSC2SG = preLayout == AppLayout.SC;
        break;
      default:
        break;
    }
    update([
      'track-container-root',
      PanelPosition.left,
      PanelPosition.right,
      PanelPosition.bottom,
      PanelPosition.center,
      PanelPosition.left.nameForTabBar,
      PanelPosition.right.nameForTabBar,
      PanelPosition.bottom.nameForTabBar,
    ] //
        );
  }

  @override
  void onClose() {
    super.onClose();
    _verSplitController?.dispose();
    _horSplitController?.dispose();
  }
}
