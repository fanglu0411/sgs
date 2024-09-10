import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/base/app_layout.dart';
import 'package:flutter_smart_genome/bean/account_bean.dart';
import 'package:flutter_smart_genome/bean/highlight_range.dart';
import 'package:flutter_smart_genome/bean/site_item.dart';
import 'package:flutter_smart_genome/components/shortener/url_shortener_logic.dart';
import 'package:flutter_smart_genome/storage/hive/site_list_box.dart' as site_box;
import 'package:flutter_smart_genome/storage/hive/account_list_box.dart' as account_box;
import 'package:flutter_smart_genome/storage/hive/session_list_box.dart' as session_box;
import 'package:flutter_smart_genome/storage/hive/highlight_box.dart' as highlight_box;
import 'package:flutter_smart_genome/storage/hive/species_session_box.dart' as species_session_box;
import 'package:flutter_smart_genome/storage/hive/settings_box.dart' as setting_box;
import 'package:flutter_smart_genome/storage/hive/track_theme_list_box.dart' as track_theme_box;
import 'package:flutter_smart_genome/storage/hive/custom_track_style_box.dart' as custom_track_styles_box;
import 'package:flutter_smart_genome/storage/hive/grouped_track_style_box.dart' as grouped_track_style_box;
import 'package:flutter_smart_genome/storage/hive/grouped_track_list_box.dart' as grouped_track_list_box;
import 'package:flutter_smart_genome/storage/isar/account_provider.dart';
import 'package:flutter_smart_genome/storage/isar/session_list_provider.dart';
import 'package:flutter_smart_genome/storage/isar/site_provider.dart';
import 'package:flutter_smart_genome/storage/isar/species_last_session_provider.dart';
import 'package:flutter_smart_genome/storage/store.dart';
import 'package:flutter_smart_genome/widget/track/base/track_session.dart';
import 'package:flutter_smart_genome/widget/track/base/track_style.dart';
import 'package:flutter_smart_genome/widget/track/base/track_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'base_store_provider.dart';

class IsarStoreProvider extends BaseStoreProvider {
  static IsarStoreProvider _instance = IsarStoreProvider._init();

  IsarStoreProvider._init() {}

  factory IsarStoreProvider() => _instance;

  @override
  Future init() async {
    await Store.get().init();
  }

  checkInitServer(List<SiteItem> defSites) async {
    return site_box.checkInit(defSites);
  }

  bool showCaseFinish() {
    return setting_box.showCase();
  }

  void finishShowCase() {
    return setting_box.finishShowCase();
  }

  Future logout() async {
    await setting_box.deleteCurrentAccount();
  }

  void setAccount(AccountBean account) {
    setting_box.setCurrentAccount(account);
  }

  AccountBean? getAccount() {
    return setting_box.getCurrentAccount();
  }

  List<AccountBean> getAccounts() {
    return account_box.getAccounts();
  }

  AccountBean? getLoginUser(String url) {
    var accounts = account_box.getAccounts();
    var loginUser = accounts.where((a) => a.url == url && a.token != null);
    if (loginUser.length > 0) return loginUser.first;
    return null;
  }

  Future addAccount(AccountBean account) async {
    await account_box.addAccount(account);
  }

  void deleteAccount(AccountBean account) {
    account_box.deleteAccount(account);
  }

  void deleteAccountByUrl(String url) {
    account_box.deleteAccountByUrl(url);
  }

  AppLayout getAppLayout() {
    return setting_box.getAppLayout();
  }

  setAppLayout(AppLayout appLayout) async {
    await setting_box.setAppLayout(appLayout);
  }

  //  void setAccounts(List<AccountBean> accounts) async {
  //   SharedPreferences _prefs = await SharedPreferences.getInstance();
  //   _prefs.setString('_accounts', (null == accounts || accounts.isEmpty) ? null : json.encode(accounts.map((e) => e.toJson()).toList()));
  // }

  SiteItem? getCurrentSite() {
    return setting_box.getCurrentSite();
  }

  setCurrentSite(SiteItem siteItem) async {
    await setting_box.setCurrentSite(siteItem);
  }

  Future<List<SiteItem>> getSiteList([SiteItem? defSite]) async {
    return await site_box.getSites();
  }

  void addSiteList(List<SiteItem> sites) async {
    await site_box.addSiteList(sites);
  }

  Future addSite(SiteItem site) async {
    await SiteProvider.saveSite(site);
  }

  Future deleteSite(SiteItem site) async {
    await SiteProvider.deleteSite(site);
  }

  Future updateSite(SiteItem site) {
    return SiteProvider.updateSite(site);
  }

  clear() async {
    await setting_box.clear();
    // await site_box.clear();
    await SiteProvider.deleteAll(); //do not clear sites
    // await session_box.clear();
    await SessionListProvider.deleteAll();
    // await species_session_box.clear();
    await SpeciesLastSessionProvider.deleteAll();
    await track_theme_box.clear();
    await custom_track_styles_box.clear();
    await account_box.clear();
    await grouped_track_list_box.clear();
    await grouped_track_style_box.clear();
    await highlight_box.clear();
  }

  int getAppVersion() {
    return setting_box.getAppVersion();
  }

  Future<void> setAppVersion(int version) {
    return setting_box.setAppVersion(version);
  }

  setThemeMode(ThemeMode themeMode) {
    setting_box.setThemeMode(themeMode);
  }

  ThemeMode getThemeMode() {
    return setting_box.getThemeMode();
  }

  setTrackAnimation(bool animation) {
    setting_box.setTrackAnimation(animation);
  }

  bool getTrackAnimation() {
    return setting_box.getTrackAnimation();
  }

  setTrackAnimationDuration(int duration) {
    setting_box.setTrackAnimationDuration(duration);
  }

  int getTrackAnimationDuration() {
    return setting_box.getTrackAnimationDuration();
  }

  setIdeMode(bool ideLayout) {
    setting_box.setIdeMode(ideLayout);
  }

  bool getIdeMode() {
    return setting_box.getIdeMode();
  }

  setThemeColor(int colorIndex) {
    setting_box.setThemeColor(colorIndex);
  }

  int getThemeColor() {
    return setting_box.getThemeColor();
  }

  TrackTheme? getCurrentTrackTheme() {
    var name = setting_box.getCurrentTrackThemeName();
    return track_theme_box.getTrackTheme(name);
  }

  void setCurrentTrackTheme(TrackTheme trackTheme) {
    setting_box.setCurrentTrackThemeName(trackTheme.name);
  }

  Future addTrackTheme(TrackTheme trackTheme) async {
    await track_theme_box.addTrackTheme(trackTheme);
  }

  Future deleteTrackTheme(TrackTheme theme) async {
    return track_theme_box.deleteTrackTheme(theme);
  }

  void deleteTrackThemeByName(String name) async {
    await track_theme_box.deleteTrackThemeByName(name);
  }

  Future setTrackTheme(TrackTheme trackTheme, {bool isAdd = false}) async {
    // logger.d('store: $trackTheme');
    await track_theme_box.updateTrackTheme(trackTheme);
  }

  List<TrackTheme> getAllTrackTheme() {
    return track_theme_box.getTrackThemes();
  }

  Future checkAndInitTrackTheme() async {
    return track_theme_box.initTrackTheme();
  }

  TrackTheme? getTrackTheme(String themeName) {
    return track_theme_box.getTrackTheme(themeName);
  }

  TrackSession? getTrackBrowserLastSession([String id = '1']) {
    return setting_box.getCurrentSession(id);
  }

  void setTrackBrowserLastSession(TrackSession session, [String id = '1']) async {
    setting_box.setCurrentBrowserSession(session, id);
  }

  ///
  /// for track session list page
  ///
  Future<List<TrackSession>> getSessionList([String? speciesId]) async {
    return await SessionListProvider.getSessions();
  }

  void addSession(TrackSession session) {
    SessionListProvider.saveSession(session);
  }

  void deleteSession(TrackSession session) {
    SessionListProvider.deleteSession(session);
  }

  void clearSession() {
    SessionListProvider.deleteAll();
  }

  /// to save every species session
  void saveSpeciesLastSession(TrackSession session) {
    SpeciesLastSessionProvider.saveSession(session);
  }

  /// get session by species
  TrackSession? getSpeciesLastSession(String speciesId) {
    return species_session_box.getSpeciesSession(speciesId);
  }

  List<HighlightRange> getHighlights() {
    return highlight_box.loadHighlights();
  }

  Future addOrPutHighlight(HighlightRange highlight) async {
    await highlight_box.addHighlight(highlight);
  }

  Future deleteHighlight(HighlightRange highlight) async {
    await highlight_box.deleteHighlight(highlight);
  }

  num getTrackThemeVersion() {
    return setting_box.getTrackThemeVersion();
  }

  setTrackThemeVersion(int version) async {
    await setting_box.setTrackThemeVersion(version);
  }

  void setCustomTrackStyles(String speciesId, Map<String, TrackStyle> styleMap) async {
    if (styleMap.length == 0) return;
    await custom_track_styles_box.setCustomTrackStyles(speciesId, styleMap);
  }

  Map<String, TrackStyle>? getCustomTrackStyles(String? speciesId) {
    if (null == speciesId) return null;
    return custom_track_styles_box.getCustomTrackStyles(speciesId);
  }

  void setGroupedTrackStyle(String speciesId, TrackStyle? style) async {
    if (style == null) return;
    await grouped_track_style_box.setGroupedTrackStyle(speciesId, style);
  }

  TrackStyle? getGroupedTrackStyle(String? speciesId) {
    if (null == speciesId) return null;
    return grouped_track_style_box.getGroupedTrackStyle(speciesId);
  }

  List<String> getGroupedTracks(String? speciesId) {
    if (null == speciesId) return [];
    return grouped_track_list_box.getGroupedTracks(speciesId);
  }

  setGroupedTracks(String? speciesId, List<String> tracks) async {
    if (speciesId == null) return;
    grouped_track_list_box.setGroupedTracks(speciesId, tracks);
  }

  @override
  Future<SiteItem?> findSiteByUrl(String url) async {
    return null;
  }

  @override
  List<List<String>> getCompareHistory(String trackId) {
    throw UnimplementedError();
  }

  @override
  void addCompareHistory(String scId, List<String> features) {
    throw UnimplementedError();
  }

  @override
  void deleteCompareHistory(String scId, List<String> features) {
    throw UnimplementedError();
  }

  @override
  List<Map> getShortenList() {
    throw UnimplementedError();
  }

  @override
  void updateShortener(String supplier, Map data) {
    throw UnimplementedError();
  }

  @override
  Map<String, TrackStyle> getGroupedTrackStyleMap(String speciesId) {
    throw UnimplementedError();
  }
}
