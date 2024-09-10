import 'package:bot_toast/bot_toast.dart';
import 'package:dartx/dartx.dart' as dx;
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_smart_genome/base/app_layout.dart';
import 'package:flutter_smart_genome/chart/graphic/plot/simple_pie_plot.dart';
import 'package:flutter_smart_genome/chart/graphic/plot/stack_bar_plot.dart';
import 'package:flutter_smart_genome/extensions/d4_extension.dart';
import 'package:flutter_smart_genome/extensions/widget_extensions.dart';
import 'package:flutter_smart_genome/mixin/async_data_loader_mixin.dart';
import 'package:flutter_smart_genome/network/http_response.dart';
import 'package:flutter_smart_genome/page/cell/cell_page/cell_page_logic.dart';
import 'package:flutter_smart_genome/page/cell/cell_scatter_chart/cell_scatter_chart_logic.dart';
import 'package:flutter_smart_genome/page/cell/cell_scatter_chart/legend_colors.dart';
import 'package:flutter_smart_genome/page/cell/cell_tool_bar/toggle_button.dart';
import 'package:flutter_smart_genome/service/single_cell_service.dart';
import 'package:flutter_smart_genome/util/random_color/random_file.dart';
import 'package:flutter_smart_genome/widget/basic/downloadable_widget.dart';
import 'package:flutter_smart_genome/widget/basic/number_field_widget.dart';
import 'package:flutter_smart_genome/widget/basic/simple_widget_builder.dart';
import 'package:flutter_smart_genome/widget/split_widget.dart';
import 'package:flutter_smart_genome/widget/toggle_button_group.dart';
import 'package:flutter_smart_genome/widget/track/base/track_data.dart';
import 'package:d4/d4.dart' as d4;

class MetaStaticChartWidget extends StatefulWidget {
  final Track track;
  final MatrixBean mod;
  final String tag;

  const MetaStaticChartWidget({
    super.key,
    required this.track,
    required this.mod,
    required this.tag,
  });

  @override
  State<MetaStaticChartWidget> createState() => _MetaStaticChartWidgetState();
}

class _MetaStaticChartWidgetState extends State<MetaStaticChartWidget> with AsyncDataLoaderMixin<MetaStaticChartWidget, List<Map>> {
  String? _groupBy;
  String? _colorBy;
  List? _groups;
  List? _types;
  num? _groupMaxValue;

  // List<Color>? _colors;
  Map<String, Color>? _colorMap;
  double _barWidth = 20;

  List<Map>? _selectedData;

  List<double> _fraction = [.7, .3];

  bool _isPercent = true;
  bool _showLegends = true;

  @override
  void initState() {
    var cats = widget.mod.categories;
    final currentGroup = CellPageLogic.safe()?.chartLogic(widget.tag).currentGroup;
    _colorBy = cats.keys.firstOrNullWhere((e) => e == currentGroup) != null ? currentGroup : cats.keys.first;
    _groupBy = cats.keys.firstOrNullWhere((e) => e != _colorBy) ?? _colorBy;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant MetaStaticChartWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mod != widget.mod) {
      var cats = widget.mod.categories;
      final currentGroup = CellPageLogic.safe()?.chartLogic(widget.tag).currentGroup;
      _colorBy = cats.keys.firstOrNullWhere((e) => e == currentGroup) != null ? currentGroup : cats.keys.first;
      _groupBy = cats.keys.firstOrNullWhere((e) => e != currentGroup) ?? _colorBy;
    }
  }

  @override
  Widget buildContent() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: filterBar(),
        ),
        Container(
          constraints: BoxConstraints.expand(),
          child: DownloadAbleWidget(
            fileName: 'meta-statics-${widget.track.name}-${widget.mod.name}',
            child:
                // (_types!.length == 1 && _groups!.length <= 5) || (_groups!.length == 1 && _types!.length <= 5)
                //     ? SimplePiePlot(
                //         data: data!,
                //         typeKey: _types!.length == 1 ? 'group' : 'type',
                //         types: _types!.length == 1 ? _groups! : _types!,
                //         // colors: _colorMap!.values.toList(),
                //       )
                //     :
                Container(
              margin: const EdgeInsets.only(top: 36),
              child: StackBarPlot(
                data: data!,
                maxValue: _isPercent ? 1.0 : _groupMaxValue,
                types: _showLegends ? _types : null,
                // colors: _colors,
                stackAccessKey: _isPercent ? 'percent' : 'value',
                colorMap: _colorMap,
                barWidth: _barWidth,
                labelColor: Theme.of(context).textTheme.bodyMedium?.color,
                dark: Theme.of(context).brightness == Brightness.dark,
                onItemTap: (selected) {
                  _selectedData = selected;
                  _selectedData?.sort((a, b) => b['value'] - a['value']);
                  setState(() {});
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget filterBar() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        margin: const EdgeInsets.only(right: 60, top: 4),
        padding: EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: Theme.of(context).dialogBackgroundColor,
        ),
        child: Row(
          children: [
            SimpleDropdownButton(
              items: widget.mod.categories.keys.toList(),
              initialValue: _groupBy,
              buttonTextBuilder: (v) => 'Group By: ${v}',
              preferDirection: PreferDirection.rightCenter,
              onSelectedChange: (v) {
                _groupBy = v;
              },
            ),
            SizedBox(width: 10),
            SimpleDropdownButton(
              items: widget.mod.categories.keys.toList(),
              initialValue: _colorBy,
              preferDirection: PreferDirection.rightCenter,
              buttonTextBuilder: (v) => 'Color By: ${v}',
              onSelectedChange: (v) {
                _colorBy = v;
              },
            ),
            // SizedBox(width: 12),
            // Text('Bar width:'),
            // NumberFieldWidget(
            //   value: _barWidth,
            //   min: 10,
            //   step: 5,
            //   max: 100,
            //   onChanged: (v) {
            //     _barWidth = v;
            //   },
            // ),
            SizedBox(width: 10),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 6),
                minimumSize: Size(40, 38),
                side: BorderSide(color: Theme.of(context).dividerColor),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
              ),
              onPressed: () {
                reloadData();
              },
              child: Text('Reload'),
            ),
            SizedBox(width: 10),

            ToggleButtonGroup(
              selectedIndex: _isPercent ? 1 : 0,
              borderRadius: BorderRadius.circular(5),
              constraints: BoxConstraints.tightFor(height: 28),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text('#'),
                ).tooltip('Count'),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text('%'),
                ).tooltip('Percent'),
              ],
              onChange: (i) {
                _isPercent = i == 1;
                setState(() {});
              },
            ),
            SizedBox(width: 10),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 6),
                minimumSize: Size(40, 38),
                side: BorderSide(color: Theme.of(context).dividerColor),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
              ),
              icon: Icon(_showLegends ? Icons.check_box : Icons.check_box_outline_blank, size: 16),
              label: Text('Legend'),
              onPressed: () {
                _showLegends = !_showLegends;
                setState(() {});
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _legends() {
    if (_selectedData == null) {
      return Offstage();
    }
    return ListView.separated(
      padding: EdgeInsets.only(right: 20, top: 20),
      itemBuilder: (c, i) {
        var item = _selectedData![i];
        return ListTile(
          dense: true,
          visualDensity: VisualDensity(horizontal: -4, vertical: -4),
          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
          leading: Icon(Icons.square, color: _colorMap![item['type']]),
          title: Text(item['type']),
          trailing: Text('${item['value']}', style: Theme.of(context).textTheme.bodyMedium),
        );
      },
      separatorBuilder: (c, i) => Divider(thickness: 1, height: 1),
      itemCount: _selectedData!.length,
    );
  }

  @override
  Future<HttpResponseBean> loadData(CancelToken cancelToken) {
    return loadMetaStatics(
      track: widget.track,
      matrixId: widget.mod.id,
      groupBy: _groupBy!,
      colorBy: _colorBy!,
      cancelToken: cancelToken,
    );
  }

  @override
  Future<List<Map>?> parseData(HttpResponseBean<dynamic> resp) async {
    Map data = resp.body;
    _groups = data.keys.toList();
    _groupMaxValue = data.values.map<num>((e) {
      if (e is Map) {
        return e.values.sumBy((v) => v);
      }
      return 0;
    }).max();
    _colorMap = null;
    _types = (data[_groups!.first] as Map).keys.map((e) => '${e}').toList();
    List<List<Map>> rst = _groups!.mapIndexed((index, g) {
      Map map = data[g];
      int groupTotal = map.values.sumBy((e) => e);
      return map.keys.map<Map>((c) => ({'group': g, 'type': c, 'value': map[c], 'percent': double.parse(((map[c] / groupTotal) as num).toStringAsFixed(4))})).toList();
    }).toList();
    if (_colorBy == CellPageLogic.safe()?.chartLogic(widget.tag).currentGroup) {
      CellScatterChartLogic chartLogic = CellPageLogic.safe()!.chartLogic(widget.tag);
      if (chartLogic.categoryLegendColorMap.length == _types!.length) {
        _colorMap = chartLogic.categoryLegendColorMap;
      }
    }
    if (_colorMap == null) {
      int count = _types!.length;
      d4.ScaleSequential colorScale = d4.ScaleSequential(domain: [1, count], interpolator: legendColors.first.interpolate);
      List<Color> _colors = List.generate(count, (index) => d4.Color.tryParse(colorScale.call(index + 1))!.flutterColor);
      _colorMap = Map.fromIterables(_types!.map<String>((e) => '${e}'), _colors);
    }
    _selectedData = null;
    return rst.flatten();
  }
}
