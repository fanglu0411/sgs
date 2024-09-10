import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'platform_entry.dart';

UploadFileItem createUploadFile(dynamic file, [String? host]) => throw UnimplementedError();

Future<List> pickFile({OnFileSelect? callback, bool multi = false}) => throw UnimplementedError();

Future<bool> saveFile(String fileName, String content, [String? type]) => throw UnimplementedError();

Future<bool> saveFileBytes(String fileName, Uint8List bytes, [String? type]) => throw UnimplementedError();

Future<String> readFile({String? file, Function? callback, String type = 'text/json'}) => throw UnimplementedError();

Future<List<String>> readFileLines({required String file, int lines = 1}) => throw UnimplementedError();

Future<List<String>> readFileLineRange({required String file, int startLine = 1, int lineCount = 1}) => throw UnimplementedError();

Future<Stream<List<int>>> openReadStream([String? type]) => throw UnimplementedError();

Future uploadFile(UploadFileItem fileItem, OnUploadFileStatusChange onUploadFileStatusChange, [String? host]) async {
  throw UnimplementedError();
}

Widget adaptiveFileImageWidget(dynamic file) => throw UnimplementedError();
