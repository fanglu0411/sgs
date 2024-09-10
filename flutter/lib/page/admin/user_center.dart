import 'package:flutter_smart_genome/widget/basic/custom_spin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/bean/account_bean.dart';
import 'package:flutter_smart_genome/bean/site_item.dart';
import 'package:flutter_smart_genome/components/setting_config_widget.dart';
import 'package:flutter_smart_genome/components/sgs_logo.dart';
import 'package:flutter_smart_genome/mixin/view_size_mixin.dart';
import 'package:flutter_smart_genome/page/admin/data_set_list_page.dart';
import 'package:flutter_smart_genome/util/native_window_util/title_bar_wrapper/title_bar_wrapper.dart';

enum SettingType {
  account_species_manage,
  account_user_manage,
  account_file_manage,
  server_manage,
}

class UserCenterWidget extends StatefulWidget {
  final AccountBean account;

  const UserCenterWidget({Key? key, required this.account}) : super(key: key);

  @override
  _UserCenterWidgetState createState() => _UserCenterWidgetState();
}

class _UserCenterWidgetState extends State<UserCenterWidget> with ViewSizeMixin {
  AccountBean? _account;

  List<SettingItem>? _settingList;

  SettingItem? _currentSetting;
  SiteItem? _currentSite;

  @override
  void initState() {
    super.initState();
    _loadAccount();
  }

  _loadAccount() async {
    _account = widget.account; //?? await BaseStoreProvider.get().getAccount();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    bool _isMobile = isMobile();
    bool _bigScreen = isBigScreen();

    bool _dark = Theme.of(context).brightness == Brightness.dark;

    if (null == _account) {
      return Material(
        child: Center(
          child: CustomSpin(color: Theme.of(context).colorScheme.primary),
        ),
      );
    }
    return DataSetListPage(site: SiteItem(url: _account!.url), account: widget.account);
  }

  Widget _left() {
    Size size = MediaQuery.of(context).size;
    final leftWidth = (size.width * .3).clamp(520.0, 800.0);

    return Container(
      width: leftWidth,
      color: Theme.of(context).colorScheme.primary.withOpacity(.15),
      alignment: Alignment.center,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        // mainAxisSize: MainAxisSize.min,
        children: [
          MoveAreaWrapper(),
          Container(
            padding: const EdgeInsets.all(12.0),
            alignment: Alignment.centerLeft,
            constraints: BoxConstraints.expand(height: 60),
            child: IconButton(
              icon: Icon(Icons.close, size: 28),
              padding: EdgeInsets.zero,
              tooltip: 'Exit',
              onPressed: () {
                Navigator.of(context).maybePop();
              },
            ),
          ),
          SizedBox(height: 60),
          SgsLogo(fontSize: 40),
          SizedBox(height: 30),
          Text(
            'SGS DATA MANAGER',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          SizedBox(height: 60),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'FEATURES:',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900, height: 2.0),
              ),
              _featureItem('List species'),
              _featureItem('Add species'),
              _featureItem('Delete species'),
              _featureItem('List tracks'),
              _featureItem('Add tracks'),
              _featureItem('Delete tracks'),
            ],
          )
        ],
      ),
    );
  }

  Widget _featureItem(String feature) {
    final featureStyles = Theme.of(context).textTheme.displayMedium?.copyWith(
          fontWeight: FontWeight.w900,
          height: 2.0,
        );
    return Container(
        padding: EdgeInsets.only(bottom: 1),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(width: 1.0, color: featureStyles!.color!)),
        ),
        child: Text(feature, style: featureStyles));
  }
}
