import 'dart:convert';

import 'package:d4/d4.dart' as d4;
import 'package:dartx/dartx.dart' as dx;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/chart/graphic/plot/violin_plot.dart';
import 'package:flutter_smart_genome/extensions/d4_extension.dart';
import 'package:flutter_smart_genome/mixin/async_data_loader_mixin.dart';
import 'package:flutter_smart_genome/network/http_response.dart';
import 'package:flutter_smart_genome/service/single_cell_service.dart';
import 'package:flutter_smart_genome/widget/track/base/track_data.dart';

class AsyncViolinWidget extends StatefulWidget {
  final Track track;
  final String modId;
  final String feature;
  final String group;
  final int index;
  final dx.Function2<List<Map>?, List<Color>, void>? onTap;

  const AsyncViolinWidget({
    super.key,
    required this.track,
    required this.modId,
    required this.feature,
    required this.group,
    required this.index,
    this.onTap,
  });

  @override
  State<AsyncViolinWidget> createState() => _AsyncViolinWidgetState();
}

class _AsyncViolinWidgetState extends State<AsyncViolinWidget> with AsyncDataLoaderMixin<AsyncViolinWidget, List<Map>> {
  bool _hover = false;

  @override
  Duration get loadDelay => Duration(milliseconds: widget.index * 1000);

  @override
  void didUpdateWidget(covariant AsyncViolinWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.feature != oldWidget.feature) {
      reloadData();
    }
  }

  @override
  Widget buildContent() {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: ViolinPlot(
            data: data!,
            label: widget.feature,
            labelColor: Theme.of(context).textTheme.bodyMedium?.color,
            colors: generateColors(data!.length.clamp(2, 1000), d4.interpolateSinebow),
            dark: Theme.of(context).brightness == Brightness.dark,
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
                widget.onTap?.call(data, generateColors(data!.length.clamp(2, 1000), d4.interpolateSinebow));
              },
              icon: Icon(Icons.fullscreen)),
        ),
      ],
    );
  }

  @override
  Future<HttpResponseBean> loadData(CancelToken cancelToken) async {
    return loadFeatureExpressions(
      track: widget.track,
      matrixId: widget.modId,
      feature: widget.feature,
      group: widget.group,
      cancelToken: cancelToken,
    );
  }

  @override
  Future<List<Map>?> parseData(HttpResponseBean resp) async {
    List data = resp.body is String ? json.decode(resp.body) : resp.body;
    if (data.isEmpty) return null;

    // List data = body['data'];
    List header = ['cell', 'value', 'group'];
    List<Map> expressions = data.map<Map>((item) => Map.fromIterables(header, item)).toList();

    Map grouped = expressions.groupBy((item) => item['group']);
    var groups = grouped.keys.sortedBy((e) => '${e}'.length).thenBy((e) => e).toList();

    List<Map> result = [];
    for (var g in groups) {
      var parser = ViolinParser(grouped[g], valueMapper: (Map item) => item['value']);
      Map k = await parser.parse();
      result.add({
        'group': g,
        ...k,
      });
    }
    return result;
    // return groups.map<Map>((e)  {
    //   var parser = ViolinParser(grouped[e], valueMapper: (Map item) => item['value']);
    //   return {
    //     'group': e,
    //     ...parser.parse(),
    //   };
    // }).toList();
  }
}
