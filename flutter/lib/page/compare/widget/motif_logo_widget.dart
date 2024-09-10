import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/chart/graphic/plot/motif_logo_plot.dart';
import 'package:flutter_smart_genome/mixin/async_data_loader_mixin.dart';
import 'package:flutter_smart_genome/network/http_response.dart';
import 'package:flutter_smart_genome/service/single_cell_service.dart';
import 'package:flutter_smart_genome/widget/track/base/track_data.dart';

class MotifLogoWidget extends StatefulWidget {
  final Track track;
  final String modId;
  final String feature;
  final ValueChanged<List<Map>?>? onTap;

  const MotifLogoWidget({super.key, required this.track, required this.modId, required this.feature, this.onTap});

  @override
  State<MotifLogoWidget> createState() => _MotifLogoWidgetState();
}

class _MotifLogoWidgetState extends State<MotifLogoWidget> with AsyncDataLoaderMixin<MotifLogoWidget, List<Map>> {
  @override
  Widget build(BuildContext context) {
    return super.build(context);
  }

  String get emptyMessage => 'No motif data';

  bool _hover = false;

  @override
  Widget buildContent() {
    bool dark = Theme.of(context).brightness == Brightness.dark;
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: MotifLogoPlot(
            data: data!,
            label: widget.feature,
            dark: dark,
            labelColor: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
        Positioned(
          right: 6,
          top: 6,
          child: IconButton(
              padding: EdgeInsets.zero,
              constraints: BoxConstraints.tightFor(width: 30, height: 30),
              iconSize: 20,
              onPressed: () {
                widget.onTap?.call(data);
              },
              icon: Icon(Icons.fullscreen)),
        ),
      ],
    );
  }

  @override
  Future<HttpResponseBean> loadData(CancelToken cancelToken) async {
    return loadMotifLogo(
      track: widget.track,
      matrixId: widget.modId,
      feature: widget.feature,
      cancelToken: cancelToken,
    );
  }

  @override
  Future<List<Map>?> parseData(HttpResponseBean resp) async {
    Map body = resp.body is String ? json.decode(resp.body) : resp.body;
    if (body.isEmpty) return null;

    List data = body['motif_logo'];
    List header = ['index', 'type', 'value', 'color'];
    List<Map> motifLogo = data.map<Map>((item) => Map.fromIterables(header, item)).toList();
    return motifLogo;
  }
}
