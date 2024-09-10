// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// A widget that takes a list of children, lays them out along [axis], and
/// allows the user to resize them.
///
/// The user can customize the amount of space allocated to each child by
/// dragging a divider between them.
///
/// [initialFractions] defines how much space to give each child when building
/// this widget.
class Split extends StatefulWidget {
  /// Builds a split oriented along [axis].
  final SplitController? controller;

  Split({
    Key? key,
    this.axis = Axis.vertical,
    required this.children,
    required this.initialFractions,
    this.minSizes,
    this.splitters,
    this.onFractionChange,
    this.controller,
  })  : assert(children.length >= 1),
        assert(initialFractions.length >= 1),
        assert(children.length == initialFractions.length),
        super(key: key) {
    _verifyFractionsSumTo1(initialFractions);
    if (minSizes != null) {
      assert(minSizes!.length == children.length);
    }
    if (splitters != null) {
      assert(splitters!.length == children.length - 1);
    }
  }

  /// The main axis the children will lay out on.
  ///
  /// If [Axis.horizontal], the children will be placed in a [Row]
  /// and they will be horizontally resizable.
  ///
  /// If [Axis.vertical], the children will be placed in a [Column]
  /// and they will be vertically resizable.
  ///
  /// Cannot be null.
  final Axis axis;

  /// The children that will be laid out along [axis].
  final List<Widget> children;

  /// The fraction of the layout to allocate to each child in [children].
  ///
  /// The index of [initialFractions] corresponds to the child at index of
  /// [children].
  final List<double> initialFractions;

  /// The minimum size each child is allowed to be.
  final List<double>? minSizes;

  /// Splitter widgets to divide [children].
  ///
  /// If this is null, a default splitter will be used to divide [children].
  final List<SizedBox>? splitters;

  final ValueChanged<List<double>>? onFractionChange;

  /// The key passed to the divider between children[index] and
  /// children[index + 1].
  ///
  /// Visible to grab it in tests.
  @visibleForTesting
  Key dividerKey(int index) => Key('$this dividerKey $index');

  static Axis axisFor(BuildContext context, double horizontalAspectRatio) {
    final screenSize = MediaQuery.of(context).size;
    final aspectRatio = screenSize.width / screenSize.height;
    if (aspectRatio >= horizontalAspectRatio) return Axis.horizontal;
    return Axis.vertical;
  }

  @override
  State<StatefulWidget> createState() => _SplitState();
}

class _SplitState extends State<Split> {
  late List<double> fractions;
  List<double>? _minSizes;
  late SplitController _controller;

  bool get isHorizontal => widget.axis == Axis.horizontal;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? SplitController();
    _controller..state = this;
    fractions = List.from(widget.initialFractions);
    if (widget.minSizes != null) {
      _minSizes = List.from(widget.minSizes!);
    }
  }

  @override
  void didUpdateWidget(covariant Split oldWidget) {
    // if ((fractions.length != widget.initialFractions?.length ?? 0) || //
    //     hasFoldItem(fractions, widget.initialFractions)) {
    //   fractions = List.from(widget.initialFractions);
    // }
    fractions = List.from(widget.initialFractions);
    if (widget.minSizes != null) {
      _minSizes = List.from(widget.minSizes!);
    }
    super.didUpdateWidget(oldWidget);
  }

  bool hasFoldItem(List<double> frac1, List<double> frac2) {
    for (int i = 0; i < frac1.length; i++) {
      if ((frac1[i] == 0 || frac2[i] == 0) && frac1[i] != frac2[i]) {
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: _buildLayout);
  }

  late double axisSize;

  double get availableSize => axisSize - _totalSplitterSize();

  double _sizeForIndex(int index) => availableSize * fractions[index];

  // Size calculation helpers.
  double _minSizeForIndex(int index) {
    if (_minSizes == null) return 0.0;

    double totalMinSize = 0;
    for (var minSize in _minSizes!) {
      totalMinSize += minSize;
    }
    // Reduce the min sizes gracefully if the total required min size for all
    // children is greater than the available size for children.
    if (totalMinSize > availableSize) {
      return _minSizes![index] * availableSize / totalMinSize;
    } else {
      return _minSizes![index];
    }
  }

  double _minFractionForIndex(int index) => _minSizeForIndex(index) / availableSize;

  void _clampFraction(int index) {
    fractions[index] = fractions[index].clamp(_minFractionForIndex(index), 1.0);
  }

  double deltaFromMinimumSize(int index) => fractions[index] - _minFractionForIndex(index);

  Widget _buildLayout(BuildContext context, BoxConstraints constraints) {
    final width = constraints.maxWidth;
    final height = constraints.maxHeight;
    axisSize = isHorizontal ? width : height;

    double fractionDeltaRequired = 0.0;
    double fractionDeltaAvailable = 0.0;

    for (int i = 0; i < fractions.length; ++i) {
      final delta = deltaFromMinimumSize(i);
      if (delta < 0) {
        fractionDeltaRequired -= delta;
      } else {
        fractionDeltaAvailable += delta;
      }
    }
    if (fractionDeltaRequired > 0) {
      // Likely due to a change in the available size, the current fractions for
      // the children do not obey the min size constraints.
      // The min size constraints for children are scaled so it is always
      // possible to meet them. A scaleFactor greater than 1 would indicate that
      // it is impossible to meet the constraints.
      double scaleFactor = fractionDeltaRequired / fractionDeltaAvailable;
      assert(scaleFactor <= 1 + defaultEpsilon);
      scaleFactor = math.min(scaleFactor, 1.0);
      for (int i = 0; i < fractions.length; ++i) {
        final delta = deltaFromMinimumSize(i);
        if (delta < 0) {
          // This is equivalent to adding delta but avoids rounding error.
          fractions[i] = _minFractionForIndex(i);
        } else {
          // Reduce all fractions that are above their minimum size by an amount
          // proportional to their ability to reduce their size without
          // violating their minimum size constraints.
          fractions[i] -= delta * scaleFactor;
        }
      }
    }

    // Determine what fraction to give each child, including enough space to
    // display the divider.
    final sizes = List.generate(fractions.length, (i) => _sizeForIndex(i));

    final children = <Widget>[];
    for (int i = 0; i < widget.children.length; i++) {
      children.addAll([
        SizedBox(
          width: isHorizontal ? sizes[i] : width,
          height: isHorizontal ? height : sizes[i],
          child: widget.children[i],
        ),
        if (i < widget.children.length - 1)
          // CustomSplitter(
          //   key: widget.dividerKey(i),
          //   index: i,
          //   horizontal: isHorizontal,
          //   size: 1,
          //   updateSpacing: updateSpacing,
          // ),
          if (fractions[i] == 0 || (i == fractions.length - 2 && fractions.last == 0))
            widget.splitters != null ? widget.splitters![i] : BlankSplitter(isHorizontal: isHorizontal)
          else
            MouseRegion(
              cursor: isHorizontal ? SystemMouseCursors.resizeColumn : SystemMouseCursors.resizeRow,
              child: GestureDetector(
                key: widget.dividerKey(i),
                behavior: HitTestBehavior.translucent,
                onHorizontalDragUpdate: (details) => isHorizontal ? updateSpacing(details, i) : null,
                onVerticalDragUpdate: (details) => isHorizontal ? null : updateSpacing(details, i),
                dragStartBehavior: DragStartBehavior.down,
                child: widget.splitters != null ? widget.splitters![i] : DefaultSplitter(isHorizontal: isHorizontal),
              ),
            ),
      ]);
    }
    return Flex(direction: widget.axis, children: children);
  }

  // Returns the actual delta applied to elements before the splitter.
  double updateSpacingBeforeSplitterIndex(double delta, int splitterIndex) {
    final startingDelta = delta;
    var index = splitterIndex;
    while (index >= 0) {
      fractions[index] += delta;
      final minFractionForIndex = _minFractionForIndex(index);
      if (fractions[index] >= minFractionForIndex) {
        _clampFraction(index);
        return startingDelta;
      }
      delta = fractions[index] - minFractionForIndex;
      _clampFraction(index);
      index--;
    }
    // At this point, we know that both [startingDelta] and [delta] are
    // negative, and that [delta] represents the overflow that did not get
    // applied.
    return startingDelta - delta;
  }

  // Returns the actual delta applied to elements after the splitter.
  double updateSpacingAfterSplitterIndex(double delta, int splitterIndex) {
    final startingDelta = delta;
    var index = splitterIndex + 1;
    while (index < fractions.length) {
      fractions[index] += delta;
      final minFractionForIndex = _minFractionForIndex(index);
      if (fractions[index] >= minFractionForIndex) {
        _clampFraction(index);
        return startingDelta;
      }
      delta = fractions[index] - minFractionForIndex;
      _clampFraction(index);
      index++;
    }
    // At this point, we know that both [startingDelta] and [delta] are
    // negative, and that [delta] represents the overflow that did not get
    // applied.
    return startingDelta - delta;
  }

  void updateSpacing(DragUpdateDetails dragDetails, int splitterIndex) {
    final dragDelta = isHorizontal ? dragDetails.delta.dx : dragDetails.delta.dy;
    final fractionalDelta = dragDelta / axisSize;

    setState(() {
      // Update the fraction of space consumed by the children. Always update
      // the shrinking children first so that we do not over-increase the size
      // of the growing children and cause layout overflow errors.
      if (fractionalDelta <= 0.0) {
        final appliedDelta = updateSpacingBeforeSplitterIndex(fractionalDelta, splitterIndex);
        updateSpacingAfterSplitterIndex(-appliedDelta, splitterIndex);
      } else {
        final appliedDelta = updateSpacingAfterSplitterIndex(-fractionalDelta, splitterIndex);
        updateSpacingBeforeSplitterIndex(-appliedDelta, splitterIndex);
      }
    });
    widget.onFractionChange?.call(fractions);
    _verifyFractionsSumTo1(fractions);
  }

  void changeFractions({required List<double> fractions, List<double>? minSizes}) {
    if (this.fractions.length != fractions.length) throw Exception('Children count change');
    if (null != minSizes) _minSizes = List.from(minSizes);

    _verifyFractionsSumTo1(fractions);
    this.fractions = fractions;
    setState(() {});
  }

  double _totalSplitterSize() {
    final numSplitters = widget.children.length - 1;
    if (widget.splitters == null) {
      return numSplitters * DefaultSplitter.defaultSplitterWidth;
    } else {
      double totalSize = 0.0;
      for (var splitter in widget.splitters!) {
        totalSize += isHorizontal ? splitter.width! : splitter.height!;
      }
      return totalSize;
    }
  }
}

class CustomSplitter extends StatefulWidget {
  final bool horizontal;
  final int index;
  final Function? updateSpacing;
  final Widget? child;
  final double? size;
  final Widget? icon;
  final Color? color;

  const CustomSplitter({
    super.key,
    required this.horizontal,
    this.size = 1,
    this.icon,
    this.color,
    this.updateSpacing,
    required this.index,
    this.child,
  });

  @override
  State<CustomSplitter> createState() => _CustomSplitterState();
}

class _CustomSplitterState extends State<CustomSplitter> {
  bool _entered = false;

  @override
  void initState() {
    super.initState();
  }

  void _onHover(e) {}

  void _onExit(e) {
    _entered = false;
    setState(() {});
  }

  void _onEnter(e) {
    _entered = true;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Color _color = widget.color ?? (Theme.of(context).brightness == Brightness.dark ? Theme.of(context).colorScheme.outline.withAlpha(50) : Colors.grey[300]!);
    return SizedBox.fromSize(
      size: widget.horizontal ? Size.fromWidth(5) : Size.fromHeight(5),
      child: MouseRegion(
        cursor: widget.horizontal ? SystemMouseCursors.resizeColumn : SystemMouseCursors.resizeRow,
        onEnter: _onEnter,
        onExit: _onExit,
        child: GestureDetector(
          // key: widget.dividerKey(i),
          behavior: HitTestBehavior.translucent,
          onHorizontalDragUpdate: (details) => widget.horizontal ? widget.updateSpacing?.call(details, widget.index) : null,
          onVerticalDragUpdate: (details) => widget.horizontal ? null : widget.updateSpacing?.call(details, widget.index),
          dragStartBehavior: DragStartBehavior.down,
          child: Container(
            color: _entered ? _color : Colors.transparent,
            constraints: widget.horizontal ? BoxConstraints.expand(width: widget.size) : BoxConstraints.expand(height: widget.size),
            child: SizedOverflowBox(
              size: widget.horizontal ? Size.fromWidth(5) : Size.fromHeight(5),
              child: Container(
                constraints: widget.horizontal ? BoxConstraints.expand(width: widget.size) : BoxConstraints.expand(height: widget.size),
                color: _color,
                child: CircleAvatar(
                  // radius: 16,
                  minRadius: 16,
                  maxRadius: 16,
                  backgroundColor: _entered ? Theme.of(context).colorScheme.primary : Colors.transparent,
                  child: Transform.rotate(
                    angle: widget.horizontal ? degToRad(90.0) : degToRad(0.0),
                    child: Icon(
                      Icons.drag_handle,
                      size: 24,
                      color: Theme.of(context).focusColor,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SplitController {
  _SplitState? state;

  SplitController() {}

  updateFractions({required List<double> fractions, List<double>? minSizes}) {
    state?.changeFractions(fractions: fractions, minSizes: minSizes);
  }

  dispose() {
    state = null;
  }
}

class BlankSplitter extends StatelessWidget {
  static const double defaultSplitterWidth = 4.0;

  final double splitterWidth;
  final bool isHorizontal;

  BlankSplitter({
    required this.isHorizontal,
    this.splitterWidth = defaultSplitterWidth,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: isHorizontal ? splitterWidth : double.infinity,
      height: !isHorizontal ? splitterWidth : double.infinity,
    );
  }
}

class DefaultSplitter extends StatelessWidget {
  DefaultSplitter({
    required this.isHorizontal,
    this.splitterWidth = defaultSplitterWidth,
    this.draggable = true,
  });

  final bool draggable;
  static const double iconSize = 18.0;
  static const double defaultSplitterWidth = 4.0;
  final double splitterWidth;
  Color? color;

  final bool isHorizontal;

  @override
  Widget build(BuildContext context) {
    Color _color = color ?? (Theme.of(context).brightness == Brightness.dark ? Theme.of(context).colorScheme.outline.withAlpha(50) : Colors.grey[300]!);

    return ConstrainedBox(
      constraints: isHorizontal ? BoxConstraints.expand(width: splitterWidth) : BoxConstraints.expand(height: splitterWidth),
      child: Center(
        child: Container(
          constraints: isHorizontal ? BoxConstraints.expand(width: 2) : BoxConstraints.expand(height: 2),
          decoration: BoxDecoration(
            color: _color,
          ),
          child: draggable
              ? OverflowBox(
                  minWidth: 30,
                  minHeight: 30,
                  maxWidth: 30,
                  maxHeight: 30,
                  child: Transform.rotate(
                    angle: isHorizontal ? degToRad(90.0) : degToRad(0.0),
                    child: Icon(
                      Icons.drag_handle,
                      size: 24,
                      color: Theme.of(context).focusColor,
                    ),
                  ),
                )
              : null,
        ),
      ),
    );
  }
}

void _verifyFractionsSumTo1(List<double> fractions) {
  if (fractions.length == 1) return;
  var sumFractions = 0.0;
  for (var fraction in fractions) {
    sumFractions += fraction;
  }
  assert(
    (1.0 - sumFractions).abs() < defaultEpsilon,
    'Fractions should sum to 1.0, but instead sum to $sumFractions:\n$fractions',
  );
}

const defaultEpsilon = 1 / 1000;

double degToRad(num deg) => deg * (math.pi / 180.0);
