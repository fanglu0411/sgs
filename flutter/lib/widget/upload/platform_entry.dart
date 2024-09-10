import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'platform_delegate.dart'

// ignore: uri_does_not_exist
    if (dart.library.html) 'web_delegate.dart'
// ignore: uri_does_not_exist
    if (dart.library.io) 'native_delegate.dart';

enum FileStatus {
  normal,
  uploading,
  success,
  fail,
}

typedef void OnFileSelect(List files);
typedef void OnUploadFileStatusChange(UploadFileItem fileItem);

typedef void OnFileRead(Object result);

Future<List> pickFileDelegate({OnFileSelect? callback, bool multi = false}) => pickFile(callback: callback, multi: multi);

Future<bool> saveFileDelegate(String fileName, String content) => saveFile(fileName, content);

Future<bool> saveFileBytesDelegate(String fileName, Uint8List bytes) => saveFileBytes(fileName, bytes);

Future<String?> readFileDelegate({String? file, Function? callback, String type = 'text/json'}) => readFile(
      callback: callback,
      type: type,
      file: file,
    );

Future<Stream<List<int>>?> openReadStreamDelegate([String? type]) => openReadStream(type);

Future uploadFileDelegate(UploadFileItem fileItem, OnUploadFileStatusChange onUploadFileStatusChange, [String? host]) async {
  return await uploadFile(fileItem, onUploadFileStatusChange, host);
}

Future<List<String>> readFileLinesDelegate({required String file, int lines = 1}) => readFileLines(file: file, lines: lines);

Future<List<String>> readFileLineRangeDelegate({required String file, int startLine = 1, int lineCount = 1}) => readFileLineRange(file: file, startLine: startLine, lineCount: lineCount);

abstract class UploadFileItem {
  static UploadFileItem create(dynamic file, String? host) => createUploadFile(file, host);

  String? host;

  late FileStatus fileStatus;
  double progress = 0.0;
  OnFileRead? onFileRead;

  String? url;

  dynamic response;

//  factory UploadFileItem(dynamic file) => createUploadFile(file);

  get file => throw UnimplementedError();

  get path => throw UnimplementedError();

  get name => throw UnimplementedError();

  get size => throw UnimplementedError();

  get sizeString {
    int size = this.size;
    double kb = size / 1024;
    if (kb < 1024) {
      return '${kb.toStringAsFixed(2)}kb';
    }
    double m = size / 1048576;
    if (m < 1024) {
      return '${m.toStringAsFixed(2)}M';
    }
    double gb = size / 1073741824;
    return '${gb.toStringAsFixed(2)}G';
  }

  Stream<List<int>> openStream() => throw UnimplementedError();

  void readFile();

  void readFileAsString();

  @override
  String toString() {
    return 'UploadFileItem{fileStatus: $fileStatus, progress: $progress, url: $url, response: $response}';
  }
}

abstract class AdaptFileImageWidget {
  static Widget file(dynamic file) => adaptiveFileImageWidget(file);
}
