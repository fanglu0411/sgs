import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:flutter_smart_genome/page/cell/cell_page/cell_layers.dart';
import 'package:flutter_smart_genome/page/cell/cell_page/cell_page_logic.dart';
import 'package:flutter_smart_genome/page/cell/cell_tool_bar/slider_widget.dart';
import 'package:flutter_smart_genome/widget/basic/custom_bot_widget.dart';
import 'package:flutter_smart_genome/widget/toggle_button_group.dart';
import 'package:get/get.dart';

class LeftToolbar extends GetView<CellPageLogic> {
  const LeftToolbar({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CellPageLogic>(
      init: controller,
      autoRemove: false,
      id: CellLayer.controlBar,
      builder: _builder,
    );
  }

  Widget get divider => SizedBox(width: 32, child: Divider(thickness: 1, color: Get.theme.dividerColor, height: 1));

  Widget _builder(CellPageLogic logic) {
    double toolbarButtonWidth = 32;
    double splashRadius = 18;
    BoxConstraints _buttonConstraints = BoxConstraints.tightFor(width: toolbarButtonWidth, height: toolbarButtonWidth);
    Color priColor = Get.theme.colorScheme.primary;
    ColorScheme colorScheme = Get.theme.colorScheme;
    // Widget divider = SizedBox(width: toolbarButtonWidth, child: Divider(thickness: 1.5, color: Get.theme.dividerColor, height: 1.5));
    return Material(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        child: Wrap(
          // mainAxisSize: MainAxisSize.min,
          direction: Axis.vertical,
          spacing: 6,
          children: [
            if (!logic.allFontLayerHide)
              ToggleButtonGroup(
                constraints: BoxConstraints.tightFor(height: toolbarButtonWidth),
                borderRadius: BorderRadius.circular(20),
                direction: Axis.vertical,
                selectedIndex: logic.isSelectionMode ? 1 : 0,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6),
                    child: Icon(Icons.pan_tool, size: 16, color: logic.isSelectionMode ? null : priColor),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6),
                    child: Icon(FontAwesome.pencil_square_o, size: 16, color: logic.isSelectionMode ? priColor : null),
                  ),
                ],
                onChange: (i) {
                  logic.setSelectionMode(i == 1);
                },
              ),
            SizedBox(height: 4),

            IconButton(
              onPressed: logic.zoomIn,
              icon: Icon(MaterialCommunityIcons.plus),
              padding: EdgeInsets.zero,
              iconSize: 20,
              constraints: _buttonConstraints,
              splashRadius: splashRadius,
              tooltip: 'Zoom in',
              style: IconButton.styleFrom(
                backgroundColor: colorScheme.secondaryContainer,
              ),
            ),
            // RotatedBox(
            //   quarterTurns: -1,
            //   child: SizedBox(
            //     width: 120,
            //     height: toolbarButtonWidth,
            //     child: Slider.adaptive(
            //       value: logic.manualScale.clamp(.1, 100),
            //       min: .1,
            //       max: 100,
            //       onChanged: logic.updateManualScale,
            //       label: '${logic.manualScale}',
            //     ),
            //   ),
            // ),
            IconButton(
              onPressed: logic.zoomOut,
              icon: Icon(MaterialCommunityIcons.minus),
              padding: EdgeInsets.zero,
              iconSize: 20,
              constraints: _buttonConstraints,
              splashRadius: splashRadius,
              tooltip: 'Zoom out',
              style: IconButton.styleFrom(
                backgroundColor: colorScheme.secondaryContainer,
              ),
            ),
            divider,
            // IconButton.outlined(
            //   icon: Icon(MaterialCommunityIcons.axis),
            //   iconSize: 20,
            //   isSelected: logic.showAxis(),
            //   onPressed: () => logic.toggleAxis(null),
            //   selectedIcon: Icon(MaterialCommunityIcons.axis, color: Get.theme.primaryColor),
            //   tooltip: 'Toggle Axis',
            //   padding: EdgeInsets.zero,
            //   constraints: _buttonConstraints,
            //   splashRadius: splashRadius,
            //   style: IconButton.styleFrom(
            //     // shape: RoundedRectangleBorder(),
            //     backgroundColor: logic.showAxis() ? Get.theme.focusColor : Get.theme.buttonTheme.colorScheme!.background,
            //   ),
            // ),
            // divider,
            IconButton(
              icon: Icon(MaterialCommunityIcons.label),
              iconSize: 18,
              isSelected: logic.showLabel,
              onPressed: logic.toggleLabel,
              selectedIcon: Icon(MaterialCommunityIcons.label),
              tooltip: 'Toggle Label',
              padding: EdgeInsets.zero,
              constraints: _buttonConstraints,
              splashRadius: splashRadius,
              style: IconButton.styleFrom(
                // shape: RoundedRectangleBorder(),
                backgroundColor: logic.showLabel ? colorScheme.primaryContainer : colorScheme.secondaryContainer,
              ),
            ),
            // divider,
            // IconButton.outlined(
            //   icon: Icon(Icons.legend_toggle),
            //   isSelected: logic.showLegend(),
            //   iconSize: 20,
            //   onPressed: () => logic.toggleLegend(null),
            //   selectedIcon: Icon(Icons.legend_toggle, color: Get.theme.primaryColor),
            //   tooltip: 'Toggle Legend',
            //   padding: EdgeInsets.zero,
            //   constraints: _buttonConstraints,
            //   splashRadius: splashRadius,
            //   style: IconButton.styleFrom(
            //     // shape: RoundedRectangleBorder(),
            //     backgroundColor: logic.showLegend() ? Get.theme.focusColor : Get.theme.buttonTheme.colorScheme!.background,
            //   ),
            // ),
            divider,
            Builder(builder: (context) {
              return IconButton(
                onPressed: () => _showPerformanceDialog(context),
                icon: Icon(Icons.directions_run_rounded),
                tooltip: 'Performance optimization',
                iconSize: 18,
                padding: EdgeInsets.zero,
                constraints: _buttonConstraints,
                splashRadius: splashRadius,
                style: IconButton.styleFrom(
                  backgroundColor: colorScheme.secondaryContainer,
                ),
              );
            }),
            divider,
            IconButton(
              onPressed: controller.resetChart,
              icon: Icon(CupertinoIcons.refresh_bold),
              tooltip: 'Reset chart',
              iconSize: 18,
              padding: EdgeInsets.zero,
              constraints: _buttonConstraints,
              splashRadius: splashRadius,
              style: IconButton.styleFrom(
                backgroundColor: colorScheme.secondaryContainer,
              ),
            ),
            divider,
            IconButton(
              onPressed: logic.saveImage,
              icon: Icon(Ionicons.image_outline),
              tooltip: 'Export Image',
              iconSize: 18,
              padding: EdgeInsets.zero,
              constraints: _buttonConstraints,
              splashRadius: splashRadius,
              style: IconButton.styleFrom(
                backgroundColor: colorScheme.secondaryContainer,
              ),
            ),
            divider,
            Builder(
              builder: (c) {
                return IconButton(
                  constraints: _buttonConstraints,
                  splashRadius: splashRadius,
                  padding: EdgeInsets.zero,
                  iconSize: 20,
                  icon: Icon(MaterialCommunityIcons.opacity),
                  tooltip: 'Background Image',
                  onPressed: () => _showBackgroundImageConfigDialog(c),
                  style: IconButton.styleFrom(
                    backgroundColor: colorScheme.secondaryContainer,
                  ),
                );
              },
            ),
            divider,
            Builder(
              builder: (c) {
                return IconButton(
                  constraints: _buttonConstraints,
                  splashRadius: splashRadius,
                  padding: EdgeInsets.zero,
                  iconSize: 20,
                  icon: Icon(MaterialCommunityIcons.scatter_plot),
                  tooltip: 'Point size',
                  onPressed: () => _showDotSizeDialog(c),
                  style: IconButton.styleFrom(
                    backgroundColor: colorScheme.secondaryContainer,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDotSizeDialog(BuildContext context) {
    showAttachedWidget(
      targetContext: context,
      preferDirection: PreferDirection.rightTop,
      offset: Offset(10, 0),
      attachedBuilder: (c) {
        return Material(
          elevation: 6,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            constraints: BoxConstraints.tightFor(width: 300),
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(child: Text('Point Config')),
                Divider(height: 6, thickness: 1.5),
                SliderWidget(
                  label: 'Opacity',
                  value: controller.currentChartLogic.state.pointOpacity,
                  onChanged: controller.setOpacity,
                  min: 0.1,
                  max: 1.0,
                  divisions: 9,
                  isColor: true,
                ),
                SizedBox(height: 10),
                SliderWidget(
                  value: controller.currentChartLogic.state.pointSize,
                  label: 'Point Size',
                  divisions: 9,
                  onChanged: controller.setPointSize,
                  min: 1.0,
                  max: 10.0,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showPerformanceDialog(BuildContext context) {
    showAttachedWidget(
      targetContext: context,
      preferDirection: PreferDirection.rightTop,
      offset: Offset(10, 0),
      attachedBuilder: (c) {
        return Material(
          elevation: 6,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            constraints: BoxConstraints.tightFor(width: 300),
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(child: Text('Performance optimization')),
                Divider(height: 10, thickness: 1.5),
                Container(child: Text('Limit the maximum count drawing points', style: Theme.of(context).textTheme.bodySmall)),
                SliderWidget(
                  label: 'Max Points',
                  value: controller.maxPointCount.toDouble(),
                  onChanged: controller.setMaxPointCount,
                  labelFormatter: (v) => '${(v ~/ 1000)}k',
                  min: 100000,
                  max: 1000000,
                  divisions: 90,
                  isColor: false,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showBackgroundImageConfigDialog(BuildContext context) {
    showAttachedWidget(
      targetContext: context,
      preferDirection: PreferDirection.rightTop,
      offset: Offset(10, 0),
      attachedBuilder: (c) {
        return Material(
          elevation: 6,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            constraints: BoxConstraints.tightFor(width: 300),
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(child: Text('Background Image')),
                Divider(height: 10, thickness: 1.5),
                SliderWidget(
                  label: 'Opacity',
                  value: controller.currentChartLogic.backgroundOpacity,
                  onChanged: controller.setBackgroundOpacity,
                  min: 0.0,
                  max: 1.0,
                  divisions: 10,
                  isColor: true,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
