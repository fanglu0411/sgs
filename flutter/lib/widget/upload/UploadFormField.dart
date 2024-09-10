import 'package:dartx/dartx.dart' as dx;
import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/widget/upload/platform_entry.dart';
import 'package:flutter_smart_genome/widget/upload/upload_type.dart';
import 'upload_widget.dart';

class UploadFormField extends FormField<List<UploadFileItem>> {
  final ValueChanged<List<UploadFileItem>?>? onChanged;

  static String? defaultFileValidator(List<UploadFileItem>? value) {
    var fileItem = (value != null && value.length > 0) ? value[0] : null;
    if (fileItem == null) return 'File is empty';

    if (fileItem.fileStatus == FileStatus.success) return null;
    if (fileItem.fileStatus == FileStatus.fail) return fileItem.response;

    return 'Wait for file uploading';
  }

  static String? defaultMultiFileValidator(List<UploadFileItem>? value) {
    if (null == value || value.length == 0) return 'File is empty';
    var failItem = value.firstOrNullWhere((e) {
      return e.fileStatus == FileStatus.fail;
    });
    return failItem?.response;
  }

  UploadFormField({
    Key? key,
    Widget? label,
    Widget? hint,
    required UploadType uploadType,
    int? maxFileSize,
    int? maxFileCount,
    this.onChanged,
    List<UploadFileItem>? value,
    bool expand = false,
    InputDecoration decoration = const InputDecoration(border: InputBorder.none, errorBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.red))),
//    decoration = const InputDecoration(border: OutlineInputBorder()),
    FormFieldSetter<List<UploadFileItem>>? onSaved,
    FormFieldValidator<List<UploadFileItem>>? validator,
    AutovalidateMode autovalidateMode = AutovalidateMode.onUserInteraction,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.start,
    String? host,
  }) : super(
            key: key,
            onSaved: onSaved,
            initialValue: value,
            validator: validator,
            autovalidateMode: autovalidateMode,
            builder: (FormFieldState<List<UploadFileItem>> fieldState) {
              final InputDecoration effectiveDecoration = (decoration ?? const InputDecoration()).applyDefaults(Theme.of(fieldState.context).inputDecorationTheme);

              void onChangedHandler(List<UploadFileItem>? value) {
                if (onChanged != null) {
                  onChanged(value);
                }
                fieldState.didChange(value);
              }

              var decHint = Text(effectiveDecoration.hintText ?? 'Tap to choose file', style: effectiveDecoration.hintStyle);
              var _hint = hint ?? (maxFileSize != null ? Text('File size less than ${maxFileSize}kb.') : null);

              var child;
              if (uploadType == UploadType.single) {
                child = SimpleFileUploadWidget(
                  maxFileSize: maxFileSize,
                  onChanged: onChangedHandler,
                  host: host,
                  hint: decHint,
                  value: value,
                );
              } else if (uploadType == UploadType.image) {
                child = ImageUploadWidget(
                  maxFileSize: maxFileSize,
                  onChanged: onChangedHandler,
                  host: host,
                );
              } else if (uploadType == UploadType.image_grid) {
                child = ImageGridUploadWidget(
                  maxFileCount: maxFileCount,
                  maxFileSize: maxFileSize,
                  onChanged: onChangedHandler,
                  host: host,
                );
              } else {
                child = MultiFileUploadWidget(
                  maxFileCount: maxFileCount,
                  maxFileSize: maxFileSize,
                  onChanged: onChangedHandler,
                  host: host,
                );
              }

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
                decoration: effectiveDecoration.copyWith(errorText: fieldState.errorText),
                child: child,
              );
            });

  @override
  FormFieldState<List<UploadFileItem>> createState() => _UploadFormFieldState();
}

class _UploadFormFieldState extends FormFieldState<List<UploadFileItem>> {
  // @override
  // UploadFormField get widget => super.widget;

  @override
  Widget build(BuildContext context) {
    return super.build(context);
  }
}