import 'dart:convert';
import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/foundation.dart';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:flutter_smart_genome/base/app_layout.dart';
import 'package:flutter_smart_genome/base/container_config.dart';
import 'package:flutter_smart_genome/base/ui_config.dart' as ui_config;
import 'package:flutter_smart_genome/base/ui_config.dart';
import 'package:flutter_smart_genome/bean/gene.dart';
import 'package:flutter_smart_genome/bean/site_item.dart';
import 'package:flutter_smart_genome/bloc/sgs_context/sgs_browse_logic.dart';
import 'package:flutter_smart_genome/bloc/track_config/track_config_event.dart';
import 'package:flutter_smart_genome/components/shortener/url_shorten_widget.dart';
import 'package:flutter_smart_genome/mixin/view_size_mixin.dart';
import 'package:flutter_smart_genome/page/chromosome_list/chromosome_list_page.dart';
import 'package:flutter_smart_genome/page/compare/compare_common.dart';
import 'package:flutter_smart_genome/page/home/home_page_drawer_end.dart';
import 'package:flutter_smart_genome/page/home/home_page_drawer_tablet.dart';
import 'package:flutter_smart_genome/page/maincontainer/track_container.dart';
import 'package:flutter_smart_genome/page/maincontainer/track_container_logic.dart';
import 'package:flutter_smart_genome/page/species/species_list_widget.dart';
import 'package:flutter_smart_genome/page/track/bottom_float_control_widget.dart';
import 'package:flutter_smart_genome/page/compare/compare_list_widget.dart';
import 'package:flutter_smart_genome/page/track/feature_search_widget.dart';
import 'package:flutter_smart_genome/page/track/theme/track_theme_selector_widget.dart';
import 'package:flutter_smart_genome/page/track/vertical_track_control_bar.dart';
import 'package:flutter_smart_genome/platform/platform_adapter.dart';
import 'package:flutter_smart_genome/routes.dart';
import 'package:flutter_smart_genome/service/sgs_app_service.dart';
import 'package:flutter_smart_genome/side/search_side.dart';
import 'package:flutter_smart_genome/side/track_list_side.dart';
import 'package:flutter_smart_genome/util/device_info.dart';
import 'package:flutter_smart_genome/util/logger.dart';
import 'package:flutter_smart_genome/util/native_window_util/window_util.dart';
import 'package:flutter_smart_genome/util/undo_redo_manager.dart';
import 'package:flutter_smart_genome/util/widget_util.dart';
import 'package:flutter_smart_genome/widget/basic/custom_bot_widget.dart';
import 'package:flutter_smart_genome/widget/basic/svg_icons.dart';
import 'package:flutter_smart_genome/widget/loading_widget.dart';
import 'package:flutter_smart_genome/widget/navigation_bar.dart';
import 'package:flutter_smart_genome/widget/sider/horizontal_sider.dart';
import 'package:flutter_smart_genome/widget/splitlayout/side_tab_item.dart';
import 'package:flutter_smart_genome/widget/track/base/track_session.dart';
import 'package:flutter_smart_genome/widget/track/base/track_data.dart';
import 'package:flutter_smart_genome/widget/track/chromosome/chromosome_data.dart';
import 'package:flutter_smart_genome/widget/track/common.dart';
import 'package:flutter_smart_genome/widget/track/interactive_group_widget.dart';
import 'package:flutter_smart_genome/widget/track/track_group_logic.dart';
import 'package:flutter_smart_genome/widget/track/track_list_view_widget.dart';
import 'package:flutter_smart_genome/extensions/widget_extensions.dart';
import 'package:get/get.dart';
import 'package:majascan/majascan.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share/share.dart';

import 'track_control_bar/track_control_bar.dart';

class SgsBrowsePage extends StatefulWidget {
  final TrackSession? session;
  final SiteItem? site;
  final bool showDrawer;
  final ValueChanged<SiteItem>? onSiteChange;
  final inIdeMode;

  const SgsBrowsePage({
    Key? key,
    this.session,
    this.site,
    this.showDrawer = false,
    this.onSiteChange,
    this.inIdeMode = false,
  }) : super(key: key);

  @override
  _SgsBrowsePageState createState() => _SgsBrowsePageState();
}

class _SgsBrowsePageState extends State<SgsBrowsePage> with ViewSizeMixin, SingleTickerProviderStateMixin, WidgetsBindingObserver, RouteAware {
  AnimationController? _floatAnimationController;
  Animation<AlignmentGeometry>? _leftBarAnimation;
  Animation<AlignmentGeometry>? _topBarAnimation;
  Animation<AlignmentGeometry>? _rightBarAnimation;
  Animation<AlignmentGeometry>? _bottomBarAnimation;

  bool _floatControlVisible = false;

  double _scale = 1.0;

  List<DeviceOrientation> orientations = [DeviceOrientation.landscapeLeft];

  SiteItem get site => SgsAppService.get()!.site!;
  final SgsBrowseLogic logic = Get.put(SgsBrowseLogic());

  SgsAppService get service => SgsAppService.get()!;

  @override
  void initState() {
    super.initState();
    logger.d(' -- init sgs browse page --');
    // logic = Get.put(SgsBrowseLogic());
    _floatAnimationController = AnimationController(vsync: this, duration: Duration(milliseconds: 250));
    _leftBarAnimation = AlignmentTween(
      begin: Alignment(-1.25, 0),
      end: Alignment(-1, 0),
    ).animate(_floatAnimationController!);
    _topBarAnimation = AlignmentTween(
      begin: Alignment(0, -1.25),
      end: Alignment(0, -.98),
    ).animate(_floatAnimationController!);
    _rightBarAnimation = AlignmentTween(
      begin: Alignment(1.25, .75),
      end: Alignment(.95, .75),
    ).animate(_floatAnimationController!);
    _bottomBarAnimation = AlignmentTween(
      begin: Alignment(0, 1.25),
      end: Alignment(0, .95),
    ).animate(_floatAnimationController!);
//    _checkOutPlugin();
    WidgetsBinding.instance.addObserver(this);
    service
      // ..sendEvent(TrackBasicEvent(session: widget.session))
      ..sendEvent(CheckClipboardEvent());

    // logic.shareSessionObserver.addListener(_onShareSessionListener);
  }

  // void _onShareSessionListener() {
  //   var session = logic.shareSessionObserver.value;
  //   if (session != null) {
  //     _openOutUrlDialog(Get.context!, session);
  //   }
  // }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      // case AppLifecycleState.inactive:
      case AppLifecycleState.resumed:
        service?.sendEvent(CheckClipboardEvent());
        break;
      default:
        break;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
  }

  // @override
  // void didPopNext() {
  //   super.didPopNext();
  // }

  // @override
  // void didPushNext() {
  //   super.didPushNext();
  // }

  @override
  void didUpdateWidget(SgsBrowsePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // bloc.site = widget.site ?? SgsAppService.get()!.site;
  }

  Future<TrackSession?> checkWebUrl() async {
    if (!kIsWeb) return null;
    final url = PlatformAdapter.create().getLocationUrl();
    return TrackSession.fromUrl(url);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SgsBrowseLogic>(
      // tag: 'sgs-browse',
      init: logic,
      autoRemove: false,
      initState: (s) {
        if (!SgsAppService.get()!.inited || logic.loading) {
          checkWebUrl().then((session) {
            SgsAppService.get()?.sendEvent(TrackBasicEvent(session: session));
          });
        }
      },
      builder: (logic) {
        return LayoutBuilder(builder: (c, constraints) => _builder(c, constraints, logic));
      },
    );
  }

  Widget _builder(BuildContext context, BoxConstraints constraints, SgsBrowseLogic logic) {
    if (DeviceOS.isMobile) {
      return OrientationBuilder(
        builder: (context, orientation) {
          return _buildPage(context, constraints, logic);
        },
      );
    }
    return _buildPage(context, constraints, logic);
  }

  Widget _buildPage(BuildContext context, BoxConstraints constraints, SgsBrowseLogic logic) {
//    final ModalRoute<dynamic> parentRoute = ModalRoute.of(context);
//    final bool canPop = parentRoute?.canPop ?? false;
    bool _isMobile = isMobile(context);
//    bool _isBigScreen = isBigScreen(context);
//    bool _dark = Theme.of(context).brightness == Brightness.dark;
    var size = constraints.biggest;
    bool smallHorizontal = smallLandscape(context, size);
    // bool _portrait = ui_config.portrait(context, size);
    // bool _mobile = ui_config.isMobile(context, size);

    PreferredSizeWidget? appBar;
    if (!logic.isLandscape && !smallHorizontal || widget.inIdeMode) {
      appBar = _buildTrackControlBar(context, logic, size);
      if (!widget.inIdeMode) {
        appBar = PreferredSize(
          preferredSize: Size.fromHeight(50),
          child: IoUtils.instance.wrapNativeTitleBarIfRequired(appBar),
        );
      }
    }

    Widget? leftDrawer, endDrawer;
    if (widget.showDrawer) {
      if (_isMobile) {
        // leftDrawer = HomeDrawer(
        //   onSiteChange: widget.onSiteChange,
        //   onTapMenu: (k) => _onTapMenu(context, k),
        // );
      } else {
        leftDrawer = HomeDrawerTablet();
        endDrawer = HomeDrawerEnd();
      }
    }

    return Scaffold(
      appBar: appBar,
      drawer: leftDrawer,
      endDrawer: endDrawer,
      drawerScrimColor: Colors.black.withOpacity(.3),
      body: _bodyBuilder(context, logic),
      floatingActionButton: _isMobile
          ? FloatingActionButton(
              tooltip: 'Show Menu',
              mini: true,
              onPressed: _showMobileFeatureMenu,
              child: Icon(Icons.menu),
            )
          : null,
    );
  }

  void _showMobileFeatureMenu() {
    var size = MediaQuery.of(context).size;
    var target = size.center(Offset.zero);
    showAttachedWidget(
        target: target,
        preferDirection: PreferDirection.bottomCenter,
        attachedBuilder: (cancel) {
          var features = [
            {
              'title': 'Server',
              'icon': Icons.dataset,
              'type': 'server',
            },
            {
              'title': 'Share',
              'icon': Icons.share,
              'type': 'share',
            },
            {
              'title': 'Setting',
              'icon': Icons.settings,
              'type': 'setting',
            }
          ];
          return Material(
            elevation: 6,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              constraints: BoxConstraints(maxWidth: size.width * .85, maxHeight: size.height * .75),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1.25,
                ),
                itemCount: features.length,
                shrinkWrap: true,
                itemBuilder: (c, i) {
                  var f = features[i];
                  return Container(
                    decoration: BoxDecoration(
                      border: Border.all(width: .5, color: Theme.of(context).dividerColor),
                    ),
                    child: TextButton(
                      onPressed: () => _onTapMenuMobile(f['type'] as String),
                      style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(f['icon'] as IconData, size: 28),
                          SizedBox(height: 10),
                          Text('${f['title']}'),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        });
  }

  _onTapMenuMobile(String type) async {
    switch (type) {
      case 'share':
        break;
      case 'setting':
        var result = await Get.toNamed(RoutePath.settings);
        break;
      case 'server':
        var result = await Get.toNamed(RoutePath.site_list);
        break;
    }
  }

  Widget _bodyBuilder(BuildContext context, SgsBrowseLogic logic) {
    Widget _body;
    if (logic.ready) {
      _body = _buildBody(context, logic);
    } else if (logic.error != null) {
      _body = LoadingWidget(
        loadingState: LoadingState.error,
        icon: SvgIcon(iconEmpty, size: Size.square(80)),
        message: logic.error,
        onErrorClick: (s) {
          service.sendEvent(TrackBasicEvent(session: service.session));
        },
      );
    } else {
      _body = LoadingWidget(
        loadingState: LoadingState.loading,
        message: ' Track data loading...',
      );
    }
    return _body;
  }

  Widget _buildFloatPositionInfo(PositionInfo positionInfo) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        color: Theme.of(context).colorScheme.background.withAlpha(200),
      ),
      child: Text('${positionInfo.species} / ${positionInfo.chrName}'),
    );
  }

  Widget _buildLeftActionBar(BuildContext context) {
    bool _dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(topRight: Radius.circular(8), bottomRight: Radius.circular(8)),
        color: _dark ? Theme.of(context).colorScheme.background.withAlpha(200) : Theme.of(context).colorScheme.primary.withOpacity(.65),
      ),
      child: CustomNavigationBar(
        mainAxisSize: MainAxisSize.min,
        orientation: Axis.vertical,
        onTap: (index, type) {
          switch (type) {
            case 'exit':
              if (ui_config.mobilePlatform()) {
                SgsBrowseLogic.safe()?.toPortrait();
              } else {
                final ModalRoute<dynamic>? parentRoute = ModalRoute.of(context);
                final bool canPop = parentRoute?.canPop ?? false;
                if (canPop) Navigator.of(context).maybePop();
              }
              break;
            case 'track_filter':
              _showTrackListFilterModel(context);
              break;
            case 'chromosome':
              _showChromosomeListDialog(context);
              break;
            case 'server':
              _showSpeciesSelector(context, null);
              break;
          }
        },
        items: [
          if (DeviceOS.isMobile)
            NavigationBarItem(
              icon: RotatedBox(quarterTurns: 2, child: Icon(Icons.exit_to_app, color: Colors.white)),
              tooltip: 'Exit',
              type: 'exit',
            ),
          NavigationBarItem(
            icon: Icon(MaterialCommunityIcons.server, color: Colors.white),
            tooltip: 'Server',
            type: 'server',
          ),
          NavigationBarItem(
            icon: Icon(MaterialCommunityIcons.format_list_checks, color: Colors.white),
            tooltip: 'Track List',
            type: 'track_filter',
          ),
          NavigationBarItem(
            icon: Icon(MaterialCommunityIcons.dna, color: Colors.white),
            tooltip: 'Chromosome',
            type: 'chromosome',
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildTrackControlBar(BuildContext context, SgsBrowseLogic logic, Size size) {
    ChromosomeData? _chr;
    Range? range;
    if (logic.ready) {
      _chr = service.chr1;
      range = logic.groupLogic?.visibleRange ?? service.session?.range;
    }
    Widget _controlBar = TrackControlBar(
      inIdeMode: widget.inIdeMode,
      site: site,
      chromosome: _chr,
      range: range,
      trackViewWidth: size.width,
      zoomConfig: logic.groupLogic?.zoomConfig,
      onPanModeChange: (value) => _onModeChange(value),
      onPan: (action) => _mockUserPan(SgsBrowseLogic.safe()?.groupLogic, action),
      onZoomChange: (action) {
        double zoom = actionToZoom(action);
        double end = zoom < 0 ? 1.0 / math.pow(2, -zoom) : 1.0 * math.pow(2, zoom);
        _mockUserScale(logic.groupLogic, zoom, Tween(begin: 1.0, end: end));
      },
      onZoomToRange: (range) {
        int minSeq = size.width ~/ 40;
        if (range.size < minSeq) {
          range.end = range.start + minSeq;
        }
        if (range.start >= (_chr?.rangeEnd ?? 0)) {
          BotToast.showSimpleNotification(title: 'start is out of range', align: Alignment(0.0, -1));
          return;
        }
        if (range.end > _chr!.rangeEnd) range.end = _chr.rangeEnd;
        zoomToRange(logic.groupLogic, range);
      },
      onTap: _onControlBarTap,
      onSearch: logic.groupLogic?.onSearchKeyword,
    );
    bool _isMobile = isMobile(context);
    return AppBar(
      titleSpacing: 0,
      automaticallyImplyLeading: !widget.inIdeMode && !_isMobile, // ui_config.mobilePlatform(),
      toolbarHeight: ui_config.appBarHeight(context),
      title: _controlBar,
    );
  }

  void _onControlBarTap(BuildContext c, action, [var data, var data2]) {
    if (action == TrackControlAction.tap_compare) {
      _showCompareList(c);
    } else if (action == TrackControlAction.tap_locate) {
      //
    } else if (action == TrackControlAction.tap_chromosome) {
      // _showChromosomeListDialog(c);
      ChromosomeData chr1 = data;
      ChromosomeData? chr2 = service.chr2;
      Range range = data2;
      var event = ChromosomeChangeEvent(
        chromosome: chr1,
        range: range,
        chromosome2: chr2,
        range2: service.session2?.range,
      );
      service.sendEvent(event);
    } else if (action == TrackControlAction.tap_session_list) {
      SgsBrowseLogic.safe()?.showSessionWidget(c);
    } else if (action == TrackControlAction.tap_site_selector) {
      _showSpeciesSelector(context, c);
    } else if (action == TrackControlAction.tap_share_session) {
      _onShare(context);
    } else if (action == TrackControlAction.tap_more) {
      _showMoreAction(c, true);
    } else if (action == TrackControlAction.tap_rotation) {
      SgsBrowseLogic.safe()?.toLandscape();
    } else if (action == TrackControlAction.tap_track_list) {
      _showTrackListFilterModel(context);
    } else if (action == TrackControlAction.tap_split_mode) {
      SgsBrowseLogic.safe()?.resetKeys();
      service.sendEvent(ToggleCompareModeEvent());
    } else if (action == TrackControlAction.tap_undo) {
      UndoRedoManager.get().undo();
    } else if (action == TrackControlAction.tap_redo) {
      UndoRedoManager.get().redo();
    }
  }

  _buildSpeciesTitle(BuildContext context) {
    return Builder(
      builder: (targetContext) {
        return Tooltip(
          message: '${site.url}\nClick to change species',
          child: InkWell(
            onTap: () => _showSpeciesSelector(context, targetContext),
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 4, horizontal: 6),
              padding: EdgeInsets.symmetric(vertical: 6, horizontal: 6),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white38),
                borderRadius: BorderRadius.circular(2),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Species: ${site.currentSpecies ?? site.name}',
                    style: TextStyle(fontWeight: FontWeight.w400, fontSize: 14),
                  ),
                  Icon(Icons.keyboard_arrow_down, size: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showSpeciesSelector(BuildContext context, BuildContext? targetContext) async {
    //List<Species> _species = bloc.species;

    if (ui_config.smallLandscape(context)) {
    } else if (isMobile(context)) {
      var site = await Navigator.of(context).pushNamed<SiteItem>(RoutePath.site_list);
      if (null != site) {
        service.changeSiteSpecies(site);
        // SgsBrowseLogic.safe().onSiteSpeciesChange(context, site);
      }
      return;
    }

    Size _size = MediaQuery.of(context).size;
    Widget content(BuildContext context, {cancel, bool dialog = false}) {
      SiteItem site = service.site!;
      Widget child = DataSetListWidget(
        site: site,
        selectedSpecies: site.currentSpeciesId!,
        onItemTap: (sps) {
          site
            ..currentSpeciesId = '${sps.id}'
            ..currentSpecies = sps.name;
          service.changeSiteSpecies(site);
        },
      );
      // Widget child = SiteSpeciesSelectorWidget(
      //   site: site,
      //   axis: Axis.horizontal,
      //   onChanged: (site) {
      //     if (dialog) {
      //       Navigator.of(context).pop();
      //     }
      //     cancel?.call();
      //     service.changeSiteSpecies(site);
      //   },
      // );
      return Material(
        elevation: 5,
        shape: modelShape(),
        child: Container(
          constraints: BoxConstraints.tightFor(width: 460, height: _size.height * .75),
          child: Column(
            children: [
              // AppBar(title: Text('Change Species'), centerTitle: false),
              ListTile(title: Text('Server: ${site.url}'), dense: true),
              Divider(height: 1.0),
              Expanded(child: child),
            ],
          ),
        ),
      );
    }

    if (targetContext == null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          contentPadding: EdgeInsets.zero,
          titlePadding: EdgeInsets.zero,
          content: content(context, dialog: true),
        ),
      );
    } else {
      showAttachedWidget(
        preferDirection: PreferDirection.bottomLeft,
        backgroundColor: Colors.black54.withAlpha(120),
        targetContext: targetContext,
        attachedBuilder: (cancel) => content(context, cancel: cancel),
      );
    }
  }

  void _onToggleActions() {
    if (_floatControlVisible) {
      _floatAnimationController?.reverse();
    } else {
      _floatAnimationController?.forward();
    }
    _floatControlVisible = !_floatControlVisible;
  }

  Widget _buildBody(BuildContext context, SgsBrowseLogic logic) {
    bool _smallHorizontal = ui_config.smallLandscape(context);
    bool _mobile = ui_config.isMobile(context);
    Widget mainBody;
    try {
      mainBody = TrackListViewWidget(
        // key: logic.groupKey1,
        tag: TrackGroupLogic.TAG_1,
        site: site,
        scale: _scale,
        tracks: service.paired ? service.selectedTracks.where((t) => !t.isInteractive).toList() : service.selectedTracks,
        session: service.session!,
        chromosomeData: service.chr1!,
        onToggleActions: _onToggleActions,
        onRangeChange: (range, [bool? lastFrame]) => logic.onRangeChange(context, range),
      );
      // 小屏幕设备 或者竖屏
      if (ui_config.portrait(context) || _mobile) {
        mainBody = Stack(
          children: [
            mainBody,
            AlignTransition(
              alignment: _bottomBarAnimation!,
              child: _buildBottomBar(context),
            ),
          ],
        );
      } else if (_smallHorizontal) {
        mainBody = Stack(
          children: [
            mainBody,
            AlignTransition(
              alignment: _leftBarAnimation!,
              child: _buildLeftActionBar(context),
            ),
            AlignTransition(
              alignment: _bottomBarAnimation!,
              child: FloatTrackControlBar(
                orientation: Axis.horizontal,
                onPan: (action) => _mockUserPan(logic.groupLogic, action),
                onZoomChange: (action) {
                  double zoom = actionToZoom(action);
                  double end = zoom < 0 ? 1.0 / math.pow(2, -zoom) : 1.0 * math.pow(2, zoom);
                  _mockUserScale(logic.groupLogic, zoom, Tween(begin: 1.0, end: end));
                },
              ),
            )
          ],
        );
      } else if (service.paired && service.session2 != null && service.chr2 != null) {
        List<Track> interactiveTracks = service.tracks.where((e) => e.isInteractive && e.checked).toList();
        bool hasInteractiveTrack = interactiveTracks.length > 0;
        mainBody = Column(
          children: [
            Expanded(child: mainBody),
            if (service.chr2 != null && hasInteractiveTrack)
              InteractiveGroupWidget(
                key: logic.relationGroupKey,
                tracks: interactiveTracks,
                site: site,
                relationParams: logic.getRelationParams(
                  service.chr1!,
                  service.chr2!,
                  logic.groupLogic?.visibleRange ?? service.session!.range!,
                  service.session2!.range!,
                )..speciesId = service.site!.currentSpeciesId!,
                touchScaling: logic.relationTouching,
              ),
            Divider(height: 4.0, thickness: 4.0, color: Theme.of(context).colorScheme.primary),
            Expanded(
              child: TrackListViewWidget(
                tag: TrackGroupLogic.TAG_2,
                site: site,
                scale: _scale,
                bottomReversed: true,
                tracks: service.paired ? service.selectedTracks.where((t) => !t.isInteractive).toList() : service.selectedTracks,
                session: service.session2!,
                chromosomeData: service.chr2!,
                onToggleActions: _onToggleActions,
                onRangeChange: (range) => logic.onRangeChange2(context, range),
              ),
            ),
            TrackControlBar(
              tag: '2',
              primary: false,
              inIdeMode: widget.inIdeMode,
              site: site,
              chromosome: service.chr2,
              zoomConfig: logic.groupLogic2?.zoomConfig,
              range: service.session2?.range,
              onPan: (action) => _mockUserPan(logic.groupLogic2!, action),
              onZoomChange: (action) {
                double zoom = actionToZoom(action);
                double end = zoom < 0 ? 1.0 / math.pow(2, -zoom) : 1.0 * math.pow(2, zoom);
                _mockUserScale(logic.groupLogic2!, zoom, Tween(begin: 1.0, end: end));
              },
              onZoomToRange: (range) {
                if (range.start >= (service.chr2?.rangeEnd ?? 0)) {
                  BotToast.showSimpleNotification(title: 'start is out of range', align: Alignment(0.0, -1));
                  return;
                }
                if (range.end > service.chr2!.rangeEnd) range.end = service.chr2!.rangeEnd;
                zoomToRange(logic.groupLogic2!, range);
              },
              onTap: (BuildContext c, action, [var data, var data2]) {
                if (action == TrackControlAction.tap_chromosome) {
                  // _showChromosomeListDialog(c);
                  ChromosomeData chr1 = service.chr1!;
                  ChromosomeData chr2 = data;
                  Range range = data2;
                  var event = ChromosomeChangeEvent(chromosome: chr1, range: service.session?.range, chromosome2: chr2, range2: range);
                  service.sendEvent(event);
                }
              },
            ),
          ],
        );
      }
    } catch (e, s) {
      logger.e(s);
      mainBody = Container(
        child: Center(child: Text('${e}')),
      );
    }
    return SafeArea(child: mainBody);
  }

  void zoomToRange(TrackGroupLogic? key, Range range) {
    key?.zoomToRange(range);
  }

  void _mockUserPan(TrackGroupLogic? key, TrackControlAction action) {
    key?.mockUserPan(action);
  }

  void _mockUserScale(TrackGroupLogic? key, double scaleDelta, [Tween<double>? tween, Offset? _point]) {
    key?.mockUserScale(scaleDelta, tween, _point);
  }

  Widget _buildTopActionBar(BuildContext context, TrackSession session, [bool float = true]) {
    bool enabled = true;
    var _actions = [
      Builder(
        builder: (context) {
          return IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: () => _showMoreAction(context, true),
          );
        },
      ),
    ];
    Widget appBar = AppBar(
      titleSpacing: 2,
      title: Row(
        children: [
          _buildSpeciesTitle(context),
          SizedBox(width: 10),
          MaterialButton(
            colorBrightness: Brightness.dark,
            padding: EdgeInsets.symmetric(horizontal: 6),
            minWidth: 10,
            elevation: 0,
            //onPressed: () => _showRangeInputDialog(context),
            onPressed: () => _showChromosomeListDialog(context),
            //icon: Icon(MaterialCommunityIcons.dna, size: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('${session.chrName}', style: TextStyle(fontWeight: FontWeight.w400)),
                Icon(Icons.keyboard_arrow_down, size: 16),
              ],
            ),
          ).tooltip('Select Chromosome'),
        ],
      ),
      actions: _actions,
    );
    if (float) {
      appBar = Container(
        margin: EdgeInsets.symmetric(horizontal: 20),
        height: 56,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: appBar,
        ),
      );
    }
    return appBar;
  }

  void _showMoreAction(BuildContext context, bool showAll) async {
//    bool _tablet = isTablet();
    showAttachedWidget(
      targetContext: context,
      backgroundColor: Colors.black.withAlpha(50),
      attachedBuilder: (cancel) {
        return Material(
//          shape: modelShape(context: context),
          elevation: 6,
          shadowColor: Theme.of(context).colorScheme.primary,
          child: Container(
            constraints: BoxConstraints.tightFor(width: 200),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
//                ListTile(
//                  leading: Icon(MaterialCommunityIcons.file_upload),
//                  title: Text('Custom Track'),
//                  onTap: () => _addCustomTrack(context),
//                ),
                if (showAll)
                  ListTile(
                    leading: Icon(MaterialCommunityIcons.format_list_checks),
                    title: Text('Track List'),
                    onTap: () => _showTrackListFilterModel(context),
                  ),
                if (ui_config.mobilePlatform())
                  ListTile(
                    leading: Icon(MaterialCommunityIcons.phone_rotate_landscape),
                    title: Text('Rotate'),
                    onTap: () {
                      cancel();
                      SgsBrowseLogic.safe()?.toLandscape();
                    },
                  ),
                if (showAll && ui_config.mobilePlatform())
                  ListTile(
                    leading: Icon(MaterialCommunityIcons.qrcode_scan),
                    title: Text('Scan QRCode'),
                    onTap: () {
                      cancel();
                      _scanQrCode(context);
                    },
                  ),

                ListTile(
                  leading: Icon(MaterialCommunityIcons.history),
                  title: Text('Session'),
                  onTap: () => SgsBrowseLogic.safe()?.showSessionWidget(context),
                ),
                if (isMobile(context))
                  ListTile(
                    leading: Icon(MaterialCommunityIcons.share),
                    title: Text('Share Session'),
                    onTap: () => _onShare(context),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _scanQrCode(BuildContext context) async {
    String? qrResult = await MajaScan.startScan(
      title: 'QRCode scanner',
      barColor: Theme.of(context).colorScheme.primary,
      titleColor: Colors.white,
      qRCornerColor: Colors.blue,
      qRScannerColor: Colors.deepPurple,
      flashlightEnable: true,
    );

    String? _url = await validateSessionUrl(qrResult);
    if (_url != null) {
      // ShareSession _shareSession = await ShareSession.fromSessionUrl(_url);
      TrackSession? session = await TrackSession.fromUrl(_url);
      service.sendEvent(LoadSessionEvent(session: session));
    } else {
      showToast(text: 'Url not detected or invalid');
    }
  }

  String gzipDecode(String str) {
    var bytes = base64Url.decode(str);
    var gzipBytes = gzip.decode(bytes);
    return utf8.decode(gzipBytes);
  }

  void _onShare(BuildContext context) async {
    WidgetUtil.showShareDialog(context, SgsAppService.get()!.session);
  }

  void _showSearchWidget(BuildContext context) async {
    var dialog = AlertDialog(
      title: Text('Search'),
      content: Container(
        constraints: BoxConstraints.tightFor(width: 400),
        child: FeatureSearchWidget(
          onResult: (v) {},
        ),
      ),
    );
    var result = await showDialog(context: context, builder: (context) => dialog);
  }

  Widget _buildBottomBar(BuildContext context) {
    bool enabled = true;
    Color _color = Theme.of(context).colorScheme.primary;
    Color _buttonColor = Colors.white;
    double elevation = 3;
    ShapeBorder shape = CircleBorder(side: BorderSide(width: 1, color: Colors.white));
    EdgeInsets _itemPadding = EdgeInsets.symmetric(horizontal: 10, vertical: 10);

    SgsBrowseLogic logic = SgsBrowseLogic.safe()!;

    var _trackActions = [
      Tooltip(
        message: 'Track list',
        child: MaterialButton(
          color: _color,
          shape: shape,
          minWidth: 32,
          height: 40,
          elevation: elevation,
          padding: _itemPadding,
          child: Icon(MaterialCommunityIcons.format_list_checks, color: _buttonColor, size: 16),
          onPressed: () => _showTrackListFilterModel(context),
        ),
      ),
      // Tooltip(
      //   message: 'Chromosome',
      //   child: MaterialButton(
      //     color: _color,
      //     shape: shape,
      //     minWidth: 32,
      //     elevation: elevation,
      //     padding: _itemPadding,
      //     child: Icon(MaterialCommunityIcons.google_chrome, color: _buttonColor, size: 16),
      //     onPressed: () => _showChromosomeListDialog(context),
      //   ),
      // ),
      Tooltip(
        message: 'Theme',
        child: MaterialButton(
          color: _color,
          shape: shape,
          minWidth: 32,
          elevation: elevation,
          padding: _itemPadding,
          child: Icon(MaterialCommunityIcons.draw, color: _buttonColor, size: 16),
          onPressed: _toTrackThemePage,
        ),
      ),
      Tooltip(
        message: 'Search',
        child: MaterialButton(
          color: _color,
          shape: shape,
          minWidth: 32,
          elevation: elevation,
          padding: _itemPadding,
          child: Icon(MaterialCommunityIcons.cloud_search_outline, color: _buttonColor, size: 16),
          onPressed: _toSearchPage,
        ),
      ),
      Tooltip(
        message: 'Session',
        child: MaterialButton(
          color: _color,
          shape: shape,
          minWidth: 32,
          elevation: elevation,
          padding: _itemPadding,
          child: Icon(MaterialCommunityIcons.history, color: _buttonColor, size: 16),
          onPressed: () => logic.showSessionWidget(context),
        ),
      ),
      Tooltip(
        message: 'Highlight',
        child: MaterialButton(
          color: _color,
          shape: shape,
          minWidth: 32,
          elevation: elevation,
          padding: _itemPadding,
          child: Icon(Icons.highlight, color: _buttonColor, size: 16),
          onPressed: () => logic.showHighLightWidget(context),
        ),
      ),
      Tooltip(
        message: 'Cell',
        child: MaterialButton(
          color: _color,
          shape: shape,
          minWidth: 32,
          elevation: elevation,
          padding: _itemPadding,
          child: Icon(MaterialCommunityIcons.chart_scatter_plot, color: _buttonColor, size: 16),
          onPressed: _toCellPage,
        ),
      ),
    ];

    return Container(
      padding: EdgeInsets.symmetric(vertical: 5),
      constraints: BoxConstraints.tightFor(height: 66),
      margin: EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withAlpha(40),
        borderRadius: BorderRadius.circular(10),
      ),
      child: BottomFloatControlWidget(
//        mainAxisSize: MainAxisSize.min,
        labels: ['zoom', 'track'],
        children: [
          Center(
            child: FloatTrackControlBar(
              orientation: Axis.horizontal,
              simple: true,
              onPan: (action) => _mockUserPan(logic.groupLogic, action),
              onZoomChange: (action) {
                double zoom = actionToZoom(action);
                double end = zoom < 0 ? 1.0 / math.pow(2, -zoom) : 1.0 * math.pow(2, zoom);
                _mockUserScale(logic.groupLogic, zoom, Tween(begin: 1.0, end: end));
              },
            ),
          ),
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.min,
              children: _trackActions,
            ),
          ),
        ],
      ),
    );
  }

  void _toCellPage() {
    Navigator.of(context).pushNamed(RoutePath.model_cell);
  }

  void _toTrackThemePage() {
    // Navigator.of(context).pushNamed(RoutePath.model_track_theme);
    showModalBottomSheet(
      context: context,
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * .65),
      showDragHandle: true,
      isScrollControlled: true,
      builder: (c) {
        return TrackThemeSelectorWidget(
          onThemeChange: (trackTheme, trackType) {
            logic.changeTheme(trackTheme, trackType);
          },
        );
      },
    );
  }

  _toSearchPage() {
    // Navigator.of(context).pushNamed(RoutePath.search);
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * .65),
      builder: (c) {
        return SearchSide();
      },
    );
  }

  handleZoom(double scale, Tween<double> tween) {
    SgsBrowseLogic.safe()!.groupLogic?.mockUserScale(scale, tween);
  }

  void _toComparePage(List<CompareItem> items) {
    Navigator.of(context).pushNamed(RoutePath.compare_browser, arguments: items);
  }

  void _showCompareList(BuildContext context) {
    List<CompareItem> compareList = service.compareList;

    Widget contentBuilder([cancel]) {
      return CompareListWidget(
        compareList: compareList,
        onCompare: (list) {
          cancel?.call();
          _toComparePage(list);
        },
      );
    }

    if (isMobile(context)) {
      showModalBottomSheet(
        context: context,
        shape: modelShape(context: context, bottomSheet: true),
        builder: (c) {
          return contentBuilder();
        },
      );
      return;
    }

    showAttachedWidget(
      preferDirection: PreferDirection.bottomCenter,
      targetContext: context,
      attachedBuilder: (cancel) {
        return Material(
          elevation: 8,
          shape: modelShape(),
          color: Theme.of(context).dialogBackgroundColor,
          child: Container(
            constraints: BoxConstraints.tightFor(width: 300, height: 300 * 1.68),
            child: contentBuilder(cancel),
          ),
        );
      },
    );
  }

  void _onModeChange(int index) {
    SgsBrowseLogic.safe()?.groupLogic?.onModeChange(index == 1);
  }

  void _showChromosomeListDialog(BuildContext context) async {
    void _onResult(var result) {
      if (result == null) return;
      List list = result;
      ChromosomeData _chromosome = list[0];
      ChromosomeData _chromosome2 = list[1];
      var event = ChromosomeChangeEvent(chromosome: _chromosome, chromosome2: _chromosome2);
      service.sendEvent(event);
    }

    TrackSession __currentSession = service.session!;
    TrackSession? __currentSession2 = service.session2;
    var result;
    if (ui_config.smallLandscape(context)) {
      showModalHorizontalSheet(
        context: context,
        builder: (c) {
          return Container(
            constraints: BoxConstraints.expand(width: ui_config.sideWidth(context)),
            child: ChromosomeListPage(
              species: __currentSession.speciesId,
              chr: __currentSession.chrId,
              onSelected: (List<ChromosomeData?> value) {
                _onResult(value);
              },
            ),
          );
        },
      );
      return;
    }
    if (ui_config.portrait(context)) {
      result = await Navigator.of(context).pushNamed(
        RoutePath.chromosome_list,
        arguments: {
          'species': __currentSession.speciesId,
          'chr': __currentSession.chrId,
          'chr2': __currentSession2?.chrId,
        },
      );
    } else {
      double _height = MediaQuery.of(context).size.height;
      result = await showDialog(
        context: context,
        builder: (c) {
          return AlertDialog(
            contentPadding: EdgeInsets.zero,
            content: Container(
              constraints: BoxConstraints.tightFor(width: 600, height: _height * .8),
              child: ChromosomeListPage(
                species: __currentSession.speciesId,
                chr: __currentSession.chrId,
                onSelected: (List<ChromosomeData?> value) {
                  Navigator.of(context).pop(value);
                },
              ),
            ),
          );
        },
      );
    }
    _onResult(result);
  }

  void _showTrackListFilterModel(BuildContext context) async {
    _onResult(var result) {
      if (result == null) return;
      var tracks = result as List<Track>;
      service.sendEvent(TrackFilterEvent(tracks: tracks));
    }

    List<Track> _currentTracks = service.selectedTracks;
    if (ui_config.portrait(context) || ui_config.isMobile(context)) {
      var result = await Navigator.of(context).pushNamed(
        RoutePath.track_selector,
        arguments: _currentTracks.map((e) => e.id).toList(),
      );
      _onResult(result);
    } else {
      showModalHorizontalSheet(
        context: context,
        builder: (c) {
          return Container(
            color: Colors.black12,
            constraints: BoxConstraints.expand(width: ui_config.sideWidth(context)),
            child: TrackListSide(),
            // TrackSelectorPage(
            //   onSelected: (values) {
            //     _onResult(values);
            //   },
            // ),
          );
        },
      );
    }
  }

  @override
  void dispose() {
    print('---> dispose browse page');
    _floatAnimationController?.dispose();
    WidgetsBinding.instance.removeObserver(this);
    // logic.shareSessionObserver.removeListener(_onShareSessionListener);
    routeObserver.unsubscribe(this);
    super.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }
}
