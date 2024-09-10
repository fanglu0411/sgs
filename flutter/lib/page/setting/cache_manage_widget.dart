import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/bloc/sgs_context/sgs_browse_logic.dart';
import 'package:flutter_smart_genome/entry/entry_logic.dart';
import 'package:flutter_smart_genome/network/dio_helper.dart';
import 'package:flutter_smart_genome/platform/platform_adapter.dart';
import 'package:flutter_smart_genome/routes.dart';
import 'package:flutter_smart_genome/service/sgs_config_service.dart';
import 'package:flutter_smart_genome/storage/base_store_provider.dart';
import 'package:flutter_smart_genome/util/file_util.dart';
import 'package:flutter_smart_genome/widget/basic/custom_bot_widget.dart';

import 'package:flutter_smart_genome/widget/basic/fast_rich_text.dart';
import 'package:get/get.dart';
import 'package:open_file/open_file.dart';

class CacheManageWidget extends StatefulWidget {
  const CacheManageWidget({Key? key}) : super(key: key);

  @override
  State<CacheManageWidget> createState() => _CacheManageWidgetState();
}

class _CacheManageWidgetState extends State<CacheManageWidget> {
  var _cacheSize = -1;

  @override
  void initState() {
    super.initState();
    SgsConfigService.get()?.checkFileCacheSize().then((s) {
      _cacheSize = s;
      setState(() {});
    });
  }

  String get sizeStr => _cacheSize < 0 ? 'Counting...' : FileUtil.fileSizeStr(_cacheSize);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildCacheItem(
          title: 'Settings',
          btnText: 'Clear Settings',
          desc: 'Stores site, session, theme etc cache.',
          icon: Icon(Icons.settings_applications, size: 16),
          path: '${SgsConfigService.get()!.applicationDocumentsPath}',
          onClearCache: onClearSettingCache,
        ),
        _buildCacheItem(
          title: 'Data Cache (${sizeStr})',
          btnText: 'Clear Data Cache',
          desc: 'Stores tack and single-cell data cache.',
          icon: Icon(Icons.sd_storage, size: 16),
          path: '${SgsConfigService.get()!.dataCachePath}',
          onClearCache: onClearDataCache,
        ),
        // SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Icon(Icons.warning_rounded, size: 36, color: Theme.of(context).colorScheme.error),
              SizedBox(width: 10),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Theme.of(context).colorScheme.errorContainer,
                ),
                child: Text('Re-open sgs is needed if you `manually` delete some of cache file.'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void onClearSettingCache() async {
    Get.offAllNamed(RoutePath.initialize);
    EntryLogic.get().check();
    // PlatformAdapter.create().setWindowSize(Size(860, 600));
    await BaseStoreProvider.get().clear();
    await SgsConfigService.get()!.init();
    SgsBrowseLogic.safe()?.initTheme();
  }

  void onClearDataCache() async {
    var _loading = BotToast.showLoading();
    await DioHelper().clearCache();

    await PlatformAdapter.create().deleteCacheFile('${SgsConfigService.get()!.applicationDocumentsPath}/sc');
    _loading.call();
    Navigator.of(context).maybePop(true);
    showToast(text: 'Data cache clear success!');
  }

  Widget _buildCacheItem({
    required String title,
    required String btnText,
    required String desc,
    required Icon icon,
    required String path,
    required VoidCallback onClearCache,
  }) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Material(
        // margin: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
        // color: Theme.of(context).canvasColor,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: FastRichText(
                  children: [
                    WidgetSpan(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: icon,
                      ),
                    ),
                    TextSpan(text: title, style: Theme.of(context).textTheme.titleMedium),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10, top: 10),
                child: Text(
                  desc,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10, top: 10, bottom: 10),
                child: Text(
                  'Path: $path',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              ButtonBar(
                alignment: MainAxisAlignment.start,
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.red,
                    ),
                    onPressed: onClearCache,
                    label: Text(btnText),
                    icon: Icon(Icons.delete_forever, size: 16),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      OpenFile.open(path);
                    },
                    label: Text('View In File'),
                    icon: Icon(Icons.folder, size: 18),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
