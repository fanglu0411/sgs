import 'dart:math' show Random, max, min, pow;
import 'package:bot_toast/bot_toast.dart';
import 'package:dio/dio.dart';
import 'package:flutter_smart_genome/widget/basic/custom_spin.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_genome/base/container_config.dart';
import 'package:flutter_smart_genome/base/ui_config.dart';
import 'package:flutter_smart_genome/bean/feature_beans.dart';
import 'package:flutter_smart_genome/bean/track_param.dart';
import 'package:flutter_smart_genome/bloc/sgs_context/sgs_browse_logic.dart';
import 'package:flutter_smart_genome/bloc/track_config/bloc.dart';
import 'package:d4_scale/d4_scale.dart';
import 'package:flutter_smart_genome/components/json_widget.dart';
import 'package:flutter_smart_genome/components/range_info_widget.dart';
import 'package:flutter_smart_genome/components/setting_config_widget.dart';
import 'package:flutter_smart_genome/d3/color/schemes.dart';
import 'package:flutter_smart_genome/extensions/widget_extensions.dart';
import 'package:flutter_smart_genome/network/adapter/base_feature_adapter.dart';
import 'package:flutter_smart_genome/network/adapter/data_adapter.dart';
import 'package:flutter_smart_genome/network/http_response.dart';
import 'package:flutter_smart_genome/page/cell/cell_page/cell_page_logic.dart';
import 'package:flutter_smart_genome/page/compare/compare_common.dart';
import 'package:flutter_smart_genome/page/home/home_page_drawer_end.dart';
import 'package:flutter_smart_genome/page/maincontainer/track_container.dart';
import 'package:flutter_smart_genome/page/maincontainer/track_container_logic.dart';
import 'package:flutter_smart_genome/page/track/theme/track_theme_selector_widget.dart';
import 'package:flutter_smart_genome/page/track/feature_search_widget.dart';
import 'package:flutter_smart_genome/page/track/track_title_widget.dart';
import 'package:flutter_smart_genome/routes.dart';
import 'package:flutter_smart_genome/service/abs_platform_service.dart';
import 'package:flutter_smart_genome/service/sgs_app_service.dart';
import 'package:flutter_smart_genome/service/sgs_config_service.dart';
import 'package:flutter_smart_genome/side/data_viewer_side.dart';
import 'package:flutter_smart_genome/side/feature_detail_side.dart';
import 'package:flutter_smart_genome/util/debouncer.dart';
import 'package:flutter_smart_genome/util/logger.dart';
import 'package:flutter_smart_genome/util/widget_util.dart';
import 'package:flutter_smart_genome/widget/basic/custom_bot_widget.dart';
import 'package:flutter_smart_genome/widget/sider/horizontal_sider.dart';
import 'package:flutter_smart_genome/widget/track/base/abstract_track_painter.dart';
import 'package:flutter_smart_genome/widget/track/base/base_track_widget.dart';
import 'package:flutter_smart_genome/widget/track/base/style_config.dart';
import 'package:flutter_smart_genome/widget/track/base/track_data.dart';
import 'package:flutter_smart_genome/widget/track/base/layout/track_layout_manager.dart';
import 'package:flutter_smart_genome/widget/track/base/track_menu_config.dart';
import 'package:flutter_smart_genome/widget/track/base/track_theme.dart';
import 'package:flutter_smart_genome/widget/track/base/track_style.dart';
import 'package:flutter_smart_genome/widget/track/cartesian/cartesian_data.dart';
import 'package:flutter_smart_genome/widget/track/cartesian/cartesian_track_painter.dart';
import 'package:flutter_smart_genome/widget/track/cartesian/stack_area_track_painter.dart';
import 'package:flutter_smart_genome/widget/track/cartesian/stack_bar_style_config.dart';
import 'package:flutter_smart_genome/widget/track/cartesian/stack_bar_track_painter.dart';
import 'package:flutter_smart_genome/widget/track/cartesian/stack_data.dart';
import 'package:flutter_smart_genome/widget/track/common.dart';
import 'package:flutter_smart_genome/extensions/string_extensions.dart';
import 'package:dartx/dartx.dart' as dx;
import 'package:get/get.dart';
import 'package:open_file/open_file.dart';

typedef TrackDataParser = List<D> Function<D>(List data);

mixin TrackDataMixin<T extends BaseTrackWidget> on State<T> {
  // TrackParams trackParams;

  bool _loading = false;
  String? _error;
  List? _trackData;

  GlobalKey? _paintKey;
  GlobalKey? _repaintBoundaryKey;

  late Scale<num, num> _linearScale;

  TrackViewType? viewType;

  double trackTotalHeight = 20;

  double get trackMaxHeight => trackStyle.trackMaxHeight.enableValueOrNull ?? 0;

  Debounce? dataDebounce;
  Debounce? _hoverDebounce;
  Debounce? _checkUpdateWidgetDebounce;

  int hoverDelay = 0;

  Map<String, Range>? _fileMap;

  List<String> featureTypes = [];

  /// 一个柱的像素宽度
  double barWidth = 2;

  ///一个block表示的图像宽度
  double blockPixels = 2000;

  bool _stackSumMode = false;

  void set stackSumMode(bool sumMode) => _stackSumMode = sumMode;

  bool get stackSumMode => _stackSumMode;

  Offset? _mousePosition;

  CancelFunc? _simpleInfoCancel;

  Scale<num, num> get linearScale => _linearScale;

  set linearScale(Scale<num, num> linearScale) {
    _linearScale = linearScale;
  }

  List? get trackData => _trackData;

  set trackData(List? data) => _trackData = data;

  bool get loading => _loading;

  set loading(bool loading) => _loading = loading;

  set error(String? error) => _error = error;

  String? get error => _error;

  bool dataRangeChanged = false;

  ScrollController? _scrollController;
  bool mouseInTrack = false;

  GestureDetector? gestureCallback;

  GlobalKey<TrackTitleWidgetState> _trackTitleKey = GlobalKey<TrackTitleWidgetState>();
  CancelToken? cancelToken;

  bool focused = false;
  double cartesianMaxValue = 1000;
  double cartesianMinValue = 1;
  Map? cartesianBlockMap;
  Map<num, Map> _blockMapOfScales = {};

  double blockVisibleScale = 0.05;
  bool forceLoadData = false; // force load data
  double forceLoadFeatureMinScale = 0.0002;

  String? barCoverageKey = null;
  bool _showTrackTitle = true;

  bool get showTrackTitle => _showTrackTitle;

  Random _random = Random();

  List<String>? _stackGroup;

  void set stackGroup(List<String>? groups) => _stackGroup = groups;

  List<String>? get stackGroup => _stackGroup;

  // String cartesianValueType = 'sum';
  TrackStyle _defaultContextStyle = TrackStyle({'dark': {}, 'light': {}})..cartesianValueType = 'sum';

  void set defaultContextStyle(TrackStyle style) {
    _defaultContextStyle = style;
  }

  TrackStyle get defaultContextStyle => _defaultContextStyle;

  TrackParams get trackParams => widget.trackParams;

  TrackTheme get trackTheme {
    SgsBrowseLogic? logic = SgsBrowseLogic.safe();
    return logic!.trackTheme!..brightness = Get.theme.brightness;
    // return BlocProvider.of<SgsContextBloc>(context).trackTheme..brightness = Theme.of(context).brightness;
  }

  /// track 样式配置 合并自定义配置后的结果
  TrackStyle? _trackStyle;

  //获取当前track样式，合并后的结果
  TrackStyle get trackStyle {
    if (null == _trackStyle) {
      var globalTrackStyleCopy = SgsBrowseLogic.safe()!.getTrackStyle(trackParams.trackType)!.copy();
      if (SgsConfigService.get()!.isTrackGrouped(trackParams.track)) {
        customTrackStyle.merge(SgsConfigService.get()!.getGroupedStyle(trackParams.track));
      }
      globalTrackStyleCopy.merge(customTrackStyle);
      _trackStyle = globalTrackStyleCopy;
    }
    return _trackStyle!;
  }

  TrackStyle get customTrackStyle => SgsConfigService.get()!.getCustomTrackStyle(trackParams.track, defaultContextStyle);

  TrackStyle getTrackStyle(TrackType trackType) {
    return trackTheme.getTrackStyle(trackType);
  }

  Color get trackColor {
    Map<String, Color>? cm = SgsConfigService.get()!.getGroupTrackColorMap(trackParams.track);
    return cm?['__auto'] ?? customTrackStyle.trackColor ?? trackStyle.trackColor!;
  }

  Map<String, Color> get colorMap {
    // bool grouped = SgsConfigService.get()!.isTrackGrouped(trackParams.track);
    Map<String, Color>? cm = SgsConfigService.get()!.getGroupTrackColorMap(trackParams.track);
    if (cm != null) return cm;
    if (_stackGroup != null) {
      Map<String, Color>? _colorMap = trackStyle.colorMap;
      if (_colorMap == null || !listEquals(_colorMap.keys.toList(), _stackGroup)) {
        bool dark = Get.isDarkMode;
        List<Color> colors = safeSchemeColor(_stackGroup!.length, s: dark ? .75 : .8, v: dark ? .85 : .85);
        Map<String, Color> _defColorMap = _stackGroup!.asMap().map<String, Color>((idx, key) {
          return MapEntry(key, colors[idx]);
        });
        trackStyle.colorMap = _defColorMap;
        customTrackStyle.colorMap = _defColorMap;
      }
    }
    return trackStyle.colorMap ?? {};
  }

  bool needLoadData() => true;

  void debounceCheckNeedLoadData(T oldWidget) {
    dataDebounce!.run(() {
      checkNeedReloadData(oldWidget).then((value) {
        dataRangeChanged = value;
        logger.d('${trackParams.track.trackName} need load data ${value}');
        if (value && mounted) {
          loadTrackData(false)
              // .onError(_handleDataError)
              .catchError(_onLoadDataError); //todo reset catch
        }
      });
    });
  }

  Future<T> _handleDataError<E extends Object>(E error, StackTrace stackTrace) {
    logger.e(stackTrace);
    throw error;
  }

  Future<bool> checkNeedReloadData(T oldWidget) async {
    logger.d('feature screen Density: ${featureScreenDensity()} -> ${trackParams.track.name}');
    // logger.d('${trackParams.track.trackName} ==> check need reload data ${oldWidget.range}-> ${widget.range}');
    if (_trackData == null || _trackData!.isEmpty) return true;

    if (trackParams.track.isCustom) return false;
    if (widget.touchScaling) return false;

    if (_loading) {
      cancelToken?.cancel('user interrupt');
      await Future.delayed(Duration(milliseconds: 200));
      cancelToken = null;
      // _loading = false;
      _fileMap = {};
      return true;
    }
    // if (oldWidget.range == widget.range) return false;// always true
    TrackViewType _viewType = getTrackViewType();
    logger.d('new type => ${_viewType}');
    if (_viewType != viewType) return true;
    if (_viewType == TrackViewType.cartesian) {
      //todo check block change
      return true;
    } else {
      return await dataBlockChange(oldWidget, _viewType);
    }
    return false;
  }

  Future<bool> dataBlockChange(T oldWidget, TrackViewType viewTypeNew) async {
    Map<String, Range> fileMap = await AbsPlatformService.get()!.findFileNameInRage(
      host: widget.site.url,
      track: trackParams.track,
      range: widget.range,
      species: trackParams.speciesName,
      chr: trackParams.chrId,
      level: viewTypeNew.index + 1,
    );
    if (fileMap.length == 0) {
      return true;
    }
    List<String>? _fileNames = _fileMap?.keys.toList();
    List<String> fileNames = fileMap.keys.toList();
    logger.d('${viewTypeNew} ${trackParams.trackTypeStr} => ${_fileNames} => ${fileNames}');

    if (!listEquals<String>(_fileNames, fileNames) || viewTypeNew != viewType) {
      _fileMap = fileMap;
      return true;
    }
    return false;
  }

  notifyDataViewer({bool needToggle = false, bool expanded = false}) async {
    if (SgsConfigService.get()!.ideMode || isBigScreen(context)) {
      if (needToggle) {
        TrackContainerLogic.safe()?.setSide(SideModel.data, expanded);
        await Future.delayed(Duration(milliseconds: 100));
      }
      if (SgsConfigService.get()!.dataActiveTrack?.id == trackParams.trackId) {
        DataViewerLogic.safe()?.setData(exportData(), track: trackParams.track);
      }
    } else if (isTablet(context)) {
      if (needToggle) {
        Scaffold.maybeOf(context)!.openEndDrawer();
        await Future.delayed(Duration(milliseconds: 260));
        EndDrawerLogic.safe()?.openDataView(trackParams.track);
        // await Future.delayed(Duration(milliseconds: 100));
        DataViewerLogic.safe()?.setData(exportData(), track: trackParams.track);
      }
    } else {
      if (needToggle) {
        Get.toNamed(RoutePath.model_data_table, arguments: trackParams.track);
        await Future.delayed(Duration(milliseconds: 300));
        DataViewerLogic.safe()?.setData(exportData(), track: trackParams.track);
      }
    }
  }

  List exportData() => _trackData ?? [];

  Future loadTrackData([bool isRefresh = false]) async {
    if (!needLoadData()) return;

    cancelToken?.cancel('cancel request track data');
    await Future.delayed(Duration(milliseconds: ((Random().nextDouble() + .1) * 200).toInt()));

    if (!mounted) return;
    TrackViewType _viewType = getTrackViewType();
    // if (trackParams.track.isCustom) {
    //   setState(() {
    //     var data = SgsConfigService.get()!.getLocalTrackData(trackParams.trackId);
    //     _trackData = data['data'];
    //     _loading = false;
    //     viewType = _viewType;
    //   });
    //   return;
    // }
    setState(() {
      _trackTitleKey.currentState?.loading = true;
      if (isRefresh || _viewType != viewType) {
        TrackLayoutManager.clear(trackParams.track);
        _trackData?.clear();
      }
      selectedItem = isRefresh || _viewType != viewType ? null : selectedItem;
      _loading = true;
    });

    Set<String> _featureTypes = Set<String>();
    cancelToken = CancelToken();

    HttpResponseBean<List> response = await dataApi(cancelToken!, _viewType, _featureTypes);
    bool _canceled = response.error?.type == DioExceptionType.cancel;
    List? trackData = response.body;
    featureTypes = _featureTypes.toList();
    _trackTitleKey.currentState?.loading = false;
    if (!mounted) return;
    if (_viewType != viewType || _trackData == null || _trackData!.isEmpty) {
      trackTotalHeight = 0;
    }
    if (!_canceled) {
      _trackData?.clear();
      _trackData = trackData;
    }
    viewType = _viewType;
    onDataLoaded(_trackData);
    setState(() {
      _loading = false;
      _error = _canceled ? null : response.error?.message;
    });
    notifyDataViewer();
  }

  Future<HttpResponseBean<List>> dataApi(CancelToken cancelToken, TrackViewType _viewType, Set<String> _featureTypes) async {
    return AbsPlatformService.get(widget.site)!.loadTrackData(
      host: widget.site.url,
      scale: trackParams.bpPerPixel,
      range: getDataRange(),
      species: trackParams.speciesId,
      track: trackParams.track,
      chr: trackParams.chrId,
      level: getDataLevel(_viewType),
      featureTypes: _featureTypes,
      cancelToken: cancelToken,
      adapter: getFeatureAdapter(_viewType),
    );
  }

  DataAdapter getFeatureAdapter([TrackViewType? type]) {
    return BaseFeatureAdapter(track: trackParams.track, level: getDataLevel(type ?? viewType!));
  }

  void onDataLoaded(List? data) {}

  //the range which need to load data
  Range getDataRange() => widget.range;

  int desiredBarCount() {
    var count = blockPixels ~/ barWidth;
    // if (count > 1024) count = 1024;
    return count;
  }

  int getDataLevel(TrackViewType viewType) {
    return viewType == TrackViewType.cartesian ? 1 : 3;
  }

  List<String> parseFeatureTypes(List data) => [];

  List<D> transformData<D>(List data) {
    return (data).map<D>(dataItemMapper).toList();
  }

  D dataItemMapper<D>(var item) => item;

  void onOtherTrackThemeChange(TrackType trackType) {}

  void onThemeChange() {}

  Widget? _checkInitWidget() {
    if (_trackData == null) return buildTrackOverlay();
    return null;
  }

  Widget? buildLegendWidget() => null;

  Widget trackWidgetWrapper(Widget child) => child;

  bool showMoreInfo(Feature feature) => feature.name != 'null';

  Widget? infoRowItemBuilder(BuildContext context, String key, value) => null;

  bool get showCartesianToolTip => true;

  Feature itemInfoTransform(Feature feature) => feature;

  int get binSize => (barWidth / findTargetScale(this.trackParams)).ceil();

  int get pixelSize => (1 / findTargetScale(this.trackParams)).ceil();

  @override
  void initState() {
    _paintKey = GlobalKey();
    _repaintBoundaryKey = GlobalKey();
    dataDebounce = Debounce(milliseconds: 100);
    _hoverDebounce = Debounce(milliseconds: hoverDelay);
    _checkUpdateWidgetDebounce = Debounce(milliseconds: 50);
    SgsBrowseLogic.safe()!.themeChangeObserver.addListener(_onThemeChange);
    SgsConfigService.get()!.groupStyleNotifier.addListener(_onGroupStyleChange);
    SgsConfigService.get()!.groupedTracksNotifier.addListener(_onGroupTrackListChange);
    super.initState();
    _scrollController = ScrollController();
    _scrollController!.addListener(() {
      onScrollCallback(_scrollController!);
    });
    init(widget.trackParams);
    cartesianBlockMap = calculateBlockMap(trackParams);
    loadTrackData(true)
        // .onError(_handleDataError)
        .catchError(_onLoadDataError); // todo reset catch
    // debounceCheckNeedLoadData();
  }

  void init(TrackParams trackParams) {
    Map statics = trackParams.track.getStatic(trackParams.chrId);
    var totalFeatureCount = statics['feature_count'] ?? trackParams.chr.size / 200.0;
    featureDensity = totalFeatureCount / trackParams.chr.size;
    logger.d(
        '${trackParams.track.trackName} $statics, total feature count ${totalFeatureCount}, feature density: ${featureDensity} feature screen density: ${featureDensity * trackParams.bpPerPixel} chr len: ${trackParams.chr.size}');
    viewType = getTrackViewType();
    initVisibleScale(trackParams);
  }

  @override
  void didUpdateWidget(T oldWidget) {
    super.didUpdateWidget(oldWidget);
    checkDidUpdateWidget(oldWidget);
  }

  late double featureDensity;

  void initVisibleScale(TrackParams trackParams) {
    // num _avgFeatureLength = statics['average_f_length'] ?? trackParams.chr.size / totalFeatureCount; // (totalFeatureCount * 1.0).clamp(100, 200000); // chrLength / totalFeatureCount;
    // var _avgFeatureLengthOfChr = trackParams.chr.size / totalFeatureCount;
    //
    // double visibleScale = _avgFeatureLength < 5 ? 1 : 20.0 / _avgFeatureLength;
    // // double visibleScale = _avgFeatureLength < 5 ? 0.5 : (1000 / (_avgFeatureLength * 50)).clamp(0.001, 0.05);
    // logger.d('visibleScale: $visibleScale， avg feature length: ${_avgFeatureLength}, avg in chr: $_avgFeatureLengthOfChr');
    // // blockVisibleScale = visibleScale;

    var chrSize = trackParams.chr.size;
    if (chrSize >= 1.5 * 100000000) //1.5亿
      blockVisibleScale = 1 / 2500;
    else if (chrSize >= 1 * 100000000) //1亿
      blockVisibleScale = 1 / 5000;
    else if (chrSize >= 50000000)
      blockVisibleScale = 1 / 5000;
    else if (chrSize >= 2 * 10000000) //2千万
      blockVisibleScale = 1 / 2500;
    else if (chrSize >= 1 * 10000000) //1千万
      blockVisibleScale = 1 / 1000;
    else
      blockVisibleScale = 1 / 500;

    forceLoadFeatureMinScale = trackParams.zoomConfig.nextLevel(blockVisibleScale, -1);
    logger.d('featureVisibleScale => $blockVisibleScale');
  }

  void checkDidUpdateWidget(T oldWidget) {
    if (widget.trackParams.chrId != oldWidget.trackParams.chrId || //
        widget.trackParams.speciesId != oldWidget.trackParams.speciesId) {
      _blockMapOfScales.clear();
      init(widget.trackParams);
    }

    double _pixelOfRangeDelta = oldWidget.trackParams.pixelPerBp - widget.trackParams.pixelPerBp;
    if (oldWidget.fixTitle != widget.fixTitle || //
        oldWidget.trackParams.nameKey != widget.trackParams.nameKey || //
        ((_pixelOfRangeDelta.abs() * 10000).floor() > 1)) {
      trackTotalHeight = 0;
    }

    TrackViewType _type = getTrackViewType(widget.trackParams);
    if (!widget.touchScaling) {
      if (_type == TrackViewType.cartesian) {
        cartesianBlockMap = calculateBlockMap(widget.trackParams);
      }
    }

    // print('${trackParams.trackTypeStr} scaling: ${widget.touchScaling},${widget.range}, ${widget.trackParams}');
    if (!widget.touchScaling
        // (oldWidget.trackParams != widget.trackParams || //
        //         oldWidget.range != widget.range) ||
        //     widget.touchScaling != oldWidget.touchScaling
        ) {
      debounceCheckNeedLoadData(oldWidget);
    }
  }

  Future<double> regionStats(Range range) async {
    return statsFromInterval(range: range, interval: 1000, expansionTime: 0, lastTime: DateTime.now().millisecondsSinceEpoch);
  }

  Future<double> _maybeRecordStats({
    required num interval,
    required Range range,
    required int featureCount,
    required double featureDensity,
    required int expansionTime,
    required int lastTime,
  }) async {
    var rangeWidth = range.end - range.start;
    if (featureCount >= 70 || interval * 2 > rangeWidth) {
      return featureDensity;
    } else if (expansionTime <= 5000) {
      var currTime = DateTime.now().millisecondsSinceEpoch;
      expansionTime += (currTime - lastTime);
      lastTime = currTime;
      return statsFromInterval(
        range: range,
        interval: interval * 2,
        expansionTime: expansionTime,
        lastTime: lastTime,
      );
    } else {
      logger.w("Stats estimation reached timeout, or didn't get enough features");
      return double.infinity;
    }
  }

  Future<double> statsFromInterval({required Range range, required num interval, required int expansionTime, required int lastTime}) async {
    double sampleCenter = range.start * 0.75 + range.end * 0.25;
    int queryStart = max(0, (sampleCenter - interval / 2).round());
    int queryEnd = min((sampleCenter - interval / 2).round(), range.end.round());

    int featureCount = 0;
    double featureDensity = featureCount / interval;
    return _maybeRecordStats(
      interval: interval,
      range: range,
      featureCount: featureCount,
      featureDensity: featureDensity,
      expansionTime: expansionTime,
      lastTime: lastTime,
    );
  }

  Future loadBigwigData([bool isRefresh = false]) async {
    try {
      cancelToken?.cancel();
      await Future.delayed(Duration(milliseconds: ((_random.nextDouble() + .1) * 300).toInt()));
      cancelToken = CancelToken();

      TrackViewType _viewType = getTrackViewType();
      // if (_viewType == TrackViewType.cartesian) {
      Range _inflateRange = widget.range;
      int _start = _inflateRange.start.toInt(), _end = _inflateRange.end.toInt(), count;

      _start = widget.range.start.toInt();
      _end = widget.range.end.toInt();
      count = desiredBarCount();

      trackData = isRefresh || _viewType != viewType ? [] : trackData;
      selectedItem = isRefresh || _viewType != viewType ? null : selectedItem;
      loading = true;
      setState(() {});

      HttpResponseBean<List> resp = await AbsPlatformService.get()!.loadBigwigData(
        host: widget.site.url,
        speciesId: trackParams.speciesId,
        track: trackParams.track,
        chr: trackParams.chrId,
        level: getDataLevel(_viewType),
        start: _start,
        end: _end,
        count: count,
        binSize: binSize,
        blockMap: _viewType == TrackViewType.cartesian ? cartesianBlockMap! : calculateExpandsBlockMap(_start, _end),
        cancelToken: cancelToken!,
        valueType: trackStyle.cartesianValueType,
        // ?? 'sum',
        adapter: getFeatureAdapter(_viewType),
      );
      var _data = resp.body;
      if (_data != null && _data.length > 0) {
        var firstValue = _data.first['pValue'] ?? _data.first['value'];
        if (null != firstValue && firstValue is Map) _stackGroup = firstValue.keys.map<String>((e) => '$e').toList();
      }
      if (!mounted) return;
      setState(() {
        loading = false;
        error = resp.error?.message;
        if (_viewType != viewType) trackTotalHeight = 0;
        trackData = _data;
        viewType = _viewType;
        cancelToken = null;
      });
      notifyDataViewer();
    } catch (e, s) {
      if (e is DioException && e.type == DioExceptionType.cancel) {
        logger.e(s);
      } else {
        setState(() {
          loading = false;
          _error = '$e';
          trackData = [];
          cancelToken = null;
        });
      }
    }
  }

  /// 优化速度，只计算当前range的block， 不缓存
  Map calculateBlockMap([TrackParams? params]) {
    TrackParams trackParams = params ?? widget.trackParams;
    double targetScale = findTargetScale(trackParams);
    // if (_blockMapOfScales.containsKey(targetScale)) {
    //   return _blockMapOfScales[targetScale];
    // }
    double fixedBpPerPixel = 1 / targetScale;
    //计算不同缩放尺度下的每一块的长度
    double blockSize = (fixedBpPerPixel * blockPixels).ceilToDouble();

    if (blockSize > trackParams.chr.size) {
      targetScale = trackParams.zoomConfig.nextZoomLevel(targetScale);
      fixedBpPerPixel = 1 / targetScale;
      blockSize = (fixedBpPerPixel * blockPixels).ceilToDouble();
    }

    //分块的总共数量
    int blockCount = (trackParams.chr.size / blockSize).ceil();
    // logger.d('targetScale: ${targetScale}, fixedBpPerPixel: $fixedBpPerPixel, blockSize: $blockSize, blockCount: $blockCount');
    int interval = blockSize ~/ desiredBarCount();

    Map blockMap = {};
    int blockStart = (widget.range.start / blockSize).ceil() - 4, blockEnd = (widget.range.start / blockSize).floor() + 4;
    if (blockStart < 0) blockStart = 0;
    if (blockEnd >= blockCount) blockEnd = blockCount;

    for (int i = blockStart; i < blockEnd; i++) {
      double start = i * blockSize;
      double end = start + blockSize;
      blockMap[i] = {
        'start': start,
        'end': end <= trackParams.chr.rangeEnd ? end : trackParams.chr.rangeEnd,
        // 'end': end,
        'blockSize': blockSize,
        'interval': interval,
        'binSize': interval, //fixedBpPerPixel * 2,
      };
    }
    _blockMapOfScales[targetScale] = blockMap;
    return blockMap;
  }

  ///
  /// create a block map just covering the range
  /// this is usually for the api do not use block, (use start, end)
  /// and this virtual block mapping is to fit cache
  ///
  Map calculateExpandsBlockMap(int start, int end) {
    Range _chrRange = trackParams.chr.range;
    double targetScale = findTargetScale(trackParams);
    double fixedBpPerPixel = 1 / targetScale;
    //计算不同缩放尺度下的每一块的长度
    double blockSize = (fixedBpPerPixel * blockPixels).ceilToDouble();
    Map _blocks = {};
    int _d = start ~/ blockSize;
    num _start = _d * blockSize;
    num _end = _start + blockSize;
    // num interval = (_end - _start) / blockSize;
    _blocks[_d++] = {
      'start': _start,
      'end': _end,
      'blockSize': blockSize,
      // 'interval': interval,
    };
    while (end > _end) {
      _start += blockSize;
      _end += blockSize;
      if (_end > _chrRange.end) _end = _chrRange.end;
      _blocks[_d++] = {
        'start': _start,
        'end': _end,
        'blockSize': _end - _start,
        // 'interval': interval,
      };
      if (_end == _chrRange.end) break;
    }
    return _blocks;
  }

  _onThemeChange() {
    if (trackParams.track.hasChildren) return;
    var s = SgsBrowseLogic.safe()!.themeChangeObserver.value;
    if (s!.trackType == null || s.trackType == trackParams.trackType) {
      var __trackStyle = s.trackTheme!.getTrackStyle(trackParams.trackType).copy();
      __trackStyle.brightness == s.trackTheme!.brightness;
      __trackStyle.merge(customTrackStyle);
      _trackStyle = __trackStyle;
      trackTotalHeight = 0;
      // _trackStyle.merge(__trackStyle);
      // clearCustomTrackStyle();
      setState(onThemeChange);
    } else {
      onOtherTrackThemeChange(s.trackType!);
    }
  }

  /// callback when group style changed
  /// @item source setting item,
  /// @trackId source track id
  _onGroupStyleChange() {
    GroupSettingItem groupItem = SgsConfigService.get()!.groupStyleNotifier.value!;
    if (groupItem.trackId == trackParams.trackId) return;
    // 通知这一组的其他track
    if (SgsConfigService.get()!.isTrackGrouped(trackParams.track)) {
      _onContextMenuItemChanged(groupItem.parentItem, groupItem.settingItem);
      SgsConfigService.get()!.saveCustomTrackStyle(trackParams.track);
    }
  }

  _onGroupTrackListChange() {
    // var groupTracks = SgsConfigService.get().groupedTracksNotifier.value;
    // if (groupTracks.trackId == trackParams.trackId) return;

    if (SgsConfigService.get()!.isTrackGrouped(trackParams.track)) {
      _trackStyle?.merge(SgsConfigService.get()!.getGroupedStyle(trackParams.track));
      trackTotalHeight = 0;
      setState(() {});
    }
  }

  void _onLoadDataError(e) {
    logger.e('${trackParams.trackType}: load track data error: $e');
    if (!mounted) return;
    if (e is DioException && e.type == DioExceptionType.cancel) return;
    setState(() {
      _loading = false;
      _error = '$e';
    });
  }

  void onScrollCallback(ScrollController controller) {}

  void scrollToPosition(double offset) {
    _scrollController?.animateTo(offset, duration: Duration(milliseconds: 500), curve: Curves.easeIn);
  }

  Widget? buildTrackOverlay() {
    if (widget.touchScaling) return null;
    if (_trackData == null || _loading || _error != null) {
      Widget _child;
      if (_error != null) {
        _child = Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error));
      } else
      //if ((_trackData == null || _loading))
      {
        _child = Container(
            constraints: BoxConstraints.tightFor(width: 80, height: 80),
            // padding: EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark ? Colors.black54.withOpacity(.35) : Colors.grey.withOpacity(.45),
              borderRadius: BorderRadius.circular(10),
            ),
            child: CustomSpin(color: Theme.of(context).colorScheme.primary));
      }
      return Container(
        alignment: Alignment.topCenter,
        padding: EdgeInsets.symmetric(vertical: 20),
        constraints: BoxConstraints(minHeight: 80),
        // color: Colors.black12.withAlpha(5),
        child: _child,
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    trackStyle..brightness = Theme.of(context).brightness; //ensure track style init
    customTrackStyle..brightness = Theme.of(context).brightness; //ensure track style init
    Widget _widget = _checkInitWidget() ?? _buildPaint();
    Widget? legendWidget = buildLegendWidget();
    // var children = [_widget, if (legendWidget != null) legendWidget];
    // Widget _trackWidget = children.length > 1 ? Column(mainAxisSize: MainAxisSize.min, children: children) : children.first;
    double _maxHeight = widget.containerHeight ?? trackMaxHeight;
    if (_maxHeight > 0 && trackTotalHeight > _maxHeight) {
      _widget = Container(
        constraints: BoxConstraints.expand(height: _maxHeight),
        child: Column(
          children: [
            Expanded(
              child: Scrollbar(
                interactive: true,
                controller: _scrollController,
                thickness: 24,
                child: SingleChildScrollView(
                  physics: ClampingScrollPhysics(),
                  child: _widget,
                  controller: _scrollController,
                ),
              ),
            ),
            if (legendWidget != null) legendWidget,
          ],
        ),
      );
    } else {
      if (legendWidget != null) {
        _widget = Column(children: [_widget, legendWidget]);
      }
    }
    _widget = trackWidgetWrapper(_widget);
//    return _trackWidget;
    Widget? title = showTrackTitle && !SgsConfigService.get()!.hideAllTitle ? buildTrackTitle() : null;
    return RepaintBoundary(
      key: _repaintBoundaryKey,
      child: Container(
        constraints: widget.fixTitle ? BoxConstraints.expand() : null,
        child: null == title
            ? _widget
            : Stack(children: [
                Padding(
                  padding: EdgeInsets.only(
                    top: trackParams.track.isCombineTrack ? 0 : 22,
                  ),
                  child: _widget,
                ),
                title
              ]),
      ),
    );
  }

  void _checkHover(PointerHoverEvent event) {
    mouseInTrack = true;
    _run() {
      RenderBox box = _paintKey!.currentContext!.findRenderObject()! as RenderBox;
      final _mousePosition = box.globalToLocal(event.position);

      final result = BoxHitTestResult();
      //if no hit, cant return false,
      bool hit = box.hitTest(result, position: _mousePosition); //tap down already hit test

      RenderCustomPaint _customPaint = box as RenderCustomPaint;
      AbstractTrackPainter _painter = _customPaint.painter! as AbstractTrackPainter;
      var _selectedItem = _painter.hitItem;
      if (selectedItem != _selectedItem) {
        //print('hover ${_mousePosition} ${selectedItem?.hashCode} ?= ${_selectedItem?.hashCode}');
        selectedItem = _selectedItem;
        _cursor = _selectedItem != null ? SystemMouseCursors.click : SystemMouseCursors.basic;
        setState(() {});
      }
      // onItemTap(selectedItem, event.position);
    }

    if (viewType == TrackViewType.cartesian || hoverDelay == 0) {
      _run();
    } else {
      _hoverDebounce?.run(_run);
    }
  }

  /// track is grouped change
  void _toggleGroup(bool? grouped) {
    SgsConfigService.get()!.toggleGroupedTrack(trackParams.track, grouped!, customTrackStyle);
    // if (grouped) {
    //   // merge group style to base style
    //   _trackStyle.merge(SgsConfigService.get().groupedStyle);
    //   trackTotalHeight = 0;
    //   setState(() {});
    // }
  }

  Widget? buildTrackTitle() {
    List<Widget> _leftItems = [
      TextButton(
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
          minimumSize: Size(30, 30),
          padding: EdgeInsets.zero,
        ),
        child: Icon(Icons.close, size: 14),
        onPressed: () => widget.eventCallback?.call('hideTrack', trackParams.track),
      ).tooltip(' Hide Track '),
      // if (!trackParams.track.hasChildren)
      //   ValueBuilder<bool>(
      //     initialValue: SgsConfigService.get()!.isTrackGrouped(trackParams.track),
      //     builder: (bool? _grouped, ValueBuilderUpdateCallback<bool> updateFn) {
      //       return TextButton(
      //         style: TextButton.styleFrom(
      //           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
      //           minimumSize: Size(30, 30),
      //           padding: EdgeInsets.zero,
      //         ),
      //         child: Icon(_grouped! ? Icons.library_add_check_rounded : Icons.library_add_check_outlined, size: 14, color: _grouped ? Theme.of(context).colorScheme.primary : null),
      //         onPressed: SgsConfigService.get()!.isTrackGroupAble(trackParams.track) ? () => updateFn.call(!_grouped) : null,
      //       ).tooltip(_grouped ? ' Grouped ' : ' To Group ');
      //     },
      //     onUpdate: _toggleGroup,
      //   ),
      Builder(
        builder: (context) {
          return TextButton(
            style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
              padding: EdgeInsets.symmetric(horizontal: 6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${trackParams.track.name}',
                  style: Theme.of(context).textTheme.labelMedium!.copyWith(fontWeight: FontWeight.w400, height: .8),
                ),
                Icon(Icons.keyboard_arrow_down, size: 14),
              ],
            ),
            onPressed: () {
              showTrackContextMenu(targetContext: context, preferDirection: PreferDirection.rightTop);
            },
          );
        },
      ),
    ];
    return Container(
      constraints: BoxConstraints.tightFor(height: TRACK_TITLE_HEIGHT),
      decoration: BoxDecoration(
        // color: Theme.of(context).colorScheme.primaryLight.withAlpha(100),
        border: (widget.fixTitle || trackParams.track.isCoAccess) ? null : Border(top: BorderSide(color: Theme.of(context).dividerColor, width: 2)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.only(bottomRight: Radius.circular(15)),
            clipBehavior: Clip.antiAlias,
            child: Container(
              color: trackParams.track.pinTop ? Theme.of(context).colorScheme.secondaryContainer.withOpacity(.3) : null,
              child: Row(mainAxisSize: MainAxisSize.min, children: _leftItems),
            ),
          ),
          ...buildTitleActions(),
          // if (viewType == TrackViewType.cartesian)
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 4),
          //   child: Text('PixelSize: ${pixelSize}', style: TextStyle(fontSize: 12)),
          // ),
          if (_loading)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 6),
              child: CustomSpin(size: 20, color: Theme.of(context).colorScheme.primary),
            ),
        ],
      ),
    );
  }

  Widget get forceLoadButton => IconButton(
        color: Colors.orange,
        onPressed: () {
          forceLoadData = true;
          viewType = TrackViewType.block;
          blockVisibleScale = forceLoadFeatureMinScale;
          customTrackStyle.forceVisibleScale = blockVisibleScale;
          SgsConfigService.get()!.saveCustomTrackStyle(trackParams.track);
          loadTrackData(true).catchError(_onLoadDataError);
        },
        padding: EdgeInsets.zero,
        constraints: BoxConstraints.tightFor(width: 36, height: 26),
        tooltip: 'Force load feature',
        icon: Icon(Icons.download_for_offline, size: 20),
      );

  List<Widget> buildTitleActions() {
    if (viewType == TrackViewType.cartesian) {
      Map<String, Color> _colorMap = colorMap;
      return [
        SizedBox(width: 10),
        // ..._colorMap.keys.where((k) => _stackGroup == null || _stackGroup!.contains(k)).map((e) => Tooltip(
        //       message: e,
        //       child: Container(
        //         padding: EdgeInsets.symmetric(horizontal: 2),
        //         constraints: BoxConstraints(minWidth: 18, maxHeight: 17),
        //         alignment: Alignment.center,
        //         decoration: BoxDecoration(
        //           borderRadius: BorderRadius.circular(2),
        //           color: _colorMap[e],
        //         ),
        //         child: Text(e.cut(6), style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w400)),
        //       ),
        //     )),
        // if (trackParams.pixelPerBp >= forceLoadFeatureMinScale) forceLoadButton,
      ];
    }
    return [
//      Builder(builder: (context) {
//        return IconButton(
//          padding: EdgeInsets.symmetric(horizontal: 0),
//          iconSize: 16,
//          icon: Icon(MaterialCommunityIcons.settings),
//          tooltip: 'More settings',
//          onPressed: () {
//            showTrackContextMenu(targetContext: context, preferDirection: PreferDirection.bottomLeft);
//          },
//        );
//      }),
    ];
  }

  dynamic selectedItem;
  dynamic _rootItem;

  bool get visible {
    RenderBox renderBox = _paintKey!.currentContext!.findRenderObject()! as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);
    return true;
  }

  Widget _buildPaint() {
    var painter = getTrackPainter();
    double _trackTotalHeight = painter.maxHeight ?? trackStyle.trackHeight;
    if (widget.containerHeight != null && widget.containerHeight! > 0) {
      _trackTotalHeight = widget.containerHeight!;
      trackTotalHeight = trackTotalHeight > 0 ? min(trackTotalHeight, _trackTotalHeight) : _trackTotalHeight;
    } else {
      trackTotalHeight = max(trackTotalHeight, _trackTotalHeight);
    }
    var constraints = BoxConstraints.expand(height: trackTotalHeight);
    Widget _widget = GestureDetector(
      onLongPressStart: mobilePlatform() ? _onTrackLongPressOrSecondaryPress : null,
      onSecondaryTapUp: mobilePlatform() ? null : _onTrackLongPressOrSecondaryPress,
      onScaleStart: widget.gestureBuilder?.onScaleStart,
      onScaleUpdate: widget.gestureBuilder?.onScaleUpdate,
      onScaleEnd: widget.gestureBuilder?.onScaleEnd,
      onDoubleTap: widget.gestureBuilder?.onDoubleTap,
      onTap: widget.gestureBuilder?.onTap,
      onTapDown: widget.gestureBuilder?.onTapDown,
      onTapUp: (details) {
        RenderBox box = _paintKey!.currentContext!.findRenderObject()! as RenderBox;
        //final offset = box.globalToLocal(details.globalPosition);
        final result = BoxHitTestResult();
        // if no hit, cant return false,
        bool hit = box.hitTest(result, position: details.localPosition); //tap down already hit test

        RenderCustomPaint _customPaint = box as RenderCustomPaint;
        AbstractTrackPainter _painter = _customPaint.painter! as AbstractTrackPainter;
        var _selectedItem = _painter.hitItem;
        var __rootItem = _painter.rootItem;
        _rootItem = __rootItem;
        // print('tap up ${details.localPosition} ${selectedItem?.hashCode} ?= ${_selectedItem?.hashCode} ${_painter.hitRect}');
        if (selectedItem != _selectedItem) {
          selectedItem = _selectedItem;
          // _rootItem = __rootItem;
          setState(() {});
        }
        if (_selectedItem == null) focused = !focused;
        Offset targetPosition = _painter.hitRect != null ? box.localToGlobal(_painter.hitRect!.topCenter) : details.globalPosition;
        onItemTap(selectedItem, targetPosition);
      },
      child: ClipRect(
        child: Container(
          constraints: constraints,
          color: widget.background,
          child: RepaintBoundary(
            child: CustomPaint(
              painter: painter,
              foregroundPainter: getForegroundPainter(),
              key: _paintKey,
              child: buildTrackOverlay(),
            ),
          ),
        ),
      ),
    );
    _widget = MouseRegion(
      // cursor: selectedItem != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      cursor: widget.touchScaling ? SystemMouseCursors.grabbing : SystemMouseCursors.basic,
      child: _widget,
      onHover: _checkHover,
      onExit: (v) {
        selectedItem = null;
        mouseInTrack = false;
        setState(() {});
      },
    );
    return _widget;
  }

  SystemMouseCursor _cursor = SystemMouseCursors.basic;

  void onItemTap(dynamic item, Offset offset) {
    _simpleInfoCancel?.call();
    if (item is CartesianDataItem) {
      if (!showCartesianToolTip) return;
      _simpleInfoCancel = showAttachedWidget(
        preferDirection: PreferDirection.topCenter,
        target: offset + Offset(0, -10),
        attachedBuilder: (cancel) {
          return Material(
            elevation: 8,
            shape: modelShape(radius: 2, color: Theme.of(context).colorScheme.primary),
            child: tooltipBuilder(context, item, cancel),
          );
        },
      );
    } else if (item is Feature) {
      _showFeatureInfo(item);
    }
  }

  void _showFeatureInfo(Feature feature) {
    var featureDetailViewState = FeatureDetailViewState(
      feature,
      _rootItem,
      trackParams.track,
      trackParams.chr,
      trackParams.speciesId,
    );
    if (SgsConfigService.get()!.ideMode || isBigScreen(context)) {
      if (!(TrackContainerLogic.safe()?.sideOpened(SideModel.feature_info) ?? false)) {
        TrackContainerLogic.safe()?.setSide(SideModel.feature_info, true);
        Future.delayed(Duration(milliseconds: 200)).then((value) {
          FeatureDetailLogic.safe()?.setDetail(featureDetailViewState);
        });
      } else {
        FeatureDetailLogic.safe()?.setDetail(featureDetailViewState);
      }
    } else if (isTablet(context) || smallLandscape(context)) {
      showModalHorizontalSheet(
        context: context,
        builder: (c) {
          return Container(
            constraints: BoxConstraints.expand(width: SIDE_WIDGET_WIDTH),
            child: FeatureDetailSide(detailState: featureDetailViewState),
          );
        },
      );
    } else {
      // mobile
      // Navigator.of(context).pushNamed(RoutePath.feature_info, arguments: {
      //   'feature': feature,
      //   'chr': trackParams.chr,
      //   'species': trackParams.speciesId,
      //   'track': trackParams.track,
      // });

      showModalBottomSheet(
        barrierColor: Colors.black38.withAlpha(30),
        isScrollControlled: true,
        context: context,
        builder: (c) {
          return Container(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * .65),
            child: RangeInfoWidget(
              feature: feature,
              chr: trackParams.chr,
              species: trackParams.speciesId,
              track: trackParams.track,
              asPage: false,
            ),
          );
        },
      );
    }
  }

  Widget itemInfoWidgetBuilder(BuildContext context, Feature feature, [cancel]) {
    return Container(
      constraints: BoxConstraints.tightFor(width: 340),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showMoreInfo(feature))
              ListTile(
                title: Text('${feature.name}'),
                trailing: IconButton(
                  icon: Icon(Icons.chevron_right),
                  onPressed: () {
                    if (cancel != null) {
                      cancel();
                    } else {
                      Navigator.of(context).pop();
                    }
                    _showFeatureInfo(feature);
                    // onContextMenuItemTap(SettingItem.button(key: TrackContextMenuKey.range_info), Rect.zero, feature);
                  },
                ),
              ),
            MapInfoWidget(
              data: itemInfoTransform(feature).json,
              itemBuilder: infoRowItemBuilder,
              skipKeys: ['view_type', 'attributes', 'sub_feature', 'children', 'desc'],
              simple: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget tooltipBuilder(BuildContext context, item, cancel) {
    if (item is CartesianDataItem) {
      return Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: Text('${item.tooltip}', style: TextStyle(fontFamily: 'Courier New')),
      );
    }
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Text('${item}', style: TextStyle(fontFamily: 'Courier New')),
    );
  }

  AbstractTrackPainter? findTrackPainter() {
    RenderBox? box = _paintKey!.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return null;
    RenderCustomPaint _customPaint = box as RenderCustomPaint;
    return _customPaint.painter as AbstractTrackPainter?;
  }

  //获取到bounds
  Rect? getTrackViewBounds() {
    RenderBox? box = _paintKey!.currentContext?.findRenderObject() as RenderBox?;
    return box?.paintBounds;
  }

  void _onTrackLongPressOrSecondaryPress(details) {
    if (widget.touchScaling) return;
    RenderBox box = _paintKey!.currentContext!.findRenderObject()! as RenderBox;
    final offset = box.globalToLocal(details.globalPosition);
    final result = BoxHitTestResult();
//        RenderCustomPaint _customPaint = box as RenderCustomPaint;
    bool hit = box.hitTest(result, position: offset);
    RenderCustomPaint _customPaint = box as RenderCustomPaint;
    AbstractTrackPainter painter = _customPaint.painter as AbstractTrackPainter;
    var _selectedItem = painter.hitItem;
    if (isMobile(context)) {
      showTrackContextMenu(
        target: details.globalPosition,
        hitItem: _selectedItem,
        preferDirection: PreferDirection.rightCenter,
      );
    } else {
      showTrackContextMenu(target: details.globalPosition, hitItem: _selectedItem);
    }
  }

  Widget? buildLabel() {
    if (portrait(context)) return null;
    Widget label = Text('${trackParams.track.trackName}');
    if (!isMobile(context)) {
      return Material(
        color: Theme.of(context).canvasColor.withAlpha(180),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: label,
        ),
      );
    }

    return Builder(
      builder: (context) {
        return Material(
          color: Theme.of(context).canvasColor.withAlpha(180),
          child: InkWell(
            onTap: () => showTrackContextMenu(
              targetContext: context,
              preferDirection: PreferDirection.bottomCenter,
              hitItem: null,
            ),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
              child: label,
            ),
          ),
        );
      },
    );
  }

  void showTrackContextMenu({
    Offset? target,
    BuildContext? targetContext,
    var hitItem,
    PreferDirection preferDirection = PreferDirection.rightTop,
  }) async {
    List<SettingItem> menuList = getContextMenuList(hitItem);
    if (null == hitItem) {
      menuList = menuList.whereNot((e) => e.key == TrackContextMenuKey.meta_data).toList();
    }
    var titleItem = menuList.firstOrNullWhere((s) => s.key == TrackContextMenuKey.show_track_title);
    if (null == titleItem) {
      titleItem = TrackMenuConfig.fromKey(TrackContextMenuKey.show_track_title);
      menuList.insert(0, titleItem);
    }

    if (null == hitItem && !trackParams.track.isSubTrack) {
      SettingItem? pinItem = menuList.firstOrNullWhere((s) => s.key == TrackContextMenuKey.pin_top);
      if (pinItem == null) {
        pinItem = TrackMenuConfig.fromKey(TrackContextMenuKey.pin_top);
        menuList.insert(0, pinItem);
      }
      pinItem.value = trackParams.track.pinTop;
    }
    if (null == hitItem) {
      SettingItem? trackInfoItem = menuList.firstOrNullWhere((s) => s.key == TrackContextMenuKey.track_info);
      if (null == trackInfoItem) {
        trackInfoItem = TrackMenuConfig.fromKey(TrackContextMenuKey.track_info);
        menuList.add(trackInfoItem);
      }
    }
    registerContextMenuSettings(menuList);

    bool _mobile = isMobile(context);
    bool _landscape = smallLandscape(context);
    Widget _contentWidget([cancel]) {
      return SettingListWidget(
        settings: menuList,
        onItemChanged: onContextMenuItemChanged,
        onItemTap: (item, rect) {
          cancel?.call();
          if (null == cancel) Navigator.of(context).pop();
          onContextMenuItemTap(item, rect, hitItem);
        },
        onItemHover: onContextMenuItemHover,
      );
    }

    if (portrait(context)) {
      var result = await showModalBottomSheet(
        context: context,
        clipBehavior: Clip.antiAlias,
        shape: modelShape(bottomSheet: _mobile),
        barrierColor: Colors.black12.withAlpha(50),
        builder: (context) => Container(
          child: SingleChildScrollView(child: _contentWidget()),
          constraints: BoxConstraints.expand(),
//          padding: EdgeInsets.symmetric(vertical: 16),
        ),
      );
      return;
    }

    if (target != null && _landscape) {
      target = Offset(target.dx, 30);
    }

    showAttachedWidget(
      target: target,
      targetContext: targetContext,
      preferDirection: preferDirection,
      backgroundColor: Colors.transparent,
      attachedBuilder: (cancel) {
        return Material(
          elevation: 6,
          clipBehavior: Clip.antiAlias,
          // color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(.95),
          shape: modelShape(bottomSheet: _mobile),
          child: Container(
            constraints: BoxConstraints.tightFor(width: _landscape ? 300 : 340),
            child: _contentWidget(cancel),
          ),
        );
      },
    );
  }

  void onMenuChangeCallback(SettingItem? parent, SettingItem item) {}

  bool onContextMenuItemChanged(SettingItem? parentItem, SettingItem item) {
    bool result = _onContextMenuItemChanged(parentItem, item);

    /// notify grouped style change if need
    if (SgsConfigService.get()!.isTrackGrouped(trackParams.track)) {
      SgsConfigService.get()!.mergeCustomStyleToGrouped(trackParams.track);
      SgsConfigService.get()!.groupStyleNotifier.value = GroupSettingItem(trackParams.trackId, item, parentItem: parentItem);
    }
    SgsConfigService.get()!.saveCustomTrackStyle(trackParams.track);
    return result;
  }

  bool _onContextMenuItemChanged(SettingItem? parentItem, SettingItem item) {
    // Map _cm = trackStyle['color_map'] ?? {};
    // if (_cm.containsKey(item.key)) {
    //   Color _color = item.value;
    //   _cm[item.key] = _color;
    //   customTrackStyle.setColorMapEntry(item.key, _color);
    //   setState(() => onMenuChangeCallback(item));
    // } //
    if (parentItem?.key == TrackContextMenuKey.color_map) {
      // trackStyle.colorMap?[item.key] = item.value;
      customTrackStyle.setColorMapEntry(item.key, item.value);
      SgsConfigService.get()?.updateAutoColor(trackParams.track, item.key, item.value);
      setState(() => onMenuChangeCallback(parentItem, item));
    } //
    else if (item.key == TrackContextMenuKey.show_track_title) {
      _showTrackTitle = item.value;
      setState(() => onMenuChangeCallback(parentItem, item));
      return true;
    } //
    else if (item.key == TrackContextMenuKey.pin_top) {
      widget.eventCallback?.call('togglePinTop', trackParams.track..pinTop = item.value);
      return true;
    } //
    else if (item.key == TrackContextMenuKey.track_max_height) {
      trackStyle.trackMaxHeight = EnabledValue(enabled: item.enabled!, value: item.value);
      customTrackStyle.trackMaxHeight = trackStyle.trackMaxHeight;
      // updateTrackStyle(trackStyle);
      setState(() => onMenuChangeCallback(parentItem, item));
      return true;
    } //
    else if (item.key == TrackContextMenuKey.max_value) {
      customTrackStyle.customMaxValue = EnabledValue(enabled: item.enabled!, value: item.value);
      // trackStyle?.customMaxValue = customTrackStyle.customMaxValue;
      setState(() => onMenuChangeCallback(parentItem, item));
      return true;
    } //
    else if (item.key == TrackContextMenuKey.min_value) {
      customTrackStyle.customMinValue = EnabledValue(enabled: item.enabled!, value: item.value);
      // trackStyle?.customMinValue = customTrackStyle.customMinValue;
      setState(() => onMenuChangeCallback(parentItem, item));
      return true;
    }
    //
    else if (item.key == TrackContextMenuKey.active_data_view) {
      SgsConfigService.get()!.dataActiveTrack = trackParams.track;
      notifyDataViewer(needToggle: true, expanded: true);
      return true;
    } else if (item.key == TrackContextMenuKey.stack_chart_split) {
      customTrackStyle.splitChart = item.value;
      trackTotalHeight = 0;
      setState(() => onMenuChangeCallback(parentItem, item));
      return true;
    } else if (item.key == TrackContextMenuKey.cartesian_value_type) {
      trackStyle.cartesianValueType = item.value;
      customTrackStyle.cartesianValueType = item.value;
      trackData?.clear();
      loadTrackData(true).catchError(_onLoadDataError);
      onMenuChangeCallback(parentItem, item);
      return true;
    }
    setState(() {
      if (item.key == TrackContextMenuKey.show_label ||
              item.key == TrackContextMenuKey.show_child_label || //
              item.key == TrackContextMenuKey.track_collapse_mode || //
              item.key == TrackContextMenuKey.track_height ||
              item.key == TrackContextMenuKey.label_font_size ||
              item.key == TrackContextMenuKey.feature_height ||
              item.key == TrackContextMenuKey.bar_width //
          ) {
        TrackLayoutManager.clear(trackParams.track);
        trackTotalHeight = 0;
      }
      trackStyle.fromSetting(item, parent: parentItem, addIfNone: true);
      customTrackStyle.fromSetting(item, parent: parentItem, addIfNone: true);
      if (item.key == TrackContextMenuKey.track_color) {
        SgsConfigService.get()?.updateAutoColor(trackParams.track, '__auto', item.value);
      }
      onMenuChangeCallback(parentItem, item);
    });
    return true;
  }

  List<SettingItem> getContextMenuList(dynamic hitItem) {
    if (hitItem == null) return TrackMenuConfig.basicTrackContextMenus;
    return TrackMenuConfig.basicTrackItemContextMenus;
  }

  AbstractTrackPainter<TrackData, StyleConfig> getBigwigTrackPainter({
    CartesianChartType coverageType = CartesianChartType.bar,
    StackMode stackMode = StackMode.stack,
    bool useSameScale = true,
  }) {
    Brightness _brightness = Theme.of(context).brightness;
    bool _dark = _brightness == Brightness.dark;
    Color _primaryColor = Theme.of(context).colorScheme.primary;

    var maxValue = customTrackStyle.customMaxValue.enableValueOrNull;
    // if (trackParams.track.isMethylation && maxValue == null) maxValue = 1.0;
    //过滤下当前区间
    List<Map> _data = transformData<Map>(trackData ?? []).where((e) => widget.range.collideRange(e['start'], e['end'])).toList();
    EdgeInsets padding = EdgeInsets.only(top: 5, bottom: 5);
    if (trackStyle.cartesianChartType == CartesianChartType.linear || trackStyle.cartesianChartType == CartesianChartType.area) {
      return StackAreaTrackPainter(
        trackData: StackData(
          values: _data,
          dataRange: widget.range,
          hasRange: true,
          scale: widget.scale,
          coverage: barCoverageKey,
          useSameScale: useSameScale,
          track: trackParams.track,
        ),
        styleConfig: StackBarStyleConfig(
          // backgroundColor: widget.background,
          padding: padding,
          brightness: _brightness,
          colorMap: colorMap,
          primaryColor: _primaryColor,
          borderWidth: 1.5,
          selectedColor: _dark ? _primaryColor.withAlpha(50) : _primaryColor.withAlpha(100),
        ),
        height: customTrackStyle.splitChart ? trackStyle.trackHeight * (_stackGroup?.length ?? 1) : trackStyle.trackHeight,
        scale: widget.scale,
        orientation: widget.orientation,
        visibleRange: widget.range,
        selectedItem: selectedItem,
        drawCoverage: false,
        splitMode: customTrackStyle.splitChart,
        coverageStyle: coverageType,
        valueScaleType: trackStyle.valueScaleType,
        areaMode: trackStyle.cartesianChartType == CartesianChartType.area,
        customMaxValue: maxValue,
      );
    }
    //这一层及深度（deeps)）分开绘制，不在这里面
    return StackBarTrackPainter(
      trackData: StackData(
        values: _data,
        dataRange: widget.range,
        hasRange: true,
        scale: widget.scale,
        coverage: barCoverageKey,
        useSameScale: useSameScale,
        track: trackParams.track,
      ),
      styleConfig: StackBarStyleConfig(
        // backgroundColor: widget.background,
        padding: padding,
        brightness: _brightness,
        colorMap: colorMap,
        primaryColor: _primaryColor,
        selectedColor: _dark ? _primaryColor.withAlpha(50) : _primaryColor.withAlpha(100),
      ),
      height: customTrackStyle.splitChart ? trackStyle.trackHeight * (_stackGroup?.length ?? 1) : trackStyle.trackHeight,
      scale: widget.scale,
      orientation: widget.orientation,
      visibleRange: widget.range,
      selectedItem: selectedItem,
      drawCoverage: false,
      splitMode: customTrackStyle.splitChart,
      coverageStyle: coverageType,
      sumMode: stackSumMode,
      valueScaleType: trackStyle.valueScaleType,
      customMaxValue: maxValue,
      stackMode: stackMode,
    );
    // }
    // return null;
  }

  AbstractTrackPainter<TrackData, StyleConfig> getTrackPainter();

  AbstractTrackPainter<TrackData, StyleConfig>? getForegroundPainter() => null;

  double featureScreenDensity([TrackParams? params]) => featureDensity * (params ?? this.trackParams).bpPerPixel;

  double get blockDensityBreak {
    var chrSize = widget.trackParams.chr.size;
    if (chrSize > 100000000) return .3;
    if (chrSize > 50000000) return .3;
    if (chrSize > 10000000) return .32;
    if (chrSize > 5000000) return .32;
    if (chrSize > 1000000) return .35;
    if (chrSize > 100000) return .5;
    return .7;
  }

  TrackViewType getTrackViewType([TrackParams? params]) {
    TrackParams trackParams = params ?? this.trackParams;
    double _featureScreenDensity = featureScreenDensity(trackParams).toPrecision(2);
    // print('_featureScreenDensity: ${_featureScreenDensity}');
    if (_featureScreenDensity > blockDensityBreak) {
      return TrackViewType.cartesian;
    } else if (_featureScreenDensity >= blockDensityBreak / 4) {
      return TrackViewType.block;
    } else {
      return TrackViewType.feature;
    }

    double targetScale = findTargetScale(trackParams);
    double sizeOfPixel = trackParams.bpPerPixel;
    double rangePercent = (widget.range.size / trackParams.chr.size);
    // logger.d('blockVisibleScale: ${blockVisibleScale}, sizeOfPixel: $sizeOfPixel, rangePercent:${rangePercent}, chr size:${trackParams.chr.size}');
    if (trackParams.chr.size < 60000) {
      if (targetScale <= 0.5) {
        return TrackViewType.block;
      }
      return TrackViewType.feature;
    }
    //cartesian -> block -> feature
    var featureVisibleScale = trackParams.zoomConfig.nextLevel(blockVisibleScale, 2);
    //小 -> 中 ->  大
    if (targetScale < blockVisibleScale) {
      return TrackViewType.cartesian;
    } else if (targetScale < featureVisibleScale) {
      return TrackViewType.block;
    } else {
      return TrackViewType.feature;
    }
  }

  double findTargetScale([TrackParams? trackParams]) {
    TrackParams _trackParams = trackParams ?? this.trackParams;
    return _trackParams.zoomConfig.findTargetScale(_trackParams.pixelPerBp);
  }

  void onContextMenuItemHover(SettingItem item, bool enter, Rect? menuRect) {}

  void onContextMenuItemTap(SettingItem item, Rect menuRect, [dynamic target]) async {
    //showToast(text: 'Select ${item.title}');
    if (item.key == TrackContextMenuKey.force_load_feature) {
      viewType = TrackViewType.block;
      forceLoadData = true;
      blockVisibleScale = forceLoadFeatureMinScale;
      customTrackStyle.forceVisibleScale = blockVisibleScale;
      loadTrackData(true).catchError(_onLoadDataError);
      ;
    } else if (item.key == TrackContextMenuKey.active_data_view) {
      SgsConfigService.get()!.dataActiveTrack = trackParams.track;
      notifyDataViewer(needToggle: true, expanded: true);
    } else if (item.key == TrackContextMenuKey.zoom_to_feature) {
      var _feature;
      if (target is Feature) {
        _feature = target;
      } else if (target is CartesianDataItem && target.hasRange) {
        _feature = RangeFeature.onlyRange(Range(start: target.start!, end: target.end!));
      }
      if (_feature != null) widget.onZoomToRange?.call(_feature);
    } //
    else if (item.key == TrackContextMenuKey.range_info) {
      if (target is Feature) {
        _showFeatureInfo(target);
      }
    } else if (item.key == TrackContextMenuKey.save_image) {
//      RenderBox box = _paintKey.currentContext.findRenderObject();
//      RenderCustomPaint _customPaint = box as RenderCustomPaint;
//      AbstractTrackPainter painter = _customPaint.painter;
//      var bytes = await painter.getPng();
//      saveFile(data: bytes, fileName: 'test.png');
      WidgetUtil.widget2Image(
        _repaintBoundaryKey,
        fileName: '${trackParams.speciesName}-${trackParams.chr.chrName}-${trackParams.track.scName ?? trackParams.track.trackName}-${trackParams.track.bioType}',
      );
    } else if (item.key == TrackContextMenuKey.remove_track) {
      // widget.onRemoveTrack?.call(trackParams.track);
      widget.eventCallback?.call('hideTrack', trackParams.track);
    } else if (item.key == TrackContextMenuKey.track_theme) {
      if (SgsConfigService.get()!.ideMode || isBigScreen(context)) {
        // BlocProvider.of<SgsContextBloc>(context).add(SgsContextToggleSideEvent(SideModel.track_theme, true));
        TrackContainerLogic.safe()?.setSide(SideModel.track_theme, true);
      } else if (isTablet(context)) {
        Scaffold.maybeOf(context)!.openEndDrawer();
        // SgsBrowseLogic.safe()?.openEndDrawer(SideModel.cell);
        Future.delayed(Duration(milliseconds: 300)).then((c) {
          EndDrawerLogic.safe()?.openTrackTheme(trackParams.track);
        });
      } else {
        Navigator.of(context).pushNamed(RoutePath.model_track_theme, arguments: trackParams.track.trackType);
      }
      // AbstractTrackPainter trackPainter = findTrackPainter();
      // if (trackPainter != null) {
      //   _showFeatureThemeSideBar();
      // } else {
      //   showToast(text: 'Zoom in to set feature style');
      // }
    } else if (item.key == TrackContextMenuKey.rename_track) {
      await showRenameTrackDialog();
    } else if (item.key == TrackContextMenuKey.meta_data) {
      Feature feature = target;
      double width = MediaQuery.of(context).size.width * .8;
      double height = MediaQuery.of(context).size.height * .8;
      // var dialog = AlertDialog(
      //   contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      //   shape: modelShape(context: context),
      //   title: Text('Metadata'),
      //   scrollable: true,
      //   content: Container(
      //     constraints: BoxConstraints(maxWidth: width, maxHeight: height, minHeight: height, minWidth: width),
      //     child:
      //         //JsonWidget(json: feature.json),
      //         // TreeWidget(treeMap: feature.dataSource, expandAll: true),
      //         SelectableText(
      //       feature.pretty(),
      //       toolbarOptions: ToolbarOptions(copy: true, selectAll: true),
      //     ),
      //   ),
      // );
      // showDialog(context: context, builder: (context) => dialog);

      showModalHorizontalSheet(
        context: context,
        builder: (c) {
          return Container(
            constraints: BoxConstraints.expand(width: 460),
            child: JsonWidget(json: feature.json),
            // TreeWidget(treeMap: feature.dataSource, expandAll: true),
            // SelectableText(
            //   feature.pretty(),
            //   toolbarOptions: ToolbarOptions(copy: true, selectAll: true),
            // ),
          );
        },
      );
    } else if (item.key == TrackContextMenuKey.search) {
      await showSearchDialog();
    } else if (item.key == TrackContextMenuKey.add_compare) {
      CompareItem compareItem = CompareItem(
        item: target,
        speciesName: trackParams.speciesName,
        speciesId: trackParams.speciesId,
        chr: trackParams.chr,
      );
      SgsAppService.get()!.sendEvent(AddCompareItemEvent(compareItem));
    } else if (item.key == TrackContextMenuKey.r_terminal) {
      OpenFile.open('/Applications/iTerm.app');
    } else if (item.key == TrackContextMenuKey.cell_browse) {
      // BlocProvider.of<SgsContextBloc>(context).add(SgsContextToggleSideEvent(SideModel.cell, true));
      if (SgsConfigService.get()!.ideMode || isBigScreen(context)) {
        TrackContainerLogic.safe()?.setSide(SideModel.cell, true);
        Future.delayed(Duration(milliseconds: 300)).then((c) {
          CellPageLogic.safe()!.changeTrack(trackParams.track.parent);
        });
      } else if (isTablet(context)) {
        Scaffold.maybeOf(context)!.openEndDrawer();
        // SgsBrowseLogic.safe()?.openEndDrawer(SideModel.cell);
        Future.delayed(Duration(milliseconds: 300)).then((c) {
          EndDrawerLogic.safe()?.openCell(trackParams.track.parent!);
        });
      } else {
        Navigator.of(context).pushNamed(RoutePath.model_cell, arguments: trackParams.track.parent);
      }
    } else if (item.key == TrackContextMenuKey.track_info) {
      _showTrackInfo();
    }
  }

  void _showTrackInfo() {
    var style = TextStyle(fontFamily: MONOSPACED_FONT, fontFamilyFallback: MONOSPACED_FONT_BACK, height: 1.5);
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: Text('${trackParams.track.name}'),
        content: Container(
          constraints: BoxConstraints(maxWidth: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Name  : ${trackParams.track.name}', style: style),
              Text('Id    : ${trackParams.trackId}', style: style),
              Text('Type  : ${trackParams.trackTypeStr}', style: style),
              if (trackParams.track.isSCTrack) ...[
                Text('scName: ${trackParams.track.scName}', style: style),
                Text('scId  : ${trackParams.track.scId}', style: style),
              ]
            ],
          ),
        ),
      ),
    );
  }

  Future showSearchDialog() async {
    var dialog = AlertDialog(
      title: Text('Search Feature'),
      shape: modelShape(context: context),
      content: Container(
        constraints: BoxConstraints.tightFor(width: 400),
        child: FeatureSearchWidget(
          dataSource: trackData!.cast<Feature>(),
          onResult: (v) async {
            Navigator.of(context).pop(v);
          },
        ),
      ),
    );
    var result = await showDialog(context: context, builder: (context) => dialog);
    if (result != null) {
      Feature feature = result;
      widget.eventCallback?.call('range-change', feature);
    }
  }

  void registerContextMenuSettings(List<SettingItem> settings) async {
    trackStyle.registerSettings(settings);
    SettingItem? maxHeightItem = settings.firstOrNullWhere((s) => s.key == TrackContextMenuKey.track_max_height);
    maxHeightItem?.enabled = trackStyle.trackMaxHeight.enabled;
    maxHeightItem?.value = trackStyle.trackMaxHeight.value;

    SettingItem? maxValueItem = settings.firstOrNullWhere((s) => s.key == TrackContextMenuKey.max_value);
    maxValueItem?.enabled = customTrackStyle.customMaxValue.enabled;
    maxValueItem?.value = customTrackStyle.customMaxValue.value;

    SettingItem? minValueItem = settings.firstOrNullWhere((s) => s.key == TrackContextMenuKey.min_value);
    minValueItem?.enabled = customTrackStyle.customMinValue.enabled;
    minValueItem?.value = customTrackStyle.customMinValue.value;

    SettingItem? item = settings.firstOrNullWhere((e) => e.key == TrackContextMenuKey.active_data_view);
    item?.value = trackParams.trackId == SgsConfigService.get()!.dataActiveTrack?.id;

    SettingItem? splitItem = settings.firstOrNullWhere((e) => e.key == TrackContextMenuKey.stack_chart_split);
    splitItem?.value = customTrackStyle.splitChart;

    var titleItem = settings.firstOrNullWhere((s) => s.key == TrackContextMenuKey.show_track_title);
    titleItem?.value = _showTrackTitle;

    // SettingItem valueTypeItem = settings.firstOrNullWhere((e) => e.key == TrackContextMenuKey.cartesian_value_type);
    // valueTypeItem?.value = trackStyle.cartesianValueType;
  }

  void _showFeatureThemeSideBar() async {
    // RenderBox box = _paintKey.currentContext.findRenderObject();
    // RenderCustomPaint _customPaint = box as RenderCustomPaint;
    // AbstractTrackPainter painter = _customPaint.painter;
    // if (!(painter.styleConfig is FeatureStyleConfig)) return;

    Widget contentBuilder(BuildContext context, [cancel]) {
      return TrackThemeSelectorWidget(
        featureTypes: featureTypes,
        currentFeatureTheme: trackTheme.name.hashCode,
        trackType: trackParams.trackType,
        onThemeChange: (trackTheme, trackType) {
          if (trackType == null || trackType == trackParams.trackType) {
            _trackStyle = trackTheme.getTrackStyle(trackParams.trackType);
            setState(() {});
          }
        },
      );
    }

    if (portrait(context)) {
      var result = await showModalBottomSheet(
        context: context,
        barrierColor: Colors.white.withAlpha(20),
        clipBehavior: Clip.antiAlias,
        shape: modelShape(context: context, bottomSheet: true),
        builder: contentBuilder,
      );
      return;
    }

    showModalHorizontalSheet(
      context: context,
      builder: (c) => Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        constraints: BoxConstraints.expand(width: sideWidth(context)),
        child: contentBuilder(c),
      ),
      barrierColor: Colors.white.withAlpha(20),
    );
  }

  TextEditingController _renameTextController = TextEditingController(text: "");

  Future showRenameTrackDialog() async {
    GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    // TextEditingController _controller = TextEditingController(text: trackParams.track.trackName);
    _renameTextController.text = trackParams.track.trackName;
    String _name = trackParams.track.trackName;
    var dialog = AlertDialog(
      shape: modelShape(context: context),
      title: Text('Rename Track'),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('CANCEL'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 20),
          ),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              Navigator.of(context).pop(_name);
            }
          },
          child: Text('Ok'),
        ),
        SizedBox(width: 10),
      ],
      content: Form(
        key: _formKey,
        child: TextFormField(
          decoration: InputDecoration(
            hintText: 'Input track name',
            labelText: 'Track Name',
            border: inputBorder(),
            suffixIcon: IconButton(
              icon: Icon(Icons.clear),
              iconSize: 16,
              splashRadius: 15,
              padding: EdgeInsets.zero,
              constraints: BoxConstraints.tightFor(width: 30, height: 30),
              onPressed: () {
                _renameTextController.text = "";
              },
            ),
          ),
          controller: _renameTextController,
          autofocus: true,
          validator: (value) {
            if (value!.isEmpty) return 'Name is empty';
            return null;
          },
          onSaved: (value) {
            _name = value!;
          },
          maxLines: 1,
        ),
      ),
    );
    var __name = await showDialog<String>(context: context, builder: (context) => dialog);
    if (__name != null && __name != trackParams.track.trackName) {
      trackParams.track.trackName = __name;
      setState(() {});
    }
  }

  double? prettyNumber(num? maxValue) {
    if (maxValue == null) return null;
    int r = maxValue.floor();
    int e = 0;
    while (r > 10) {
      r ~/= 10;
      e++;
    }
    double interval = e > 1 ? pow(10, e - 1) * 1.0 : 2.0;
    // num delta = maxValue % interval;
    int tickerCount = maxValue ~/ interval + 1;
    double _maxValue = interval * tickerCount;
    if (_maxValue == 0) return null;
    return _maxValue;
  }

  @override
  void dispose() {
    logger.d('track widget dispose ->${trackParams.trackTypeStr}-> ${trackParams.track.trackName}');
    cancelToken?.cancel('${trackParams.track.name} -> dispose');
    _renameTextController.dispose();
    _scrollController?.dispose();
    dataDebounce?.dispose();
    SgsBrowseLogic.safe()?.themeChangeObserver.removeListener(_onThemeChange);
    SgsConfigService.get()?.groupStyleNotifier.removeListener(_onGroupStyleChange);
    SgsConfigService.get()?.groupedTracksNotifier.removeListener(_onGroupTrackListChange);
    BotToast.cleanAll();
    super.dispose();
    _trackData?.clear();
    _trackData = null;
  }
}
