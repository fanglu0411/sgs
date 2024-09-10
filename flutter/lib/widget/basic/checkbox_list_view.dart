import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';

class CheckboxListView<T> extends StatefulWidget {
  final bool useListView;
  final List<T> data;
  final ValueChanged<List<T>>? onSelectionChanged;
  final Function1<T, String>? titleBuilder;

  const CheckboxListView({
    super.key,
    this.useListView = true,
    required this.data,
    this.titleBuilder,
    this.onSelectionChanged,
  });

  @override
  State<CheckboxListView> createState() => _CheckboxListViewState<T>();
}

class _CheckboxListViewState<T> extends State<CheckboxListView<T>> {
  late Map<T, bool> _selectedMap;

  @override
  void initState() {
    super.initState();
    _selectedMap = Map.fromIterable(widget.data, value: (e) => false);
  }

  @override
  Widget build(BuildContext context) {
    var children = widget.data.mapIndexed<Widget>((i, e) => _buildItem(i, e)).toList();
    if (widget.useListView) {
      return ListView.builder(
        itemBuilder: (c, i) => _buildItem(i, widget.data[i]),
        itemCount: widget.data.length,
      );
    }
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }

  Widget _buildItem(int index, T item) {
    return CheckboxListTile(
      value: _selectedMap[item],
      title: Text(widget.titleBuilder?.call(item) ?? '${item}'),
      onChanged: (v) {
        _selectedMap[item] = v!;
        setState(() {});
        List<T> selectedList = widget.data.where((e) => _selectedMap[e]!).toList();
        widget.onSelectionChanged?.call(selectedList);
      },
    );
  }
}