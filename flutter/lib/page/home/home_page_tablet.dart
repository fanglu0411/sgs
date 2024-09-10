import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/bean/site_item.dart';
import 'package:flutter_smart_genome/page/home/home_page_drawer_tablet.dart';
import 'package:flutter_smart_genome/page/track/sgs_browse_page.dart';
import 'package:flutter_smart_genome/service/sgs_app_service.dart';

import 'package:flutter_smart_genome/widget/basic/custom_bot_widget.dart';
import 'package:flutter_smart_genome/widget/navigation_bar.dart';

class HomePageTablet extends StatefulWidget {
  @override
  _HomePageTabletState createState() => _HomePageTabletState();
}

class _HomePageTabletState extends State<HomePageTablet> {
  SiteItem? _site;

  int _index = 1;

  @override
  void initState() {
    super.initState();
    _site = SgsAppService.get()!.site;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SgsBrowsePage(
        site: _site,
        showDrawer: true,
      ),
    );
  }

  Widget _userHeader(BuildContext context) {
    return Builder(
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(top: 0),
          child: IconButton(
            constraints: BoxConstraints.tightFor(width: 80, height: 80),
            icon: Icon(Icons.person_pin, size: 50),
            tooltip: 'User',
            onPressed: () {
//              _toggleUserInfoDialog(context);
              setState(() {
                _index = 3;
              });
            },
          ),
        );
      },
    );
  }

  Widget _settingFooter(BuildContext context) {
    return IconButton(
      constraints: BoxConstraints.tightFor(width: 60, height: 60),
      icon: Icon(Icons.settings),
      tooltip: 'Setting',
      onPressed: () {
        setState(() {
          _index = 4;
        });
      },
    );
  }

  void _onItemTap(int index, String type) {
    setState(() {
      _index = index;
    });
  }

  void _onToolSubItemTap(NavigationBarItem item) {}

  void _toggleUserInfoDialog(BuildContext context) {
    showAttachedWidget(
      targetContext: context,
      preferDirection: PreferDirection.rightCenter,
      attachedBuilder: (cancel) {
        return Card(
          elevation: 8,
          shadowColor: Theme.of(context).colorScheme.primary,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            constraints: BoxConstraints.tightFor(width: 300),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                ListTile(
                  leading: Icon(Icons.person_pin),
                  title: Text('Hello Jone'),
                  trailing: IconButton(onPressed: () {}, icon: Icon(Icons.exit_to_app), tooltip: 'Logout'),
                ),
                ListTile(onTap: () {}, leading: Icon(Icons.info), title: Text('Show User Info')),
                ListTile(onTap: () {}, leading: Icon(Icons.storage), title: Text('Admin Data Manage')),
              ],
            ),
          ),
        );
      },
    );
  }
}
