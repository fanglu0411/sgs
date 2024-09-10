import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/base/container_config.dart';
import 'package:flutter_smart_genome/components/json_widget.dart';
import 'package:flutter_smart_genome/widget/basic/scroll_controller_builder.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pretty_json/pretty_json.dart';

import 'logic.dart';

class ErrorEventComponent extends StatefulWidget {
  @override
  _HttpRequestEventComponentState createState() => _HttpRequestEventComponentState();
}

class _HttpRequestEventComponentState extends State<ErrorEventComponent> {
  late ErrorEventLogic logic;

  @override
  initState() {
    super.initState();
    logic = ErrorEventLogic.safe() ?? Get.put(ErrorEventLogic());
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ErrorEventLogic>(
      init: logic,
      autoRemove: false,
      builder: (logic) {
        return _buildList();
      },
    );
  }

  Widget _buildList() {
    return Container(
      constraints: BoxConstraints(minHeight: 200, maxHeight: 400),
      child: ScrollControllerBuilder(builder: (c, controller) {
        return ListView.separated(
          itemBuilder: itemBuilder,
          separatorBuilder: separatorBuilder,
          itemCount: logic.count,
          controller: controller,
        );
      }),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  DateFormat _dateFormat = DateFormat.Hm();

  Widget itemBuilder(BuildContext context, int index) {
    var item = logic.data[index];
    return ListTile(
      dense: true,
      title: Text(item.title),
      trailing: Text('${_dateFormat.format(item.time!)}', style: Theme.of(context).textTheme.bodySmall),
      onTap: () => _onTap(item),
    );
  }

  void _onTap(ErrorEventItem item) async {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        scrollable: true,
        title: Text(item.title),
        content: Container(
          constraints: BoxConstraints(minWidth: 1000),
          margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          // color: Theme.of(context).colorScheme.primary.withAlpha(10),
          padding: EdgeInsets.all(10),
          child: SelectableText(
            '${item.error}',
            style: TextStyle(
              fontFamily: MONOSPACED_FONT,
              fontFamilyFallback: MONOSPACED_FONT_BACK,
            ),
          ),
        ),
      ),
    );
  }

  Widget separatorBuilder(BuildContext context, int index) {
    return Divider(thickness: 1, height: 1);
  }
}
