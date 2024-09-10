import 'dart:math';

import 'package:dio/dio.dart';
import 'package:d4/d4.dart' as d4;
import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/bean/feature_beans.dart';
import 'package:flutter_smart_genome/chart/graphic/plot/grouped_scatter_plot.dart';
import 'package:flutter_smart_genome/chart/graphic/plot/heatmap_plot.dart';
import 'package:flutter_smart_genome/chart/graphic/plot/motif_logo_plot.dart';
import 'package:flutter_smart_genome/chart/graphic/plot/violin_plot.dart';
import 'package:flutter_smart_genome/components/gene/gene_structure_widget.dart';
import 'package:flutter_smart_genome/d3/d3_mixin.dart';
import 'package:flutter_smart_genome/extensions/d4_extension.dart';
import 'package:flutter_smart_genome/network/http_response.dart';
import 'package:flutter_smart_genome/page/cell/cell_base.dart';
import 'package:flutter_smart_genome/page/cell/cell_data_table/async_image_view.dart';
import 'package:flutter_smart_genome/page/cell/cell_page/cell_page_logic.dart';
import 'package:flutter_smart_genome/page/cell/cell_plot_legend/category_legend_view.dart';
import 'package:flutter_smart_genome/page/cell/cell_plot_legend/linear_legend_view.dart';
import 'package:flutter_smart_genome/page/cell/cell_scatter_chart/cell_scatter_chart_state.dart';
import 'package:flutter_smart_genome/page/cell/peak_coverage/async_peak_coverage_chart.dart';
import 'package:flutter_smart_genome/page/compare/compare_logic.dart';
import 'package:flutter_smart_genome/page/compare/compare_window_manager.dart';
import 'package:flutter_smart_genome/page/compare/widget/async_heatmap_widget.dart';
import 'package:flutter_smart_genome/page/compare/widget/async_scatter_widget.dart';
import 'package:flutter_smart_genome/page/compare/widget/async_violin_widget.dart';
import 'package:flutter_smart_genome/page/compare/widget/motif_logo_widget.dart';
import 'package:flutter_smart_genome/page/compare/widget/server_plot_widget.dart';
import 'package:flutter_smart_genome/service/sgs_app_service.dart';
import 'package:flutter_smart_genome/service/sgs_config_service.dart';
import 'package:flutter_smart_genome/service/single_cell_service.dart';
import 'package:flutter_smart_genome/widget/basic/download_button.dart';
import 'package:flutter_smart_genome/widget/basic/downloadable_widget.dart';
import 'package:flutter_smart_genome/widget/track/base/track_data.dart';
import 'package:get/get.dart';

class CompareItemPlot extends StatelessWidget {
  final CompareElement element;
  final double? width;
  final double? height;
  final dynamic data;
  final int index;
  final ValueChanged<String>? onDelete;

  const CompareItemPlot({
    super.key,
    required this.element,
    required this.data,
    this.width,
    this.height,
    required this.index,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    switch (element.type) {
      case SCViewType.violin:
        return _violin();
      case SCViewType.coverage:
        return _coverage();
      case SCViewType.motif:
        return _motif();
      case SCViewType.feature:
        return _feature();
      case SCViewType.scatter:
        return _scatter();
      case SCViewType.heatmap:
        return _heatmap(heatmap: true);
      case SCViewType.dotplot:
        return _heatmap(heatmap: false);
        return _serverImage();
    }
  }

  Widget _scatter() {
    Map item = data;
    CompareElement ele = element;
    return SizedBox(
      width: width!,
      height: height!,
      child: AsyncScatterWidget(
        key: Key(item['feature'] ?? item['feature_name']),
        track: CellPageLogic.safe()!.track!,
        modId: ele.matrix,
        features: [item['feature'] ?? item['feature_name']],
        spatial: ele.spatial,
        group: ele.category,
        index: index,
        width: width!,
        height: height!,
        plotType: ele.plotType!,
        legendColor: ele.legendColor,
        pointSize: ele.pointSize,
        opacity: ele.opacity,
        onTap: (featurePlotMatrix, colors) {
          final modeName = CellPageLogic.safe()!.matrixList.firstWhereOrNull((m) => m.id == ele.matrix)?.name;
          final title = '${ele.type.name}-${modeName}-${ele.plotType}-${ele.category}-${item['feature'] ?? item['feature_name']}';
          CompareWindowManager.get().showDraggableWindow(
            title: title,
            group: 'big-${ele.type.name}',
            builder: (context, size, dragging, resizing, c) {
              return DownloadAbleWidget(
                child: Container(
                  color: Get.theme.scaffoldBackgroundColor,
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                  child: Stack(
                    children: [
                      AspectRatio(
                        aspectRatio: 1.0,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            if (null != ele.spatial)
                              Image.network(
                                '${SgsAppService.get()!.staticBaseUrl}${ele.spatial!.currentSlice.image}',
                                fit: BoxFit.contain,
                                alignment: Alignment.topLeft,
                              ),
                            // CustomPaint(
                            //   painter: SimpleScatterPlotPainter(featurePlotMatrix..changeViewSize(Rect.fromLTWH(0, 0, size.shortestSide, size.shortestSide)), pointSize: ele.pointSize),
                            //   isComplex: true,
                            //   willChange: false,
                            //   size: Size.square(size.shortestSide),
                            // ),
                            if (resizing || dragging)
                              Container(
                                child: Center(child: Text(resizing ? 'Resizing...' : 'Dragging...')),
                              )
                            else
                              GroupedScatterPlot(
                                data: featurePlotMatrix.groupedData!,
                                cordMax: featurePlotMatrix.domainScale.rangeMax,
                                label: item['feature'] ?? item['feature_name'],
                                labelColor: Get.textTheme.bodyMedium?.color,
                                colors: colors,
                                dotSize: ele.pointSize * 1.5,
                                labelSize: 14,
                                showAxis: true,
                                revertY: ele.spatial != null,
                                domainMapper: (value) => featurePlotMatrix.domainScale.call(value)!,
                              ),
                          ],
                        ),
                      ),
                      Align(
                        alignment: Alignment.topRight,
                        child: Container(
                          margin: EdgeInsets.only(right: 10, top: 10),
                          child: CategoryLegendView(
                            legends: featurePlotMatrix.legends!,
                            editable: false,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                fileName: title,
              );
            },
          );
        },
      ),
    );
  }

  Widget _feature() {
    var item = data;
    CompareElement ele = element;
    var name = item is Map ? item['feature_name'] : item?.name;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: Get.theme.dividerColor),
      ),
      // constraints: BoxConstraints(minHeight: 80),
      padding: EdgeInsets.symmetric(vertical: 6),
      width: width,
      // height: widget.height,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
            child: Row(
              children: [
                Expanded(child: Text('${name}', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16))),
                if (onDelete != null)
                  IconButton(
                    iconSize: 14,
                    splashRadius: 16,
                    constraints: BoxConstraints.tightFor(width: 30, height: 30),
                    icon: Icon(Icons.close),
                    onPressed: () => onDelete?.call('${name}'),
                    tooltip: 'Delete',
                  ),
              ],
            ),
          ),
          if (item is RangeFeature)
            Container(
              constraints: BoxConstraints.expand(height: 60),
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: GeneStructureWidget(feature: item),
            ),
        ],
      ),
    );
  }

  Widget _coverage() {
    Map item = data;
    CompareElement ele = element;
    var coverage_track = CellPageLogic.safe()!.track!.children!.firstWhereOrNull((t) => t.isGroupCoverage);
    return InkWell(
      onTap: () => _showPeakCoverageChart(item, coverage_track!),
      child: Container(
        width: width,
        height: height,
        child: AsyncPeakCoverageChart(
          compareElement: element,
          peak: item['feature_name'],
          // dataLoader: _loadPeakCoverage,
          track: coverage_track,
          matrix: ele.matrix,
          group: ele.category,
          showAxis: index == 0,
          //|| widget.axis == Axis.vertical,
          showLabel: true,
          brightness: Brightness.light,
          //todo
          // customMaxValue: _logic.scaleGrouped ? _logic.featureGroupCoverageMaxValue : null,
          // onGetMaxValue: _logic.scaleGrouped ? null : (v) => _logic.onGetFeatureMaxValue(item, v),
        ),
      ),
    );
  }

  Widget _violin() {
    Map item = data;
    CompareElement ele = element;
    return Container(
      width: width,
      height: height,
      child: AsyncViolinWidget(
        key: Key(item['feature'] ?? item['feature_name']),
        track: CellPageLogic.safe()!.track!,
        modId: ele.matrix,
        feature: item['feature'] ?? item['feature_name'],
        group: ele.category,
        index: index,
        onTap: (data, colors) {
          if (null == data) return;
          final modeName = CellPageLogic.safe()!.matrixList.firstWhereOrNull((m) => m.id == ele.matrix)?.name;
          final title = '${ele.type.name}-${modeName}-${ele.category}-${item['feature'] ?? item['feature_name']}';
          CompareWindowManager.get().showDraggableWindow(
            title: title,
            group: 'big-${ele.type.name}',
            builder: (context, size, dragging, resizing, c) {
              return DownloadAbleWidget(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  color: Theme.of(context).canvasColor,
                  child: ViolinPlot(
                    data: data,
                    label: item['feature'] ?? item['feature_name'],
                    labelColor: Get.textTheme.bodyMedium?.color,
                    colors: colors,
                    labelSize: 14,
                    dark: Get.isDarkMode,
                  ),
                ),
                fileName: title,
              );
            },
          );
        },
      ),
    );
  }

  Widget _heatmap({bool heatmap = true}) {
    CompareElement ele = element;
    return AsyncHeatmapWidget(
      key: Key('${data}'),
      track: CellPageLogic.safe()!.track!,
      modId: ele.matrix,
      features: data,
      group: ele.category,
      legendColor: ele.legendColor,
      heatmap: heatmap,
      transposed: ele.transposed,
      onTap: (heatmapData, _min, _max) {
        if (null == heatmapData) return;
        final modeName = CellPageLogic.safe()!.matrixList.firstWhereOrNull((m) => m.id == ele.matrix)?.name;
        final title = '${ele.type.name}-${modeName}-${ele.category}-${data}';
        CompareWindowManager.get().showDraggableWindow(
          title: title,
          group: 'big-${ele.type.name}',
          builder: (context, size, dragging, resizing, c) {
            var colors = generateColors(10, ele.legendColor.interpolate);
            Color? labelColor = Get.textTheme.bodyMedium?.color;
            return DownloadAbleWidget(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                color: Get.theme.canvasColor,
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    HeatmapPlot(
                      data: heatmapData,
                      accessorX: (data) => data['group'].toString(),
                      accessorY: (data) => data['feature'].toString(),
                      heatmap: heatmap,
                      labelColor: labelColor,
                      // label: '${data}',
                      labelSize: 14,
                      colors: colors,
                      transposed: ele.transposed,
                    ),
                    SizedBox(height: 20),
                    LinearLegendView(
                      color: ele.legendColor.copyWith(min: _min, max: _max),
                      width: 140,
                      height: 50,
                      axis: Axis.horizontal,
                    )
                  ],
                ),
              ),
              fileName: title,
            );
          },
        );
      },
    );
  }

  Widget _motif() {
    Map item = data;
    CompareElement ele = element;
    return Container(
      width: width,
      height: height,
      child: MotifLogoWidget(
        key: Key(item['feature'] ?? item['feature_name']),
        track: CellPageLogic.safe()!.track!,
        modId: ele.matrix,
        feature: item['feature'] ?? item['feature_name'],
        onTap: (data) {
          if (null == data) return;
          final modeName = CellPageLogic.safe()!.matrixList.firstWhereOrNull((m) => m.id == ele.matrix)?.name;
          final title = '${ele.type.name}-${modeName}-${ele.category}-${item['feature'] ?? item['feature_name']}';
          CompareWindowManager.get().showDraggableWindow(
            title: title,
            group: 'big-${ele.type.name}',
            builder: (context, size, dragging, resizing, c) {
              return DownloadAbleWidget(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  color: Get.theme.canvasColor,
                  child: MotifLogoPlot(
                    data: data,
                    label: item['feature'] ?? item['feature_name'],
                    labelSize: 14,
                    labelColor: Get.theme.textTheme.bodyMedium?.color,
                    dark: Get.isDarkMode,
                  ),
                ),
                fileName: title,
              );
            },
          );
        },
      ),
    );
  }

  Widget _serverImage() {
    return ServerPlotWidget(
      track: CellPageLogic.safe()!.track!,
      element: element,
      features: data,
      onTap: (data) {
        final modeName = CellPageLogic.safe()!.matrixList.firstWhereOrNull((m) => m.id == element.matrix)?.name;
        final title = '${element.type.name}-${modeName}-${element.category}-$data';
        var image = '${SgsAppService.get()!.staticBaseUrl}${data['image_url']}';
        showBigImage(title, image);
      },
    );
  }

  Widget _image() {
    Map item = data;
    CompareElement ele = element;
    String imageId = item['image_id'];
    if (ele.type == SCViewType.heatmap || ele.type == SCViewType.dotplot) item['status'] = 'done';
    return Container(
      width: width,
      height: height,
      child: AsyncImageView(
        imageId: imageId,
        imageInfo: SgsConfigService.get()!.getImage(imageId) ?? item,
        baseUrl: SgsAppService.get()!.staticBaseUrl,
        autoReload: true,
        thumb: false,
        onTap: ele.type == SCViewType.heatmap || ele.type == SCViewType.dotplot ? null : (image) => showBigImage(item['feature_name'], image),
        onLoadImage: _loadImage,
      ),
    );
  }

  _showPeakCoverageChart(Map rowData, Track coverage_track) {
    CompareWindowManager.get().showDraggableWindow(
      title: rowData['feature_name'],
      builder: (context, size, dragging, resizing, c) {
        return DownloadAbleWidget(
          fileName: '${rowData['feature_name']}}',
          child: Container(
            child: AsyncPeakCoverageChart(
              key: Key('${element.toString()}'),
              compareElement: element,
              // start: rowData['peak_start'],
              // end: rowData['peak_end'],
              peak: rowData['peak_name'],
              // chrName: rowData['chr_name'],
              // dataLoader: _loadPeakCoverage,
              track: coverage_track,
              showLabel: true,
              showAxis: true,
              brightness: Brightness.light,
            ),
          ),
        );
      },
    );
  }

  void showBigImage(String title, String image) {
    CompareWindowManager.get().showDraggableWindow(
      title: title,
      builder: (context, size, dragging, resizing, c) {
        return Stack(
          fit: StackFit.expand,
          children: [
            Image.network(image),
            Align(
              alignment: Alignment.topRight,
              child: DownloadButton(url: image, name: title),
            ),
          ],
        );
      },
    );
  }

  Future<HttpResponseBean<List<Map>>> _loadPeakCoverage(String feature) async {
    var site = SgsAppService.get()!.site!;
    var cellPageLogic = CellPageLogic.safe()!;

    HttpResponseBean featureLocationResp = await searchGene(host: site.url, speciesId: site.currentSpeciesId!, feature: feature, track: cellPageLogic.track!);
    if (featureLocationResp.success) {
      var body = featureLocationResp.body;
      var chr = SgsAppService.get()!.chromosomes?.firstWhere((c) => c.id == body['chr_id'], orElse: null);
      if (body['start'] != null && body['end'] != null && chr != null) {
        return loadMarkerPeakGroupCoverage(
          host: site.url,
          track: cellPageLogic.track!,
          matrixId: element.matrix,
          groupName: element.category,
          chrName: chr.chrName,
          featureName: feature,
          start: body['start'],
          end: body['end'],
        );
      }
    }
    return HttpResponseBean<List<Map>>.error("load feature error");
  }

  Future<HttpResponseBean> _loadImage(String id, CancelToken? cancelToken) {
    var site = SgsAppService.get()!.site!;
    var type = element.plotType;
    var matrixId = element.matrix;
    return loadFeatureImage(
      imageId: id,
      plotType: type,
      host: site.url,
      matrixId: matrixId,
      cancelToken: cancelToken,
    );
  }
}
