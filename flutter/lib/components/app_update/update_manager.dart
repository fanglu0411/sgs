import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/components/app_update/download_status_view.dart';
import 'package:flutter_smart_genome/network/api/simple_request.dart'
    as http_util;
import 'package:flutter_smart_genome/network/core/http_error.dart';
import 'package:flutter_smart_genome/network/dio_helper.dart';
import 'package:flutter_smart_genome/network/http_response.dart';
import 'package:flutter_smart_genome/service/public_service.dart';
import 'package:flutter_smart_genome/util/debouncer.dart';
import 'package:flutter_smart_genome/util/device_info.dart';
import 'package:flutter_smart_genome/widget/basic/custom_bot_widget.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

import 'download_progress_notifier.dart';

class VersionInfo {
  List updates;
  int version;
  String versionName;
  String downloadUrl;

  VersionInfo(
      {required this.updates,
      required this.version,
      required this.versionName,
      required this.downloadUrl});

  @override
  String toString() {
    return 'VersionInfo{updates: $updates, version: $version, versionName: $versionName, downloadUrl: $downloadUrl}';
  }
}

class UpdateManager {
  static final UpdateManager _instance = UpdateManager._init();

  late DownloadProgressNotifier progressNotifier;

  static String UPDATE_URL = "";
  static String UPDATE_FALLBACK_URL = "";

  factory UpdateManager() {
    return _instance;
  }

  static UpdateManager instance() {
    return _instance;
  }

  static const int checkDelay = 60 * 60 * 1000;

  UpdateManager._init() {
    _debounce = Debounce(milliseconds: checkDelay);
    progressNotifier = DownloadProgressNotifier();
  }

  late Debounce _debounce;
  bool _checking = false;
  VersionInfo? newVersion;
  bool _downloading = false;
  String? downloadedFilePath;

  HttpError? _error = null;

  bool get downloading => _downloading;

  String? get downloadStatus {
    if (downloading) {
      return 'Downloading';
    } else if (_error != null) {
      return _error!.message;
    } else if (downloadedFilePath != null) {
      return 'Downloaded';
    }
    return '';
  }

  bool get hasNewVersion =>
      newVersion != null &&
      newVersion!.version > PublicService.get()!.buildNumber;

  checkUpdate({int delay = checkDelay}) {
    _debounce.run(
        () => _checkUpdate().catchError((e, s) {
              _checking = false;
              showToast(text: '${e}');
            }),
        milliseconds: delay);
  }

  Future _checkUpdate() async {
    if (kIsWeb || _checking) return;
    _checking = true;
    Map? body;
    HttpResponseBean resp =
        await http_util.get(path: UPDATE_URL, dio: DioHelper().thirdDio);
    if (!resp.success || resp.error != null) {
      resp = await http_util.get(
        path: UPDATE_FALLBACK_URL,
        dio: DioHelper().thirdDio,
      );
      if (!resp.success || resp.error != null) {
        _checking = false;
        showToast(text: 'Check version fail!');
        return;
      }
      List list = resp.body['list'];
      body = Map.fromIterable(list, key: (e) => e['Platform'], value: (e) => e);
    } else {
      body = resp.body;
    }
    Map? versionInfo = body?[os];
    if (null == versionInfo) {
      _checking = false;
      showToast(text: 'No version info for platform: ${os}');
      return;
    }
    List updates = (versionInfo['Updates'] ?? '') is String
        ? (versionInfo['Updates'] ?? '').split('\n')
        : versionInfo['Updates'];
    newVersion = VersionInfo(
      updates: updates,
      version: versionInfo['VersionCode'],
      versionName: versionInfo['VersionName'] ?? '',
      downloadUrl: versionInfo['Url'],
    );
    if (hasNewVersion) {
      // showToast(text: 'New version ${newVersion!.versionName} found!');
      showCustomNotification(
        duration: Duration(milliseconds: 5500),
        title: Text('New version ${newVersion!.versionName} found!',
            textScaler: TextScaler.linear(1.2)),
        icon: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Icon(Icons.tips_and_updates,
              size: 36, color: Get.theme.colorScheme.primary),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: ElevatedButton(
            onPressed: () {
              downloadNewVersion();
            },
            child: Text('Update Now'),
          ),
        ),
      );
    } else {
      showToast(text: 'SGS is the latest version!');
    }
    _checking = false;
  }

  String get os {
    if (DeviceOS.isMacOS) return 'MacOS';
    if (DeviceOS.isWindows) return 'Windows';
    if (DeviceOS.isLinux) return 'Linux';
    if (DeviceOS.isAndroid) return 'Android';
    if (DeviceOS.isWeb) return 'Web';
    return Platform.operatingSystem;
  }

  Future<void> openExeFile(String filePath) async {
    await Process.start(filePath, ['-t', '-l', '1000'])
        .then((v) {})
        .catchError((e) {
      showToast(text: '${e}');
    });
  }

  openDMGFile(String filePath) async {
    await Process.start('open', [filePath]);
    // await Process.start("MOUNTDEV=\$(hdiutil mount '$filePath' | awk '/dev.disk/{print\$1}')", []).then((value) {});
  }

  Future downloadNewVersion() async {
    if (_downloading) {
      showDownloadDialog();
      return;
    }

    String fileUrl = newVersion!.downloadUrl;
    final fileName = fileUrl.split("/").last;
    _downloading = true;

    downloadedFilePath = "${(await getDownloadsDirectory())!.path}/$fileName";
    progressNotifier.updateVersion(
        versionName: newVersion!.versionName, updates: newVersion!.updates);

    showDownloadDialog();

    if (File(downloadedFilePath!).existsSync()) {
      progressNotifier.updateProgress(1.0);
      _downloading = false;
      showSuccessNotification(
        title: Text('${newVersion?.versionName}'),
        subtitle: Text('new version download finish!'),
      );
      // _openFile();
      return;
    }

    progressNotifier.updateProgress(0);
    await http_util
        .download(
      dio: DioHelper().thirdDio,
      url: fileUrl,
      savePath: downloadedFilePath!,
      progress: (received, total) {
        final progress = (received / total);
        // print('Rec: $received , Total: $total, $progress%');
        progressNotifier.updateProgress(progress);
        if (progress == 1.0) {
          _downloading = false;
          showSuccessNotification(
            title: Text('${newVersion?.versionName}'),
            subtitle: Text('new version download finish!'),
          );
        }
      },
    )
        .then((s) {
      if (!s.success) {
        _downloading = false;
        _error = s.error;
        showToast(text: s.error?.message ?? s.body ?? 'download fail!');
      }
    }).catchError((error) {
      _downloading = false;
      _error = HttpError(-1, '${error}');
      return error;
    });
    _downloading = false;
    // print("File Downloaded Path: $downloadedFilePath");
  }

  _openFile() async {
    if (Platform.isWindows || Platform.isLinux) {
      await openExeFile(downloadedFilePath!);
    } else if (Platform.isMacOS) {
      await openDMGFile(downloadedFilePath!);
    }
  }

  void showDownloadDialog() async {
    var result = await showDialog<bool>(
        context: Get.context!,
        // barrierDismissible: false,
        builder: (c) {
          return AlertDialog(
            title: Text('Update SGS!'),
            content: ConstrainedBox(
              constraints:
                  BoxConstraints(minWidth: 400, maxWidth: 800, maxHeight: 300),
              child: AppDownloadStatusView(
                progressNotifier: progressNotifier,
                onCancel: () {
                  Navigator.of(c).pop(false);
                },
                onInstall: () {
                  Navigator.of(c).pop(true);
                },
              ),
            ),
          );
        });
    if (null != result && result) {
      _openFile();
      await Future.delayed(Duration(milliseconds: 500));
      exit(0);
    }
  }
}
