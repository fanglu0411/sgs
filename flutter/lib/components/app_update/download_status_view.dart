import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';

import 'download_progress_notifier.dart';

class AppDownloadStatusView extends StatefulWidget {
  final VoidCallback? onCancel;
  final VoidCallback? onInstall;

  final DownloadProgressNotifier progressNotifier;

  const AppDownloadStatusView({super.key, required this.progressNotifier, this.onCancel, this.onInstall});

  @override
  State<AppDownloadStatusView> createState() => _AppDownloadStatusViewState();
}

class _AppDownloadStatusViewState extends State<AppDownloadStatusView> {
  @override
  void initState() {
    super.initState();
    widget.progressNotifier.addListener(progressUpdate);
  }

  void progressUpdate() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var progress = widget.progressNotifier.progress;
    List updates = widget.progressNotifier.updates;
    String versionName = widget.progressNotifier.versionName;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text('New Version: ${versionName}', style: Theme.of(context).textTheme.titleMedium),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text('Updates:', style: Theme.of(context).textTheme.titleMedium),
        ),
        ...updates.mapIndexed((i, e) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text('${i + 1}. $e'),
            )),
        SizedBox(height: 10),
        Text(progress == 1.0 ? 'Download finish!' : 'Downloading... ${(progress * 100).round()}%', style: Theme.of(context).textTheme.bodySmall),
        SizedBox(height: 6),
        LinearProgressIndicator(value: progress, minHeight: 5),
        SizedBox(height: 16),
        if (progress == 1.0)
          ButtonBar(
            children: [
              TextButton(onPressed: widget.onCancel, child: Text('Cancel')),
              ElevatedButton(onPressed: widget.onInstall, child: Text('Exit And Install')),
            ],
          )
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
    widget.progressNotifier.removeListener(progressUpdate);
  }
}