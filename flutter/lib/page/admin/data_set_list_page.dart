import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/base/global_state.dart';
import 'package:flutter_smart_genome/bean/account_bean.dart';
import 'package:flutter_smart_genome/bean/site_item.dart';
import 'package:flutter_smart_genome/components/window/multi_window_controller.dart';
import 'package:flutter_smart_genome/page/admin/project/project_home_view.dart';
import 'package:flutter_smart_genome/page/admin/sc/edit_sc_page.dart';
import 'package:flutter_smart_genome/page/admin/sc/sc_data_list_view.dart';
import 'package:flutter_smart_genome/page/admin/species/genome_data_list_view.dart';
import 'package:flutter_smart_genome/page/admin/species/species_edit_page.dart';
import 'package:flutter_smart_genome/page/admin/token/token_list.dart';
import 'package:flutter_smart_genome/page/admin/track/edit_track_page.dart';
import 'package:flutter_smart_genome/page/admin/track/track_list_page.dart';
import 'package:flutter_smart_genome/routes.dart';
import 'package:flutter_smart_genome/storage/base_store_provider.dart';

import 'package:flutter_smart_genome/util/device_info.dart';
import 'package:flutter_smart_genome/util/native_window_util/title_bar_wrapper/title_bar_wrapper.dart';
import 'package:flutter_smart_genome/widget/basic/button_group.dart';
import 'package:flutter_smart_genome/widget/basic/custom_bot_widget.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:multiavatar/multiavatar.dart';

class DataSetListPage extends StatefulWidget {
  final SiteItem site;
  final AccountBean account;

  const DataSetListPage({Key? key, required this.site, required this.account}) : super(key: key);

  @override
  State<DataSetListPage> createState() => _DataSetListPageState();
}

class _DataSetListPageState extends State<DataSetListPage> {
  int _mobileSelectItem = 0;

  MyNavigatorObserver navigatorObserver = MyNavigatorObserver();

  String? iconSvg;

  late SiteItem _site;

  @override
  void initState() {
    iconSvg = multiavatar('${widget.account.username}', trBackground: false);
    accountObs.value = widget.account;
    _site = widget.site;

    super.initState();
    // Future.delayed(Duration(milliseconds: 800)).then((v) {
    //   showHelp(null);
    // });
    accountObs.listen(_onAccountChange);
  }

  void _onAccountChange(AccountBean? account) {
    _site = SiteItem(url: account!.url);
    ngKey.currentState!.popUntil((route) => route.settings.name == RoutePath.manage_genome_list);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(40),
        child: TitleBarWrapper(
          child: AppBar(
            title: ObxValue<Rx<AccountBean?>>((s) {
              return Text('Data Manager - ${s.value?.url}');
            }, accountObs),
            // foregroundColor: Colors.black54,
            backgroundColor: Theme.of(context).dialogBackgroundColor,
            elevation: 0,
            centerTitle: true,
          ),
          extras: [
            Builder(builder: (context) {
              return IconButton(
                onPressed: () {
                  showAdminManager(context);
                },
                // iconSize: 20,
                padding: EdgeInsets.zero,
                icon: SvgPicture.string(iconSvg!, width: 28, height: 28),
                // icon: Icon(Icons.supervised_user_circle_rounded),
                tooltip: '${widget.account.username} - Token Manager',
                splashRadius: 22,
                // style: IconButton.styleFrom(foregroundColor: Colors.red),
              );
            }),
            // Builder(builder: (context) {
            //   return IconButton(
            //     onPressed: () {
            //       showHelp(context);
            //     },
            //     padding: EdgeInsets.zero,
            //     tooltip: 'HELP',
            //     icon: Icon(Icons.help_outline),
            //     iconSize: 16,
            //     splashRadius: 22,
            //   );
            // }),
            if (DeviceOS.isMacOS)
              IconButton(
                onPressed: () {
                  multiWindowController.closeSelf();
                },
                iconSize: 20,
                icon: Icon(Icons.close),
                padding: EdgeInsets.zero,
                tooltip: 'CLOSE',
                splashRadius: 22,
                style: IconButton.styleFrom(foregroundColor: Colors.red),
              ),
          ],
        ),
      ),
      body: _genome(),
    );
  }

  GlobalKey<NavigatorState> ngKey = GlobalKey();

  bool _isTokenManager = false;

  Widget _genome() {
    return Navigator(
      key: ngKey,
      initialRoute: RoutePath.manage_genome_list,
      observers: [navigatorObserver],
      onGenerateRoute: (RouteSettings settings) {
        bool asDialog = false;
        Widget page;
        switch (settings.name) {
          case RoutePath.manage_genome_list:
            page = GenomeDataListView(siteItem: _site, account: accountObs.value!, cardView: true);
            break;
          case RoutePath.manage_genome_edit:
            asDialog = true;
            SpeciesEditParams? params = settings.arguments as SpeciesEditParams?;
            page = SpeciesEditPage(site: params!.site, account: accountObs.value!);
            break;
          case RoutePath.manage_genome_tracks:
            asDialog = true;
            SpeciesEditParams? params = settings.arguments as SpeciesEditParams?;
            page = TrackListPage(site: params!.site, species: params.species!, account: accountObs.value!);
            break;
          case RoutePath.manage_genome_track_add:
            asDialog = true;
            SpeciesEditParams? params = settings.arguments as SpeciesEditParams?;
            page = EditTrackPage(site: _site, species: params!.species, account: accountObs.value!);
            break;
          case RoutePath.manage_sc_add:
            asDialog = true;
            SpeciesEditParams? params = settings.arguments as SpeciesEditParams?;
            page = EditSCPage(site: _site, species: params!.species!, asPage: true);
            break;
          case RoutePath.project_home_page:
            SpeciesEditParams params = settings.arguments as SpeciesEditParams;
            page = ProjectHomeView(project: params.species!, site: params.site);
            break;
          case '/token':
            page = TokenListPage(site: _site, account: accountObs.value!);
            break;
          default:
            page = Scaffold(body: Center(child: Text('Page not found')));
            break;
        }
        return MaterialPageRoute<dynamic>(
          builder: (context) => page,
          fullscreenDialog: asDialog,
          settings: settings,
        );
      },
    );
  }

  Widget _sc() {
    return Navigator(
      initialRoute: RoutePath.manage_sc_list,
      onGenerateRoute: (RouteSettings settings) {
        bool asDialog = false;
        Widget page;
        switch (settings.name) {
          case RoutePath.manage_sc_list:
            page = SCDataListView(site: widget.site);
            break;
          case RoutePath.manage_sc_add:
            asDialog = true;
            SpeciesEditParams? params = settings.arguments as SpeciesEditParams?;
            page = EditSCPage(site: widget.site, species: params!.species!, asPage: true);
            break;
          default:
            page = Scaffold(body: Center(child: Text('Page not found')));
            break;
        }
        return MaterialPageRoute<dynamic>(
          builder: (context) => page,
          fullscreenDialog: asDialog,
          settings: settings,
        );
      },
    );
  }

  Widget _navs() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        ButtonGroup(axis: Axis.vertical, children: [
          ElevatedButton(
            onPressed: () {},
            child: Text('Genome Data List'),
            style: ElevatedButton.styleFrom(
              minimumSize: Size(100, 60),
            ),
          ),
          TextButton(
            onPressed: () {},
            child: Text('SC Data List'),
            style: TextButton.styleFrom(
              minimumSize: Size(100, 60),
            ),
          ),
        ]),
      ],
    );
  }

  void showHelp(BuildContext? context) {
    var size = Get.size;
    showAttachedWidget(
      targetContext: context,
      preferDirection: PreferDirection.bottomLeft,
      target: context == null ? Offset(size.width - 30, 30) : null,
      backgroundColor: Colors.transparent,
      onClose: () {},
      attachedBuilder: (c) {
        return Material(
          color: Get.theme.dialogBackgroundColor,
          elevation: 8,
          borderRadius: BorderRadius.circular(8),
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: 320, maxWidth: 480, minHeight: 200, maxHeight: 500),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text('1.xxx\n2.xxx\n3.dssss\n'),
            ),
          ),
        );
      },
    );
  }

  void showAdminManager(BuildContext? context) {
    var size = Get.size;
    showAttachedWidget(
      targetContext: context,
      preferDirection: PreferDirection.bottomLeft,
      // target: context == null ? Offset(size.width - 30, 30) : null,
      backgroundColor: Colors.transparent,
      onClose: () {},
      attachedBuilder: (c) {
        return Material(
          // color: Get.theme.dialogBackgroundColor,
          elevation: 8,
          borderRadius: BorderRadius.circular(8),
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: 240, maxWidth: 280, minHeight: 40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(Icons.token),
                  title: Text('Token Manager'),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8))),
                  onTap: () {
                    c.call();
                    if (navigatorObserver.isTokenManager) return;
                    ngKey.currentState?.pushNamed('/token');
                  },
                ),
                Divider(height: 1, thickness: 1),
                ListTile(
                  leading: SvgPicture.string(iconSvg!, width: 26, height: 26),
                  trailing: TextButton.icon(
                      onPressed: () {
                        c.call();
                        _logout();
                      },
                      icon: Icon(Icons.logout),
                      label: Text('Logout')),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(bottomLeft: Radius.circular(8), bottomRight: Radius.circular(8))),
                  title: Text('${widget.account.username}'),
                  onTap: () {},
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _logout() async {
    if (kWindowType == WindowType.dataManager) {
      multiWindowController.notifyMainWindow(WindowCallEvent.logout.name, widget.account.toJson());
      multiWindowController.closeSelf();
    } else {
      BaseStoreProvider.get().deleteAccountByUrl(widget.account.url);
      Navigator.of(context).popUntil((route) => route.settings.name == RoutePath.home);
    }
  }
}

class MyNavigatorObserver extends NavigatorObserver {
  bool isTokenManager = false;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    isTokenManager = route.settings.name == '/token';
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    isTokenManager = (previousRoute?.settings.name == '/token');
  }
}
