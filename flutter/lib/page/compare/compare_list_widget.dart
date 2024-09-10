import 'package:flutter/material.dart';

import 'package:flutter_smart_genome/widget/loading_widget.dart';
import 'compare_common.dart';

class CompareListWidget extends StatefulWidget {
  final List<CompareItem> compareList;

  final VoidCallback? onClear;
  final ValueChanged<List<CompareItem>>? onCompare;

  const CompareListWidget({
    Key? key,
    this.compareList = const [],
    this.onClear,
    this.onCompare,
  }) : super(key: key);

  @override
  _CompareListWidgetState createState() => _CompareListWidgetState();
}

class _CompareListWidgetState extends State<CompareListWidget> {
  List<CompareItem> _compareList = [];

  @override
  void initState() {
    super.initState();
    _compareList = widget.compareList;
  }

  @override
  Widget build(BuildContext context) {
    var _items = _compareList.map(_itemBuilder);
    var buttons = [
      TextButton.icon(
        onPressed: _onClear,
        icon: Icon(Icons.clear_all),
        label: Text('Clear'),
      ),
      TextButton.icon(
        onPressed: () {
          if (widget.onCompare != null) {
            widget.onCompare!(_compareList);
          }
        },
        icon: Icon(Icons.compare),
        label: Text('Compare'),
      ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(children: buttons.map((e) => Expanded(child: e)).toList()),
        Expanded(
          child: _compareList.isEmpty
              ? LoadingWidget(
                  loadingState: LoadingState.noData,
                  message: 'No Item to compare',
                )
              : ListView(
                  children: ListTile.divideTiles(context: context, tiles: _items).toList(),
                ),
        )
      ],
    );
  }

  Widget _itemBuilder(CompareItem item) {
    return ListTile(
      dense: true,
      title: Text(item.title),
      subtitle: Text(item.subTitle),
      visualDensity: VisualDensity.compact,
      trailing: IconButton(
        constraints: BoxConstraints.tightFor(width: 24, height: 24),
        iconSize: 20,
        splashRadius: 20,
        padding: EdgeInsets.zero,
        icon: Icon(Icons.close),
        onPressed: () {
          _compareList.remove(item);
          setState(() {});
        },
      ),
      onTap: () {},
    );
  }

  void _onClear() {
    _compareList.clear();
    setState(() {});
  }
}