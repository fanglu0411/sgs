import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:flutter_smart_genome/base/app_layout.dart';
import 'package:flutter_smart_genome/page/cell/cell_page/cell_page_logic.dart';
import 'package:flutter_smart_genome/page/cell/cell_scatter_chart/cell_scatter_chart_logic.dart';
import 'package:flutter_smart_genome/page/cell/cell_tool_bar/feature_search_input.dart';
import 'package:flutter_smart_genome/service/sgs_config_service.dart';
import 'package:flutter_smart_genome/widget/basic/custom_bot_widget.dart';
import 'package:flutter_smart_genome/widget/basic/fast_rich_text.dart';
import 'package:flutter_smart_genome/widget/basic/simple_widget_builder.dart';
import 'package:flutter_smart_genome/widget/track/base/track_data.dart';
import 'package:get/get.dart';

class CellToolBarView extends StatefulWidget {
  @override
  _CellToolBarViewState createState() => _CellToolBarViewState();
}

class _CellToolBarViewState extends State<CellToolBarView> {
  // final CellToolBarLogic logic = Get.put(CellToolBarLogic());

  late ScrollController _scrollController;
  late double _width;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    // _autoScroll();
  }

  _autoScroll() async {
    await Future.delayed(Duration(milliseconds: 500));
    _scrollController.animateTo((_width) / 2, duration: Duration(milliseconds: 800), curve: Curves.ease);
    await Future.delayed(Duration(milliseconds: 800));
    _scrollController.animateTo(0, duration: Duration(milliseconds: 600), curve: Curves.decelerate);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (c, constraints) => _builder(c, constraints),
    );
  }

  Widget _builder(BuildContext context, BoxConstraints constraints) {
    _width = constraints.maxWidth;
    CellScatterChartLogic chartLogic = CellPageLogic.safe()!.currentChartLogic;
    CellPageLogic logic = CellPageLogic.safe()!;
    ColorScheme colorScheme = Get.theme.colorScheme;
    const buttonSize = 32.0;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          IconButton(
            isSelected: logic.allFontLayerHide,
            onPressed: () => logic.toggleAllLayer(),
            icon: Icon(Icons.layers, size: 16),
            selectedIcon: Icon(Icons.layers_clear, size: 16, color: Theme.of(context).colorScheme.primary),
            tooltip: 'Toggle Control',
            padding: EdgeInsets.zero,
            constraints: BoxConstraints.tightFor(width: buttonSize, height: buttonSize),
            splashRadius: 20,
            style: IconButton.styleFrom(
              backgroundColor: logic.allFontLayerHide ? colorScheme.primaryContainer : colorScheme.secondaryContainer,
            ),
          ),
          SizedBox(width: 10),
          if (!logic.allFontLayerHide)
            IconButton(
              // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              isSelected: logic.splitMode,
              onPressed: () => logic.toggleSplitMod(!logic.splitMode),
              icon: Icon(CupertinoIcons.square_split_2x1, size: 16),
              selectedIcon: Icon(CupertinoIcons.square_split_2x1_fill, size: 16, color: Theme.of(context).colorScheme.primary),
              tooltip: 'Toggle Split Mode',
              padding: EdgeInsets.zero,
              constraints: BoxConstraints.tightFor(width: buttonSize, height: buttonSize),
              splashRadius: 20,
              style: IconButton.styleFrom(
                // shape: RoundedRectangleBorder(),
                backgroundColor: logic.splitMode ? colorScheme.primaryContainer : colorScheme.secondaryContainer,
              ),
            ),
          SizedBox(width: 10),
          Spacer(),
          if (!logic.allFontLayerHide && !logic.searchFieldExpanded)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!logic.nativeSource)
                  // SimplePopMenuButton<MatrixBean>(
                  //   context: context,
                  //   items: logic.matrixList,
                  //   initialValue: chartLogic.state.mod,
                  //   onSelected: logic.changeMatrix,
                  //   tooltip: 'Mod: ${chartLogic.state.mod?.name}',
                  //   borderRadius: BorderRadius.circular(4),
                  //   // offset: Offset(0, 50),
                  //   // buttonConstraints: BoxConstraints(maxWidth: 240),
                  //   buttonTextBuilder: (e) => 'Mod: ${e?.name}',
                  //   buttonPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  // ),
                  SimpleDropdownButton<MatrixBean>(
                    items: logic.matrixList,
                    initialValue: chartLogic.state.mod,
                    onSelectedChange: logic.changeMatrix,
                    buttonPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                    buttonTextBuilder: (e) => 'Mod: ${e?.name}',
                  ),
                // SimplePopMenuButton<String>(
                //   context: context,
                //   items: logic.plotTypes.map<String>((e) => e).toList(),
                //   initialValue: chartLogic.state.plotType,
                //   onSelected: logic.changePlotType,
                //   tooltip: 'Plot: ${chartLogic.state.plotType}',
                //   borderRadius: BorderRadius.circular(4),
                //   buttonTextBuilder: (e) => ' Plot1: ${e}',
                //   buttonPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                // ),
                SizedBox(width: 10),
                SimpleDropdownButton<String>(
                  items: logic.plotTypes.map<String>((e) => e).toList(),
                  initialValue: chartLogic.state.plotType,
                  onSelectedChange: logic.changePlotType,
                  buttonTextBuilder: (e) => ' Plot1: ${e}',
                  buttonPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                ),
              ],
            ),
          SizedBox(width: 10),
          if (!logic.allFontLayerHide)
            _width > 860 || logic.searchFieldExpanded
                ? FeatureSearchInput(
                    showCollapse: logic.searchFieldExpanded,
                    onChange: (list) {
                      CellPageLogic.safe()?.onTapFeatures(list);
                    },
                    onCollapse: () {
                      CellPageLogic.safe()?.collapseSearchField();
                    },
                  )
                : IconButton(
                    // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    onPressed: () {
                      logic.toggleSearchFieldExpanded();
                    },
                    icon: Icon(Icons.search),
                    iconSize: 18,
                    tooltip: 'Search Gene',
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints.tightFor(width: buttonSize, height: buttonSize),
                    splashRadius: 20,
                    style: IconButton.styleFrom(
                      backgroundColor: colorScheme.secondaryContainer,
                    ),
                  ),
          Spacer(),
          if (!logic.allFontLayerHide)
            IconButton(
              // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              isSelected: logic.showLegend,
              onPressed: logic.toggleLegend,
              icon: Icon(Icons.keyboard_arrow_left),
              tooltip: 'Toggle legend',
              selectedIcon: Icon(MaterialIcons.keyboard_arrow_right, color: colorScheme.primary),
              padding: EdgeInsets.zero,
              constraints: BoxConstraints.tightFor(width: buttonSize, height: buttonSize),
              splashRadius: 20,
              style: IconButton.styleFrom(
                backgroundColor: logic.showLegend ? colorScheme.primaryContainer : colorScheme.secondaryContainer,
              ),
            ),
        ],
      ),
    );
  }

  // void _showGraphPlot() {
  //   var dialog = AlertDialog(
  //     content: Container(
  //       constraints: BoxConstraints.expand(width: 1200),
  //       child: GraphicPlotWidget(),
  //     ),
  //   );
  //   showDialog(context: context, builder: (c) => dialog);
  // }

  void showHelpTip(BuildContext context) {
    showAttachedWidget(
      targetContext: context,
      preferDirection: PreferDirection.bottomRight,
      attachedBuilder: (cancel) {
        return Material(
          elevation: 6,
          shadowColor: Theme.of(context).colorScheme.primary,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            constraints: BoxConstraints.tightFor(width: 300),
            child: FastRichText(
              textStyle: TextStyle(height: 1.4, color: Theme.of(context).textTheme.bodyMedium!.color),
              children: [
                TextSpan(text: '1. zoom in and out chart by mouse wheel.\n'),
                TextSpan(text: '2. set color by and label by individual.\n'),
                TextSpan(text: '3. toggle legend to show or hide legend.\n'),
                TextSpan(text: '4. long press label to drag and move.'),
              ],
            ),
          ),
        );
      },
    );
  }

  void showLabelByDialog(BuildContext context) {
    showAttachedWidget(
        targetContext: context,
        preferDirection: PreferDirection.bottomLeft,
        attachedBuilder: (c) {
          CellPageLogic pageLogic = CellPageLogic.safe()!;
          Iterable<Widget> children = pageLogic.currentChartLogic.state.mod!.groups.map((e) {
            return RadioListTile<String>(
              value: e,
              title: Text(e),
              groupValue: pageLogic.labelByGroup,
              contentPadding: EdgeInsets.symmetric(horizontal: 10),
              dense: true,
              onChanged: (e) {
                c.call();
                pageLogic.onLabelByChange(e!);
              },
            );
          });
          double height = children.length * 50.0;
          if (height >= 200) height = 200;
          return Material(
            elevation: 6,
            child: Container(
              constraints: BoxConstraints(minHeight: height, maxHeight: height, maxWidth: 200, minWidth: 100),
              child: ListView(
                children: ListTile.divideTiles(tiles: children, context: context).toList(),
              ),
            ),
          );
        });
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }
}
