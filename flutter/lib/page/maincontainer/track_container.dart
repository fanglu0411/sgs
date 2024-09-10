import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/bean/site_item.dart';
import 'package:flutter_smart_genome/bloc/sgs_context/sgs_browse_logic.dart';
import 'package:flutter_smart_genome/bloc/track_config/bloc.dart';
import 'package:flutter_smart_genome/components/events/error/view.dart';
import 'package:flutter_smart_genome/components/events/http_request_event/view.dart';
import 'package:flutter_smart_genome/page/cell/cell_page/cell_page_view.dart';
import 'package:flutter_smart_genome/page/cell/cell_page/cell_page_view_big.dart';
import 'package:flutter_smart_genome/page/chromosome_list/chromosome_list_page.dart';
import 'package:flutter_smart_genome/page/session/session_widget.dart';
import 'package:flutter_smart_genome/page/setting/setting_page.dart';
import 'package:flutter_smart_genome/page/track/theme/track_theme_selector_widget.dart';
import 'package:flutter_smart_genome/page/track/site_species_selector_widget.dart';
import 'package:flutter_smart_genome/page/track/sgs_browse_page.dart';
import 'package:flutter_smart_genome/service/sgs_app_service.dart';
import 'package:flutter_smart_genome/service/sgs_config_service.dart';
import 'package:flutter_smart_genome/side/cell_data_viewer_side.dart';
import 'package:flutter_smart_genome/side/data_viewer_side.dart';
import 'package:flutter_smart_genome/side/feature_detail_side.dart';
import 'package:flutter_smart_genome/side/highlight_side.dart';
import 'package:flutter_smart_genome/side/home_side.dart';
import 'package:flutter_smart_genome/side/search_side.dart';
import 'package:flutter_smart_genome/side/track_list_side.dart';
import 'package:flutter_smart_genome/side/updates/update_side.dart';
import 'package:flutter_smart_genome/widget/split_widget.dart' as sw;
import 'package:flutter_smart_genome/widget/splitlayout/edge_toolbar_widget.dart';
import 'package:flutter_smart_genome/widget/splitlayout/side_tab_item.dart';
import 'package:flutter_smart_genome/widget/splitlayout/sider_wrapper.dart';
import 'package:flutter_smart_genome/widget/track/chromosome/chromosome_data.dart';
import 'package:get/get.dart';

import 'track_container_logic.dart';

enum SideModel {
  home,
  server,
  chromosome,
  track_list,
  session_list,
  track_theme,
  feature_info,
  cell,
  data,
  cell_data,
  event,
  message,
  track_browse,
  search,
  highlight,
  terminal,
  extra,
  updates,
}

class TrackContainer extends StatefulWidget {
  @override
  _TrackContainerState createState() => _TrackContainerState();
}

class _TrackContainerState extends State<TrackContainer> {
  late Key _trackKey;

  bool _bottomExpanded = false;

  // Map<SideModel, Widget> _edgeWidgetMap;

  _toSetting() async {
    showSettingDialog(context);
  }

  final TrackContainerLogic logic = Get.put(TrackContainerLogic());

  @override
  void initState() {
    super.initState();
    SiteItem _site = SgsAppService.get()!.site!;
    _trackKey = Key('browser-${_site.sid}-${_site.currentSpeciesId}');
  }

  Widget _findPanelWidget(TabItem item) {
    switch (item.type) {
      case SideModel.home:
        return HomeSide(pop: false);
      case SideModel.track_list:
        return TrackListSide();
      case SideModel.session_list:
        return SessionWidget(
          currentSession: SgsAppService.get()!.session,
          onChanged: (session) {
            SgsAppService.get()!.loadSession(session);
          },
        );
      case SideModel.track_theme:
        return TrackThemeSelectorWidget(
          smallSize: true,
          onThemeChange: (trackTheme, trackType) {
            trackTheme..brightness = Theme.of(context).brightness;
            SgsBrowseLogic.safe()!.changeTheme(trackTheme, trackType);
          },
        );
      case SideModel.chromosome:
        return ChromosomeListPage(
          asPage: false,
          chr: SgsAppService.get()!.chr1?.id,
          chr2: SgsAppService.get()!.chr2?.id,
          onSelected: (List<ChromosomeData?> c) {
            var event = ChromosomeChangeEvent(chromosome: c[0]!, chromosome2: c[1]);
            SgsAppService.get()!.sendEvent(event);
          },
          species: SgsAppService.get()!.site!.currentSpeciesId!,
        );
      case SideModel.server:
        return SiteSpeciesSelectorWidget(
          axis: Axis.vertical,
          site: SgsAppService.get()!.site,
          onChanged: (site) {
            SgsAppService.get()!.changeSiteSpecies(site);
          },
        );
      case SideModel.track_browse:
        return SgsBrowsePage(
          key: _trackKey,
          inIdeMode: true,
        );
      case SideModel.feature_info:
        return FeatureDetailSide();
      case SideModel.updates:
        return UpdateSide();
      case SideModel.cell:
        return CellPage();
      case SideModel.data:
        return DataViewerSide();
      case SideModel.cell_data:
        return CellDataViewerSide();
      case SideModel.search:
        return SearchSide();
      case SideModel.highlight:
        return HighlightSide();
      // case SideModel.terminal:
      //   return TerminalSideWidget();
      case SideModel.event:
        return HttpRequestEventComponent();
      case SideModel.message:
        return ErrorEventComponent();
      default:
        return Container();
    }
  }

  void _onSideHide(TabItem item) async {
    if (item.type == SideModel.data) SgsConfigService.get()!.dataActiveTrack = null;
  }

  void _onTabChange(TabItem tabItem) {
    if (tabItem.type == SideModel.data && !tabItem.selected) SgsConfigService.get()!.dataActiveTrack = null;
    if (tabItem.selected) {
      logic.resetSideSelected(tabItem);
      logic.update(['track-container-root']);
      // logic.update([tabItem.position]);
    } else {
      //may be collapsed side, need update fraction
      logic.update(['track-container-root']);
    }
    // setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TrackContainerLogic>(
      id: 'track-container-root',
      builder: (logic) {
        if (logic.isScOnlyMode) return CellPageBig();

        return Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  _buildTabBarWidget(PanelPosition.left),
                  Expanded(child: _buildCenterWidget()),
                  _buildTabBarWidget(PanelPosition.right),
                ],
              ),
            ),
            _buildTabBarWidget(PanelPosition.bottom),
          ],
        );
      },
    );
  }

  Widget _buildTabBarWidget(PanelPosition position) {
    return GetBuilder<TrackContainerLogic>(
      init: logic,
      id: position.nameForTabBar,
      autoRemove: false,
      builder: (con) {
        List<TabItem> _items = logic.tabItems.where((t) => t.tabPosition == position).toList();
        List<TabItem> _footers = logic.footers.where((t) => t.tabPosition == position).toList();
        return EdgeToolbarWidget(
          position: position,
          tabs1: _items,
          footers: _footers,
          onChanged: logic.toggleTabItem,
        );
      },
    );
  }

  void _onHotKey(HotKey hotKey) {
    if (hotKey.ctrl || hotKey.alt) {
      TabItem? tab = logic.tabItems.firstWhereOrNull((e) => hotKey.equalWithKey(e.hotKey!));
      if (tab != null) {
        if (tab.selected) {
          tab.selected = false;
        } else {
          PanelPosition position = tab.panelPosition;
          logic.tabItems.where((t) => t.panelPosition == position).forEach((t) {
            t.selected = t == tab;
          });
        }
        setState(() {});
      } else if (hotKey.ctrl && hotKey.shift) {
        //SgsConfigService.get().ideMode = !SgsConfigService.get().ideMode;
        //todo
      }
    }
  }

  TabItem? _selectedSideItem(PanelPosition position) {
    return logic.allTabs.firstWhereOrNull((e) => e.panelPosition == position && e.selected);
  }

  Widget _buildCenterWidget() {
    TabItem? leftItem = _selectedSideItem(PanelPosition.left);
    TabItem? rightItem = _selectedSideItem(PanelPosition.right);
    TabItem? bottomItem = _selectedSideItem(PanelPosition.bottom);

    var (l, r, b) = (leftItem?.fraction ?? .0, rightItem?.fraction ?? .0, bottomItem?.fraction ?? .0);
    List<double> horFractions = [l, 1 - l - r, r];
    List<double> verFractions = [1 - b, b];
    List<double> horMinSize = [leftItem == null ? 0 : leftItem.minWidth ?? 300, 600, rightItem == null ? 0 : rightItem.minWidth ?? 300];
    List<double> verMinSize = [100, bottomItem == null ? 0 : bottomItem.verMinWidth ?? 200];

    Widget layout = sw.Split(
      axis: Axis.horizontal,
      controller: logic.horSplitController,
      onFractionChange: (frs) {
        _updateSideItemFraction(frs, Axis.horizontal);
      },
      children: [
        _buildSidePanel(PanelPosition.left),
        SgsBrowsePage(inIdeMode: true, key: logic.browsePageKey),
        _buildSidePanel(PanelPosition.right), // right
      ],
      initialFractions: horFractions,
      minSizes: horMinSize,
    );

    layout = sw.Split(
      controller: logic.verSplitController,
      children: [
        layout,
        _buildSidePanel(PanelPosition.bottom), //bottom
      ],
      initialFractions: verFractions,
      minSizes: verMinSize,
      onFractionChange: (frs) {
        _updateSideItemFraction(frs, Axis.vertical);
      },
    );
    return layout;
  }

  Widget _buildSidePanel(PanelPosition panelPosition) {
    return GetBuilder<TrackContainerLogic>(
        init: logic,
        id: panelPosition,
        autoRemove: false,
        builder: (context) {
          TabItem? item = logic.allTabs.firstWhereOrNull((e) => e.selected && e.panelPosition == panelPosition);
          if (item == null) return SizedBox();
          return SidePanelWrapper(
            tabItem: item,
            child: _findPanelWidget(item),
            onHide: logic.toggleTabItem,
            onChangePosition: logic.onChangePanelPosition,
          );
        });
  }

  _updateSideItemFraction(List<double> fractions, Axis axis) {
    if (axis == Axis.horizontal) {
      final leftSideTabItem = _selectedSideItem(PanelPosition.left);
      final rightSideTabItem = _selectedSideItem(PanelPosition.right);
      if (fractions.first != 0) leftSideTabItem?.fraction = fractions.first;
      if (fractions.last != 0) rightSideTabItem?.fraction = fractions.last;
    } else {
      final bottomSideTabItem = _selectedSideItem(PanelPosition.bottom);
      if (fractions.last != 0) bottomSideTabItem?.fraction = fractions.last;
    }
  }
}
