import 'package:bot_toast/bot_toast.dart';
import 'package:dartx/dartx.dart' as dx;
import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/page/admin/track/track_file.dart';
import 'package:flutter_smart_genome/widget/basic/custom_bot_widget.dart';
import 'package:path/path.dart' as path;
import 'package:flutter_smart_genome/bean/field_item.dart';
import 'package:flutter_smart_genome/bean/site_item.dart';
import 'package:flutter_smart_genome/bean/datasets.dart';
import 'package:flutter_smart_genome/components/remote_file_manager_widget.dart';
import 'package:flutter_smart_genome/service/single_cell_service.dart';
import 'package:flutter_smart_genome/widget/basic/scroll_controller_builder.dart';
import 'package:flutter_smart_genome/widget/basic/simple_form.dart';
import 'package:flutter_smart_genome/widget/track/base/track_data.dart';

class EditSCPage extends StatefulWidget {
  final ValueChanged? onChanged;
  final SiteItem site;
  final Species species;
  final bool asPage;

  const EditSCPage({
    Key? key,
    this.onChanged,
    required this.site,
    required this.species,
    this.asPage = true,
  }) : super(key: key);

  @override
  _EditSingleCellPageState createState() => _EditSingleCellPageState();
}

class _EditSingleCellPageState extends State<EditSCPage> {
  CustomTrack? _track;

  List<FieldItem> _formItems = [];

  bool _smartMode = false;

  List<TrackFile> _files = [];

  int spatialImageIndex = 1;

  List<FieldItem> _buildFormItems() {
    return [
      FieldItem.name(
        name: 'sc_name',
        label: 'Name',
        hint: 'Input sc name',
        value: '',
        required: true,
      ),
      FieldItem.multiSourceFile(
        name: 'sc_file',
        label: 'SC File',
        hint: 'Tap to choose sc file (.h5ad)',
        required: true,
        fileValueMapper: (item) => item?.response,
        fileSource: 1,
        onChanged: _onFileChanged,
      ),
      FieldItem.button(
        label: 'Add Image',
        widget: OutlinedButton.icon(
          onPressed: _addImageField,
          icon: Icon(Icons.add),
          label: Text('Add Image'),
        ),
      ),
    ];
  }

  _addImageField({update = true}) {
    var imageGroupField = FieldItem.grouped(
      name: 'spatial-slice-${spatialImageIndex++}',
      label: 'Spatial Image',
      required: false,
      subFields: [
        FieldItem.name(
          name: 'slice_key',
          label: 'Slice Key',
          hint: 'Input slice key',
          required: true,
        ),
        FieldItem.multiSourceFile(
          name: 'image_file',
          label: 'Image File',
          hint: 'Tap to choose image file (.png/.jpg)',
          required: true,
          fileValueMapper: (item) => item?.response,
          fileSource: 1,
        ),
      ],
    );
    int index = _formItems.indexWhere((f) => f.fieldType == FieldType.button);
    _formItems.insert(index, imageGroupField);
    if (update) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _formItems = _buildFormItems();
  }

  _onFileChanged(v, FieldItem field) {
    if (v is RemoteFile) {
      String name = path.basenameWithoutExtension(v.path!);
      FieldItem? nameField = _formItems.firstOrNullWhere((e) => e.name == "sc_name");
      nameField!.value = name;
      setState(() {});
    } else if (v is List<RemoteFile>) {
      var __files = v.map((e) => TrackFile.from(e));
      _files.insertAll(0, __files);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    double padding = widget.asPage ? 10 : 20;
    Widget body = ScrollControllerBuilder(
      builder: (c, controller) => SingleChildScrollView(
        controller: controller,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: padding, vertical: padding),
          child: SimpleForm(
            host: widget.site.url,
            fields: _formItems,
            filled: true,
            buttonExpand: false,
            onFieldDelete: _onDeleteField,
            inputBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(5), borderSide: BorderSide.none),
            onSubmit: (values) {
              _handleSubmit(values);
            },
          ),
        ),
      ),
    );

    if (_smartMode) {
      body = Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 1, child: body),
          VerticalDivider(width: 1),
          SizedBox(width: 20),
          Expanded(flex: 1, child: _remoteFileViewer()),
          SizedBox(width: 20),
        ],
      );
    }
    bool _dark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      // backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text('Add sc', style: widget.asPage ? null : TextStyle(color: _dark ? Colors.white : Colors.black87)),
        centerTitle: false,
        // shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8))),
        actions: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Tooltip(
                child: Text('Smart Mode'),
                message: 'This will automatic fill form from selected files !',
              ),
              Switch(value: _smartMode, onChanged: _toggleSmartMode),
            ],
          )
        ],
      ),
      body: body,
    );
  }

  int _fileViewerMode = 1;

  Widget _remoteFileViewer() {
    return Column(
      children: [
        SizedBox(height: 20),
        Card(
          margin: EdgeInsets.zero,
          child: ListTile(
            title: Text("Remote File Viewer"),
            subtitle: Text('View file from your sgs server ❗️ Drag and drop file to the left form field!', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
            contentPadding: EdgeInsets.symmetric(horizontal: 10),
            leading: Icon(Icons.warning_rounded, size: 40),
            // trailing: ToggleButtonGroup(
            //   constraints: BoxConstraints.tightFor(height: 28),
            //   borderRadius: BorderRadius.circular(4),
            //   selectedIndex: _fileViewerMode,
            //   onChange: (v) {
            //     _fileViewerMode = v;
            //     setState(() {});
            //   },
            //   children: [
            //     Tooltip(
            //       message: 'File View',
            //       child: Padding(
            //         padding: const EdgeInsets.symmetric(horizontal: 6),
            //         child: Icon(Icons.folder, size: 18),
            //       ),
            //     ),
            //     Tooltip(
            //       message: 'Tree View',
            //       child: Padding(
            //         padding: const EdgeInsets.symmetric(horizontal: 6),
            //         child: Icon(Icons.account_tree_rounded, size: 18),
            //       ),
            //     ),
            //   ],
            // ),
          ),
        ),
        SizedBox(height: 12),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).dividerColor),
              borderRadius: BorderRadius.circular(6),
            ),
            padding: EdgeInsets.all(10),
            child: RemoteFileManagerWidget(
              host: widget.site.url,
              multi: false,
              treeMode: _fileViewerMode == 1,
              draggable: true,
            ),
          ),
        ),
        SizedBox(height: 10),
      ],
    );
  }

  _toggleSmartMode(bool v) {
    _smartMode = v;
    setState(() {});
  }

  void _onDeleteField(FieldItem fieldItem) {
    // _formItems.remove(fieldItem);
    // setState(() {});
  }

  bool _validValue(String value) {
    return value.isNotEmpty;
  }

  void _handleSubmit(Map values) async {
    var imageKeys = values.keys.where((k) => k.contains('spatial-slice'));
    List slice = imageKeys.map((k) => values[k]).toList();

    Map params = {
      'species_id': widget.species.id,
      'sc_name': values['sc_name'],
      'sc_file': values['sc_file'],
      'slice': slice,
    };

    var cancel = BotToast.showLoading();
    var bean = await addSingleCell(host: widget.site.url, data: params);
    cancel.call();

    if (bean.success) {
      //_track.id = '${bean.body['track_id']}';
      if (widget.onChanged == null) {
        Navigator.of(context).pop(true);
      } else {
        widget.onChanged!.call(null);
      }
    } else {
      showErrorNotification(title: Text('${bean.error}'));
    }
  }
}
