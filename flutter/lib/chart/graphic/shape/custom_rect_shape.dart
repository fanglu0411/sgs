import 'package:graphic/graphic.dart';

class CustomRectShape extends RectShape {
  @override
  double get defaultSize => barWidth ?? 20;

  double? barWidth;

  CustomRectShape({
    super.histogram = false,
    super.labelPosition = 1,
    super.borderRadius,
    this.barWidth = 20,
  });
}