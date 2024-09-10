import 'package:bot_toast/bot_toast.dart';
import 'package:dio/dio.dart';
import 'package:flutter_smart_genome/service/sgs_app_service.dart';
import 'package:flutter_smart_genome/util/logger.dart';
import 'package:flutter_smart_genome/widget/basic/custom_bot_widget.dart';
import 'package:flutter_smart_genome/widget/basic/custom_spin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/bean/site_item.dart';
import 'package:flutter_smart_genome/bean/datasets.dart';
import 'package:flutter_smart_genome/network/core/http_error.dart';
import 'package:flutter_smart_genome/extensions/widget_extensions.dart';
import 'package:flutter_smart_genome/service/abs_platform_service.dart';
import 'package:flutter_smart_genome/util/debouncer.dart';
import 'package:flutter_smart_genome/widget/loading_widget.dart';
import 'package:get/get.dart';

class SpeciesListLogic extends GetxController {
  static SpeciesListLogic? safe() {
    if (Get.isRegistered<SpeciesListLogic>()) {
      return Get.find<SpeciesListLogic>();
    }
    return null;
  }

  bool _loading = true;
  HttpError? _error;

  bool get loading => _loading;

  HttpError? get error => _error;

  List<Species> _speciesList = [];

  List<Species> get speciesList => _speciesList;

  late Debounce _debounce;
  SiteItem? _site;
  CancelToken? _cancelToken;

  SpeciesListLogic() {
    _debounce = Debounce(milliseconds: 10000);
  }

  changeSite(SiteItem site, {bool didUpdate = false, bool refresh = false}) async {
    _site = site;
    if (_loading) {
      _cancelToken?.cancel('site changed');
      _cancelToken = null;
      await Future.delayed(Duration(milliseconds: 200));
    }
    loadSpecies(showLoading: !didUpdate, refresh: refresh);
  }

  void loadSpecies({bool showLoading = true, bool refresh = false}) async {
    _loading = true;
    _error = null;
    if (showLoading) update();
    _cancelToken = CancelToken();
    final _result = await AbsPlatformService.get(_site)!.loadSpeciesList(
      host: _site?.url ?? '',
      forceRefresh: refresh,
      cancelToken: _cancelToken,
    );
    _loading = false;
    if (_result.success) {
      _speciesList = _result.body ?? [];
      SgsAppService.get()!.updateSiteSpecies(_site!, _speciesList);
    } else {
      _error = _result.error;
    }
    update();
    if (_speciesList.any((e) => !(e.statusDone || e.statusError))) {
      _debounceRefreshList();
    }
  }

  void _debounceRefreshList() {
    _debounce.run(() => loadSpecies(refresh: true));
  }

  void clear() {
    _debounce.dispose();
  }

  @override
  void onClose() {
    _debounce.dispose();
    super.onClose();
  }
}

/// data set list
/// including genome data set and sc data set
class DataSetListWidget extends StatefulWidget {
  final SiteItem site;
  final String? selectedSpecies;
  final ValueChanged? onAddTap;
  final ValueChanged<Species>? onItemTap;
  final ValueChanged<Species>? onEditItem;
  final bool asPage;
  final bool cardMod;
  final bool refresh;
  final bool autoHeight;

  const DataSetListWidget({
    Key? key,
    required this.site,
    required this.selectedSpecies,
    this.onAddTap,
    this.onItemTap,
    this.onEditItem,
    this.asPage = false,
    this.cardMod = false,
    this.refresh = false,
    this.autoHeight = false,
  }) : super(key: key);

  @override
  _DataSetListWidgetState createState() => _DataSetListWidgetState();
}

class _DataSetListWidgetState extends State<DataSetListWidget> {
  String? _id;
  late String _siteId;

  final SpeciesListLogic logic = Get.put(SpeciesListLogic());

  @override
  void initState() {
    super.initState();
    _siteId = widget.site.sid;
    _id = widget.selectedSpecies;
    logic.changeSite(widget.site, didUpdate: true, refresh: widget.refresh);
  }

  @override
  void didUpdateWidget(DataSetListWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_siteId != widget.site.sid) {
      logic.changeSite(widget.site, didUpdate: true, refresh: widget.refresh);
    }
    _siteId = widget.site.sid;
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SpeciesListLogic>(
      init: logic,
      autoRemove: true,
      dispose: (s) {
        logic.clear();
      },
      builder: (logic) {
        if (logic.loading) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: LoadingWidget(loadingState: LoadingState.loading),
          );
        }
        if (logic.error != null) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20),
            child: LoadingWidget(
              loadingState: LoadingState.error,
              message: logic.error!.message,
              onErrorClick: (s) {
                logic.loadSpecies();
              },
            ),
          );
        }
        return _buildBody(context, logic.speciesList);
      },
    );
  }

  Widget _speciesListItemBuilder(Species _species) {
    bool speciesSelected = '${_species.id}' == _id;
    return ListTile(
      leading: _species.iconUrl != null
          ? CircleAvatar(
              child: Image.network(_species.iconUrl!),
            )
          : CircleAvatar(
              backgroundColor: Theme.of(context).dialogBackgroundColor,
              child: Text(
                '${_species.name!.substring(0, 1).toUpperCase()}',
              ),
              radius: 16,
            ),
      title: Text(
        '${_species.name}',
        style: speciesSelected ? TextStyle(color: Theme.of(context).colorScheme.primary) : null,
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 10),
      selected: speciesSelected,
      enabled: _species.statusDone,
      onTap: () {
        if (!_species.statusDone) {
          showToast(text: 'Species「${_species.name}」 is not ready');
          return;
        }
        setState(() {
          _id = '${_species.id}';
        });
        widget.onItemTap?.call(_species);
      },
    ).withBottomBorder(color: Theme.of(context).dividerColor);
  }

  Widget _speciesCardItemBuilder(Species _species) {
    bool speciesSelected = '${_species.id}' == _id;
    return Card(
      elevation: 2,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: _species.iconUrl != null
                ? CircleAvatar(
                    child: Image.network(_species.iconUrl!),
                  )
                : CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Text(
                      '${_species.name!.substring(0, 1).toUpperCase()}',
                      style: TextStyle(color: Colors.white70),
                    ),
                    radius: 16,
                  ),
            title: Text(
              '${_species.name}',
              style: speciesSelected ? TextStyle(color: Theme.of(context).colorScheme.primary) : null,
            ),
            trailing: Chip(
              avatar: _species.statusDone ? Icon(Icons.check_circle_rounded) : CustomSpin(color: Theme.of(context).colorScheme.primary),
              label: Text('${_species.status}'),
              backgroundColor: _species.statusDone ? Theme.of(context).colorScheme.primary.withAlpha(50) : null,
            ),
            onTap: () {
              if (!_species.statusDone) {
                showToast(text: 'Species「${_species.name}」 is not ready');
                return;
              }
              setState(() {
                _id = '${_species.id}';
              });
              widget.onItemTap?.call(_species);
            },
          ).withBottomBorder(color: Theme.of(context).dividerColor),
          ButtonBar(
            children: [
              TextButton(
                child: Text('Track List'),
                onPressed: () => widget.onItemTap!(_species),
              ),
              TextButton.icon(
                onPressed: () {},
                icon: Icon(Icons.delete),
                label: Text('DELETE'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, List<Species> species) {
    var _children = (species).map(widget.cardMod ? _speciesCardItemBuilder : _speciesListItemBuilder);

    Widget body = Container(
//      decoration: BoxDecoration(border: Border(top: BorderSide(color: Theme.of(context).dividerColor))),
      child: _children.length == 0
          ? Container(
              height: 80,
              child: LoadingWidget(
                loadingState: LoadingState.noData,
                message: 'Species is empty!',
              ),
            )
          : ListView(children: _children.toList()),
    );
    if (_children.length > 0 && widget.autoHeight) {
      double h = (_children.length * 48.0).clamp(80.0, MediaQuery.of(context).size.height * .85);
      body = SizedBox(height: h, child: body);
    }
    if (widget.asPage) {
      body = Scaffold(
        appBar: AppBar(title: Text('Select Species')),
        body: body,
      );
    }
    return body;
  }

  @override
  void dispose() {
    Get.delete<SpeciesListLogic>();
    super.dispose();
  }
}
