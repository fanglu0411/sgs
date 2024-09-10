import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/widget/basic/custom_spin.dart';
import 'package:flutter_smart_genome/network/core/http_error.dart';
import 'package:flutter_smart_genome/network/http_response.dart';
import 'package:flutter_smart_genome/widget/loading_widget.dart';

mixin AsyncDataLoaderMixin<T extends StatefulWidget, D> on State<T> {
  bool _loading = false;
  bool _loadingFinish = false;
  D? _data;
  HttpError? _error;

  bool get loading => _loading;

  HttpError? get error => _error;

  D? get data => _data;
  CancelToken? _fetchCancelToken;

  String get emptyMessage => 'Load data empty!';

  Duration get loadDelay => Duration.zero;

  bool get loadingFinish => _loadingFinish;

  _loadData() async {
    _loading = true;
    _loadingFinish = false;
    setState(() {});
    _fetchCancelToken?.cancel('reload');
    await Future.delayed(loadDelay + Duration(milliseconds: 200));
    _fetchCancelToken = CancelToken();
    final resp = await loadData(_fetchCancelToken!);
    if (resp.success) {
      _error = null;
      try {
        _data = await parseData(resp);

        await onBeforeSetData();
        _loading = false;
        if (_data == null) {
          _error = HttpError(-1, emptyMessage);
        }
      } catch (e, s) {
        // print(s);
        _error = HttpError(-1, "${e}");
      }
    } else {
      _error = resp.error;
    }
    _loading = false;
    if (mounted) setState(() {});
  }

  void reloadData() => _loadData();

  Future<HttpResponseBean> loadData(CancelToken cancelToken);

  Future<D?> parseData(HttpResponseBean resp);

  Future onBeforeSetData() async {
    _loadingFinish = true;
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Widget buildError() {
    return Center(
      child: LoadingWidget(
        loadingState: LoadingState.error,
        message: _error!.message,
        onErrorClick: (s) {
          reloadData();
        },
      ),
    );
  }

  Widget buildLoading() {
    return Center(
      child: CustomSpin(color: Theme.of(context).colorScheme.primary),
    );
  }

  Widget buildContent();

  Widget buildEmpty() {
    return LoadingWidget(
      loadingState: LoadingState.error,
      message: 'Data not loaded!',
      onErrorClick: (s) {
        _loadData();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return buildLoading();
    }
    if (_error != null) {
      return buildError();
    }
    if (_data == null) {
      return buildEmpty();
    }
    return buildContent();
  }

  @override
  void dispose() {
    super.dispose();
    _fetchCancelToken?.cancel("view dispose");
  }
}
