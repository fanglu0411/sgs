import 'dart:math';

import 'package:flutter/material.dart';
import 'package:dartx/dartx.dart';
import 'collapsible_mixin.dart';
import 'trees.dart';

typedef WidgetItemBuilder = Widget Function(BuildContext context, TreeNode node);

class SimpleMapTreeNode extends TreeNode<SimpleMapTreeNode> {
  dynamic title;
  dynamic value;

  Map? sourceMap;

  SimpleMapTreeNode({required this.title, this.value = null}) {}

  static List<SimpleMapTreeNode> fromMap(Map map, {List skipKeys = const [], bool expandAll = false}) {
    List<SimpleMapTreeNode> nodes = [];
    List<MapEntry> entries = map.entries.sortedWith((a, b) {
      int _a = a.value is Map ? 1 : 0;
      int _b = b.value is Map ? 1 : 0;
      return _a - _b;
    }).toList();

    for (MapEntry entry in entries) {
      var key = entry.key;
      var value = entry.value;
      if (skipKeys.contains(key)) continue;
      SimpleMapTreeNode node = fromValue(key).first;
      node.title = key;
      if (value is Map || value is List) {
        List<SimpleMapTreeNode> children = fromValue(value, expandAll);
        if (value is List && value.length < 2) {
          node.value = value.join(', ');
        } else if (children.length > 0 || (children.length > 0 && children.first.isExpandable)) {
          node.addAllChildren(children);
          node.value = null;
        } else {
          node.value = children.isEmpty ? null : children.first.title;
        }
        if (expandAll) node.toggleExpansion();
      } else {
        node.value = value;
      }
      nodes.add(node);
    }

    // entries.forEach((entry) {
    //   var k = entry.key;
    //   var value = entry.value;
    // });
    // map.forEach((key, value) {
    //   if (skipKeys != null && skipKeys.contains(key)) return;
    //   SimpleMapTreeNode node = fromValue(key).first;
    //   node.title = key;
    //   if (value is Map || value is List) {
    //     List<SimpleMapTreeNode> children = fromValue(value, expandAll);
    //     if (value is List && value.length < 2) {
    //       node.value = value.join(', ');
    //     } else if (children.length > 0 || (children.length > 0 && children.first.isExpandable)) {
    //       node.addAllChildren(children);
    //       node.value = null;
    //     } else {
    //       node.value = children.isEmpty ? null : children.first.title;
    //     }
    //     if (expandAll) node.toggleExpansion();
    //   } else {
    //     node.value = value;
    //   }
    //   nodes.add(node);
    // });
    return nodes;
  }

  static List<SimpleMapTreeNode> fromValue(value, [bool expandAll = false]) {
    if (value is Map) {
      return fromMap(value, expandAll: expandAll);
    }
    if (value is List) {
      if (value.length == 0) return <SimpleMapTreeNode>[];
      return value.map<SimpleMapTreeNode>((e) {
        List<SimpleMapTreeNode> list = fromValue(e, expandAll);
        if (list.length > 0) return list.first;
        return SimpleMapTreeNode(title: '');
      }).toList();
    }
    return [SimpleMapTreeNode(title: value)];
  }

  @override
  String toString() {
    return 'TreeNode{title: $title, value: $value}';
  }
}

class TreeView<T extends TreeNode<T>> extends StatefulWidget {
  const TreeView({
    required this.dataRoots,
    required this.dataDisplayProvider,
    this.onItemPressed,
    this.shrinkWrap = false,
    this.controller,
    this.parentNodeColor,
  });

  final ScrollController? controller;
  final bool shrinkWrap;
  final List<T> dataRoots;
  final Color? parentNodeColor;

  final Widget Function(T) dataDisplayProvider;

  final void Function(T)? onItemPressed;

  @override
  _TreeViewState<T> createState() => _TreeViewState<T>();
}

class _TreeViewState<T extends TreeNode<T>> extends State<TreeView<T>> with TreeMixin<T> {
  @override
  void initState() {
    super.initState();
    _initData();
    _updateItems();
  }

  @override
  void didUpdateWidget(TreeView<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    // if (widget.dataRoots != oldWidget.dataRoots) {
    //   _initData();
    //   _updateItems();
    // }
    _initData();
    _updateItems();
  }

  void _initData() {
    dataRoots = List.from(widget.dataRoots);
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: widget.controller,
      shrinkWrap: widget.shrinkWrap,
      itemCount: items!.length,
      // itemExtent: 36,
      itemBuilder: (context, index) {
        final item = items![index];
        return TreeViewItem<T>(
          item,
          display: widget.dataDisplayProvider(item),
          onItemPressed: _onItemPressed,
          parentColor: widget.parentNodeColor,
        );
      },
    );
  }

  // animate expansions and collapses.
  void _onItemPressed(T item) {
    if (item.isExpandable) {
      // Order of execution matters for the below calls.
      item.toggleExpansion();
    } else {}
    widget.onItemPressed?.call(item);
    _updateItems();
  }

  void _updateItems() {
    setState(() {
      items = buildFlatList(dataRoots!);
    });
  }
}

class TreeViewItem<T extends TreeNode<T>> extends StatefulWidget {
  const TreeViewItem(this.data, {this.display, this.onItemPressed, this.parentColor});

  final T data;
  final Color? parentColor;

  final Widget? display;

  final void Function(T)? onItemPressed;

  @override
  _TreeViewItemState<T> createState() => _TreeViewItemState<T>();
}

class _TreeViewItemState<T extends TreeNode<T>> extends State<TreeViewItem<T>> with TickerProviderStateMixin, CollapsibleAnimationMixin {
  @override
  Widget build(BuildContext context) {
    double indent = nodeIndent(widget.data);
    return InkWell(
      onTap: _onPressed,
      child: Container(
        padding: EdgeInsets.only(left: indent),
        color: widget.data.isExpandable ? widget.parentColor : null,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.data.isExpandable)
              Container(
                color: Theme.of(context).colorScheme.primary.withOpacity(.15),
                margin: EdgeInsets.only(right: 2),
                child: RotationTransition(
                  turns: expandArrowAnimation!,
                  child: Icon(Icons.keyboard_arrow_down, size: 16),
                ),
              ),
            Expanded(child: widget.display!),
          ],
        ),
      ),
    );
  }

  @override
  bool get isExpanded => widget.data.isExpanded;

  @override
  void onExpandChanged(bool expanded) {}

  @override
  bool shouldShow() => widget.data.shouldShow();

  double nodeIndent(T dataObject) {
    return max((dataObject.level) * 18.0, 4);
  }

  void _onPressed() {
    widget.onItemPressed?.call(widget.data);
    setExpanded(widget.data.isExpanded);
  }
}

class RowItemWidget extends StatelessWidget {
  final Widget? leading;
  final Widget? title;

  final GestureTapCallback? onTap;

  const RowItemWidget({
    Key? key,
    this.leading,
    this.title,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          if (leading != null) leading!,
          if (title != null) Expanded(child: title!),
        ],
      ),
    );
  }
}

class TreeBorder extends Border {
  final BorderSide side;
  final double width;

  TreeBorder({this.side = const BorderSide(color: Colors.red, width: 2), this.width = 8});

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
//    return super.getInnerPath(rect, textDirection: textDirection);
    return _getPath(rect);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
//    return super.getOuterPath(rect, textDirection: textDirection);
    return _getPath(rect);
  }

  Path _getPath(Rect rect) {
    return Path()
      ..moveTo(rect.left, rect.top)
      ..lineTo(rect.left, rect.bottom - 8)
      ..relativeLineTo(this.width, 0);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection, BoxShape shape = BoxShape.rectangle, BorderRadius? borderRadius}) {
    canvas.drawPath(getOuterPath(rect), side.toPaint());
  }
}

mixin TreeMixin<T extends TreeNode<T>> {
  List<T>? dataRoots;

  List<T>? items;

  List<T> buildFlatList(List<T> roots) {
    final flatList = <T>[];
    for (T root in roots) {
      traverse(root, (n) {
        flatList.add(n);
        return n.isExpanded;
      });
    }
    return flatList;
  }

  void traverse(T? node, bool Function(T) callback) {
    if (node == null) return;
    final shouldContinue = callback(node);
    if (shouldContinue) {
      for (var child in node.children) {
        traverse(child, callback);
      }
    }
  }
}
