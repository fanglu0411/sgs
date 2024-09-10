import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/bean/site_item.dart';
import 'package:flutter_smart_genome/page/species/species_list_widget.dart';
import 'package:flutter_smart_genome/page/site/site_selector_widget.dart';
import 'package:flutter_smart_genome/service/sgs_app_service.dart';
import 'package:flutter_smart_genome/storage/base_store_provider.dart';
import 'package:flutter_smart_genome/storage/isar/site_provider.dart';
import 'package:flutter_smart_genome/widget/split_widget.dart' as sw;

class SiteSpeciesSelectorWidget extends StatefulWidget {
  final SiteItem? site;
  final ValueChanged<SiteItem>? onChanged;
  final Axis axis;
  final VoidCallback? onEvent;

  const SiteSpeciesSelectorWidget({
    Key? key,
    this.site,
    this.onChanged,
    this.axis = Axis.vertical,
    this.onEvent,
  }) : super(key: key);

  @override
  _SiteSpeciesSelectorWidgetState createState() => _SiteSpeciesSelectorWidgetState();
}

class _SiteSpeciesSelectorWidgetState extends State<SiteSpeciesSelectorWidget> {
  SiteItem? _currentSite;
  List<SiteItem> _siteList = [];

  @override
  void initState() {
    super.initState();
    _currentSite = widget.site;
    _loadSites();
  }

  void _loadSites() async {
    _siteList = await BaseStoreProvider.get().getSiteList();
    // setState(() {});
  }

  @override
  void didUpdateWidget(covariant SiteSpeciesSelectorWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _currentSite = widget.site;
  }

  @override
  Widget build(BuildContext context) {
    Widget _speciesList = _buildSpeciesList();

    Widget _siteListWidget = SiteSelectorWidget(
      site: _currentSite,
      onChanged: (site) {
        _currentSite = site;
        setState(() {});
      },
      onEvent: widget.onEvent,
    );
    if (widget.axis == Axis.vertical) {
      _speciesList = ClipRect(
        child: _speciesList,
        clipBehavior: Clip.antiAlias,
      );
    }
    // if (SgsConfigService.get().ideMode) {
    return sw.Split(
      initialFractions: widget.axis == Axis.horizontal ? [.45, .55] : [.55, .45],
      axis: widget.axis,
      children: [_siteListWidget, _speciesList],
    );
  }

  Widget _buildSpeciesList() {
    if (_currentSite == null) {
      return Container();
    }
    var curSpeciesId = SgsAppService.get()!.site?.currentSpeciesId;
    Widget list = DataSetListWidget(
      site: _currentSite ?? _siteList.first,
      selectedSpecies: curSpeciesId,
      refresh: true,
      onItemTap: (sps) {
        _currentSite!
          ..currentSpeciesId = '${sps.id}'
          ..currentSpecies = sps.name;
        widget.onChanged?.call(_currentSite!);
      },
    );
    return list;
  }
}
