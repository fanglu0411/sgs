import 'package:app_links/app_links.dart';
import 'package:dio/dio.dart';
import 'package:flutter_smart_genome/base/app_layout.dart';
import 'package:flutter_smart_genome/bean/account_bean.dart';
import 'package:flutter_smart_genome/bloc/sgs_context/sgs_browse_logic.dart';
import 'package:flutter_smart_genome/bloc/track_config/bloc.dart';
import 'package:flutter_smart_genome/mixin/track_list_mixin.dart';
import 'package:flutter_smart_genome/network/dio_helper.dart';
import 'package:flutter_smart_genome/page/home/home_app_title_bar.dart';
import 'package:flutter_smart_genome/page/maincontainer/track_container.dart';
import 'package:flutter_smart_genome/page/maincontainer/track_container_logic.dart';
import 'package:flutter_smart_genome/page/site/site_logic.dart';
import 'package:flutter_smart_genome/platform/platform_adapter.dart';
import 'package:flutter_smart_genome/service/sgs_config_service.dart';
import 'package:flutter_smart_genome/service/single_cell_service.dart';
import 'package:flutter_smart_genome/side/highlight_side.dart';
import 'package:flutter_smart_genome/storage/base_store_provider.dart';
import 'package:flutter_smart_genome/util/device_info.dart';
import 'package:flutter_smart_genome/util/widget_util.dart';
import 'package:flutter_smart_genome/widget/track/track_group_logic.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_genome/bean/gene.dart';
import 'package:flutter_smart_genome/bean/site_item.dart';
import 'package:flutter_smart_genome/bean/datasets.dart';
import 'package:flutter_smart_genome/network/http_response.dart';
import 'package:flutter_smart_genome/page/cell/cell_page/cell_page_logic.dart';
import 'package:flutter_smart_genome/page/compare/compare_common.dart';
import 'package:flutter_smart_genome/service/abs_platform_service.dart';
import 'package:flutter_smart_genome/util/debouncer.dart';
import 'package:flutter_smart_genome/util/logger.dart';
import 'package:flutter_smart_genome/widget/track/base/layout/track_layout_manager.dart';
import 'package:flutter_smart_genome/widget/track/base/track_session.dart';
import 'package:flutter_smart_genome/widget/track/base/track_data.dart';
import 'package:flutter_smart_genome/widget/track/chromosome/chromosome_data.dart';
import 'package:flutter_smart_genome/widget/track/common.dart';
import 'package:dartx/dartx.dart' as dx;
import 'package:window_manager/window_manager.dart';
import 'package:window_size/window_size.dart';

class SgsAppService extends GetxService {
  static SgsAppService? get() {
    if (Get.isRegistered<SgsAppService>()) {
      return Get.find<SgsAppService>();
    }
    return null;
  }

  List<Track> _tracks = [];
  List<Track> _scTracks = [];

  Map? _trackConfig;
  List<ChromosomeData>? _chromosomeList;

  late List<PositionInfo> _historyList;

  late int _currentHistoryIndex;

  TrackSession? _browserSession;
  TrackSession? _browserSession2;

  ChromosomeData? _currentChromosome;
  ChromosomeData? _currentChromosome2;

  ChromosomeData? get chr1 => _currentChromosome;

  ChromosomeData? get chr2 => _currentChromosome2;

  Debounce? _debounce;
  Debounce? _persistDebounce;

  List<Track> get tracks => _tracks;

  List<Track> get scTracks => _scTracks;

  String get staticBaseUrl {
    return site!.url;
    // Uri uri = Uri.parse(site!.url);
    // return 'http://${uri.host}';
  }

  Map? get trackConfig => _trackConfig;

  // List<Species>? _speciesList;

  List<ChromosomeData>? get chromosomes => _chromosomeList;

  List<Track> get selectedTracks => (_tracks).where((e) => (e.checked || e.childrenHasChecked) && e.statusDone).toList();

  TrackSession? get session => _browserSession;

  TrackSession? get session2 => _browserSession2;

  bool _paired = false;

  bool get paired => _paired; //null != _currentChromosome2;

  SiteItem? _site;

  SiteItem? get site => _site;

  void setSite(SiteItem site) {
    reset();
    _site = site;
  }

  late List<CompareItem> _compareList;

  List<CompareItem> get compareList => _compareList;

  List<PositionInfo>? get historyList => _historyList;

  List<Species>? get species {
    if (_site == null) return null;
    return _memoryCacheSiteSpecies[_site!.url];
  }

  void updateSiteSpecies(SiteItem site, List<Species>? list) {
    _memoryCacheSiteSpecies[site.url] = list ?? [];
  }

  Map<String, List<Species>> _memoryCacheSiteSpecies = {};

  bool _autoWitchScConfirmShowing = false;

  AccountBean? _loginUser;

  AccountBean? get loginUser => _loginUser;

  bool get inited => tracks.isNotEmpty || scTracks.isNotEmpty;

  SgsAppService() {
    _historyList = [];
    _currentHistoryIndex = 0;
    _debounce = Debounce(milliseconds: 10000);
    _compareList = [];
    _persistDebounce = Debounce(milliseconds: 1500);
    if (kIsWeb) _site = SiteLogic.defSite().first;

    // protocolHandler.register('sgs');
    PlatformAdapter.create().registrySchema('sgs');
    final _appLinks = AppLinks(); // AppLinks is singleton
    // Subscribe to all events (initial link and further)
    _appLinks.uriLinkStream.listen((uri) {
      _checkUrl(uri.toString());
    });
  }

  reset() {
    _historyList = [];
    _currentHistoryIndex = 0;
    _compareList = [];
    _site = null;
    // _speciesList = null;
    // _memoryCacheSiteSpecies.clear();
  }

  //
  // Future<SgsAppService> init() async {
  //   return this;
  // }

  PositionInfo? getPreviousPositionInfo() {
    if (_currentHistoryIndex > 0) {
      _currentHistoryIndex -= 1;
      return _historyList[_currentHistoryIndex];
    }
    return null;
  }

  PositionInfo? getNextPositionInfo() {
    if (_currentHistoryIndex < _historyList.length - 1) {
      _currentHistoryIndex++;
      return _historyList[_currentHistoryIndex];
    }
    return null;
  }

  void setCurrentHistoryIndex(PositionInfo info) {
    int index = _historyList.indexWhere((element) => element.range == info.range);
    if (index >= 0) _currentHistoryIndex = index;
  }

  void updateSession(TrackSession session, [TrackSession? session2]) {
    _browserSession = session;
    if (session2 != null) {
      _browserSession2 = session2;
    }
  }

  void _checkUrl(String text, {bool fromClipboard = false}) async {
    var _url = await validateSessionUrl(text);
    if (_url != null) {
      // ShareSession _shareSession = await ShareSession.fromSessionUrl(_url);
      TrackSession? _session = await TrackSession.fromUrl(_url);
      await Future.delayed(Duration(milliseconds: 200));
      // SgsBrowseLogic.safe()?.shareSessionObserver.value = _session;
      if (null != _session) WidgetUtil.openOutUrlDialog(_session);
      if (!fromClipboard && DeviceOS.isMacOS) windowManager.show();
      if (fromClipboard) Clipboard.setData(ClipboardData(text: ''));
    }
  }

  void sendEvent(TrackConfigEvent event) => _handleEvent(event);

  void _handleEvent(TrackConfigEvent event) async {
    if (event is TrackBasicEvent) {
      _mapLoadBasicDataToState(event);
    } //
    else if (event is CheckClipboardEvent) {
      if (kIsWeb || Platform.isWindows) return;
      String? text = (await Clipboard.getData('text/plain'))?.text;
      if (text == null || text.length == 0) return;
      _checkUrl(text, fromClipboard: true);
    } //
    else if (event is LoadSessionEvent) {
      /// load session from url
      TrackSession _session = event.session!;
      //in case site has been deleted
      SiteItem? cached = await BaseStoreProvider.get().findSiteByUrl(_session.url);
      if (cached == null) {
        await BaseStoreProvider.get().addSite(SiteItem(url: _session.url));
      }
      _site = await BaseStoreProvider.get().findSiteByUrl(_session.url);
      // _session.id = await SpeciesLastSessionProvider.autoIncrement();
      _handleEvent(TrackBasicEvent(session: _session));
    } //
    else if (event is SpeciesChangeEvent) {
      _chromosomeList = [];
      _currentChromosome2 = null;
      _currentChromosome = null;
      // _browserSession2 = null;
      _tracks = [];
      _debounce?.dispose();

      // IoUtils.instance.setTitle('${event.session.site.url} - ${event.session.speciesName}');
      if (!kIsWeb) setWindowTitle('SGS - ${event.session!.url} - ${event.session!.speciesName}');
      _site = await BaseStoreProvider.get().findSiteByUrl(event.session!.url);

      TrackLayoutManager.clear();
      CellPageLogic.safe()?.changeTrack(null);
      HighlightsLogic.safe()?.reloadData();
      _handleEvent(TrackBasicEvent(session: event.session));
    } //
    else if (event is ToggleCompareModeEvent) {
      if (chromosomes == null || chromosomes!.length == 0) return;
      _paired = !_paired;

      if (_paired) {
        if (_browserSession2 == null || _browserSession2!.speciesId != _browserSession!.speciesId || _currentChromosome2 == null) {
          _currentChromosome2 = chromosomes!.length == 1
              ? chromosomes![0] //
              : chromosomes!.whereNot((e) => e.id == chr1!.id).first;
          _browserSession2 = _browserSession!.copy(
            chrName: _currentChromosome2!.chrName,
            chrId: _currentChromosome2!.id,
            range: _currentChromosome2!.range,
          );
        } else {}
      }
      _notifyBrowseView();
      // if (chr2 == null) {
      //   var _secondaryChr = chromosomes.length == 1
      //       ? chromosomes[0] //
      //       : chromosomes.whereNot((e) => e.id == chr1.id).first;
      //   _handleEvent(ChromosomeChangeEvent(chromosome: chr1, chromosome2: _secondaryChr));
      // } else {
      //   _handleEvent(ChromosomeChangeEvent(chromosome: chr1));
      // }
    } //
    else if (event is ChromosomeChangeEvent) {
      _currentChromosome = event.chromosome;
      _currentChromosome2 = event.chromosome2;
      _browserSession = _browserSession!.copy(
        chrName: event.chromosome.chrName,
        chrId: event.chromosome.id,
        range: event.range,
      );
      _browserSession2 = null == _currentChromosome2
          ? null
          : _browserSession!.copy(
              chrName: event.chromosome2!.chrName,
              chrId: event.chromosome2!.id,
              range: event.range2,
            );
      _notifyBrowseView();
      if (event.range != null) {
        await Future.delayed(Duration(milliseconds: 800));
        SgsBrowseLogic.safe()?.zoomToRange(event.range!);
      }
    } //
    else if (event is ForceUpdateTracksEvent) {
      List<HttpResponseBean<List<Track>>> __trackResp = await Future.wait<HttpResponseBean<List<Track>>>([
        if (event.genomeTrack)
          AbsPlatformService.get(site)!.loadAllTrackList(host: _site!.url, species: _site!.currentSpeciesId!, refresh: true)
        else
          Future.value(HttpResponseBean.fromBody(<Track>[])),
        if (event.scTrack) loadCellTrackList(host: _site!.url, speciesId: _site!.currentSpeciesId!, refresh: true) else Future.value(HttpResponseBean.fromBody(<Track>[])),
      ]);
      if (event.genomeTrack) {
        _tracks = __trackResp[0].body ?? [];
        if (_tracks.length > 0) _tracks.insert(0, Track.refSeqTrack());
        _setTrackSelectionAndOrder();
        _notifyTrackListView(tracks: _tracks);
      }
      if (event.scTrack) {
        _scTracks = __trackResp[1].body ?? [];
        CellPageLogic.safe()?.updateStatus(false, error: __trackResp[1].error?.message);
      }
    } //
    else if (event is UpdateTrackListEvent) {
      _notifyTrackListView(tracks: _tracks);
    } //
    else if (event is TrackFilterEvent) {
      //todo
    } //
    else if (event is AddCustomTrackEvent) {
      _tracks.add(event.track);
      _notifyBrowseView();
      if (!event.track.statusDone) {
        _checkTrackStatus();
      }
    } //
    else if (event is ReorderTrackEvent) {
      int old = event.old, newIndex = event.newIndex;
      if (old < newIndex) newIndex -= 1;
      final element = _tracks.removeAt(old);
      _tracks.insert(newIndex, element);
      _notifyBrowseView();
      _notifyTrackListView(tracks: _tracks);
      _saveSession();
    } //
    else if (event is FilterTrackWithKeywordEvent) {
      RegExp regExp = RegExp('${event.keyword.toLowerCase()}');
      List<Track> filterTracks = event.keyword == ''
          ? _tracks //
          : _tracks.where((track) => track.trackName.toLowerCase().contains(regExp)).toList();
      _notifyTrackListView(tracks: filterTracks);
    } //
    else if (event is ToggleTrackSelectionEvent) {
      event.track.checked = event.selected;
      var t = tracks.firstOrNullWhere((e) => e.id == event.track.id);
      t?.checked = event.selected;
      if (t != null && t.hasChildren) t.children!.forEach((_t) => _t.checked = event.selected);
      _notifyTrackListView(tracks: _tracks);
      _notifyBrowseView();
      _saveSession();
    } //
    else if (event is ToggleSelectAllTrackEvent) {
      // print('event.selectAll ${event.selectAll}');
      _tracks.forEach((t) => t.checkWithChildren = event.selectAll);
      // TrackListLogic.safe()?.setTracks(tracks);
      _notifyBrowseView();
      _notifyTrackListView(tracks: _tracks);
      _saveSession();
    } //
    else if (event is ResetOrderTrackListEvent) {
      if (_tracks.isEmpty) return;
      Track _ref = _tracks.firstWhere((t) => t.isReference);
      var __tracks = _tracks.where((t) => !t.isReference).sortedBy((t) => t.bioType).toList();
      __tracks.insert(0, _ref);
      _tracks = __tracks;
      // TrackListLogic.safe()?.setTracks(tracks);
      _notifyBrowseView();
      _notifyTrackListView(tracks: _tracks);
      _saveSession();
    } //
    else if (event is PositionRangeChangeEvent) {
      //only change position range
      _browserSession = event.session;
    } //
    else if (event is AddHistoryEvent) {
      _historyList.insert(0, event.positionInfo);
    }
    // no use
    else if (event is SetCurrentSessionEvent) {
      // _browserSession = event.session;
    } //
    // compare start
    else if (event is AddCompareItemEvent) {
      _compareList.add(event.item);
    }
  }

  void changeSiteSpecies(SiteItem site) async {
    _site = site;
    var _session = await BaseStoreProvider.get().getSpeciesLastSession(site.currentSpeciesId!);
    if (_session == null) {
      _session = TrackSession(
        siteId: site.id,
        url: site.url,
        chrId: null,
        chrName: null,
        speciesName: site.currentSpecies,
        speciesId: site.currentSpeciesId!,
        // range: _browserSession?.range,
      );
      // ..id = await SpeciesLastSessionProvider.autoIncrement();
    }
    _session
      ..siteId = site.id
      ..url = site.url
      ..speciesId = site.currentSpeciesId!
      ..speciesName = site.currentSpecies;
    _handleEvent(SpeciesChangeEvent(session: _session));
  }

  /// load session
  void loadSession(TrackSession session) {
    // logger.d(session);

    TrackSession _currentSession = this.session!;
    if (session.speciesId == _currentSession.speciesId && session.chrId == _currentSession.chrId) {
      TrackGroupLogic? trackGroupLogic = TrackGroupLogic.safe();
      trackGroupLogic?.zoomToRange(session.range!);
    } else {
      _handleEvent(SpeciesChangeEvent(session: session));
    }
  }

  void _notifyLoading() {
    _notifyBrowseView(true, null);
    _notifyTrackListView(loading: true);
    CellPageLogic.safe()?.updateStatus(true);
  }

  void _notifyError(String? error, {String? scError}) {
    _notifyBrowseView(false, error);
    _notifyTrackListView(loading: false, clearFilter: true, tracks: _tracks);
    CellPageLogic.safe()?.updateStatus(false, error: scError);
  }

  void _notifyBrowseView([bool loading = false, String? error = null]) {
    SgsBrowseLogic.safe()?.setData(
      loading: loading,
      error: error,
      session: _browserSession,
    );
  }

  void _notifyTrackListView({
    bool loading = false,
    String? error = null,
    List<Track> tracks = const [],
    bool clearFilter = false,
  }) {
    TrackListLogic.safe()?.setData(loading: loading, error: error, tracks: tracks, clearFilter: clearFilter);
  }

  CancelToken? _basicCancelToken;

  /// load session
  /// session from:
  /// @1, storage history
  /// @2, no storage
  /// @3, share session, no id
  /// @4, saved session list
  _mapLoadBasicDataToState(TrackBasicEvent event) async {
    try {
      _notifyLoading();
      _basicCancelToken?.cancel('new request rich!');
      await Future.delayed(Duration(milliseconds: 200));

      _basicCancelToken = CancelToken();
      _browserSession = event.session ?? await BaseStoreProvider.get().getTrackBrowserLastSession();

      _paired = false;
      _browserSession2 = null;
      _currentChromosome2 = null;

      DioHelper().dio.options.baseUrl = site!.url;

      _loginUser = BaseStoreProvider.get().getLoginUser(site!.url);
      if (species == null) {
        HttpResponseBean<List<Species>> bean = await AbsPlatformService.get(site)!.loadSpeciesList(
          host: _site!.url,
          forceRefresh: false,
          cancelToken: _basicCancelToken,
        );
        if (!bean.success) {
          if (bean.error?.type == DioExceptionType.cancel) return;
          _tracks = [];
          _scTracks = [];
          _notifyError(bean.error!.message);
          return;
        }
        var list = bean.body;
        if (list != null && list.length > 0) updateSiteSpecies(_site!, list);
      }
      List<Species>? _speciesList = species;

      if (_speciesList == null || _speciesList.length == 0) {
        _tracks = [];
        _scTracks = [];
        _notifyError('Database is empty, Please add Species first!');
        return;
      }

      if (_browserSession?.speciesId != null) {
        _site!.currentSpeciesId = _browserSession!.speciesId;
        _site!.currentSpecies = _browserSession!.speciesName;
      }

      ///没有选择物种或者id没找到
      if (_site!.currentSpeciesId == null || (_speciesList.indexWhere((e) => e.id == _site!.currentSpeciesId) < 0)) {
        _site!.currentSpeciesId = _speciesList.first.id;
        _site!.currentSpecies = _speciesList.first.name;
      }

      await BaseStoreProvider.get().updateSite(_site!);
      await BaseStoreProvider.get().setCurrentSite(_site!);

      List<HttpResponseBean<List<Track>>> __trackResp = await Future.wait<HttpResponseBean<List<Track>>>([
        AbsPlatformService.get(site)!.loadAllTrackList(
          host: _site!.url,
          species: _site!.currentSpeciesId!,
          refresh: false,
          cancelToken: _basicCancelToken,
        ),
        loadCellTrackList(
          host: _site!.url,
          speciesId: _site!.currentSpeciesId!,
          refresh: false,
          cancelToken: _basicCancelToken,
        ),
      ]);
      if (__trackResp[0].error?.type == DioExceptionType.cancel || __trackResp[1].error?.type == DioExceptionType.cancel) return;
      _scTracks = __trackResp[1].body ?? [];
      CellPageLogic.safe()?.updateStatus(false, error: __trackResp[1].error?.message);
      // HomeTitleBarLogic.get()?.updateTitle();

      _tracks = __trackResp[0].body ?? [];
      _tracks = _tracks.sortedBy((t) => t.bioType).toList();
      if (_tracks.length > 0) _tracks.insert(0, Track.refSeqTrack());
      SgsConfigService.get()!.setSiteSpecies(_site!);
      _checkTrackStatus();

      HomeTitleBarLogic.get()?.updateTitle();

      //是否需要自动切换到sc模式
      if (_tracks.length == 0 && scTracks.isNotEmpty && SgsConfigService.get()!.appLayout == AppLayout.gnome && !_autoWitchScConfirmShowing) {
        _autoWitchScConfirmShowing = true;
        bool? toScMode = await autoChangeScLayoutConfirm(Get.context!);
        _autoWitchScConfirmShowing = false;
        if (toScMode == true) {
          // HomeTitleBarLogic.get()?.updateTitle();
          SgsConfigService.get()!.changeAppLayout(AppLayout.SC);
          _checkSessionAndSave();
          return;
        }
      }

      //handle for web app url
      if (event.session?.appLayout == AppLayout.SC) {
        SgsConfigService.get()!.changeAppLayout(event.session!.appLayout!);
        await Future.delayed(Duration(milliseconds: 200));
        _checkAutoSelectScTrack(event.session);
        _checkSessionAndSave();
        return;
      }

      if (event.session?.appLayout == null && SgsConfigService.get()!.appLayout == AppLayout.SC) {
        if (_tracks.length > 1 && _scTracks.length == 0) {
          SgsConfigService.get()!.changeAppLayout(AppLayout.gnome);
        } else {
          // HomeTitleBarLogic.get()?.updateTitle();
          CellPageLogic.safe()?.updateStatus(false);
          _checkAutoSelectScTrack(event.session);
          _checkSessionAndSave();
          return;
        }
      }

      if (_tracks.length == 0) {
        // HomeTitleBarLogic.get()?.updateTitle();
        _notifyError(__trackResp[0].error?.message ?? 'No Genome Track Found!', scError: __trackResp[1].error?.message);
        _checkSessionAndSave();
        return;
      }

      _chromosomeList = await AbsPlatformService.get(site)!.loadChromosomes(
        host: _site!.url,
        speciesId: _site!.currentSpeciesId!,
        refresh: false,
        cancelToken: _basicCancelToken,
      );
      if (_chromosomeList == null || _chromosomeList!.length == 0) {
        _notifyError('Load chromosome error!');
        _checkSessionAndSave();
        return;
      }

      var defChar = _chromosomeList!.firstWhereOrNull((e) => e.chrName == 'chr1' || e.chrName == '1') ?? _chromosomeList!.first;
      _currentChromosome = _findChromosome(_browserSession?.chrId, defChar);
      //尝试恢复track的排序
      _setTrackSelectionAndOrder();
      if (selectedTracks.length == 0 && _tracks.length > 0) {
        _tracks[0].checked = true;
      }
      _notifyBrowseView();
      _notifyTrackListView(tracks: _tracks, clearFilter: true);

      CellPageLogic.safe()?.updateStatus(false);
      SgsConfigService.get()!.changeAppLayout(event.session?.appLayout ?? AppLayout.gnome);

      // TrackContainerLogic.safe()?.changeAppLayout(SgsConfigService.get()!.appLayout);
      // TrackContainerLogic.safe()?.setSide(SideModel.track_list, true);
      _checkAutoSelectScTrack(event.session);

      _checkSessionAndSave();
    } catch (e, stackTrace) {
      logger.e(stackTrace);
      _notifyError(e.toString());
    }
  }

  //check need choose initial sc track
  void _checkAutoSelectScTrack(TrackSession? session) {
    if (session == null || AppLayout.gnome == SgsConfigService.get()!.appLayout) return;
    var sc = scTracks.firstOrNullWhere((e) => e.scId == session.scId) ?? (scTracks.length > 0 ? scTracks.first : null);
    if (sc != null) {
      CellPageLogic.safe()?.changeTrack(sc);
    }
  }

  void _checkSessionAndSave() {
    var range = (_browserSession == null || _browserSession!.range == null) ? _currentChromosome?.range : _currentChromosome?.range.intersection(_browserSession!.range!);
    _browserSession ??= TrackSession(
      siteId: _site!.id,
      url: _site!.url,
      speciesId: _site!.currentSpeciesId!,
      speciesName: _site!.currentSpecies,
      autoSave: true,
    )
      ..range = range
      ..chrId = _currentChromosome?.id
      ..chrName = _currentChromosome?.chrName;
    _saveSession(true);
  }

  void _setTrackSelectionAndOrder() {
    if (_browserSession?.tracks != null && _browserSession!.tracks!.length > 0) {
      List sortedId = _browserSession!.tracks!.map((t) => t.split(':')[0]).toList();
      _sortTracks(sortedId);
      List checkedList = _browserSession!.tracks!
          .map((e) {
            var arr = e.split(':');
            if (arr.length == 2 && arr[1] == '1') return arr[0];
            return null;
          })
          .where((e) => e != null)
          .toList();
      _tracks.forEach((t) {
        t.checkWithChildren = checkedList.contains(t.id); // || t.id == 'ref_seq';
      });
    } else {
      _tracks.forEachIndexed((e, i) => e.checkWithChildren = i <= 5);
      //_selectedTracks = [..._tracks];
    }
  }

  ChromosomeData _findChromosome(String? chrId, ChromosomeData defaultChr) {
    if (null == chrId) return defaultChr;
    return _chromosomeList!.firstWhere((element) => element.id == chrId, orElse: () => defaultChr);
  }

  void _checkTrackStatus() {
    _debounce?.dispose(); // fix change species
    if (_tracks.any((t) => !t.statusDone)) {
      _debounce!.run(() {
        _handleEvent(ForceUpdateTracksEvent());
      });
    }
  }

  void _sortTracks(List sortedId) {
    Map<String, int> orderMap = sortedId.asMap().map<String, int>((key, value) {
      return MapEntry(value, key);
    });
    int? _trackOrder(String trackId) {
      if (trackId == 'ref_seq') return 0;
      return orderMap[trackId];
    }

    _tracks.sort((a, b) {
      int _a = _trackOrder(a.id!) ?? 0;
      int _b = _trackOrder(b.id!) ?? 0;
      return _a - _b;
    });
  }

  void updateCurrentSession(Range _range) {
    _browserSession!..range = _range;
    _saveSession();
  }

  void updateCurrentSession2(Range visibleRange) {
    if (_browserSession2 != null) {
      _browserSession2?.range = visibleRange;
      _saveSession();
    }
  }

  void _saveSessionInternal() {
    if (_browserSession == null) return;
    _browserSession!
      ..chrId = _currentChromosome?.id
      ..chrName = _currentChromosome?.chrName
      ..autoSave = true
      ..scId = CellPageLogic.safe()?.track?.scId ?? _browserSession?.scId
      ..appLayout = SgsConfigService.get()!.appLayout
      ..tracks = _tracks.map((e) => '${e.id}:${(e.checked) ? 1 : 0}').toList()
      ..updateTime = DateTime.now().millisecondsSinceEpoch;
    BaseStoreProvider.get().setTrackBrowserLastSession(_browserSession!, '1');
    BaseStoreProvider.get().saveSpeciesLastSession(_browserSession!);
    if (null != _browserSession2) {
      _browserSession2!
        ..chrId = _currentChromosome?.id
        ..chrName = _currentChromosome?.chrName
        ..tracks = _tracks.map((e) => '${e.id}:${(e.checked) ? 1 : 0}').toList()
        ..updateTime = DateTime.now().millisecondsSinceEpoch;
      BaseStoreProvider.get().setTrackBrowserLastSession(_browserSession2!, '2');
    }

    // if (kIsWeb) {
    //   session?.toShareUrl().then((url) {
    //     PlatformAdapter.create().updateUrl(url);
    //   });
    // }
  }

  void _saveSession([bool immediate = false]) {
    if (immediate) {
      _saveSessionInternal();
    } else {
      _persistDebounce!.run(_saveSessionInternal);
    }
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    _debounce?.dispose();
    super.onClose();
  }
}
