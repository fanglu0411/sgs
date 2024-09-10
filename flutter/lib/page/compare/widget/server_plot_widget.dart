import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_smart_genome/widget/basic/custom_spin.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/mixin/async_data_loader_mixin.dart';
import 'package:flutter_smart_genome/network/http_response.dart';
import 'package:flutter_smart_genome/page/compare/compare_logic.dart';
import 'package:flutter_smart_genome/service/sgs_app_service.dart';
import 'package:flutter_smart_genome/service/single_cell_service.dart';
import 'package:flutter_smart_genome/widget/track/base/track_data.dart';

class ServerPlotWidget extends StatefulWidget {
  final Track track;
  final CompareElement element;
  final List features;
  final ValueChanged<Map>? onTap;

  const ServerPlotWidget({super.key, required this.track, required this.element, required this.features, this.onTap});

  @override
  State<ServerPlotWidget> createState() => _AsyncViolinWidgetState();
}

class _AsyncViolinWidgetState extends State<ServerPlotWidget> with AsyncDataLoaderMixin<ServerPlotWidget, Map> {
  bool _hover = false;

  @override
  void didUpdateWidget(covariant ServerPlotWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(widget.features, oldWidget.features)) {
      reloadData();
    }
  }

  @override
  Widget buildContent() {
    return Stack(
      children: [
        Image.network(
          '${SgsAppService.get()!.staticBaseUrl}${data!['image_url']}',
          loadingBuilder: (c, child, p) {
            if (p == null) return child;
            return Center(child: CustomSpin(color: Theme.of(context).colorScheme.primary));
          },
          errorBuilder: (c, e, s) {
            print(e);
            return Center(child: Icon(Icons.broken_image, size: 36));
          },
        ),
        Positioned(
          right: 6,
          top: 6,
          child: IconButton(
              padding: EdgeInsets.zero,
              constraints: BoxConstraints.tightFor(width: 30, height: 30),
              iconSize: 20,
              onPressed: () {
                widget.onTap?.call(data!);
              },
              icon: Icon(Icons.fullscreen)),
        ),
      ],
    );
  }

  @override
  Future<HttpResponseBean> loadData(CancelToken cancelToken) async {
    final site = SgsAppService.get()!.site!;
    return loadCompareFeatureImages(
      host: site.url,
      scId: widget.track.scId!,
      genes: widget.features,
      matrix: widget.element.matrix,
      group: widget.element.category,
      plotType: widget.element.plotType,
      chartType: widget.element.type.name,
      cancelToken: cancelToken,
    );
  }

  @override
  Future<Map?> parseData(HttpResponseBean resp) async {
    Map body = resp.body is String ? json.decode(resp.body) : resp.body;
    if (body.isEmpty) return null;
    return body;
  }
}
