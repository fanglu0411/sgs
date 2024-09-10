import 'dart:math';

import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart';

const _kBaseGroupPaddingHorizontal = 32.0;
const _kMinBarSize = 4.0;

/// Changes the position of marks while also updating their width to match
/// the number of marks in a single band. Useful for bar charts when the
/// width of the bars can be dynamic.
@immutable
class DodgeSizeModifier extends Modifier {
  @override
  AttributesGroups modify(AttributesGroups groups, Map<String, ScaleConv<dynamic, num>> scales, AlgForm form, CoordConv coord, Offset origin) {
    final xField = form.first[0];
    final band = (scales[xField]! as DiscreteScaleConv).band;

    final ratio = 1 / groups.length;
    final numGroups = groups.length;
    final groupHorizontalPadding = _kBaseGroupPaddingHorizontal / numGroups;
    final invertedGroupPaddingHorizontal = coord.invertDistance(groupHorizontalPadding, Dim.x);

    final effectiveBand = band - 2 * invertedGroupPaddingHorizontal;

    final maxWidth = coord.convert(const Offset(1, 0)).dx;
    final maxWidthInBand = effectiveBand * maxWidth;
    final maxWidthPerAttributes = maxWidthInBand / numGroups;
    final barHorizontalPadding = groupHorizontalPadding / 2;
    final size = max(maxWidthPerAttributes - barHorizontalPadding, _kMinBarSize);

    final bias = ratio * effectiveBand;

    // Negatively shift half of the total bias.
    var accumulated = -bias * (numGroups + 1) / 2;

    final AttributesGroups rst = [];
    for (final group in groups) {
      final groupRst = <Attributes>[];
      for (final attributes in group) {
        final oldPosition = attributes.position;

        groupRst.add(Attributes(
          index: attributes.index,
          tag: attributes.tag,
          position: oldPosition
              .map(
                (point) => Offset(point.dx + accumulated + bias, point.dy),
              )
              .toList(),
          shape: attributes.shape,
          color: attributes.color,
          gradient: attributes.gradient,
          elevation: attributes.elevation,
          label: attributes.label,
          size: size,
        ));
      }
      rst.add(groupRst);
      accumulated += bias;
    }

    return rst;
  }

  @override
  bool equalTo(Object other) {
    return super == other;
  }
}