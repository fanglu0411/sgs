import 'package:flutter/material.dart';

class BottomFloatControlWidget extends StatefulWidget {
  final List<Widget> children;
  final List<String> labels;

  const BottomFloatControlWidget({Key? key, this.children = const [], required this.labels}) : super(key: key);
  @override
  _BottomFloatControlWidgetState createState() => _BottomFloatControlWidgetState();
}

class _BottomFloatControlWidgetState extends State<BottomFloatControlWidget> {
  late int _index;
  late String _label;
  @override
  void initState() {
    super.initState();
    _index = 0;
    _label = widget.labels[_index];
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _indicators = widget.labels.map<Widget>((e) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: CircleAvatar(backgroundColor: e == _label ? Theme.of(context).colorScheme.primary : Colors.white70, radius: 3),
      );
    }).toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: PageView(
            onPageChanged: (int index) {
              setState(() {
                _index = index;
                _label = widget.labels[_index];
              });
            },
            children: widget.children,
          ),
        ),
        SizedBox(height: 5),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: _indicators,
        ),
      ],
    );
  }
}
