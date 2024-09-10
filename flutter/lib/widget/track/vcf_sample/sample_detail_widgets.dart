import 'package:flutter_smart_genome/widget/basic/custom_spin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/bean/feature_beans.dart';
import 'package:flutter_smart_genome/bean/site_item.dart';
import 'package:flutter_smart_genome/components/range_info_widget.dart';
import 'package:flutter_smart_genome/service/abs_platform_service.dart';
import 'package:flutter_smart_genome/service/sgs_app_service.dart';
import 'package:flutter_smart_genome/widget/quick_data_grid/quick_data_grid.dart';
import 'package:flutter_smart_genome/widget/table/simple_data_table.dart';
import 'package:dartx/dartx.dart' as dx;
import 'package:flutter_smart_genome/widget/track/base/track_data.dart';
import 'package:flutter_smart_genome/widget/track/chromosome/chromosome_data.dart';

class SampleDetailWidget extends StatefulWidget {
  final Feature feature;

  // final List samples;
  // final Map variantMap;
  final Track track;
  final ChromosomeData chr;

  const SampleDetailWidget({
    Key? key,
    required this.feature,
    // this.samples,
    // this.variantMap,
    required this.track,
    required this.chr,
  }) : super(key: key);

  @override
  State<SampleDetailWidget> createState() => _SampleDetailWidgetState();
}

class _SampleDetailWidgetState extends State<SampleDetailWidget> {
  Feature? _detailFeature;
  bool _loading = false;
  String? _error = null;

  @override
  void initState() {
    super.initState();
    // _detailFeature = widget.feature;
    _loadDetail();
  }

  @override
  void didUpdateWidget(SampleDetailWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.feature.featureId != widget.feature.featureId) {
      _loadDetail();
    }
  }

  _loadDetail() async {
    _loading = true;
    _error = null;
    _detailFeature = null;
    setState(() {});
    SiteItem _site = SgsAppService.get()!.site!;
    var blockMap = await AbsPlatformService.get()!.findFileNameInRage(
      host: _site.url,
      range: widget.feature.range,
      track: widget.track,
      species: _site.currentSpeciesId!,
      chr: widget.chr.id,
      level: 3,
      inflate: false,
    );
    var blockIndex = blockMap.entries.first.key;
    _detailFeature = await AbsPlatformService.get()!.loadFeatureDetail(
      host: _site.url,
      blockIdx: int.tryParse(blockIndex)!,
      chrId: widget.chr.id,
      chrName: widget.chr.chrName,
      trackId: widget.track.parentId!,
      featureId: widget.feature.featureId,
      trackType: widget.track.bioType,
    );
    setState(() {
      _loading = false;
      _error = _detailFeature == null ? 'load detail error' : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: _build);
  }

  Widget _build(BuildContext context, BoxConstraints constraints) {
    List<Map>? _samples;
    Map baseInfo = {
      "feature_id": widget.feature.featureId,
      "feature_name": widget.feature.name,
      "position": '${widget.chr.chrName}: ${widget.feature.range.print('..')}',
    };
    if (_detailFeature != null) {
      Map? sample_info = _detailFeature!['sample_info'];
      if (null != sample_info && !sample_info.isEmpty) {
        Map samples = sample_info['genotype info'];
        var header = samples['header'];
        List data = samples['data'] ?? [];
        _samples = data.map<Map>((e) {
          return Map.fromIterables(header, e);
        }).toList();
      }

      baseInfo = {..._detailFeature!.json}..remove('sample_info');
      // var alt = baseInfo['alt detail'];
      // baseInfo..remove('alt detail');
      // baseInfo['alt detail'] = alt;
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            decoration: BoxDecoration(
              color: Theme.of(context).focusColor,
              border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
            ),
            child: Text('${widget.feature.name}'),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: TreeInfoWidget(
              data: baseInfo,
              expandedAll: true,
              shrinkWrap: true,
            ),
          ),
          // MapInfoWidget(data: baseInfo),
          // SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: SampleStatic(variantStatic: _detailFeature?['sample_info']?['variant statistic']),
          ),
          if (_loading)
            Container(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: CustomSpin(color: Theme.of(context).colorScheme.primary),
            ),
          if (_samples != null)
            ConstrainedBox(
              constraints: BoxConstraints(minHeight: 200, maxHeight: 400),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: QuickDataGrid(
                  data: _samples,
                  paginated: true,
                  pageSize: 50,
                  minWidth: constraints.maxWidth - 16,
                  errorBuilder: (c) => Text('Empty data!'),
                  headBuilder: (c) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      'Sample genome type info (${_samples?.length ?? ''})',
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(fontSize: 18),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class SampleStatic extends StatelessWidget {
  final Map? variantStatic;

  const SampleStatic({Key? key, this.variantStatic}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (null == variantStatic) {
      return Container();
    }
    List<Map> _variants = variantStatic!.keys.mapIndexed((index, v) {
      List vv = variantStatic![v];
      return {
        'variant type': v,
        'sample num': vv[0],
        'frequency': vv[1],
      };
    }).toList();
    return Container(
      constraints: BoxConstraints(maxHeight: 170),
      child: QuickDataGrid(
        data: _variants,
        paginated: false,
        headBuilder: (c) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            'Sample genotype static',
            style: Theme.of(context).textTheme.titleSmall!.copyWith(fontSize: 18),
          ),
        ),
      ),
      // SimpleDataTable(data: _variants),
    );
  }
}
