import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_smart_genome/components/crash/crash_reporter.dart';
import 'package:flutter_smart_genome/components/events/error/logic.dart';
import 'package:flutter_smart_genome/service/cache_service.dart';
import 'package:flutter_smart_genome/storage/base_store_provider.dart';
import 'package:flutter_smart_genome/widget/basic/alert_widget.dart';

import 'package:window_size/window_size.dart' as window_size;
import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/base/global_state.dart';
import 'package:flutter_smart_genome/bean/account_bean.dart';
import 'package:flutter_smart_genome/components/window/multi_window_controller.dart';
import 'package:flutter_smart_genome/entry/entry_logic.dart';
import 'package:flutter_smart_genome/page/admin/user_center.dart';
import 'package:flutter_smart_genome/page/setting/setting_page.dart';
import 'package:flutter_smart_genome/routes.dart';
import 'package:flutter_smart_genome/service/public_service.dart';
import 'package:flutter_smart_genome/service/sgs_app_service.dart';
import 'package:flutter_smart_genome/service/sgs_config_service.dart';
import 'package:flutter_smart_genome/util/custom_scroll_behavior.dart';
import 'package:flutter_smart_genome/util/device_info.dart';
import 'package:flutter_smart_genome/util/native_window_util/window_util.dart';

// import 'package:flutter_window_close/flutter_window_close.dart';
import 'package:get/get.dart';
import 'package:window_manager/window_manager.dart';

Future initEnv() async {
  await BaseStoreProvider.get().init();
  await initSubEnv();
  Get.put(EntryLogic());
  Get.put(SgsConfigService());
  Get.put(SgsAppService());
  Get.put(ErrorEventLogic());
}

Future initSubEnv() async {
  Get.put(PublicService());
  Get.put(CacheService());
  await PublicService.get()!.init();
}

void root(List<String> args) {
  FlutterError.onError = (FlutterErrorDetails details) {
    if (kDebugMode) {
      FlutterError.dumpErrorToConsole(details);
    } else {
      Zone.current.handleUncaughtError(details.exception, details.stack!);
    }
  };
  runZonedGuarded(() => _entry(args), (Object error, StackTrace stack) {
    if (error is DioException && error.type == DioExceptionType.cancel) {
      return;
    }
    CrashReporter.report(error, stack);
    ErrorEventLogic.safe()?.add(ErrorEventItem(title: '${error}', error: stack));
  });
}

void _entry(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!DeviceOS.isDesktop) {
    await initEnv();
    runApp(_MainApp());
    return;
  }

  // debugPrint("launch args: $args");
  kBootArgs = List.from(args);

  if (args.isNotEmpty && args.first == 'multi_window') {
    kWindowId = int.parse(args[1]);
    final argument = args[2].isEmpty ? <String, dynamic>{} : jsonDecode(args[2]) as Map<String, dynamic>;
    int type = argument['type'] ?? -1;
    argument['windowId'] = kWindowId;
    kWindowType = fromIndex(type);
    _runMultiWindow(kWindowType, argument);
  } else {
    kWindowType = WindowType.main;
    _runMainApp();
  }
}

void _runMainApp() async {
  var _error;
  await initEnv().catchError((error) {
    _error = error;
  });
  await windowManager.ensureInitialized();
  // windowManager.setPreventClose(true);
  DesktopMultiWindow.setMethodHandler(multiWindowController.handleMessage);
  Widget app = _error != null ? ErrorApp(error: _error!) : _MainApp();
  if (DeviceOS.isLinux) {
    app = Material(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2), side: BorderSide(color: Colors.grey[300]!, width: 1.5)),
      clipBehavior: Clip.antiAlias,
      child: app,
    );
  }
  var windowInfo = await window_size.getWindowInfo();
  final screenFrame = windowInfo.screen!.visibleFrame;
  runApp(app);
  IoUtils.instance.showWindowWhenReady();
  //set size
  WindowOptions windowOptions = WindowOptions(
    size: Size(screenFrame.width, screenFrame.height) * .95,
    center: true,
    backgroundColor: Colors.grey[300],
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });
}

void _runMultiWindow(WindowType windowType, Map argument) async {
  if (!DeviceOS.isMacOS) {
    WindowController.fromWindowId(kWindowId).showTitleBar(false);
  }
  await initSubEnv();
  DesktopMultiWindow.setMethodHandler(multiWindowController.handleMessage);
  int theme = argument['theme'] ?? 5;
  int themeMode = argument['themeMode'] ?? ThemeMode.system.index;
  PublicService.get()!.setTheme(theme, ThemeMode.values[themeMode]);
  WindowController.fromWindowId(kWindowId).setPreventClose(true);
  Widget widget;
  switch (windowType) {
    case WindowType.dataManager:
      AccountBean account = AccountBean.fromMap(argument['account']);
      widget = UserCenterWidget(account: account);
      break;
    case WindowType.setting:
      widget = SettingPage();
      break;
    default:
      exit(0);
  }
  _runSubApp(title: '', home: widget);
  // show window from hidden status
  WindowController.fromWindowId(kWindowId).show();
}

void _runSubApp({required String title, required Widget home}) {
  var publicService = PublicService.get()!;
  final botToastBuilder = BotToastInit();
  Widget app = GetMaterialApp(
    navigatorKey: globalKey,
    debugShowCheckedModeBanner: false,
    title: title,
    theme: publicService.themeData,
    darkTheme: publicService.darkThemeData,
    themeMode: publicService.themeMode,
    home: home,
    scrollBehavior: CustomScrollBehavior(),
    navigatorObservers: [
      BotToastNavigatorObserver(),
    ],
    builder: (context, child) {
      child = botToastBuilder(context, child);
      return child;
    },
    onInit: () {
      //linux close bug, hide instead
      // _setWindowClose('Quit SGS Data Manager ?'); // linux 会显示，windows not working
    },
  );
  if (DeviceOS.isLinux) {
    app = Material(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2), side: BorderSide(color: Colors.grey[300]!, width: 1.5)),
      clipBehavior: Clip.antiAlias,
      child: app,
    );
  }
  runApp(app);
}

class _MainApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var configService = SgsConfigService.get();
    final botToastBuilder = BotToastInit();
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SGS',
      // scrollBehavior: CustomScrollBehavior(),
      navigatorObservers: [
        BotToastNavigatorObserver(),
        routeObserver,
      ],
      scrollBehavior: CustomScrollBehavior(),
      themeMode: configService!.themeMode,
      theme: configService.themeData,
      darkTheme: configService.darkThemeData,
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
      initialRoute: RoutePath.initialize,
      onInit: () {
        _setWindowClose();
      },
    );
    // return GetBuilder<EntryLogic>(
    //   autoRemove: false,
    //   builder: _builder,
    // );
  }
}

void _setWindowClose([String? msg]) {
  // FlutterWindowClose.setWindowShouldCloseHandler(() async {
  //   Completer<bool> completer = Completer();
  //   BotToast.showAnimationWidget(
  //       backgroundColor: Colors.black.withOpacity(.65),
  //       toastBuilder: (c) {
  //         return AlertDialog(
  //           title: Text(msg ?? 'Do you really want to quit SGS ?'),
  //           actionsAlignment: MainAxisAlignment.center,
  //           actionsPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
  //           actions: [
  //             ElevatedButton(
  //               style: ElevatedButton.styleFrom(
  //                 backgroundColor: Colors.red,
  //                 textStyle: TextStyle(color: Colors.white),
  //                 padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
  //                 minimumSize: Size(100, 40),
  //               ),
  //               onPressed: () {
  //                 c.call();
  //                 completer.complete(true);
  //               },
  //               child: const Text('Quit'),
  //             ),
  //             SizedBox(width: 10),
  //             ElevatedButton(
  //                 style: ElevatedButton.styleFrom(
  //                   padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
  //                   minimumSize: Size(100, 40),
  //                 ),
  //                 onPressed: () {
  //                   c.call();
  //                   completer.complete(false);
  //                 },
  //                 child: const Text('NO')),
  //           ],
  //         );
  //       },
  //       animationDuration: Duration(milliseconds: 300));
  //   return completer.future;
  // });
}

class ErrorApp extends StatelessWidget {
  final Object error;

  const ErrorApp({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    var (title, subtitle) = errorMsg;
    return MaterialApp(
      home: Material(
        child: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title, style: Theme.of(context).textTheme.displaySmall?.copyWith(color: Colors.red)),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: Size(120, 50),
                foregroundColor: Colors.white,
                backgroundColor: Colors.red,
                textStyle: Theme.of(context).textTheme.titleLarge,
              ),
              onPressed: () {
                exit(0);
              },
              child: Text('Exit'),
            ),
            SizedBox(height: 20),
            Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
            SizedBox(
              height: 20,
            ),
            AlertWidget.info(
              message: Text('Try to clean cache in ${SgsConfigService.get()?.applicationDocumentsPath ?? '~/Document/sgs'} and restart app!'),
              constraints: BoxConstraints(maxWidth: 600),
            ),
          ],
        )),
      ),
    );
  }

  (String title, String subtitle) get errorMsg {
    if (error is FileSystemException) {
      return ('SGS is already launched!', '');
    } else {
      return ('SGS start failed!', '${error}');
    }
  }
}
