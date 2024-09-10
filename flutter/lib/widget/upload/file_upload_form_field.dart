import 'package:flutter_smart_genome/widget/basic/custom_spin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/util/logger.dart';
import 'platform_entry.dart';
import 'dart:html' as html;

class FileUploadFormField extends StatefulWidget {
  final UploadFileItem fileItem;
  final GestureTapCallback? onTap;
  final String? label;
  final FormFieldSetter<String>? onSaved;

  const FileUploadFormField({Key? key, required this.fileItem, this.onTap, this.label, this.onSaved}) : super(key: key);

  @override
  _FileUploadFormFieldState createState() => _FileUploadFormFieldState();
}

class _FileUploadFormFieldState extends State<FileUploadFormField> {
  late TextEditingController _textEditingController;

  @override
  void didUpdateWidget(FileUploadFormField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.fileItem != oldWidget.fileItem) {
      _textEditingController.text = widget.fileItem.file.name;
      _sendFormData(widget.fileItem.file);
    }
  }

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController(text: widget.fileItem.file?.name ?? 'Click to select file');

    _sendFormData(widget.fileItem.file);
  }

  _sendFormData(final html.File file) async {
    setState(() {
      widget.fileItem.fileStatus = FileStatus.uploading;
    });

    final html.FormData formData = html.FormData()..appendBlob('file', file);

    handleRequest(html.HttpRequest httpRequest) {
      logger.i('upload resp: ${httpRequest.responseText}');
      switch (httpRequest.status) {
        case 200:
          setState(() {
            widget.fileItem.fileStatus = FileStatus.success;
          });
          return;
        default:
          setState(() {
            widget.fileItem.fileStatus = FileStatus.fail;
          });
          break;
      }
    }

    onProgress(e) {
      double progress = e.lengthComputable ? (e.loaded * 100 ~/ e.total) / 100.0 : e.loaded / 100.0;
      logger.i('upload sending: ${e.loaded} ${e.total} progress:$progress');

      if (widget.fileItem.progress == progress) return;
      setState(() {
        widget.fileItem.progress = progress;
      });
    }

    //    var url = 'https://www.mocky.io/v2/5cc8019d300000980a055e76';
    var url = 'http://localhost:8088/api/file/upload';

    html.HttpRequest.request(
      url,
      method: 'POST',
      sendData: formData,
      onProgress: onProgress,
    ).then((httpRequest) {
      handleRequest(httpRequest);
    }).catchError((e) {
      setState(() {
        widget.fileItem.fileStatus = FileStatus.fail;
      });
    });

//    final html.HttpRequest httpRequest = html.HttpRequest();
//    httpRequest
//      ..onProgress.listen(onProgress)
//      ..onLoadEnd.listen((e) {
//        handleRequest(httpRequest);
//      })
//      ..open('POST', url)
//      ..send(formData);
  }

  @override
  Widget build(BuildContext context) {
    UploadFileItem fileItem = widget.fileItem;
    debugPrint('build ${fileItem.file?.name}');
    var prefixIcon;
    if (fileItem.fileStatus == FileStatus.uploading || fileItem.fileStatus == FileStatus.normal) {
      prefixIcon = CustomSpin(color: Theme.of(context).colorScheme.primary);
    } else {
      prefixIcon = Icon(
        Icons.insert_drive_file,
        color: Colors.brown,
        size: 20.0,
      );
    }
    return TextFormField(
      controller: _textEditingController,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(30))),
        filled: false,
//        prefixIcon: Icon(Icons.insert_drive_file),
        prefixIcon: prefixIcon,
//        icon: prefixIcon,
        hintText: 'Click to select file',
        labelText: '${widget.label} ${'*'}',
        errorText: fileItem.fileStatus == FileStatus.fail ? 'File upload error' : null,
      ),
      showCursor: false,
      onTap: widget.onTap,
      onSaved: widget.onSaved,
    );
  }
}
