import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/chart/base/interactive_viewport.dart';
import 'package:flutter_smart_genome/components/setting_config_widget.dart';
import 'package:flutter_smart_genome/page/cell/cell_page/cell_page_logic.dart';
import 'package:flutter_smart_genome/page/cell/cell_scatter_chart/circular_progress_view.dart';
import 'package:flutter_smart_genome/page/cell/cell_scatter_chart/plot_status_view.dart';
import 'package:flutter_smart_genome/service/sgs_app_service.dart';
import 'package:flutter_smart_genome/widget/basic/custom_bot_widget.dart';
import 'package:flutter_smart_genome/widget/basic/error_code_icon.dart';
import 'package:flutter_smart_genome/widget/loading_widget.dart';
import 'package:flutter_smart_genome/widget/track/base/track_data.dart';
import 'package:get/get.dart';

import 'cell_plot_chart_label.dart';
import 'cell_scatter_chart_logic.dart';

class CellScatterChartView extends StatefulWidget {
  final bool showDataPop;
  final String tag;
  final Size size;
  final bool focused;

  const CellScatterChartView({
    Key? key,
    this.showDataPop = true,
    required this.tag,
    required this.size,
    required this.focused,
  }) : super(key: key);

  @override
  _CellScatterChartViewState createState() => _CellScatterChartViewState();
}

class _CellScatterChartViewState extends State<CellScatterChartView> {
  late CellScatterChartLogic logic;

  @override
  void initState() {
    super.initState();
    logic = CellScatterChartLogic.safe(widget.tag)!;
    logic.setViewportSize(widget.size);
    if (!logic.loading && logic.isEmpty) {
      logic.fetchData();
    }
  }

  @override
  void didUpdateWidget(covariant CellScatterChartView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!Get.isRegistered<CellScatterChartLogic>(tag: widget.tag)) {
      print('ops ! CellScatterChartLogic is unregistered!');
      // Get.put(CellScatterChartLogic(widget.size));
    }
    if (widget.size != oldWidget.size) {
      logic.setViewportSize(widget.size);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CellScatterChartLogic>(
      tag: widget.tag,
      init: logic,
      id: 'scatter-chart-root',
      autoRemove: false,
      builder: (logic) => LayoutBuilder(builder: (c, bc) => _builder(logic, c, bc)),
    );
  }

  GlobalKey _paintKey = GlobalKey();

  Widget _builder(CellScatterChartLogic logic, BuildContext context, BoxConstraints constraints) {
    // Size __size = constraints.biggest;
    // logic.setContainerSize(widget.size);
    // Size viewportSize = logic.splitMode ? Size(__size.width / 2 - 10, __size.height) : __size;
    Size viewportSize = widget.size; // logic.splitMode ? Size(__size.width / 2 - 10, __size.height) : __size;

    final state = logic.state;
    // print('size: ${viewportSize}, state: ${state.tag}, logic :${logic.tag}, ${widget.key}, ${logic.isSelectionMode}');

    if (logic.loading)
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Spacer(flex: 1),
          CircularProgressView(
            width: 60,
            height: 60,
            finish: logic.state.finishLoading,
            finishDuration: logic.finishDuration,
          ),
          SizedBox(height: 16),
          Text(
            state.loadingMessage ?? '   Loading cords...',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
          ),
          Spacer(flex: 2),
        ],
      );
    // return LoadingWidget(
    //   loadingState: LoadingState.loading,
    //   message: state.loadingMessage ?? 'Loading cords...',
    // );
    if (logic.error != null)
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 65),
        child: LoadingWidget(
          loadingState: LoadingState.error,
          icon: ErrorCodeIcon(code: logic.error!.code, size: Size.square(120)),
          message: logic.error!.message,
          simple: true,
          onErrorClick: (s) {
            logic.fetchData(refresh: true);
          },
        ),
      );
    return Stack(
      // alignment: Alignment.center,
      children: [
        GetBuilder<CellScatterChartLogic>(
            init: logic,
            id: 'label-layer',
            tag: widget.tag,
            autoRemove: false,
            builder: (logic) {
              if (!state.isValidSpatial) return Offstage();
              return ClipRect(
                child: Transform(
                  transform: state.transformationController.value,
                  child: Opacity(
                    opacity: logic.backgroundOpacity,
                    child: Image.network(
                      '${SgsAppService.get()!.staticBaseUrl}${state.spatial!.currentSlice.image}',
                      alignment: Alignment.topLeft,
                      width: viewportSize.width,
                      height: viewportSize.height,
                      fit: BoxFit.contain,
                      errorBuilder: (c, e, s) {
                        s.printError();
                        e.printError();
                        return Placeholder(color: Colors.red, strokeWidth: 1);
                      },
                    ),
                  ),
                ),
              );
            }),

        // plot 1 layer
        GetBuilder<CellScatterChartLogic>(
          init: logic,
          tag: widget.tag,
          id: 'canvas-layer',
          autoRemove: false,
          builder: (c) {
            if (state.loading || null == state.plotPainter) return SizedBox();
            return RepaintBoundary(
              child: ClipRect(
                child: CustomPaint(
                  key: _paintKey,
                  isComplex: true,
                  willChange: false,
                  size: viewportSize,
                  painter: state.plotPainter,
                ),
              ),
            );
          },
        ),

        // plot 1 font layer
        GetBuilder<CellScatterChartLogic>(
          init: logic,
          tag: widget.tag,
          id: 'label-layer',
          autoRemove: false,
          builder: (c) {
            return ClipRect(
              child: CustomPaint(
                size: viewportSize,
                child: logic.showLabel && state.groupLabelMap != null
                    ? CellPlotChartLabelWidget(
                        labelSize: logic.labelSize,
                        transformationController: state.transformationController,
                        labelMap: state.groupLabelMap!,
                        legendMap: logic.legendMap,
                        size: viewportSize,
                      )
                    : null,
                painter: state.scatterFontPainter,
              ),
            );
          },
        ),

        // plot 1 controller layer
        InteractiveViewport(
          key: state.viewPortKey,
          maxScale: state.groupDataMatrix?.maxScale ?? state.canvasController.maxUserScale,
          minScale: .25,
          selectionMode: logic.isSelectionMode,
          boundaryMargin: EdgeInsets.all(double.infinity),
          transformationController: state.transformationController,
          enableFling: false,
          onPointerHover: logic.pointHover,
          onInteractionStart: logic.interactionStart,
          onSelectionUpdate: logic.selectionUpdate,
          onSelectionEnd: logic.onSelectionEnd,
          onTap: logic.onTap,
          onPointerDown: logic.onPointerDown,
          onSecondaryTap: onContextTap,
          onInteractionUpdate: logic.onInteractionUpdate,
          onInteractionEnd: logic.onInteractionEnd,
          child: SizedBox(width: viewportSize.width, height: viewportSize.height),
        ),

        ///feature legend left
        GetBuilder<CellScatterChartLogic>(
          id: 'label-layer',
          tag: widget.tag,
          autoRemove: false,
          init: logic,
          builder: (c) => Positioned(
            bottom: 6,
            right: 8,
            child: Text(logic.state.info, style: Theme.of(context).textTheme.bodySmall),
          ),
        ),
        // msg layer
        Align(
          alignment: Alignment(0.0, -.25),
          child: GetBuilder<CellScatterChartLogic>(
            id: 'msg-layer',
            tag: widget.tag,
            init: logic,
            autoRemove: false,
            builder: (c) {
              if (logic.plotDrawState.visible) {
                return PlotStatusView(state: logic.plotDrawState);
              }
              return Offstage();
            },
          ),
        ),
      ],
    );
  }

  void onContextTap(PointerHoverEvent event) {
    var position = event.localPosition;
    RenderBox? renderObj = logic.state.viewPortKey.currentContext?.findRenderObject() as RenderBox?;
    var _position = renderObj?.localToGlobal(position) ?? position + Offset(20, 0);
    _showContextMenu(target: _position);
  }

  void _showContextMenu({required Offset target, bool secondary = false}) {
    showAttachedWidget(
      target: target,
      preferDirection: PreferDirection.bottomLeft,
      backgroundColor: Colors.transparent,
      offset: Offset(10, 0),
      attachedBuilder: (c) {
        return Material(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 6,
          color: Theme.of(context).dialogBackgroundColor,
          child: Container(
            constraints: BoxConstraints(minWidth: 200, maxWidth: 280),
            child: SettingListWidget(
              settings: logic.buildSettingItems(),
              onItemHover: (item, hover, rect) {
                if (item.key == 'slice') {
                  if (hover) _showSliceSelectorMenu(target: rect!.topRight);
                }
              },
              onItemTap: (item, rect) {
                BotToast.cleanAll();
                logic.onContextMenuItemTap(item);
              },
              onItemChanged: logic.onContextMenuItemChange,
            ),
          ),
        );
      },
    );
  }

  CancelFunc? _sliceFunc;

  void _showSliceSelectorMenu({required Offset target}) {
    if (_sliceFunc != null) return;
    _sliceFunc = showAttachedWidget(
      target: target,
      preferDirection: PreferDirection.rightTop,
      backgroundColor: Colors.transparent,
      onClose: () => _sliceFunc = null,
      attachedBuilder: (c) {
        var sliceItem = SettingItem.checkGroup(
            title: 'Change slice',
            value: (logic.state).spatial,
            options: (logic.state.mod?.spatials ?? []).map((s) => OptionItem('${s.key}', s)).toList(),
            valueBuilder: (value) {
              Spatial s = value;
              return Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  SizedBox(width: 10),
                  Image.network(
                    '${SgsAppService.get()!.staticBaseUrl}/${s.safeLowSlice.image}',
                    width: 50,
                    height: 50,
                    fit: BoxFit.contain,
                    errorBuilder: (c, e, s) {
                      return Icon(Icons.broken_image, size: 30);
                    },
                  ),
                  SizedBox(width: 10),
                  Expanded(child: Text('${s.key}', style: TextStyle(fontSize: 12), softWrap: true)),
                ],
              );
              return Text('${s.key}', style: TextStyle(fontSize: 12));
            });
        return Material(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          color: Theme.of(context).dialogBackgroundColor,
          elevation: 6,
          child: Container(
            constraints: BoxConstraints(minWidth: 200, maxWidth: 290),
            child: SettingListWidget(
              settings: [sliceItem],
              onItemChanged: (parentItem, item) {
                _sliceFunc = null;
                BotToast.cleanAll();
                logic.changeSlice(item.value);
              },
              // onItemTap: (item, rect) => logic.changeSlice(item.value, secondary: secondary),
            ),
          ),
        );
      },
    );
  }

  void _onContextMenuItemHover(SettingItem item, bool hover, Rect rect) {}

  @override
  void dispose() {
    // Get.delete<CellScatterChartLogic>();
    super.dispose();
  }
}
