import 'package:bot_toast/bot_toast.dart';
import 'package:flutter_smart_genome/widget/basic/custom_spin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_genome/bean/site_item.dart';
import 'package:flutter_smart_genome/bean/datasets.dart';
import 'package:flutter_smart_genome/network/core/http_error.dart';
import 'package:flutter_smart_genome/network/http_response.dart';
import 'package:flutter_smart_genome/service/single_cell_service.dart';
import 'package:flutter_smart_genome/util/debouncer.dart';
import 'package:flutter_smart_genome/widget/loading_widget.dart';
import 'package:flutter_smart_genome/extensions/widget_extensions.dart';
import 'package:get/get.dart';

import 'cell_cluster_selector/cell_cluster_selector_view.dart';

class SCDataSetLogic extends GetxController {
  bool _loading = false;
  HttpError? _error = null;
  List<SCSet> _data = [];

  bool get loading => _loading;

  HttpError? get error => _error;

  List<SCSet> get data => _data;

  late SiteItem _site;
  Debounce? _debounce;

  SCDataSetLogic(this._site);

  @override
  void onInit() {
    _debounce = Debounce(milliseconds: 10000);
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();

    _loadData();
  }

  reload() async {
    _loadData();
  }

  _loadData() async {
    var resp = await loadCellTrackList(
      speciesId: _site.currentSpeciesId!,
      host: _site.url,
      refresh: true,
    );
    // _data = resp.body ?? [];
    _loading = false;
    _error = resp.error;
    update();

    if ((_data).any((t) => !t.statusDone)) {
      _debounce!.run(() => _loadData());
    }
  }

  @override
  void onClose() {
    super.onClose();
    _debounce?.dispose();
  }
}

class SCDataListView extends StatefulWidget {
  final SiteItem site;

  SCDataListView({
    Key? key,
    required this.site,
  }) : super(key: key);

  @override
  _SCDataListViewState createState() => _SCDataListViewState();
}

class _SCDataListViewState extends State<SCDataListView> {
  SCDataSetLogic? logic;

  @override
  void initState() {
    super.initState();
    logic = Get.put(SCDataSetLogic(widget.site));
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SCDataSetLogic>(
      init: logic,
      builder: (logic) {
        Widget _body;
        if (logic.loading || logic.error != null) {
          _body = LoadingWidget(
            simple: false,
            loadingState: logic.loading ? LoadingState.loading : LoadingState.error,
            message: logic.error!.message,
          );
        } else if (logic.data.length == 0) {
          _body = Center(
            child: OutlinedButton.icon(
              icon: Icon(Icons.add, size: 32),
              onPressed: _addDataSet,
              label: Text('Add SC Data'),
              style: OutlinedButton.styleFrom(
                minimumSize: Size(200, 128),
                textStyle: TextStyle(fontSize: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
            ),
          );
        } else {
          _body = ListView.builder(
            itemBuilder: _itemBuilder,
            itemCount: logic.data.length,
          );
        }
        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Text(
              'SC Data List',
              style: TextStyle(color: Colors.white),
            ),
            systemOverlayStyle: SystemUiOverlayStyle.dark,
            backgroundColor: Colors.orange,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8))),
            leading: null,
            automaticallyImplyLeading: false,
            actions: [
              if (logic.loading) CustomSpin(color: Theme.of(context).colorScheme.primary),
              if (!logic.loading)
                IconButton(
                  onPressed: () => logic.reload(),
                  icon: Icon(Icons.refresh),
                  color: Colors.white,
                  tooltip: 'Refresh List',
                ),
              IconButton(
                onPressed: _addDataSet,
                icon: Icon(Icons.add_box),
                tooltip: 'Add SC Data',
                color: Colors.white,
              ),
              SizedBox(width: 10),
            ],
          ),
          body: _body,
        );
      },
    );
  }

  Widget _itemBuilder(context, index) {
    SCSet _track = logic!.data[index];
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        child: Text('${_track.name!.substring(0, 1).toUpperCase()}', style: TextStyle(fontSize: 18)),
      ),
      title: Text('${_track.name}'),
      subtitle: Text('Description: ${_track.description ?? ''}'),
      onTap: () {},
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          OutlinedButton.icon(
            label: Text('Link Genome Data'),
            onPressed: () => _linkGenomeData(_track),
            icon: Icon(Icons.dataset_linked),
          ),
          SizedBox(width: 10),
          Chip(
            avatar: _track.statusDone ? Icon(Icons.check_circle_rounded) : CustomSpin(color: Theme.of(context).colorScheme.primary),
            label: Text('${_track.status}'),
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () => _deleteConfirm(_track),
          ),
        ],
      ),
    ).withBottomBorder(color: Theme.of(context).dividerColor);
  }

  _linkGenomeData(SCSet track) async {
    var resp = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) {
        return AlertDialog(
          title: Text('Select columns you want to set as Cluster'),
          // scrollable: true,
          content: Container(
            // constraints: BoxConstraints.tightFor(width: 200, height: Get.context.height * .6),
            child: CellClusterSelectorView(
              site: widget.site,
              scId: track.id,
              onCancel: () => Navigator.pop(c, false),
              onCommit: () => Navigator.pop(c, true),
            ),
          ),
        );
      },
    );
  }

  _deleteConfirm(SCSet track) async {
    var dialog = AlertDialog(
      title: Text('Delete single cell track?'),
      content: Text("Are you sure wan't to delete track { ${track.name} } ?"),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(false);
          },
          child: Text('CANCEL'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () {
            Navigator.of(context).pop(true);
          },
          child: Text('DELETE'),
        ),
        SizedBox(width: 10),
      ],
    );
    var result = await showDialog(context: context, builder: (context) => dialog);
    if (result) {
      _deleteDataSet(track);
    }
  }

  _addDataSet() async {
    // Navigator.of(context).pushNamed(
    //   RoutePath.manage_sc_add,
    //   arguments: SpeciesEditParams(widget.site, null, ),
    // );
  }

  _deleteDataSet(SCSet track) async {
    BotToast.showLoading(clickClose: false);
    HttpResponseBean bean = await deleteSingleCell(host: widget.site.url, scId: track.id);
    BotToast.closeAllLoading();
    if (bean.success) {
      Get.snackbar(
        'Success',
        'Delete track success!',
        icon: Icon(Icons.check_circle),
        duration: Duration(milliseconds: 2000),
        margin: EdgeInsets.only(bottom: 10),
        borderColor: Get.theme.primaryColor,
        borderWidth: .5,
        maxWidth: 400,
        borderRadius: 5,
      );
      logic!.data.removeWhere((t) => t.id == track.id);
      setState(() {});
    } else {
      Get.snackbar(
        'Error',
        'Delete fail!',
        icon: Icon(Icons.error),
        duration: Duration(milliseconds: 3000),
        margin: EdgeInsets.only(bottom: 10),
        borderColor: Get.theme.primaryColor,
        borderWidth: .5,
        maxWidth: 400,
        borderRadius: 5,
      );
    }
  }
}
