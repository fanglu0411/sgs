import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/widget/basic/simple_meu_widget.dart';
import 'package:flutter_smart_genome/widget/navigation_bar.dart';

mixin ExpressionPageMixin<T extends StatefulWidget> on State<T> {
  final List<NavigationBarItem> menuItems = [
    NavigationBarItem(
      title: Text('Input'),
      icon: Icon(Icons.insert_drive_file),
      tooltip: 'Input file',
      type: 'file',
    ),
    NavigationBarItem(title: Text('Download Data'), icon: Icon(Icons.file_download), tooltip: 'Download Data', type: 'download'),
    NavigationBarItem(
      title: Text('Save Image'),
      icon: Icon(Icons.image),
      tooltip: 'Save Image',
      type: 'save',
    ),
  ];

  List<SMenuItem> _chartTypeMenu = [];

  List<SMenuItem> get chartTypeMenus => _chartTypeMenu;

  set chartTypeMenus(List<SMenuItem> items) {
    _chartTypeMenu = items;
  }

  List<Widget> buildActions() {
    return menuItems
        .map((e) => IconButton(
              icon: e.icon!,
              onPressed: () {},
              tooltip: e.tooltip,
            ))
        .toList();
  }

  int currentViewTypeIndex = 0;

  Widget buildMobileBody() {
    return IndexedStack(
      sizing: StackFit.expand,
      index: currentViewTypeIndex,
      children: <Widget>[
        buildChartWidget(),
        buildDataWidget(),
      ],
    );
  }

  Widget buildChartWidget();

  Widget buildDataWidget();

  String chartType = 'heatmap';

  Widget buildTabletBody() {
    return Container(
      decoration: BoxDecoration(
//        border: Border.all(color: Colors.green[200], width: 2),
        borderRadius: BorderRadius.all(Radius.circular(3)),
        color: Colors.lightGreen[50],
      ),
      child: Column(
        children: <Widget>[
          Container(
            height: 48,
            child: Row(
              children: <Widget>[
                SizedBox(width: 20),
                if (currentViewTypeIndex == 0 && chartTypeMenus.isNotEmpty)
                  Text(
                    'Chart Type:  ',
                    style: TextStyle(fontWeight: FontWeight.w200),
                  ),
                if (currentViewTypeIndex == 0 && chartTypeMenus.isNotEmpty)
                  DropdownButton<String>(
                    value: chartType,
                    items: chartTypeMenus.map<DropdownMenuItem<String>>((e) => DropdownMenuItem<String>(child: Text(e.label!), value: e.type)).toList(),
                    onChanged: (v) {
                      setState(() {
                        chartType = v!;
                      });
                    },
                  ),
                if (currentViewTypeIndex == 1)
                  Text(
                    'Data Source Table',
                    style: TextStyle(fontWeight: FontWeight.w400, fontSize: 18),
                  ),
                Expanded(child: SizedBox()),
                CupertinoSegmentedControl<int>(
                    selectedColor: Theme.of(context).colorScheme.primary,
                    borderColor: Theme.of(context).colorScheme.primary,
                    groupValue: currentViewTypeIndex,
                    children: <int, Widget>{
                      0: Tooltip(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: Icon(Icons.show_chart),
                          ),
                          message: 'Chart'),
                      1: Tooltip(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: Icon(Icons.grid_on),
                          ),
                          message: 'Data'),
                    },
                    onValueChanged: (index) {
                      setState(() {
                        currentViewTypeIndex = index;
                      });
                    }),
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.lightBlue[50],
              child: IndexedStack(
                index: currentViewTypeIndex,
                children: <Widget>[
                  buildChartWidget(),
                  buildDataWidget(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
