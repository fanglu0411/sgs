import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/bean/site_item.dart';
import 'package:flutter_smart_genome/network/core/http_error.dart';
import 'package:flutter_smart_genome/service/single_cell_service.dart';
import 'package:get/get.dart';

class CellClusterSelectorLogic extends GetxController {
  Map _clusters = {};
  bool _loading = true;
  HttpError? _error = null;

  int get count => _clusters.length;

  bool get isEmpty => _clusters.length == 0;

  String scId;
  SiteItem site;

  HttpError? get error => _error;

  bool get loading => _loading;

  Map get clusters => _clusters;
  bool _submit = false;

  CellClusterSelectorLogic(this.site, this.scId) {}

  bool get submit => _submit;

  @override
  void onReady() {
    super.onReady();
    _loadData();
  }

  void reloadData() => _loadData();

  _loadData() async {
    var resp = await loadAllPotentialClusters(host: site.url, scId: this.scId);
    _loading = false;
    if (resp.success) {
      _clusters = resp.body ?? {};
      _error = null;
    } else {
      _error = resp.error;
    }
    update();
  }

  Widget itemBuilder(cluster) {
    return CheckboxListTile(
      value: _clusters[cluster] == 'y' ? true : false,
      onChanged: (v) {
        _clusters[cluster] = v! ? 'y' : 'n';
        update();
      },
      title: Text('${cluster}'),
    );
  }

  @override
  void onClose() {
    super.onClose();
  }

  void cancel() {
    try {
      if (_cancelToken != null && !_cancelToken!.isCancelled) _cancelToken?.cancel();
    } catch (e) {}
  }

  CancelToken? _cancelToken;

  void commit(VoidCallback? onCommit) async {
    List __clusters = [];
    _clusters.forEach((key, value) {
      if (value == 'y') __clusters.add(key);
    });

    if (_clusters.length == 0) {
      return;
    }
    _submit = true;
    update();
    _cancelToken = CancelToken();
    var resp = await confirmClusters(clusters: __clusters, scId: scId, host: site.url, cancelToken: _cancelToken);
    if (resp.success) {
      onCommit?.call();
      Get.showSnackbar(GetSnackBar(
        title: 'Success',
        icon: Icon(Icons.check_circle),
        duration: Duration(milliseconds: 2000),
        message: 'set clusters success!',
        margin: EdgeInsets.only(bottom: 10),
        borderColor: Get.theme.primaryColor,
        borderWidth: .5,
        maxWidth: 400,
        borderRadius: 5,
      ));
    } else {
      _submit = false;
      update();
      Get.showSnackbar(GetSnackBar(
        title: 'Error',
        message: resp.error!.message,
        icon: Icon(Icons.error),
        duration: Duration(milliseconds: 4000),
        margin: EdgeInsets.only(bottom: 10),
        borderColor: Get.theme.primaryColor,
        borderWidth: .5,
        maxWidth: 400,
        borderRadius: 5,
      ));
    }
  }
}
