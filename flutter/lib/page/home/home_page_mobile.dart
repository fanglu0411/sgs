import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/bean/site_item.dart';
import 'package:flutter_smart_genome/mixin/view_size_mixin.dart';
import 'package:flutter_smart_genome/page/track/sgs_browse_page.dart';
import 'package:flutter_smart_genome/service/sgs_app_service.dart';
import 'package:flutter_smart_genome/widget/basic/custom_bot_widget.dart';
import 'package:majascan/majascan.dart';

class HomePageMobile extends StatefulWidget {
  @override
  _HomePageMobileState createState() => _HomePageMobileState();
}

class _HomePageMobileState extends State<HomePageMobile> with ViewSizeMixin {
  int _currentIndex = 0;
  SiteItem? _site;

  @override
  void initState() {
    super.initState();
    _site = SgsAppService.get()!.site;
  }

  @override
  Widget build(BuildContext context) {
    return SgsBrowsePage(
        site: _site,
        key: Key('browser-${_site?.sid}-${_site?.currentSpeciesId}'),
        showDrawer: true,
        onSiteChange: (site) {
          setState(() {
            _site = site;
          });
        });
//    return Scaffold(
//      appBar: AppBar(
//        title: Text('Smart Genome'),
//        actions: <Widget>[
////          TextButton(child: Text('Silkworm/'), onPressed: null, textColor: Colors.white),
//          if (isAndroidOrIOS)
//            IconButton(
//              icon: Icon(Icons.crop_free),
//              tooltip: 'Scan cor-code',
//              onPressed: _scanQrCode,
//            ),
//        ],
//      ),
//      bottomNavigationBar: _buildBottomNavigation(),
//      drawer: HomeDrawer(),
//      drawerEnableOpenDragGesture: false,
//      body: IndexedStack(
//        index: _currentIndex,
//        children: <Widget>[
//          HomeWidget(),
//          FavoritePage(),
//          AccountPageMobile(),
//          SettingPage(),
//        ],
//      ),
//    );
  }

  _scanQrCode() async {
    String? qrResult = await MajaScan.startScan(
      title: 'QRcode scanner',
      barColor: Theme.of(context).colorScheme.primary,
      titleColor: Colors.white,
      qRCornerColor: Colors.blue,
      qRScannerColor: Colors.deepPurple,
      flashlightEnable: true,
    );
    showToast(text: '$qrResult');
  }

  _buildBottomNavigation() {
    bool _dark = Theme.of(context).brightness == Brightness.dark;
    List<BottomNavigationBarItem> items = [
      BottomNavigationBarItem(
        icon: Icon(Icons.home),
        label: 'Home',
        activeIcon: Icon(Icons.home),
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.favorite_border),
        label: 'Favor',
        activeIcon: Icon(Icons.favorite),
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.person_outline),
        label: 'User',
        activeIcon: Icon(Icons.person),
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.settings),
        label: 'Setting',
        activeIcon: Icon(Icons.settings),
      ),
    ];
    return BottomNavigationBar(
      backgroundColor: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Theme.of(context).colorScheme.primary,
      unselectedItemColor: _dark ? Colors.white : Colors.black54,
      items: items,
      currentIndex: _currentIndex,
      onTap: _onItemTap,
    );
  }

  void _onItemTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
}
