import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/widget/track/painter/feature_style_config.dart';

class OrdinalLegendsWidget extends StatefulWidget {
  final Map<String, FeatureStyle> featureStyles;
  final Function2<String, FeatureStyle, void>? onItemTap;
  final double featureHeight;

  const OrdinalLegendsWidget({
    Key? key,
    required this.featureStyles,
    this.onItemTap,
    this.featureHeight = 20,
  }) : super(key: key);

  @override
  _OrdinalLegendsWidgetState createState() => _OrdinalLegendsWidgetState();
}

class _OrdinalLegendsWidgetState extends State<OrdinalLegendsWidget> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        List<String> keys = widget.featureStyles.keys.toList();
        if (keys.length == 0) return SizedBox();
        String maxKey = keys.reduce((value, element) => value.length > element.length ? value : element);
        double maxLabelWidth = maxKey.length * 10.0;

        double _width = constraints.biggest.width;

        int column = _width ~/ (maxLabelWidth + 40);

        double childAspectRatio = (_width / column) / 24;
        return GridView.builder(
          shrinkWrap: true,
          itemCount: keys.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//            crossAxisSpacing: 2,
//            mainAxisSpacing: 2,
            crossAxisCount: column,
            childAspectRatio: childAspectRatio,
          ),
          itemBuilder: (context, index) {
            FeatureStyle featureStyle = widget.featureStyles[keys[index]]!;
            return InkWell(
              onTap: widget.onItemTap != null
                  ? () {
                      widget.onItemTap!(keys[index], featureStyle);
                    }
                  : null,
              child: Row(
                children: [
                  SizedBox(width: 10),
                  Container(
                    constraints: BoxConstraints.tightFor(width: 20, height: widget.featureHeight * featureStyle.height),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(featureStyle.radius),
                      border: featureStyle.hasBorder
                          ? Border.all(
                              color: featureStyle.borderColor!,
                              width: featureStyle.borderWidth,
                            )
                          : null,
                      color: featureStyle.colorWithAlpha,
                    ),
                  ),
                  SizedBox(width: 10),
                  Text('${featureStyle.name}'),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
