import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_smart_genome/network/api/simple_request.dart';
import 'package:flutter_smart_genome/service/public_service.dart';
import 'package:flutter_smart_genome/util/debouncer.dart';

class CrashReporter {
  static String REPORT_URL = 'https://nocodb.superbrain.work/api/v2/tables/m88g0brueh4qfd0/records';
  static String TOKEN = 'cKp92PzGkBaFrJaFE8HnPesg0NCardnJMIR06fCH';

  static Debounce debounce = Debounce(milliseconds: 5000);

  static Future report(Object error, StackTrace stack) async {
    if (!kReleaseMode) {
      return;
    }
    debounce.run(() => _report(error, stack));
  }

  static Future _report(Object error, StackTrace stack) async {
    var appInfo = PublicService.get()!.appInfo!;
    var resp = await postJson(
      path: REPORT_URL,
      headers: {'xc-token': TOKEN},
      data: {
        'Version': appInfo.version,
        'VersionCode': appInfo.buildNumber,
        'Platform': kIsWeb ? 'Web' : Platform.operatingSystem,
        'PlatformVersion': kIsWeb ? '-' : Platform.operatingSystemVersion,
        'Error': error.toString(),
        'Stack': stack.toString(),
      },
    );
    if (resp.success) {
      print('report crash success!');
    }
  }
}
