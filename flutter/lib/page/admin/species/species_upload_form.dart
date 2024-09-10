import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/base/container_config.dart';
import 'package:flutter_smart_genome/base/ui_config.dart';
import 'package:flutter_smart_genome/bean/field_item.dart';
import 'package:flutter_smart_genome/widget/basic/simple_form.dart';

class SpeciesUploadForm extends StatefulWidget {
  final Map? map;
  final ValueChanged<Map<String, dynamic>>? onSubmit;
  final String? host;

  const SpeciesUploadForm({Key? key, this.map, this.onSubmit, this.host}) : super(key: key);
  @override
  _UploadFormState createState() => _UploadFormState();
}

class _UploadFormState extends State<SpeciesUploadForm> with AutomaticKeepAliveClientMixin {
  List<FieldItem> _fieldItems = [
    FieldItem.upload(
      name: 'gff',
      label: 'Gff file',
      fieldType: FieldType.file,
      required: true,
//      maxSize: 200,
    ),
    FieldItem.upload(
      name: 'fasta',
      label: 'Fasta file',
      fieldType: FieldType.file,
      required: true,
//      maxSize: 200,
    ),
    FieldItem.upload(
      name: 'annotation',
      label: 'Annotation file',
      fieldType: FieldType.file,
      required: true,
//      maxSize: 200,
    ),
    FieldItem.upload(
      name: 'expression',
      label: 'Expression file',
      fieldType: FieldType.file,
      required: true,
//      maxSize: 200,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
//      color: Colors.white,
      padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 20),
      child: SimpleForm(
        fields: _fieldItems,
        buttonExpand: isMobile(context),
        onSubmit: widget.onSubmit,
        reset: false,
        inputBorder: inputBorder(),
        buttonShape: buttonShape(),
        host: widget.host,
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}