import 'package:dartx/dartx.dart' as dx;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_smart_genome/service/sgs_config_service.dart';
import 'package:flutter_smart_genome/widget/split_widget.dart' as sw;
import 'package:flutter_smart_genome/widget/splitlayout/sider_wrapper.dart';
import 'edge_toolbar_widget.dart';
import 'grid_spliter.dart';
import 'side_tab_item.dart';

typedef HotKeyListener = void Function(HotKey hotKey);

class EdgeLayoutDelegate extends MultiChildLayoutDelegate {
  EdgeInsets edgeBarSize = EdgeInsets.fromLTRB(42, 30, 42, 30);

  EdgeLayoutDelegate({
    this.edgeBarSize = const EdgeInsets.fromLTRB(42, 30, 42, 30),
  });

  @override
  void performLayout(Size size) {
    Size leftSize, topSize, centerSize, rightSize, bottomSize;
    bool hasTopChild = hasChild(PanelPosition.top);
    bool hasLeftChild = hasChild(PanelPosition.left);
    bool hasRightChild = hasChild(PanelPosition.right);
    bool hasBottomChild = hasChild(PanelPosition.bottom);

    EdgeInsets _edgeBarSize =
        EdgeInsets.fromLTRB(hasLeftChild ? edgeBarSize.left : 0, hasTopChild ? edgeBarSize.top : 0, hasRightChild ? edgeBarSize.right : 0, hasBottomChild ? edgeBarSize.bottom : 0);

    if (hasTopChild) {
      topSize = layoutChild(PanelPosition.top, BoxConstraints.expand(height: _edgeBarSize.top, width: size.width));
      positionChild(PanelPosition.top, Offset.zero);
    }
    if (hasChild(PanelPosition.bottom)) {
      bottomSize = layoutChild(PanelPosition.bottom, BoxConstraints.expand(height: _edgeBarSize.bottom, width: size.width));
      positionChild(PanelPosition.bottom, Offset(0, size.height - _edgeBarSize.bottom));
    }
    if (hasChild(PanelPosition.left)) {
      leftSize = layoutChild(
        PanelPosition.left,
        BoxConstraints.expand(
          width: _edgeBarSize.left,
          height: size.height - _edgeBarSize.vertical,
        ),
      );
      positionChild(PanelPosition.left, Offset(0, _edgeBarSize.top));
    }

    if (hasChild(PanelPosition.right)) {
      rightSize = layoutChild(
        PanelPosition.right,
        BoxConstraints.expand(
          width: _edgeBarSize.right,
          height: size.height - _edgeBarSize.vertical,
        ),
      );
      positionChild(PanelPosition.right, Offset(size.width - _edgeBarSize.right, _edgeBarSize.top));
    }

    if (hasChild(PanelPosition.center)) {
      centerSize = layoutChild(
        PanelPosition.center,
        BoxConstraints.expand(
          width: size.width - _edgeBarSize.horizontal,
          height: size.height - _edgeBarSize.vertical,
        ),
      );
      positionChild(PanelPosition.center, Offset(_edgeBarSize.left, _edgeBarSize.top));
    }
  }

  @override
  bool shouldRelayout(covariant MultiChildLayoutDelegate oldDelegate) {
    return false;
  }
}

typedef IdeWidgetBuilder = Widget Function(BuildContext context, PanelPosition position);

class AppContainer extends StatefulWidget {
  // final List<IdeEdgeComponent> components;
  final IdeWidgetBuilder builder;
  final List<TabItem> tabs;
  final List<TabItem> footers;
  final HotKeyListener? hotKeyListener;
  final ValueChanged<bool>? onFocusChange;

  final ValueChanged<TabItem>? onTabChange;

  AppContainer({
    Key? key,
    required this.tabs,
    this.footers = const [],
    this.onTabChange,
    required this.builder,
    this.hotKeyListener,
    this.onFocusChange,
  }) : super(key: key) {
    //
  }

  @override
  _AppContainerState createState() => _AppContainerState();
}

class _AppContainerState extends State<AppContainer> with TickerProviderStateMixin {
  Key _verSplitKey = Key('ver');
  Key _horSplitKey = Key('hor');

  late FocusNode _focusNode;
  bool _altKeyPressed = false;
  bool _controlKeyPressed = false;

  List<double> _hFractions = [.15, .7, .15];
  List<double> _vFractions = [.8, .2];

  sw.SplitController? _horSplitController;
  sw.SplitController? _verSplitController;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
    _horSplitController = sw.SplitController();
    _verSplitController = sw.SplitController();
  }

  void _onFocusChange() {
    widget.onFocusChange?.call(_focusNode.hasFocus);
  }

  TabItem? _selectedSideItem(PanelPosition position) {
    return (position == PanelPosition.bottom ? widget.footers : widget.tabs) //
        .firstOrNullWhere((e) => e.panelPosition == position && e.selected);
  }

  _updateSideItemFraction(List<double> fractions, Axis axis) {
    if (axis == Axis.horizontal) {
      final leftSideTabItem = _selectedSideItem(PanelPosition.left);
      final rightSideTabItem = _selectedSideItem(PanelPosition.right);
      if (fractions.first != 0) leftSideTabItem?.fraction = fractions.first;
      if (fractions.last != 0) rightSideTabItem?.fraction = fractions.last;
    } else {
      final bottomSideTabItem = _selectedSideItem(PanelPosition.bottom);
      if (fractions.last != 0) bottomSideTabItem?.fraction = fractions.last;
    }
  }

  double splitterWidth = 4;

  Widget _buildCenterWidget() {
    final bottomSideTabItem = _selectedSideItem(PanelPosition.bottom);
    final leftSideTabItem = _selectedSideItem(PanelPosition.left);
    final rightSideTabItem = _selectedSideItem(PanelPosition.right);
    bool hasRight = rightSideTabItem != null;
    bool hasLeft = leftSideTabItem != null;
    bool hasBottom = bottomSideTabItem != null;

    Widget _widget;
    bool hasBoth = hasLeft && hasRight;

    var centerFractions = 1.0 - (hasLeft ? leftSideTabItem.fraction : 0) - (hasRight ? rightSideTabItem.fraction : 0);
    List<double> hFractions = [
      (leftSideTabItem?.fraction ?? 0),
      centerFractions,
      (rightSideTabItem?.fraction ?? 0),
    ];

    _widget = sw.Split(
      key: _horSplitKey,
      axis: Axis.horizontal,
      controller: _horSplitController,
      onFractionChange: (fractions) => _updateSideItemFraction(fractions, Axis.horizontal),
      splitters: <SizedBox>[
        for (var i = 1; i < hFractions.length; i++) SizedBox(width: splitterWidth, child: GridSplitter(isHorizontal: true)),
      ],
      children: [
        _buildSidePanelWrapper(leftSideTabItem),
        widget.builder(context, PanelPosition.center),
        _buildSidePanelWrapper(rightSideTabItem),
      ],
      initialFractions: hFractions,
      minSizes: [
        (leftSideTabItem?.minWidth ?? 0),
        600,
        (rightSideTabItem?.minWidth ?? 0),
      ],
    );

    if (hasBottom) {
      _widget = _verticalSplit(
        [
          _widget,
          _buildSidePanelWrapper(bottomSideTabItem),
        ],
        hasBottom,
        bottomSideTabItem,
      );
    }
    return LayoutId(id: PanelPosition.center, child: _widget);
  }

  Widget _verticalSplit(List<Widget> children, bool hasBottom, TabItem? bottomSideTabItem) {
    List<double> vFractions = [
      1.0 - (bottomSideTabItem?.fraction ?? 0),
      (bottomSideTabItem?.fraction ?? 0),
    ];
    return sw.Split(
      key: _verSplitKey,
      axis: Axis.vertical,
      controller: _verSplitController,
      onFractionChange: (fractions) => _updateSideItemFraction(fractions, Axis.vertical),
      splitters: <SizedBox>[
        SizedBox(height: splitterWidth, child: GridSplitter(isHorizontal: false)),
      ],
      children: children,
      minSizes: [100, 200],
      initialFractions: vFractions,
    );
  }

  Widget _buildSidePanelWrapper(TabItem? item) {
    if (item == null) return SizedBox();
    List<TabItem> tabs = widget.tabs.where((e) => e.panelPosition == item.panelPosition).toList();
    return SidePanelWrapper(
      tabItem: item,
      child: widget.builder(context, item.panelPosition),
      onChangePosition: (item, p) {
        widget.onTabChange?.call(item);
      },
    );
  }

  Widget _buildEdgeWidget(PanelPosition position) {
    List<TabItem> _items = widget.tabs.where((t) => t.tabPosition == position).toList();
    List<TabItem> _footers = widget.footers.where((t) => t.tabPosition == position).toList();
    if (_items.length > 0) {
      return LayoutId(
        child: EdgeToolbarWidget(
          position: position,
          tabs1: _items,
          footers: _footers,
          onChanged: (item) {
            // widget.onTabChange?.call(item);
            _toggleTabItem(item);
          },
        ),
        id: position,
      );
    }
    return SizedBox();
  }

  void _toggleTabItem(TabItem item) {
    // if (item.panelPosition.isHor) {
    //   double l = item.panelPosition == PanelPosition.left ? (item.selected ? item.fraction : 0) : _horSplitController!.state!.fractions[0];
    //   double r = item.panelPosition == PanelPosition.left ? _horSplitController!.state!.fractions[2] : (item.selected ? item.fraction : 0);
    //   _horSplitController?.updateFractions([l, 1 - l - r, r]);
    // } else if (item.panelPosition.isVer) {
    //   double b = item.selected ? item.fraction : 0;
    //   _verSplitController?.updateFractions([
    //     1 - b,
    //     b,
    //   ]);
    // }
  }

  @override
  void didUpdateWidget(covariant AppContainer oldWidget) {
    // FocusScope.of(context).requestFocus(_focusNode);
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    super.dispose();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget container = Column(
      children: [
        Expanded(
          child: Row(
            children: [
              _buildEdgeWidget(PanelPosition.left),
              Expanded(child: _buildCenterWidget()),
              _buildEdgeWidget(PanelPosition.right),
            ],
          ),
        ),
        _buildEdgeWidget(PanelPosition.bottom),
      ],
    );
    // Widget container = Container(
    //   constraints: BoxConstraints.expand(),
    //   child: CustomMultiChildLayout(
    //     delegate: EdgeLayoutDelegate(),
    //     children: <Widget>[
    //       _buildEdgeWidget(PanelPosition.left),
    //       _buildEdgeWidget(PanelPosition.right),
    //       _buildEdgeWidget(PanelPosition.top),
    //       _buildEdgeWidget(PanelPosition.bottom),
    //       _buildCenterWidget(),
    //     ].where((w) => w is LayoutId).toList(),
    //   ),
    // );
    container = MouseRegion(
      onEnter: _handleMouseEnter,
      onExit: _handleMouseExit,
      onHover: _handleMouseHover,
      child: container,
    );
    return RawKeyboardListener(
      autofocus: true, //fix bug,input field cannot copy past
      focusNode: _focusNode,
      child: container,
      onKey: _handleKeyEvent,
    );
  }

  void _handleMouseEnter(PointerEnterEvent event) {
    //fix bug,input field cannot copy past
    // _focusNode.requestFocus();
  }

  void _handleMouseExit(PointerExitEvent event) {
    //fix bug,input field cannot copy past
    // _focusNode.unfocus();
  }

  void _handleMouseHover(PointerHoverEvent event) {
    // mouseHoverX = event.localPosition.dx;
  }

  void _handleKeyEvent(RawKeyEvent event) {
    _altKeyPressed = event.isAltPressed;
    _controlKeyPressed = event.isControlPressed;
    SgsConfigService.get()!.altPressed = event.isAltPressed;
    SgsConfigService.get()!.shiftPressed = event.isShiftPressed;
    SgsConfigService.get()!.ctrlPressed = event.isControlPressed;
    if (event is RawKeyDownEvent) {
      final keyLabel = event.data.keyLabel;
      widget.hotKeyListener?.call(HotKey(_altKeyPressed, _controlKeyPressed, event.isShiftPressed, keyLabel));
    }
  }
}
