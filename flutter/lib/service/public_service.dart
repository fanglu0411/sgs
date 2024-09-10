import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/R.dart';
import 'package:flutter_smart_genome/base/background_mode.dart';
import 'package:flutter_smart_genome/m3/material_color_source.dart';
import 'package:flutter_smart_genome/storage/base_store_provider.dart';

import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

class CustomStateColor extends WidgetStateColor {
  CustomStateColor(super.defaultValue);

  @override
  Color resolve(Set<WidgetState> states) {
    if (states.contains(WidgetState.focused)) {
      return withOpacity(.3);
    }
    if (states.contains(WidgetState.hovered)) {
      return withOpacity(.5);
    }
    if (states.contains(WidgetState.selected)) {
      return withOpacity(.25);
    }
    return withOpacity(.05);
  }
}

//多窗口下公用的service
class PublicService extends GetxService {
  static PublicService? get() {
    if (Get.isRegistered<PublicService>()) {
      return Get.find<PublicService>();
    }
    return null;
  }

  late List<MaterialColorSource> _colorSources;

  List<MaterialColorSource> get colorSources => _colorSources;
  late MaterialColorSource materialColorSource;

  late int _themeIndex;

  PackageInfo? appInfo;

  int get buildNumber => int.tryParse(appInfo?.buildNumber ?? '-') ?? R.versionCode;

  int get themeIndex => _themeIndex;

  late ThemeMode themeMode = ThemeMode.system;
  ThemeData? _themeData;

  late BackgroundMode _backgroundMode = BackgroundMode.classic;

  BackgroundMode get backgroundMode => _backgroundMode;

  ThemeData? _darkThemeData;

  ThemeData? get themeData => _themeData;

  ThemeData? get darkThemeData => _darkThemeData;

  init() async {
    _colorSources = materialColorSources;
    _backgroundMode = BackgroundMode.classic;
    // _materialThemes = await loadThemes();
    appInfo = await PackageInfo.fromPlatform().catchError((e) {
      return PackageInfo(appName: 'SGS', packageName: 'flutter_smart_genome', version: R.version, buildNumber: '${R.versionCode}');
    });
  }

  void setBackgroundMode(int mode) {
    _backgroundMode = BackgroundMode.values[mode.clamp(0, BackgroundMode.values.length - 1)];
    changeTheme(themeIndex);
  }

  setTheme(int themeIndex, ThemeMode themeMode) async {
    _themeIndex = themeIndex;
    this.themeMode = themeMode;
    materialColorSource = getMaterialThemeSourceByIndex(themeIndex);
    _themeData = await _buildThemeData(materialColorSource);
    _darkThemeData = await _buildThemeData(materialColorSource, brightness: Brightness.dark);
    _notifyThemeUpdate();
  }

  MaterialColorSource getMaterialThemeSourceByIndex(int index) => _colorSources[index % _colorSources.length];

  void _changeMaterialTheme(MaterialColorSource colorSource) async {
    materialColorSource = colorSource;
    _themeData = await _buildThemeData(colorSource);
    _darkThemeData = await _buildThemeData(colorSource, brightness: Brightness.dark);
    _notifyThemeUpdate();
  }

  void _notifyThemeUpdate() {
    Get.rootController.theme = _themeData; //似乎Get.changeTheme(只会对theme mode 改变才有效果)
    Get.rootController.darkTheme = _darkThemeData;
    Get.rootController.themeMode = themeMode;
    Get.rootController.update();
    // Get.changeTheme(_themeData);
    // Get.changeThemeMode(themeMode);
    // EntryLogic.get().show();

    // if (brightnessChanged) {
    Future.delayed(Duration(milliseconds: 800)).then((r) {
      WidgetsBinding.instance.handlePlatformBrightnessChanged();
    });
    // }
  }

  /// change theme color
  void changeTheme(int i) {
    BotToast.cleanAll();
    _themeIndex = i;
    BaseStoreProvider.get().setThemeColor(i);
    _changeMaterialTheme(getMaterialThemeSourceByIndex(i));
  }

  Future<ThemeData> _buildThemeData(MaterialColorSource colorSource, {Brightness brightness = Brightness.light}) async {
    ColorScheme colorScheme = await colorSource.colorScheme(brightness: brightness, backgroundMode: backgroundMode);
    Color dividerColor = brightness == Brightness.light ? colorScheme.outlineVariant.withOpacity(.45) : colorScheme.outlineVariant.withOpacity(.75);
    return ThemeData(
      colorScheme: colorScheme,
      brightness: brightness,
      dividerColor: dividerColor,
      dividerTheme: DividerThemeData(color: dividerColor, thickness: 1.5),
      scrollbarTheme: ScrollbarThemeData(interactive: true),
      tooltipTheme: TooltipThemeData(
        padding: EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      ),
      pageTransitionsTheme: PageTransitionsTheme(
        builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: ZoomPageTransitionsBuilder(),
          TargetPlatform.windows: ZoomPageTransitionsBuilder(),
          TargetPlatform.linux: ZoomPageTransitionsBuilder(),
        },
      ),
    );
  }

  changeThemeMode(int i) {
    themeMode = ThemeMode.values[i];
    BaseStoreProvider.get().setThemeMode(themeMode);
    // Get.rootController.themeMode = themeMode;
    Get.changeThemeMode(themeMode);
    // Get.rootController.update();
  }
}
