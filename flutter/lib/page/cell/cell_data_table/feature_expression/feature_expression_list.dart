import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/page/cell/cell_data_table/table_data_state.dart';
import 'package:flutter_smart_genome/page/cell/cell_page/cell_page_logic.dart';
import 'package:flutter_smart_genome/page/cell/cell_scatter_chart/feature_history_item.dart';
import 'package:flutter_smart_genome/page/compare/widget/async_scatter_widget.dart';
import 'package:flutter_smart_genome/widget/loading_widget.dart';
import 'package:flutter_smart_genome/widget/track/base/track_data.dart';

class FeatureExpressionList extends StatelessWidget {
  final FeatureExpressionState state;
  final Track track;

  const FeatureExpressionList({
    super.key,
    required this.track,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: _builder);
  }

  Widget _builder(BuildContext context, BoxConstraints constraints) {
    if (state.isEmpty) {
      return LoadingWidget(loadingState: LoadingState.noData, message: state.emptyMsg);
    }
    double width = constraints.maxWidth;
    int cols = width ~/ 260;
    double spacing = 10;
    double colWidth = (width - (cols - 1) * spacing) / (cols);
    double colHeight = colWidth / 1.35;
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cols,
        childAspectRatio: 1.35,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      itemBuilder: (c, i) => _itemBuilder(c, i, colWidth, colHeight),
      itemCount: state.features.length,
      padding: EdgeInsets.all(10),
    );
  }

  Widget _itemBuilder(BuildContext c, int i, double width, double height) {
    FeatureHistoryItem item = state.features[i];
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(c).dividerColor),
      ),
      child: AsyncScatterWidget(
        track: track,
        plotType: item.plotType,
        modId: item.modId,
        features: item.features,
        group: item.group,
        spatial: item.spatial,
        legendColor: CellPageLogic.safe()?.featureLegendColor,
        width: width,
        height: height,
        index: i,
        // onTap: (d, c) {},
      ),
    );
  }
}
