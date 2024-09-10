import 'package:flutter/material.dart';

import '../compare_logic.dart';

class SCCompareElementsView extends StatefulWidget {
  final List<CompareElement> types;
  final ValueChanged<List<CompareElement>>? onOrderChange;
  final ValueChanged<CompareElement>? onCheckedChange;
  const SCCompareElementsView({Key? key,required this.types, this.onOrderChange, this.onCheckedChange}) : super(key: key);

  @override
  _SCCompareElementsViewState createState() => _SCCompareElementsViewState();
}

class _SCCompareElementsViewState extends State<SCCompareElementsView> {
  // List<CompareElement> _types;

  @override
  void initState() {
    super.initState();
    // _types = widget.types;
  }

  void _orderViewTypes(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) newIndex -= 1;
    var _types = widget.types;
    final element = _types.removeAt(oldIndex);
    _types.insert(newIndex, element);
    setState(() {});
    widget.onOrderChange?.call(_types);
  }

  @override
  Widget build(BuildContext context) {
    return ReorderableListView(
      shrinkWrap: true,
      onReorder: _orderViewTypes,
      children: widget.types.map((e) {
        return Container(
          key: Key('${e.type}'),
          decoration: BoxDecoration(border: Border(bottom: BorderSide(width: 1, color: Theme.of(context).dividerColor))),
          child: ListTile(
            horizontalTitleGap: 4,
            visualDensity: VisualDensity(horizontal: VisualDensity.minimumDensity, vertical: VisualDensity.minimumDensity),
            leading: Checkbox(
              value: e.checked,
              onChanged: (v) {
                e.checked = v!;
                setState(() {});
                widget.onCheckedChange?.call(e);
              },
            ),
            title: Text('${e.type.toString().split('.').last}'),
          ),
        );
      }).toList(),
    );
  }
}