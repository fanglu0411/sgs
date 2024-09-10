import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/bean/field_item.dart';
import 'package:flutter_smart_genome/widget/basic/simple_form.dart';

Future<Map?> showCordSelectorDialog(BuildContext context, {Offset? anchor}) async {
  Map? result = await showDialog<Map?>(
    context: context,
    anchorPoint: anchor,
    builder: (c) {
      return AlertDialog(
        title: Text('Select Cord and meta'),
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        content: ConstrainedBox(
          constraints: BoxConstraints(minWidth: 360, maxWidth: 480),
          child: LocalCellCordSelector(
            onSubmit: (files) {
              Navigator.of(context).pop(files);
            },
          ),
        ),
      );
    },
  );

  return result;
}

class LocalCellCordSelector extends StatefulWidget {
  ValueChanged<Map>? onSubmit;

  LocalCellCordSelector({super.key, this.onSubmit});

  @override
  State<LocalCellCordSelector> createState() => _LocalCellCordSelectorState();
}

class _LocalCellCordSelectorState extends State<LocalCellCordSelector> {
  late List<FieldItem> files;

  @override
  void initState() {
    super.initState();
    files = [
      FieldItem.file(
        name: 'cord',
        label: 'Cord File',
        hint: 'Please select Cord File',
      ),
      FieldItem.file(
        name: 'meta',
        label: 'Meta File',
        hint: 'Please select Meta File',
      ),
    ];
  }

  void _onSubmit(Map files) {
    widget.onSubmit?.call(files);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: SimpleForm(
        fields: files,
        onSubmit: _onSubmit,
        inputBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
        ),
      ),
    );
  }
}