import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/base/container_config.dart';
import 'package:dartx/dartx.dart' as dx;

class ClusterPopWidget extends StatefulWidget {
  final ValueChanged<List>? onChanged;
  final String group;
  final List clusters;
  final String? checkedCluster;
  final bool clearable;
  final VoidCallback? onClear;

  ClusterPopWidget({
    Key? key,
    required this.group,
    this.clusters = const [],
    this.clearable = false,
    this.checkedCluster,
    this.onChanged,
    this.onClear,
  }) : super(key: key);

  @override
  _ClusterPopWidgetState createState() => _ClusterPopWidgetState();
}

class _ClusterPopWidgetState extends State<ClusterPopWidget> {
  String? _checkValue;

  @override
  void initState() {
    super.initState();
    _checkValue = widget.checkedCluster;
  }

  @override
  void didUpdateWidget(covariant ClusterPopWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    var maxC = widget.clusters.maxBy((c) => '${c}'.length);
    int maxLength = '${maxC!}'.length;
    return SingleChildScrollView(
      child: Wrap(
        direction: Axis.vertical,
        alignment: WrapAlignment.start,
        crossAxisAlignment: WrapCrossAlignment.start,
        spacing: 10,
        runSpacing: 10,
        children: [
          if (_checkValue != null && widget.clearable)
            TextButton.icon(
              onPressed: widget.onClear,
              icon: Icon(Icons.clear_all),
              label: Text('Clear'),
              style: TextButton.styleFrom(
                minimumSize: Size(40, 24),
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              ),
            ),
          ...widget.clusters.map((e) {
            return InkWell(
              borderRadius: BorderRadius.circular(5),
              onTap: () {
                if (e == _checkValue) return;
                _toggleChecked(e);
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Radio<String>.adaptive(value: e, groupValue: _checkValue, onChanged: _toggleChecked),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      minWidth: maxLength * 8.0,
                    ),
                    child: Text(
                      e,
                      style: TextStyle(fontSize: 14, fontFamily: MONOSPACED_FONT, fontFamilyFallback: MONOSPACED_FONT_BACK),
                    ),
                  ),
                  SizedBox(width: 10),
                ],
              ),
            );
          })
        ],
      ),
    );
  }

  void _toggleChecked(String? item) {
    _checkValue = item;
    setState(() {});
    widget.onChanged?.call([widget.group, item!]);
  }
}
