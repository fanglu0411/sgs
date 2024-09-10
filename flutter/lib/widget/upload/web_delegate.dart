import 'package:flutter_smart_genome/widget/basic/custom_spin.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/network/dio_helper.dart';
import 'package:flutter_smart_genome/util/logger.dart';
import 'platform_entry.dart';
import 'dart:html' as html;

UploadFileItem createUploadFile(dynamic file, [String? host]) => BrowserUploadFile(file, host);

Widget adaptiveFileImageWidget(dynamic file) => WebImage(file: file);

Future<List> pickFile({OnFileSelect? callback, bool multi = false}) async {
  html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
  uploadInput.multiple = multi;
//    uploadInput.pattern = 'image/*';
  uploadInput.onChange.listen((e) {
    final files = uploadInput.files ?? [];
    callback?.call(files);
  });
  uploadInput.click();
  return [];
}

Future<bool> saveFile(String fileName, String content, [String type = 'text/plain']) async {
  var file;
  try {
    file = html.File([content], fileName, {'type': type});
  } catch (e) {
    file = html.Blob([content], type);
  }
  var url = html.Url.createObjectUrl(file);
  var a = html.document.createElement('a');
  a.attributes = {'target': '_blank', 'download': fileName, 'href': url};
  a.click();
  return true;
}

Future<bool> saveFileBytes(String fileName, Uint8List bytes, [String type = 'text/plain']) async {
  var file;
  try {
    file = html.File([bytes], fileName, {'type': type});
  } catch (e) {
    file = html.Blob([bytes], type);
  }
  var url = html.Url.createObjectUrl(file);
  var a = html.document.createElement('a');
  a.attributes = {'target': '_blank', 'download': fileName, 'href': url};
  a.click();
  return true;
}

Future<String?> readFile({String? file, Function? callback, String type = 'text/json'}) async {
  await pickFile(callback: (files) {
    if (files.length == 0) return null;
    html.File _file = files.first;
    final html.FileReader _reader = new html.FileReader();
    _reader.onLoadEnd.listen((e) => callback?.call(_reader.result));
    _reader.readAsText(_file);
  });
  return null;
}

Future<List<String>> readFileLines({required String file, int lines = 1}) async {
  return Future.value([]);
}

Future<List<String>> readFileLineRange({required String file, int startLine = 1, int lineCount = 1}) {
  throw Exception('not supported');
}

Future<Stream<List<int>>?> openReadStream([String? type]) async {
  throw Error();
}

Future uploadFile(UploadFileItem fileItem, OnUploadFileStatusChange onUploadFileStatusChange, [String? host]) async {
  onUploadFileStatusChange(fileItem..fileStatus = FileStatus.uploading);

  final html.FormData formData = html.FormData()..appendBlob('file', fileItem.file);

  handleRequest(html.HttpRequest httpRequest) {
    logger.i('upload resp: ${httpRequest.responseText}');
    switch (httpRequest.status) {
      case 200:
        fileItem
          ..response = httpRequest.responseText
          ..fileStatus = FileStatus.success;
        onUploadFileStatusChange(fileItem);
        break;
      default:
        fileItem
          ..response = httpRequest.responseText
          ..fileStatus = FileStatus.fail;
        onUploadFileStatusChange(fileItem);
        break;
    }
  }

  onProgress(html.ProgressEvent e) {
    double progress = e.lengthComputable ? (e.loaded! * 100 ~/ e.total!) / 100.0 : e.loaded! / 100.0;
    logger.i('upload sending: ${e.loaded} ${e.total} progress: $progress');

    if (fileItem.progress == progress) return;
    onUploadFileStatusChange(fileItem..progress = progress);
  }

  //    var url = 'https://www.mocky.io/v2/5cc8019d300000980a055e76';
  var url = '${host ?? DioHelper().baseUrl}/api/file/upload';

  html.HttpRequest.request(
    url,
    method: 'POST',
    sendData: formData,
    onProgress: onProgress,
  ).then((httpRequest) {
    handleRequest(httpRequest);
  }).catchError((e) {
    logger.e(e);
    fileItem
      ..response = e.toString()
      ..fileStatus = FileStatus.fail;
    onUploadFileStatusChange(fileItem);
  });
}

class BrowserUploadFile extends UploadFileItem {
  BrowserUploadFile(file, [String? _host]) {
    _file = file;
    fileStatus = FileStatus.normal;
    this.host = _host;
  }

  late html.File _file;

  @override
  get file => _file;

  @override
  get path => _file.name;

  @override
  get name => _file.name;

  @override
  get size => _file.size;

  Stream<List<int>> openStream() => throw UnimplementedError();

  @override
  void readFile() {
    final html.FileReader _reader = new html.FileReader();
    _reader.onLoadEnd.listen((e) {
      onFileRead?.call(_reader.result!);
    });
    _reader.readAsArrayBuffer(file);
  }

  @override
  void readFileAsString() {
    final html.FileReader _reader = new html.FileReader();
    _reader.onLoadEnd.listen((e) {
      onFileRead?.call(_reader.result!);
    });
    _reader.readAsText(file);
  }
}

class WebImage extends StatefulWidget {
  final html.File? file;

  const WebImage({Key? key, this.file}) : super(key: key);

  @override
  _WebImageState createState() => _WebImageState();
}

class _WebImageState extends State<WebImage> {
  _readFile(html.File file) async {
    final html.FileReader _reader = new html.FileReader();
    _reader
      ..onProgress.listen((e) {
        logger.i('reading ... ${e.loaded! * 1.0 / e.total!}');
      })
      ..onLoadEnd.listen((e) async {
        _onFileRead(_reader.result);
      });
    _reader.readAsArrayBuffer(file);
  }

  dynamic _fileContent;

  _onFileRead(result) {
    setState(() {
      _fileContent = result;
    });
  }

  @override
  void initState() {
    super.initState();

    if (widget.file != null) _readFile(widget.file!);
  }

  @override
  Widget build(BuildContext context) {
    var child;
    if (null == widget.file) {
      child = Icon(Icons.terrain, size: 40);
    } else if (_fileContent == null) {
      child = CustomSpin(color: Theme.of(context).colorScheme.primary);
    } else {
      child = Image.memory(_fileContent);
    }
    return Container(
      alignment: Alignment.center,
      child: child,
    );
  }
}
