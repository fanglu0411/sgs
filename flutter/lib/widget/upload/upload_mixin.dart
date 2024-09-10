import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/widget/basic/custom_bot_widget.dart' as toast;
import 'package:flutter_smart_genome/widget/upload/platform_entry.dart';

mixin UploadMixin<T extends StatefulWidget> on State<T> {
  int? maxFileSize;
  int? maxFileCount;

  List<UploadFileItem> fileItemList = [];

  UploadFileItem? get file => fileItemList.length > 0 ? fileItemList.last : null;

  int get fileCount => fileItemList.length;

  String? _host;

  String? get host => _host;

  void set host(String? host) => _host = host;

  void _onFileSelected(List files) {
    if (files.length == 0) {
      showToast('No file selected!');
      return;
    }
    final file = files[0];
    if (maxFileSize != null && file.size > maxFileSize! * 1000) {
      showToast('File size exceeds limit!', duration: Duration(milliseconds: 3500));
      return;
    }
    var fileItem = UploadFileItem.create(files[0], host);
    if (maxFileCount != null && maxFileCount! > 1) {
      fileItemList.add(fileItem);
    } else {
      if (fileItemList.length > 0) fileItemList.clear();
      fileItemList.add(fileItem);
    }

    onFileSelect(fileItem);
  }

  void selectFile() {
    pickFileDelegate(callback: _onFileSelected);
  }

  void uploadFileMixin(UploadFileItem fileItem, [host]) async {
    String? _host = fileItem.host ?? host;
    if (_host == null || _host.length == 0) {
      fileItem.fileStatus = FileStatus.success;
      return;
    }
    uploadFileDelegate(fileItem, onFileStatusChange, _host);
  }

  bool hasFile() {
    return fileItemList.length > 0;
  }

  void onFileStatusChange(UploadFileItem fileItem);

  void onFileSelect(UploadFileItem fileItem);

  void onFileDeleted();

  void deleteFile(UploadFileItem fileItem) {
    setState(() {
      fileItemList.remove(fileItem);
    });
    onFileDeleted();
  }

  showToast(String msg, {Duration duration = const Duration(milliseconds: 2000)}) {
    toast.showToast(
      text: msg,
      duration: duration,
      align: Alignment(0, 0.02),
    );
  }
}
