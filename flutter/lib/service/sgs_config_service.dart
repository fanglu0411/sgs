import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide AxisDirection;
import 'package:flutter_smart_genome/base/app_layout.dart';
import 'package:flutter_smart_genome/bean/highlight_range.dart';
import 'package:flutter_smart_genome/bloc/sgs_context/sgs_browse_logic.dart';
import 'package:flutter_smart_genome/components/setting_config_widget.dart';
import 'package:flutter_smart_genome/components/window/multi_window_controller.dart';
import 'package:flutter_smart_genome/entry/entry_logic.dart';
import 'package:flutter_smart_genome/page/maincontainer/track_container_logic.dart';
import 'package:flutter_smart_genome/page/setting/track_curve.dart';
import 'package:flutter_smart_genome/page/site/site_logic.dart';
import 'package:flutter_smart_genome/service/public_service.dart';
import 'package:flutter_smart_genome/service/sgs_app_service.dart';
import 'package:flutter_smart_genome/storage/base_store_provider.dart';
import 'package:flutter_smart_genome/storage/hive/box_manager.dart';

import 'package:flutter_smart_genome/util/common.dart';
import 'package:flutter_smart_genome/util/debouncer.dart';
import 'package:flutter_smart_genome/util/device_info.dart';
import 'package:flutter_smart_genome/util/lru_cache.dart';
import 'package:flutter_smart_genome/util/random_color/random_file.dart';
import 'package:flutter_smart_genome/widget/track/cartesian/axis_direction.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show join;
import 'package:flutter_smart_genome/bean/admin_manage_beans.dart';
import 'package:flutter_smart_genome/bean/site_item.dart';
import 'package:flutter_smart_genome/widget/track/base/track_data.dart';
import 'package:flutter_smart_genome/widget/track/base/track_style.dart';
import 'package:get/get.dart';

class GroupSettingItem {
  final String trackId;
  final SettingItem settingItem;
  final SettingItem? parentItem;

  const GroupSettingItem(this.trackId, this.settingItem, {this.parentItem});
}

class GroupTracks {
  final String? trackId;
  List<String> tracks = [];

  GroupTracks(this.trackId, this.tracks);
}

class SgsConfigService extends GetxService {
  bool _cellTableScrolled = false;

  bool get cellTableScrolled => _cellTableScrolled;

  void set cellTableScrolled(bool v) => _cellTableScrolled = v;

  /// get the config service instance
  static SgsConfigService? get() {
    if (Get.isRegistered<SgsConfigService>()) {
      return Get.find<SgsConfigService>();
    }
    return null;
  }

  late AppLayout appLayout;

  late String applicationSupportPath;
  late String applicationDocumentsPath;
  late String applicationDownloadPath;
  late String externalCachePath;
  late String userDirectory;

  Map _localeTrackData = {};

  bool ideMode = true;
  late bool trackAnimation;
  late Curve trackAnimationCurve;

  Map<String, TrackStyle> _customTrackStyleMap = {};

  Track? dataActiveTrack;

  bool altPressed = false;
  bool ctrlPressed = false;
  bool shiftPressed = false;

  List<CustomTrack> _customTracks = [];

  List<CustomTrack> get customTracks => _customTracks;

  UserBean? _user;

  UserBean? get user => _user;

  String get userId => _user?.id ?? 'test01';

  ThemeMode get themeMode => PublicService.get()!.themeMode;

  ThemeData? get themeData => PublicService.get()!.themeData;

  ThemeData? get darkThemeData => PublicService.get()!.darkThemeData;

  bool _ready = false;

  bool get ready => _ready;

  Debounce? _debounce;
  Debounce? _groupedTracksDebounce;

  String? _speciesId;

  // List<String> _groupedTracks = [];
  // TrackStyle? _groupedStyle;
  Map<String, TrackStyle> _groupedStyleByType = {};

  TrackStyle? getGroupedStyle(Track track) => _groupedStyleByType[_groupedTypeKey(track)];

  Rx<TrackType?> _groupedTrackTypeRx = Rx(null);

  // Rx<TrackType?> get groupedTrackTypeRx => _groupedTrackTypeRx;

  // Set<String> _groupedTrackList = Set<String>();

  ValueNotifier<GroupTracks> _groupedTracksNotifier = ValueNotifier<GroupTracks>(GroupTracks(null, []));

  ValueNotifier<GroupTracks> get groupedTracksNotifier => _groupedTracksNotifier;

  // int get groupedCount => _groupedTrackList.length;

  ValueNotifier<GroupSettingItem?> _groupStyleNotifier = ValueNotifier<GroupSettingItem?>(null);

  ValueNotifier<GroupSettingItem?> get groupStyleNotifier => _groupStyleNotifier;

  LruCache<String, Map>? _imageInfoCache;

  bool _hideAllTitle = false;

  bool get hideAllTitle => _hideAllTitle;

  void set hideAllTitle(bool hide) => _hideAllTitle = hide;

  TrackAxisDirection _axisDirection = TrackAxisDirection.center;

  TrackAxisDirection get axisDirection => _axisDirection;

  void set axisDirection(TrackAxisDirection hide) => _axisDirection = hide;

  Map<String, Map<String, Color>> _groupedTrackColor = {};

  List<HighlightRange> getHighlights() {
    List<HighlightRange> highlights = BaseStoreProvider.get().getHighlights();
    var session = SgsAppService.get()!.session;
    return highlights.where((h) => h.serverId == session!.siteId && h.speciesId == session.speciesId).toList();
  }

  AppConfigService() {
    _customTracks = [];
  }

  @override
  void onInit() {
    super.onInit();
    init();
  }

  @override
  void onReady() {
    super.onReady();
  }

  Future init() async {
    _ready = false;
    _speciesId = null;
    ideMode = BaseStoreProvider.get().getIdeMode();
    trackAnimation = BaseStoreProvider.get().getTrackAnimation();
    trackAnimationCurve = curveMap.values.first;
    if (null == _debounce) _debounce = Debounce(milliseconds: 3000);
    if (null == _groupedTracksDebounce) _groupedTracksDebounce = Debounce(milliseconds: 3000);

    _imageInfoCache?.clear();
    _imageInfoCache = LruCache();

    await BaseStoreProvider.get().checkAndInitTrackTheme();

    if (!kIsWeb) {
      // MemoryCache.externalCachePath = (await getExternalCacheDirectories()).first.path;
      applicationSupportPath = (await getApplicationSupportDirectory()).path;
      applicationDocumentsPath = join((await getApplicationDocumentsDirectory()).path, 'sgs');
      applicationDownloadPath = await _getDownloadPath();
      userDirectory = getUserDirectory().path;
    }
    appLayout = await BaseStoreProvider.get().getAppLayout();

    int themeIndex = BaseStoreProvider.get().getThemeColor();
    await PublicService.get()!.init();
    await PublicService.get()!.setTheme(themeIndex, BaseStoreProvider.get().getThemeMode());

    // await DioHelper().checkCacheSize();
    // await checkCacheSize();

    await Future.delayed(Duration(milliseconds: 200));
    _ready = true;
    EntryLogic.get().show();
  }

  String get dataCachePath => join(applicationDocumentsPath, '_cache');

  void cacheImage(String id, Map imageInfo) {
    _imageInfoCache?.save(id, imageInfo);
  }

  Map? getImage(String id) {
    return _imageInfoCache?.get(id);
  }

  Future<String> _getDownloadPath() async {
    if (DeviceOS.isAndroid) {
      return join((await getExternalStorageDirectory())!.path, 'Download');
    }
    String? download = (await getDownloadsDirectory())?.path;
    if (download == null) {
      Directory docPath = (await getApplicationDocumentsDirectory());
      download = join(docPath.parent.path, 'Downloads');
      Directory downloadDir = Directory(download);
      if (!downloadDir.existsSync()) {
        downloadDir.createSync();
      }
    }
    return download;
  }

  //dio
  Future<int> checkFileCacheSize() async {
    if (kIsWeb) return -1;
    var file = Directory(dataCachePath);
    if (!file.existsSync()) return 0;
    return _countFileSize(file);
  }

  int _countFileSize(FileSystemEntity file) {
    if (file is File) {
      return file.lengthSync();
    }
    int _total = 0;
    if (file is Directory) {
      for (FileSystemEntity f in file.listSync(recursive: false)) {
        _total += _countFileSize(f);
      }
    }
    return _total;
  }

  ///deprecated cache by hive is deprecated. use file cache instead
  checkCacheSize() async {
    if (kIsWeb) return;

    var cacheFilePath = join(SgsConfigService.get()!.applicationDocumentsPath, 'dio_cache.hive');
    var file = File(cacheFilePath);
    if (!file.existsSync()) return;

    var s = await file.stat();
    var max = 1 * 1000 * 1000; //* 1000;
    if (s.size > max) {
      // await clearCache();
      await file.delete();
      var cacheLockFilePath = join(SgsConfigService.get()!.applicationDocumentsPath, 'dio_cache.lock');
      var lockFile = File(cacheLockFilePath);
      if (lockFile.existsSync()) {
        await lockFile.delete();
      }
    }
  }

  void setSiteSpecies(SiteItem site) {
    if (_speciesId == site.currentSpeciesId) return;

    _debounce?.run(_saveCustomTrackStyle, milliseconds: 0);
    _groupedTracksDebounce?.run(_saveGroupedTracks, milliseconds: 0);

    _customTrackStyleMap = BaseStoreProvider.get().getCustomTrackStyles(site.currentSpeciesId) ?? {};
    _groupedStyleByType = BaseStoreProvider.get().getGroupedTrackStyleMap(site.currentSpeciesId!);
    // _groupedStyle = BaseStoreProvider.get().getGroupedTrackStyle(site.currentSpeciesId)?.copy();
    // _groupedTrackList = Set.from(BaseStoreProvider.get().getGroupedTracks(site.currentSpeciesId));
    _speciesId = site.currentSpeciesId;
    // _groupedTrackTypeRx.value = _groupedTrackList.length > 0 ? SgsAppService.get()!.tracks.firstWhereOrNull((t) => t.id == _groupedTrackList.first)?.trackType : null;
    // setGroupedTrackColor();
  }

  /// change theme color
  void changeTheme(int i) {
    PublicService.get()!.changeTheme(i);

    ///通知其他窗口
    multiWindowController.notifyWindowCall(WindowType.dataManager, WindowCallEvent.changeTheme.name, i);
  }

  /// change theme mode
  void changeThemeMode(int i) {
    PublicService.get()!.changeThemeMode(i);
    // EntryLogic.get().show();
  }

  void addCustomTrack(CustomTrack track) {
    _customTracks.add(track);
  }

  bool find(CustomTrack track) {
    int index = _customTracks.indexWhere((element) => element.url == track.url);
    return index >= 0;
  }

  void changeAppLayout(AppLayout layout) {
    appLayout = layout;
    TrackContainerLogic.safe()!.changeAppLayout(layout);
    BaseStoreProvider.get().setAppLayout(layout);
  }

  addLocalTrackData(String key, var data) {
    _localeTrackData[key] = data;
  }

  getLocalTrackData(String key) {
    return _localeTrackData[key];
  }

  void removeCustomTrackStyle(Track track) {
    if (_customTrackStyleMap.containsKey(track.id)) {
      _customTrackStyleMap.remove(track.id);
    }
  }

  TrackStyle getCustomTrackStyle(Track track, [TrackStyle? defTrackStyle]) {
    if (null == _customTrackStyleMap[track.id]) {
      _customTrackStyleMap[track.id!] = defTrackStyle ?? TrackStyle.empty(Brightness.light);
    }
    return _customTrackStyleMap[track.id]!;
  }

  String _groupedTypeKey(Track track) => '${_speciesId}-${track.trackType.name}';

  void mergeCustomStyleToGrouped(Track track) {
    var _groupedStyle = safeGroupedStyle(track);
    _groupedStyle.merge(_customTrackStyleMap[track.id]);
  }

  TrackStyle safeGroupedStyle(Track track) {
    var _groupedStyle = _groupedStyleByType[_groupedTypeKey(track)];
    if (null == _groupedStyle) {
      _groupedStyle = TrackStyle.empty(Brightness.light);
      _groupedStyleByType[_groupedTypeKey(track)] = _groupedStyle;
    }
    return _groupedStyle;
  }

  void removeGroupedStyle(Track track) {
    var key = _groupedTypeKey(track);
    if (_groupedStyleByType.containsKey(key)) {
      _groupedStyleByType.remove(key);
    }
  }

  // save the custom style
  void saveCustomTrackStyle(Track track) {
    _debounce!.run(_saveCustomTrackStyle);
  }

  void _saveCustomTrackStyle() {
    if (null == _speciesId) return;
    for (var entry in _groupedStyleByType.entries) {
      BaseStoreProvider.get().setGroupedTrackStyle(entry.key, entry.value);
    }
    if (_customTrackStyleMap.length == 0 || _speciesId == null) return;
    BaseStoreProvider.get().setCustomTrackStyles(_speciesId!, _customTrackStyleMap);
  }

  void clearCustomTrackStyle() {
    _customTrackStyleMap.clear();
  }

  void toggleGroupedTrack(Track track, bool grouped, TrackStyle trackStyle) {
    if (grouped) {
      if (_groupedTrackTypeRx.value != null && track.trackType != _groupedTrackTypeRx.value) {
        return;
      }

      if (_groupedTrackTypeRx.value == null) {
        _groupedTrackTypeRx.value = track.trackType;
      }
      // _groupedTrackList.add(track.id!);
      // _groupedTracksNotifier.value = GroupTracks(track.id!, _groupedTrackList.toList());

      TrackStyle _groupedStyle = safeGroupedStyle(track);
      _groupedStyle.trackHeight = max<double>(_groupedStyle!.getDouble('track_height') ?? 0.0, trackStyle.trackHeight);
      var maxValue = max<double>(_groupedStyle.customMaxValue.enableValueOrNull ?? 0.0, trackStyle.customMaxValue.value ?? 0.0);
      _groupedStyle.customMaxValue = EnabledValue(enabled: true, value: maxValue);

      if (_customTrackStyleMap[track.id] != null) {
        _customTrackStyleMap[track.id]!.merge(_groupedStyle);
      }
    } else {
      // _groupedTrackList.remove(track.id);
      // _groupedTracksNotifier.value = GroupTracks(track.id!, _groupedTrackList.toList());
      // if (_groupedTrackList.length == 0) {
      removeGroupedStyle(track);
      _groupedTrackTypeRx.value = null;
      // }
    }
    _groupedTracksDebounce?.run(_saveGroupedTracks);
  }

  void toggleGroupByTrackType(Track track, bool checked) {
    var key = _groupedTypeKey(track);
    var style = safeGroupedStyle(track);
    style['grouped'] = checked;
    // _saveCustomTrackStyle();
    BaseStoreProvider.get().setGroupedTrackStyle(key, style);
    SgsBrowseLogic.safe()?.update();
  }

  void _saveGroupedTracks() {
    // BaseStoreProvider.get().setGroupedTracks(_speciesId, _groupedTrackList.toList());
  }

  bool isTrackGroupAble(Track track) {
    return _groupedTrackTypeRx.value == null || track.trackType == _groupedTrackTypeRx.value;
  }

  bool isTrackGrouped(Track track) {
    var safeStyle = _groupedStyleByType[_groupedTypeKey(track)] ?? BaseStoreProvider.get().getGroupedTrackStyle(_groupedTypeKey(track));
    return safeStyle?['grouped'] ?? false;
    // return _groupedStyleByType[_groupedTypeKey(track)] != null || BaseStoreProvider.get().getGroupedTrackStyle(_groupedTypeKey(track)) != null;
    // return _groupedTrackList.contains(track.id);
  }

  void setGroupedTrackColor(TrackType trackType, List<String> trackList) {
    bool dark = Get.isDarkMode;

    var style = SgsBrowseLogic.safe()!.getTrackStyle(trackType);
    Map<String, Color>? colorMap = style?.colorMap;

    List colorKeys = colorMap?.keys.toList() ?? [];
    if (colorKeys.length == 0) colorKeys = ['__auto'];
    int count = trackList.length;
    int colorsLen = count * colorKeys.length;

    List<Color> colors = RandomColor().randomColors(count: colorsLen, colorSaturation: ColorSaturation.mediumSaturation, colorBrightness: ColorBrightness.primary);
    //a list of color_map
    // Map<String, Map<String, Color>> colorGroups = Map.fromIterables(trackList, List.generate(count, (i) => <String, Color>{}));
    // _groupedTrackColor.clear();
    for (var i = 0; i < colorsLen; i++) {
      var r = i ~/ count;
      var n = i % count;
      _groupedTrackColor[trackList[n]] ??= {};
      _groupedTrackColor[trackList[n]]![colorKeys[r]] = colors[i];
    }
    SgsBrowseLogic.safe()?.update();
  }

  void updateAutoColor(Track track, String key, Color color) {
    if (_groupedTrackColor[track.id] == null) return;
    _groupedTrackColor[track.id]![key] = color;
  }

  Map<String, Color>? getGroupTrackColorMap(Track track) {
    if (!isTrackGrouped(track)) return null;
    return _groupedTrackColor[track.id];
  }

  void clear() {
    _debounce!.dispose();
  }
}
