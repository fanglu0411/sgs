
import 'package:flutter_smart_genome/widget/basic/custom_spin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/bean/site_item.dart';
import 'package:flutter_smart_genome/components/setting_config_widget.dart';
import 'package:flutter_smart_genome/service/abs_platform_service.dart';
import 'package:flutter_smart_genome/service/sgs_app_service.dart';
import 'package:flutter_smart_genome/service/sgs_service_delegate.dart';
import 'package:flutter_smart_genome/widget/loading_widget.dart';
import 'package:flutter_smart_genome/widget/relation/hic_relation/circle_interactive_painter_fast.dart';
import 'package:flutter_smart_genome/widget/relation/hic_relation/interactive_data.dart';
import 'package:flutter_smart_genome/widget/track/base/track_data.dart';
import 'package:flutter_smart_genome/widget/track/chromosome/chromosome_data.dart';
import 'package:get/get.dart';

class GlobalCircleInteractiveWidget extends StatefulWidget {
  final ChromosomeData chr;
  final Track track;
  final SiteItem site;

  const GlobalCircleInteractiveWidget({Key? key, required this.chr, required this.track, required this.site}) : super(key: key);

  @override
  _GlobalCircleInteractiveWidgetState createState() => _GlobalCircleInteractiveWidgetState();
}

class _GlobalCircleInteractiveWidgetState extends State<GlobalCircleInteractiveWidget> {
  List<ChromosomeData>? chromosomes;
  Map<ChromosomeData, List<InteractiveItem>>? _interactions;
  Map<ChromosomeData, int>? __interactions;

  List<SettingItem>? _settings;
  RangeValues? rangeValue;
  late Map<String, bool> chrSelection;

  double _maxValue = 0;

  @override
  void initState() {
    super.initState();
    _settings = [];
    rangeValue = RangeValues(0, 1000);

    _load();
  }

  _load() async {
    _maxValue = 0;
    var chromosomes = SgsAppService.get()!.chromosomes!;

    ChromosomeData? findChr(String id) {
      return chromosomes.firstWhereOrNull((e) => e.id == id);
    }

    Map _data = await (AbsPlatformService.get() as SgsServiceDelegate).loadGlobalInteractiveData(
      host: widget.site.url,
      speciesId: widget.site.currentSpeciesId!,
      track: widget.track,
      chr: widget.chr.id,
    );
    // _interactions = _data.map((key, value) {
    //   List _value = value;
    //   List<InteractiveItem> items = _value.map((e) => InteractiveItem.fromList(e)).toList();
    //   _maxValue = max(items.maxBy((e) => e.value).value, _maxValue);
    //   return MapEntry(findChr(key), items);
    // });
    __interactions = _data.map((key, value) {
      return MapEntry(findChr(key)!, value);
    });
    chrSelection = __interactions!.map((key, value) => MapEntry(key.id, true));
    rangeValue = RangeValues(_maxValue * .9, _maxValue);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (null == __interactions) {
      return SizedBox(
        width: 200,
        height: 200,
        child: Center(
          child: CustomSpin(color: Theme.of(context).colorScheme.primary),
        ),
      );
    }
    if (__interactions!.length == 0) {
      return SizedBox(
        width: 200,
        height: 200,
        child: LoadingWidget(
          loadingState: LoadingState.error,
          message: 'Data Empty!',
          onErrorClick: (s) {
            _load();
          },
        ),
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
          child: CustomPaint(
            size: Size(600, 600),
            painter: CircleInteractivePainterFast(
              primaryChr: widget.chr,
              interactions: __interactions!,
              selectedChrList: chrSelection.keys.where((k) => chrSelection[k]!).toList(),
              rangeValues: rangeValue,
            ),
          ),
        ),
        SizedBox(width: 24),
        // _controlWidget(),
        Container(
          constraints: BoxConstraints(minWidth: 300, maxWidth: 300, minHeight: 600),
          child: _chrList(),
        ),
      ],
    );
  }

  Widget _controlWidget() {
    Color _color = Theme.of(context).colorScheme.primary;
    return Container(
      constraints: BoxConstraints(maxWidth: 300, minWidth: 300, minHeight: 500, maxHeight: 800),
      child: Column(
        // mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _chrList(),
          // Padding(
          //   padding: EdgeInsets.only(left: 8.0),
          //   child: Text('  Value Filter: '),
          // ),
          // RangeSlider(
          //   values: rangeValue,
          //   labels: RangeLabels('${rangeValue.start}', '${rangeValue.end}'),
          //   onChanged: (_rangeValue) {
          //     setState(() {
          //       rangeValue = _rangeValue;
          //     });
          //   },
          //   onChangeStart: (s) {
          //     //
          //   },
          //   activeColor: _color,
          //   inactiveColor: _color.withOpacity(.4),
          //   min: 0,
          //   max: _maxValue,
          //   semanticFormatterCallback: (double newValue) {
          //     return '${newValue.round()} dollars';
          //   },
          // ),
          // ListTile(
          //   dense: true,
          //   visualDensity: VisualDensity(horizontal: VisualDensity.minimumDensity, vertical: VisualDensity.minimumDensity),
          //   title: Text('Min: ${rangeValue.start.round()}'),
          //   trailing: Text('Max: ${rangeValue.end.round()}'),
          // ),
        ],
      ),
    );

    return SettingListWidget(
      settings: [],
    );
  }

  Widget _chrList() {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: ListTile.divideTiles(
          tiles: __interactions!.keys.map((e) {
            return CheckboxListTile(
              dense: true,
              title: Text(e.chrName),
              value: chrSelection[e.id],
              onChanged: (v) {
                setState(() {
                  chrSelection[e.id] = v!;
                });
              },
            );
          }),
          context: context,
        ).toList(),
      ),
    );
  }
}
