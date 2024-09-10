import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/bean/site_item.dart';
import 'package:flutter_smart_genome/components/sgs_logo.dart';
import 'package:flutter_smart_genome/entry/entry_logic.dart';
import 'package:flutter_smart_genome/platform/platform_adapter.dart';
import 'package:flutter_smart_genome/routes.dart';
import 'package:flutter_smart_genome/service/public_service.dart';
import 'package:flutter_smart_genome/service/sgs_app_service.dart';
import 'package:flutter_smart_genome/storage/base_store_provider.dart';
import 'package:flutter_smart_genome/storage/isar/site_provider.dart';

import 'package:flutter_smart_genome/util/native_window_util/app_title_bar.dart';
import 'package:flutter_smart_genome/widget/loading_widget.dart';
import 'package:get/get.dart';

import 'new_project_widget.dart';
import 'welcome_widget.dart';

class InitializePage extends StatefulWidget {
  @override
  _InitializePageState createState() => _InitializePageState();
}

class _InitializePageState extends State<InitializePage> {
  List<SiteItem>? sites;
  bool _showNewProject = false;

  EntryLogic? checkLogic;

  @override
  void initState() {
    super.initState();
    _init();
  }

  _init() async {
    sites = await BaseStoreProvider.get().getSiteList();
    await Future.delayed(Duration(milliseconds: 300));
    setState(() {});
  }

  void _onCreateProject() {
    _showNewProject = true;
    setState(() {});
  }

  void _remove(SiteItem site) async {
    await BaseStoreProvider.get().deleteSite(site);
    sites = await BaseStoreProvider.get().getSiteList();
    setState(() {});
  }

  Widget _builder(EntryLogic logic) {
    if (logic.loading) {
      return Material(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SgsLogo(fontSize: 40, color: Theme.of(context).colorScheme.primary),
              SizedBox(height: 4),
              Text('v ${PublicService.get()!.appInfo?.version}', style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w300)),
            ],
          ),
        ),
      );
    } else if (logic.error != null) {
      return LoadingWidget(loadingState: LoadingState.error, message: logic.error);
    }

    if (sites == null) {
      return Container();
    }
    Widget body;
    if (_showNewProject || (sites?.length ?? -1) == 0) {
      body = NewProjectWidget(
        showBack: _showNewProject,
        onBack: () {
          _showNewProject = false;
          setState(() {});
        },
        onViewExample: () {
          PlatformAdapter.create().setWindowSize(Size.zero, fullscreen: true);
          var demoSite = sites!.firstWhere((e) => e.isDemoServer);
          SgsAppService.get()!.setSite(demoSite);
          Get.offAllNamed(RoutePath.home);
          // Navigator.of(context).popAndPushNamed(RoutePath.home);
        },
      );
    } else {
      // body = Center(
      //   child: CustomSpin(radius: 12),
      // );
      body = Center(
        child: WelcomeWidget(
          sites: sites!,
          onNewProject: _onCreateProject,
          onRemove: _remove,
        ),
      );
    }

    // if (sites == null || sites.length > 1) {
    //   body = Center(
    //     child: CustomSpin(radius: 12),
    //   );
    //   body = Center(child: WelcomeWidget(sites: sites, onNewProject: _onCreateProject));
    // } else {
    //   body = _newProjectWidget();
    // }
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(30),
        child: AppTitleBar(
          child: Center(child: Text('Welcome to SGS')),
        ),
      ),
      body: body,
      // Stack(
      //   children: [
      //     body,
      //     // Container(
      //     //   height: ui_config.HORIZONTAL_TOOL_BAR_HEIGHT,
      //     //   child: AppBar(
      //     //     automaticallyImplyLeading: false,
      //     //     toolbarHeight: ui_config.HORIZONTAL_TOOL_BAR_HEIGHT,
      //     //     backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      //     //     title: AppTitleBar(
      //     //       child: Row(),
      //     //     ),
      //     //   ),
      //     // ),
      //   ],
      // ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<EntryLogic>(builder: _builder);
  }
}
