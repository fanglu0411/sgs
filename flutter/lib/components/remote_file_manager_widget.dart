import 'dart:convert';
import 'package:flutter_smart_genome/base/global_state.dart';
import 'package:flutter_smart_genome/components/window/multi_window_controller.dart';
import 'package:flutter_smart_genome/widget/basic/custom_spin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/base/container_config.dart';
import 'package:flutter_smart_genome/components/tree_widget.dart';
import 'package:flutter_smart_genome/components/trees.dart';
import 'package:flutter_smart_genome/network/api/simple_request.dart';
import 'package:flutter_smart_genome/page/admin/track/track_file_type.dart';
import 'package:flutter_smart_genome/page/cell/cell_tool_bar/toggle_button.dart';
import 'package:flutter_smart_genome/widget/toggle_button_group.dart';
import 'package:path/path.dart' as p;
import 'package:dartx/dartx.dart' as dx;
import 'package:flutter_smart_genome/extensions/widget_extensions.dart';

class RemoteFileManagerWidget extends StatefulWidget {
  final ValueChanged<List<RemoteFile>>? onSelected;
  final String? host;
  final bool treeMode;
  final bool enableDirectorySelect;
  final bool multi;
  final bool draggable;

  const RemoteFileManagerWidget({
    Key? key,
    this.onSelected,
    this.host,
    this.treeMode = false,
    this.enableDirectorySelect = false,
    this.multi = false,
    this.draggable = false,
  }) : super(key: key);

  @override
  _RemoteFileManagerWidgetState createState() => _RemoteFileManagerWidgetState();
}

class _RemoteFileManagerWidgetState extends State<RemoteFileManagerWidget> {
  bool _loading = false;
  String? _error;
  int _mode = 0;

  late RemoteFile _currentFile;

  @override
  void initState() {
    super.initState();
    _mode = widget.treeMode ? 1 : 0;
    var account = accountObs.value;
    String? lastPath = account?.lastDataPath;
    _currentFile = (lastPath != null && !widget.treeMode) ? RemoteFile.path(lastPath) : RemoteFile.root();
    _connect();
  }

  _connect([RemoteFile? remoteFile]) async {
    setState(() {
      _loading = true;
    });
    var path = (remoteFile ?? _currentFile).path;
    var resp = await postJson(
      path: '${widget.host}/api/folder/walk',
      cache: true,
      duration: Duration(minutes: 5),
      data: {'folder_path': path},
    );

    if (resp.success) {
      saveLastPath(path!);
      Map data = resp.body!;
      if (data['files'] != null) {
        List files = data['files'] ?? [];
        var __entries = files.map((e) => RemoteFile.fromMap(e, checked: (remoteFile ?? _currentFile).checked)).sortedByDescending((f) => f.type!).thenBy((f) => f.name).toList();
        __entries.forEach((f) {
          if (f.ext == '.zarr') {
            f.type = 'file';
          }
        });
        if (widget.treeMode) {
          (remoteFile ?? _currentFile)
            ..clearChildren()
            ..addAllChildren(__entries);
        } else {
          if (null != remoteFile) {
            _currentFile = remoteFile;
          }
          _currentFile.clearChildren();
          _currentFile.addAllChildren(__entries);
        }
      } else {
        _error = json.encode(data);
      }
    } else {
      _error = resp.error!.message;
    }
    _loading = false;
    setState(() {});
  }

  void saveLastPath(String path) {
    var account = accountObs.value;
    account?.lastDataPath = path;
    if (account != null) multiWindowController.notifyMainWindow(WindowCallEvent.updateLastDataPath.name, account.toJson()..removeWhere((k, v) => v == null));
  }

  void _onChangeMode(int m) {
    _mode = m;
    if (_mode == 1 && !(_currentFile.root as RemoteFile).sgsDataRoot) {
      _connect(RemoteFile.root());
    } else {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: CloseButton(),
          title: Text('Remote File Viewer', style: Theme.of(context).textTheme.titleLarge),
          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          trailing: ToggleButtonGroup(
            selectedIndex: _mode,
            borderRadius: BorderRadius.circular(4),
            constraints: BoxConstraints.tightFor(height: 32, width: 36),
            children: [
              Tooltip(child: Icon(Icons.folder), message: 'Folder view'),
              Tooltip(child: Icon(Icons.account_tree_rounded), message: 'Tree View'),
            ],
            onChange: _onChangeMode,
          ),
        ),
        if (_error != null) _message(),
        if (!_currentFile.isRoot && _mode == 0) _path(),
        Expanded(
          child: Stack(
            alignment: Alignment.center,
            fit: StackFit.expand,
            children: [
              if (_mode == 0)
                FileViewer(
                  fileEntry: _currentFile,
                  onTap: _onItemTap,
                  onSelect: _onSelectFile,
                  multi: widget.multi,
                  enableDirectorySelect: widget.enableDirectorySelect,
                  onMultiSelect: _onMultiSelect,
                  draggable: widget.draggable,
                ),
              if (_mode == 1)
                TreeFileViewer(
                  onFileSelected: _onMultiSelect,
                  root: _currentFile,
                  multi: widget.multi,
                  loader: _connect,
                ),
              if (_loading) maybeLoading()!,
            ],
          ),
        ),
      ],
    );
  }

  void _onFileCheckedChange(RemoteFile file, bool checked) {
    if (file.isDirectory) {
      file.checkWithChildren = checked;
      setState(() {});
    } else {
      RemoteFile? parent = file.parent as RemoteFile;
      // if (parent.checked == checked) return;
      // parent.checked = checked;
      setState(() {});
    }
  }

  Widget _path() {
    var trailing;
    if (widget.multi) {
      trailing = Checkbox(
        value: _currentFile.checked,
        onChanged: (v) {
          _currentFile.checkWithChildren = v!;
          setState(() {});
        },
      );
    } else if (widget.enableDirectorySelect) {
      trailing = IconButton(
        icon: Icon(Icons.check_box),
        padding: EdgeInsets.zero,
        tooltip: 'Select this Directory',
        constraints: BoxConstraints.tightFor(width: 30, height: 30),
        splashRadius: 15,
        onPressed: () => _onSelectFile(_currentFile),
      );
    }

    return ListTile(
      selected: true,
      leading: _currentFile.parent == null
          ? null
          : IconButton(
              icon: Icon(Icons.arrow_back),
              iconSize: 18,
              tooltip: 'BACK',
              onPressed: () {
                setState(() {
                  _currentFile = _currentFile.parent as RemoteFile;
                });
              },
            ),
      title: Text(_currentFile.path!, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
      horizontalTitleGap: 6,
      contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 0),
      trailing: trailing,
    ).withBottomBorder(color: Theme.of(context).colorScheme.primary);
  }

  Widget _message() {
    return ListTile(
      selected: true,
      dense: true,
      selectedTileColor: Theme.of(context).colorScheme.errorContainer.withOpacity(.35),
      leading: Icon(Icons.message),
      title: Text(_error!),
      // tileColor: Theme.of(context).colorScheme.errorContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      onTap: () {},
      trailing: IconButton(
        icon: Icon(Icons.close),
        iconSize: 20,
        padding: EdgeInsets.zero,
        constraints: BoxConstraints.tightFor(width: 20, height: 20),
        onPressed: () {
          setState(() {
            _error = null;
          });
        },
      ),
    );
  }

  void _onItemTap(RemoteFile remoteFile) {
    if (widget.treeMode && !remoteFile.isExpanded) {
      return;
    }

    if (remoteFile.path == '..') {
      if (_currentFile.parent != null) {
        setState(() {
          _currentFile = _currentFile.parent as RemoteFile;
        });
      } else {
        _connect(_currentFile.createParent());
      }
    } else if (remoteFile.isDirectory) {
      _connect(remoteFile);
    } else {
      _onSelectFile(remoteFile);
    }
  }

  void _onSelectFile(RemoteFile remoteFile) {
    widget.onSelected?.call([remoteFile]);
  }

  void _onMultiSelect(List<RemoteFile> remoteFiles) {
    widget.onSelected?.call(remoteFiles);
  }

  Widget? maybeLoading() {
    if (_loading) {
      return Container(
        color: Colors.black26.withOpacity(.15),
        child: CustomSpin(color: Theme.of(context).colorScheme.primary),
      );
    }
    return null;
  }
}

class FileViewer extends StatefulWidget {
  final RemoteFile fileEntry;
  final ValueChanged<RemoteFile>? onTap;
  final ValueChanged<RemoteFile>? onSelect;
  final ValueChanged<List<RemoteFile>>? onMultiSelect;
  final bool enableDirectorySelect;
  final bool multi;
  final bool draggable;

  const FileViewer({
    Key? key,
    required this.fileEntry,
    this.onTap,
    this.onSelect,
    this.enableDirectorySelect = false,
    this.multi = false,
    this.onMultiSelect,
    this.draggable = false,
  }) : super(key: key);

  @override
  _FileViewerState createState() => _FileViewerState();
}

class _FileViewerState extends State<FileViewer> {
  late List<RemoteFile> _files;

  // Map<String, RemoteFile> _selectedFiles = {};

  @override
  void initState() {
    super.initState();
    _files = <RemoteFile>[
      if (!widget.fileEntry.isRoot || widget.fileEntry.path != '/home/sgs') RemoteFile.parent(),
      ...((widget.fileEntry.children).sortedBy((f) => f.type!).sortedBy((f) => f.ext).toList()),
    ];
    // print(_files);
  }

  @override
  void didUpdateWidget(FileViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    _files = [
      if (!widget.fileEntry.isRoot || widget.fileEntry.path != '/home/sgs') RemoteFile.parent(),
      ...((widget.fileEntry.children).sortedBy((f) => f.type!).sortedBy((f) => f.ext).toList()),
    ];
    // _selectedFiles = {};
  }

  int _hoverIndex = -1;

  Widget _itemBuilder(BuildContext context, int index) {
    RemoteFile entry = _files[index];
    Widget _leading = widget.enableDirectorySelect && index == _hoverIndex && entry.isDirectory && entry.path != '..'
        ? IconButton(
            onPressed: () => widget.onSelect?.call(entry),
            tooltip: 'Tap to Select Directory',
            color: Theme.of(context).iconTheme.color,
            icon: Icon(Icons.check_box),
          ) //
        : Icon(entry.isDirectory ? Icons.folder : Icons.insert_drive_file_outlined);

    Widget tile = widget.multi && entry.isFile
        ? CheckboxListTile(
            value: entry.checked,
            onChanged: (c) => _toggleSelected(entry, c!),
            title: Row(
              children: [_leading, SizedBox(width: 10), Text(entry.name), Spacer(), Text('${entry.sizeStr}')],
            ),
          )
        : ListTile(
            leading: _leading,
            title: Text(entry.name),
            trailing: entry.isDirectory ? Icon(Icons.arrow_forward_ios_rounded, size: 16) : Text('${entry.sizeStr}'),
            onTap: () => entry.isFile ? widget.onSelect?.call(entry) : widget.onTap?.call(entry),
            horizontalTitleGap: 8,
          );

    tile = tile.withBottomBorder(color: Theme.of(context).dividerColor);
    if (entry.isFile) {
      if (widget.draggable) {
        tile = Draggable(
          child: tile,
          feedback: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 600),
            child: Card(
              child: ListTile(
                title: Text(entry.path!),
              ),
            ),
          ),
          data: entry.path,
        );
      }
      return tile;
    }

    return MouseRegion(
      onEnter: (e) {
        _hoverIndex = index;
        setState(() {});
      },
      onExit: (e) {
        _hoverIndex = -1;
        setState(() {});
      },
      child: tile,
    );
  }

  void _toggleSelected(RemoteFile file, bool checked) {
    file.checked = checked;
    // if (checked) {
    //   _selectedFiles[file.path] = file;
    // } else {
    //   _selectedFiles.remove(file.path);
    // }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var body = ListView.builder(
      itemBuilder: _itemBuilder,
      itemExtent: 50,
      itemCount: _files.length,
    );
    if (widget.multi) {
      var _selectedFiles = widget.fileEntry.children.where((f) => f.isFile && f.checked).toList();
      return Column(
        children: [
          Expanded(child: body),
          SizedBox(height: 12),
          if (_selectedFiles.isNotEmpty)
            FilledButton(
              child: Text('Done Select ${_selectedFiles.length}'),
              style: FilledButton.styleFrom(
                minimumSize: Size(120, 50),
              ),
              onPressed: () {
                if (_selectedFiles.isEmpty) return;
                widget.onMultiSelect?.call(_selectedFiles);
              },
            ),
          if (_selectedFiles.isNotEmpty) SizedBox(height: 12),
        ],
      );
    }
    return body;
  }
}

class TreeFileViewer extends StatefulWidget {
  final bool multi;
  final RemoteFile root;
  final ValueChanged<RemoteFile> loader;
  final ValueChanged<List<RemoteFile>>? onFileSelected;

  const TreeFileViewer({super.key, this.multi = false, required this.root, this.onFileSelected, required this.loader});

  @override
  State<TreeFileViewer> createState() => _TreeFileViewerState();
}

class _TreeFileViewerState extends State<TreeFileViewer> {
  _findSelected(RemoteFile file, List<RemoteFile> files) {
    if (file.hasChildren) {
      for (var f in file.children) {
        _findSelected(f, files);
      }
    } else if (file.isFile && file.checked) {
      files.add(file);
    }
  }

  void _onFileCheckedChange(RemoteFile file, bool checked) {
    if (file.isDirectory) {
      file.checkWithChildren = checked;
      setState(() {});
    } else {
      RemoteFile? parent = file.parent as RemoteFile?;
      // if (parent.checked == checked) return;
      // parent.checked = checked;
      setState(() {});
    }
  }

  void _onItemTap(RemoteFile remoteFile) {
    if (remoteFile.isDirectory) {
      if (!remoteFile.isExpanded || remoteFile.hasChildren) {
        return;
      }
      widget.loader.call(remoteFile);
    } else {
      if (widget.multi) {
        remoteFile.checked = !remoteFile.checked;
        setState(() {});
      } else {
        widget.onFileSelected?.call([remoteFile]);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    List<RemoteFile> _selectedFiles = [];
    _findSelected(widget.root.root as RemoteFile, _selectedFiles);
    return Column(
      children: [
        Expanded(
          child: TreeView<RemoteFile>(
            dataRoots: widget.root.root.children,
            dataDisplayProvider: (file) => TreeItemWidget(
              file: file,
              checkable: widget.multi,
              onCheckedChange: (v) => _onFileCheckedChange(file, v),
            ),
            onItemPressed: _onItemTap,
          ),
        ),
        if (_selectedFiles.length > 0)
          FilledButton(
            style: FilledButton.styleFrom(
              minimumSize: Size(120, 50),
            ),
            onPressed: () {
              if (_selectedFiles.isEmpty) return;
              widget.onFileSelected?.call(_selectedFiles);
            },
            child: Text('Done select ${_selectedFiles.length}'),
          ),
        SizedBox(height: 12),
      ],
    );
  }
}

class TreeItemWidget extends StatefulWidget {
  final bool checkable;
  final RemoteFile file;
  final ValueChanged<bool>? onCheckedChange;

  const TreeItemWidget({
    Key? key,
    required this.file,
    this.onCheckedChange,
    this.checkable = false,
  }) : super(key: key);

  @override
  State<TreeItemWidget> createState() => _TreeItemWidgetState();
}

class _TreeItemWidgetState extends State<TreeItemWidget> {
  @override
  void initState() {
    super.initState();
  }

  void _onCheckedChange(bool v) {
    widget.file.checked = v;
    setState(() {});
    widget.onCheckedChange?.call(v);
  }

  @override
  Widget build(BuildContext context) {
    var file = widget.file;
    var textTheme = Theme.of(context).textTheme.displayMedium!.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w300,
          color: file.checked ? Theme.of(context).colorScheme.primary : null,
          fontFamily: MONOSPACED_FONT,
          fontFamilyFallback: MONOSPACED_FONT_BACK,
        );

    var toggleButton = widget.checkable
        ? ToggleButton(
            label: file.checked ? Icon(Icons.check, size: 16) : SizedBox(width: 16, height: 16),
            height: 18,
            padding: EdgeInsets.symmetric(horizontal: 1, vertical: 1),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
            borderWidth: 1.5,
            checked: file.checked,
            onChanged: _onCheckedChange,
          )
        : null;

    Widget item = Container(
      padding: EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: file.isDirectory
          ? RichText(
              text: TextSpan(
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w300),
                children: [
                  WidgetSpan(child: Padding(padding: EdgeInsets.only(right: 6), child: Icon(Icons.folder, size: 18))),
                  if (toggleButton != null) WidgetSpan(child: Padding(padding: const EdgeInsets.only(right: 6.0), child: toggleButton)),
                  if (file.isExpanded) TextSpan(text: '${file.directory}/', style: Theme.of(context).textTheme.bodySmall!.copyWith(fontSize: 14, fontWeight: FontWeight.w300, letterSpacing: 1)),
                  TextSpan(text: file.name, style: textTheme.copyWith(fontWeight: FontWeight.w400, fontSize: 18)),
                ],
              ),
            )
          : Row(
              children: [
                if (toggleButton != null) toggleButton,
                SizedBox(width: 10),
                Text(file.name, style: textTheme),
                Spacer(),
                Text(file.sizeStr, style: textTheme.copyWith(fontSize: 14)),
                SizedBox(width: 12),
              ],
            ),
    );
    if (file.isFile) {
      item = Draggable(
        data: file.path,
        child: item,
        feedback: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 600),
          child: Card(
            child: ListTile(
              title: Text(file.path!),
              trailing: Text(file.sizeStr),
            ),
          ),
        ),
      );
    }
    return item;
  }
}

class RemoteFile extends TreeNode<RemoteFile> {
  String? path;
  int? size;
  String? type;
  bool checked = false;
  TrackFileType? _fileType;

  TrackFileType get fileType {
    if (null == _fileType || _fileType == TrackFileType.unknown) {
      _fileType = findTrackFileType(path!);
    }
    return _fileType!;
  }

  void set fileType(TrackFileType type) => _fileType = type;

  String get serverTrackType => toServerTrackType(_fileType!);

  bool get isUnknown => fileType == TrackFileType.unknown;

  bool get isFasta => fileType == TrackFileType.fasta;

  bool get isSc => fileType == TrackFileType.sc_h5ad;

  String get sizeStr {
    int size = this.size!;
    double kb = size / 1024;
    if (kb < 1024) {
      return '${kb.toStringAsFixed(2)}kb';
    }
    double m = size / 1048576;
    if (m < 1024) {
      return '${m.toStringAsFixed(2)}M';
    }
    double gb = size / 1073741824;
    return '${gb.toStringAsFixed(2)}G';
  }

  bool get isDirectory => type == 'folder';

  bool get isFile => type == 'file';

  String get name => p.basename(path!);

  String get directory => p.dirname(path!);

  String get ext => p.extension(path!);

  RemoteFile createParent() {
    return RemoteFile.path(directory);
  }

  bool get sgsDataRoot => path == '/home/sgs/data';

  @override
  bool get isExpandable {
    return isDirectory;
  }

  bool get hasChildren => children.length > 0;

  RemoteFile.path(String path) {
    this.path = path;
    type = 'file';
  }

  RemoteFile.fromMap(Map map, {bool checked = false}) {
    path = map['name'];
    size = map['size'];
    type = map['type'];
    this.checked = checked;
  }

  RemoteFile.root() {
    path = '/home/sgs/data';
    size = 0;
    type = 'folder';
    checked = false;
  }

  RemoteFile.parent() {
    path = '..';
    size = 0;
    type = 'folder';
    checked = false;
  }

  set checkWithChildren(bool checked) {
    _check(this, checked);
  }

  void _check(RemoteFile file, bool checked) {
    file.checked = checked;
    if (file.hasChildren) {
      for (var _file in file.children) {
        _check(_file, checked);
      }
    }
  }

  @override
  String toString() {
    return 'RemoteFile{path: $path, size: $size, type: $type, children: ${children.length}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is RemoteFile && runtimeType == other.runtimeType && path == other.path && size == other.size && type == other.type && children == other.children;

  @override
  int get hashCode => path.hashCode ^ size.hashCode ^ type.hashCode ^ children.length.hashCode;
}
