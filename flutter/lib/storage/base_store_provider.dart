import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/base/app_layout.dart';
import 'package:flutter_smart_genome/bean/account_bean.dart';
import 'package:flutter_smart_genome/bean/highlight_range.dart';
import 'package:flutter_smart_genome/bean/site_item.dart';
import 'package:flutter_smart_genome/components/shortener/url_shortener_logic.dart';
import 'package:flutter_smart_genome/storage/hive_store_provider.dart';
import 'package:flutter_smart_genome/widget/track/base/track_session.dart';
import 'package:flutter_smart_genome/widget/track/base/track_style.dart';
import 'package:flutter_smart_genome/widget/track/base/track_theme.dart';

abstract class BaseStoreProvider {
  static BaseStoreProvider get() {
    return HiveStoreProvider();
  }

  Future init();

  bool showCaseFinish();

  void finishShowCase();

  Future logout();

  void setAccount(AccountBean account);

  AccountBean? getAccount();

  List<AccountBean> getAccounts();

  AccountBean? getLoginUser(String url);

  Future addAccount(AccountBean account);

  void deleteAccount(AccountBean account);

  void deleteAccountByUrl(String url);

  AppLayout getAppLayout();

  setAppLayout(AppLayout appLayout);

  Future checkInitServer(List<SiteItem> defSites);

  Future<SiteItem?> findSiteByUrl(String url);

  SiteItem? getCurrentSite();

  setCurrentSite(SiteItem siteItem);

  Future<List<SiteItem>> getSiteList([SiteItem? defSite]);

  void addSiteList(List<SiteItem> sites);

  Future addSite(SiteItem site);

  Future deleteSite(SiteItem site);

  Future updateSite(SiteItem site);

  Future clear();

  int getAppVersion();

  Future<void> setAppVersion(int version);

  setThemeMode(ThemeMode themeMode);

  ThemeMode getThemeMode();

  setTrackAnimation(bool animation);

  bool getTrackAnimation();

  setTrackAnimationDuration(int duration);

  int getTrackAnimationDuration();

  setIdeMode(bool ideLayout);

  bool getIdeMode();

  setThemeColor(int colorIndex);

  int getThemeColor();

  // static Future<TrackUIConfigBean> getTrackUIConfig([String track = 'all']) async {
  //   SharedPreferences _prefs = await SharedPreferences.getInstance();
  //   String uiConfig = _prefs.getString('track-ui-config-$track');
  //   if (null == uiConfig) return TrackUIConfigBean.defaultValue();
  //   return TrackUIConfigBean.fromMap(json.decode(uiConfig));
  // }
  //
  // static void setTrackUIConfig(TrackUIConfigBean bean, [String track = 'all']) async {
  //   SharedPreferences _prefs = await SharedPreferences.getInstance();
  //   //print('save => ${bean.toPersistMap()}');
  //   _prefs.setString('track-ui-config-$track', json.encode(bean.toPersistMap()));
  // }

  TrackTheme? getCurrentTrackTheme();

  void setCurrentTrackTheme(TrackTheme trackTheme);

  Future addTrackTheme(TrackTheme trackTheme);

  Future deleteTrackTheme(TrackTheme theme);

  void deleteTrackThemeByName(String name);

  Future setTrackTheme(TrackTheme trackTheme, {bool isAdd = false});

  List<TrackTheme> getAllTrackTheme();

  Future checkAndInitTrackTheme();

  TrackTheme? getTrackTheme(String themeName);

  TrackSession? getTrackBrowserLastSession([String id = '1']);

  void setTrackBrowserLastSession(TrackSession session, [String id = '1']);

  ///
  /// for track session list page
  ///
  Future<List<TrackSession>> getSessionList([String? speciesId]);

  void addSession(TrackSession session);

  void deleteSession(TrackSession session);

  void clearSession();

  /// to save every species session
  void saveSpeciesLastSession(TrackSession session);

  /// get session by species
  TrackSession? getSpeciesLastSession(String speciesId);

  List<HighlightRange> getHighlights();

  Future addOrPutHighlight(HighlightRange highlight);

  Future deleteHighlight(HighlightRange highlight);

  num getTrackThemeVersion();

  setTrackThemeVersion(int version);

  void setCustomTrackStyles(String speciesId, Map<String, TrackStyle> styleMap);

  Map<String, TrackStyle>? getCustomTrackStyles(String? speciesId);

  void setGroupedTrackStyle(String speciesId, TrackStyle? style);

  TrackStyle? getGroupedTrackStyle(String? speciesId);

  List<String> getGroupedTracks(String? speciesId);

  setGroupedTracks(String? speciesId, List<String> tracks);

  Map<String, TrackStyle> getGroupedTrackStyleMap(String speciesId);

  List<List<String>> getCompareHistory(String scId);

  void addCompareHistory(String scId, List<String> features);

  void deleteCompareHistory(String scId, List<String> features);

  List<Map> getShortenList();

  void updateShortener(String supplier, Map data);
}
