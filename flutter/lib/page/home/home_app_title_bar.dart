import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:flutter_smart_genome/base/app_layout.dart';
import 'package:flutter_smart_genome/base/constants.dart';
import 'package:flutter_smart_genome/bean/account_bean.dart';
import 'package:flutter_smart_genome/bean/datasets.dart';
import 'package:flutter_smart_genome/components/app_update/update_manager.dart';
import 'package:flutter_smart_genome/components/setting_config_widget.dart';
import 'package:flutter_smart_genome/components/sgs_logo.dart';
import 'package:flutter_smart_genome/page/admin/project/project_home_view.dart';
import 'package:flutter_smart_genome/page/admin/species/species_edit_page.dart';
import 'package:flutter_smart_genome/page/cell/cell_tool_bar/cell_track_selector_widget.dart';
import 'package:flutter_smart_genome/page/help/help_widget.dart';
import 'package:flutter_smart_genome/page/setting/setting_page.dart';
import 'package:flutter_smart_genome/page/setting/theme_list_widget.dart';
import 'package:flutter_smart_genome/page/species/species_list_widget.dart';
import 'package:flutter_smart_genome/page/track/site_species_selector_widget.dart';
import 'package:flutter_smart_genome/platform/platform_adapter.dart';
import 'package:flutter_smart_genome/routes.dart';
import 'package:flutter_smart_genome/service/sgs_app_service.dart';
import 'package:flutter_smart_genome/service/sgs_config_service.dart';

import 'package:flutter_smart_genome/util/device_info.dart';
import 'package:flutter_smart_genome/util/native_window_util/app_title_bar.dart';
import 'package:flutter_smart_genome/util/widget_util.dart';
import 'package:flutter_smart_genome/widget/basic/bubble_icon_button.dart';
import 'package:flutter_smart_genome/widget/basic/custom_bot_widget.dart';
import 'package:flutter_smart_genome/widget/basic/simple_widget_builder.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher_string.dart';

class HomeTitleBarLogic extends GetxController {
  String? title;

  static HomeTitleBarLogic? get() {
    if (Get.isRegistered<HomeTitleBarLogic>()) {
      return Get.find<HomeTitleBarLogic>();
    }
    return null;
  }

  updateTitle() {
    update();
    // if (kIsWeb) {
    //   SgsAppService.get()?.session?.toShareUrl().then((url) {
    //     PlatformAdapter.create().updateUrl(url);
    //   });
    // }
  }

  void showShare(BuildContext context) {
    WidgetUtil.showShareDialog(context, SgsAppService.get()?.session);
  }

  @override
  void onInit() {
    super.onInit();
    UpdateManager().checkUpdate(delay: 60 * 1000);
  }
}

class HomeAppTitleBar extends StatefulWidget {
  final VoidCallback? onSnapshot;

  const HomeAppTitleBar({Key? key, this.onSnapshot}) : super(key: key);

  @override
  State<HomeAppTitleBar> createState() => _HomeAppTitleBarState();
}

class _HomeAppTitleBarState extends State<HomeAppTitleBar> {
  HomeTitleBarLogic logic = Get.put(HomeTitleBarLogic());

  CancelFunc? _siteFunc;
  CancelFunc? _dataSetFunc;

  Widget _builder(HomeTitleBarLogic logic) {
    final appService = SgsAppService.get()!;
    // String title = AppLayout.SC != SgsConfigService.get()!.appLayout ? '${appService.site?.url}--${appService.site?.currentSpecies}' : '${appService.site?.url}--${CellPageLogic.safe()?.track?.scName}';
    return AppTitleBar(
      child: Center(
          // child: Text(title),
          ),
      leading: [
        if (!GetPlatform.isMacOS || kIsWeb) SgsLogo(fontSize: 12, padding: EdgeInsets.symmetric(horizontal: 6)),
        if (!kIsWeb)
          Builder(builder: (context) {
            return MaterialButton(
              minWidth: 40,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '${SgsAppService.get()!.site?.safeName ?? '-'}',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  Icon(Icons.keyboard_arrow_down, size: 16),
                ],
              ),
              elevation: 0,
              textTheme: ButtonTextTheme.normal,
              onPressed: () => _showServerPop(context),
            );
          }),
        Builder(builder: (context) {
          return MaterialButton(
            elevation: 0,
            textTheme: ButtonTextTheme.normal,
            onPressed: () => _showSpeciesPop(context),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('P ', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Theme.of(context).colorScheme.primary)),
                Text(
                  '${SgsAppService.get()!.site?.currentSpecies ?? '-'}',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                Icon(Icons.keyboard_arrow_down, size: 16),
              ],
            ),
          );
        }),
        if (SgsConfigService.get()!.appLayout == AppLayout.SC) CellTrackSelectorWidget(),
        SizedBox(width: 20),
        IconButton(
          onPressed: () {
            _showProjectInfoDialog();
          },
          icon: Icon(Entypo.info),
          iconSize: 16,
          constraints: BoxConstraints.tight(Size(32, 32)),
          splashRadius: 16,
          tooltip: 'About Project',
          padding: EdgeInsets.zero,
          style: IconButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.primary,
          ),
        ),
        SizedBox(width: 2),
        IconButton(
          onPressed: () => logic.showShare(context),
          icon: Icon(MaterialCommunityIcons.share),
          iconSize: 20,
          tooltip: 'Share url',
          constraints: BoxConstraints.tight(Size(32, 32)),
          splashRadius: 16,
          padding: EdgeInsets.zero,
          style: IconButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
      extras: [
        SimpleDropdownButton(
          initialValue: SgsConfigService.get()!.appLayout,
          tooltip: 'App Layout: ${SgsConfigService.get()!.appLayout.name}',
          items: AppLayout.values,
          borderSide: BorderSide.none,
          childBuilder: (c) => Icon(Feather.layout, size: 20),
          itemBuilder: (l) => (null, Text('${l.name}')),
          itemWidth: 120,
          buttonPadding: EdgeInsets.symmetric(vertical: 6, horizontal: 6),
          minimumSize: Size(32, 34),
          preferDirection: PreferDirection.bottomRight,
          onSelectedChange: (l) {
            SgsConfigService.get()!.changeAppLayout(l);
            setState(() {});
          },
        ),
        Builder(builder: (c) {
          return IconButton(
            onPressed: () => _showThemeListPop(c),
            icon: Icon(AntDesign.skin, size: 18, color: Theme.of(context).colorScheme.primary),
            padding: EdgeInsets.zero,
            constraints: BoxConstraints.tightFor(width: 32, height: 32),
            tooltip: 'Theme',
          );
        }),
        IconButton(
          onPressed: widget.onSnapshot,
          icon: Icon(Icons.screenshot_monitor, size: 20),
          padding: EdgeInsets.zero,
          constraints: BoxConstraints.tightFor(width: 32, height: 32),
          tooltip: 'take screenshot',
        ),
        Builder(builder: (context) {
          Widget _btn = MaterialButton(
            onPressed: () {
              UpdateManager().checkUpdate(delay: 60 * 1000);
              _showSettingMenus(context);
            },
            child: Icon(Ionicons.ios_settings, size: 18),
            shape: RoundedRectangleBorder(),
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            minWidth: 50,
          );
          if (UpdateManager().hasNewVersion) {
            _btn = _btn.withBubble(radius: 4, right: 8, top: 4, child: SizedBox());
          }
          return _btn;
        }),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeTitleBarLogic>(
      init: logic,
      builder: _builder,
    );
  }

  _showThemeListPop(BuildContext context) {
    showAttachedWidget(
      preferDirection: PreferDirection.bottomRight,
      targetContext: context,
      offset: Offset(0, 3),
      attachedBuilder: (cancel) {
        return Material(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          // color: Theme.of(context).colorScheme.surfaceVariant,
          elevation: 6,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 320, maxHeight: 465),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ThemeListWidget(
                columns: 3,
                padding: EdgeInsets.symmetric(horizontal: 14),
                onColorSelect: (c) {
                  cancel.call();
                  SgsConfigService.get()!.changeTheme(c);
                },
              ),
            ),
          ),
        );
      },
    );
  }

  _showSettingMenus(BuildContext context) {
    showAttachedWidget(
        preferDirection: PreferDirection.bottomRight,
        targetContext: context,
        offset: Offset(0, 4),
        attachedBuilder: (cancel) {
          return Material(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            clipBehavior: Clip.antiAlias,
            elevation: 6,
            child: ConstrainedBox(
              constraints: BoxConstraints.tightFor(width: 300),
              child: SettingListWidget(
                settings: [
                  if (UpdateManager().hasNewVersion && !DeviceOS.isWeb)
                    SettingItem.button(title: 'New version update...', key: 'update', prefix: Icon(MaterialCommunityIcons.upload).withBubble(radius: 3, right: 0, child: SizedBox())),
                  SettingItem.button(title: 'Settings ...', key: 'settings', prefix: Icon(Icons.settings_sharp)),
                  SettingItem.button(title: 'Deploy SGS Server', key: 'deploy', prefix: Icon(MaterialCommunityIcons.database_plus)),
                  SettingItem.button(title: 'Document ...', key: 'document', prefix: Icon(Ionicons.md_document)),
                  SettingItem.button(title: 'Feedback ...', key: 'feedback', prefix: Icon(Icons.feedback, size: 20)),
                  SettingItem.button(title: 'About ...', key: 'about', prefix: Icon(Icons.info)),
                ],
                onItemTap: (item, ctx) {
                  cancel();
                  if (item.key == 'deploy') {
                    Get.toNamed(RoutePath.server_create);
                  } else if (item.key == 'update') {
                    UpdateManager().downloadNewVersion();
                  } else if (item.key == 'settings') {
                    showSettingDialog(context);
                  } else if (item.key == 'document') {
                    // showHelpDialog(context);
                    // PlatformAdapter.create().openBrowser(WEBSITE_URL);
                    launchUrlString(WEBSITE_URL);
                  } //
                  else if (item.key == 'feedback') {
                    launchUrlString(FEEDBACK_URL);
                  } //
                  else if (item.key == 'about') {
                    PackageInfo.fromPlatform().then((info) {
                      showAboutDialog(
                        context: context,
                        applicationIcon: SgsLogo(),
                        applicationName: 'SGS',
                        applicationVersion: 'v${info.version}  build:${info.buildNumber}',
                        applicationLegalese: '@2020 SouthWest University',
                      );
                    });
                  } else {}
                },
              ),
            ),
          );
        });
  }

  _showServerPop(BuildContext context) {
    _siteFunc?.call();
    Widget builder(cancel) {
      return SiteSpeciesSelectorWidget(
        axis: Axis.horizontal,
        site: SgsAppService.get()!.site!,
        onChanged: (site) {
          cancel.call();
          SgsAppService.get()!.changeSiteSpecies(site);
        },
        onEvent: () {
          cancel();
          _siteFunc = null;
        },
      );
    }

    return showAttachedWidget(
      targetContext: context,
      preferDirection: PreferDirection.bottomLeft,
      backgroundColor: Colors.transparent,
      onClose: () {
        _siteFunc = null;
      },
      attachedBuilder: (c) {
        return Material(
          elevation: 6,
          clipBehavior: Clip.antiAlias,
          // color: Theme.of(context).dialogBackgroundColor,
          borderRadius: BorderRadius.circular(10),
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: 380, maxWidth: 720, minHeight: 200, maxHeight: 500),
            child: builder(c),
          ),
        );
      },
    );
  }

  _showSpeciesPop(BuildContext context) {
    if (_dataSetFunc != null) return;
    return showAttachedWidget(
      targetContext: context,
      preferDirection: PreferDirection.bottomLeft,
      backgroundColor: Colors.transparent,
      onClose: () {
        _dataSetFunc = null;
      },
      attachedBuilder: (c) {
        Widget pop = DataSetListWidget(
          site: SgsAppService.get()!.site!,
          selectedSpecies: SgsAppService.get()!.site!.currentSpeciesId,
          autoHeight: true,
          refresh: true,
          onItemTap: (sps) {
            c.call();
            _dataSetFunc = null;
            var site = SgsAppService.get()!.site!;
            site
              ..currentSpeciesId = sps.id
              ..currentSpecies = sps.name;
            SgsAppService.get()!.changeSiteSpecies(site);
          },
        );
        return Material(
          elevation: 6,
          borderRadius: BorderRadius.circular(10),
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: 350, maxWidth: 380, maxHeight: 800),
            child: pop,
          ),
        );
      },
    );
  }

  void _showProjectInfoDialog() {
    final appService = SgsAppService.get()!;
    int spsId = appService.species!.indexWhere((e) => e.id == appService.session!.speciesId);
    if (spsId < 0) return;

    Species sps = appService.species![spsId];

    var dialog = (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          clipBehavior: Clip.antiAlias,
          contentPadding: EdgeInsets.zero,
          content: ConstrainedBox(
            constraints: BoxConstraints.expand(width: Get.width * .9),
            child: ProjectHomeView(project: sps, site: appService.site!, previewOnly: true),
          ),
        );
    showDialog(context: context, builder: dialog);
    // Navigator.of(context).pushNamed(RoutePath.project_home_page, arguments: SpeciesEditParams(appService.site!, sps, ));
  }
}
