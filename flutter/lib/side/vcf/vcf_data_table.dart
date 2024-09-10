import 'dart:convert';

import 'package:flutter_smart_genome/widget/basic/custom_spin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:flutter_smart_genome/components/json_widget.dart';
import 'package:flutter_smart_genome/side/vcf/filter_view.dart';
import 'package:flutter_smart_genome/side/vcf/vcf_data_table_logic.dart';
import 'package:flutter_smart_genome/util/file_util.dart';
import 'package:flutter_smart_genome/widget/basic/custom_bot_widget.dart';
import 'package:flutter_smart_genome/widget/quick_data_grid/data_column.dart';
import 'package:flutter_smart_genome/widget/quick_data_grid/quick_data_grid.dart';
import 'package:flutter_smart_genome/widget/table/simple_data_table_source.dart';
import 'package:flutter_smart_genome/widget/track/base/track_data.dart';
import 'package:get/get.dart';

class VcfDataTableSide extends StatefulWidget {
  final Track track;

  const VcfDataTableSide({Key? key, required this.track}) : super(key: key);

  @override
  State<VcfDataTableSide> createState() => _VcfDataTableSideState();
}

class _VcfDataTableSideState extends State<VcfDataTableSide> with WidgetsBindingObserver {
  List<ColumnKey>? columnKeys;

  VcfDataTableLogic? logic;

  TextEditingController? _searchInputController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _searchInputController = TextEditingController();
    logic = VcfDataTableLogic.safe();
    if (logic == null) logic = Get.put(VcfDataTableLogic());
    logic!.track = widget.track;
  }

  @override
  void didUpdateWidget(VcfDataTableSide oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (logic!.track != widget.track) {
      logic!.track = widget.track;
      //todo
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<VcfDataTableLogic>(
      init: logic,
      autoRemove: false,
      builder: (logic) {
        return Column(
          children: [
            _toolbar(),
            Expanded(child: _buildTableData(logic)),
          ],
        );
      },
    );
  }

  Widget _buildTableData(VcfDataTableLogic logic) {
    if (logic.loading) {
      return Center(
        child: CustomSpin(color: Theme.of(context).colorScheme.primary),
      );
    }

    return QuickDataGrid(
      data: [],
      paginationDataLoader: logic.loadData,
      pageSize: 50,
    );

    // return Container(
    //   // child: null,
    //   child: SimplePaginatedDataTable(
    //     data: logic.data,
    //     // columnKeys: [],
    //   ),
    // );
  }

  void _rowDoubleTap(DataGridColumn column) {
    if (column.dataKey == "info") {
      // _showPrettyInfo(value);
    }
  }

  void _showPrettyInfo(String info) {
    List arr = info.split(';');
    Map _info = {};
    var _item;
    for (String s in arr) {
      _item = s.split("=");
      _info[_item[0]] = _item[1];
    }
    var dialog = AlertDialog(
      title: Text('info'),
      content: Container(
        constraints: BoxConstraints(minWidth: 400, minHeight: 600, maxWidth: 400, maxHeight: 600),
        child: JsonWidget(
          search: false,
          json: _info,
          // expandedAll: true,
        ),
      ),
    );
    showDialog(context: context, builder: (c) => dialog);
  }

  Widget _toolbar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: Row(
        children: [
          TextField(
            controller: _searchInputController,
            decoration: InputDecoration(
              constraints: BoxConstraints(minWidth: 200, maxWidth: 300, minHeight: 30, maxHeight: 30),
              border: OutlineInputBorder(),
              hintText: 'search keyword',
              contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 4),
              suffixIcon: IconButton(
                icon: Icon(Icons.clear),
                onPressed: () => _searchInputController!.text = "",
                constraints: BoxConstraints.tight(Size(32, 32)),
                splashRadius: 16,
                padding: EdgeInsets.zero,
                iconSize: 18,
                tooltip: 'clear',
              ),
            ),
            onSubmitted: (v) {
              // print(v);
            },
          ),
          SizedBox(width: 6),
          _IconButton(
            onPressed: _showFilter,
            icon: Icon(Icons.filter_alt),
            tooltip: 'Advanced filter',
          ),
          _IconButton(
            onPressed: _showExportDialog,
            icon: Icon(MaterialCommunityIcons.file_export),
            tooltip: 'Export csv',
          ),
          Spacer(),
          _IconButton(
            onPressed: _clearFilter,
            icon: Icon(MaterialCommunityIcons.restore),
            tooltip: 'Clear filter',
          ),
          SizedBox(width: 6),
          Tooltip(
            message: 'Apply on Track',
            child: OutlinedButton(
              onPressed: () {},
              child: Text('Apply'.toUpperCase()),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 6),
                minimumSize: Size(50, 34),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showExportDialog() async {
    _exportCsv(',');
  }

  void _exportCsv(String splitter) async {
    String title = "${logic?.track?.name}";
    var exported = const Utf8Encoder().convert('');
    var result = await FileUtil.saveByteData("$title.csv", exported);
    if (result) {
      showSuccessNotification(title: Text("$title.csv export success!"));
    }
    // await FileSaver.instance.saveFile("$title.csv", exported, ".csv");
  }

  _clearFilter() {
    logic!.setFilters(null);
    //todo
    // logic!.loadData();
  }

  _showFilter() async {
    var columns = logic!.filterColumns;
    List<FilterItem>? filters = await showTableFilterDialog(context, columns, filters: logic!.filters);
    if (null == filters) return;
    logic!.setFilters(filters);
    //todo
    // logic!.loadData();
  }

  Widget _IconButton({required Icon icon, VoidCallback? onPressed, String? tooltip}) {
    return IconButton(
      onPressed: onPressed,
      constraints: BoxConstraints.tight(Size(40, 40)),
      splashRadius: 20,
      padding: EdgeInsets.zero,
      iconSize: 20,
      icon: icon,
      tooltip: tooltip,
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
