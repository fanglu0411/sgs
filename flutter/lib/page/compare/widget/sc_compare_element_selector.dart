import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/page/cell/cell_base.dart';
import 'package:flutter_smart_genome/page/cell/cell_page/cell_page_logic.dart';
import 'package:flutter_smart_genome/widget/basic/custom_bot_widget.dart';
import 'package:flutter_smart_genome/widget/track/base/track_data.dart';

import '../compare_logic.dart';

class SCCompareElementSelector extends StatefulWidget {
  final List<SCViewType> types;
  final String matrix;
  final SCViewType type;
  final ValueChanged<CompareElement>? onAddElement;

  const SCCompareElementSelector({Key? key, required this.type, required this.matrix, this.onAddElement, required this.types}) : super(key: key);

  @override
  _SCCompareElementsViewState createState() => _SCCompareElementsViewState();
}

class _SCCompareElementsViewState extends State<SCCompareElementSelector> {
  // List<CompareElement> _types;

  int _selectedElementIndex = 0;

  late SCViewType _type;
  late String _matrix;
  String? _plotType;
  late String _category;
  Spatial? _spatial;

  @override
  void initState() {
    super.initState();
    // _types = widget.types;
    _type = widget.type;
    _matrix = widget.matrix;
    _plotType = CellPageLogic.safe()!.currentChartLogic.state.mod!.plots.first;
    _category = CellPageLogic.safe()!.categories.keys.first;
  }

  @override
  void didUpdateWidget(covariant SCCompareElementSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    _type = widget.type;
    _matrix = widget.matrix;
  }

  @override
  Widget build(BuildContext context) {
    final dropdownWidth = 320.0;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Center(
        //   child: ToggleButtonGroup(
        //     constraints: BoxConstraints.tightFor(height: 36),
        //     selectedIndex: _selectedElementIndex,
        //     borderRadius: BorderRadius.circular(4),
        //     onChange: (v) {
        //       _selectedElementIndex = v;
        //       _type = widget.types[_selectedElementIndex];
        //     },
        //     children: widget.types.map((e) {
        //       final icon = e == SCViewType.motif
        //           ? SvgPicture.string(iconMotifLogo, width: 50)
        //           : (e == SCViewType.violin
        //               ? Padding(
        //                   padding: const EdgeInsets.symmetric(horizontal: 10),
        //                   child: SvgPicture.string(iconViolin, height: 24),
        //                 )
        //               : Padding(
        //                   padding: const EdgeInsets.symmetric(horizontal: 10.0),
        //                   child: Icon(CompareLogic.get()!.chartTypeIcon(e), size: 26),
        //                 ));
        //       return Tooltip(message: e.name, child: icon);
        //     }).toList(),
        //   ),
        // ),
        Text('Add ${widget.type.name}', style: Theme.of(context).textTheme.bodyLarge),
        SizedBox(height: 16),
        DropdownMenu<String>(
          inputDecorationTheme: InputDecorationTheme(
            isDense: true,
            border: OutlineInputBorder(),
            constraints: BoxConstraints.expand(height: 32),
            contentPadding: EdgeInsets.symmetric(horizontal: 12),
            alignLabelWithHint: true,
          ),
          label: Text('Mod: '),
          width: dropdownWidth,
          enabled: false,
          onSelected: (v) {
            _matrix = v!;
          },
          initialSelection: _matrix,
          dropdownMenuEntries: CellPageLogic.safe()!.matrixList.map((k) {
            return DropdownMenuEntry<String>(
              value: k.id,
              label: k.name,
            );
          }).toList(),
        ),
        if (widget.type == SCViewType.scatter) SizedBox(height: 16),
        if (widget.type == SCViewType.scatter)
          DropdownMenu<String>(
            inputDecorationTheme: InputDecorationTheme(
              isDense: true,
              border: OutlineInputBorder(),
              constraints: BoxConstraints.expand(height: 32),
              contentPadding: EdgeInsets.symmetric(horizontal: 12),
              alignLabelWithHint: true,
            ),
            label: Text('Plot: '),
            width: dropdownWidth,
            onSelected: (v) {
              _plotType = v!;
              _spatial = null;
              setState(() {});
            },
            initialSelection: _plotType,
            dropdownMenuEntries: CellPageLogic.safe()!.currentChartLogic.state.mod!.plots.map((k) {
              return DropdownMenuEntry<String>(
                value: k,
                label: k,
              );
            }).toList(),
          ),
        if (_plotType == Spatial.SPATIAL_PLOT && CellPageLogic.safe()!.currentChartLogic.state.mod!.hasSpatials)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: DropdownMenu<Spatial>(
              inputDecorationTheme: InputDecorationTheme(
                isDense: true,
                border: OutlineInputBorder(),
                constraints: BoxConstraints.expand(height: 32),
                contentPadding: EdgeInsets.symmetric(horizontal: 12),
                alignLabelWithHint: true,
              ),
              label: Text('Spatial: '),
              width: dropdownWidth,
              onSelected: (v) {
                _spatial = v!;
              },
              initialSelection: _spatial,
              dropdownMenuEntries: CellPageLogic.safe()!.currentChartLogic.state.mod!.spatials!.map((k) {
                return DropdownMenuEntry<Spatial>(
                  value: k,
                  label: k.key,
                );
              }).toList(),
            ),
          ),
        if (widget.type != SCViewType.scatter) SizedBox(height: 16),
        if (widget.type != SCViewType.scatter)
          DropdownMenu<String>(
            inputDecorationTheme: InputDecorationTheme(
              isDense: true,
              border: OutlineInputBorder(),
              constraints: BoxConstraints.expand(height: 32),
              contentPadding: EdgeInsets.symmetric(horizontal: 12),
              alignLabelWithHint: true,
            ),
            label: Text('Category: '),
            width: dropdownWidth,
            onSelected: (v) {
              _category = v!;
            },
            initialSelection: _category,
            dropdownMenuEntries: CellPageLogic.safe()!.categories.keys.map((k) {
              return DropdownMenuEntry<String>(
                value: k,
                label: k,
              );
            }).toList(),
          ),
        SizedBox(height: 16),
        ElevatedButton(onPressed: _addElement, child: Text('Add Plot')),
      ],
    );
  }

  void _addElement() {
    if ((_plotType == Spatial.SPATIAL_PLOT && CellPageLogic.safe()!.currentChartLogic.state.mod!.hasSpatials) && _spatial == null) {
      showToast(text: 'please select spatial');
      return;
    }
    var ele = CompareElement(
      type: _type,
      matrix: _matrix,
      plotType: _plotType,
      category: _category,
      checked: true,
      spatial: _spatial,
    );
    widget.onAddElement?.call(ele);
  }
}
