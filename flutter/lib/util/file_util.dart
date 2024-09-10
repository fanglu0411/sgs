import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_smart_genome/network/dio_helper.dart';
import 'package:flutter_smart_genome/widget/upload/platform_entry.dart' as file_entry;

class FileUtil {
  static Future saveFile(String fileName, String content) async {
    return file_entry.saveFileDelegate(fileName, content);
  }

  static Future saveByteData(String fileName, Uint8List bytes) async {
    return file_entry.saveFileBytesDelegate(fileName, bytes);
  }

  static Future readFile({String? file, Function? callback, String type = 'text/json'}) async {
    return file_entry.readFileDelegate(callback: callback, file: file, type: type);
  }

  static Future<Stream<List<int>>?> openReadStream() async {
    return await file_entry.openReadStreamDelegate();
  }

  static Future<file_entry.UploadFileItem?> selectFile() async {
    List? files = await file_entry.pickFileDelegate();
    if (files.length == 0) return null;
    return file_entry.UploadFileItem.create(files.first, '');
  }

  static Future<List<String>> readFileLines(String path, {int lines = 1}) async {
    return file_entry.readFileLinesDelegate(file: path, lines: lines);
  }

  static Future loadNetworkFile(String url) async {
    try {
      var response = await DioHelper().thirdDio.get(
            url,
            options: Options(
              responseType: ResponseType.stream,
            ),
          );
      if (response.statusCode == 200) {
        final Uint8List bytes = await consolidateHttpClientResponseBytes(response.data);
        print(bytes.length);
      } else {
        throw Exception('Failed to load binary file');
      }
    } catch (e) {
      print(e);
    }
  }

  static Future<Uint8List> consolidateHttpClientResponseBytes(ResponseBody response) {
    // response.contentLength is not trustworthy when GZIP is involved
    // or other cases where an intermediate transformer has been applied
    // to the stream.
    final Completer<Uint8List> completer = Completer<Uint8List>.sync();
    final List<List<int>> chunks = <List<int>>[];
    int contentLength = 0;
    response.stream.listen(
      (List<int> chunk) {
        chunks.add(chunk);
        contentLength += chunk.length;
        print('read : ${chunk.length}');
      },
      onDone: () {
        final Uint8List bytes = Uint8List(contentLength);
        int offset = 0;
        for (List<int> chunk in chunks) {
          bytes.setRange(offset, offset + chunk.length, chunk);
          offset += chunk.length;
        }
        completer.complete(bytes);
      },
      onError: completer.completeError,
      cancelOnError: true,
    );

    return completer.future;
  }

  static String fileSizeStr(int size) {
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
}
