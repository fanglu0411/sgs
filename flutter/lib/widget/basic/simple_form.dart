import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/bean/field_item.dart';
import 'package:flutter_smart_genome/components/ftp_file_form_field.dart';
import 'package:flutter_smart_genome/components/remote_file_form_field.dart';
import 'package:flutter_smart_genome/components/remote_file_manager_widget.dart';
import 'package:flutter_smart_genome/widget/upload/UploadFormField.dart';
import 'package:flutter_smart_genome/widget/upload/platform_entry.dart';
import 'package:flutter_smart_genome/widget/upload/upload_type.dart';

import '../toggle_button_group.dart';

class SimpleForm extends StatefulWidget {
  final List<FieldItem> fields;
  final ValueChanged<Map<String, dynamic>>? onSubmit;
  final VoidCallback? onReset;
  final String? submitLabel;
  final String? resetLabel;
  final bool reset;
  final MainAxisAlignment buttonAlignment;
  final bool buttonExpand;
  final Widget? divider;
  final EdgeInsetsGeometry buttonPadding;
  final EdgeInsetsGeometry buttonGroupPadding;
  final bool? filled;
  final InputBorder inputBorder;
  final TextStyle? textStyle;
  final TextStyle? labelStyle;
  final OutlinedBorder? buttonShape;
  final String? host;
  final ValueChanged<FieldItem>? onFieldDelete;

  const SimpleForm({
    Key? key,
    required this.fields,
    this.onSubmit,
    this.submitLabel = 'SUBMIT',
    this.reset = true,
    this.resetLabel = 'RESET',
    this.buttonAlignment = MainAxisAlignment.start,
    this.buttonExpand = false,
    this.buttonPadding = const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
    this.buttonGroupPadding = const EdgeInsets.symmetric(vertical: 16),
    this.divider,
    this.filled = false,
    this.inputBorder = InputBorder.none,
    this.textStyle,
    this.labelStyle,
    this.buttonShape,
    this.host,
    this.onFieldDelete,
    this.onReset,
  }) : super(key: key);

  @override
  _SimpleFormState createState() => _SimpleFormState();
}

class _SimpleFormState extends State<SimpleForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  UploadFileItem? _defFileValueMapper(UploadFileItem? item) => item;

  bool _formWasEdited = false;
  bool _autovalidate = false;

  Map<String, dynamic> formValues = {};

  Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
  }

  TextEditingController _getController(FieldItem field, [FieldItem? parentField]) {
    var key = '${parentField?.name ?? 'root'}-${field.name}}';
    if (!_controllers.containsKey(key)) {
      _controllers[key] = TextEditingController(text: field.value);
    }
    if (field.value != null && _controllers[key]!.text != field.value) {
      _controllers[key]!.text = field.value ?? '';
    }
    return _controllers[key]!;
  }

  @override
  void didUpdateWidget(covariant SimpleForm oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return _buildFields();
  }

  _validateField(FieldItem fieldItem, value) {
    _formWasEdited = true;
    if (fieldItem.required) {
      if (fieldItem.fieldValidator != null) {
        return fieldItem.fieldValidator!(value);
      }
      if (value.isEmpty) return '${fieldItem.label} is required.';
      if (fieldItem.validateRegExp != null && !fieldItem.validateRegExp!.hasMatch(value)) {
        return '${fieldItem.label} is not valid.';
      }
    }
    return null;
  }

  void _handleSubmit() {
    final FormState form = _formKey.currentState!;
    if (!form.validate()) {
      _autovalidate = true; // Start validating on every change.
//      showSnackBarWithMsg('Please fix the errors in red before submitting.');
    } else {
      form.save();
      if (widget.onSubmit != null) widget.onSubmit!(formValues);
//      showSnackBarWithMsg('Project saved.');
    }
  }

  void _resetForm() {
    final FormState form = _formKey.currentState!;
    form.reset();
    _controllers.values.forEach((c) {
      c.text = '';
    });
    widget.onReset?.call();
  }

  Widget _buildTextFieldItem(FieldItem fieldItem, [FieldItem? parentField]) {
    var controller = _getController(fieldItem, parentField);
    var item = TextFormField(
      textCapitalization: TextCapitalization.words,
      style: widget.textStyle,
      decoration: InputDecoration(
        border: widget.inputBorder,
        filled: widget.filled,
        hintText: fieldItem.hint,
        labelStyle: widget.labelStyle,
        labelText: '${fieldItem.label} ${fieldItem.required ? '*' : ''}',
        suffix: IconButton(
          splashRadius: 15,
          constraints: BoxConstraints.tightFor(width: 24, height: 24),
          padding: EdgeInsets.zero,
          iconSize: 16,
          onPressed: () => controller.clear(),
          icon: Icon(Icons.clear),
        ),
      ),
      onSaved: (String? value) {
        if (parentField != null) {
          formValues[parentField.name!] ??= {};
          formValues[parentField.name][fieldItem.name] = value;
        } else {
          formValues[fieldItem.name!] = value;
        }
      },
      controller: controller,
      // initialValue: fieldItem.value,
      validator: (value) {
        return _validateField(fieldItem, value);
      },
      minLines: fieldItem.minLines,
      maxLines: fieldItem.maxLines,
    );
    return item;
  }

  Widget _buildFields() {
    List<Widget> formFields = [];
    for (var fieldItem in widget.fields) {
      Widget? fieldFormItem = _buildFormItem(fieldItem);
      if (fieldFormItem != null) formFields.add(fieldFormItem);
      formFields.add(SizedBox(height: 24.0));
    }

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          ...formFields,
//            SizedBox(height: 24.0),
          if (widget.divider != null) widget.divider!,
          Padding(padding: widget.buttonGroupPadding, child: _buttonGroup()),
          Text(
            '* indicates required field',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget? _buildFormItem(FieldItem fieldItem, [FieldItem? parentField]) {
    Widget? fieldFormItem;
    switch (fieldItem.fieldType) {
      case FieldType.divider:
        fieldFormItem = fieldItem.widgetBuilder?.call(context) ?? fieldItem.widget ?? Container(child: Text('${fieldItem.label}'));
        break;
      case FieldType.button:
        fieldFormItem = fieldItem.widget ??
            ElevatedButton(
              child: Text('${fieldItem.label}'),
              onPressed: () {},
            );
        break;
      case FieldType.switcher:
        fieldFormItem = FormField<bool>(
          initialValue: fieldItem.value,
          builder: (FormFieldState<bool> state) {
            return SwitchListTile.adaptive(
              value: state.value ?? fieldItem.value,
              title: Text(fieldItem.label!),
              subtitle: fieldItem.hint == null ? null : Text(fieldItem.hint!),
              contentPadding: EdgeInsets.symmetric(horizontal: 0),
              onChanged: (v) {
                state.didChange(v);
              },
            );
          },
          onSaved: (v) {
            if (parentField != null) {
              formValues[parentField.name!] ??= {};
              formValues[parentField.name][fieldItem.name] = v;
            } else {
              formValues[fieldItem.name!] = v;
            }
          },
        );
        break;
      case FieldType.checkbox:
        fieldFormItem = FormField<bool>(
          initialValue: fieldItem.value,
          builder: (FormFieldState<bool> state) {
            return CheckboxListTile(
              value: state.value ?? fieldItem.value,
              title: Text(fieldItem.label!),
              subtitle: fieldItem.hint == null ? null : Text(fieldItem.hint!),
              contentPadding: EdgeInsets.symmetric(horizontal: 0),
              onChanged: (v) {
                state.didChange(v);
              },
            );
          },
          onSaved: (v) {
            if (parentField != null) {
              formValues[parentField.name!] ??= {};
              formValues[parentField.name][fieldItem.name] = v;
            } else {
              formValues[fieldItem.name!] = v;
            }
          },
        );
        break;
      case FieldType.text:
        fieldFormItem = _buildTextFieldItem(fieldItem, parentField);
        break;
      case FieldType.image_list:
        fieldFormItem = UploadFormField(
          uploadType: UploadType.image_grid,
          maxFileCount: 4,
          crossAxisAlignment: CrossAxisAlignment.center,
          onSaved: (value) {
            var _v = value?.map((item) => (fieldItem.fileValueMapper ?? _defFileValueMapper).call(item)).toList();
            if (parentField != null) {
              formValues[parentField.name!] ??= {};
              formValues[parentField.name][fieldItem.name] = _v;
            } else {
              formValues[fieldItem.name!] = _v;
            }
          },
          validator: fieldItem.required ? UploadFormField.defaultMultiFileValidator : null,
          host: widget.host,
        );
        break;
      case FieldType.image:
        fieldFormItem = UploadFormField(
          uploadType: UploadType.image,
          label: Text('${fieldItem.label}'),
          crossAxisAlignment: CrossAxisAlignment.center,
          onSaved: (value) {
            var fileItem = value != null ? value[0] : null;
            var _v = (fieldItem.fileValueMapper ?? _defFileValueMapper).call(fileItem);
            if (parentField != null) {
              formValues[parentField.name!] ??= {};
              formValues[parentField.name][fieldItem.name] = _v;
            } else {
              formValues[fieldItem.name!] = _v;
            }
          },
          validator: fieldItem.required ? UploadFormField.defaultFileValidator : null,
          host: widget.host,
        );
        break;
      case FieldType.ftp_file:
        fieldFormItem = FtpFileFormField(
          label: Text('${fieldItem.label}'),
          crossAxisAlignment: CrossAxisAlignment.center,
          decoration: InputDecoration(
            filled: true,
            labelText: '${fieldItem.label} ${fieldItem.required ? '*' : ''}',
            labelStyle: widget.labelStyle,
            border: widget.inputBorder,
          ),
          onSaved: (value) {
            formValues[fieldItem.name!] = value;
            if (parentField != null) {
              formValues[parentField.name!] ??= {};
              formValues[parentField.name][fieldItem.name] = value;
            } else {
              formValues[fieldItem.name!] = value;
            }
          },
        );
        break;
      case FieldType.file:
        fieldFormItem = _buildFileItem(fieldItem, parentField);
        break;
      case FieldType.remote_file:
        fieldFormItem = _buildRemoteFileFormField(fieldItem, parentField);
        break;
      case FieldType.multi_file_source:
        fieldFormItem = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ToggleButtonGroup(
              constraints: BoxConstraints.tightFor(height: 28),
              borderRadius: BorderRadius.only(topLeft: Radius.circular(5), topRight: Radius.circular(5)),
              children: [
                Padding(padding: EdgeInsets.symmetric(horizontal: 4), child: Text(' Local File ')),
                Padding(padding: EdgeInsets.symmetric(horizontal: 4), child: Text(' Remote File ')),
              ],
              selectedIndex: fieldItem.fileSource,
              onChange: (idx) {
                fieldItem.fileSource = idx;
                setState(() {});
              },
            ),
            if (widget.inputBorder != InputBorder.none) SizedBox(height: 8),
            if (fieldItem.fileSource == 0) _buildFileItem(fieldItem, parentField),
            if (fieldItem.fileSource == 1) _buildRemoteFileFormField(fieldItem, parentField),
          ],
        );
        break;
      case FieldType.select:
        fieldFormItem = DropdownButtonFormField(
          decoration: InputDecoration(
            filled: widget.filled,
            labelText: fieldItem.label,
            labelStyle: widget.labelStyle,
            border: widget.inputBorder,
          ),
          value: fieldItem.value,
          items: fieldItem.options!.map((e) => DropdownMenuItem(child: Text(e.label), value: e.value)).toList(),
          onSaved: (_v) {
            fieldItem.value = _v;
            if (parentField != null) {
              formValues[parentField.name!] ??= {};
              formValues[parentField.name][fieldItem.name] = _v;
            } else {
              formValues[fieldItem.name!] = _v;
            }
          },
          onChanged: (_v) {
            fieldItem.value = _v;
            if (parentField != null) {
              formValues[parentField.name!] ??= {};
              formValues[parentField.name][fieldItem.name] = _v;
            } else {
              formValues[fieldItem.name!] = _v;
            }
          },
        );
        break;
      case FieldType.grouped:
        fieldFormItem = Container(
          padding: EdgeInsets.only(left: 10),
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(color: Theme.of(context).colorScheme.primary.withOpacity(.65), width: 4),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Text(fieldItem.label!, style: Theme.of(context).textTheme.titleMedium),
                  if (!fieldItem.required)
                    IconButton(
                      onPressed: () {
                        formValues.remove(fieldItem.name);
                        widget.fields.remove(fieldItem);
                        widget.onFieldDelete?.call(fieldItem);
                        setState(() {});
                      },
                      icon: Icon(Icons.close),
                      color: Colors.red,
                      iconSize: 16,
                      tooltip: 'Delete',
                      splashRadius: 15,
                      constraints: BoxConstraints.tightFor(width: 30, height: 30),
                      padding: EdgeInsets.zero,
                    )
                ],
              ),
              SizedBox(height: 10),
              ...dividerWith((fieldItem.subFields ?? []).map<Widget>((f) => _buildFormItem(f, fieldItem)!), 12),
            ],
          ),
        );
        break;
      default:
        fieldFormItem = Offstage();
        break;
    }
    return fieldFormItem;
  }

  Widget _buildRemoteFileFormField(FieldItem fieldItem, [FieldItem? parentField]) {
    return RemoteFileFormField(
      // label: Text('${fieldItem.label}'),
      host: widget.host,
      enableDirectorySelect: fieldItem.enableDirectorySelect,
      crossAxisAlignment: CrossAxisAlignment.center,
      multiple: fieldItem.multiFile,
      decoration: InputDecoration(
        filled: true,
        helperStyle: Theme.of(context).textTheme.bodySmall!.copyWith(
              fontWeight: FontWeight.w400,
              fontSize: 14,
              color: Theme.of(context).colorScheme.primary,
            ),
        helperMaxLines: 6,
        helperText: fieldItem.helperText,
        labelText: '${fieldItem.label} ${fieldItem.required ? '*' : ''}',
        // prefixIcon: Icon(Icons.cast_connected, size: 18, color: Theme.of(context).colorScheme.primary),
        labelStyle: widget.labelStyle,
        hintText: fieldItem.hint,
        border: widget.inputBorder,
        focusColor: Theme.of(context).colorScheme.primary.withOpacity(.15),
      ),
      initialValue: fieldItem.value == null || fieldItem.value is List<RemoteFile> ? fieldItem.value : null,
      validator: fieldItem.required ? (v) => v == null ? '${fieldItem.label} is required.' : null : null,
      onChanged: (List<RemoteFile>? files) {
        var v = (files == null || files.length == 0) ? null : (fieldItem.multiFile ? files : files.first);
        (parentField?.onChanged ?? fieldItem.onChanged)?.call(v, parentField ?? fieldItem);
      },
      onSaved: (List<RemoteFile>? files) {
        var value = fieldItem.multiFile ? files!.map((e) => e.path).toList() : files!.first.path;
        var isDir = fieldItem.multiFile ? false : files.first.isDirectory;
        if (parentField != null) {
          formValues[parentField.name!] ??= {};
          formValues[parentField.name][fieldItem.name] = value;
          formValues[parentField.name]['isDir'] = isDir;
        } else {
          formValues[fieldItem.name!] = value;
          formValues['isDir'] = isDir;
        }
      },
    );
  }

  Widget _buildFileItem(FieldItem<dynamic> fieldItem, [FieldItem<dynamic>? parentField]) {
    return UploadFormField(
      uploadType: UploadType.single,
      value: fieldItem.value == null || fieldItem.value is List<UploadFormField> ? fieldItem.value : null,
      crossAxisAlignment: CrossAxisAlignment.center,
      expand: true,
      decoration: InputDecoration(
        filled: true,
        labelText: '${fieldItem.label} ${fieldItem.required ? '*' : ''}',
        labelStyle: widget.labelStyle,
        hintText: fieldItem.hint,
        border: widget.inputBorder,
      ),
      onChanged: (value) {
        var fileItem = value != null ? value[0] : null;
        (parentField?.onChanged ?? fieldItem.onChanged)?.call(fileItem, parentField ?? fieldItem);
      },
      onSaved: (List<UploadFileItem>? value) {
        var fileItem = value != null ? value[0] : null;
        var _v = (fieldItem.fileValueMapper ?? _defFileValueMapper).call(fileItem);
        if (parentField != null) {
          formValues[parentField.name!] ??= {};
          formValues[parentField.name][fieldItem.name] = _v;
        } else {
          formValues[fieldItem.name!] = _v;
        }
      },
      validator: fieldItem.required ? (fieldItem.fieldValidator ?? UploadFormField.defaultFileValidator) : null,
      host: widget.host,
    );
  }

  Iterable<Widget> dividerWith(Iterable<Widget> list, double height) sync* {
    assert(height != null || context != null);

    final Iterator<Widget> iterator = list.iterator;
    final bool hasNext = iterator.moveNext();

    if (!hasNext) return;

    Widget tile = iterator.current;
    while (iterator.moveNext()) {
      yield Padding(
        padding: EdgeInsets.only(bottom: height),
        child: tile,
      );
      tile = iterator.current;
    }
    if (hasNext) yield tile;
  }

  _buttonGroup() {
    final children = [
      if (widget.reset)
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            shape: widget.buttonShape,
            padding: widget.buttonPadding,
            foregroundColor: Colors.red,
            minimumSize: Size(120, 46),
          ),
          onPressed: _resetForm,
          child: Text(widget.resetLabel!),
        ),
      if (widget.reset) SizedBox(width: 20),
      ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: widget.buttonShape,
          padding: widget.buttonPadding,
          minimumSize: Size(120, 46),
        ),
        onPressed: _handleSubmit,
        child: Text(widget.submitLabel!),
      ),
    ];

//    if (widget.reset) {
//      return ButtonBar(
//        alignment: widget.buttonAlignment,
//        buttonPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 24.0),
//        children: children,
//      );
//    }

    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: widget.buttonAlignment,
      children: widget.buttonExpand
          ? children.map((btn) {
              if (btn is SizedBox) return btn;
              return Expanded(child: btn);
            }).toList()
          : children,
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controllers.values.forEach((c) {
      c.dispose();
    });
    _controllers.clear();
  }
}
