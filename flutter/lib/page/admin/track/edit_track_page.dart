import 'package:bot_toast/bot_toast.dart';
import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/bean/account_bean.dart';
import 'package:flutter_smart_genome/components/window/multi_window_controller.dart';
import 'package:flutter_smart_genome/page/admin/base/base_widgets.dart';
import 'package:flutter_smart_genome/page/admin/track/batch_track_file_list.dart';
import 'package:flutter_smart_genome/page/admin/track/track_file.dart';
import 'package:flutter_smart_genome/widget/basic/alert_widget.dart';
import 'package:flutter_smart_genome/widget/basic/custom_bot_widget.dart';
import 'package:path/path.dart' as path;
import 'package:flutter_smart_genome/bean/field_item.dart';
import 'package:flutter_smart_genome/bean/site_item.dart';
import 'package:flutter_smart_genome/bean/datasets.dart';
import 'package:flutter_smart_genome/components/remote_file_manager_widget.dart';
import 'package:flutter_smart_genome/service/abs_platform_service.dart';
import 'package:flutter_smart_genome/widget/basic/simple_form.dart';
import 'package:flutter_smart_genome/widget/track/base/track_data.dart';

class EditTrackPage extends StatefulWidget {
  final ValueChanged? onChanged;
  final SiteItem site;
  final Species? species;
  final AccountBean account;

  const EditTrackPage({
    Key? key,
    this.onChanged,
    required this.site,
    this.species,
    required this.account,
  }) : super(key: key);

  @override
  _EditTrackPageState createState() => _EditTrackPageState();
}

class _EditTrackPageState extends State<EditTrackPage> {
  CustomTrack? _track;

  late List<FieldItem> _formFields;

  List<TrackFile>? _files;

  List<FieldItem> _buildFormItems() {
    return [
      // FieldItem.select(
      //   name: 'type',
      //   label: 'Track Type',
      //   hint: 'Track Type',
      //   value: 'gff_track',
      //   required: true,
      //   options: [FieldOption('gff3', 'gff_track'), FieldOption('bed', 'bed'), FieldOption('wig', 'wig'), FieldOption('g3d', 'g3d')],
      // ),
      // if (!kIsWeb)
      FieldItem.remoteFile(
        name: 'file_id',
        label: 'Track File',
        hint: 'select track file/s from server',
        required: true,
        multiFile: true,
        // fileSource: 1,
        fileValueMapper: (item) => item?.response,
        onChanged: _onFileChanged,
        helperText:
            'You can select more than one genome track file or sc (h5ad) file to batch upload.',
      ),
      FieldItem.builder(widgetBuilder: _fileListTips),
      FieldItem.builder(widgetBuilder: _fileListBuilder),
    ];
  }

  @override
  void initState() {
    super.initState();
    _formFields = _buildFormItems();
  }

  Widget _fileListTips(BuildContext context) {
    if (_files == null || _files!.every((f) => !f.remoteFile.isUnknown))
      return SizedBox();
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AlertWidget.warning(
          message: Text(
              '`unknown` means the exactly track type is not recognized, you can assign a type manually, otherwise it will be ignored.'),
        ),
      ],
    );
  }

  Widget _fileListBuilder(BuildContext context) {
    return BatchTrackPreviewWidget(
      files: _files,
      onFileDelete: (f) {
        _files?.remove(f);
        setState(() {});
      },
      onClear: () {
        _files?.clear();
        setState(() {});
      },
    );
  }

  _onFileChanged(v, FieldItem field) {
    if (v is RemoteFile) {
      String name = path.basenameWithoutExtension(v.path!);
      FieldItem? nameField =
          _formFields.firstOrNullWhere((e) => e.name == "track_name");
      nameField!.value = name;
      setState(() {});
    } else if (v is List<RemoteFile>) {
      if (_files == null) _files = [];
      var __files = v.map((e) => TrackFile.from(e));
      _files!.insertAll(0, __files);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    double padding = 10;
    var body = SingleChildScrollView(
      child: Container(
        alignment: Alignment.topCenter,
        padding: EdgeInsets.symmetric(horizontal: padding, vertical: padding),
        child: SimpleForm(
          host: widget.site.url,
          fields: _formFields,
          filled: true,
          buttonExpand: true,
          inputBorder: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(10)),
          // inputBorder: inputBorder(),
          onSubmit: _onSubmit,
          onReset: _onReset,
        ),
      ),
    );
    Color pri = Theme.of(context).colorScheme.primary;
    return Scaffold(
      // backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text('Add Data'),
        // backgroundColor: Colors.white,
        // systemOverlayStyle: SystemUiOverlayStyle.dark,
        foregroundColor: pri,
        elevation: 0,
        centerTitle: false,
        // shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8))),
        leading: widget.onChanged != null
            ? IconButton(
                icon: Icon(Icons.arrow_back_ios),
                onPressed: () => widget.onChanged?.call(null),
              )
            : null,
      ),
      body: body,
    );
  }

  void _onReset() {
    _files = null;
    setState(() {});
  }

  void _onSubmit(Map values) async {
    if (_files == null || _files!.isEmpty) {
      showToast(text: 'please select file first!', backgroundColor: Colors.red);
      return;
    }

    List<TrackFile> unknownFiles =
        _files!.where((e) => e.remoteFile.isUnknown).toList();
    if (unknownFiles.isEmpty) {
      _submit(values);
      return;
    }

    /// unknownFiles is not empty
    var result = await showDialog(
        context: context,
        builder: (c) => UnknownFilesDialog(context, unknownFiles));
    if (result != null && result) {
      _submit(values);
    }
  }

  _submit(Map values) {
    List<TrackFile> files =
        _files!.where((e) => !e.remoteFile.isUnknown).toList();
    if (files.length == 0) {
      showToast(text: 'No correct track files.', backgroundColor: Colors.red);
      return;
    }
    // if (files.length == 1) {
    //   _submitSingle(files.first);
    // } else {
    _submitBatch(files);
    // }
  }

  void _submitSingle(TrackFile file) async {
    // Map params = {...values, 'species_id': widget.species?.id};
    Map params = {
      "file_id": file.remoteFile.path,
      "track_name": file.trackName,
      'species_id': widget.species?.id,
      "type": file.remoteFile.serverTrackType,
    };
    _track = CustomTrack.fromMap(params);

    var cancel = BotToast.showLoading(clickClose: false);
    var bean = await AbsPlatformService.get(widget.site)!
        .addTrack(host: widget.site.url, params: params);
    cancel();

    if (bean.success) {
      //_track.id = '${bean.body['track_id']}';
      if (widget.onChanged == null) {
        Navigator.of(context).pop();
      } else {
        widget.onChanged!.call(null);
      }
    } else {
      showErrorNotification(
          title: Text('Add track error!'), subtitle: Text('${bean.error}'));
    }
  }

  void _submitBatch(List<TrackFile> files) async {
    List<TrackFile> _files = files.where((f) => !f.remoteFile.isFasta).toList();
    List<Map> tracks = _files.map((f) {
      return {
        "name": f.trackName,
        "file": f.remoteFile.path,
        "type": f.remoteFile.serverTrackType,
      };
    }).toList();

    Map params = {
      'species_id': widget.species?.id,
      "tracks": tracks,
    };

    var cancel = BotToast.showLoading(clickClose: false);
    var bean = await AbsPlatformService.get(widget.site)!
        .addTracks(host: widget.site.url, params: params);
    cancel();

    if (bean.success) {
      List ids = bean.body['track_id_list'] ?? [];
      showToast(text: 'Add data success, count: ${ids.length}');
      if (widget.onChanged == null) {
        Navigator.of(context).pop(true);
      } else {
        widget.onChanged!.call(null);
      }
      multiWindowController.notifyMainWindow(WindowCallEvent.addData.name,
          {"tracks": ids, "speciesId": widget.species?.id});
    } else {
      showErrorNotification(
          title: Text('Batch add tracks error!'),
          subtitle: Text('${bean.error}'));
    }
  }
}
