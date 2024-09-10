

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/page/cell/cell_scatter_chart/legend_colors.dart';
import 'package:flutter_smart_genome/widget/basic/custom_bot_widget.dart';

void showColorSchemaDialog(BuildContext context, {required List<LegendColor> legendColors, ValueChanged<LegendColor>? onColorSchemaChange,}) {
  showAttachedWidget(
    targetContext: context,
    preferDirection: PreferDirection.bottomCenter,
    attachedBuilder: (cancel) {
      return ConstrainedBox(
        constraints: BoxConstraints.tightFor(width: 160),
        child: Material(
          elevation: 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: ListTile.divideTiles(
              context: context,
              tiles: legendColors.map((e) {
                return InkWell(
                  borderRadius: BorderRadius.circular(5),
                  onTap: () {
                    cancel.call();
                    onColorSchemaChange?.call(e);
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    constraints: BoxConstraints.expand(height: 24),
                    decoration: BoxDecoration(
                      image: DecorationImage(image: AssetImage('assets/images/color/${e.name}.png'), fit: BoxFit.fill),
                    ),
                    alignment: Alignment.centerRight,
                    child: Text(
                      '${e.name}',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ),
                );
              }),
            ).toList(),
          ),
        ),
      );
    },
  );
}