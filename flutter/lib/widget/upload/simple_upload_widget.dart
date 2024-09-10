import 'package:flutter_smart_genome/widget/basic/custom_spin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/widget/upload/platform_entry.dart';
import 'package:flutter_smart_genome/widget/upload/upload_mixin.dart';

class SimpleFileUploadWidget extends StatefulWidget {
  final Widget hint;
  final int? maxFileSize;
  final ValueChanged<List<UploadFileItem>?>? onChanged;
  final String? host;
  final List<UploadFileItem>? value;

  const SimpleFileUploadWidget({
    Key? key,
    this.maxFileSize,
    this.onChanged,
    this.hint = const Text('Tap to select file'),
    this.host,
    this.value,
  }) : super(key: key);

  @override
  _SimpleFileUploadWidgetState createState() => _SimpleFileUploadWidgetState();
}

class _SimpleFileUploadWidgetState extends State<SimpleFileUploadWidget> with UploadMixin {
  @override
  void initState() {
    super.initState();
    maxFileSize = widget.maxFileSize;
    maxFileCount = 1;
    host = widget.host;
    if (widget.value != null) {
      fileItemList = <UploadFileItem>[...widget.value!];
    }
  }

  @override
  Widget build(BuildContext context) {
    var prefixIcon;
    if (file?.fileStatus == FileStatus.uploading) {
      prefixIcon = CustomSpin(color: Theme.of(context).colorScheme.primary);
    } else {
      prefixIcon = Icon(Icons.insert_drive_file, size: 20.0);
    }

    var fail = file?.fileStatus == FileStatus.fail;
    var textStyle = TextStyle(color: fail ? Colors.red : Theme.of(context).textTheme.bodySmall!.color);
    return InkWell(
      splashColor: Theme.of(context).colorScheme.primary,
      onTap: selectFile,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            prefixIcon,
            SizedBox(width: 8),
            Expanded(
                child: file != null
                    ? RichText(
                        text: TextSpan(children: [
                          TextSpan(text: '${file!.path ?? file!.response}', style: textStyle),
                          if (file!.size != null) TextSpan(text: ' (${file!.sizeString})', style: Theme.of(context).textTheme.bodySmall),
                        ]),
                      )
                    : widget.hint),
            if (file?.fileStatus == FileStatus.uploading) _buildProgress(),
            if (file != null && file!.fileStatus != FileStatus.uploading)
              IconButton(
                constraints: BoxConstraints.tightFor(width: 24, height: 24),
                splashRadius: 18,
                padding: EdgeInsets.zero,
                iconSize: 20,
                icon: Icon(Icons.close),
                onPressed: () {
                  deleteFile(file!);
                },
              )
          ],
        ),
      ),
    );
  }

  Widget _buildProgress() {
    return SizedBox(
      width: 34,
      height: 34,
      child: Stack(
        children: [
          CircularProgressIndicator(
            value: file!.progress,
            backgroundColor: Theme.of(context).colorScheme.primary.withAlpha(80),
          ),
          Center(
            child: Text(
              '${(file!.progress * 100).toStringAsFixed(0)}%',
              style: TextStyle(fontSize: 12),
            ),
          )
        ],
      ),
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
