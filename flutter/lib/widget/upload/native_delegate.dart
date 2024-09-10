import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/base/ui_config.dart';
import 'package:flutter_smart_genome/network/api/simple_request.dart';
import 'package:flutter_smart_genome/network/dio_helper.dart';
import 'package:flutter_smart_genome/network/http_response.dart';
import 'package:flutter_smart_genome/util/logger.dart';
import 'platform_entry.dart';

// import 'package:file_selector/file_selector.dart' as fileSelector;

UploadFileItem createUploadFile(dynamic file, [String? host]) => NativeUploadFile(file);

Widget adaptiveFileImageWidget(dynamic file) => Image.file(file);

Future<List> pickFile({OnFileSelect? callback, bool multi = false}) async {
  // if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) return desktopPickFile(callback: callback, multi: false);
  FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: multi);
  List _files = result == null ? [] : result.files.map((e) => File(e.path!)).toList();
  callback?.call(_files);
  return _files;
}

Future parseFile(File file) async {
  try {
    Uint8List content = await file.readAsBytes();
    // logger.i('parse file: ${String.fromCharCodes(content)}');
    return content;
  } catch (e) {
    logger.e('e $e');
    return '--';
  }
}

Future<bool> saveFile(String fileName, String content, [String? type]) async {
  if (!desktopPlatform()) return false;
  // fileSelector.FileSaveLocation? location = await fileSelector.getSaveLocation(suggestedName: fileName);
  // if (location == null) return false;
  String? path = await FilePicker.platform.saveFile(fileName: fileName);

  if (path == null) return false;
  File file = File(path);
  if (await file.exists()) {
  } else {
    file.createSync(recursive: true);
  }
  await file.writeAsString(content, flush: true);
  return true;
}

Future<bool> saveFileBytes(String fileName, Uint8List bytes, [String? type]) async {
  if (!desktopPlatform()) return false;
  // fileSelector.FileSaveLocation? location = await fileSelector.getSaveLocation(suggestedName: fileName);
  // if (location == null) return false;
  String? path = await FilePicker.platform.saveFile(fileName: fileName);
  if (path == null) return false;

  File file = File(path);
  if (await file.exists()) {
  } else {
    file.createSync(recursive: true);
  }
  await file.writeAsBytes(bytes, flush: true);
  return true;
}

Future<String?> readFile({String? file, Function? callback, String type = 'text/json'}) async {
  File __file;
  if (file == null) {
    List files = await pickFile();
    if (files.length == 0) return null;
    __file = files.first;
  } else {
    __file = File(file);
  }
  String content = await __file.readAsString();
  callback?.call(__file.path, content);
  return content;
}

Future<List<String>> readFileLines({required String file, int lines = 1}) async {
  List<String> _lines = List.empty(growable: true);
  try {
    final _file = File(file);
    final randomAccessFile = await _file.open();
    final lineList = <int>[];
    int byte;
    while ((byte = await randomAccessFile.readByte()) >= 0) {
      if (byte == utf8.encode('\n').first) {
        _lines.add(utf8.decode(lineList));
        if (_lines.length == lines) break;
      }
      lineList.add(byte);
    }
    await randomAccessFile.close();
    return _lines;
  } catch (e) {
    // handle error
    return _lines;
  }
}

Future<List<String>> readFileLineRange({required String file, int startLine = 1, int lineCount = 1}) async {
  final _file = File(file);
  final length = await _file.length();
  final raf = await _file.open();
  final lines = <String>[];
  var currentLine = 1;
  var startOffset = 0;
  var endOffset = length - 1;

  while (currentLine <= startLine && startOffset <= endOffset) {
    final byte = await raf.readByte();
    if (byte == 10) {
      // line feed
      currentLine++;
    }
    startOffset++;
  }

  while (currentLine <= startLine + lineCount - 1 && startOffset <= endOffset) {
    final byte = await raf.readByte();
    if (byte == 10) {
      // line feed
      List<int> buffer = List.empty(growable: true);
      var bytesRead = raf.readIntoSync(buffer, startOffset - lines.last.length - 1, lines.last.length);
      lines.add(utf8.decode(buffer));
      currentLine++;
    }
    startOffset++;
  }

  await raf.close();
  return lines;
}

Future<Stream<List<int>>?> openReadStream([String? type]) async {
  List files = await pickFile();
  if (files.length == 0) return null;
  File _file = files.first;
  return _file.openRead();
}

Future<List> desktopPickFile({OnFileSelect? callback, bool multi = false}) async {
  // List<fileSelector.XFile> result = [];
  // if (multi) {
  //   result = await fileSelector.openFiles();
  // } else {
  //   var file = await fileSelector.openFile();
  //   if (null != file) result = [file];
  // }

  FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: multi);
  if (result == null) return [];

  List<File> files = result.paths.map((e) => File(e!)).toList();
  callback?.call(files);
  return files;
}

Future uploadFile(UploadFileItem fileItem, OnUploadFileStatusChange onUploadFileStatusChange, [String? host]) async {
  onUploadFileStatusChange(fileItem..fileStatus = FileStatus.uploading);
  HttpResponseBean bean = await postMultipart(
    '${host ?? DioHelper().baseUrl}/api/file/upload',
    file: fileItem.path,
    onSendProgress: (progress, total) {
      onUploadFileStatusChange(fileItem..progress = progress / total);
    },
  );
  if (bean.success) {
    onUploadFileStatusChange(fileItem
      ..fileStatus = FileStatus.success
      ..response = bean.bodyStr);
  } else {
    onUploadFileStatusChange(fileItem
      ..fileStatus = FileStatus.fail
      ..response = bean.bodyStr ?? bean.error?.message);
  }

  // ChunkedUploader chunkedUploader = ChunkedUploader(Dio(BaseOptions(
  //   baseUrl: '${host ?? DioHelper.apiUrl}',
  //   headers: {'Authorization': 'Bearer'},
  // )));
  // try {
  //   Response response = await chunkedUploader.upload(
  //     filePath: fileItem.path,
  //     maxChunkSize: 10000000,
  //     path: '/api/file/upload',
  //     onUploadProgress: (progress) {
  //       print(progress);
  //       onUploadFileStatusChange(fileItem..progress = progress);
  //     },
  //   );
  //   print(response);
  //   if (response.statusCode == 200) {
  //     onUploadFileStatusChange(fileItem
  //       ..fileStatus = FileStatus.success
  //       ..response = response.data);
  //   } else {
  //     onUploadFileStatusChange(fileItem
  //       ..fileStatus = FileStatus.fail
  //       ..response = response.data ?? response.statusMessage);
  //   }
  // } on DioError catch (e) {
  //   print(e);
  // }
}

class NativeUploadFile extends UploadFileItem {
  NativeUploadFile(file, [String? _host]) {
    _file = file;
    fileStatus = FileStatus.normal;
    host = _host;
  }

  late File _file;

  @override
  get file => _file;

  @override
  get path => _file.path;

  @override
  get name => _file.path.substring(_file.path.lastIndexOf('/') + 1);

  @override
  get size => _file.lengthSync();

  Stream<List<int>> openStream() => _file.openRead();

  @override
  void readFile() {
    var content = _file.readAsBytesSync();
    if (onFileRead != null) onFileRead!.call(content);
  }

  @override
  void readFileAsString() {
    String content = _file.readAsStringSync();
    if (onFileRead != null) onFileRead!.call(content);
  }
}
