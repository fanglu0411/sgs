import 'package:flutter/services.dart';
import 'package:flutter_smart_genome/bean/site_item.dart';
import 'package:flutter_smart_genome/page/home/home_page_big_screen.dart';
import 'package:flutter_smart_genome/page/home/home_page_mobile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/page/home/home_page_tablet.dart';
import 'package:flutter_smart_genome/service/sgs_config_service.dart';
import 'package:flutter_smart_genome/storage/base_store_provider.dart';

import 'package:flutter_smart_genome/util/device_info.dart';
import 'package:flutter_smart_genome/widget/basic/custom_multi_size_layout.dart';
import 'package:showcaseview/showcaseview.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  SiteItem? _currentSite;

  @override
  void initState() {
    super.initState();
    if (DeviceOS.isAndroid) {
      SystemUiOverlayStyle systemUiOverlayStyle = SystemUiOverlayStyle(statusBarColor: Colors.transparent);
      SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
    }
  }

  @override
  Widget build(BuildContext context) {
    var widget = CustomMultiSizeLayout.builder(
      breakpoints: defaultBreakPoints,
      mobile: (c) => HomePageMobile(),
      tablet: (c) => SgsConfigService.get()!.ideMode ? HomePageBigScreen() : HomePageTablet(),
      desktop: (c) => HomePageBigScreen(),
    );
    // if (BaseStoreProvider.get().showCaseFinish()) {
    //   return widget;
    // }
    return ShowCaseWidget(
      builder: (c) => widget,
      onComplete: (i, s) {
        BaseStoreProvider.get().finishShowCase();
      },
      autoPlay: false,
      autoPlayDelay: Duration(seconds: 2),
    );
  }
}
