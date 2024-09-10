import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/widget/upload/platform_entry.dart';
import 'package:flutter_smart_genome/widget/upload/upload_mixin.dart';
import 'package:flutter_smart_genome/widget/basic/hover_editable_widget.dart';

class ImageUploadWidget extends StatefulWidget {
  final int? maxFileSize;
  final ValueChanged<List<UploadFileItem>?>? onChanged;
  final String? host;
  final List<UploadFileItem>? value;

  ImageUploadWidget({
    Key? key,
    this.maxFileSize,
    this.onChanged,
    this.host,
    this.value,
  }) : super(key: key);

  @override
  _ImageUploadWidgetState createState() => _ImageUploadWidgetState();
}

class _ImageUploadWidgetState extends State<ImageUploadWidget> with UploadMixin {
  @override
  void initState() {
    super.initState();
    maxFileCount = 1;
    maxFileSize = widget.maxFileSize;
    if (widget.value != null) {
      fileItemList = <UploadFileItem>[...widget.value!];
    }
  }

  @override
  Widget build(BuildContext context) {
    if (hasFile()) {
//      var font;
//      if (file.fileStatus == FileStatus.uploading) {
//        font = CustomSpin(animating: true);
//      } else {
//        font = IconButton(
//          icon: Icon(Icons.delete),
//          color: Colors.red,
//          onPressed: () {
//            deleteFile(file);
//          },
//        );
//      }

      return HoverEditableWidget(
        hoverColor: Theme.of(context).colorScheme.primaryContainer,
        constraints: BoxConstraints.expand(width: 100, height: 100),
        onTap: () {},
        child: AdaptFileImageWidget.file(file?.file),
        fontChild: Container(
          alignment: Alignment.center,
          child: IconButton(
            icon: Icon(Icons.delete),
            color: Colors.red,
            onPressed: () {
              deleteFile(file!);
            },
          ),
        ),
      );
    }

    return Card(
//      color: Theme.of(context).colorScheme.primary,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        hoverColor: Theme.of(context).colorScheme.primaryContainer,
        onTap: selectFile,
        child: Container(
          alignment: Alignment.center,
          constraints: BoxConstraints.expand(width: 100, height: 100),
          child: Icon(Icons.add, size: 40, color: Colors.black45),
        ),
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
