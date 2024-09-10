import 'dart:typed_data';
import 'dart:ui';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_smart_genome/base/container_config.dart';
import 'package:flutter_smart_genome/base/ui_config.dart';
import 'package:flutter_smart_genome/bloc/track_config/track_config_event.dart';
import 'package:flutter_smart_genome/components/shortener/url_shorten_widget.dart';
import 'package:flutter_smart_genome/service/sgs_app_service.dart';
import 'package:flutter_smart_genome/util/file_util.dart';
import 'package:flutter_smart_genome/widget/basic/custom_bot_widget.dart';
import 'package:flutter_smart_genome/widget/track/base/track_session.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share/share.dart';

class WidgetUtil {
  static DateFormat dateFormat = DateFormat('yyyy-MM-dd-hhmmss');

  static Future widget2Image(GlobalKey? repaintBoundaryKey, {String? fileName = null, double pixelRatio = 4.0}) async {
    if (repaintBoundaryKey == null) return;
    var dismiss = BotToast.showLoading();
    return Future.delayed(Duration(milliseconds: 100), () async {
      RenderRepaintBoundary ro = repaintBoundaryKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      var image = await ro.toImage(pixelRatio: pixelRatio);
      ByteData? byteData = await image.toByteData(format: ImageByteFormat.png);
      if (byteData != null) {
        fileName ??= 'sgs-${dateFormat.format(DateTime.now())}';
        var result = await FileUtil.saveByteData('${fileName}.png', byteData!.buffer.asUint8List());
        showToast(text: result ? 'save image success!' : 'save image failed!');
      }
      dismiss.call();
    });
  }

  static void showShareDialog(BuildContext context, TrackSession? session) async {
    if (null == session) return;
    String url = await session.toShareUrl();
    url = Uri.encodeFull(url);
    var size = MediaQuery.of(context).size;
    var dialog = AlertDialog(
      title: Text('Share session'),
      content: Container(
        constraints: BoxConstraints.tightFor(width: 800.0.clamp(size.width * .3, size.width * .8)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            QrImageView(
              data: url,
              size: isMobile(context) ? 150 : 200,
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 15),
              child: UrlShortenWidget(url: url),
            ),
            if (mobilePlatform())
              ButtonBar(
                children: [
                  TextButton(
                    child: Text('CANCEL'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                    ),
                    onPressed: () {
                      Size _size = MediaQuery.of(context).size;
                      Share.share(
                        url,
                        subject: 'SGS Share: ${session.speciesName}',
                        sharePositionOrigin: Rect.fromLTWH(0, _size.height - 100, _size.width, 10),
                      );
                    },
                    child: Text('Share'),
                  ),
                ],
              )
          ],
        ),
      ),
    );
    showDialog(context: context, builder: (context) => dialog);
  }

  static CancelFunc? _shareReceiveDialog;

  static void openOutUrlDialog(TrackSession session) async {
    _shareReceiveDialog?.call();
    var context = Get.context!;
    var shareUrl = await session.toShareUrl();
    var dialog = (CancelFunc c) => AlertDialog(
          title: Text('Open url ?'),
          scrollable: true,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Share Url detected, do you want to open now?'),
              SizedBox(height: 10),
              Text(
                  [
                    'Server : ${session.url}',
                    'Species: ${session.speciesName}',
                    'Range  : ${session.range?.print2()}',
                  ].join('\n'),
                  style: TextStyle(fontFamily: MONOSPACED_FONT, fontFamilyFallback: MONOSPACED_FONT_BACK, height: 1.5)),
              SizedBox(height: 10),
              Text('${shareUrl}', style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
          actions: [
            ElevatedButton(
              child: Text('NO'),
              onPressed: () => c.call(),
            ),
            FilledButton(
              child: Text('YES'),
              onPressed: () {
                c.call();
                SgsAppService.get()?.sendEvent(LoadSessionEvent(session: session));
              },
            ),
          ],
        );

    _shareReceiveDialog = BotToast.showEnhancedWidget(
      toastBuilder: (c) {
        return Center(child: Container(constraints: BoxConstraints(maxWidth: (Get.width * .65).clamp(200, 900)), child: dialog(c)));
      },
      crossPage: true,
      allowClick: false,
      onlyOne: true,
      groupKey: 'receive-share-dialog',
      clickClose: false,
      backgroundColor: Colors.black54.withOpacity(.5),
      onClose: () {
        _shareReceiveDialog = null;
      },
    );
  }
}
