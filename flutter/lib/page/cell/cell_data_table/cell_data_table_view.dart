import 'package:bot_toast/bot_toast.dart';
import 'package:dartx/dartx.dart';
import 'package:dio/dio.dart';
import 'package:flutter_smart_genome/extensions/widget_extensions.dart';
import 'package:flutter_smart_genome/page/cell/cell_data_table/feature_expression/feature_expression_list.dart';
import 'package:flutter_smart_genome/widget/basic/custom_spin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/base/container_config.dart';
import 'package:flutter_smart_genome/network/http_response.dart';
import 'package:flutter_smart_genome/page/cell/cell_data_table/async_image_view.dart';
import 'package:flutter_smart_genome/page/cell/cell_data_table/meta_static_chart.dart';
import 'package:flutter_smart_genome/page/cell/cell_data_table/selected_cell_widget.dart';
import 'package:flutter_smart_genome/page/cell/cell_data_table/spital_slice_list_view.dart';
import 'package:flutter_smart_genome/page/cell/cell_data_table/table_data_state.dart';
import 'package:flutter_smart_genome/page/cell/cell_page/cell_page_logic.dart';
import 'package:flutter_smart_genome/page/cell/cell_scatter_chart/cell_scatter_chart_logic.dart';
import 'package:flutter_smart_genome/service/sgs_app_service.dart';
import 'package:flutter_smart_genome/service/sgs_config_service.dart';
import 'package:flutter_smart_genome/service/single_cell_service.dart';
import 'package:flutter_smart_genome/widget/basic/scroll_controller_builder.dart';
import 'package:flutter_smart_genome/widget/basic/custom_bot_widget.dart';
import 'package:flutter_smart_genome/widget/basic/fast_rich_text.dart';
import 'package:flutter_smart_genome/widget/basic/simple_widget_builder.dart';
import 'package:flutter_smart_genome/widget/loading_widget.dart';
import 'package:flutter_smart_genome/widget/quick_data_grid/data_column.dart';
import 'package:flutter_smart_genome/widget/quick_data_grid/quick_data_grid.dart';
import 'package:flutter_smart_genome/widget/table/simple_data_table_source.dart';
import 'package:flutter_smart_genome/widget/toggle_button_group.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';

import 'cell_data_table_logic.dart';
import 'cluster_pop_widget.dart';
import 'marker_search_filter.dart';

class CellDataTableView extends StatefulWidget {
  final bool pop;
  final VoidCallback? onHide;
  final String tag;

  const CellDataTableView({
    Key? key,
    this.pop = false,
    this.onHide,
    required this.tag,
  }) : super(key: key);

  @override
  _CellDataTableViewState createState() => _CellDataTableViewState();
}

class _CellDataTableViewState extends State<CellDataTableView> {
  late NumberFormat _numberFormat;

  late CellDataTableLogic _logic;

  @override
  void initState() {
    _logic = CellDataTableLogic.safe(widget.tag) ?? Get.put(CellDataTableLogic(widget.tag), tag: widget.tag);
    super.initState();
    _numberFormat = NumberFormat('###.00####');
  }

  @override
  void didUpdateWidget(covariant CellDataTableView oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CellDataTableLogic>(
      tag: widget.tag,
      builder: (c) => LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) => _builder(c, constraints)),
      dispose: (s) {
        s.controller?.onViewDispose();
      },
    );
  }

  Widget _builder(CellDataTableLogic logic, BoxConstraints constraints) {
    if (logic.tableSourceType == null) {
      return LoadingWidget.loading();
    }
    if (logic.currentTableDataState.loading) {
      return LoadingWidget.loading(
        message: logic.currentTableDataState.needSearch ? 'Searching...' : 'Loading data...',
        onCancel: logic.tableSourceType == TableSourceType.marker_feature && logic.currentTableDataState.needSearch
            ? () {
                logic.currentTableDataState.cancelSearch();
                logic.loadData();
              }
            : null,
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ToggleButtonGroup(
              selectedIndex: logic.dataSourceIndex,
              borderRadius: BorderRadius.circular(2),
              constraints: BoxConstraints.tightFor(height: 24),
              children: logic.dataSourceMap.keys
                  .map(
                    (v) => SizedBox(
                      width: 50,
                      // child: Text(v),
                      child: logic.getTabIcon(v, Theme.of(context).textTheme.bodyMedium?.color),
                    ).tooltip(logic.tabNameMap[v]!),
                  )
                  .toList(),
              onChange: logic.onDataSourceTypeChange,
            ),
            SizedBox(width: 12),
            if (logic.tableSourceType == TableSourceType.marker_feature)
              Builder(builder: (c) {
                return ToggleButtonGroup(
                  borderRadius: BorderRadius.circular(2),
                  constraints: BoxConstraints.tightFor(height: 24),
                  buttonMode: true,
                  children: [
                    SizedBox(
                      width: 30,
                      child: Icon(Icons.search, size: 16),
                    ).tooltip('Search Marker Feature'),
                    SizedBox(
                      width: 30,
                      child: Icon(Icons.clear, size: 16),
                    ).tooltip('Clear Search'),
                  ],
                  onChange: (i) {
                    if (i == 0) {
                      _showSearchMarkerFeatureDialog(c);
                    } else if (i == 1) {
                      _logic.clearMarkerFeatureSearch();
                    }
                  },
                );
              }),
            Spacer(),
            FilledButton(
              style: FilledButton.styleFrom(
                elevation: 0,
                padding: EdgeInsets.symmetric(horizontal: 8),
                minimumSize: Size(30, 32),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
              ),
              onPressed: logic.showMultiCompare,
              child: Text('scMultiCompare'),
            ),
            SizedBox(width: 4),
            // if (logic.tableSourceType != TableSourceType.cluster_meta)
            //   IconButton(
            //     onPressed: _logic.toggleAlbumMode,
            //     padding: EdgeInsets.zero,
            //     constraints: BoxConstraints.tightFor(width: 24, height: 24),
            //     splashRadius: 12,
            //     tooltip: _logic.albumMode ? 'Table View' : 'Grid List',
            //     icon: Icon(_logic.albumMode ? Icons.table_view : Icons.grid_view, size: 16),
            //   ),
            // SizedBox(width: 10),

            if (widget.pop)
              IconButton(
                padding: EdgeInsets.zero,
                splashRadius: 12,
                tooltip: 'Hide',
                constraints: BoxConstraints.tightFor(width: 30, height: 24),
                onPressed: widget.onHide,
                icon: Icon(Icons.expand_more),
                style: IconButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
                ),
              ),
            SizedBox(width: 4),
          ],
        ),
        // SizedBox(height: 0),
        // logic.dataSourceType == 0 ? _buildMarkerGeneHeader(logic) : _buildClusterMetaHeader(logic),
        Expanded(child: _tableSourceWidgetBuilder(logic, constraints)),
      ],
    );
  }

  void _showSearchMarkerFeatureDialog(BuildContext context) async {
    List<String> getColumnsFromData() {
      if (_logic.markerFeatureState.isEmpty) return _logic.markerFeatureState.headers ?? <String>[];
      var first = _logic.markerFeatureState.dataSource!.first;
      return first.keys.filter((k) => !(first[k] is num) || num.tryParse('${first[k]}') == null).map<String>((s) => '$s').toList();
    }

    List<String> columns = getColumnsFromData();

    if (columns.length == 0) {
      showToast(text: 'No columns is searchable!');
      return;
    }
    showAttachedWidget(
      targetContext: context,
      preferDirection: PreferDirection.bottomCenter,
      attachedBuilder: (c) {
        return Material(
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: MarkerSearchFilter(
                columns: columns,
                onChanged: (a) {
                  c.call();
                  _onFilterMarkerFeature(a);
                }),
          ),
        );
      },
    );
  }

  void _onFilterMarkerFeature(a) {
    var (String col, String keyword) = a;
    _logic.markerFeatureState
      ..searchBy = col
      ..searchKeyword = keyword.replaceAll(RegExp('[^A-Za-z0-9-_]'), '');
    _logic.loadData();
  }

  Widget _tableSourceWidgetBuilder(CellDataTableLogic logic, BoxConstraints constraints) {
    CellScatterChartLogic chartLogic = CellPageLogic.safe()!.chartLogic(widget.tag);
    if (logic.tableSourceType == TableSourceType.spatial_slice) {
      logic.spatialSliceState.selectedSlice = chartLogic.state.spatial;
      return SpatialSliceView(
        state: logic.spatialSliceState,
        onItemTap: (spatial) {
          CellPageLogic.safe()?.changeSpatial(spatial);
        },
      );
    } else if (logic.tableSourceType == TableSourceType.cluster_meta) {
      return _buildClusterMetaWidget(logic);
    } else if (logic.tableSourceType == TableSourceType.cluster_meta_chart) {
      return MetaStaticChartWidget(track: CellPageLogic.safe()!.track!, mod: chartLogic.state.mod!, tag: widget.tag);
    } else if (logic.tableSourceType == TableSourceType.selected_feature) {
      return SelectedCellWidget(
        dataState: logic.selectedFeatureState,
        onExportData: logic.exportSelectedCells,
        onClear: () => logic.clearSelection(),
      );
    } else if (logic.tableSourceType == TableSourceType.feature_expression) {
      return FeatureExpressionList(state: logic.featureExpressionState, track: CellPageLogic.safe()!.track!);
    } else {
      return _buildFeatureTableWidget(logic, constraints);
    }
  }

  // final CellDataTableLogic logic = Get.put(CellDataTableLogic());
  // final CellDataTableState state = Get.find<CellDataTableLogic>().state;

  List<String> _featureKeys = ['feature_name', 'name', 'names', 'feature', 'gene', 'peak_name', 'motif'];

  Widget _buildFeatureTableWidget(CellDataTableLogic logic, BoxConstraints constraints) {
    AbsTableDataState _currentTableState = logic.currentTableDataState;
    bool _dark = Theme.of(context).brightness == Brightness.dark;

    if (_currentTableState.loading) {
      return Center(child: CustomSpin(color: Theme.of(context).colorScheme.primary));
    }
    // if (_currentTableState.count == 0) {
    //   return Center(child: Text('Data is empty'));
    // }
    if (logic.albumMode) {
      return ScrollControllerBuilder(
        builder: (c, controller) => GridView.builder(
          controller: controller,
          itemCount: _currentTableState.count,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 1.0,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
          ),
          itemBuilder: (BuildContext context, int index) => _gridImageItemBuilder(context, logic, _currentTableState.dataSource![index]),
        ),
      );
    }
    return QuickDataGrid<Map>(
      key: Key('marker-feature-grid'),
      data: _currentTableState.dataSource ?? [],
      minWidth: constraints.maxWidth,
      emptyMessage: _currentTableState.needSearch ? 'Search feature { ${_currentTableState.searchKeyword} } not found!' : 'Feature list is empty!',
      paginated: _currentTableState.needSearch ? false : true,
      showCheckbox: true,
      onSort: (col, s) {
        _currentTableState
          ..orderByColumnKey = col.dataKey
          ..order = s.type;
      },
      headers: _currentTableState.headers,
      totalCount: _currentTableState.totalCount,
      cellBuilder: _cellItemBuilder,
      columnBuilder: _markerGeneHeaderItemBuilder,
      paginationDataLoader: _currentTableState.needSearch ? null : _logic.quickPageDataLoader,
      onRowSelectChanged: logic.changeSelection,
      cursorBuilder: (column) {
        return _featureKeys.contains(column.dataKey) ? SystemMouseCursors.click : MouseCursor.defer;
      },
      onCellTap: (rowData, row, column) {
        bool nameCell = _logic.currentTableDataState.nameKey == column.dataKey || _featureKeys.contains(column.dataKey);
        if (nameCell) {
          _logic.onFeatureTap(rowData[column.dataKey], rowData, context);
        }
      },
    );
    // return CellDataTableWidget(
    //   key: Key('${logic.dataSourceIndex}-${logic.modId}'),
    //   headers: _currentTableState.headers,
    //   data: _currentTableState.dataSource ?? [],
    //   // headerBuilder: _markerGeneHeaderItemBuilder,
    //   cellItemBuilder: _cellItemBuilder,
    //   onRowSelectChanged: (i, row) => logic.changeSelection(i, row, row.selected),
    //   rowHeight: 36,
    //   message: _currentTableState.error ?? _currentTableState.emptyMsg,
    //   pageDataLoader: logic.pageDataLoader,
    //   asyncPaginated: _currentTableState.paginated,
    // );
  }

  Widget _markerGeneHeaderItemBuilder(BuildContext context, DataGridColumn column) {
    Widget child;

    var state = _logic.markerFeatureState;
    if (!state.isColumnFilterEmpty && state.columnFilters![column.dataKey] != null) {
      String _label = column.label;
      child = Builder(
        builder: (c) {
          return TextButton(
            style: TextButton.styleFrom(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.symmetric(horizontal: 2),
              minimumSize: Size(30, 32),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            child: FastRichText(
              children: [
                TextSpan(text: '${_label}', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 14)),
                WidgetSpan(child: Icon(Icons.arrow_drop_down, size: 16)),
              ],
            ),
            onPressed: () => _showMarkerTableColumnFilterDialog(c, group: column.dataKey!, clusters: state.columnFilters![column.dataKey!], selectedCluster: state.filterColumnValue, clearable: true),
          );
        },
      );
    } else {
      child = Text(column.label);
    }
    return child;
  }

  Widget _gridImageItemBuilder(BuildContext context, CellDataTableLogic logic, Map _item) {
    // String imageUrl = '${logic.imageBaseUrl}${_item['image_url']}';
    // String thumbImageUrl = '${logic.imageBaseUrl}${_item['thumb_image_url']}';
    TextStyle textStyle = Theme.of(context).textTheme.bodyMedium!.copyWith(
          fontFamily: MONOSPACED_FONT,
          fontFamilyFallback: MONOSPACED_FONT_BACK,
          color: Theme.of(context).colorScheme.primary,
        );
    String name = _item[logic.currentTableDataState.nameKey];
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Stack(
        children: [
          Container(
            color: Theme.of(context).colorScheme.background,
            margin: EdgeInsets.all(4),
            // height: 80,
            child: AsyncImageView(
              onTap: (v) => logic.onImageTap('${name}', v),
              baseUrl: SgsAppService.get()!.staticBaseUrl,
              imageId: _item['image_id'],
              imageInfo: SgsConfigService.get()!.getImage(_item['image_id']),
              onLoadImage: _loadImage,
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: InkWell(
              child: Padding(
                padding: EdgeInsets.only(left: 10, bottom: 8),
                child: Text('${name}', style: textStyle),
              ),
              onTap: () => logic.onFeatureTap(name, _item, context),
            ),
          ),
        ],
      ),
    );
  }

  void _showMarkerTableColumnFilterDialog(
    BuildContext context, {
    required String group,
    required List clusters,
    String? selectedCluster,
    bool clearable = false,
  }) {
    showAttachedWidget(
        targetContext: context,
        preferDirection: PreferDirection.bottomLeft,
        attachedBuilder: (c) {
          return Material(
            elevation: 4,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            child: ConstrainedBox(
              constraints: BoxConstraints.loose(Size(400, 300)),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ClusterPopWidget(
                  clearable: clearable,
                  group: group,
                  clusters: clusters,
                  checkedCluster: selectedCluster,
                  onClear: () {
                    c.call();
                    _logic.clearMarkerTableFilter();
                  },
                  onChanged: (values) {
                    c.call();
                    _logic.onMarkerTableFilterChange(values[0], values[1]);
                  },
                ),
              ),
            ),
          );
        });
  }

  void _showMetaTableColumnFilterDialog(BuildContext context, String? group, List clusters, String? selectedCluster) {
    showAttachedWidget(
        targetContext: context,
        preferDirection: PreferDirection.bottomLeft,
        attachedBuilder: (c) {
          return Material(
            elevation: 4,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            child: ConstrainedBox(
              constraints: BoxConstraints.loose(Size(400, 300)),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ClusterPopWidget(
                  group: group ?? _logic.group!,
                  clusters: clusters,
                  clearable: true,
                  checkedCluster: selectedCluster,
                  onClear: () {
                    c.call();
                    _logic.clearMetaTableFilter();
                  },
                  onChanged: (values) {
                    c.call();
                    _logic.onMetaTableFilterChange(values[0], values[1]);
                  },
                ),
              ),
            ),
          );
        });
  }

  Widget _cellItemBuilder(BuildContext context, Map row, TableVicinity vicinity, DataGridColumn column) {
    var v = _formatValue.call(row[column.dataKey]);
    bool nameCell = _logic.currentTableDataState.nameKey == column.dataKey || _featureKeys.contains(column.dataKey);
    // if (nameCell) {
    //   return TextButton(
    //       style: TextButton.styleFrom(
    //         minimumSize: Size(30, 30),
    //         padding: EdgeInsets.symmetric(horizontal: 2),
    //         textStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
    //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
    //       ),
    //       onPressed: () => _logic.onFeatureTap(row[column.dataKey], row, context),
    //       child: Text('${v}'));
    // }
    TextStyle? textStyle = nameCell
        ? Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontFamily: MONOSPACED_FONT,
              fontFamilyFallback: MONOSPACED_FONT_BACK,
            )
        : Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontFamily: MONOSPACED_FONT,
              fontFamilyFallback: MONOSPACED_FONT_BACK,
              overflow: TextOverflow.ellipsis,
            );
    return Text('$v', style: textStyle);
  }

  Widget _imageCell(rowData, cellData) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 4),
      constraints: BoxConstraints.tightFor(width: 80, height: 60),
      child: AsyncImageView(
        onTap: (v) => _logic.onImageTap('${rowData[_logic.currentTableDataState.nameKey]}', v),
        baseUrl: SgsAppService.get()!.staticBaseUrl,
        imageId: rowData['image_id'],
        imageInfo: SgsConfigService.get()!.getImage(rowData['image_id']),
        onLoadImage: _loadImage,
      ),
    );
  }

  Future<HttpResponseBean> _loadImage(String id, CancelToken? cancelToken) {
    CellScatterChartLogic chartLogic = CellPageLogic.safe()!.chartLogic(widget.tag);
    var site = SgsAppService.get()!.site;

    return loadFeatureImage(
      imageId: id,
      plotType: chartLogic.state.plotType!,
      host: site!.url,
      matrixId: chartLogic.state.mod!.id,
      cancelToken: cancelToken,
    );
  }

  dynamic _formatValue(dynamic item) {
    if (item is Map) {
      return '{${item.entries.first.key}: ${item.entries.first.value}, ...more}';
    }
    if (item is List) {
      return '${item.sublist(0, 3)} ...';
    }
    if (item is double) {
      int v = item.toInt();
      if ((v - item) == 0) {
        return '${v}';
      }
      // if ((item.abs()) >= 0.0001) return item.toStringAsPrecision(5);
      // return _numberFormat.format(item);
      return item.toStringAsPrecision(8);
    }
    return item;
  }

  Widget _buildClusterMetaWidget(CellDataTableLogic logic) {
    if (logic.clusterMetaState.loading) {
      return Center(child: CustomSpin(color: Theme.of(context).colorScheme.primary));
    }
    return QuickDataGrid<Map>(
      key: Key('cluster-meta-grid'),
      data: logic.clusterMetaState.dataSource ?? [],
      totalCount: logic.clusterMetaState.totalCount,
      paginated: true,
      showCheckbox: false,
      columnBuilder: _metaHeaderItemBuilder,
      paginationDataLoader: logic.quickPageDataLoader,
      cellBuilder: _cellItemBuilder,
      onSort: (col, s) {
        logic.clusterMetaState
          ..orderByColumnKey = col.dataKey
          ..order = s.type;
      },
    );

    // return CellDataTableWidget(
    //   key: Key('${logic.tableSourceType}'),
    //   headers: logic.clusterMetaState.headers,
    //   data: logic.clusterMetaState.dataSource ?? [],
    //   // headerBuilder: _metaHeaderItemBuilder,
    //   cellItemBuilder: _cellItemBuilder,
    //   showCheckBox: false,
    //   message: logic.clusterMetaState.error ?? logic.clusterMetaState.emptyMsg,
    //   pageDataLoader: null, //no paginated
    // );
  }

  Widget _metaHeaderItemBuilder(BuildContext context, DataGridColumn column) {
    Widget child;

    CellPageLogic pageLogic = CellPageLogic.safe()!;
    CellScatterChartLogic chartLogic = CellPageLogic.safe()!.chartLogic(widget.tag);
    var groupMap = chartLogic.state.mod!.groupMap;

    if (groupMap[column.dataKey] != null && !chartLogic.state.mod!.isCartesian(column.dataKey)) {
      var state = _logic.clusterMetaState;
      String _label = column.label;
      child = Builder(
        builder: (c) {
          return TextButton(
            style: TextButton.styleFrom(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.symmetric(horizontal: 2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
            child: FastRichText(
              children: [
                TextSpan(text: '${_label}', style: TextStyle(color: state.filterColumnKey == column.dataKey ? Theme.of(context).colorScheme.primary : Theme.of(context).textTheme.bodyMedium!.color)),
                WidgetSpan(child: Icon(Icons.arrow_drop_down, size: 16)),
              ],
            ),
            onPressed: () => _showMetaTableColumnFilterDialog(c, column.dataKey!, chartLogic.state.mod!.getClusters(column.dataKey), state.filterColumnValue),
          );
        },
      );
    } else {
      child = Text(column.label);
    }
    return child;
  }

  @override
  void dispose() {
    // Get.delete<CellDataTableLogic>();
    super.dispose();
  }
}
