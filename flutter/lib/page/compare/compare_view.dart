import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/page/cell/cell_base.dart';
import 'package:flutter_smart_genome/page/compare/compare_history_widget.dart';
import 'package:flutter_smart_genome/page/compare/compare_logic.dart';
import 'package:flutter_smart_genome/page/compare/feature_input_widget.dart';
import 'package:flutter_smart_genome/page/compare/group/compare_group_view.dart';
import 'package:flutter_smart_genome/page/compare/group/compare_group_widget.dart';
import 'package:flutter_smart_genome/page/compare/group/compare_group_wrapper.dart';
import 'package:flutter_smart_genome/page/compare/group/item_plot.dart';
import 'package:flutter_smart_genome/page/compare/widget/sc_compare_element_selector.dart';
import 'package:flutter_smart_genome/widget/basic/bubble_icon_button.dart';
import 'package:flutter_smart_genome/widget/basic/custom_bot_widget.dart';
import 'package:flutter_smart_genome/widget/basic/linked_scroll_controller_group.dart';
import 'package:flutter_smart_genome/widget/toggle_button_group.dart';
import 'package:flutter_smart_genome/widget/track/base/track_data.dart';
import 'package:get/get.dart';

class CompareView extends StatefulWidget {
  final List<Map> features;
  final MatrixBean matrix;

  const CompareView({
    Key? key,
    required this.features,
    required this.matrix,
  }) : super(key: key);

  @override
  _CompareViewState createState() => _CompareViewState();
}

class _CompareViewState extends State<CompareView> {
  late CompareLogic _logic;

  Axis _axis = Axis.vertical;
  bool _showTitle = true;
  bool _showLabel = true;

  LinkedScrollControllerGroup? _horScrollControllerGroup;
  ScrollController? _verScrollController;

  Map<String, ScrollController> _horScrollControllers = {};

  double _columnWidth = 360;

  int _pageViewIndex = 0;

  @override
  void initState() {
    super.initState();
    _logic = CompareLogic.get() ?? Get.put(CompareLogic());
    _horScrollControllerGroup = LinkedScrollControllerGroup();
    _verScrollController = TrackingScrollController();
    _logic.setFeatures(widget.features, widget.matrix);
  }

  ScrollController safeScrollController(CompareElement ele) {
    String key = ele.type.name;
    if (_horScrollControllers[key] == null) _horScrollControllers[key] = _horScrollControllerGroup!.addAndGet();
    return _horScrollControllers[key]!;
  }

  @override
  void didUpdateWidget(covariant CompareView oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CompareLogic>(
      init: _logic,
      autoRemove: false,
      builder: (controller) => LayoutBuilder(
        builder: (c, constraints) => _builder(controller, constraints),
      ),
    );
  }

  Widget _builder(CompareLogic logic, BoxConstraints constraints) {
    // var header = _buildHeader(constraints.biggest);

    var contentWidth = _columnWidth * _logic.genes.length + 32;
    if (constraints.biggest.width > contentWidth) {
      contentWidth = constraints.biggest.width;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        buildToolBar(constraints),
        Expanded(
          child: _logic.checkedElements.length == 0 || _logic.genes.length == 0
              ? _buildEmpty()
              : CustomScrollView(
                  slivers: _buildCompareGroups(constraints),
                  controller: _verScrollController,
                ),
        ),
      ],
    );
  }

  List<Widget> _buildCompareGroups(BoxConstraints constraints) {
    List<Widget> silvers = [];
    for (CompareElement ele in _logic.checkedElements) {
      Widget groupItem = _buildGroup(ele, constraints);
      var box = SliverToBoxAdapter(child: groupItem);
      silvers.add(box);
    }
    silvers.add(SliverToBoxAdapter(child: SizedBox(height: 12)));
    return silvers;
  }

  Widget _buildGroup(CompareElement ele, BoxConstraints constraints) {
    switch (ele.type) {
      //其他的批量一次请求数据，比如feature
      case SCViewType.feature:
        return CompareGroupWrapper(
          compareElement: ele,
          showTitle: _showLabel,
          onRemove: _logic.onDeleteCompareItem,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            controller: safeScrollController(ele),
            child: CompareGroupView(
              key: Key('${ele.toString().hashCode}-${_logic.genes.join(',').hashCode}'),
              compareElement: ele,
              features: _logic.genes,
              showLabel: false,
              expanded: false,
              axis: Axis.horizontal,
              // onRemove: _logic.onDeleteCompareItem,
              onDelete: _logic.onGeneDelete,
            ),
          ),
        );

      /// 一下这些单独请求数据
      case SCViewType.scatter:
      case SCViewType.violin:
      case SCViewType.motif:
      case SCViewType.coverage:
        return CompareGroupWidget(
          key: Key(ele.toString()),
          horScrollController: safeScrollController(ele),
          features: _logic.genes,
          compareElement: ele,
          width: constraints.constrainWidth(),
          showLabel: _showLabel,
          onRemove: _logic.onDeleteCompareItem,
        );

      /// 这两种是一张图片
      case SCViewType.dotplot:
      case SCViewType.heatmap:
        return CompareGroupWrapper(
          compareElement: ele,
          showTitle: _showLabel,
          onRemove: _logic.onDeleteCompareItem,
          builder: (c) => CompareItemPlot(
            key: Key(ele.toString()),
            element: ele,
            data: _logic.featureNames,
            index: 0,
            width: _columnWidth,
            // height: 400,
          ),
        );
    }
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: RichText(
          text: TextSpan(
            style: Theme.of(context).textTheme.bodyMedium,
            children: [
              TextSpan(text: 'Click '),
              WidgetSpan(
                child: IconButton(
                  constraints: BoxConstraints.tightFor(width: 32, height: 32),
                  padding: EdgeInsets.zero,
                  splashRadius: 16,
                  onPressed: () {},
                  icon: Icon(Icons.list_alt),
                ),
              ),
              TextSpan(text: ' to set features, '),
              TextSpan(text: 'Click '),
              WidgetSpan(
                child: IconButton(
                  constraints: BoxConstraints.tightFor(width: 32, height: 32),
                  padding: EdgeInsets.zero,
                  splashRadius: 16,
                  onPressed: () {},
                  icon: Icon(Icons.add_chart),
                ),
              ),
              TextSpan(text: ' to add compare chart, '),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildToolBar(BoxConstraints constraints) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Wrap(
        spacing: 20,
        crossAxisAlignment: WrapCrossAlignment.center,
        alignment: WrapAlignment.center,
        children: [
          Builder(
            builder: (context) {
              return IconButton(
                onPressed: () => _showFeatureListPop(context),
                icon: Icon(Icons.list_alt),
                tooltip: 'Feature List',
              ).withBubble(text: '${_logic.genes.length}');
            },
          ),
          Builder(
            builder: (context) {
              return IconButton(
                onPressed: () => _showHistoryPop(context),
                icon: Icon(Icons.history),
                tooltip: 'Histories',
              );
            },
          ),
          SizedBox(width: 20),
          Builder(builder: (c) {
            return _buildPlotTypes(c);
          }),
          SizedBox(width: 20),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Label:'),
              Switch.adaptive(
                value: _showLabel,
                onChanged: (v) {
                  _showLabel = v;
                  setState(() {});
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddCompareElementsMenu(BuildContext targetContext, SCViewType type, [PreferDirection? preferDirection]) {
    showAttachedWidget(
      targetContext: targetContext,
      preferDirection: preferDirection ?? PreferDirection.bottomCenter,
      backgroundColor: Colors.transparent,
      attachedBuilder: (c) {
        return Material(
          elevation: 6,
          borderRadius: BorderRadius.circular(5),
          child: Container(
            constraints: BoxConstraints.tightFor(width: 360),
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: SCCompareElementSelector(
              types: _logic.viewTypes,
              matrix: _logic.matrix,
              type: type,
              onAddElement: (e) {
                c.call();
                _logic.onAddCompareElement(e);
              },
            ),
          ),
        );
      },
    );
  }

  void _showFeatureListPop(BuildContext context) {
    showAttachedWidget(
      targetContext: context,
      preferDirection: PreferDirection.bottomLeft,
      attachedBuilder: (c) {
        return Material(
          elevation: 6,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            constraints: BoxConstraints.tightFor(width: 360),
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: FeatureInputWidget(
              features: _logic.featureNames,
              onChange: (v) {
                c.call();
                _logic.onFeatureChange(v);
              },
            ),
          ),
        );
      },
    );
  }

  void _showHistoryPop(BuildContext context) {
    showAttachedWidget(
      targetContext: context,
      preferDirection: PreferDirection.bottomLeft,
      attachedBuilder: (c) {
        return Material(
          elevation: 6,
          color: Theme.of(context).dialogBackgroundColor,
          borderRadius: BorderRadius.circular(10),
          shadowColor: Theme.of(context).colorScheme.primary,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: CompareHistoryWidget(
              features: _logic.getFeatureHistories(),
              onTap: (list) {
                c.call();
                _logic.onFeatureChange(list, isHistory: true);
              },
              onDelete: _logic.onDeleteHistoryItem,
            ),
          ),
        );
      },
    );
  }

  int _selectedElementIndex = 0;

  _buildPlotTypes(BuildContext c) {
    var iconColor = Theme.of(context).brightness == Brightness.dark ? Theme.of(context).colorScheme.primary : null;
    return ToggleButtonGroup(
      constraints: BoxConstraints.tightFor(height: 36),
      selectedIndex: _selectedElementIndex,
      buttonMode: true,
      borderRadius: BorderRadius.circular(4),
      onChange: (v) {
        _selectedElementIndex = v;
        // _type = widget.types[_selectedElementIndex];
        _showAddCompareElementsMenu(c, _logic.viewTypes[v]);
      },
      children: _logic.viewTypes.map((e) {
        Widget icon = _logic.svgIcon(e, color: iconColor) ?? Icon(CompareLogic.get()!.chartTypeIcon(e), size: 26, color: iconColor);
        return Tooltip(
          message: e.name,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: icon,
          ),
        );
      }).toList(),
    );
  }

  @override
  void dispose() {
    _verScrollController?.dispose();
    for (var entry in _horScrollControllers.entries) {
      entry.value.dispose();
    }
    _horScrollControllers.clear();
    _logic.onViewDispose();
    super.dispose();
  }
}
