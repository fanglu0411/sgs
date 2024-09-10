import 'package:flutter_smart_genome/widget/basic/custom_spin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/bean/site_item.dart';
import 'package:get/get.dart';

import 'cell_cluster_selector_logic.dart';

class CellClusterSelectorView extends StatefulWidget {
  final SiteItem site;
  final String scId;
  final VoidCallback? onCancel;
  final VoidCallback? onCommit;

  const CellClusterSelectorView({
    Key? key,
    required this.site,
    required this.scId,
    this.onCancel,
    this.onCommit,
  }) : super(key: key);

  @override
  _CellClusterSelectorViewState createState() => _CellClusterSelectorViewState();
}

class _CellClusterSelectorViewState extends State<CellClusterSelectorView> {
  @override
  void initState() {
    super.initState();
    Get.put(CellClusterSelectorLogic(widget.site, widget.scId));
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CellClusterSelectorLogic>(builder: (logic) {
      double screenHeight = Get.context!.height;
      if (logic.loading || logic.error != null) {
        return Container(
          height: screenHeight * .6,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: logic.loading ? CustomSpin(color: Theme.of(context).colorScheme.primary) : Text(logic.error!.message),
              ),
              if (!logic.loading)
                ButtonBar(
                  alignment: MainAxisAlignment.center,
                  children: [
                    OutlinedButton(onPressed: () => logic.reloadData(), child: Text('Reload')),
                    ElevatedButton(
                      onPressed: widget.onCancel,
                      child: Text('Close'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    ),
                  ],
                )
            ],
          ),
        );
      }
      int height = logic.clusters.keys.length * 40 + 300;

      bool _scroll = height > screenHeight;
      var children = ListTile.divideTiles(
        tiles: logic.clusters.keys.map(logic.itemBuilder),
        context: context,
        color: Theme.of(context).dividerColor,
      ).toList();
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_scroll)
            Container(
              height: screenHeight - 300,
              child: SingleChildScrollView(
                child: Column(mainAxisSize: MainAxisSize.min, children: children),
              ),
            ),
          if (!_scroll) ...children,
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(
                style: OutlinedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () {
                  logic.cancel();
                  widget.onCancel?.call();
                },
                child: Text('Cancel'),
              ),
              SizedBox(width: 10),
              if (logic.submit)
                ElevatedButton.icon(
                  icon: CustomSpin(color: Theme.of(context).colorScheme.primary),
                  onPressed: null,
                  label: Text('Submiting'),
                ),
              if (!logic.submit)
                ElevatedButton(
                  onPressed: () {
                    logic.commit(widget.onCommit);
                  },
                  child: Text('Submit'),
                ),
            ],
          )
        ],
      );
    });
  }

  @override
  void dispose() {
    Get.delete<CellClusterSelectorLogic>();
    super.dispose();
  }
}
