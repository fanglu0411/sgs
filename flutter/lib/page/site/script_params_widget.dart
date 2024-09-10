import 'package:bot_toast/bot_toast.dart';
import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/base/container_config.dart';
import 'package:flutter_smart_genome/widget/basic/custom_bot_widget.dart';
import 'package:flutter_smart_genome/widget/basic/fast_rich_text.dart';

class ScriptParamsWidget extends StatefulWidget {
  final VoidCallback? onBack;
  final Function4<int, int, int, String, void>? onSubmit;
  final String host;
  final String dataPath;

  const ScriptParamsWidget({
    super.key,
    this.host = 'localhost',
    this.dataPath = '/data/docker/vol/sgs',
    this.onSubmit,
    this.onBack,
  });

  @override
  State<ScriptParamsWidget> createState() => _ScriptParamsWidgetState();
}

class _ScriptParamsWidgetState extends State<ScriptParamsWidget> {
  TextEditingController? _pathController;
  TextEditingController? _mysqlController;
  TextEditingController? _apiPortController;
  TextEditingController? _webPortController;

  @override
  void initState() {
    super.initState();
    _pathController = TextEditingController(text: widget.dataPath);
    _mysqlController = TextEditingController(text: '33061');
    _apiPortController = TextEditingController(text: '6102');
    _webPortController = TextEditingController(text: '1080');
  }

  String? portError(TextEditingController text) {
    int? port = int.tryParse(text.text);
    return port == null ? 'Port is invalid' : null;
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Material(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Container(
        constraints: BoxConstraints(maxWidth: 480, minWidth: 200),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: Text('Confirm server params settings!', style: Theme.of(context).textTheme.titleLarge),
              contentPadding: EdgeInsets.zero,
            ),
            Text('If some port on your server is already in use, then you can custom by yourself!'),
            SizedBox(height: 10),
            FastRichText(
              children: [
                TextSpan(text: 'Server host: '),
                TextSpan(text: '${widget.host}', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.primary)),
              ],
              textStyle: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: 10),
            TextField(
              controller: _pathController,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 4),
                alignLabelWithHint: false,
                prefix: _prefix('Data path:'),
                helperText: 'sgs data path, will auto create api and mysql folder.',
                // constraints: BoxConstraints(maxWidth: 120, minWidth: 120),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _mysqlController,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 4),
                alignLabelWithHint: false,
                prefix: _prefix('DB  Port:'),
                helperText: 'sgs database port, usually no need to change.',
                errorText: portError(_mysqlController!),
                // constraints: BoxConstraints(maxWidth: 120, minWidth: 120),
              ),
              onChanged: (s) {
                setState(() {});
              },
            ),
            SizedBox(height: 10),
            TextField(
              controller: _apiPortController,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 4),
                prefix: _prefix('Api Port:'),
                helperText: 'sgs api port, usually no need to change.',
                errorText: portError(_apiPortController!),
                // constraints: BoxConstraints(maxWidth: 120),
              ),
              onChanged: (s) {
                setState(() {});
              },
            ),
            SizedBox(height: 10),
            TextField(
              controller: _webPortController,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 4),
                prefix: _prefix('Web Port:'),
                helperMaxLines: 2,
                errorText: portError(_webPortController!),
                helperText: 'sgs web client port, visit sgs website by:\nhttp://${widget.host}:${_webPortController?.text} or http://your-ip:${_webPortController?.text}',
                // constraints: BoxConstraints(maxWidth: 120),
              ),
              onChanged: (s) {
                setState(() {});
              },
            ),
            SizedBox(height: 10),
            ButtonBar(
              children: [
                ElevatedButton(
                  onPressed: widget.onBack,
                  child: Text('Back'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(120, 36),
                  ),
                ),
                FilledButton(
                  onPressed: _check,
                  child: Text('Next'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(120, 36),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _prefix(String label) {
    return Container(
      constraints: BoxConstraints(maxWidth: 100, maxHeight: 36, minWidth: 70),
      // alignment: Alignment.center,
      margin: EdgeInsets.only(right: 6),
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: Theme.of(context).colorScheme.primary.withOpacity(.12),
      ),
      child: Text(label, style: Theme.of(context).textTheme.labelLarge),
    );
  }

  void _check() {
    int? mysqlPort = int.tryParse(_mysqlController!.text);
    int? apiPort = int.tryParse(_apiPortController!.text);
    int? webPort = int.tryParse(_webPortController!.text);
    String path = _pathController!.text.trim();

    if (path.isEmpty) {
      showToast(text: 'Data path is invalid');
      return;
    }

    if (mysqlPort == null || mysqlPort == 0) {
      showToast(text: 'Mysql port is invalid');
      return;
    }
    if (apiPort == null || apiPort == 0) {
      showToast(text: 'Api port is invalid');
      return;
    }
    if (webPort == null || webPort == 0) {
      showToast(text: 'Web port is invalid');
      return;
    }
    widget.onSubmit?.call(mysqlPort, apiPort, webPort, path);
  }

  @override
  void dispose() {
    super.dispose();
    _pathController?.dispose();
    _mysqlController?.dispose();
    _apiPortController?.dispose();
    _webPortController?.dispose();
  }
}
