import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/components/ftp_file_manager_widget.dart';

class FtpFileFormField extends FormField<List<String>> {
  final ValueChanged<List<String>>? onChanged;

  static String? defaultFileValidator(List<String>? value) {
    if (value == null || value.isEmpty) return 'File is empty';
    return null;
  }

  static String? defaultMultiFileValidator(List<String>? value) {
    if (value == null || value.isEmpty) return 'File is empty';
    return null;
  }

  FtpFileFormField({
    Key? key,
    Widget? label,
    Widget? hint,
    bool multiple = false,
    int? maxFileSize,
    int? maxFileCount,
    this.onChanged,
    List<String>? value,
    bool expand = false,
    decoration = const InputDecoration(border: InputBorder.none),
//    decoration = const InputDecoration(border: OutlineInputBorder()),
    FormFieldSetter<List<String>>? onSaved,
    FormFieldValidator<List<String>>? validator,
    AutovalidateMode autovalidateMode = AutovalidateMode.onUserInteraction,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.start,
    String? host,
  }) : super(
            key: key,
            onSaved: onSaved,
            initialValue: value,
            validator: validator,
            autovalidateMode: autovalidateMode,
            builder: (FormFieldState<List<String>> field) {
              final InputDecoration effectiveDecoration = (decoration ?? const InputDecoration()).applyDefaults(Theme.of(field.context).inputDecorationTheme);

              void onChangedHandler(List<String> value) {
                if (onChanged != null) {
                  onChanged(value);
                }
                field.didChange(value);
              }

              var _hint = hint ?? (maxFileSize != null ? Text('File size less than ${maxFileSize}kb.', style: TextStyle(color: Colors.black38)) : null);

              Widget child = _FtpFileSelector(
                host: host,
                multiple: multiple,
                onChanged: onChangedHandler,
              );

              if (label != null || _hint != null) {
                child = Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: crossAxisAlignment,
                  children: <Widget>[
                    if (label != null) ...[label, SizedBox(width: 10)],
                    if (expand) Expanded(child: child) else child,
                    if (_hint != null) ...[SizedBox(width: 10), _hint]
                  ],
                );
              }
              return InputDecorator(
                decoration: effectiveDecoration.copyWith(
                  errorText: field.errorText,
                ),
                child: child,
              );
            });

  @override
  FormFieldState<List<String>> createState() => _UploadFormFieldState();
}

class _UploadFormFieldState extends FormFieldState<List<String>> {
  // @override
  // FtpFileFormField get widget => super.widget;

  @override
  Widget build(BuildContext context) {
    return super.build(context);
  }
}

class _FtpFileSelector extends StatefulWidget {
  final bool multiple;
  final String? host;
  final ValueChanged<List<String>>? onChanged;

  _FtpFileSelector({
    Key? key,
    this.multiple = false,
    this.host,
    this.onChanged,
  }) : super(key: key);

  @override
  __FtpFileSelectorState createState() => __FtpFileSelectorState();
}

class __FtpFileSelectorState extends State<_FtpFileSelector> {
  String? _file;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Theme.of(context).colorScheme.primary,
      onTap: _showFtpFileDialog,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.insert_drive_file, size: 24.0),
            SizedBox(width: 8),
            Expanded(child: Text(_file ?? 'Tap to choose file from ftp server')),
            if (_file != null)
              IconButton(
                constraints: BoxConstraints.tightFor(width: 20, height: 20),
                padding: EdgeInsets.zero,
                iconSize: 20,
                icon: Icon(Icons.close),
                onPressed: () {
                  _file = null;
                  setState(() {});
                },
              )
          ],
        ),
      ),
    );
  }

  _showFtpFileDialog() async {
    var dialog = AlertDialog(
      title: Text('FTP File Viewer'),
      content: Container(
        constraints: BoxConstraints.tightFor(width: 800),
        child: FtpFileManagerWidget(
          host: widget.host,
          onSelected: (files) {
            Navigator.of(context).pop(files);
          },
        ),
      ),
    );
    var result = await showDialog(context: context, builder: (c) => dialog);
    if (null != result) {
      widget.onChanged?.call(result);
      List<String> files = result;
      _file = files.first;
      setState(() {});
    }
  }
}
