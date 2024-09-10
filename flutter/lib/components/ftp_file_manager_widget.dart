import 'package:flutter_smart_genome/widget/basic/custom_spin.dart';
import 'package:flutter/material.dart';
import 'package:ftpconnect/ftpconnect.dart';
import 'package:ftpconnect/src/ftp_entry.dart';
import 'package:flutter_smart_genome/extensions/widget_extensions.dart';

class FtpFileManagerWidget extends StatefulWidget {
  final ValueChanged<List<String>>? onSelected;
  final String? host;

  const FtpFileManagerWidget({Key? key, this.onSelected, this.host}) : super(key: key);

  @override
  _FtpFileManagerWidgetState createState() => _FtpFileManagerWidgetState();
}

class _FtpFileManagerWidgetState extends State<FtpFileManagerWidget> {
  FTPConnect? _ftpConnect;
  bool _connected = false;
  bool _loading = false;
  String? _error;
  String? _rootDirectory;
  List<FTPEntry> _entries = [];

  List<String> _paths = [];

  @override
  void initState() {
    super.initState();
  }

  _connect(String host, int port, String user, String pass) async {
    setState(() {
      _loading = true;
    });
    if (_ftpConnect != null) await _ftpConnect?.disconnect();
    _ftpConnect = FTPConnect(host, port: port, user: user, pass: pass);
    _connected = await _ftpConnect!.connect();
    _paths = [];
    if (!_connected) {
      _error = "Can't connect to server";
      _loading = false;
      setState(() {});
      return;
    }
    _rootDirectory = await _ftpConnect!.currentDirectory();
    // _entries = await _ftpConnect.listDirectoryContent();
    _entries = await _toDirectory(_rootDirectory!);
    _loading = false;
    setState(() {});
  }

  Future<List<FTPEntry>> _toDirectory(String dirName) async {
    bool result = await _ftpConnect!.changeDirectory(dirName);
    if (dirName == '..') {
      if (_paths.length > 0) _paths.removeLast();
    } else {
      _paths.add(dirName);
    }
    if (result) {
      _error = null;
      return await _ftpConnect!.listDirectoryContent();
    } else {
      _error = 'Can not go to directory: $dirName';
      return _entries;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        children: [
          _connectForm(),
          if (_error != null) _message(),
          if (_paths.length > 0) _path(),
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              fit: StackFit.expand,
              children: [
                FileViewer(
                  fileEntries: _entries,
                  onTap: _onItemTap,
                ),
                if (_loading) maybeLoading()!,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _path() {
    return ListTile(
      selected: true,
      title: Text(_paths.join(' > ')),
    ).withBottomBorder(color: Theme.of(context).colorScheme.primary);
  }

  Widget _message() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: ListTile(
        selected: true,
        dense: true,
        // selectedTileColor: Colors.red.shade200,
        leading: Icon(Icons.message),
        title: Text(_error!),
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
      ).withBorder(Border.all(color: Colors.green)),
    );
  }

  void _onItemTap(FTPEntry entry) async {
    if (entry.type == FTPEntryType.DIR || entry.name == '..' || entry.name == '.') {
      setState(() {
        _loading = true;
      });
      _entries = await _toDirectory(entry.name);
      setState(() {
        _loading = false;
      });
    } else {
      widget.onSelected?.call([
        [..._paths, entry.name].join('/')
      ]);
    }
  }

  Widget? maybeLoading() {
    if (_loading) {
      return Container(
        color: Colors.black26.withOpacity(.3),
        child: CustomSpin(color: Theme.of(context).colorScheme.primary),
      );
    }
    return null;
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? _host;
  int? _port;
  String? _username;
  String? _pass;
  bool _passwordVisible = false;

  String _parseHost() {
    if (null != widget.host) {
      Uri uri = Uri.parse(widget.host!);
      return uri.host;
    }
    return '';
  }

  Widget _connectForm() {
    var _padding = EdgeInsets.symmetric(vertical: 0, horizontal: 8);
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Form(
        key: _formKey,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: 200,
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: 'host',
                  hintText: '0.0.0.0',
                  contentPadding: _padding,
                  border: OutlineInputBorder(),
                ),
                initialValue: _parseHost(),
                onSaved: (v) {
                  _host = v;
                },
              ),
            ),
            SizedBox(
              width: 60,
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: 'port',
                  hintText: '21',
                  contentPadding: _padding,
                  border: OutlineInputBorder(),
                ),
                // initialValue: '21',
                validator: (v) {
                  if (int.tryParse(v!) == null) return 'Port is not validate';
                  return null;
                },
                onSaved: (v) {
                  _port = int.tryParse(v!);
                },
              ),
            ),
            SizedBox(
              width: 150,
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: 'username',
                  hintText: 'username',
                  contentPadding: _padding,
                  border: OutlineInputBorder(),
                ),
                // initialValue: '',
                onSaved: (v) {
                  _username = v;
                },
              ),
            ),
            SizedBox(
              width: 150,
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: 'password',
                  hintText: 'password',
                  contentPadding: _padding,
                  border: OutlineInputBorder(),
                  suffixIcon: IconButton(
                    iconSize: 18,
                    constraints: BoxConstraints.tightFor(width: 20, height: 20),
                    splashRadius: 15,
                    padding: EdgeInsets.zero,
                    icon: Icon(_passwordVisible ? Icons.visibility_rounded : Icons.visibility_off_rounded),
                    onPressed: () {
                      setState(() {
                        _passwordVisible = !_passwordVisible;
                      });
                    },
                  ),
                ),
                // initialValue: '',
                obscureText: !_passwordVisible,
                keyboardType: TextInputType.visiblePassword,
                onSaved: (v) {
                  _pass = v;
                },
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              onPressed: _onSubmit,
              child: Text('Connect'),
            )
          ],
        ),
      ),
    );
  }

  _onSubmit() async {
    FormState formState = _formKey.currentState!;
    bool validate = formState.validate();
    if (!validate) {
      return;
    }
    formState.save();
    _connect(_host!, _port!, _username!, _pass!);
  }

  @override
  void dispose() {
    super.dispose();
    _ftpConnect?.disconnect();
  }
}

class FileViewer extends StatefulWidget {
  final List<FTPEntry> fileEntries;
  final bool isRoot;
  final ValueChanged<FTPEntry>? onTap;

  const FileViewer({
    Key? key,
    this.fileEntries = const [],
    this.isRoot = true,
    this.onTap,
  }) : super(key: key);

  @override
  _FileViewerState createState() => _FileViewerState();
}

class _FileViewerState extends State<FileViewer> {
  @override
  void initState() {
    super.initState();
  }

  Widget _itemBuilder(BuildContext context, int index) {
    FTPEntry entry = widget.fileEntries[index];
    return ListTile(
      leading: Icon(entry.type == FTPEntryType.DIR ? Icons.folder : Icons.insert_drive_file),
      title: Text(entry.name),
      trailing: entry.type == FTPEntryType.DIR ? Icon(Icons.arrow_forward_ios_rounded) : null,
      onTap: () => widget.onTap?.call(entry),
    ).withBottomBorder(color: Theme.of(context).dividerColor);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView.builder(
        itemBuilder: _itemBuilder,
        itemCount: widget.fileEntries.length,
      ),
    );
  }
}
