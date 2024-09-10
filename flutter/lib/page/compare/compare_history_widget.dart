import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';

class CompareHistoryWidget extends StatefulWidget {
  final List<List<String>> features;
  final ValueChanged<List<String>>? onTap;
  final ValueChanged<List<String>>? onDelete;

  const CompareHistoryWidget({
    super.key,
    required this.features,
    this.onTap,
    this.onDelete,
  });

  @override
  State<CompareHistoryWidget> createState() => _CompareHistoryWidgetState();
}

class _CompareHistoryWidgetState extends State<CompareHistoryWidget> {
  @override
  Widget build(BuildContext context) {
    if (widget.features.length == 0) {
      return Container(
        height: 60,
        child: Text('History is empty!'),
      );
    }
    double maxItemHeight = 32.0 * widget.features.maxBy((e) => e.length)!.length;
    double h = MediaQuery.of(context).size.height * .75;
    double _w = widget.features.flatten().maxBy((e) => e.length)!.length * 9.5;
    int maxColumns = 4;
    int columns = widget.features.length < maxColumns ? widget.features.length : maxColumns;

    return SizedBox(
      height: (maxItemHeight * (widget.features.length / columns).ceil()).clamp(maxItemHeight, h),
      width: _w * columns + 90,
      child: CustomScrollView(
        scrollDirection: Axis.vertical,
        slivers: [
          SliverGrid(
            delegate: SliverChildBuilderDelegate(itemBuilder, childCount: widget.features.length),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: columns, mainAxisExtent: maxItemHeight),
          )
        ],
      ),
    );
  }

  Widget itemBuilder(BuildContext context, int index) {
    return HistoryItemView(
      data: widget.features[index],
      onTap: widget.onTap,
      onDelete: (item) {
        widget.features.removeAt(index);
        setState(() {});
        widget.onDelete?.call(item);
      },
    );
    return ListTile(
      title: Text(""),
      subtitle: Wrap(
        runSpacing: 10,
        spacing: 10,
        children: widget.features[index]
            .map((e) => Container(
                  child: Text(e),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Theme.of(context).colorScheme.primaryContainer,
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                ))
            .toList(),
      ),
      onTap: () => widget.onTap?.call(widget.features[index]),
    );
  }
}

class HistoryItemView extends StatefulWidget {
  final List<String> data;
  final ValueChanged<List<String>>? onTap;
  final ValueChanged<List<String>>? onDelete;

  const HistoryItemView({super.key, required this.data, this.onTap, this.onDelete});

  @override
  State<HistoryItemView> createState() => _HistoryItemViewState();
}

class _HistoryItemViewState extends State<HistoryItemView> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      // color: Theme.of(context).canvasColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      child: InkWell(
        // radius: 5,
        onHover: (v) {
          _hover = v;
          setState(() {});
        },
        borderRadius: BorderRadius.circular(4),
        child: Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: widget.data
                  .map((e) => Padding(
                        child: Text(e),
                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      ))
                  .toList(),
            ),
            if (_hover)
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.errorContainer,
                    borderRadius: BorderRadius.only(bottomLeft: Radius.circular(5), bottomRight: Radius.circular(5)),
                  ),
                  child: IconButton(
                    onPressed: () => widget.onDelete?.call(widget.data),
                    icon: Icon(Icons.delete),
                    style: IconButton.styleFrom(
                      foregroundColor: Colors.red,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
                    ),
                    splashRadius: 20,
                    constraints: BoxConstraints.tightFor(width: 32, height: 32),
                    padding: EdgeInsets.zero,
                  ),
                ),
              ),
          ],
        ),
        onTap: () => widget.onTap?.call(widget.data),
      ),
    );
  }
}
