import 'package:flutter_smart_genome/widget/basic/custom_spin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/widget/upload/platform_entry.dart';
import 'package:flutter_smart_genome/widget/upload/upload_mixin.dart';


class MultiFileUploadWidget extends StatefulWidget {
  final int? maxFileCount;
  final int? maxFileSize;
  final Widget? hint;
  final ValueChanged<List<UploadFileItem>?>? onChanged;
  final String? host;
  final List<UploadFileItem>? value;

  const MultiFileUploadWidget({
    Key? key,
    this.maxFileCount,
    this.maxFileSize,
    this.onChanged,
    this.hint = const Text('Tap to select file'),
    this.host,
    this.value,
  }) : super(key: key);

  @override
  _MultiFileUploadWidgetState createState() => _MultiFileUploadWidgetState();
}

class _MultiFileUploadWidgetState extends State<MultiFileUploadWidget> with UploadMixin<MultiFileUploadWidget> {
  @override
  void initState() {
    super.initState();
    host = widget.host;
    maxFileSize = widget.maxFileSize;
    maxFileCount = widget.maxFileCount ?? 999;
    if (widget.value != null) {
      fileItemList = <UploadFileItem>[...widget.value!];
    }
  }

  @override
  Widget build(BuildContext context) {
    var picker = InkWell(
      hoverColor: Colors.blue[50],
      splashColor: Colors.blue[10],
      onTap: fileCount < maxFileCount! ? selectFile : null,
      child: Container(
        decoration: BoxDecoration(
//          color: Colors.blue[50],
          border: Border.all(color: Colors.blue),
          borderRadius: BorderRadius.all(Radius.circular(5.0)),
        ),
        padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
        child: widget.hint,
      ),
    );

    var filesList = fileItemList.map(_fileItem);

    return Container(
      constraints: BoxConstraints.tightFor(width: 400),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          picker,
          if (filesList.length > 0) SizedBox(height: 10.0),
          ...filesList,
        ],
      ),
    );
  }

  Widget _fileItem(UploadFileItem fileItem) {
    var prefixIcon;
    if (fileItem.fileStatus == FileStatus.uploading || fileItem.fileStatus == FileStatus.normal) {
      prefixIcon = CustomSpin(color: Theme.of(context).colorScheme.primary);
    } else {
      prefixIcon = Icon(
        Icons.attach_file,
        color: Colors.lightBlue,
        size: 20.0,
      );
    }
    return Row(
      children: <Widget>[
        prefixIcon,
        SizedBox(width: 8.0),
        Expanded(
          child: Text(
            '${fileItem.file.name}',
            style: TextStyle(color: fileItem.fileStatus == FileStatus.fail ? Colors.red : Colors.black87, fontSize: 18.0),
          ),
        ),
        if (fileItem.fileStatus == FileStatus.uploading)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: CircularProgressIndicator(value: fileItem.progress),
          ),
        IconButton(
          padding: EdgeInsets.all(2.0),
          iconSize: 18.0,
          icon: Icon(Icons.delete),
          onPressed: () {
            deleteFile(fileItem);
          },
          color: Colors.red[500],
        ),
      ],
    );
  }

  @override
  void onFileStatusChange(UploadFileItem fileItem) {
    if (fileItem.fileStatus == FileStatus.success || fileItem.fileStatus == FileStatus.fail) {
      if (widget.onChanged != null) widget.onChanged!(fileItemList);
    }
    setState(() {
      // update status
    });
  }

  @override
  void onFileSelect(UploadFileItem fileItem) {
    if (widget.onChanged != null) widget.onChanged!(fileItemList);
    uploadFileMixin(fileItem, widget.host);
  }

  @override
  void onFileDeleted() {
    if (widget.onChanged != null) widget.onChanged!(null);
  }
}
