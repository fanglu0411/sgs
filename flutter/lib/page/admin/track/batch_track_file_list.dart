import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_genome/base/ui_config.dart';
import 'package:flutter_smart_genome/extensions/widget_extensions.dart';
import 'package:flutter_smart_genome/page/admin/base/base_widgets.dart';
import 'package:flutter_smart_genome/page/admin/track/track_file.dart';
import 'package:flutter_smart_genome/page/admin/track/track_file_type.dart';
import 'package:flutter_smart_genome/widget/basic/custom_multi_size_layout.dart';
import 'package:path/path.dart' as path;

class BatchTrackPreviewWidget extends StatefulWidget {
  final List<TrackFile>? files;
  final VoidCallback? onClear;
  final ValueChanged<TrackFile>? onFileDelete;

  const BatchTrackPreviewWidget({Key? key, this.files, this.onFileDelete, this.onClear}) : super(key: key);

  @override
  State<BatchTrackPreviewWidget> createState() => _BatchTrackPreviewWidgetState();
}

class _BatchTrackPreviewWidgetState extends State<BatchTrackPreviewWidget> {
  @override
  Widget build(BuildContext context) {
    return _buildFileList();
  }

  void _setType(TrackFile file) async {
    var dialog = (context) => SimpleDialog(
          title: Text('Assign track type'),
          children: trackFileTypeMapper.keys
              .map((e) => SimpleDialogOption(
                    child: Container(alignment: Alignment.centerLeft, child: FileTypeWidget(e)),
                    onPressed: () {
                      Navigator.of(context).pop(e);
                    },
                  ).withBottomBorder(color: Theme.of(context).dividerColor))
              .toList(),
        );
    var type = await showDialog(context: context, builder: dialog);
    if (null != type) {
      file.remoteFile.fileType = type;
      String ext = path.extension(file.remoteFile.path!, 2);
      if (!ext.isEmpty) {
        trackFileTypeMapper[type]!.add(ext);
      }
      setState(() {});
    }
  }

  Widget _buildFileList() {
    var _files = widget.files;
    if (_files == null) return SizedBox();

    var files = _files.mapIndexed((i, e) {
      return TrackFileItemWidget(
        index: i,
        file: e,
        onSetType: _setType,
        onRename: _showRenameDialog,
        onDelete: _onFileDelete,
      );
    }).toList();
    bool _isMobile = isMobile(context);
    if (_isMobile) {
      return Column(
        children: files,
        mainAxisSize: MainAxisSize.min,
      );
    }
    return Card(
      child: Column(
        children: [
          _listHeader(),
          Divider(height: 1),
          ...ListTile.divideTiles(tiles: files, color: Theme.of(context).dividerColor),
        ],
        mainAxisSize: MainAxisSize.min,
      ),
    );
  }

  Widget _listHeader() {
    return ListTile(
      leading: Text('Index'),
      title: Text('File name'),
      titleTextStyle: Theme.of(context).textTheme.bodySmall,
      textColor: Theme.of(context).textTheme.bodyMedium?.color,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('File size'),
          SizedBox(width: 20),
          SizedBox(child: Container(alignment: Alignment.centerLeft, child: Text('Type')), width: 90),
          SizedBox(width: 10),
          SizedBox(
            width: 90,
            child: Text('Operation'),
          ),
          SizedBox(width: 10),
          IconButton(
            tooltip: "Clear all",
            padding: EdgeInsets.zero,
            constraints: BoxConstraints.tightFor(width: 30, height: 30),
            onPressed: () => widget.onClear?.call(),
            iconSize: 18,
            icon: Icon(Icons.clear_all, color: Colors.red),
          ),
        ],
      ),
    );
  }

  void _onFileDelete(TrackFile file) {
    widget.files!.remove(file);
    setState(() {});
    widget.onFileDelete?.call(file);
  }

  TextEditingController? _renameController;

  void _showRenameDialog(TrackFile file) async {
    _renameController = TextEditingController(text: file.trackName);
    String value = file.trackName;
    var dialog = (BuildContext context) => AlertDialog(
          title: Text('Rename Track Name'),
          content: TextField(
            controller: _renameController,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
            ),
            onChanged: (v) {},
          ),
          actions: [
            ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(null);
                },
                child: Text('Cancel')),
            ElevatedButton(
                onPressed: () {
                  var text = _renameController!.text.trim();
                  if (text.isEmpty) return;
                  Navigator.of(context).pop(text);
                },
                child: Text('Ok'))
          ],
        );
    var result = await showDialog(context: context, builder: dialog, barrierDismissible: false);
    if (null != result) {
      String name = result;
      file.trackName = name;
      setState(() {});
    }
  }
}

class TrackFileItemWidget extends StatefulWidget {
  final TrackFile file;
  final ValueChanged<TrackFile>? onSetType;
  final ValueChanged<TrackFile>? onRename;
  final ValueChanged<TrackFile>? onDelete;
  final int index;

  const TrackFileItemWidget({
    Key? key,
    required this.file,
    this.onSetType,
    this.onRename,
    this.onDelete,
    required this.index,
  }) : super(key: key);

  @override
  State<TrackFileItemWidget> createState() => _TrackFileItemWidgetState();
}

class _TrackFileItemWidgetState extends State<TrackFileItemWidget> {
  bool _entered = false;

  @override
  Widget build(BuildContext context) {
    return CustomMultiSizeLayout.builder(
      breakpoints: defaultBreakPoints,
      mobile: mobile,
      tablet: tablet,
    );
  }

  Widget mobile(BuildContext context) {
    var file = widget.file;
    // var ext = path.extension(file.remoteFile.path, 2);
    var style = Theme.of(context).textTheme.titleMedium;
    var subTitleStyle = Theme.of(context).textTheme.bodySmall;
    return Card(
      elevation: 6,
      margin: EdgeInsets.symmetric(vertical: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            dense: true,
            leading: CircleAvatar(
              radius: 15,
              child: Text('${widget.index + 1}', textScaler: TextScaler.linear(1.2)),
            ),
            horizontalTitleGap: 6,
            title: Text(file.trackName, style: style),
            subtitle: Text(file.remoteFile.path!, style: subTitleStyle!.copyWith(color: file.remoteFile.isUnknown ? Colors.red : null)),
            onTap: () {},
          ),
          Divider(thickness: 1),
          // SizedBox(height: 5),
          Row(
            // mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(width: 16),
              Text('Type: '),
              FileTypeWidget(file.remoteFile.fileType),
              Spacer(),
              Text('File Size: '),
              Text(file.remoteFile.sizeStr),
              SizedBox(width: 18),
            ],
          ),
          // SizedBox(height: 5),
          Divider(thickness: 1),
          Row(
            children: [
              SizedBox(width: 10),
              TextButton.icon(
                icon: Icon(Icons.edit_note, size: 16),
                onPressed: () => widget.onRename?.call(file),
                label: Text('rename'),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  minimumSize: Size(60, 40),
                  elevation: 0,
                  // side: BorderSide(color: Theme.of(context).colorScheme.primary, width: .5),
                ),
              ),
              IconButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: file.remoteFile.name));
                },
                iconSize: 16,
                tooltip: 'copy name',
                icon: Icon(Icons.copy),
                padding: EdgeInsets.zero,
                constraints: BoxConstraints.tightFor(width: 30, height: 30),
              ),
              Spacer(),
              TextButton.icon(
                onPressed: () => widget.onSetType?.call(file),
                icon: Icon(Icons.tag, size: 16),
                label: Text('Set a Type'),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                  minimumSize: Size(90, 40),
                  // maximumSize: Size(90, 40),
                  elevation: 0,
                ),
              ),
              Spacer(),
              TextButton.icon(
                onPressed: () => widget.onDelete?.call(file),
                icon: Icon(Icons.delete, size: 16),
                label: Text('Delete'),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                  minimumSize: Size(90, 40),
                  // maximumSize: Size(90, 40),
                  elevation: 0,
                ),
              ),
              SizedBox(width: 10),
            ],
          ),
          SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget tablet(BuildContext context) {
    var file = widget.file;
    // var ext = path.extension(file.remoteFile.path, 2);
    var style = Theme.of(context).textTheme.titleMedium;
    var subTitleStyle = Theme.of(context).textTheme.bodySmall;
    return MouseRegion(
      onHover: (s) {},
      onEnter: (s) {
        _entered = true;
        setState(() {});
      },
      onExit: (s) {
        _entered = false;
        setState(() {});
      },
      child: ListTile(
        dense: true,
        leading: CircleAvatar(
          radius: 15,
          child: Text('${widget.index + 1}', textScaler: TextScaler.linear(1.2)),
        ),
        // horizontalTitleGap: 0,
        title: Row(
          children: [
            Text(file.trackName, style: style),
            SizedBox(width: 12),
            if (_entered)
              OutlinedButton.icon(
                icon: Icon(Icons.edit, size: 16),
                onPressed: () => widget.onRename?.call(file),
                label: Text('rename'),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  minimumSize: Size(60, 30),
                  elevation: 0,
                  side: BorderSide(color: Theme.of(context).colorScheme.primary, width: .5),
                ),
              ),
            SizedBox(width: 10),
            if (_entered)
              IconButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: file.remoteFile.name));
                },
                iconSize: 16,
                splashRadius: 15,
                tooltip: 'copy name',
                icon: Icon(Icons.copy),
                padding: EdgeInsets.zero,
                constraints: BoxConstraints.tightFor(width: 30, height: 24),
              ),
          ],
        ),
        subtitle: Text(file.remoteFile.path!, style: subTitleStyle!.copyWith(color: file.remoteFile.isUnknown ? Colors.red : null)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(file.remoteFile.sizeStr),
            SizedBox(width: 20),
            SizedBox(child: Container(alignment: Alignment.centerLeft, child: FileTypeWidget(file.remoteFile.fileType)), width: 90),
            SizedBox(width: 10),
            SizedBox(
              width: 90,
              child: _entered
                  ? OutlinedButton(
                      onPressed: () => widget.onSetType?.call(file),
                      child: Text('Set a Type'),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                        minimumSize: Size(90, 32),
                        maximumSize: Size(90, 40),
                        elevation: 0,
                        side: BorderSide(color: Theme.of(context).colorScheme.primary, width: .5),
                      ),
                    )
                  : null,
            ),
            SizedBox(width: 10),
            IconButton(
              tooltip: "Delete",
              padding: EdgeInsets.zero,
              constraints: BoxConstraints.tightFor(width: 30, height: 30),
              onPressed: () => widget.onDelete?.call(file),
              iconSize: 18,
              icon: Icon(Icons.clear, color: Colors.red),
            ),
          ],
        ),
        onTap: () {},
      ),
    );
  }
}
