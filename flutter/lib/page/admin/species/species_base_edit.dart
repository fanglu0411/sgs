import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/base/container_config.dart';
import 'package:flutter_smart_genome/base/ui_config.dart';
import 'package:flutter_smart_genome/bean/field_item.dart';
import 'package:flutter_smart_genome/components/remote_file_manager_widget.dart';
import 'package:flutter_smart_genome/page/admin/base/base_widgets.dart';
import 'package:flutter_smart_genome/page/admin/track/batch_track_file_list.dart';
import 'package:flutter_smart_genome/page/admin/track/track_file.dart';
import 'package:flutter_smart_genome/widget/basic/alert_widget.dart';
import 'package:flutter_smart_genome/widget/basic/custom_bot_widget.dart';
import 'package:flutter_smart_genome/widget/basic/simple_form.dart';
import 'package:path/path.dart' as path;

class SpeciesBaseForm extends StatefulWidget {
  final Map? map;
  final ValueChanged<Map<String, dynamic>>? onSubmit;
  final String? host;

  const SpeciesBaseForm({
    Key? key,
    this.map,
    this.onSubmit,
    this.host,
  }) : super(key: key);

  @override
  _SpeciesBaseFormState createState() => _SpeciesBaseFormState();
}

class _SpeciesBaseFormState extends State<SpeciesBaseForm> with AutomaticKeepAliveClientMixin {
  late List<FieldItem> _fieldItems;

  List<TrackFile>? _files;
  List<TrackFile> _fastaFiles = [];

  _initFields() {
    _fieldItems = [
      // if (kIsWeb)
      //   FieldItem.upload(
      //     name: 'fasta_file',
      //     label: 'Fasta',
      //     fieldType: FieldType.file,
      //     required: true,
      //     fileValueMapper: (item) => item.response,
      //   ),
      // if (!kIsWeb)
      // FieldItem.remoteFile(
      //   name: 'fasta_file',
      //   label: 'Fasta / Folder',
      //   required: true,
      //   enableDirectorySelect: true,
      //   helperText: 'Select a fasta file to add species.\nYou can also select a folder(which contains a fasta file and other track files) to add species and generate tracks automatically!',
      //   fileValueMapper: (item) => item.response,
      //   // fileSource: 1,
      //   onChanged: _onFileChanged,
      // ),
      FieldItem.remoteFile(
        name: 'file_list',
        label: 'Fasta / Folder',
        required: true,
        enableDirectorySelect: false,
        multiFile: true,
        helperText: 'Select a fasta file, some genome track files or single-cell(h5ad) files!',
        fileValueMapper: (item) => item?.response,
        // fileSource: 1,
        onChanged: _onFileChanged,
      ),
      FieldItem.name(
        name: 'species_name',
        label: 'Name',
        hint: 'species name',
        required: true,
      ),
      FieldItem.builder(widgetBuilder: _fileListTips),
      FieldItem.builder(widgetBuilder: _fileListBuilder),

      // FieldItem.upload(
      //   name: 'iconUrl',
      //   label: 'Icon',
      //   fieldType: FieldType.image,
      //   maxSize: 200,
      // ),
    ];
  }

  Widget _fileListTips(BuildContext context) {
    if (_files == null) return SizedBox();
    int scCount = _files!.count((e) => e.remoteFile.isSc);
    List errors = [
      if (_fastaFiles.isEmpty && scCount == 0) 'No fasta and single-cell(h5ad) file selected. please add at least one of theme.',
      if (_files!.any((f) => f.remoteFile.isUnknown)) '`unknown` means file type is not recognized, you can set a type manually, otherwise it will be ignored.',
    ];
    if (errors.length > 0) {
      return AlertWidget.error(message: Text(errors.join('\n')));
    }
    return SizedBox();
  }

  Widget _fileListBuilder(BuildContext context) {
    return BatchTrackPreviewWidget(
      files: _files,
      onFileDelete: _onFileDelete,
      onClear: () {
        _files?.clear();
        _fastaFiles.clear();
        setState(() {});
      },
    );
  }

  void _onFileDelete(TrackFile file) {
    if (file.remoteFile.isFasta) {
      _fastaFiles = _files!.where((f) => f.remoteFile.isFasta).toList();
      if (_fastaFiles.length == 1) {
        _fillSpeciesName(_fastaFiles.first);
      }
      setState(() {});
    }
  }

  _onFileChanged(v, FieldItem field) {
    if (v is RemoteFile) {
      String name = path.basenameWithoutExtension(v.path!);
      FieldItem? nameField = _fieldItems.firstOrNullWhere((e) => e.name == "species_name");
      nameField!.value = name;
      _fastaFiles = [TrackFile.from(v)];
      setState(() {});
    } else if (v is List<RemoteFile>) {
      _files = v.map<TrackFile>((e) => TrackFile.from(e)).toList();
      _fastaFiles = _files!.where((f) => f.remoteFile.isFasta).toList();
      if (_fastaFiles.length == 1) {
        _fillSpeciesName(_fastaFiles.first);
      }
      setState(() {});
    }
  }

  void _fillSpeciesName(TrackFile fastaFile) {
    FieldItem? nameField = _fieldItems.firstOrNullWhere((e) => e.name == "species_name");
    nameField?.value = fastaFile.trackName;
  }

  setFormValues(Map? map) {
    if (map == null) return;
    _fieldItems.forEach((fieldItem) {
      var value = map[fieldItem.name];
      fieldItem.value = value ?? '';
    });
  }

  @override
  void initState() {
    super.initState();
    _initFields();
    setFormValues(widget.map);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
//      color: Colors.white,
      padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 20),
      child: SimpleForm(
        fields: _fieldItems,
        reset: true,
        filled: true,
        buttonAlignment: MainAxisAlignment.start,
        buttonExpand: isMobile(context),
        divider: Container(height: 1, color: Theme.of(context).dividerTheme.color),
        inputBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
        host: widget.host,
        onSubmit: _onSubmit,
        buttonShape: buttonShape(),
        onReset: _onReset,
      ),
    );
  }

  void _onReset() {
    _files = [];
    _fastaFiles = [];
    setState(() {});
  }

  void _onSubmit(Map values) async {
    if (_files!.length == 0) {
      showToast(text: "No file selected.", backgroundColor: Colors.red);
      return;
    }

    // if (_fastaFiles.length > 1) {
    //   showToast(text: "Only one fasta file is allowed, please delete other fasta.", backgroundColor: Colors.red);
    //   return;
    // }

    int fastCount = _files!.count((e) => e.remoteFile.isFasta);
    int scCount = _files!.count((e) => e.remoteFile.isSc);
    if (fastCount == 0 && scCount == 0) {
      showToast(text: "No fasta and single-cell(h5ad) file selected. please add at least one", backgroundColor: Colors.red);
      return;
    }

    if (fastCount > 1) {
      showToast(text: "Only one fasta file is allowed, please delete other fasta.", backgroundColor: Colors.red);
      return;
    }

    List<TrackFile> unknownFiles = _files!.where((e) => e.remoteFile.isUnknown).toList();
    if (unknownFiles.isEmpty) {
      _submit(values);
      return;
    }

    /// unknownFiles is not empty
    var result = await showDialog(context: context, builder: (c) => UnknownFilesDialog(context, unknownFiles));
    if (result != null && result) {
      _submit(values);
    }
  }

  void _submit(Map values) {
    values.remove('file_list');

    var trackFiles = _files!.where((e) => !e.remoteFile.isUnknown && !e.remoteFile.isFasta).toList();
    var tracks = trackFiles.map((e) {
      return {
        'name': e.trackName,
        'file': e.remoteFile.path,
        'type': e.remoteFile.serverTrackType,
      };
    }).toList();

    String? fasta = _fastaFiles.length > 0 ? _fastaFiles.first.remoteFile.path : null;
    Map<String, dynamic> params = {
      ...values,
      'fasta_file': fasta,
      'tracks': tracks,
    }..removeWhere((key, value) => value == null);
    widget.onSubmit?.call(params);
  }

  @override
  bool get wantKeepAlive => true;
}
