import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/widget/upload/platform_entry.dart';
import 'package:flutter_smart_genome/widget/upload/upload_mixin.dart';
import 'package:flutter_smart_genome/widget/basic/hover_editable_widget.dart';

class ImageGridUploadWidget extends StatefulWidget {
  final int? maxFileSize;
  final int? maxFileCount;
  final ValueChanged<List<UploadFileItem>?>? onChanged;
  final String? host;

  const ImageGridUploadWidget({
    Key? key,
    this.maxFileSize,
    this.maxFileCount,
    this.onChanged,
    this.host,
  }) : super(key: key);

  @override
  _ImageGridUploadWidgetState createState() => _ImageGridUploadWidgetState();
}

class _ImageGridUploadWidgetState extends State<ImageGridUploadWidget> with UploadMixin<ImageGridUploadWidget> {
  @override
  void initState() {
    super.initState();
    maxFileSize = widget.maxFileSize;
    maxFileCount = widget.maxFileCount;
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return _buildWithSize(context, size);
  }

  Widget _buildWithSize(BuildContext context, [Size? size]) {
    final width = 200.0;
    final height = width * .618;

    final items = fileItemList.map<Widget>((file) {
      return _buildImageItem(file, width, height);
    }).toList();

    if (fileItemList.length < maxFileCount!) {
      var addImage = Card(
//        color: Theme.of(context).colorScheme.primary.withAlpha(50),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          hoverColor: Theme.of(context).colorScheme.primaryContainer,
          onTap: selectFile,
          child: Container(
            constraints: BoxConstraints.expand(width: width, height: height),
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(Icons.add_photo_alternate, size: 60, color: Colors.black45),
                SizedBox(height: 12),
                Text('Upload Image', style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ),
      );
      items.add(addImage);
    }
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: items,
    );
  }

  Widget _buildImageItem(UploadFileItem fileItem, double width, double height) {
    return HoverEditableWidget(
      child: AdaptFileImageWidget.file(fileItem.file),
      onTap: () {},
      hoverColor: Theme.of(context).colorScheme.primary.withAlpha(100),
      constraints: BoxConstraints.expand(width: width, height: height),
      fontChild: Container(
        alignment: Alignment.center,
        child: IconButton(
          icon: Icon(Icons.delete),
          tooltip: 'Delete',
          color: Colors.red,
          onPressed: () {
            deleteFile(fileItem);
          },
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
