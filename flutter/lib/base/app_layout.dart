import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';

enum AppLayout {
  gnome,
  SC,
  SG_h,
  SG_v,
}

AppLayout fromName(String name) {
  switch (name) {
    case 'gnome_Browse':
      return AppLayout.gnome;
    case 'sc_Browse':
      return AppLayout.SC;
    case 'SG_Browser_h':
      return AppLayout.SG_h;
    case 'SG_Browser_v':
      return AppLayout.SG_v;
    default:
      return AppLayout.gnome;
  }
}

Future<bool?> autoChangeScLayoutConfirm(BuildContext context) async {
  bool autoSwitch = false;
  return showDialog(
    context: context,
    builder: (c) {
      return AlertDialog(
        title: Text('Tips'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Text('Only sc data found, switch to sc-only view ?', style: Theme.of(context).textTheme.bodyLarge),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Text('- there is no genome track found!', style: Theme.of(context).textTheme.bodySmall),
            ),
            SizedBox(height: 6),
            AutoSwitchButton(
              checked: autoSwitch,
              onChange: (value) {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(c).pop(false);
            },
            child: Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(c).pop(true);
            },
            child: Text('YES'),
          ),
        ],
      );
    },
  );
}

class AutoSwitchButton extends StatefulWidget {
  final bool checked;
  final ValueChanged<bool>? onChange;
  final Function2<BuildContext, bool, Widget>? builder;

  const AutoSwitchButton({super.key, this.checked = false, this.builder, this.onChange});

  @override
  State<AutoSwitchButton> createState() => _AutoSwitchButtonState();
}

class _AutoSwitchButtonState extends State<AutoSwitchButton> {
  late bool _checked;

  @override
  void initState() {
    super.initState();
    _checked = widget.checked;
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder?.call(context, _checked) ??
        TextButton.icon(
          onPressed: () {
            _checked = !_checked;
            setState(() {});
            widget.onChange?.call(_checked);
          },
          icon: Icon(_checked ? Icons.check_box : Icons.check_box_outline_blank),
          label: Text('Auto Switch'),
        );
  }
}