import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/base/container_config.dart';
import 'package:flutter_smart_genome/base/ui_config.dart';
import 'package:flutter_smart_genome/bean/highlight_range.dart';
import 'package:flutter_smart_genome/bloc/sgs_context/sgs_browse_logic.dart';
import 'package:flutter_smart_genome/extensions/common_extensions.dart';
import 'package:flutter_smart_genome/service/sgs_config_service.dart';
import 'package:flutter_smart_genome/storage/base_store_provider.dart';

import 'package:flutter_smart_genome/widget/basic/custom_bot_widget.dart';
import 'package:flutter_smart_genome/widget/basic/fixed_color_picker.dart';

import 'package:get/get.dart';

class HighlightsLogic extends GetxController {
  List<HighlightRange> _highlights = [];

  @override
  void onReady() {
    _loadData();
  }

  reloadData() {
    _loadData();
    update();
  }

  _loadData() {
    _highlights = SgsConfigService().getHighlights();
  }

  void deleteHighlight(HighlightRange highlight) async {
    await BaseStoreProvider.get().deleteHighlight(highlight);
    _loadData();
    update();
  }

  void toggleVisible(HighlightRange highlight) async {
    highlight.toggleVisible();
    await BaseStoreProvider.get().addOrPutHighlight(highlight);
    update();
  }

  void setColor(HighlightRange highlight) async {
    await BaseStoreProvider.get().addOrPutHighlight(highlight);
    update();
  }

  static HighlightsLogic? safe() {
    if (Get.isRegistered<HighlightsLogic>()) {
      return Get.find<HighlightsLogic>();
    }
    return null;
  }
}

class HighlightSide extends StatefulWidget {
  const HighlightSide({Key? key}) : super(key: key);

  @override
  State<HighlightSide> createState() => _HighlightSideState();
}

class _HighlightSideState extends State<HighlightSide> {
  final HighlightsLogic _logic = Get.put(HighlightsLogic());

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HighlightsLogic>(
      builder: (controller) {
        return _buildList();
      },
      didUpdateWidget: (d, c) {
        print('did update');
        c.controller!._loadData();
      },
    );
  }

  _buildList() {
    _logic._loadData();
    List<HighlightRange> highlights = _logic._highlights;

    if (highlights.isEmpty) {
      return Container(
        padding: EdgeInsets.symmetric(vertical: 30),
        alignment: Alignment.center,
        child: Text(
          'Highlights is empty!',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      );
    }

    var children = highlights.map((e) {
      return ListTile(
          dense: true,
          // isThreeLine: true,
          onTap: () {},
          // tileColor: e.color,
          title: Text('${e.chrName}: ${e.range.print()}', style: Theme.of(context).textTheme.titleSmall!.copyWith(fontWeight: FontWeight.w300)),
          horizontalTitleGap: 0,
          contentPadding: EdgeInsets.only(left: 10),
          subtitle: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Builder(builder: (context) {
                return TextButton(
                  child: Text(
                    '#${e.color.hexString}',
                    style: TextStyle(
                      fontFamily: MONOSPACED_FONT,
                      fontFamilyFallback: MONOSPACED_FONT_BACK,
                      height: 1.25,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: e.color,
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    minimumSize: Size(50, 30),
                    elevation: 0,
                  ),
                  onPressed: () => _showColorPicker(context, e),
                );
              }),
              Spacer(),
              IconButton(
                onPressed: () => _logic.deleteHighlight(e),
                padding: EdgeInsets.zero,
                iconSize: 16,
                splashRadius: 22,
                constraints: BoxConstraints.tight(Size(34, 34)),
                icon: Icon(Icons.delete, color: Colors.red),
                tooltip: 'Delete',
              ),
              IconButton(
                onPressed: () => _logic.toggleVisible(e),
                padding: EdgeInsets.zero,
                iconSize: 16,
                splashRadius: 22,
                constraints: BoxConstraints.tight(Size(34, 34)),
                icon: Icon(e.visible ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                tooltip: 'Toggle visible',
              ),
              IconButton(
                padding: EdgeInsets.zero,
                splashRadius: 22,
                iconSize: 16,
                constraints: BoxConstraints.tight(Size(34, 34)),
                onPressed: () => _jumpToHighlight(e),
                icon: Icon(Icons.my_location),
                tooltip: 'Locate to highlight',
              ),
              SizedBox(width: 8),
            ],
          ));
    });
    return ListView(
      children: ListTile.divideTiles(tiles: children, context: context, color: Theme.of(context).dividerColor).toList(),
    );
  }

  void _jumpToHighlight(HighlightRange highlight) {
    SgsBrowseLogic.safe()?.jumpToPosition(highlight.chrId, highlight.range, context);
  }

  void _showColorPicker(BuildContext context, HighlightRange highlight) {
    double width = isMobile(context) ? 200 : 300;

    var colorPicker = FixedColorPicker(
      colorPickerWidth: width - 50,
      showLabel: true,
      pickerColor: highlight.color,
      onColorChanged: (color) {
        highlight.setColor(color);
        _logic.setColor(highlight);
      },
    );

    showAttachedWidget(
      targetContext: context,
      preferDirection: PreferDirection.bottomRight,
      attachedBuilder: (cancel) {
        return Container(
          constraints: BoxConstraints.tightFor(width: width),
          //decoration: defaultContainerDecoration(context),
          child: Material(
            elevation: 6,
            color: Theme.of(context).dialogBackgroundColor,
            shape: modelShape(),
            child: colorPicker,
          ),
        );
      },
    );
  }
}
