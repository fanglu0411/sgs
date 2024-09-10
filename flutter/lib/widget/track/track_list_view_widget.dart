import 'package:bot_toast/bot_toast.dart';
import 'package:dartx/dartx.dart' as dx;
import 'package:flutter_smart_genome/widget/basic/custom_bot_widget.dart';
import 'package:flutter_smart_genome/widget/basic/custom_spin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/base/ui_config.dart';
import 'package:flutter_smart_genome/bean/feature_beans.dart';
import 'package:flutter_smart_genome/bean/site_item.dart';
import 'package:flutter_smart_genome/bean/track_param.dart';
import 'package:flutter_smart_genome/bloc/track_config/bloc.dart';
import 'package:d4_scale/d4_scale.dart';
import 'package:flutter_smart_genome/d3/d3_mixin.dart';
import 'package:flutter_smart_genome/mixin/view_size_mixin.dart';
import 'package:flutter_smart_genome/service/sgs_app_service.dart';
import 'package:flutter_smart_genome/util/logger.dart';
import 'package:flutter_smart_genome/widget/basic/scroll_top_button.dart';
import 'package:flutter_smart_genome/widget/split_widget.dart';
import 'package:flutter_smart_genome/widget/track/bam_coverage/bam_coverage_track_widget.dart';
import 'package:flutter_smart_genome/widget/track/bam_reads/bam_reads_track_widget.dart';
import 'package:flutter_smart_genome/widget/track/base/base_track_widget.dart';
import 'package:flutter_smart_genome/widget/track/base/empty_track_widget.dart';
import 'package:flutter_smart_genome/widget/track/base/track_session.dart';
import 'package:flutter_smart_genome/widget/track/base/track_data.dart';
import 'package:flutter_smart_genome/widget/track/bed/bed_track_widget.dart';
import 'package:flutter_smart_genome/widget/track/bigwig/bigwig_track_widget.dart';
import 'package:flutter_smart_genome/widget/track/cell_expression/cell_exp_track_widget.dart';
import 'package:flutter_smart_genome/widget/track/cross_overlay/cross_overlay_widget.dart';
import 'package:flutter_smart_genome/widget/track/eqtl/eqtl_track_widget.dart';
import 'package:flutter_smart_genome/widget/track/group_coverage/group_coverage_track_widget.dart';
import 'package:flutter_smart_genome/widget/track/grouped/grouped_parent_track_widget.dart';
import 'package:flutter_smart_genome/widget/track/hic/hic_track_widget.dart';
import 'package:flutter_smart_genome/widget/track/methylation/methylation_track_widget.dart';
import 'package:flutter_smart_genome/widget/track/peak/co_access_track_widget.dart';
import 'package:flutter_smart_genome/widget/track/peak/peak_track_widget.dart';
import 'package:flutter_smart_genome/widget/track/relation/relation_track_widget.dart';
import 'package:flutter_smart_genome/widget/track/ruler/chr_global_ruler_widget.dart';
import 'package:flutter_smart_genome/widget/track/chromosome/chromosome_data.dart';
import 'package:flutter_smart_genome/widget/track/common.dart';
import 'package:flutter_smart_genome/widget/track/ruler/chr_local_ruler_widget.dart';
import 'package:flutter_smart_genome/widget/track/ruler/ruler_area_indicator.dart';
import 'package:flutter_smart_genome/widget/track/sequence/sequence_track_widget.dart';
import 'package:flutter_smart_genome/widget/track/simple/range_track_widget.dart';
import 'package:flutter_smart_genome/widget/track/track_group_logic.dart';
import 'package:flutter_smart_genome/widget/track/vcf/vcf_track_widget.dart';
import 'package:flutter_smart_genome/widget/track/vcf_sample/vcf_sample_track_widget.dart';
import 'package:flutter_smart_genome/extensions/widget_extensions.dart';
import 'package:get/get.dart';

class TrackListViewWidget extends StatefulWidget {
  final ChromosomeData chromosomeData;
  final double scale;
  final TrackSession session;
  final List<Track>? tracks;
  final ValueChanged<Range>? onRangeChange;
  final SiteItem site;
  final VoidCallback? onToggleActions;
  final TrackWidgetEventCallback? eventCallback;
  final bool bottomReversed;
  final String tag;

  TrackListViewWidget({
    Key? key,
    required this.site,
    required this.chromosomeData,
    required this.session,
    required this.scale,
    this.tracks = const [],
    this.onRangeChange,
    this.onToggleActions,
    this.eventCallback,
    this.bottomReversed = false,
    this.tag = 'group1',
  }) : super(key: key);

  @override
  TrackListViewWidgetState createState() => TrackListViewWidgetState();
}

class TrackListViewWidgetState extends State<TrackListViewWidget> with TickerProviderStateMixin, ViewSizeMixin, WidgetsBindingObserver {
  AnimationController? _animationController;
  Animation<double>? _animation;
  Animation<Offset>? _panAnimation;
  Animation<AlignmentGeometry>? _topBarAnimation;
  Animation<AlignmentGeometry>? _rightBarAnimation;
  Animation<AlignmentGeometry>? _bottomBarAnimation;

  Map<String, GlobalKey> trackKeyMap = {};

  AnimationController? _floatAnimationController;
  ScrollController? _trackScrollController;
  GlobalKey<ScrollTopButtonState>? _scrollButtonKey;

  late TrackGroupLogic logic;

  @override
  void initState() {
    super.initState();
    var _logic = TrackGroupLogic.safe(tag: widget.tag);
    if (_logic != null) {
      logic = _logic;
      logic.init(widget);
    } else {
      logic = _logic ?? Get.put(TrackGroupLogic(widget), tag: widget.tag);
    }
    _scrollButtonKey = GlobalKey<ScrollTopButtonState>();
    _trackScrollController = ScrollController();
    _trackScrollController!.addListener(() {
      ScrollPosition _position = _trackScrollController!.position;
      _scrollButtonKey!.currentState?.setOpacity((_position.pixels / _position.maxScrollExtent).clamp(0.0, 1.0));
    });
    _animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 800));
    _floatAnimationController = AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    _topBarAnimation = AlignmentTween(begin: Alignment(0, -1.15), end: Alignment(0, -.98)).animate(_floatAnimationController!);
    _rightBarAnimation = AlignmentTween(begin: Alignment(1.25, .75), end: Alignment(.95, .75)).animate(_floatAnimationController!);
    _bottomBarAnimation = AlignmentTween(begin: Alignment(0, 1.15), end: Alignment(0, .95)).animate(_floatAnimationController!);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didUpdateWidget(TrackListViewWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    logic.didUpdateWidget(widget, oldWidget);
  }

  @override
  void didChangePlatformBrightness() {
    // logger.d('system change brightness');
    // BlocProvider.of<SgsContextBloc>(context).setBrightness(Theme.of(context).brightness);
  }

  @override
  Widget build(BuildContext context) {
    if (null == widget.tracks) {
      return Center(child: CustomSpin(color: Theme.of(context).colorScheme.primary));
    }
    return GetBuilder<TrackGroupLogic>(
      id: 'id-${widget.tag}',
      tag: widget.tag,
      init: logic,
      global: true,
      builder: (logic) {
        return LayoutBuilder(
          builder: (context, constraints) {
            logic.initIfNeed(context, constraints.biggest);
            return _buildTrackGroups(constraints.biggest, logic);
          },
        );
      },
    );
  }

  GlobalKey getTrackKey(TrackParams trackParams) {
    String key = '${trackParams.key}-${Theme.of(context).brightness}';
    if (!trackKeyMap.containsKey(key)) {
      trackKeyMap[key] = GlobalKey(debugLabel: key);
    }
    return trackKeyMap[key]!;
  }

  List<Widget> _buildTrackWidgets(List<Track> tracks) {
    Iterable<List<Widget>> widgets = tracks.map<List<Widget>>((track) {
      Color bgColor = Theme.of(context).scaffoldBackgroundColor;
      return <Widget>[
        _buildTrack(track, bgColor),
        if (track.hasChildren) ..._buildTrackWidgets(track.checkedChildren),
      ];
    });
    return widgets.flatten().toList();
  }

  void eventCallback<String, Object>(type, data) {
    switch (type) {
      case 'range-change':
        Feature feature = data;
        logic.onZoomToRange(feature);
        break;
      case 'toggleSplitMode':
        logic.toggleSplitMode();
        break;
      case 'hideTrack':
        Track _track = data;
        // _track.checked = false;
        // widget.tracks?.remove(_track);
        // setState(() {});
        SgsAppService.get()!.sendEvent(ToggleTrackSelectionEvent(_track, false));
        break;
      case 'togglePinTop':
        Track _track = data;
        int maxCount = mobilePlatform() ? 3 : 4;
        if (_track.pinTop && widget.tracks!.where((t) => t.pinTop).length >= maxCount) {
          showToast(text: 'Pin top track max count reached');
          _track.pinTop = false;
          return;
        }
//        _track.pinTop = !_track.pinTop;
        setState(() {});
        break;
    }
  }

  Widget _buildTrackGroups(Size size, TrackGroupLogic logic) {
    List<Track> _pinedTracks = widget.tracks!.where((t) => t.pinTop).toList();
    List<Track> _restTracks = widget.tracks!.where((t) => !t.pinTop).map((t) => [t, if (t.hasChildren) ...t.checkedChildren]).flatten().toList();

    List<Widget> _pinTopTrackWidgets = _buildTrackWidgets(_pinedTracks);

    bool _smallHorizontalScreen = smallLandscape(context);
    double _rulerSize = _smallHorizontalScreen ? 22 : 22;
    double _globalRulerSize = _smallHorizontalScreen ? 12 : 16;

    List<Widget> _rulerTracks = <Widget>[
      ClipRect(
        child: GlobalChrRulerWidget(
          tag: widget.tag,
          width: _globalRulerSize,
          trackData: widget.chromosomeData,
          visibleRange: logic.visibleRange,
          orientation: logic.trackOrientation,
          scale: logic.createScale(widget.chromosomeData.range, logic.viewSize),
          onRangeChange: logic.onRangeChangeManual,
        ),
      ),
      RulerAreaIndicator(
        // global -> local link area
        height: 30,
        range: logic.visibleRange,
        pixedRange: (logic.visibleRange.size / logic.viewSize).round(),
        scale: logic.createScale(widget.chromosomeData.range, logic.viewSize),
      ),
      ClipRect(
        child: Container(
          constraints: logic.trackOrientation == Axis.vertical
              ? BoxConstraints.expand(width: _rulerSize) //
              : BoxConstraints.expand(height: _rulerSize),
          child:
              // LocalRulerWidget(
              //   timeline: logic.timeline,
              //   orientation: logic.trackOrientation,
              //   linearScale: logic.linearScale,
              //   tag: logic.tag,
              //   cursor: logic.crossoverPositionNotifier.value.hover,
              // ),
              LocalChrRulerWidget(range: logic.visibleRange, scale: logic.linearScale!),
          // child: LocalChrRulerWidget(trackData: , trackLine: logic.timeline,),
        ),
      ),
    ];

    Widget trackScrollList = CustomScrollView(
      scrollDirection: Axis.vertical,
      controller: _trackScrollController,
      physics: ClampingScrollPhysics(),
      slivers: [
        if (_restTracks.length == 0)
          SliverToBoxAdapter(
              child: logic.gestureWrapper(
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
              ),
              constraints: BoxConstraints.expand(height: 200),
              alignment: Alignment.center,
              child: Text('No Track Selected!', style: Theme.of(context).textTheme.titleLarge),
            ),
          )),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => _buildTrack(_restTracks[index], Theme.of(context).scaffoldBackgroundColor),
            childCount: _restTracks.length,
          ),
        ),
        SliverFillRemaining(
          hasScrollBody: false,
          child: logic.gestureWrapper(
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
              ),
              padding: EdgeInsets.symmetric(vertical: 20),
              alignment: Alignment.bottomCenter,
              child: Text(
                '----- The End -----',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).dividerColor,
                    ),
              ),
            ),
          ),
        )
      ],
    );
    // trackScrollList = _withListener(trackScrollList);
    Widget columns = Column(
      children: [
        if (!widget.bottomReversed) ..._rulerTracks,
        ..._pinTopTrackWidgets,
        Stack(
          children: [
            trackScrollList,
            IgnorePointer(
              // show cursor
              child: Container(
                constraints: BoxConstraints.expand(),
                child: CrossOverlayWidget(tag: widget.tag),
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: ScrollTopButton(
                key: _scrollButtonKey,
                opacity: (_trackScrollController!.hasClients ? _trackScrollController!.offset / 300 : 0.0).clamp(0.0, 1.0),
                onPressed: () {
                  _trackScrollController!.animateTo(0, duration: Duration(milliseconds: 300), curve: Curves.decelerate);
                },
              ),
            ),
          ],
        ).expand(),
        if (widget.bottomReversed) ..._rulerTracks,
      ],
    );
    return logic.withListener(columns, context);
  }

  Widget _buildTrack(Track track, Color background, {double? maxHeight}) {
    var trackParams = logic.createTrackParams(track, widget.chromosomeData);
    var range = logic.visibleRange.copy();
//    if (track.isCustom) {
//      return CustomTrackWidget(
//        key: getTrackKey(trackParams),
//        site: widget.site,
//        scale: _linearScaleByRange,
//        range: _visibleRange,
//        trackParams: trackParams,
//        background: background,
//        orientation: _trackOrientation,
//        onRemoveTrack: _onRemoveTrack,
//        onZoomToRange: _onZoomToRange,
//        gestureBuilder: _gestureDetector,
//        eventCallback: _eventCallback,
//      );
//    }

    if (track.isVcfSample) {
      bool _dark = Theme.of(context).brightness == Brightness.dark;
      return VcfSampleTrackWidget(
        key: getTrackKey(trackParams),
        fixTitle: logic.splitMode && widget.tracks!.length > 1,
        maxHeight: maxHeight,
        site: widget.site,
        scale: logic.linearScaleByRange!,
        range: range,
        trackParams: trackParams,
        touchScaling: logic.touchScaling,
        background: _dark ? Colors.black12 : Colors.white24,
        orientation: logic.trackOrientation,
        onRemoveTrack: logic.onRemoveTrack,
        onZoomToRange: logic.onZoomToRange,
        gestureBuilder: logic.gestureDetector,
        eventCallback: eventCallback,
      );
      // return Container(height: 30);
    }

    if (track.isVcfCoverage) {
      return VcfTrackWidget(
        key: getTrackKey(trackParams),
        fixTitle: logic.splitMode && widget.tracks!.length > 1,
        maxHeight: maxHeight,
        site: widget.site,
        scale: logic.linearScaleByRange!,
        range: range,
        trackParams: trackParams,
        touchScaling: logic.touchScaling,
        background: background,
        orientation: logic.trackOrientation,
        onRemoveTrack: logic.onRemoveTrack,
        onZoomToRange: logic.onZoomToRange,
        gestureBuilder: logic.gestureDetector,
        eventCallback: eventCallback,
      );
    }

    if (track.isBed) {
      return BedTrackWidget(
        key: getTrackKey(trackParams),
        fixTitle: logic.splitMode && widget.tracks!.length > 1,
        maxHeight: maxHeight,
        site: widget.site,
        scale: logic.linearScaleByRange!,
        range: range,
        trackParams: trackParams,
        touchScaling: logic.touchScaling,
        touchScale: logic.touchScale,
        background: background,
        orientation: logic.trackOrientation,
        onRemoveTrack: logic.onRemoveTrack,
        onZoomToRange: logic.onZoomToRange,
        gestureBuilder: logic.gestureDetector,
        eventCallback: eventCallback,
      );
    }
    if (track.isBigWig) {
      return BigWigTrackWidget(
        key: getTrackKey(trackParams),
        fixTitle: logic.splitMode && widget.tracks!.length > 1,
        maxHeight: maxHeight,
        site: widget.site,
        scale: logic.linearScaleByRange!,
        range: range,
        trackParams: trackParams,
        touchScaling: logic.touchScaling,
        background: background,
        orientation: logic.trackOrientation,
        onRemoveTrack: logic.onRemoveTrack,
        onZoomToRange: logic.onZoomToRange,
        gestureBuilder: logic.gestureDetector,
        eventCallback: eventCallback,
      );
    }
    if (track.isReference) {
      return SequenceTrackWidget(
        site: widget.site,
        fixTitle: logic.splitMode && widget.tracks!.length > 1,
        maxHeight: maxHeight,
        scale: logic.linearScaleByRange!,
        range: range,
        trackParams: trackParams,
        background: background,
        orientation: logic.trackOrientation,
        gestureBuilder: logic.gestureDetector,
        touchScaling: logic.touchScaling,
        eventCallback: eventCallback,
      );
    }

    if (track.isBamCoverage) {
      return BamCoverageTrackWidget(
        key: getTrackKey(trackParams),
        fixTitle: logic.splitMode && widget.tracks!.length > 1,
        maxHeight: maxHeight,
        site: widget.site,
        scale: logic.linearScaleByRange!,
        range: range,
        trackParams: trackParams,
        touchScaling: logic.touchScaling,
        background: background,
        orientation: logic.trackOrientation,
        onRemoveTrack: logic.onRemoveTrack,
        onZoomToRange: logic.onZoomToRange,
        gestureBuilder: logic.gestureDetector,
        eventCallback: eventCallback,
      );
    }
    if (track.isBamReads) {
      return BamReadsTrackWidget(
        key: getTrackKey(trackParams),
        fixTitle: logic.splitMode && widget.tracks!.length > 1,
        maxHeight: maxHeight,
        site: widget.site,
        scale: logic.linearScaleByRange!,
        range: range,
        trackParams: trackParams,
        touchScaling: logic.touchScaling,
        background: background,
        orientation: logic.trackOrientation,
        onRemoveTrack: logic.onRemoveTrack,
        onZoomToRange: logic.onZoomToRange,
        gestureBuilder: logic.gestureDetector,
        eventCallback: eventCallback,
      );
    }

    if (track.isGff) {
      return RangeTrackWidget(
        key: getTrackKey(trackParams),
        fixTitle: logic.splitMode && widget.tracks!.length > 1,
        maxHeight: maxHeight,
        site: widget.site,
        scale: logic.linearScaleByRange!,
        range: range,
        trackParams: trackParams,
        touchScaling: logic.touchScaling,
        background: background,
        orientation: logic.trackOrientation,
        onRemoveTrack: logic.onRemoveTrack,
        onZoomToRange: logic.onZoomToRange,
        gestureBuilder: logic.gestureDetector,
        eventCallback: eventCallback,
      );
    }
    if (track.isMethylation) {
      return MethylationTrackWidget(
        key: getTrackKey(trackParams),
        fixTitle: logic.splitMode && widget.tracks!.length > 1,
        maxHeight: maxHeight,
        site: widget.site,
        scale: logic.linearScaleByRange!,
        range: range,
        trackParams: trackParams,
        touchScaling: logic.touchScaling,
        background: background,
        onRemoveTrack: logic.onRemoveTrack,
        onZoomToRange: logic.onZoomToRange,
        gestureBuilder: logic.gestureDetector,
        eventCallback: eventCallback,
      );
    }

    if (track.isCellExp) {
      return CellExpTrackWidget(
        key: getTrackKey(trackParams),
        fixTitle: logic.splitMode && widget.tracks!.length > 1,
        maxHeight: maxHeight,
        site: widget.site,
        scale: logic.linearScaleByRange!,
        range: range,
        trackParams: trackParams,
        touchScaling: logic.touchScaling,
        background: background,
        orientation: logic.trackOrientation,
        onRemoveTrack: logic.onRemoveTrack,
        onZoomToRange: logic.onZoomToRange,
        gestureBuilder: logic.gestureDetector,
        eventCallback: eventCallback,
      );
    }

    if (track.isCombineTrack) {
      return GroupedTrackWidget(
        key: getTrackKey(trackParams),
        fixTitle: logic.splitMode && widget.tracks!.length > 1,
        maxHeight: 20,
        site: widget.site,
        scale: logic.linearScaleByRange!,
        range: range,
        trackParams: trackParams,
        touchScaling: logic.touchScaling,
        background: background,
        orientation: logic.trackOrientation,
        onRemoveTrack: logic.onRemoveTrack,
        onZoomToRange: logic.onZoomToRange,
        gestureBuilder: logic.gestureDetector,
        eventCallback: eventCallback,
      );
    }

    if (track.isPeak) {
      return PeakTrackWidget(
        key: getTrackKey(trackParams),
        fixTitle: logic.splitMode && widget.tracks!.length > 1,
        maxHeight: maxHeight,
        site: widget.site,
        scale: logic.linearScaleByRange!,
        range: range,
        trackParams: trackParams,
        touchScaling: logic.touchScaling,
        background: background,
        orientation: logic.trackOrientation,
        onRemoveTrack: logic.onRemoveTrack,
        onZoomToRange: logic.onZoomToRange,
        gestureBuilder: logic.gestureDetector,
        eventCallback: eventCallback,
      );
    }
    if (track.isCoAccess) {
      return CoAccessTrackWidget(
        key: getTrackKey(trackParams),
        fixTitle: logic.splitMode && widget.tracks!.length > 1,
        maxHeight: maxHeight,
        site: widget.site,
        scale: logic.linearScaleByRange!,
        range: range,
        trackParams: trackParams,
        touchScaling: logic.touchScaling,
        background: background,
        orientation: logic.trackOrientation,
        onRemoveTrack: logic.onRemoveTrack,
        onZoomToRange: logic.onZoomToRange,
        gestureBuilder: logic.gestureDetector,
        eventCallback: eventCallback,
      );
    }
    if (track.isGroupCoverage) {
      return GroupCoverageTrackWidget(
        key: getTrackKey(trackParams),
        fixTitle: logic.splitMode && widget.tracks!.length > 1,
        maxHeight: maxHeight,
        site: widget.site,
        scale: logic.linearScaleByRange!,
        range: range,
        trackParams: trackParams,
        touchScaling: logic.touchScaling,
        background: background,
        orientation: logic.trackOrientation,
        onRemoveTrack: logic.onRemoveTrack,
        onZoomToRange: logic.onZoomToRange,
        gestureBuilder: logic.gestureDetector,
        eventCallback: eventCallback,
      );
    }

    if (track.isInteractive) {
      return RelationTrackWidget(
        key: getTrackKey(trackParams),
        fixTitle: logic.splitMode && widget.tracks!.length > 1,
        maxHeight: maxHeight,
        site: widget.site,
        scale: logic.linearScaleByRange!,
        range: range,
        trackParams: trackParams,
        touchScaling: logic.touchScaling,
        background: background,
        orientation: logic.trackOrientation,
        onRemoveTrack: logic.onRemoveTrack,
        onZoomToRange: logic.onZoomToRange,
        gestureBuilder: logic.gestureDetector,
        eventCallback: eventCallback,
      );
    }

    if (track.isHic) {
      return HicTrackWidget(
        key: getTrackKey(trackParams),
        fixTitle: logic.splitMode && widget.tracks!.length > 1,
        maxHeight: maxHeight,
        site: widget.site,
        scale: logic.linearScaleByRange!,
        range: range,
        trackParams: trackParams,
        touchScaling: logic.touchScaling,
        background: background,
        orientation: logic.trackOrientation,
        onRemoveTrack: logic.onRemoveTrack,
        onZoomToRange: logic.onZoomToRange,
        gestureBuilder: logic.gestureDetector,
        eventCallback: eventCallback,
      );
    }

    if (track.isEqtl) {
      return EQTLTrackWidget(
        key: getTrackKey(trackParams),
        fixTitle: logic.splitMode && widget.tracks!.length > 1,
        maxHeight: maxHeight,
        site: widget.site,
        scale: logic.linearScaleByRange!,
        range: range,
        trackParams: trackParams,
        touchScaling: logic.touchScaling,
        background: background,
        orientation: logic.trackOrientation,
        onRemoveTrack: logic.onRemoveTrack,
        onZoomToRange: logic.onZoomToRange,
        gestureBuilder: logic.gestureDetector,
        eventCallback: eventCallback,
      );
    }

    return EmptyTrackWidget(
      key: getTrackKey(trackParams),
      fixTitle: logic.splitMode && widget.tracks!.length > 1,
      maxHeight: maxHeight,
      site: widget.site,
      scale: logic.linearScaleByRange!,
      range: range,
      trackParams: trackParams,
      touchScaling: logic.touchScaling,
      background: background,
      orientation: logic.trackOrientation,
      onRemoveTrack: logic.onRemoveTrack,
      gestureBuilder: logic.gestureDetector,
      // eventCallback: eventCallback,
      label: 'Track of type: ${trackParams.track.bioType} is not implemented',
    );
  }

  @override
  void dispose() {
    logger.d('dispose');
    WidgetsBinding.instance.removeObserver(this);
    // Get.delete<TrackGroupLogic>(tag: widget.tag);
    _floatAnimationController?.dispose();
    _animationController?.dispose();
    _trackScrollController?.dispose();
    super.dispose();
  }
}
