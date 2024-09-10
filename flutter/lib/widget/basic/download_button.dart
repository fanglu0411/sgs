
import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/network/api/simple_request.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as _path;

class DownloadButton extends StatefulWidget {
  final String url;
  final String? savePath;
  final String? name;
  const DownloadButton({Key? key, required this.url, this.savePath, this.name}) : super(key: key);

  @override
  State<DownloadButton> createState() => _DownloadButtonState();
}

class _DownloadButtonState extends State<DownloadButton> {
  double? _progress;

  @override
  Widget build(BuildContext context) {
    if (_progress != null) {
      return Container(
        width: 30,
        height: 30,
        margin: EdgeInsets.all(10),
        child: _progress == 1.0 ? Icon(Icons.download_done, size: 30) : CircularProgressIndicator(value: _progress),
      );
    }
    return IconButton(
      onPressed: () => _downloadImage(widget.url),
      icon: Icon(Icons.download),
      tooltip: 'Download',
    );
  }

  void _downloadImage(String url) async {
    String name = _path.basename(url);
    var _name;
    if (widget.name != null) {
      _name = '${widget.name}${_path.extension(name)}';
    } else {
      _name = name;
    }

    var dir = await getDownloadsDirectory();
    var savePath = widget.savePath ?? _path.join(dir!.path, _name);
    download(
      url: url,
      savePath: savePath,
      progress: (int count, int total) {
        setState(() {
          _progress = (count / total);
        });
      },
    );
  }
}