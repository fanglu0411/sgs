import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/base/app_layout.dart';
import 'package:flutter_smart_genome/bean/account_bean.dart';
import 'package:flutter_smart_genome/bean/site_item.dart';
import 'package:flutter_smart_genome/page/site/site_logic.dart';
import 'package:flutter_smart_genome/platform/platform_adapter.dart';
import 'package:flutter_smart_genome/widget/track/base/track_session.dart';
import 'package:hive/hive.dart';

Box _box() => Hive.box('sgs-settings');

void setThemeColor(int colorIndex) => _box().put('theme-color', colorIndex);

int getThemeColor() => _box().get('theme-color', defaultValue: 5);

bool getIdeMode() => _box().get('ide-mode', defaultValue: true);

void setIdeMode(bool ideMode) => _box().put('ide-mode', ideMode);

bool getTrackAnimation() => _box().get('track-animation', defaultValue: true);

void setTrackAnimation(bool animation) => _box().put('track-animation', animation);

int getTrackAnimationDuration() => _box().get('track-animation-duration', defaultValue: 400);

void setTrackAnimationDuration(int duration) => _box().put('track-animation-duration', duration);

void setThemeMode(ThemeMode mode) => _box().put('theme-mode', mode.index);

ThemeMode getThemeMode() {
  int idx = _box().get('theme-mode', defaultValue: ThemeMode.system.index);
  return ThemeMode.values[idx];
}

bool showCase() => _box().get('show-case-finish', defaultValue: false);

void finishShowCase() => _box().put('show-case-finish', true);

setCurrentSite(SiteItem site) async {
  await _box().put('current-site', site.toMap());
}

SiteItem? getCurrentSite() {
  Map? _site = _box().get('current-site', defaultValue: null);
  if (null == _site) {
    return PlatformAdapter.create().getDefaultSite().first;
  }
  return SiteItem.fromMap(_site);
}

void setCurrentAccount(AccountBean account) => _box().put('current-account', account.toJson());

Future deleteCurrentAccount() async {
  await _box().delete('current-account');
}

AccountBean? getCurrentAccount() {
  Map? map = _box().get('current-account', defaultValue: null);
  if (null == map) return null;
  return AccountBean.fromMap(map);
}

String getCurrentTrackThemeName() => _box().get('current-track-theme', defaultValue: 'theme_jbrowser');

void setCurrentTrackThemeName(String name) {
  _box().put('current-track-theme', name);
}

void setCurrentBrowserSession(TrackSession session, [String id = '1']) {
  _box().put('current-session-${id}', session.toMap());
}

TrackSession? getCurrentSession([String id = '1']) {
  Map? _map = _box().get('current-session-${id}');
  if (null == _map) return null;
  return TrackSession.fromMap(_map);
}

void setSpeciesLastSession(TrackSession session) {
  _box().put('species-last-session-${session.speciesId}', session.toMap());
}

TrackSession? getSpeciesLastSession(String speciesId) {
  Map? _map = _box().get('species-last-session-${speciesId}');
  if (null == _map) return null;
  return TrackSession.fromMap(_map);
}

Future setTrackThemeVersion(int version) async {
  await _box().put('theme-version', version);
}

int getTrackThemeVersion() {
  return _box().get('theme-version', defaultValue: 1);
}

int getAppVersion() {
  return _box().get('app-version', defaultValue: 14);
}

Future<void> setAppVersion(int version) {
  return _box().put('app-version', version);
}

setAppLayout(AppLayout layout) async {
  await _box().put('app-layout', layout.name);
}

AppLayout getAppLayout() {
  var name = _box().get('app-layout', defaultValue: AppLayout.gnome.name);
  return fromName(name);
}

// void setCustomTrackStyles(Map styleMap) async {
//   await _box().put('custom-track-styles', styleMap);
// }
//
// Map getCustomTrackStyles() {
//   return _box().get('custom-track-styles', defaultValue: {});
// }
//
// /// grouped style
// void setGroupedTrackStyle(Map styleMap) async {
//   await _box().put('grouped-track-style', styleMap);
// }
//
// Map getGroupedTrackStyle() {
//   return _box().get('grouped-track-style', defaultValue: {'dark': {}, 'light': {}});
// }

Future<int> clear() => _box().clear();
