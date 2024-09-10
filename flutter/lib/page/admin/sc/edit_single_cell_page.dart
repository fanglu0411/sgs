import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/bean/field_item.dart';
import 'package:flutter_smart_genome/bean/site_item.dart';
import 'package:flutter_smart_genome/bean/datasets.dart';
import 'package:flutter_smart_genome/components/remote_file_manager_widget.dart';
import 'package:flutter_smart_genome/service/single_cell_service.dart';
import 'package:flutter_smart_genome/widget/basic/custom_bot_widget.dart';
import 'package:flutter_smart_genome/widget/basic/scroll_controller_builder.dart';
import 'package:flutter_smart_genome/widget/basic/simple_form.dart';
import 'package:flutter_smart_genome/widget/toggle_button_group.dart';
import 'package:flutter_smart_genome/widget/track/base/track_data.dart';
import 'package:get/get.dart';

class EditSingleCellPage extends StatefulWidget {
  final ValueChanged? onChanged;
  final SiteItem site;
  final Species species;
  final bool asPage;

  const EditSingleCellPage({
    Key? key,
    this.onChanged,
    required this.site,
    required this.species,
    this.asPage = true,
  }) : super(key: key);

  @override
  _EditSingleCellPageState createState() => _EditSingleCellPageState();
}

class _EditSingleCellPageState extends State<EditSingleCellPage> {
  CustomTrack? _track;

  List<FieldItem> _formItems = [];

  int gene_meta_index = 1;
  int plot_type_index = 1;

  bool _smartMode = true;

  List<RemoteFile> _files = [];

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
      FieldItem.name(
        name: 'sc_name',
        label: 'Name',
        hint: 'Input Single Cell Name',
        value: '',
        required: true,
      ),

      FieldItem.multiSourceFile(
        name: 'cell_meta_file',
        label: 'Cell-Meta File',
        hint: 'Tap to choose meta file',
        required: true,
        fileValueMapper: (item) => item?.response,
        fileSource: 1,
      ),

      FieldItem.grouped(
        name: 'matrix_group-0',
        label: 'Matrix',
        required: true,
        subFields: [
          FieldItem.name(
            name: 'name',
            label: 'Matrix Name',
            hint: 'Input Matrix Name',
            value: '',
            required: true,
          ),
          FieldItem.multiSourceFile(
            name: 'file',
            label: 'Exp-File',
            hint: 'Tap to choose expression file',
            required: true,
            fileValueMapper: (item) => item?.response,
            fileSource: 1,
          ),
          FieldItem.multiSourceFile(
            name: 'marker',
            label: 'Marker File',
            hint: 'Tap to choose marker file',
            required: true,
            fileValueMapper: (item) => item?.response,
            fileSource: 1,
          ),
        ],
      ),

      FieldItem.button(
        label: 'Add New Matrix',
        widget: OutlinedButton.icon(
          onPressed: _addNewMatrixField,
          icon: Icon(Icons.add),
          label: Text('Add New Matrix'),
        ),
      ),

      FieldItem.grouped(
        name: 'plot_group-0',
        label: 'Plot',
        required: true,
        subFields: [
          FieldItem.name(
            name: 'name',
            label: 'Plot type',
            hint: 'Input plot type. tsne/umap',
            value: '',
            required: true,
          ),
          FieldItem.multiSourceFile(
            name: 'file',
            label: 'Plot-File',
            hint: 'Tap to choose plot file',
            required: true,
            fileValueMapper: (item) => item?.response,
            fileSource: 1,
          ),
        ],
      ),

      FieldItem.button(
        label: 'Add New Plot',
        widget: OutlinedButton.icon(
          onPressed: _addPlotField,
          icon: Icon(Icons.add),
          label: Text('Add New Plot'),
        ),
      ),
    ];
  }

  void _addNewMatrixField([bool update = true]) {
    var field = FieldItem.grouped(
      name: 'matrix_group-${gene_meta_index}',
      label: 'Matrix',
      required: false,
      subFields: [
        FieldItem.name(
          name: 'name',
          label: 'Matrix Name',
          hint: 'Input Matrix Name',
          value: '',
          required: true,
        ),
        FieldItem.multiSourceFile(
          name: 'file',
          label: 'Exp-File',
          hint: 'Tap to choose expression file',
          required: true,
          fileValueMapper: (item) => item?.response,
          fileSource: 1,
        ),
        FieldItem.multiSourceFile(
          name: 'marker',
          label: 'Marker File',
          hint: 'Tap to choose marker file',
          required: true,
          fileValueMapper: (item) => item?.response,
          fileSource: 1,
        ),
      ],
    );
    int index = _formItems.indexWhere((f) => f.fieldType == FieldType.button);
    _formItems.insert(index, field);
    if (update) setState(() {});
  }

  void _addPlotField([bool update = true]) {
    var field = FieldItem.grouped(
      name: 'plot_group-${plot_type_index}',
      label: 'Plot',
      required: false,
      subFields: [
        FieldItem.name(
          name: 'name',
          label: 'Plot type',
          hint: 'Input plot type. tsne/umap',
          value: '',
          required: true,
        ),
        FieldItem.multiSourceFile(
          name: 'file',
          label: 'Plot-File',
          hint: 'Tap to choose plot file',
          required: true,
          fileValueMapper: (item) => item?.response,
          fileSource: 1,
        ),
      ],
    );
    _formItems.add(field);
    plot_type_index++;
    if (update) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _formItems = _buildFormItems();
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
            buttonExpand: widget.asPage,
            onFieldDelete: _onDeleteField,
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
          // Expanded(flex: 2, child: _fileListWidget()),
          VerticalDivider(width: 1),
          SizedBox(width: 20),
          Expanded(flex: 1, child: _remoteFileViewer()),
          SizedBox(width: 20),
        ],
      );
    }
    bool _dark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text('Add RNASeq Track',
            style: widget.asPage
                ? null
                : TextStyle(color: _dark ? Colors.white : Colors.black87)),
//        automaticallyImplyLeading: widget.asPage ? true : false,
        centerTitle: widget.asPage ? null : false,
        leading: widget.onChanged != null
            ? IconButton(
                icon: Icon(Icons.arrow_back_ios),
                onPressed: () => widget.onChanged?.call(null),
              )
            : null,
        actions: [
          if (!widget.asPage)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Tooltip(
                  child: Text('Smart Mode'),
                  message:
                      'This will automatic fill form from selected files !',
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
            subtitle: Text(
                'View file from your sgs server ❗️ Drag and drop file to the left form field!',
                style: TextStyle(color: Theme.of(context).colorScheme.primary)),
            contentPadding: EdgeInsets.symmetric(horizontal: 10),
            leading: Icon(Icons.warning_rounded, size: 40),
            trailing: ToggleButtonGroup(
              constraints: BoxConstraints.tightFor(height: 28),
              borderRadius: BorderRadius.circular(4),
              selectedIndex: _fileViewerMode,
              onChange: (v) {
                _fileViewerMode = v;
                setState(() {});
              },
              children: [
                Tooltip(
                  message: 'File View',
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Icon(Icons.folder, size: 18),
                  ),
                ),
                Tooltip(
                  message: 'Tree View',
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Icon(Icons.account_tree_rounded, size: 18),
                  ),
                ),
              ],
            ),
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

  Widget _fileListWidget() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
              decoration: BoxDecoration(
                color: Get.theme.primaryColor.withOpacity(.25),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                _files.length == 0
                    ? '1.Tap button below to select files'
                    : '2.Drag files below to left form',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w300),
              ),
            ),
            SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                    color: Get.theme.primaryColor.withOpacity(.25), width: 1),
                borderRadius: BorderRadius.circular(5),
                color: Get.theme.primaryColor.withOpacity(.2),
              ),
              // constraints: BoxConstraints(minHeight: 200),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: _files.map(_buildDraggableFileItem).toList(),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: ElevatedButton.icon(
                onPressed: _showRemoteFileDialog,
                icon: Icon(Icons.folder_open),
                label: Text('Select files...'),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildDraggableFileItem(RemoteFile file) {
    return Draggable<String>(
      data: file.path,
      child: Card(
        child: ListTile(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
          leading: Icon(Icons.more_vert),
          title: Text(file.name),
          subtitle: Text(file.path!),
          horizontalTitleGap: 2,
          contentPadding: EdgeInsets.zero,
          onTap: () {},
        ),
      ),
      feedback: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 255),
        child: Card(
          child: ListTile(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
            leading: Icon(Icons.more_vert),
            title: Text(file.name),
            horizontalTitleGap: 2,
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ),
    );
  }

  bool _validValue(String value) {
    return value.isNotEmpty;
  }

  void _handleSubmit(Map values) async {
    Map params = {...values, 'species_id': widget.species.id};
    // _track = CustomTrack.fromMap(params);

    var matrixKeys = values.keys.where((k) => k.contains('matrix_group'));

    /// matrix:[{name, file, marker},...]
    var matrixList = matrixKeys.map((e) => values[e]).toList();

    var plotKeys = values.keys.where((k) => k.contains('plot_group'));

    /// plots{ name -> file,}
    ///
    var plotEntryList = plotKeys
        .map((e) => values[e])
        .map((e) => MapEntry(e['name'], e['file']));
    var plotMap = Map.fromEntries(plotEntryList);

    Map data = {
      'species_id': widget.species.id,
      'sc_type': 'transcript',
      'sc_name': params['sc_name'],
      'cell_meta_file': params['cell_meta_file'],
      'feature_matrix': matrixList,
      'cell_plots': plotMap,
    };
    var cancel = BotToast.showLoading();
    var bean = await addSingleCell(host: widget.site.url, data: data);
    cancel.call();

    if (bean.success) {
      //_track.id = '${bean.body['track_id']}';
      if (widget.onChanged == null) {
        Navigator.of(context).pop();
      } else {
        widget.onChanged!.call(null);
      }
    } else {
      showErrorNotification(title: Text('${bean.error}'));
    }
  }

  _showRemoteFileDialog() async {
    var dialog = AlertDialog(
      title:
          Row(children: [Text('Remote File Viewer'), Spacer(), CloseButton()]),
      content: Container(
        constraints: BoxConstraints.tightFor(width: 800),
        child: RemoteFileManagerWidget(
          host: widget.site.url,
          multi: true,
          onSelected: (files) {
            Navigator.of(context).pop(files);
          },
        ),
      ),
    );
    var result = await showDialog(
        context: context, builder: (c) => dialog, barrierDismissible: false);
    if (null != result) {
      List<RemoteFile> files = result;
      _files = files;
      _formItems = _buildFormItems(); //reset form
      _smartFillFormField();
      setState(() {});
    }
  }

  void _smartFillFormField() {
    // _fillFormField('exp_file', ['exp']);
    _fillFormField('cell_meta_file', ['cell']);
    // _fileMultiFormField('matrix_group', ['marker', 'gene']);
    _fillMultiFormField('plot_group', ['coord', 'plot']);
  }

  List<FieldItem> _findField(String name) {
    return _formItems
        .where((f) => f.name != null && f.name!.contains(name))
        .toList();
  }

  void _fillFormField(String fieldName, List<String> keywords) {
    var field = _findField(fieldName).first;
    var reg = RegExp('.*${keywords.join('|')}.*');
    var files =
        _files.where((f) => reg.hasMatch(f.name.toLowerCase())).toList();
    if (files.length == 0) return;

    if (files.length > 0) {
      field.value = files.toList();
    }
  }

  ///一组只有一个文件适用
  void _fillMultiFormField(String fieldNameKey, List<String> keywords) {
    var fields = _findField(fieldNameKey);

    var reg = RegExp('.*${keywords.join('|')}.*');
    var files =
        _files.where((f) => reg.hasMatch(f.name.toLowerCase())).toList();
    if (files.length == 0) return;

    int delta = files.length - fields.length;
    while (delta > 0) {
      if (fieldNameKey == 'plot_group') {
        _addPlotField(false);
      } else {
        // no match type
      }
      delta--;
    }
    fields = _findField(fieldNameKey);

    for (int i = 0; i < files.length; i++) {
      var file = files[i];
      if (fieldNameKey == 'plot_group') {
        _fillPlotGroupField(fields[i], file);
      } else {
        //do nothing
      }
    }
  }

  void _fillMatrixGroupField() {
    //todo current there isn't a nice way fill group sub fields
  }

  _fillPlotGroupField(FieldItem plotField, RemoteFile file) {
    var plotFileField = plotField.subFields!
        .firstWhere((f) => f.name != null && f.name == 'file');
    plotFileField.value = [file];
    var plotTypeField = plotField.subFields!
        .firstWhere((f) => f.name != null && f.name == 'name');
    plotTypeField.value = _parsePlotTypeByFile(file.name);
  }

  String _parsePlotTypeByFile(String name) {
    var arr = name.split('.');
    arr
      ..removeLast()
      ..remove('coords')
      ..remove('plot');
    return arr.join('.');
  }
}
