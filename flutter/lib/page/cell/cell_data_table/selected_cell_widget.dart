import 'package:bot_toast/bot_toast.dart';
import 'package:flutter_smart_genome/widget/basic/custom_bot_widget.dart';
import 'package:flutter_smart_genome/widget/basic/custom_spin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:flutter_smart_genome/base/container_config.dart';
import 'package:flutter_smart_genome/page/cell/cell_data_table/table_data_state.dart';
import 'package:flutter_smart_genome/widget/quick_data_grid/quick_data_grid.dart';
import 'package:flutter_smart_genome/widget/table/simple_data_table_source.dart';

import 'cell_data_table_widget.dart';

class SelectedCellWidget extends StatefulWidget {
  final SelectedFeatureState dataState;
  final ValueChanged<String>? onExportData;
  final VoidCallback? onClear;

  const SelectedCellWidget({
    super.key,
    required this.dataState,
    this.onExportData,
    this.onClear,
  });

  @override
  State<SelectedCellWidget> createState() => _SelectedCellWidgetState();
}

class _SelectedCellWidgetState extends State<SelectedCellWidget> {
  TextEditingController? _groupTextEditingController;

  @override
  void initState() {
    super.initState();
    _groupTextEditingController = TextEditingController();
  }

  Widget _builder(context, BoxConstraints constraints) {
    double rightWidth = 200;
    return Row(
      children: [
        Expanded(
          child: QuickDataGrid<Map>(
            data: widget.dataState.dataSource ?? [],
            headers: widget.dataState.headers,
            showCheckbox: false,
            // message: widget.dataState.error ?? widget.dataState.emptyMsg,
            cellBuilder: (c, Map item, v, col) {
              return Text('${item[col.dataKey]}', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontFamily: MONOSPACED_FONT, fontFamilyFallback: MONOSPACED_FONT_BACK));
            },
            minWidth: constraints.maxWidth - rightWidth,
          ),
          // CellDataTableWidget(
          //   headers: widget.dataState.headers,
          //   data: widget.dataState.dataSource ?? [],
          //   cellItemBuilder: _cellItemBuilder,
          //   showCheckBox: false,
          //   message: widget.dataState.error ?? widget.dataState.emptyMsg,
          // ),
        ),
        Container(
          width: rightWidth,
          // margin: EdgeInsets.only(left: 20),
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 20),
              TextField(
                controller: _groupTextEditingController,
                decoration: InputDecoration(
                  hintText: 'group name',
                  prefixIcon: Icon(Icons.edit, size: 16),
                  // prefixIconConstraints: BoxConstraints(maxHeight: 36),
                  // fillColor: Theme.of(context).dialogBackgroundColor.withAlpha(190),
                  filled: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(5), borderSide: BorderSide.none),
                  // focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(5), borderSide: BorderSide()),
                  alignLabelWithHint: true,
                  constraints: BoxConstraints(maxHeight: 32),
                  contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                ),
                cursorHeight: 16,
                onChanged: (v) {},
              ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                  icon: Icon(MaterialCommunityIcons.file_excel, size: 16),
                  onPressed: () {
                    var group = _groupTextEditingController!.text.trim();
                    if (group.length > 0) {
                      widget.onExportData?.call(group);
                    } else {
                      showToast(text: 'please input group name');
                    }
                  },
                  label: Text('Export csv')),
              SizedBox(height: 20),
              ElevatedButton.icon(
                icon: Icon(Icons.clear_all, size: 16),
                onPressed: widget.onClear,
                label: Text('Clear'),
              ),
            ],
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.dataState.loading) {
      return Center(child: CustomSpin(color: Theme.of(context).colorScheme.primary));
    }
    return LayoutBuilder(builder: _builder);
  }

  DataCell _cellItemBuilder(rowData, item, ColumnKey columnKey) {
    return DataCell(Text('${item}', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontFamily: MONOSPACED_FONT, fontFamilyFallback: MONOSPACED_FONT_BACK)));
  }
}
