import 'dart:html' as html;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/bean/site_item.dart';
import 'package:flutter_smart_genome/components/window/prompt_window.dart';
import '../platform/platform_adapter.dart';

PlatformAdapter createPlatformAdapter() => BrowserAdapter();

class BrowserAdapter implements PlatformAdapter {
  static BrowserAdapter _instance = BrowserAdapter._init();

  factory BrowserAdapter() {
    return _instance;
  }

  BrowserAdapter._init();

  String getLocationOrigin() {
    return html.window.location.origin;
  }

  String getLocationHost() {
    return html.window.location.host;
  }

  String getLocationUrl() {
    return html.window.location.href;
  }

  void updateUrl(String url) {
    // html.window.location.href = url;
    html.window.history.replaceState({}, "", url);
  }

  @override
  Future<T> openUrl<T extends Object>(BuildContext context, String url, {Object? arguments}) async {
    String? args = arguments?.toString();
    var result = html.window.open(url, '_blank', args);
    return await Future.delayed(Duration(milliseconds: 50));
  }

  @override
  Future<bool> saveFile({String? filename, content}) async {
    Uint8List data = content as Uint8List;
    var blob = new html.Blob([data], 'image/png');
    var url = html.Url.createObjectUrl(blob);

    var a = html.document.createElement("a");
    a.setAttribute("style", "display: none");
    a.setAttribute("href", url);
    a.setAttribute("download", filename!);

    html.document.body!.append(a);
    a.click();

    html.Url.revokeObjectUrl(url);
    return true;
  }

  @override
  List<SiteItem> getDefaultSite() {
    String url = html.window.location.origin;
    if (url == 'http://0.0.0.0:5200' || url == 'http://localhost:5200') url = 'http://localhost:8080';
    return [
      SiteItem(url: url, isDemoServer: true),
    ];
  }

  @override
  void openBrowser(String url) {
    html.window.open(url, '_blank');
  }

  @override
  void openWindow(WindowDataSource dataSource) {
    List data = dataSource.contents.first.data;
    html.window.open(data.first, 'newwindow', 'width=400,height=400,top=200,left=400,toolbar=no');
  }

  @override
  void openTerminal(List<String> params) {}

  @override
  void setWindowSize(Size size, {bool center = true, bool fullscreen = false}) {}

  @override
  Future deleteCacheFile(String path) async {
    //delete
  }
  @override
  Future registrySchema(String scheme) async {

  }
}
