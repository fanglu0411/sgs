import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/theme/material_theme.dart';
import 'package:flutter_smart_genome/widget/splitlayout/app_container.dart';
import 'package:flutter_smart_genome/widget/splitlayout/side_tab_item.dart';

class ThemePreviewWidget extends StatelessWidget {
  final bool checked;
  final MaterialTheme theme;

  const ThemePreviewWidget({
    Key? key,
    required this.theme,
    this.checked = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: checked ? BorderSide(color: theme.primary, width: .8) : BorderSide.none,
      ),
      color: theme.background,
      clipBehavior: Clip.antiAlias,
      child: CustomMultiChildLayout(
        delegate: EdgeLayoutDelegate(edgeBarSize: EdgeInsets.fromLTRB(30, 30, 30, 30)),
        children: [
          LayoutId(
            id: PanelPosition.left,
            child: Container(
              decoration: BoxDecoration(
                color: theme.appBarBackground,
                border: Border(right: BorderSide(color: theme.border, width: 1)),
              ),
              constraints: BoxConstraints.expand(width: 100),
              child: Column(
                children: [
                  SizedBox(height: 10),
                  Icon(Icons.home, color: theme.primary, size: 14),
                  SizedBox(height: 10),
                  Icon(Icons.list, color: theme.primary, size: 14),
                ],
              ),
            ),
          ),
          LayoutId(
            id: PanelPosition.top,
            child: Container(
              decoration: BoxDecoration(
                color: theme.appBarBackground,
                border: Border(bottom: BorderSide(color: theme.border, width: 1)),
              ),

              // constraints: BoxConstraints.expand(height: 32),
              padding: EdgeInsets.symmetric(horizontal: 10),
              alignment: Alignment.centerLeft,
              child: Text(
                '${theme.name}',
                style: TextStyle(color: theme.whiteOrBlack, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          LayoutId(
            id: PanelPosition.center,
            child: Container(
              decoration: BoxDecoration(
                color: theme.background,
              ),
              constraints: BoxConstraints.expand(),
              child: checked ? Icon(Icons.check, color: theme.primary, size: 22) : null,
            ),
          ),
        ],
      ),
    );
  }
}
