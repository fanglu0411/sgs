import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:flutter_smart_genome/base/ui_config.dart';
import 'package:flutter_smart_genome/bean/account_bean.dart';
import 'package:flutter_smart_genome/bean/site_item.dart';
import 'package:flutter_smart_genome/components/sgs_logo.dart';
import 'package:flutter_smart_genome/page/admin/account_info_widget.dart';
import 'package:flutter_smart_genome/page/home/header_menu.dart';
import 'package:flutter_smart_genome/page/maincontainer/track_container.dart';
import 'package:flutter_smart_genome/page/session/session_widget.dart';
import 'package:flutter_smart_genome/page/site/site_selector_widget.dart';
import 'package:flutter_smart_genome/page/track/site_species_selector_widget.dart';
import 'package:flutter_smart_genome/routes.dart';
import 'package:flutter_smart_genome/service/sgs_app_service.dart';
import 'package:flutter_smart_genome/side/highlight_side.dart';
import 'package:flutter_smart_genome/side/home_side.dart';
import 'package:flutter_smart_genome/side/search_side.dart';
import 'package:flutter_smart_genome/storage/base_store_provider.dart';

import 'package:flutter_smart_genome/util/device_info.dart';
import 'package:flutter_smart_genome/widget/navigation_bar.dart';
import 'package:flutter_smart_genome/widget/sider/horizontal_sider.dart';

class HomeDrawerTablet extends StatefulWidget {
  final ValueChanged<SiteItem>? onSiteChange;
  final ValueChanged<String>? onTapMenu;

  const HomeDrawerTablet({
    Key? key,
    this.onSiteChange,
    this.onTapMenu,
  }) : super(key: key);

  @override
  _HomeDrawerState createState() => _HomeDrawerState();
}

class _HomeDrawerState extends State<HomeDrawerTablet> {
  AccountBean? _account;

  int _index = 0;

  @override
  void initState() {
    super.initState();
//    LicenseRegistry.reset();
//    LicenseRegistry.addLicense(() async* {
//      yield LicenseEntryWithLineBreaks(<String>['my_library'], '''
//      Copyright @2020 SouthWest University. All rights reserved.
//      Developed by Wang. Contact: xxxxx@mail.com
//      ''');
//    });
    _loadAccountInfo();
  }

  @override
  void didUpdateWidget(HomeDrawerTablet oldWidget) {
    super.didUpdateWidget(oldWidget);
    _loadAccountInfo();
  }

  void _loadAccountInfo() async {
    _account = await BaseStoreProvider.get().getAccount();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    bool _mobile = isMobile(context);
    double width = _mobile ? MediaQuery.of(context).size.width * .75 : 450;
    // if (width > 400) width = 400;

    return SafeArea(
      child: Material(
        child: Container(
          constraints: BoxConstraints.expand(width: width),
          decoration: BoxDecoration(
            border: Border(right: BorderSide(width: .5, color: Theme.of(context).dividerColor)),
          ),
          child: Row(
            children: [
              _buildLeftMenuBar(),
              VerticalDivider(width: 1.0),
              Expanded(
                child: Column(
                  children: [
                    _buildLogo(),
                    Expanded(
                      child: IndexedStack(
                        index: _index,
                        children: [
                          HomeSide(),
                          SiteSpeciesSelectorWidget(
                            axis: Axis.vertical,
                            site: SgsAppService.get()!.site!,
                            onChanged: (site) {
                              SgsAppService.get()!.changeSiteSpecies(site);
                            },
                          ),
                          SearchSide(),
                          SessionWidget(
                            currentSession: SgsAppService.get()!.session,
                            onChanged: (session) {
                              SgsAppService.get()!.loadSession(session);
                            },
                          ),
                          HighlightSide(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeftMenuBar() {
    List<NavigationBarItem> items = [
      NavigationBarItem(
        icon: Icon(Icons.manage_accounts),
//        title: Text('Home'),
        tooltip: 'Home',
        activeIcon: Icon(Icons.manage_accounts),
        type: HeaderMenu.home,
      ),
      NavigationBarItem(
        icon: Icon(Octicons.server),
//        title: Text('Favor'),
        tooltip: 'Server',
        activeIcon: Icon(Octicons.server),
        type: SideModel.server.toString(),
      ),
      NavigationBarItem(
        icon: Icon(Octicons.search),
//        title: Text('Favor'),
        tooltip: 'Search',
        activeIcon: Icon(Octicons.search),
        type: SideModel.search.toString(),
      ),
      NavigationBarItem(
        icon: Icon(Icons.history),
//        title: Text('Favor'),
        tooltip: 'Session',
        activeIcon: Icon(Icons.history),
        type: SideModel.session_list.toString(),
      ),
      NavigationBarItem(
        icon: Icon(Icons.high_quality),
//        title: Text('Favor'),
        tooltip: 'Highlight',
        activeIcon: Icon(Icons.highlight),
        type: SideModel.highlight.toString(),
      ),
      // NavigationBarItem(
      //   icon: Icon(Icons.settings_applications),
      //   tooltip: 'Settings',
      //   activeIcon: Icon(Icons.settings_applications),
      // ),
    ];

    return Container(
//      constraints: BoxConstraints.expand(width: 80),
      decoration: BoxDecoration(
          // border: Border(right: BorderSide(color: Theme.of(context).dividerColor, width: 1)),
          ),
      child: NavigationRail(
        selectedIndex: _index,
        selectedIconTheme: Theme.of(context).iconTheme,
        selectedLabelTextStyle: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w400),
//        groupAlignment: .0,
        extended: false,
//        leading: _userHeader(context),
//        trailing: _settingFooter(context),
        minWidth: 32,
        labelType: NavigationRailLabelType.selected,
        onDestinationSelected: (index) {
          setState(() {
            _index = index;
          });
        },
        destinations: items.where((element) => element.type != 'space').map((e) {
          return NavigationRailDestination(icon: e.icon!, selectedIcon: e.activeIcon, label: Text(e.tooltip!));
        }).toList(),
        leading: DeviceOS.isMacOS ? SizedBox(height: 10) : null,
      ),
    );
  }

  Widget _buildUserHeader() {
//    SiteItem _siteItem = MemoryCache().currentSite;
    return AccountInfoWidget();
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: AccountInfoWidget(),
    );
  }

  void _showSessionWidget() async {
    var result;
    if (isMobile(context)) {
      result = await Navigator.of(context).popAndPushNamed(RoutePath.session);
    } else {
      Navigator.of(context).pop();
      double _h = MediaQuery.of(context).size.height;
      result = await showDialog(
        context: context,
        builder: (c) {
          return AlertDialog(
            title: Text('Session'),
            content: Container(
              constraints: BoxConstraints.tightFor(width: 800, height: _h * .65),
              child: SessionWidget(),
            ),
          );
        },
      );
    }
    if (result != null) {
//      ShareSession url = result;
    }
  }

  void _toggleLogin() async {
    if (null == _account) {
      _checkLogin();
    } else {
      _account = null;
      await BaseStoreProvider.get().logout();
      setState(() {});
    }
  }

  void _checkLogin() async {
    if (null == _account) {
      var result = await Navigator.of(context).popAndPushNamed(RoutePath.login);
      if (null != result) {
        setState(() {
          _account = result as AccountBean;
        });
        await Future.delayed(Duration(milliseconds: 300));
//        Navigator.of(context).popAndPushNamed(RoutePath.user_center);
      }
    } else {
      Navigator.of(context).popAndPushNamed(RoutePath.user_center);
    }
  }

  _changeServer() async {
    var result = await Navigator.of(context).popAndPushNamed(RoutePath.site_list);
    if (result == null) return;
    SiteItem _site = result as SiteItem;
    widget.onSiteChange?.call(_site);
  }

  void _showSiteSelector() async {
    Navigator.of(context).pop();
    showHorizontalSheet(
      context: context,
      builder: (c) {
        return Container(
          constraints: BoxConstraints.expand(width: 400),
          child: SiteSelectorWidget(
            onChanged: (site) {
              widget.onSiteChange?.call(site);
            },
          ),
        );
      },
    );
  }

  Widget _buildLogo({bool showTitle = true}) {
    Color _color = Theme.of(context).colorScheme.primary;
    var logo = SgsLogo(color: _color);
    return Container(
      constraints: BoxConstraints.tightFor(height: 40),
      margin: EdgeInsets.symmetric(vertical: 16),
      child: showTitle
          ? Row(
              children: [
                SizedBox(width: 16),
                logo,
                SizedBox(width: 10),
                Text(
                  'Smart Genome DB',
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(color: _color),
                ),
              ],
            )
          : logo,
    );
  }
}
