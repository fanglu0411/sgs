import 'package:flutter_smart_genome/widget/basic/custom_spin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/page/cell/cell_base.dart';
import 'package:flutter_smart_genome/page/compare/compare_logic.dart';
import 'package:flutter_smart_genome/page/compare/group/item_plot.dart';
import 'package:flutter_smart_genome/page/compare/widget/compare_element_label.dart';
import 'package:get/get.dart';
import 'package:dartx/dartx.dart' as dx;

import 'compare_group_logic.dart';

typedef Widget ItemBuilder(BuildContext context, CompareGroupLogic logic);

class CompareGroupView extends StatefulWidget {
  final CompareElement compareElement;

  final bool expanded;
  final bool showLabel;
  final List<Map> features;
  final Axis axis;
  final ItemBuilder? itemBuilder;
  final ValueChanged<CompareElement>? onRemove;
  final ValueChanged<String>? onDelete;

  const CompareGroupView({
    Key? key,
    required this.compareElement,
    required this.axis,
    required this.expanded,
    required this.showLabel,
    required this.features,
    this.itemBuilder,
    this.onDelete,
    this.onRemove,
  }) : super(key: key);

  @override
  _CompareGroupViewState createState() => _CompareGroupViewState();
}

class _CompareGroupViewState extends State<CompareGroupView> {
  CompareGroupLogic? _logic;

  double _itemWidth = 420;
  double _itemHeight = 360;

  @override
  void initState() {
    super.initState();
    _logic = CompareGroupLogic.find(tag: widget.compareElement.toString());
    if (_logic != null) {
      _logic!.setFeatures(widget.features);
    } else {
      Get.put(
          CompareGroupLogic(
            compareElement: widget.compareElement,
            features: widget.features,
          ),
          tag: widget.compareElement.toString());
    }
  }

  @override
  void didUpdateWidget(covariant CompareGroupView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _logic?.didUpdateWidget(oldWidget, widget);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CompareGroupLogic>(
      autoRemove: true,
      init: _logic,
      initState: (s) {},
      tag: widget.compareElement.toString(),
      builder: (c) => LayoutBuilder(builder: (context, constraints) => _builder(c, constraints)),
    );
  }

  Widget _builder(CompareGroupLogic controller, BoxConstraints constraints) {
    bool _dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      child: Stack(
        children: [
          _buildContent(controller, constraints),
          if (
              // !widget.compareElement.isFeature &&
              widget.showLabel)
            CompareElementLabel(
              onRemove: (ele) => widget.onRemove?.call(ele),
              compareElement: widget.compareElement,
              onChange: (parentMenu, menu) {
                if (parentMenu['key'] == 'matrix') {
                  controller.compareElement.matrix = menu['value'];
                } else {
                  controller.compareElement.category = menu['value'];
                }
                controller.loadData();
              },
            ),
        ],
      ),
    );
  }

  Widget _buildContent(CompareGroupLogic controller, BoxConstraints constraints) {
    if (controller.loading || controller.error != null) {
      var _constraints = widget.axis == Axis.horizontal
          ? BoxConstraints.expand(
              height: _itemHeight,
              width: widget.expanded ? null : widget.features.length * _itemWidth,
            )
          : BoxConstraints.expand(
              height: widget.expanded ? null : widget.features.length * _itemHeight,
              width: _itemWidth,
            );
      return Container(
        alignment: Alignment.center,
        constraints: _constraints,
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).colorScheme.primaryContainer),
        ),
        child: controller.loading ? CustomSpin(color: Theme.of(context).colorScheme.primary) : Text(controller.error!.message),
      );
    }

    if (widget.compareElement.type == SCViewType.heatmap || widget.compareElement.type == SCViewType.dotplot) {
      return CompareItemPlot(
        element: widget.compareElement,
        data: controller.data!.first,
        index: 0,
      );
      // return buildGroupItem(widget.compareElement.type, controller.data!.first, 0);
    }

    if (widget.axis == Axis.horizontal) {
      List<Widget> children = controller.features.mapIndexed<Widget>((i, feature) {
        var item = controller.findFeatureItem(feature['feature_name']);
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 2),
          constraints: widget.expanded ? null : BoxConstraints.tightFor(width: _itemWidth),
          child: CompareItemPlot(
            element: widget.compareElement,
            data: widget.compareElement.type == SCViewType.coverage ? feature : item,
            width: _itemWidth,
            height: _itemHeight,
            onDelete: widget.onDelete,
            index: i,
          ),
          //buildGroupItem(widget.compareElement.type, widget.compareElement.type == SCViewType.coverage ? feature : item, i),
        );
      }).toList();
      return Row(
        mainAxisSize: widget.expanded ? MainAxisSize.max : MainAxisSize.min,
        children: widget.expanded ? children.map<Widget>((e) => Expanded(child: e)).toList() : children,
      );
    } else {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: controller.features.mapIndexed<Widget>((i, feature) {
          var item = controller.findFeatureItem(feature['feature_name']);
          return Container(
            margin: EdgeInsets.symmetric(vertical: 2),
            constraints: BoxConstraints.tightFor(width: widget.compareElement.type == SCViewType.feature ? _itemWidth : null, height: _itemHeight),
            child: CompareItemPlot(
              element: widget.compareElement,
              data: widget.compareElement.type == SCViewType.coverage ? feature : item,
              width: _itemWidth,
              height: _itemHeight,
              index: i,
              onDelete: widget.onDelete,
            ),
            // buildGroupItem(widget.compareElement.type, widget.compareElement.type == SCViewType.coverage ? feature : item, i),
          );
        }).toList(),
      );
    }
  }

  @override
  void dispose() {
    GetInstance().delete<CompareGroupLogic>(tag: widget.compareElement.type.toString());
    super.dispose();
  }
}
