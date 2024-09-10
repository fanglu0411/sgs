import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/widget/basic/simple_widget_builder.dart';

class MarkerSearchFilter extends StatefulWidget {
  final List<String> columns;
  final ValueChanged<(String, String)>? onChanged;

  const MarkerSearchFilter({super.key, required this.columns, this.onChanged});

  @override
  State<MarkerSearchFilter> createState() => _MarkerSearchFilterState();
}

class _MarkerSearchFilterState extends State<MarkerSearchFilter> {
  late String _column;
  late String _keyword;

  @override
  void initState() {
    super.initState();
    _column = widget.columns.first;
  }

//escompress -i "tSNE.coords.tsv" -o "output.lz4"
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Search in marker feature', style: Theme.of(context).textTheme.titleSmall),
        SizedBox(height: 16),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SimpleDropdownButton(
              items: widget.columns,
              initialValue: _column,
              onSelectedChange: (s) {
                _column = s;
              },
            ),
            TextField(
              autofocus: true,
              decoration: InputDecoration(
                constraints: BoxConstraints(maxWidth: 160, maxHeight: 30),
                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  style: IconButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  ),
                  iconSize: 16,
                  splashRadius: 15,
                  constraints: BoxConstraints.tightFor(width: 28, height: 28),
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    widget.onChanged?.call((_column, _keyword));
                  },
                ),
              ),
              onChanged: (v) {
                _keyword = v;
              },
              onSubmitted: (s) {
                _keyword = s;
                widget.onChanged?.call((_column, _keyword));
              },
            ),
          ],
        ),
      ],
    );
  }
}
