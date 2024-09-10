import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/cell/data_category.dart';
import 'package:flutter_smart_genome/page/cell/cell_page/cell_page_logic.dart';
import 'package:flutter_smart_genome/page/cell/cell_plot_legend/category_legend_view.dart';
import 'package:flutter_smart_genome/page/cell/cell_plot_legend/linear_legend_view.dart';
import 'package:flutter_smart_genome/page/cell/cell_scatter_chart/legend_colors.dart';
import 'package:flutter_smart_genome/widget/basic/simple_widget_builder.dart';
import 'package:get/get.dart';
import 'cell_plot_legend_logic.dart';

class CellPlotLegendView extends StatefulWidget {
  final List<DataCategory>? legends;
  final ValueChanged<DataCategory?>? onCheckedChange;
  final ValueChanged<DataCategory?>? onSelectionChange;
  final ValueChanged<LegendColor>? onColorSchemaChange;
  final ValueChanged<List<DataCategory>>? onColorChange;
  final List<LegendColor>? legendColors;
  final LegendColor? legendColor;
  final bool showColorSchema;
  final bool editable;
  final bool showColorBy;

  CellPlotLegendView({
    Key? key,
    this.legends,
    this.onCheckedChange,
    this.onSelectionChange,
    this.onColorChange,
    this.onColorSchemaChange,
    this.showColorSchema = true,
    this.legendColors,
    this.editable = true,
    this.legendColor,
    this.showColorBy = true,
  }) : super(key: key) {}

  @override
  _CellPlotLegendViewState createState() => _CellPlotLegendViewState();
}

class _CellPlotLegendViewState extends State<CellPlotLegendView> {
  final CellPlotLegendLogic logic = Get.put(CellPlotLegendLogic());

  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(covariant CellPlotLegendView oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    CellPageLogic pageLogic = CellPageLogic.safe()!;
    Color priColor = Theme.of(context).colorScheme.primary;
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 10),
          // if (widget.showColorBy)
          // SimplePopMenuButton<String>(
          //   context: context,
          //   enabled: widget.showColorBy,
          //   buttonPadding: const EdgeInsets.only(left: 8),
          //   items: pageLogic.orderedGroupList,
          //   initialValue: pageLogic.currentChartLogic.currentGroup,
          //   onSelected: pageLogic.changeGroup,
          //   tooltip: 'Color by ${pageLogic.currentChartLogic.currentGroup}',
          //   buttonConstraints: BoxConstraints(maxWidth: 260),
          //   borderRadius: BorderRadius.circular(4),
          //   buttonTextBuilder: (e) => 'Color by ${e}',
          //   itemBuilder: (e) {
          //     return Wrap(
          //       spacing: 4,
          //       children: [
          //         Icon(pageLogic.currentChartLogic.state.mod!.getGroupType(e) == 'list' ? Icons.category : Icons.numbers, size: 18),
          //         Text('${e}'),
          //       ],
          //     );
          //   },
          // ),
          if (widget.showColorBy)
            SimpleDropdownButton<String>(
              items: pageLogic.orderedGroupList,
              initialValue: pageLogic.currentChartLogic.currentGroup,
              onSelectedChange: pageLogic.changeGroup,
              buttonPadding: const EdgeInsets.only(left: 8, right: 4),
              buttonConstraints: BoxConstraints(maxWidth: 260),
              buttonTextBuilder: (e) => 'Color by ${e}',
              enabled: widget.showColorBy,
              itemBuilder: (e) {
                return (Icon(pageLogic.currentChartLogic.state.mod!.getGroupType(e) == 'list' ? Icons.category : Icons.numbers, size: 18), Text('${e}'));
              },
            ),
          SizedBox(height: 4),
          if (widget.legendColor == null && widget.legends != null)
            CategoryLegendView(
              legends: widget.legends!,
              legendColors: widget.legendColors,
              onCheckedChange: widget.onCheckedChange,
              onSelectionChange: widget.onSelectionChange,
              onColorChange: widget.onColorChange,
              onColorSchemaChange: widget.onColorSchemaChange,
            ),
          if (widget.legendColor != null)
            LinearLegendView(
              color: widget.legendColor!,
              height: 300,
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    Get.delete<CellPlotLegendLogic>();
    super.dispose();
  }
}
