// import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:flutter_smart_genome/base/container_config.dart';
import 'package:flutter_smart_genome/base/ui_config.dart';
import 'package:flutter_smart_genome/bean/site_item.dart';
import 'package:flutter_smart_genome/components/sgs_logo.dart';
import 'package:flutter_smart_genome/components/sub_menu_list_widget.dart';
import 'package:flutter_smart_genome/page/admin/account_info_widget.dart';
import 'package:flutter_smart_genome/page/home/home_app_title_bar.dart';
import 'package:flutter_smart_genome/page/maincontainer/track_container.dart';
import 'package:flutter_smart_genome/page/session/session_widget.dart';
import 'package:flutter_smart_genome/page/setting/setting_page.dart';
import 'package:flutter_smart_genome/routes.dart';
import 'package:flutter_smart_genome/service/sgs_app_service.dart';
import 'package:flutter_smart_genome/storage/base_store_provider.dart';

import 'package:flutter_smart_genome/util/logger.dart';
import 'package:flutter_smart_genome/util/native_window_util/app_title_bar.dart';
import 'package:flutter_smart_genome/util/widget_util.dart';
import 'package:flutter_smart_genome/widget/basic/custom_bot_widget.dart';
import 'package:flutter_smart_genome/widget/navigation_bar.dart';
import 'package:flutter_smart_genome/widget/splitlayout/show_case_info.dart';
import 'package:flutter_smart_genome/widget/track/base/track_session.dart';
import 'package:showcaseview/showcaseview.dart';

import 'header_menu.dart';

class HomePageBigScreen extends StatefulWidget {
  const HomePageBigScreen({Key? key}) : super(key: key);

  @override
  _HomePageBigScreenState createState() => _HomePageBigScreenState();
}

class _HomePageBigScreenState extends State<HomePageBigScreen> {
  SiteItem? _site;

  GlobalKey? _repaintBoundaryKey;

//  Map<String, Widget> _typeWidgets = <String, Widget>{
//      HeaderMenu.home: HomeWidget(),
//      HeaderMenu.track_browser: TrackPage(),
//      HeaderMenu.help: HelpWidget(),
//      HeaderMenu.favor: FavoritePage(),
//      HeaderMenu.setting: SettingPage(),
//      HeaderMenu.user: UserCenterWidget(),
//      HeaderMenu.tool_hi_c: DevelopingWidget(title: 'hi-c'),
//      HeaderMenu.tool_pangenome: DevelopingWidget(title: 'pangenome'),
//      HeaderMenu.tool_synteny: DevelopingWidget(title: 'synteny'),
//      HeaderMenu.tool_ortholog: DevelopingWidget(title: 'Ortholog'),
//    };

  List<String> _tabTypes = [
    if (kIsWeb) HeaderMenu.home,
    HeaderMenu.track_browser,
    HeaderMenu.help,
    HeaderMenu.favor,
//    HeaderMenu.setting,
//    HeaderMenu.user,
    HeaderMenu.tool_blast,
    HeaderMenu.tool_hi_c,
    HeaderMenu.tool_pangenome,
    HeaderMenu.tool_synteny,
    HeaderMenu.tool_ortholog,
  ];

  List<NavigationBarItem> _toolsMenuList = [
    // NavigationBarItem(title: Text('Blast'), type: HeaderMenu.tool_blast),
    // NavigationBarItem(title: Text('Hi-C'), type: HeaderMenu.tool_hi_c),
    // NavigationBarItem(title: Text('Pangenome'), type: HeaderMenu.tool_pangenome),
    // NavigationBarItem(title: Text('Synteny'), type: HeaderMenu.tool_synteny),
    // NavigationBarItem(title: Text('Ortholog'), type: HeaderMenu.tool_ortholog),
  ];

  List<NavigationBarItem>? leftMenuItems;

  int _pageIndex = kIsWeb ? 1 : 0;
  int _menuIndex = kIsWeb ? 1 : 0;
  bool _toolSelected = false;
  Key? _trackKey;
  TrackSession? _session;

  CancelFunc? _menuKey;

  @override
  void initState() {
    _repaintBoundaryKey = GlobalKey(debugLabel: 'home-repaint-boundary');
    _site = SgsAppService.get()!.site;
    leftMenuItems = [
      if (kIsWeb)
        NavigationBarItem(
          icon: Icon(Icons.home, size: 24),
          title: Text('Home'),
          activeIcon: Icon(Icons.home, size: 30),
          type: HeaderMenu.home,
        ),
      NavigationBarItem(
        icon: Icon(Icons.chrome_reader_mode, size: 24),
        title: Text('Browse'),
        activeIcon: Icon(Icons.chrome_reader_mode, size: 24),
        type: HeaderMenu.track_browser,
      ),
      NavigationBarItem(
        icon: Icon(MaterialCommunityIcons.toolbox, size: 22),
        title: Text('Tools'),
        activeIcon: Icon(MaterialCommunityIcons.toolbox, size: 22),
        type: 'tools',
        builder: (c) {
          return Builder(
            builder: (context) {
              return TextButton.icon(
                style: TextButton.styleFrom(
                  textStyle: TextStyle(color: _toolSelected ? Theme.of(c).primaryColor : null),
                ),
                icon: Icon(MaterialCommunityIcons.toolbox, size: 22),
                label: Text('Tools'),
                onPressed: () {
                  _toggleFloatMenu(context);
                },
              );
            },
          );
        },
      ),
      NavigationBarItem(
        icon: Icon(MaterialCommunityIcons.help_box, size: 24),
        title: Text('Help'),
        activeIcon: Icon(MaterialCommunityIcons.help_box, size: 30),
        type: HeaderMenu.help,
      ),
      NavigationBarItem.spacer(),
//      NavigationBarItem(
//        icon: Icon(Icons.history, size: 24),
//        title: Text('Session'),
//        activeIcon: Icon(Icons.history, size: 30),
//        type: HeaderMenu.favor,
//        builder: (c) {
//          return Builder(
//            builder: (context) {
//              return TextButton.icon(
//                icon: Icon(MaterialCommunityIcons.file_document_box_outline),
//                label: Text('Session'),
//                onPressed: () {
//                  _showSessionDialog(context);
//                },
//              );
//            },
//          );
//        },
//      ),
      NavigationBarItem(
        icon: Icon(MaterialCommunityIcons.settings_helper),
        title: Text('Setting'),
        tooltip: 'Setting',
        activeIcon: Icon(Icons.settings_applications, size: 30),
        type: HeaderMenu.setting,
        builder: (context) {
          return Builder(
            builder: (context) {
              return TextButton.icon(
                icon: Icon(MaterialCommunityIcons.settings_helper),
                label: Text('Setting'),
                onPressed: () {
                  _showSettingDialog(context);
                },
              );
            },
          );
        },
      ),

      NavigationBarItem(
        icon: Icon(Icons.person_outline, size: 24),
        title: Text('Admin'),
        activeIcon: Icon(Icons.person, size: 30),
        type: HeaderMenu.user,
        builder: (context) {
          return Builder(
            builder: (context) {
              var c = TextButton.icon(
                icon: Icon(MaterialCommunityIcons.shield_account),
                label: Text('Admin'),
                onPressed: () {
                  _toggleUserInfoDialog(context);
                },
              );
              // return c;
              if (BaseStoreProvider.get().showCaseFinish()) {
                return c;
              }
              return Showcase(
                key: adminShowCase,
                child: c,
                title: 'Tips',
                description: 'manage your server data here',
                disableMovingAnimation: true,
                overlayOpacity: .45,
              );
            },
          );
        },
      ),
      NavigationBarItem(
        icon: Icon(Icons.add, size: 24),
        title: Text('Deploy'),
        activeIcon: Icon(Icons.add, size: 30),
        type: HeaderMenu.server_create,
        builder: (context) {
          return Builder(
            builder: (context) {
              return IconButton(
                icon: Icon(MaterialCommunityIcons.plus),
                tooltip: 'Deploy New Server',
                onPressed: () {
                  Navigator.of(context).pushNamed(RoutePath.server_create);
                },
              );
            },
          );
        },
      ),
    ];
    super.initState();
    _trackKey = Key('browser-${_site?.sid}-${_site?.currentSpeciesId}');
    // if (!BaseStoreProvider.get().showCaseFinish()) {
    //   var cases = [serverShowCase, searchShowCase, trackShowCase, trackThemeShowCase, singleCellShowCase, adminShowCase];
    //   WidgetsBinding.instance.addPostFrameCallback((_) => ShowCaseWidget.of(context).startShowCase(cases));
    // }
  }

  Widget _buildSinkTopBar() {
    bool _dark = Theme.of(context).brightness == Brightness.dark;
    var site = SgsAppService.get()!.site;
    return AppTitleBar(
      height: 24,
      child: Container(
        constraints: BoxConstraints.expand(height: 24),
        decoration: BoxDecoration(
          color: _dark ? Colors.black26 : Colors.white10,
          border: Border(
            bottom: BorderSide(
              color: _dark ? Colors.black26 : Colors.grey[300]!,
              width: 1,
            ),
          ),
        ),
        // child: Row(
        //   mainAxisAlignment: MainAxisAlignment.center,
        //   children: [
        //     Text('SGS', style: TextStyle(fontSize: 12)),
        //     Text(' - ${site.url} - ${site.currentSpecies}', style: TextStyle(fontSize: 12)),
        //   ],
        // ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // var body = Column(
    //   children: <Widget>[
    //     // _buildTopBar(),
    //     // _buildSinkTopBar(),
    //     Expanded(
    //       child: IndexedStack(
    //         sizing: StackFit.expand,
    //         index: _pageIndex,
    //         children: [
    //           if (kIsWeb) WebHomeWidget(),
    //           TrackContainer(),
    //           HelpWidget(),
    //           FavoritePage(),
    //           BlastFormPage(),
    //           DevelopingWidget(title: 'hi-c'),
    //           DevelopingWidget(title: 'pangenome'),
    //           DevelopingWidget(title: 'synteny'),
    //           DevelopingWidget(title: 'Ortholog'),
    //         ],
    //       ),
    //     )
    //   ],
    // );
    var body = TrackContainer();
    Widget _page = RepaintBoundary(
      key: _repaintBoundaryKey,
      child: Scaffold(
        body: body,
        appBar: PreferredSize(
          child: HomeAppTitleBar(
            onSnapshot: () => WidgetUtil.widget2Image(_repaintBoundaryKey),
          ),
          preferredSize: Size.fromHeight(36),
        ),
      ),
    );
    Size _size = MediaQuery.of(context).size;
    if (kIsWeb && !IDE_MODE && _size.width > 1920) {
      _page = Material(
        child: Center(
          child: Container(
            constraints: BoxConstraints.expand(width: 1920),
            decoration: defaultContainerDecoration(context),
            child: _page,
          ),
        ),
      );
    }
    return _page;
  }

  Widget _buildTopBar() {
    bool _dark = Theme.of(context).brightness == Brightness.dark;
    return AppTitleBar(
      child: Container(
        constraints: BoxConstraints.expand(height: HORIZONTAL_TOOL_BAR_HEIGHT),
        decoration: BoxDecoration(
          color: _dark ? Colors.black26 : Colors.white10,
          border: Border(
            bottom: BorderSide(
              color: _dark ? Colors.black26 : Colors.grey[300]!,
              width: 1,
            ),
          ),
        ),
        child: CustomNavigationBar(
          index: _menuIndex,
          items: leftMenuItems!,
//        header: (context) => SpeciesHeader(onTap: _onSiteChanged),
          header: (context) => SgsLogo(
            color: Theme.of(context).colorScheme.primary,
            backgroundColor: Colors.white10,
          ),
          alignment: MainAxisAlignment.start,
          orientation: Axis.horizontal,
          onTap: _onItemTap,
          mainAxisSize: MainAxisSize.max,
        ),
      ),
    );
  }

  void _onSiteChanged(SiteItem siteItem) async {
    logger.d('site change ${siteItem}');
    setState(() {
      _site = siteItem;
    });
  }

  void _onItemTap(int index, String type) {
    int __index = _tabTypes.indexWhere((element) => element == '$type');
    setState(() {
      _pageIndex = __index;
      _menuIndex = leftMenuItems!.indexWhere((element) => element.type == type);
      _toolSelected = false;
    });
  }

  void _onToolSubItemTap(NavigationBarItem item) {
    String value = item.type;
    var index = _tabTypes.indexWhere((element) => element == value);
    if (index < 0) return;
    setState(() {
      _pageIndex = index;
      _menuIndex = leftMenuItems!.indexOf(item);
      _toolSelected = true;
    });
  }

  void _toggleFloatMenu(BuildContext context) {
    _menuKey = showAttachedWidget(
      targetContext: context,
      preferDirection: PreferDirection.bottomLeft,
      attachedBuilder: (cancel) {
        var selected = _tabTypes[_pageIndex];
        return Material(
          shape: modelShape(context: context),
          elevation: 8,
          child: SubMenuListWidget(
            menus: _toolsMenuList,
            selected: selected,
            onTap: (e) {
              cancel();
              _onToolSubItemTap(e);
            },
          ),
        );
      },
    );
  }

  void _showSettingDialog(BuildContext context) async {
    await showSettingDialog(context);
  }

  void _toggleUserInfoDialog(BuildContext context) async {
    showAttachedWidget(
      targetContext: context,
      preferDirection: PreferDirection.bottomRight,
      attachedBuilder: (cancel) {
        return Material(
          elevation: 8,
          shadowColor: Theme.of(context).colorScheme.primary,
          // shape: modelShape(context: context),
          borderRadius: BorderRadius.circular(5),
          child: Container(
            constraints: BoxConstraints.tightFor(width: 360),
            child: AccountInfoWidget(context: context),
          ),
        );
      },
    );
  }
}
