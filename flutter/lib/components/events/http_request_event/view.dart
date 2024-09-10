import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/base/container_config.dart';
import 'package:flutter_smart_genome/components/json_widget.dart';
import 'package:flutter_smart_genome/widget/basic/scroll_controller_builder.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pretty_json/pretty_json.dart';

import 'logic.dart';

class HttpRequestEventComponent extends StatefulWidget {
  @override
  _HttpRequestEventComponentState createState() => _HttpRequestEventComponentState();
}

class _HttpRequestEventComponentState extends State<HttpRequestEventComponent> {
  late HttpRequestEventLogic logic;

  @override
  initState() {
    super.initState();
    logic = HttpRequestEventLogic.safe() ?? Get.put(HttpRequestEventLogic());
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HttpRequestEventLogic>(
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
    // Get.delete<HttpRequestEventLogic>();
    super.dispose();
  }

  DateFormat _dateFormat = DateFormat.Hm();

  Widget itemBuilder(BuildContext context, int index) {
    var item = logic.data[index];
    return ListTile(
      dense: true,
      leading: CircleAvatar(
        radius: 16,
        child: Text('${item.statusCode}', style: TextStyle(color: Colors.white, fontSize: 12)),
        backgroundColor: item.statusCode == 200 ? Colors.green : Colors.red,
      ),
      title: Text(item.url),
      trailing: Text('${_dateFormat.format(item.time!)}', style: Theme.of(context).textTheme.bodySmall),
      onTap: () => _onTap(item),
    );
  }

  void _onTap(HttpRequestItem item) async {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        scrollable: true,
        content: Container(
          constraints: BoxConstraints(minWidth: 1000),
          margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          // color: Theme.of(context).colorScheme.primary.withAlpha(10),
          padding: EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(title: Text(item.url), dense: true),
              Divider(),
              ListTile(title: Text('Status Code: ${item.statusCode}'), dense: true),
              Divider(),
              // _rowItem('Params:', prettyJson(item.params, indent: 4)),
              ExpansionTile(
                title: Text('Params'),
                childrenPadding: EdgeInsets.symmetric(horizontal: 10),
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    alignment: Alignment.topLeft,
                    child: SelectableText(
                      prettyJson(item.params, indent: 4),
                      style: TextStyle(
                        fontFamily: MONOSPACED_FONT,
                        fontFamilyFallback: MONOSPACED_FONT_BACK,
                      ),
                    ),
                  ),
                ],
              ),
              Divider(),
              // _rowItem('Data:', prettyJson(item.data, indent: 4)),
              ExpansionTile(
                title: Text('Response Header'),
                childrenPadding: EdgeInsets.symmetric(horizontal: 10),
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    alignment: Alignment.topLeft,
                    child: SelectableText(
                      // prettyJson(item.responseHeader, indent: 4),
                      '${item.responseHeader}',
                      style: TextStyle(
                        fontFamily: MONOSPACED_FONT,
                        fontFamilyFallback: MONOSPACED_FONT_BACK,
                      ),
                    ),
                  ),
                ],
              ),
              Divider(),
              ExpansionTile(
                title: Text('Response'),
                childrenPadding: EdgeInsets.symmetric(horizontal: 10),
                children: [
                  if (item.data != null)
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Theme.of(context).dividerColor),
                      ),
                      constraints: BoxConstraints.expand(height: 400, width: 1000),
                      child: JsonWidget(json: item.data!, search: false),
                      // SelectableText(
                      //   prettyJson(item.data, indent: 4),
                      //   style: TextStyle(
                      //     fontFamily: MONOSPACED_FONT,
                      //     fontFamilyFallback: MONOSPACED_FONT_BACK,
                      //   ),
                      // ),
                    ),
                  if (item.error != null)
                    Container(
                      constraints: BoxConstraints.expand(height: 400),
                      child: SingleChildScrollView(
                        child: HtmlWidget(item.error.toString()),
                        // childhild: Text(item.error),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _rowItem(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // SizedBox(width: 10),
        Expanded(flex: 1, child: Text(label)),
        Expanded(
          flex: 6,
          child: SelectableText(
            value,
            style: TextStyle(
              fontFamily: MONOSPACED_FONT,
              fontFamilyFallback: MONOSPACED_FONT_BACK,
            ),
          ),
        ),
        // SizedBox(width: 10),
      ],
    );
  }

  Widget separatorBuilder(BuildContext context, int index) {
    return Divider(thickness: 1, height: 1);
  }
}
