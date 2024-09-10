import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/base/container_config.dart';
import 'package:flutter_smart_genome/components/remote_file_manager_widget.dart';

class RemoteFileFormField extends FormField<List<RemoteFile>> {
  final ValueChanged<List<RemoteFile>>? onChanged;

  static String? defaultFileValidator(List<RemoteFile>? value) {
    if (value == null || value.isEmpty) return 'File is empty';
    return null;
  }

  static String? defaultMultiFileValidator(List<RemoteFile>? value) {
    if (value == null || value.isEmpty) return 'File is empty';
    return null;
  }

  RemoteFileFormField({
    Key? key,
    Widget? label,
    Widget? hint,
    bool multiple = false,
    int? maxFileSize,
    int? maxFileCount,
    this.onChanged,
    List<RemoteFile>? initialValue,
    bool enableDirectorySelect = false,
    bool expand = false,
    InputDecoration decoration = const InputDecoration(border: InputBorder.none),
    FormFieldSetter<List<RemoteFile>>? onSaved,
    FormFieldValidator<List<RemoteFile>>? validator,
    AutovalidateMode autovalidateMode = AutovalidateMode.onUserInteraction,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.start,
    String? host,
  }) : super(
            key: key,
            onSaved: onSaved,
            initialValue: initialValue,
            validator: validator,
            autovalidateMode: autovalidateMode,
            builder: (FormFieldState<List<RemoteFile>> fieldState) {
              final InputDecoration effectiveDecoration = (decoration).applyDefaults(Theme.of(fieldState.context).inputDecorationTheme);

              void onChangedHandler(List<RemoteFile> value) {
                if (onChanged != null) {
                  onChanged(value);
                }
                fieldState.didChange(value);
              }

              return DragTarget<String>(
                onAccept: (data) {
                  List<RemoteFile> _files = [RemoteFile.path(data)];
                  onChangedHandler(_files);
                },
                onWillAccept: (data) {
                  return true;
                },
                builder: (context, List<String?> candidateData, rejectedData) {
                  // List<RemoteFile> _files = candidateData.map((e) => RemoteFile.path(e)).toList();
                  var decHint = Text(effectiveDecoration.hintText ?? 'Tap to choose file from server', style: effectiveDecoration.hintStyle);
                  var _hint = hint ?? (maxFileSize != null ? Text('File size less than ${maxFileSize}kb.', style: TextStyle(color: Colors.black38)) : null);

                  Widget child = _RemoteFileSelector(
                    host: host,
                    multiple: multiple,
                    enableDirectorySelect: enableDirectorySelect,
                    onChanged: onChangedHandler,
                    files: fieldState.value,
                    hint: decHint,
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
                  var fillColor = candidateData.length > 0 ? effectiveDecoration.focusColor : effectiveDecoration.fillColor;
                  return InputDecorator(
                    decoration: effectiveDecoration.copyWith(
                      errorText: fieldState.errorText,
                      fillColor: fillColor,
                    ),
                    child: child,
                  );
                },
              );
            });

  @override
  FormFieldState<List<RemoteFile>> createState() => _UploadFormFieldState();
}

class _UploadFormFieldState extends FormFieldState<List<RemoteFile>> {
  // @override
  // RemoteFileFormField get widget => super.widget;

  @override
  void didUpdateWidget(covariant FormField<List<RemoteFile>> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue) {
      setValue(widget.initialValue);
    }
  }

  @override
  Widget build(BuildContext context) {
    return super.build(context);
  }

  @override
  void reset() {
    super.reset();
  }
}

class _RemoteFileSelector extends StatefulWidget {
  final bool multiple;
  final String? host;
  final bool enableDirectorySelect;
  final ValueChanged<List<RemoteFile>>? onChanged;
  final Widget hint;
  final List<RemoteFile>? files;

  _RemoteFileSelector({
    Key? key,
    this.multiple = false,
    this.host,
    this.onChanged,
    this.hint = const Text('Tap to choose file from server'),
    this.enableDirectorySelect = false,
    this.files,
  }) : super(key: key);

  @override
  ___RemoteFileSelectorState createState() => ___RemoteFileSelectorState();
}

class ___RemoteFileSelectorState extends State<_RemoteFileSelector> {
  late List<RemoteFile> _files;

  @override
  void initState() {
    super.initState();
    _files = widget.files ?? [];
  }

  @override
  void didUpdateWidget(covariant _RemoteFileSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(widget.files, _files)) {
      _files = widget.files ?? [];
    }
  }

  @override
  Widget build(BuildContext context) {
    int _fileCount = _files.length;
    return InkWell(
      // splashColor: Theme.of(context).colorScheme.primary,
      onTap: _showRemoteFileDialog,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.electrical_services, size: 20),
            SizedBox(width: 8),
            Expanded(
                child: _fileCount == 1
                    ? Text(
                        _files.first.path!,
                        style: TextStyle(
                          // color: Theme.of(context).colorScheme.primary,
                          fontSize: 16,
                          fontWeight: FontWeight.w300,
                          fontFamily: MONOSPACED_FONT,
                          fontFamilyFallback: MONOSPACED_FONT_BACK,
                        ),
                      )
                    : widget.hint),
            if (_fileCount == 1)
              IconButton(
                constraints: BoxConstraints.tightFor(width: 20, height: 20),
                splashRadius: 15,
                padding: EdgeInsets.zero,
                iconSize: 20,
                icon: Icon(Icons.close),
                onPressed: () {
                  _files.clear();
                  setState(() {});
                },
              ),
            SizedBox(width: 10),
          ],
        ),
      ),
    );
  }

  _showRemoteFileDialog() async {
    var result = await showDialog(
        context: context,
        barrierDismissible: false,
        // barrierColor: Theme.of(context).colorScheme.tertiary,
        builder: (c) {
          return AlertDialog(
            backgroundColor: Theme.of(context).colorScheme.background,
            contentPadding: EdgeInsets.zero,
            clipBehavior: Clip.antiAlias,
            content: Container(
              constraints: BoxConstraints.tightFor(width: 800),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: RemoteFileManagerWidget(
                host: widget.host,
                multi: widget.multiple,
                enableDirectorySelect: widget.enableDirectorySelect,
                onSelected: (files) {
                  Navigator.of(c).pop(files);
                },
              ),
            ),
          );
        });
    if (null != result) {
      widget.onChanged?.call(result);
      List<RemoteFile> files = result;
      _files = files;
      setState(() {});
    }
  }
}
