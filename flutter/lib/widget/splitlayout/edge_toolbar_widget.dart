import 'package:flutter/material.dart';

import 'side_tab_item.dart';

class EdgeToolbarWidget extends StatefulWidget {
  final List<TabItem> tabs1;
  final List<TabItem> tabs2;
  final List<TabItem> footers;
  final ValueChanged<TabItem>? onChanged;
  final PanelPosition position;

  const EdgeToolbarWidget({
    Key? key,
    required this.position,
    this.tabs1 = const [],
    this.tabs2 = const [],
    this.footers = const [],
    this.onChanged,
  }) : super(key: key);

  @override
  _EdgeToolbarWidgetState createState() => _EdgeToolbarWidgetState();
}

class _EdgeToolbarWidgetState extends State<EdgeToolbarWidget> {
  bool _willAccept = false;

  @override
  void initState() {
    super.initState();
    _willAccept = false;
  }

  void _toggleSelection(TabItem tabItem, {bool footer = false}) {
    tabItem.selected = !tabItem.selected;
    if (tabItem.selected) {
      (footer ? widget.footers : widget.tabs1).forEach((e) {
        if (e != tabItem) e.selected = false;
      });
    }
    setState(() {});
    // List<TabItem> selectedItems = [...widget.tabs1, ...widget.tabs2].where((e) => e.selected).toList();
    widget.onChanged?.call(tabItem);
  }

  @override
  Widget build(BuildContext context) {
    // int truns = 0;
    // if (widget.position == EdgeLayoutPosition.left) truns = -1;
    // if (widget.position == EdgeLayoutPosition.right) truns = 1;
    bool vertical = widget.position == PanelPosition.left || widget.position == PanelPosition.right;

    var children = <Widget>[
      ...widget.tabs1.map((t) => _buildTabItemView(t)),
      Spacer(),
      ...widget.tabs2.map((t) => _buildTabItemView(t)),
      ...widget.footers.map((t) => _buildTabItemView(t, footer: true)),
      if (vertical) SizedBox(height: 10),
    ];
    // if (widget.position == EdgeLayoutPosition.left) children = children.reversed.toList();

    Widget toolBar = vertical ? Column(children: children) : Row(children: children);

    // if (widget.position == EdgeLayoutPosition.left || widget.position == EdgeLayoutPosition.right) {
    //   toolBar = RotatedBox(quarterTurns: truns, child: toolBar);
    // }

    toolBar = wrapWithDragTarget(toolBar);
    var border = BorderSide(color: Theme.of(context).dividerColor, width: 1.0);
    return Container(
      decoration: BoxDecoration(
        color: _willAccept ? Theme.of(context).splashColor : Theme.of(context).appBarTheme.backgroundColor,
        border: _willAccept
            ? Border.all(color: Theme.of(context).colorScheme.primary, width: 1.0)
            : Border(
                top: widget.position == PanelPosition.bottom ? border : BorderSide.none,
                right: widget.position == PanelPosition.left ? border : BorderSide.none,
                left: widget.position == PanelPosition.right ? border : BorderSide.none,
                bottom: widget.position == PanelPosition.top ? border : BorderSide.none,
              ),
      ),
      child: toolBar,
    );
  }

  Widget wrapWithDragTarget(Widget child) {
    return DragTarget<TabItem>(
      builder: (BuildContext context, List<TabItem?> candidateData, List rejectedData) {
        return child;
      },
      onWillAccept: (tabItem) {
        bool find = [...widget.tabs1, ...widget.tabs2].where((e) => e == tabItem).length > 0;
        if (find) return false;
        setState(() {
          _willAccept = true;
        });
        return true;
      },
      onLeave: (d) {
        setState(() {
          _willAccept = false;
        });
      },
      onAcceptWithDetails: (details) {
        TabItem tabItem = details.data;
        widget.tabs1.add(tabItem
          ..selected = false
          ..panelPosition = widget.position);
        setState(() {
          _willAccept = false;
        });
      },
      onAccept: (data) {
        setState(() {
          _willAccept = false;
        });
      },
    );
  }

  BorderRadiusGeometry _buttonBorderRadius() {
    if (widget.position == PanelPosition.left) {
      return BorderRadiusDirectional.only(
        topEnd: Radius.elliptical(6, 15),
        bottomEnd: Radius.elliptical(6, 15),
        // topStart: Radius.elliptical(20, 20),
        // bottomStart: Radius.elliptical(20, 20),
      );
    }
    if (widget.position == PanelPosition.right) {
      return BorderRadiusDirectional.only(
        // topEnd: Radius.elliptical(20, 20),
        // bottomEnd: Radius.elliptical(20, 20),
        topStart: Radius.elliptical(6, 15),
        bottomStart: Radius.elliptical(6, 15),
      );
    }
    if (widget.position == PanelPosition.bottom) {
      // return BorderRadiusDirectional.circular(2);
      return BorderRadiusDirectional.only(
        topStart: Radius.elliptical(1, 1),
        topEnd: Radius.elliptical(1, 1),
      );
    }
    return BorderRadiusDirectional.only(
      topStart: Radius.elliptical(1, 1),
      topEnd: Radius.elliptical(1, 1),
    );
    ;
  }

  Widget _buildTabItemView(TabItem tabItem, {bool footer = false}) {
    if (tabItem.builder != null) return tabItem.builder!.call(tabItem, context);
    bool leftOrRight = widget.position == PanelPosition.left || widget.position == PanelPosition.right;
    var t = Tooltip(
      message: '${tabItem.title} (${tabItem.hotKey?.print()})',
      child: LongPressDraggable(
        data: tabItem,
        feedbackOffset: widget.position == PanelPosition.left ? Offset(4, 4) : Offset(-4, 4),
        child: Padding(
          padding: leftOrRight ? const EdgeInsets.symmetric(vertical: 4) : EdgeInsets.symmetric(horizontal: 4),
          child: MaterialButton(
            padding: EdgeInsets.zero,
            // constraints: BoxConstraints.tightFor(width: 30, height: 30),
            // splashRadius: 15,
            // padding: EdgeInsets.symmetric(horizontal: 6),
            minWidth: leftOrRight ? 50 : 40,
            height: leftOrRight ? 42 : null,
            elevation: 0,
            focusElevation: 0,
            highlightElevation: 0,
            hoverElevation: 0,
            shape: BeveledRectangleBorder(
              borderRadius: _buttonBorderRadius(),
            ),
            textColor: tabItem.selected ? Colors.white : null,
            child: tabItem.icon,
            // label: Text('${tabItem.hotKey?.key ?? ''}. ${tabItem.title}', style: TextStyle(fontWeight: FontWeight.w300, fontSize: 12)),
            color: tabItem.selected ? Theme.of(context).colorScheme.primary : null,
            // tooltip: '${tabItem.hotKey?.key ?? ''}. ${tabItem.title}',
            onPressed: () {
              _toggleSelection(tabItem, footer: footer);
            },
          ),
        ),
        feedback: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).dividerColor, width: 1),
            borderRadius: BorderRadius.circular(5),
            color: Theme.of(context).colorScheme.primary.withOpacity(.5),
          ),
          child: TextButton.icon(
            icon: tabItem.icon,
            label: Text('${tabItem.hotKey?.key ?? ''}. ${tabItem.title}'),
            onPressed: null,
          ),
        ),
        onDragStarted: () {},
        onDragCompleted: () {
          setState(() {
            _willAccept = false;
          });
        },
        onDragEnd: (details) {
          if (details.wasAccepted) {
            widget.tabs1.remove(tabItem);
          }
        },
      ),
    );
    // ShowCaseItem showCaseItem = showCaseMap[tabItem.type];
    // if (showCaseItem != null && !BaseStoreProvider.get().showCaseFinish()) {
    //   return Showcase(
    //     key: showCaseItem.key,
    //     child: t,
    //     title: 'Tips',
    //     description: showCaseItem.info,
    //     disableMovingAnimation: true,
    //     overlayOpacity: .25,
    //     // overlayColor: Colors.teal.withAlpha(100),
    //   );
    // }
    return t;
  }
}
