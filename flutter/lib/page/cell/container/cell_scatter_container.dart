import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/page/cell/cell_data_table/cell_data_table_view.dart';
import 'package:flutter_smart_genome/page/cell/cell_data_table/pop_drag_widget.dart';
import 'package:flutter_smart_genome/page/cell/cell_page/cell_layers.dart';
import 'package:flutter_smart_genome/page/cell/cell_page/cell_page_logic.dart';
import 'package:flutter_smart_genome/page/cell/cell_plot_legend/cell_plot_legend_view.dart';
import 'package:flutter_smart_genome/page/cell/cell_scatter_chart/cell_scatter_chart_view.dart';
import 'package:flutter_smart_genome/page/cell/cell_scatter_chart/legend_colors.dart';
import 'package:flutter_smart_genome/page/cell/cell_tool_bar/cell_tool_bar_view.dart';
import 'package:flutter_smart_genome/page/cell/cell_tool_bar/left_tool_bar.dart';
import 'package:flutter_smart_genome/util/debouncer.dart';
import 'package:get/get.dart';

class CellScatterContainer extends StatefulWidget {
  final bool showDataPop;

  const CellScatterContainer({super.key, this.showDataPop = true});

  @override
  State<CellScatterContainer> createState() => _CellScatterContainerState();
}

class _CellScatterContainerState extends State<CellScatterContainer> {
  Key _scatter1Key = Key('scatter1');
  Key _scatter2Key = Key('scatter2');

  Key _dataTable1Key = Key('data-table-1');
  Key _dataTable2Key = Key('data-table-2');

  late Debounce _resizeDebounce;

  Size? _containerSize, _viewportSize;
  bool _resizing = false;

  @override
  void initState() {
    super.initState();
    _resizeDebounce = Debounce(milliseconds: 100);
  }

  void debounceSetViewportSize(Size size) {
    _resizing = true;
    _resizeDebounce.run(() => updateSize(size));
  }

  void updateSize(Size size) {
    setState(() {
      _containerSize = size;
      _resizing = false;
      CellPageLogic pageLogic = CellPageLogic.safe()!;
      Size viewportSize = pageLogic.splitMode ? Size(_containerSize!.width / 2, _containerSize!.height) : _containerSize!;
      CellPageLogic.safe()?.onChartResize(viewportSize);
    });
  }

  Widget _builder(BuildContext context, BoxConstraints constraints) {
    CellPageLogic pageLogic = CellPageLogic.safe()!;
    Size __size = constraints.biggest;
    if (_containerSize != null && _containerSize != __size) {
      debounceSetViewportSize(__size);
      return Container(child: Text('Resizing...', style: Theme.of(context).textTheme.displaySmall), alignment: Alignment.center);
    }
    _containerSize = __size;
    Size viewportSize = pageLogic.splitMode ? Size(__size.width / 2, __size.height) : __size;

    return RepaintBoundary(
      key: pageLogic.chartRepaintBoundaryKey,
      child: Container(
        color: Theme.of(context).canvasColor,
        child: Stack(
          children: [
            GetBuilder<CellPageLogic>(
                id: CellLayer.controlBar,
                autoRemove: false,
                builder: (c) {
                  if (!pageLogic.screenshotMode && pageLogic.splitMode && pageLogic.currentChartTag == CellPageLogic.CHART_TAG_1)
                    return Align(
                        alignment: Alignment.centerLeft,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            border: Border.all(color: Theme.of(context).colorScheme.primary, width: 1.2),
                          ),
                          child: SizedBox(width: viewportSize.width, height: viewportSize.height),
                        ));
                  return Offstage();
                }),

            GetBuilder<CellPageLogic>(
                id: CellLayer.controlBar,
                autoRemove: false,
                builder: (c) {
                  if (!pageLogic.screenshotMode && pageLogic.splitMode && pageLogic.currentChartTag == CellPageLogic.CHART_TAG_2)
                    return Align(
                        alignment: Alignment.centerRight,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            border: Border.all(color: Theme.of(context).colorScheme.primary, width: 1.2),
                          ),
                          child: SizedBox(width: viewportSize.width, height: viewportSize.height),
                        ));
                  return Offstage();
                }),

            GetBuilder<CellPageLogic>(
              id: CellLayer.scatterLayer,
              autoRemove: false,
              builder: (c) {
                return Align(
                  alignment: pageLogic.splitMode ? Alignment.centerLeft : Alignment.center,
                  child: SizedBox(
                    width: viewportSize.width,
                    height: viewportSize.height,
                    child: CellScatterChartView(
                      key: _scatter1Key,
                      tag: CellPageLogic.CHART_TAG_1,
                      size: viewportSize,
                      focused: pageLogic.currentChartTag == CellPageLogic.CHART_TAG_1,
                    ),
                  ),
                );
              },
            ),

            GetBuilder<CellPageLogic>(
              id: CellLayer.scatterLayer,
              autoRemove: false,
              builder: (c) {
                if (!pageLogic.splitMode) return Offstage();
                return Align(
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                    width: viewportSize.width,
                    height: viewportSize.height,
                    child: CellScatterChartView(
                      key: _scatter2Key,
                      tag: CellPageLogic.CHART_TAG_2,
                      size: viewportSize,
                      focused: pageLogic.currentChartTag == CellPageLogic.CHART_TAG_2,
                    ),
                  ),
                );
              },
            ),

            GetBuilder<CellPageLogic>(
                id: CellLayer.modeLayer,
                autoRemove: false,
                builder: (c) {
                  if (pageLogic.screenshotMode) return Offstage();
                  return CellToolBarView();
                }),
            // top selections

            // left bar
            GetBuilder<CellPageLogic>(
              id: CellLayer.controlBar,
              autoRemove: false,
              builder: (c) {
                if (pageLogic.screenshotMode || pageLogic.allFontLayerHide) return Offstage();
                return Positioned(top: 60, left: 10, child: LeftToolbar());
              },
            ),

            // legend layer
            GetBuilder<CellPageLogic>(
                init: pageLogic,
                id: CellLayer.legendLayer,
                autoRemove: false,
                builder: (logic) {
                  if (pageLogic.allFontLayerHide || !logic.showLegend) return Offstage();
                  final noneZeroLegends = logic.currentChartLogic.noneZeroLegends;
                  return Positioned(
                    right: 10,
                    top: 45,
                    height: (noneZeroLegends.length * 24 + 80.0).clamp(40.0, viewportSize.height - 80),
                    // bottom: logic.showDataTable ? min(logic.dataTableHeight + 20, 600) : 30,
                    child: Material(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      child: CellPlotLegendView(
                        legendColors: logic.currentChartLogic.state.featureDataMatrix == null ? legendColors : expressionLegendColors,
                        legends: noneZeroLegends,
                        onCheckedChange: logic.currentChartLogic.onToggleLegend,
                        onSelectionChange: logic.currentChartLogic.onLegendSelectionChange,
                        onColorChange: logic.onColorChange,
                        onColorSchemaChange: logic.onColorSchemaChange,
                        editable: logic.currentChartLogic.state.featureDataMatrix == null,
                        showColorBy: logic.currentChartLogic.state.featureDataMatrix == null,
                      ),
                    ),
                  );
                }),

            //data table
            if (widget.showDataPop)
              GetBuilder<CellPageLogic>(
                id: CellLayer.dataTableLayer,
                autoRemove: false,
                builder: (c) {
                  if (pageLogic.screenshotMode || pageLogic.allFontLayerHide || !(pageLogic.showDataTable && widget.showDataPop)) return Offstage();
                  return Positioned(
                    bottom: 0,
                    left: 60,
                    right: 0,
                    child: PopDragWidget(
                      minHeight: 200,
                      maxHeight: MediaQuery.of(context).size.height - 120,
                      height: pageLogic.dataTableHeight,
                      onHeightChange: pageLogic.saveDataTableHeight,
                      child: CellDataTableView(
                        key: pageLogic.currentChartTag == CellPageLogic.CHART_TAG_1 ? _dataTable1Key : _dataTable2Key,
                        tag: pageLogic.currentChartTag,
                        pop: true,
                        onHide: pageLogic.toggleDataTable,
                      ),
                    ),
                  );
                },
              ),

            if (widget.showDataPop)
              GetBuilder<CellPageLogic>(
                id: CellLayer.controlBar,
                autoRemove: false,
                builder: (c) {
                  if (pageLogic.screenshotMode || pageLogic.allFontLayerHide || !widget.showDataPop) return Offstage();
                  return Positioned(
                      bottom: 8,
                      left: 10,
                      child: IconButton(
                        // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        isSelected: pageLogic.showDataTable,
                        onPressed: pageLogic.toggleDataTable,
                        icon: Icon(Icons.table_chart_outlined),
                        selectedIcon: Icon(Icons.table_chart, color: Get.theme.primaryColor),
                        tooltip: 'Toggle Data Table',
                        padding: EdgeInsets.zero,
                        iconSize: 18,
                        constraints: BoxConstraints.tightFor(width: 32, height: 32),
                        splashRadius: 20,
                        style: IconButton.styleFrom(
                          backgroundColor: pageLogic.showDataTable ? Get.theme.colorScheme.primaryContainer : Get.theme.colorScheme.secondaryContainer,
                        ),
                      )
                      // .withBubble(text: pageLogic.selectedFeatureCount > 0 ? '' : null, right: 0, top: 0, radius: 5),
                      );
                },
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: _builder);
  }

  @override
  void dispose() {
    super.dispose();
    _resizeDebounce.dispose();
  }
}
