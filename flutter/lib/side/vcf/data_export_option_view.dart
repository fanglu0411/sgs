import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/widget/toggle_button_group.dart';

class TableExportOptionView extends StatefulWidget {
  final ValueChanged<String>? onSplitterChange;
  const TableExportOptionView({Key? key, this.onSplitterChange}) : super(key: key);

  @override
  State<TableExportOptionView> createState() => _TableExportOptionViewState();
}

class _TableExportOptionViewState extends State<TableExportOptionView> {
  List _splitters = [',', ';'];

  int _selectedIndex = 0;
  int _splitterIndex = 0;

  void _onFileFormatChange(int i) {
    _selectedIndex = i;
    // setState(() {});
    widget.onSplitterChange?.call(_splitters[i]);
  }

  void _onSplitChange(int i) {
    _splitterIndex = i;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Splitter: '),
          ToggleButtonGroup(
            borderRadius: BorderRadius.circular(5),
            constraints: BoxConstraints.tightFor(height: 30, width: 40),
            children: _splitters.map<Widget>((e) => Text('${e}')).toList(),
            selectedIndex: _selectedIndex,
            onChange: _onFileFormatChange,
          ),
        ],
      ),
    );
  }
}