import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_genome/base/container_config.dart';
import 'package:flutter_smart_genome/base/ui_config.dart';
import 'package:flutter_smart_genome/bean/site_item.dart';
import 'package:flutter_smart_genome/bloc/track_config/track_config_event.dart';
import 'package:flutter_smart_genome/page/maincontainer/track_container.dart';
import 'package:flutter_smart_genome/page/session/session_logic.dart';
import 'package:flutter_smart_genome/page/session/session_widget.dart';
import 'package:flutter_smart_genome/page/track/track_control_bar/track_control_bar_logic.dart';
import 'package:flutter_smart_genome/routes.dart';
import 'package:flutter_smart_genome/service/sgs_app_service.dart';
import 'package:flutter_smart_genome/side/highlight_side.dart';
import 'package:flutter_smart_genome/storage/base_store_provider.dart';
import 'package:flutter_smart_genome/util/debouncer.dart';
import 'package:flutter_smart_genome/widget/basic/custom_bot_widget.dart';
import 'package:flutter_smart_genome/widget/relation/base/relation_params.dart';
import 'package:flutter_smart_genome/widget/track/base/track_data.dart';
import 'package:flutter_smart_genome/widget/track/base/track_session.dart';
import 'package:flutter_smart_genome/widget/track/base/track_style.dart';
import 'package:flutter_smart_genome/widget/track/base/track_theme.dart';
import 'package:flutter_smart_genome/widget/track/chromosome/chromosome_data.dart';
import 'package:flutter_smart_genome/widget/track/common.dart';
import 'package:flutter_smart_genome/widget/track/cross_overlay/cross_overlay_logic.dart';
import 'package:flutter_smart_genome/widget/track/interactive_group_widget.dart';
import 'package:flutter_smart_genome/widget/track/track_group_logic.dart';
import 'package:flutter_smart_genome/widget/track/track_list_view_widget.dart';
import 'package:get/get.dart';

class ThemeNotifyValue {
  TrackTheme? trackTheme;
  TrackType? trackType;

  ThemeNotifyValue(this.trackTheme, [this.trackType]);
}

class SgsBrowseLogic extends GetxController {
  //
  GlobalKey<InteractiveGroupWidgetState>? relationGroupKey;
  late GlobalKey<TrackListViewWidgetState>? groupKeyLandscape;

  Key groupKey1 = Key('group1');

  bool _isLandscape = false;

  bool get isLandscape => _isLandscape;

  late Debounce _debounce;
  TrackTheme? _trackTheme;

  TrackTheme? get trackTheme => _trackTheme;

  TrackSession? _session;

  TrackSession? get session => _session;

  bool _loading = true;

  bool get loading => _loading;

  ShareSession? _shareSession;

  ShareSession? get shareSession => _shareSession;

  set shareSession(ShareSession? shareSession) => _shareSession = shareSession;

  void set loading(bool loading) => _loading = loading;

  String? _error;

  String? get error => _error;

  set error(String? e) => _error = e;

  bool get ready => (!_loading) && _error == null;

  late ValueNotifier<ThemeNotifyValue?> themeChangeObserver;

  // late ValueNotifier<TrackSession?> shareSessionObserver;

  TrackGroupLogic? get groupLogic => TrackGroupLogic.safe(tag: TrackGroupLogic.TAG_1);

  TrackGroupLogic? get groupLogic2 => TrackGroupLogic.safe(tag: TrackGroupLogic.TAG_2);

  static SgsBrowseLogic _ins = SgsBrowseLogic._init();

  factory SgsBrowseLogic() {
    return _ins;
  }

  @override
  void onReady() {
    super.onReady();
    // SgsAppService.get()?.sendEvent(TrackBasicEvent(session: null));
  }

  SgsBrowseLogic._init() {
    _debounce = Debounce(milliseconds: 5 * 1000);
    initTheme();
    relationGroupKey = GlobalKey<InteractiveGroupWidgetState>();
    groupKeyLandscape = GlobalKey<TrackListViewWidgetState>();
    themeChangeObserver = ValueNotifier<ThemeNotifyValue?>(ThemeNotifyValue(_trackTheme));
    // shareSessionObserver = ValueNotifier<TrackSession?>(null);
  }

  initTheme() {
    _trackTheme = BaseStoreProvider.get().getCurrentTrackTheme();
    _trackTheme?.brightness = Get.theme.brightness;
  }

  static SgsBrowseLogic? safe() {
    if (Get.isRegistered<SgsBrowseLogic>()) {
      return Get.find<SgsBrowseLogic>();
    }
    return null;
  }

  void setData({bool loading = false, String? error = null, TrackSession? session}) {
    _session = session;
    _loading = loading;
    _error = error;
    update();
  }

  void toLandscape() {
    _isLandscape = true;
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);
  }

  void toPortrait() {
    _isLandscape = false;
    SystemChrome.restoreSystemUIOverlays();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  void onSiteSpeciesChange(BuildContext context, SiteItem site) {
    SgsAppService.get()!.changeSiteSpecies(site);
  }

  void showSessionWidget(BuildContext context) async {
    TrackGroupLogic? trackGroupLogic = TrackGroupLogic.safe();
    var result;
    if (isMobile(context)) {
      // result = await Get.toNamed(RoutePath.session, arguments: trackGroupLogic?.session);
      result = showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * .65),
        builder: (c) {
          return SessionWidget(currentSession: trackGroupLogic?.session);
        },
      );
    } else {
      double _h = MediaQuery.of(context).size.height;
      result = await showDialog(
        context: context,
        builder: (c) {
          return AlertDialog(
            title: Text('Session'),
            content: Container(
              constraints: BoxConstraints.tightFor(width: 800, height: _h * .65),
              child: SessionWidget(currentSession: trackGroupLogic!.session),
            ),
          );
        },
      );
    }
    if (result != null) {
      TrackSession session = result;
      _onTrackSessionItemTap(context, session);
    }
  }

  void showHighLightWidget(BuildContext context) {
    var result = showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (c) {
        double _h = MediaQuery.of(context).size.height;
        return Container(constraints: BoxConstraints(maxHeight: _h * .65), child: HighlightSide());
      },
    );
  }

  void _onTrackSessionItemTap(BuildContext context, TrackSession session) {
    SgsAppService.get()!.loadSession(session);
  }

  TrackStyle? getTrackStyle(TrackType trackType) {
    return _trackTheme?.getTrackStyle(trackType);
  }

  void changeTheme(TrackTheme trackTheme, TrackType? trackType, [bool notify = true]) {
    _trackTheme = trackTheme;

    if (notify) {
      themeChangeObserver.value = ThemeNotifyValue(_trackTheme, trackType);
    }

    if (trackType == null) {
      BaseStoreProvider.get().setCurrentTrackTheme(trackTheme);
    } else {
      _debounceStoreTrackTheme();
    }
  }

  void jumpToPositionByChrName(String chrName, Range range, BuildContext context) async {
    var chrList = SgsAppService.get()!.chromosomes;
    var chr = chrList!.firstWhereOrNull((chr) => chr.chrName == chrName);
    if (chr == null) {
      showToast(text: 'Can not zoom to range, ${chrName} not found!');
      return;
    }
    jumpToPosition(chr.id, range, context);
  }

  Future jumpToPosition(String chrId, Range range, BuildContext context, {Track? track}) async {
    if (track != null && !track.checked) {
      SgsAppService.get()!.sendEvent(ToggleTrackSelectionEvent(track, true));
      await Future.delayed(Duration(milliseconds: 500));
    }
    if (chrId == SgsAppService.get()!.chr1!.id) {
      groupLogic!.zoomToGene(range);
    } else if (chrId == SgsAppService.get()!.chr2?.id) {
      groupLogic2!.zoomToGene(range);
    } else {
      var chrList = SgsAppService.get()!.chromosomes;
      var chr = chrList!.firstWhereOrNull((chr) => chr.id == chrId);
      if (null == chr) {
        showToast(text: 'Can not zoom to range, chr not found!');
        return;
      }
      var result = await showDialog(
          context: context,
          builder: (c) {
            var span = TextSpan(
              style: Theme.of(context).textTheme.displayMedium!.copyWith(fontSize: 16),
              children: [
                TextSpan(text: 'Go to position: '),
                TextSpan(
                  text: '${chr.chrName}:${range.print('...')}',
                  style: TextStyle(color: Theme.of(context).colorScheme.primary, fontFamily: MONOSPACED_FONT),
                ),
              ],
            );
            return AlertDialog(
              title: RichText(text: span),
              actions: [
                OutlinedButton(onPressed: () => Navigator.pop(c, false), child: Text('NO')),
                ElevatedButton(onPressed: () => Navigator.pop(c, true), child: Text('YES')),
              ],
            );
          });
      if (result != null && result) {
        // var _range = range.inflate(range.size);
        var _range = range.copy();
        if (_range.start < chr.rangeStart) {
          _range.start = chr.rangeStart.toDouble();
        }
        if (_range.end > chr.rangeEnd) {
          _range.end = chr.rangeEnd.toDouble();
        }
        var event = ChromosomeChangeEvent(chromosome: chr, range: _range, chromosome2: SgsAppService.get()!.chr2, range2: SgsAppService.get()!.session2?.range);
        SgsAppService.get()!.sendEvent(event);
        CrossOverlayLogic.safe()?.addFlashRange(range);
      }
    }
  }

  void zoomToRange(Range range) {
    groupLogic!.zoomToGene(range);
  }

  void _debounceStoreTrackTheme() {
    _debounce.run(() {
      BaseStoreProvider.get().setTrackTheme(trackTheme!);
    });
  }

  bool get relationTouching =>
      (groupLogic?.touchScaling ?? false) || //
      (groupLogic2?.touchScaling ?? false);

  void onRangeChange(BuildContext context, Range range) {
    TrackControlBarLogic.safe('1')?.updateRange(range);
    SessionLogic.find()?.currentSession = groupLogic!.session;

    var service = SgsAppService.get()!;
    relationGroupKey?.currentState?.updateParams(
      getRelationParams(
        service.chr1!,
        service.chr2!,
        range,
        groupLogic2!.visibleRange,
      )..speciesId = service.site!.currentSpeciesId!,
      relationTouching,
    );
  }

  void onRangeChange2(BuildContext context, Range range) {
    TrackControlBarLogic.safe('2')?.updateRange(range);
    var bloc = SgsAppService.get()!;
    relationGroupKey?.currentState?.updateParams(
      getRelationParams(
        bloc.chr1!,
        bloc.chr2!,
        groupLogic!.visibleRange,
        range,
      )..speciesId = bloc.site!.currentSpeciesId!,
      relationTouching,
    );
  }

  RelationParams getRelationParams(ChromosomeData chr1, ChromosomeData chr2, Range range1, Range range2) {
    return RelationParams(
      // speciesId: site.currentSpeciesId,
      chr1: chr1,
      range1: range1,
      sizeOfPixel1: groupLogic!.sizeOfPixel!,
      pixelPerSeq1: groupLogic!.pixelOfRange!,
      zoomConfig1: groupLogic!.zoomConfig!,
      scale1: groupLogic!.linearScale!,
      chr2: chr2,
      range2: range2,
      sizeOfPixel2: groupLogic2?.sizeOfPixel,
      pixelPerSeq2: groupLogic2?.pixelOfRange,
      zoomConfig2: groupLogic2?.zoomConfig,
      scale2: groupLogic2?.linearScale,
    );
  }

  void resetKeys() {
    relationGroupKey = GlobalKey<InteractiveGroupWidgetState>();
  }

  @override
  void onClose() {
    _debounce.dispose();
    themeChangeObserver.dispose();
    // shareSessionObserver.dispose();
    // groupKey1 = null;
    relationGroupKey = null;
    super.onClose();
  }

  void openEndDrawer(SideModel cell) {}
}
