import 'dart:convert';

import 'package:d4/d4.dart' as d4;
import 'package:dartx/dartx.dart' as dx;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/chart/graphic/plot/heatmap_plot.dart';
import 'package:flutter_smart_genome/chart/graphic/plot/violin_plot.dart';
import 'package:flutter_smart_genome/extensions/d4_extension.dart';
import 'package:flutter_smart_genome/mixin/async_data_loader_mixin.dart';
import 'package:flutter_smart_genome/network/http_response.dart';
import 'package:flutter_smart_genome/page/cell/cell_page/cell_page_logic.dart';
import 'package:flutter_smart_genome/page/cell/cell_plot_legend/linear_legend_view.dart';
import 'package:flutter_smart_genome/page/cell/cell_scatter_chart/legend_colors.dart';
import 'package:flutter_smart_genome/service/single_cell_service.dart';
import 'package:flutter_smart_genome/widget/track/base/track_data.dart';

class AsyncHeatmapWidget extends StatefulWidget {
  final Track track;
  final String modId;
  final List features;
  final String group;
  final LegendColor legendColor;
  final dx.Function3<List<Map>, double, double, void>? onTap;
  final bool heatmap;
  final bool transposed;

  const AsyncHeatmapWidget({
    super.key,
    required this.track,
    required this.modId,
    required this.features,
    required this.group,
    required this.legendColor,
    this.heatmap = true,
    this.transposed = false,
    this.onTap,
  });

  @override
  State<AsyncHeatmapWidget> createState() => _AsyncViolinWidgetState();
}

class _AsyncViolinWidgetState extends State<AsyncHeatmapWidget> with AsyncDataLoaderMixin<AsyncHeatmapWidget, List<Map>> {
  bool _hover = false;
  double? _min = 0, _max = 0;

  @override
  void didUpdateWidget(covariant AsyncHeatmapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(widget.features, oldWidget.features)) {
      reloadData();
    }
  }

  @override
  Widget buildContent() {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: HeatmapPlot(
                  data: data!,
                  heatmap: widget.heatmap,
                  labelColor: Theme.of(context).textTheme.bodyMedium?.color,
                  // label: widget.features.join(','),
                  colors: generateColors(10, widget.legendColor.interpolate),
                  accessorX: (data) => data['group'].toString(),
                  accessorY: (data) => data['feature'].toString(),
                  transposed: widget.transposed,
                ),
              ),
              SizedBox(height: 20),
              LinearLegendView(
                color: widget.legendColor.copyWith(min: _min, max: _max),
                width: 140,
                height: 50,
                axis: Axis.horizontal,
              )
            ],
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
                if (data != null) widget.onTap?.call(data!, _min!, _max!);
              },
              icon: Icon(Icons.fullscreen)),
        ),
      ],
    );
  }

  @override
  Future<HttpResponseBean> loadData(CancelToken cancelToken) async {
    return loadFeatureAvgExpressionInGroup(
      track: widget.track,
      matrixId: widget.modId,
      features: widget.features,
      group: widget.group,
      cancelToken: cancelToken,
    );
  }

  @override
  Future<List<Map>?> parseData(HttpResponseBean resp) async {
    Map data = resp.body is String ? json.decode(resp.body) : resp.body;
    if (data.isEmpty) return null;
    List<Map> expressions = data.keys
        .map<List<Map>>((feature) {
          Map expressionMap = data[feature];
          return expressionMap.keys
              .map((g) => ({
                    'feature': feature,
                    'group': g,
                    'value': expressionMap[g],
                  }))
              .toList();
        })
        .flatten()
        .toList();
    _min = 0.0; // expressions.minBy((e) => e['value'])?['value'] ?? 0;
    _max = expressions.maxBy((e) => e['value'])?['value'] ?? 1.0;
    return expressions;
  }
}
