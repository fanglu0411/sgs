import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/components/events/error/logic.dart';
import 'package:flutter_smart_genome/routes.dart';
import 'package:flutter_smart_genome/service/cache_service.dart';
import 'package:flutter_smart_genome/service/public_service.dart';
import 'package:flutter_smart_genome/service/sgs_app_service.dart';
import 'package:flutter_smart_genome/service/sgs_config_service.dart';
import 'package:flutter_smart_genome/storage/base_store_provider.dart';
import 'package:flutter_smart_genome/util/custom_scroll_behavior.dart';
import 'package:get/get.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'entry_logic.dart';

Future initEnv() async {
  await BaseStoreProvider.get().init();
  Get.put(EntryLogic());
  Get.put(PublicService());
  Get.put(SgsConfigService());
  Get.put(SgsAppService());
  Get.put(CacheService());
  Get.put(ErrorEventLogic());
}

void root(List<String> args) async {
  usePathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();
  await initEnv();
  runApp(_MainApp());
}

class _MainApp extends StatelessWidget {
  /// build by logic
  Widget _builder(EntryLogic controller) {
    if (controller.loading) {
      return Material(
        child: Center(
          child: Image.asset('images/app_icon_512.png', width: 100, height: 100, fit: BoxFit.contain),
        ),
      );
    }
    var configService = SgsConfigService.get();
    final botToastBuilder = BotToastInit();
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SGS',
      scrollBehavior: CustomScrollBehavior(),
      navigatorObservers: [
        BotToastNavigatorObserver(),
        routeObserver,
      ],
      themeMode: configService!.themeMode,
      theme: configService.themeData,
      // darkTheme: configService.darkThemeData,
      routes: buildRoutes(),
      builder: (ctx, child) {
        child = botToastBuilder(ctx, child);
        // return child;
        return Overlay(
          initialEntries: [
            OverlayEntry(builder: (c) => child!),
          ],
        );
      },
      onGenerateRoute: onCreateRoute,
      initialRoute: RoutePath.home,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<EntryLogic>(
      autoRemove: false,
      init: EntryLogic.get(),
      builder: _builder,
    );
  }
}
