import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/components/markdown_widget.dart';
import 'package:flutter_smart_genome/page/help/user_manual.dart';
import 'package:flutter_smart_genome/page/help/version_history.dart';
import 'package:flutter_smart_genome/widget/split_widget.dart' as sw;
import 'package:flutter_smart_genome/widget/splitlayout/grid_spliter.dart';

Future<T?> showHelpDialog<T>(BuildContext context) {
  var size = MediaQuery.of(context).size;
  var dialog = AlertDialog(
    // title: Text('Help'),
    content: Container(
      constraints: BoxConstraints.tightFor(width: size.width * .8, height: size.height * .8),
      child: HelpWidget(),
    ),
  );
  return showGeneralDialog<T?>(
    context: context,
    barrierColor: Theme.of(context).colorScheme.background.withOpacity(.95),
    // Colors.black54.withOpacity(.35),
    barrierDismissible: true,
    barrierLabel: 'Help',
    transitionDuration: Duration(milliseconds: 450),
    pageBuilder: (ctx, a1, a2) {
      return Container();
    },
    transitionBuilder: (ctx, a1, a2, child) {
      var curve = Curves.decelerate.transform(a1.value);
      return Transform.scale(scale: curve, child: Opacity(opacity: a1.value, child: dialog));
    },
  );

  // return showDialog<T>(context: context, builder: (c) => dialog);
}

class HelpWidget extends StatefulWidget {
  @override
  _HelpWidgetState createState() => _HelpWidgetState();
}

class _HelpWidgetState extends State<HelpWidget> {
  List menus = [
    {'title': 'User Manual', 'icon': Icons.chrome_reader_mode_outlined, 'key': 'user-manual', 'doc': userManual},
    {'title': 'Version Update', 'icon': Icons.update_rounded, 'key': 'version', 'doc': versionHistory},
  ];

  Map? _currentMenu;

  @override
  void initState() {
    super.initState();
    _currentMenu = menus.first;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: sw.Split(
        axis: Axis.horizontal,
        initialFractions: [.2, .8],
        minSizes: [200, 800],
        splitters: [
          SizedBox(width: 2, child: GridSplitter(isHorizontal: true)),
        ],
        children: [
          _menuBar(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: SimpleMarkdownWidget(source: _currentMenu!['doc']),
          ),
        ],
      ),
    );
  }

  void _onMenuTap(Map menu) {
    _currentMenu = menu;
    setState(() {});
  }

  Widget _menuBar() {
    var children = menus.map((e) {
      return ListTile(
        selected: _currentMenu == e,
        leading: Icon(e['icon']),
        title: Text(e['title']),
        contentPadding: EdgeInsets.symmetric(horizontal: 10),
        onTap: () => _onMenuTap(e),
      );
    });
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: ListTile.divideTiles(tiles: children, context: context).toList(),
      ),
    );
  }
}
