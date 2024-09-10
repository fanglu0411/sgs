import 'dart:ui';

import 'package:flutter/painting.dart' as painting;
import 'package:graphic/graphic.dart';

/// A label element.
class InlineSpanElement extends MarkElement<LabelStyle> {
  final Offset anchor;

  /// The default align of this block to anchor when [BlockStyle.align] is not set.
  ///
  /// This is useful because a block may need different default aligns for different
  /// anchor position.
  painting.Alignment defaultAlign;

  late final Offset paintPoint;

  /// Creates a label element.
  InlineSpanElement({
    required this.textSpan,
    required this.anchor,
    this.defaultAlign = painting.Alignment.center,
    required LabelStyle style,
    String? tag,
  }) : super(
          style: style,
          tag: tag,
        ) {
    _painter = painting.TextPainter(
      text: this.textSpan,
      textAlign: this.style.textAlign ?? TextAlign.start,
      textDirection: this.style.textDirection ?? TextDirection.ltr,
      textScaler: style.textScaler ?? painting.TextScaler.noScaling,
      maxLines: this.style.maxLines,
      ellipsis: this.style.ellipsis,
      locale: this.style.locale,
      strutStyle: this.style.strutStyle,
      textWidthBasis: this.style.textWidthBasis ?? painting.TextWidthBasis.parent,
      textHeightBehavior: this.style.textHeightBehavior,
    );
    _painter.layout(
      minWidth: this.style.minWidth ?? 0.0,
      maxWidth: this.style.maxWidth ?? double.infinity,
    );

    paintPoint = getBlockPaintPoint(rotationAxis!, _painter.width, _painter.height, this.style.align ?? this.defaultAlign);
  }

  /// The content text of this label.
  final painting.InlineSpan textSpan;

  /// The text painter.
  late final painting.TextPainter _painter;

  @override
  void draw(Canvas canvas) => _painter.paint(canvas, paintPoint);

  @override
  InlineSpanElement lerpFrom(covariant LabelElement from, double t) => InlineSpanElement(
        textSpan: textSpan,
        anchor: Offset.lerp(from.anchor, anchor, t)!,
        defaultAlign: painting.Alignment.lerp(from.defaultAlign, defaultAlign, t)!,
        style: style.lerpFrom(from.style, t),
        tag: tag,
      );

  @override
  bool operator ==(Object other) => other is InlineSpanElement && super == other && this.textSpan == other.textSpan;
}
