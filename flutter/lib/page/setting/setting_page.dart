import 'package:dartx/dartx.dart' as dx;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:flutter_smart_genome/base/container_config.dart';
import 'package:flutter_smart_genome/base/ui_config.dart';
import 'package:flutter_smart_genome/components/app_update/update_manager.dart';
import 'package:flutter_smart_genome/components/setting_config_widget.dart';
import 'package:flutter_smart_genome/components/sgs_logo.dart';
import 'package:flutter_smart_genome/mixin/view_size_mixin.dart';
import 'package:flutter_smart_genome/page/setting/app_layout_preview_widget.dart';
import 'package:flutter_smart_genome/page/setting/cache_manage_widget.dart';
import 'package:flutter_smart_genome/page/setting/theme_list_widget.dart';
import 'package:flutter_smart_genome/page/setting/track_curve.dart';
import 'package:flutter_smart_genome/service/public_service.dart';
import 'package:flutter_smart_genome/service/sgs_config_service.dart';
import 'package:flutter_smart_genome/storage/base_store_provider.dart';

enum SettingType {
  appLayout,
  theme,
  theme_mode,
  track_orientation,
  track_animation,
  track_animation_enabled,
  track_animation_duration,
  track_animation_curve,
  force_desktop_layout,
  cache,
  about,
  account_species_manage,
  account_user_manage,
  account_file_manage,
}

Future<T?> showSettingDialog<T>(BuildContext context) async {
  var dialog = AlertDialog(
    contentPadding: EdgeInsets.zero,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    clipBehavior: Clip.antiAlias,
    content: ConstrainedBox(
      child: SettingPage(),
      constraints: BoxConstraints.tightFor(width: 1000, height: 620),
    ),
  );

  return showGeneralDialog(
      context: context,
      barrierColor: Theme.of(context).colorScheme.surfaceVariant,
      barrierDismissible: true,
      barrierLabel: 'Settings',
      transitionDuration: Duration(milliseconds: 350),
      pageBuilder: (ctx, a1, a2) {
        return Container();
      },
      transitionBuilder: (ctx, a1, a2, child) {
        var curve = Curves.decelerate.transform(a1.value);
        return Transform.scale(scale: curve, child: Opacity(opacity: a1.value, child: dialog));
      });

  return showDialog(
    context: context,
    barrierColor: Theme.of(context).colorScheme.background.withOpacity(.35), // Colors.black54.withOpacity(.35),
    builder: (c) => dialog,
  );
}

class SettingPage extends StatefulWidget {
  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> with ViewSizeMixin {
  late List<SettingItem> _basicSettingList;

  Axis _currentTrackOrientation = Axis.horizontal;
  static SettingItem? _currentSettingItem;

  @override
  void initState() {
    super.initState();
    _basicSettingList = _mainSettingList();
    _currentSettingItem ??= _basicSettingList[0];
  }

  // ThemeMode get _themeMode => SgsConfigService.get()!.themeMode;

  bool get _ideMode => SgsConfigService.get()!.ideMode;

  bool get _trackAnimation => SgsConfigService.get()!.trackAnimation;

  List<SettingItem> _mainSettingList() {
    return [
//      SettingItem.button(
//        prefix: Icon(Icons.swap_horizontal_circle),
//        title: 'Track Orientation',
//        key: SettingType.track_orientation,
//        value: _currentTrackOrientation,
//        valueBuilder: (value) {
//          Axis ais = value as Axis;
//          return Icon(ais == Axis.horizontal ? Icons.border_horizontal : Icons.border_vertical);
//        },
//      ),
      SettingItem.button(
        prefix: Icon(MaterialCommunityIcons.page_layout_sidebar_right),
        title: 'Prefer Layout Mode',
        key: SettingType.appLayout,
        value: Colors.blueAccent,
        valueBuilder: (value) {
          return Icon(MaterialCommunityIcons.page_layout_sidebar_right);
        },
      ),
      SettingItem.button(
        prefix: Icon(Icons.color_lens),
        title: 'Color Theme',
        key: SettingType.theme,
        value: Colors.blueAccent,
        valueBuilder: (value) {
          return Icon(Icons.color_lens);
        },
      ),
      // SettingItem.button(
      //   prefix: Icon(Icons.settings_brightness),
      //   title: 'Theme Mode',
      //   key: SettingType.theme_mode,
      //   value: _themeMode,
      //   valueBuilder: (value) {
      //     if (_themeMode == ThemeMode.dark) return Icon(Icons.brightness_4);
      //     if (_themeMode == ThemeMode.light) return Icon(Icons.brightness_high);
      //     return Icon(Icons.brightness_auto);
      //   },
      // ),
      SettingItem.button(
        prefix: Icon(Icons.ac_unit),
        title: 'Track Animation',
        key: SettingType.track_animation,
        value: _trackAnimation,
        valueBuilder: (value) {
          return Icon(_trackAnimation ? MaterialCommunityIcons.toggle_switch : MaterialCommunityIcons.toggle_switch_off);
        },
      ),
      SettingItem.toggle(
        prefix: Icon(Icons.desktop_mac),
        title: 'Force Desktop Layout',
        key: SettingType.force_desktop_layout,
        value: SgsConfigService.get()!.ideMode,
      ),
      SettingItem.button(
        prefix: Icon(Icons.sd_storage),
        title: 'Cache',
        key: SettingType.cache,
        valueBuilder: (value) {
          return Icon(Icons.keyboard_arrow_right);
        },
      ),
      SettingItem.button(
        prefix: Icon(Icons.info_outline),
        title: 'About SGS',
        key: SettingType.about,
        valueBuilder: (value) {
          return Icon(Icons.keyboard_arrow_right);
        },
      ),
    ];
  }

  List<SettingItem> _orientationSettingList() {
    return [
      SettingItem.checkGroup(
        title: 'Horizontal',
        key: SettingType.track_orientation,
        value: _currentTrackOrientation,
        options: [
          OptionItem('Horizontal', Axis.horizontal, Icon(Icons.border_horizontal)),
          OptionItem('Vertical', Axis.vertical, Icon(Icons.border_vertical)),
        ],
      ),
    ];
  }

  List<SettingItem> _animationSettingList() {
    return [
      SettingItem.toggle(
        title: 'Enabled',
        key: SettingType.track_animation_enabled,
        prefix: Icon(Icons.animation),
        value: _trackAnimation,
      ),
      SettingItem.range(
        title: 'Duration',
        key: SettingType.track_animation_duration,
        prefix: Icon(Icons.timer),
        value: BaseStoreProvider.get().getTrackAnimationDuration(),
        min: 100,
        max: 800,
        step: 50,
      ),
      SettingItem.checkGroup(
        title: 'Animation curve',
        key: SettingType.track_animation_curve,
        value: findCurve(),
        options: curveMap.keys.map((key) => OptionItem(key, key, SizedBox(width: 20))).toList(),
      ),
    ];
  }

  String? findCurve() {
    return curveMap.keys.firstOrNullWhere((key) => SgsConfigService.get()!.trackAnimationCurve == curveMap[key]!);
  }

  @override
  Widget build(BuildContext context) {
    bool _mobile = isMobile(context);
    var _listView = _buildSettingList(_mobile);
    if (_mobile) {
      return Scaffold(
        appBar: AppBar(title: Text('Settings')),
        body: _listView,
      );
    }

    Widget body = Container(
//      padding: _bigScreen ? EdgeInsets.symmetric(vertical: 30) : null,
      decoration: BoxDecoration(
        border: Border(top: BorderSide(width: 1, color: Theme.of(context).dividerColor)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
//            if (_bigScreen) Expanded(child: SizedBox(), flex: 2),
          Expanded(
            child: _listView,
            flex: 2,
          ),
          VerticalDivider(width: 1),
          Expanded(child: _buildTabletSettingContent(), flex: 4),
//            if (_bigScreen) Expanded(child: SizedBox(), flex: 2),
        ],
      ),
    );
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: body,
    );
  }

  Widget _buildSettingList(bool _mobile) {
    return SettingListWidget(
      settings: _basicSettingList,
      currentKey: _mobile ? null : _currentSettingItem?.key,
      onItemTap: _onSettingTap,
      onItemChanged: (p, item) {
        if (item.key == SettingType.track_animation) {
          setState(() {
            SgsConfigService.get()!.trackAnimation = item.value;
            BaseStoreProvider.get().setTrackAnimation(item.value);
          });
        } else if (item.key == SettingType.force_desktop_layout) {
          setState(() {
            SgsConfigService.get()!.ideMode = !SgsConfigService.get()!.ideMode;
            BaseStoreProvider.get().setIdeMode(SgsConfigService.get()!.ideMode);
          });
          //todo
        }
      },
    );
  }

  Widget _buildTabletSettingContent() {
    Widget content;
    if (_currentSettingItem?.key == SettingType.appLayout) {
      content = Container(
        child: AppLayoutPreviewWidget(
          currentLayout: SgsConfigService.get()!.appLayout,
          onItemClick: (layout) {
            Navigator.of(context).maybePop(true);
            SgsConfigService.get()!.changeAppLayout(layout);
          },
        ),
      );
    } else if (_currentSettingItem!.key == SettingType.theme) {
      content = Container(
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        child: ThemeListWidget(
          itemSpace: 20,
          columns: 4,
          onColorSelect: (theme) => _onThemeColorChange(theme),
        ),
      );
    } else if (_currentSettingItem!.key == SettingType.track_orientation) {
      content = Container(
        padding: EdgeInsets.symmetric(horizontal: 30),
        child: SettingListWidget(
          settings: _orientationSettingList(),
          onItemChanged: (p, item) {
            setState(() {
              _currentTrackOrientation = item.value;
              _basicSettingList = _mainSettingList();
            });
          },
        ),
      );
    } else if (_currentSettingItem!.key == SettingType.cache) {
      content = CacheManageWidget();
    } else if (_currentSettingItem!.key == SettingType.track_animation) {
      content = Container(
        padding: EdgeInsets.symmetric(horizontal: 30),
        child: SettingListWidget(
          settings: _animationSettingList(),
          onItemChanged: _handleAnimationChange,
        ),
      );
    } else if (_currentSettingItem!.key == SettingType.about) {
      content = Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SgsLogo(fontSize: 40),
            SizedBox(height: 20),
            Text('v${PublicService.get()!.appInfo?.version}', style: Theme.of(context).textTheme.bodyMedium),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                UpdateManager().checkUpdate(delay: 0);
              },
              child: Text('Check update'),
            ),
          ],
        ),
      );
    } else {
      content = Container(
        decoration: defaultContainerDecoration(context),
      );
    }

    return Material(
//      borderRadius: defaultContainerRadius,
      color: defaultContainerColor(context),
      child: Column(
        children: <Widget>[
//          Padding(
//            padding: const EdgeInsets.symmetric(vertical: 30),
//            child: Text('${_currentSettingItem?.title}', style: TextStyle(fontWeight: FontWeight.w400), textScaleFactor: 1.3),
//          ),
          Expanded(child: content),
        ],
      ),
    );
  }

  void handleThemeModeChange(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.system:
        final brightness = WidgetsBinding.instance.window.platformBrightness;
        SystemChrome.setSystemUIOverlayStyle(brightness == Brightness.dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark);
        break;
      case ThemeMode.light:
        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
        break;
      case ThemeMode.dark:
        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
        break;
    }
    setState(() {});
    // SgsConfigService.get()!.changeThemeMode(themeMode);
  }

  _handleAnimationChange(SettingItem? p, SettingItem item) {
    if (item.key == SettingType.track_animation_enabled) {
      SgsConfigService.get()!.trackAnimation = item.value;
      BaseStoreProvider.get().setTrackAnimation(item.value);
    } else if (item.key == SettingType.track_animation_duration) {
      double dur = item.value;
      BaseStoreProvider.get().setTrackAnimationDuration(dur.toInt());
    } else if (item.key == SettingType.track_animation_curve) {
      // print('curve ---> ${item.value}');
      SgsConfigService.get()!.trackAnimationCurve = curveMap[item.value]!;
    }
  }

  void _onSettingTap(SettingItem settingItem, Rect menuRect) {
    if (!isMobile(context)) {
      setState(() {
        _currentSettingItem = settingItem;
      });
      return;
    }
    if (settingItem.key == SettingType.track_orientation) {
      _showTrackOrientationOptionDialog();
    } else if (settingItem.key == SettingType.theme) {
      _buildThemeDialog();
    } else if (settingItem.key == SettingType.cache) {
      _showCacheDialog();
    }
  }

  void _showTrackOrientationOptionDialog() async {
    var dialog = AlertDialog(
      title: Text('Track orientation'),
      content: SettingListWidget(
        settings: _orientationSettingList(),
        onItemTap: (axis, ctx) => Navigator.of(context).pop(axis),
      ),
    );
    var result = await showDialog(context: context, builder: (context) => dialog);
    if (result == null) return;
    setState(() {
      _currentTrackOrientation = result;
    });
  }

  void _onThemeColorChange(int index) {
    // var index = ThemeColors.indexOf(color);
    BaseStoreProvider.get().setThemeColor(index);
    SgsConfigService.get()!.changeTheme(index);
  }

  void _buildThemeDialog() async {
    bool _isMobile = isMobile(context);
    double _width = MediaQuery.of(context).size.width * .85;
    if (_width > 400) _width = 400;
    double _space = _isMobile ? 8 : 16;
    var dialog = AlertDialog(
      title: Text('Select theme color', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
      contentPadding: EdgeInsets.all(10.0),
      content: Container(
        padding: EdgeInsets.all(10),
        constraints: BoxConstraints.tightFor(width: _width),
        child: ThemeListWidget(
          itemSpace: _space,
          onColorSelect: (i) {
            _onThemeColorChange(i);
            Navigator.of(context).pop();
          },
        ),
      ),
    );
    showDialog(context: context, builder: (context) => dialog);
  }

  void _showCacheDialog() async {
    bool _isMobile = isMobile(context);
    double _width = MediaQuery.of(context).size.width * .85;
    if (_width > 400) _width = 400;
    double _space = _isMobile ? 8 : 16;
    var dialog = AlertDialog(
      title: Text('Cache Setting', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
      contentPadding: EdgeInsets.all(10.0),
      content: Container(
        padding: EdgeInsets.all(10),
        constraints: BoxConstraints.tightFor(width: _width),
        child: CacheManageWidget(),
      ),
    );
    showDialog(context: context, builder: (context) => dialog);
  }

  void _clearCacheConfirm(SettingType type) async {
    var dialog = AlertDialog(
      title: Text('Confirm clear cache?'),
      actions: [
        TextButton(
          child: Text('NO'),
          onPressed: () => Navigator.of(context).pop(false),
        ),
        TextButton(
          child: Text('YES'),
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ],
    );
    var result = await showDialog(context: context, builder: (c) => dialog);
    if (result != null && result) {
      _clearCache(type);
    }
  }

  void _clearCache(SettingType type) async {
    // if (type == SettingType.cache) {
    //   Get.offAllNamed(RoutePath.initialize);
    //   EntryLogic.get().check();
    //   PlatformAdapter.create().setWindowSize(Size(860, 600));
    //   await BaseStoreProvider.get().clear();
    //   await SgsConfigService.get()!.init();
    //   SgsBrowseLogic.safe()?.initTheme();
    // } else {
    //   var _loading = BotToast.showLoading();
    //   await DioHelper().clearCache();
    //   await PlatformAdapter.create().deleteCacheFile('${SgsConfigService.get()!.applicationDocumentsPath}/sc');
    //   _loading?.call();
    //   Navigator.of(context).maybePop(true);
    //   showToast(text: 'Data cache clear success!');
    // }
  }
}
