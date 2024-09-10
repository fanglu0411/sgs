import 'dart:math' show Random;

import 'package:dio/dio.dart';
import 'package:flutter_smart_genome/widget/basic/custom_spin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/network/http_response.dart';
import 'package:flutter_smart_genome/service/sgs_config_service.dart';
import 'package:flutter_smart_genome/util/debouncer.dart';

typedef OnLoadImage = Future<HttpResponseBean> Function(String id, CancelToken? cancelToken);

class AsyncImageView extends StatefulWidget {
  final String imageId;
  final String? baseUrl;
  final ValueChanged<String>? onTap;
  final Map? imageInfo;
  final bool autoReload;
  final bool thumb;
  final OnLoadImage onLoadImage;

  const AsyncImageView({
    Key? key,
    required this.imageId,
    this.onTap,
    this.baseUrl,
    this.imageInfo,
    this.autoReload = true,
    this.thumb = true,
    required this.onLoadImage,
  }) : super(key: key);

  @override
  _AsyncImageViewState createState() => _AsyncImageViewState();
}

class _AsyncImageViewState extends State<AsyncImageView> {
  // String _image;
  // String _thumb;

  Map? _info;
  CancelToken? _cancelToken;
  Random? _random;
  bool _loading = false;
  Debounce? _debounce;

  @override
  void initState() {
    super.initState();
    _random = Random();
    _info = widget.imageInfo;
    _debounce = Debounce(milliseconds: 1000);
    _load(widget.imageId);
  }

  @override
  void didUpdateWidget(AsyncImageView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _info = widget.imageInfo;
    _checkStatus();
  }

  _load(String id) async {
    if (!mounted || _loading) return;
    if (null != _info && _info!['status'] == 'done') return;

    _loading = true;
    _cancelToken = CancelToken();
    var resp = await widget.onLoadImage.call(id, _cancelToken);
    Map body = resp.body;
    if (resp.success) {
      _info = body;
      if (_info!['status'] == 'done') {
        SgsConfigService.get()?.cacheImage(widget.imageId, _info!);
      }
    }
    if (resp.success) {
      // _image = '${widget.baseUrl}${body['image_path']}';
      // _thumb = '${widget.baseUrl}${body['thumb_image_path']}';
    }
    // print('imageId:${id}');
    // print('image  :${_thumb}');
    if (mounted) setState(() {});
    _loading = false;
    _checkStatus();
  }

  void _checkStatus() {
    if (_info == null || _info!['status'] != 'done') {
      if (!widget.autoReload) return;
      _debounce!.run(() {
        if (_info == null || _info!['status'] != 'done') {
          _load(widget.imageId);
        }
      }, milliseconds: (_random!.nextDouble() * 500 + 5000).toInt());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (null == _info || _info!['status'] != 'done')
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text('Drawing...', textScaleFactor: .85),
        ),
      );
    String? _image = '${widget.baseUrl}${_info!['image_url']}';
    String? _thumb = '${widget.baseUrl}${_info!['thumb_image_url']}';
    return InkWell(
      onTap: () => widget.onTap?.call(_image!),
      child: Image.network(
        widget.thumb ? _thumb : _image,
        fit: BoxFit.contain,
        loadingBuilder: (c, child, p) {
          if (p == null) return child;
          return Center(child: CustomSpin(color: Theme.of(context).colorScheme.primary));
        },
        errorBuilder: (c, d, e) {
          _image = null;
          _thumb = null;
          return Center(child: Icon(Icons.broken_image, size: 40));
        },
      ),
    );
  }

  @override
  void dispose() {
    _cancelToken?.cancel('image disposed');
    super.dispose();
  }
}
