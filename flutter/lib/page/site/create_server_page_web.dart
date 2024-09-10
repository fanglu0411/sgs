import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/components/sgs_logo.dart';
import 'package:flutter_smart_genome/util/device_info.dart';
import 'package:flutter_smart_genome/util/native_window_util/app_title_bar.dart';
import 'package:flutter_smart_genome/base/ui_config.dart' as ui_config;

Widget createServerPage() => CreateServerPageWeb();

class CreateServerPageWeb extends StatefulWidget {
  CreateServerPageWeb({Key? key}) : super(key: key);

  @override
  _CreateServerPageState createState() => _CreateServerPageState();
}

class _CreateServerPageState extends State<CreateServerPageWeb> {
  @override
  Widget build(BuildContext context) {
    bool showLeading = !(DeviceOS.isMacOS || DeviceOS.isWeb);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: showLeading,
        toolbarHeight: ui_config.HORIZONTAL_TOOL_BAR_HEIGHT,
        titleSpacing: 0,
        title: Container(
          height: ui_config.HORIZONTAL_TOOL_BAR_HEIGHT,
          child: AppTitleBar(
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                SgsLogo(),
                Text('Deploy New Server'),
              ],
            ),
          ),
        ),
        actions: [
          if (!showLeading)
            TextButton.icon(
              onPressed: () {
                Navigator.of(context).maybePop();
              },
              icon: Icon(Icons.exit_to_app),
              label: Text('Exit'),
            ),
        ],
      ),
      body: Center(
        child: Text('Web Client is not support create server!', style: Theme.of(context).textTheme.titleLarge),
      ),
    );
  }
}