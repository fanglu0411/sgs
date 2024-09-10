import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/bean/site_item.dart';
import 'package:flutter_smart_genome/components/window/prompt_window.dart';

import 'platform_stub.dart'
// ignore: uri_does_not_exist
    if (dart.library.html) '../entry/browser_adapter.dart'
// ignore: uri_does_not_exist
    if (dart.library.io) '../entry/native_adapter.dart';

abstract class PlatformAdapter {
  static PlatformAdapter create() => createPlatformAdapter();

  String getLocationOrigin();

  String getLocationHost();

  String getLocationUrl();

  void updateUrl(String url);

  Future deleteCacheFile(String path);

  Future<T?> openUrl<T extends Object>(BuildContext context, String url, {Object arguments});

  Future<bool> saveFile({String filename, dynamic content});

  List<SiteItem> getDefaultSite();

  void openWindow(WindowDataSource dataSource);

  void openBrowser(String url);

  void openTerminal(List<String> params);

  void setWindowSize(Size size, {bool center = true, bool fullscreen = false});

  Future registrySchema(String schema);
}
