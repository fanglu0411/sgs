import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/widget/upload/platform_entry.dart';

typedef String FieldValidator(dynamic value);
typedef bool OnFileSelect(dynamic value);
typedef dynamic FileValueMapper(UploadFileItem? item);

enum FieldType {
  text,
  image,
  image_list,
  file,
  select,
  checkbox,
  switcher,
  divider,
  ftp_file,
  remote_file,
  multi_file_source,
  button,
  grouped,
}

class FieldOption {
  String label;
  dynamic value;

  FieldOption(this.label, this.value);
}

class FieldItem<T> {
  final bool required;
  final String? name;
  final String? label;
  RegExp? validateRegExp;
  final String? hint;
  T? value;
  String? helperText;
  late bool enableDirectorySelect = false;
  int? minLines;
  int? maxLines;
  final FieldType fieldType;
  int? maxSize;
  List<FieldOption>? options;

  final FieldValidator? fieldValidator;
  Widget? widget;

  /// file select interceptor false will not upload,
  OnFileSelect? onFileSelect;
  FileValueMapper? fileValueMapper;
  int fileSource = 0;
  List<FieldItem>? subFields;
  Function2<T, FieldItem, void>? onChanged;
  bool multiFile = false;

  WidgetBuilder? widgetBuilder;

  FieldItem({
    this.required = false,
    this.name,
    this.label,
    String? regExp,
    this.hint,
    this.value,
    this.fieldValidator,
    this.minLines = 1,
    this.maxLines = 1,
    this.fieldType = FieldType.text,
    this.onChanged,
  }) {
    this.validateRegExp = regExp?.isNotEmpty ?? false ? RegExp(regExp!) : null;
  }

  FieldItem.button({
    this.label,
    this.widget,
  })  : this.name = null,
        this.hint = null,
        this.value = null,
        this.fieldType = FieldType.button,
        this.fieldValidator = null,
        this.required = false,
        this.maxSize = null;

  FieldItem.name({
    this.name,
    this.label,
    this.required = false,
    this.hint,
    this.value,
    this.fieldValidator,
    this.minLines = 1,
    this.maxLines = 1,
    this.fieldType = FieldType.text,
    this.onChanged,
  });

  FieldItem.server({
    this.name,
    this.label,
    this.required = false,
    this.hint,
    this.value,
    this.fieldValidator,
    this.minLines = 1,
    this.maxLines = 1,
    this.fieldType = FieldType.ftp_file,
    this.onChanged,
  });

  FieldItem.file({
    this.name,
    this.label,
    this.required = false,
    this.hint,
    this.value,
    this.fieldValidator,
    this.minLines = 1,
    this.maxLines = 1,
    this.fieldType = FieldType.file,
    this.onChanged,
    this.onFileSelect,
  });

  FieldItem.remoteFile({
    this.name,
    this.label,
    this.required = false,
    this.hint,
    this.value,
    this.fieldValidator,
    this.minLines = 1,
    this.maxLines = 1,
    this.fieldType = FieldType.remote_file,
    this.fileValueMapper,
    this.helperText,
    this.enableDirectorySelect = false,
    this.multiFile = false,
    this.onChanged,
  });

  FieldItem.multiSourceFile({
    this.name,
    this.label,
    this.required = false,
    this.hint,
    this.value,
    this.fieldValidator,
    this.minLines = 1,
    this.maxLines = 1,
    this.fieldType = FieldType.multi_file_source,
    this.fileValueMapper,
    this.helperText,
    this.enableDirectorySelect = false,
    this.fileSource = 0,
    this.onChanged,
  });

  FieldItem.upload({
    this.name,
    this.label,
    this.required = false,
    this.hint,
    this.value,
    this.fieldValidator,
    this.fieldType = FieldType.image,
    this.maxSize,
    this.onFileSelect,
    this.fileValueMapper,
    this.onChanged,
  });

  FieldItem.widget({this.widget, this.label})
      : this.name = null,
        this.hint = null,
        this.value = null,
        this.fieldType = FieldType.divider,
        this.fieldValidator = null,
        this.required = false,
        this.maxSize = null;

  FieldItem.builder({
    this.widgetBuilder,
  })  : this.name = null,
        this.label = "custom-item-builder",
        this.hint = null,
        this.value = null,
        this.fieldType = FieldType.divider,
        this.fieldValidator = null,
        this.required = false,
        this.maxSize = null;

  FieldItem.select({
    this.name,
    this.value,
    this.label,
    this.hint,
    this.required = false,
    this.options,
    this.fieldValidator,
  }) : this.fieldType = FieldType.select;

  FieldItem.grouped({
    this.name = "group",
    this.label,
    this.required = false,
    this.subFields,
    this.onChanged,
  })  : this.fieldType = FieldType.grouped,
        this.hint = "",
        this.fieldValidator = null;
}
