import 'package:dartx/dartx.dart' as dx;
import 'package:dio/dio.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/bean/feature_beans.dart';
import 'package:flutter_smart_genome/bean/site_item.dart';
import 'package:flutter_smart_genome/components/sequence/async_sequence_widget.dart';
import 'package:flutter_smart_genome/components/tree_widget.dart';
import 'package:flutter_smart_genome/service/abs_platform_service.dart';
import 'package:flutter_smart_genome/service/sgs_app_service.dart';
import 'package:flutter_smart_genome/widget/basic/scroll_controller_builder.dart';
import 'package:flutter_smart_genome/widget/track/base/track_data.dart';
import 'package:flutter_smart_genome/extensions/widget_extensions.dart';
import 'package:flutter_smart_genome/widget/track/chromosome/chromosome_data.dart';
import 'package:get/get.dart';
import 'package:pretty_json/pretty_json.dart';

List baseInfoSkipKeys = ['view_type', 'sgs_id', 'attributes', 'sub_feature', 'sub_features', 'children', 'start', 'end'];

class RangeInfoWidget extends StatefulWidget {
  final Feature feature;
  final String? rootFeatureId;
  final String species;
  final ChromosomeData chr;
  final Track track;
  final bool asPage;

  const RangeInfoWidget({
    Key? key,
    required this.feature,
    this.rootFeatureId,
    required this.chr,
    required this.species,
    required this.track,
    this.asPage = true,
  }) : super(key: key);

  @override
  _RangeInfoWidgetState createState() => _RangeInfoWidgetState();
}

class _RangeInfoWidgetState extends State<RangeInfoWidget> with TickerProviderStateMixin {
  TabController? _tabController;
  List<String> _tabs = [];

  Feature? _detailFeature;

  CancelToken? cancelToken;

  @override
  void initState() {
    super.initState();
    _tabs = <String>[
      'Basic Info',
      if (widget.track.isGff || widget.track.isBed) 'Sequence',
      if (widget.feature.hasSubFeature) 'SubFeature',
      if (widget.feature.hasChildren) 'Children',
    ];
    _tabController = TabController(length: _tabs.length, vsync: this);
    _loadFeatureDetail();
  }

  _loadFeatureDetail() async {
    if (!(widget.track.isGff || widget.track.isVcfCoverage || widget.track.isBamReads || widget.track.isVcfCoverage || widget.track.isVcfSample || widget.track.isEqtl)) return;
    var _featureId = widget.feature.featureId;
    // print('root feature id: ${widget.rootFeatureId}');
    if (widget.track.isGff) {
      _featureId = widget.rootFeatureId ?? widget.feature.uniqueId;
    } else if (widget.track.isEqtl) {
      _featureId = widget.feature['snp'];
    }
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
    cancelToken?.cancel('new feature detail request rich!');
    cancelToken = CancelToken();
    var blockIndex = widget.track.isEqtl ? '0' : blockMap.entries.first.key;
    _detailFeature = await AbsPlatformService.get()!.loadFeatureDetail(
      host: _site.url,
      blockIdx: int.parse(blockIndex),
      chrId: widget.chr.id,
      chrName: widget.chr.chrName,
      trackId: widget.track.id!,
      featureId: _featureId,
      trackType: widget.track.bioType,
      cancelToken: cancelToken,
    );

    if (widget.track.isGff) {
      if (_featureId != widget.feature.featureId && (_detailFeature?.hasChildren ?? false)) {
        _detailFeature = _detailFeature!.children!.firstOrNullWhere((f) => f.featureId == widget.feature.featureId);
      }
    } else if (widget.track.isEqtl) {
      _detailFeature = _detailFeature?.children?.firstWhereOrNull((f) => f['p'] == widget.feature['p']);
    }

    // print(_detailFeature?.json);

    if (_detailFeature == null) return;
    _tabs = <String>[
      'Basic Info',
      if (widget.track.isGff || widget.track.isBed) 'Sequence',
      if (_detailFeature!.hasSubFeature) 'SubFeature',
      if (_detailFeature!.hasChildren) 'Children',
    ];

    _tabController?.dispose();
    _tabController = TabController(length: _tabs.length, vsync: this);
    if (mounted) setState(() {});
  }

  @override
  void didUpdateWidget(covariant RangeInfoWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.feature != widget.feature) {
      _tabs = <String>[
        'Basic Info',
        if (widget.track.isGff || widget.track.isBed) 'Sequence',
        if (widget.feature.hasSubFeature) 'SubFeature',
        if (widget.feature.hasChildren) 'Children',
      ];
      _tabController?.dispose();
      _tabController = TabController(length: _tabs.length, vsync: this);
      _loadFeatureDetail();
    }
  }

  Widget _tabItem(String title) {
    return Text(title);
  }

  @override
  Widget build(BuildContext context) {
    Feature feature = _detailFeature ?? widget.feature;
    //bool dark = Theme.of(context).brightness == Brightness.dark;
    TabBar? tabBar = _tabs.length > 1
        ? TabBar(
            indicatorWeight: 1,
            indicatorColor: Theme.of(context).colorScheme.primary,
            controller: _tabController,
            labelPadding: EdgeInsets.symmetric(vertical: 4),
            unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w300),
            tabs: _tabs.map<Widget>(_tabItem).toList(),
            labelColor: Theme.of(context).textTheme.displayMedium!.color,
          )
        : null;

    Widget tabView = TabBarView(
      controller: _tabController,
      physics: NeverScrollableScrollPhysics(),
      children: [
        _buildBasicInfo(feature),
        if (widget.track.isGff || widget.track.isBed)
          AsyncSequenceWidget(
            range: feature.range,
            strand: feature.strand,
            species: widget.species,
            chr: widget.chr.id,
            simple: true,
            featureId: feature.featureId,
            header: _sequenceHeader(feature),
          ),
        if (feature.hasSubFeature) _buildSubFeatures(feature.subFeatures!.where((e) => e['view_type'] != BedFeature.ENHANCE_BLOCK_TYPE).toList()),
        if (feature.hasChildren) _buildSubFeatures(feature.children!),
      ],
    );

    if (widget.asPage) {
      return Scaffold(
        appBar: AppBar(
          title: Text('${feature.featureId}', softWrap: true),
          bottom: tabBar,
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: tabView,
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Container(
        //   padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        //   decoration: BoxDecoration(
        //     border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
        //   ),
        //   child: Text('${feature.featureId}'),
        // ),
        if (tabBar != null) Container(child: tabBar, constraints: BoxConstraints.expand(height: 30)),
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: tabView,
          ),
        ),
      ],
    );
  }

  String _sequenceHeader(Feature feature) {
    var range = widget.track.isGff ? feature.toZeroStartRange : feature.range;
    return '>${feature.featureId} ${widget.chr.chrName}:${range.print2('..')} (${feature.strandStr} strand) class=${feature.type} length=${range.size.toInt()}';
  }

  Widget _buildBasicInfo(Feature feature) {
    Map json = _toDetailJson(feature);

    if (feature is GffFeature) {
      var attrs = feature['attributes'] ?? feature['Attributes'];
      return ScrollControllerBuilder(builder: (c, controller) {
        return SingleChildScrollView(
          controller: controller,
          child: Column(
            children: [
              _buildTitle('Primary Data', true),
              TreeInfoWidget(
                data: {
                  ...feature.json,
                  'Length': widget.track.isGff ? feature.toZeroStartRange.lengthStr : feature.range.lengthStr + ' bp',
                },
                skipKeys: baseInfoSkipKeys,
                shrinkWrap: true,
                expandedAll: true,
              ),
              if (attrs != null) _buildTitle('Attributes', true),
              if (attrs != null) _buildAttributes(feature),
            ],
          ),
        );
      });
    }
    return TreeInfoWidget(
      data: json,
      skipKeys: ['sub_feature', 'sgs_id', 'sub_features', 'children', 'start', 'end'],
      shrinkWrap: false,
      expandedAll: true,
    );
  }

  Widget _buildTitle(String _title, bool expanded) {
    return ListTile(
      selected: expanded,
      dense: true,
      title: Text(
        _title,
        style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.normal, fontSize: 18),
      ),
    );
  }

  Widget _buildRangeInfo(Feature feature) {
    Map _map = feature.toJson();
    List skipKeys = ['view_type', 'sgs_id', 'attributes', 'sub_feature', 'sub_features', 'children'];
    var keys = _map.keys.where((value) => !skipKeys.contains(value));
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: keys.mapIndexed((i, e) {
          return _buildItem(context, i, e, _map[e]);
        }).toList(),
      ),
    );
  }

  Widget _buildAttributes(Feature feature) {
    var attrs = feature['attributes'] ?? feature['Attributes'];

    if (attrs is Map) {
      return MapInfoWidget(data: attrs);
    }

    if (attrs == null || attrs.length == 0) {
      return Container(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Text('No Attributes'),
      );
    }

    List pairs = attrs.split('\],');
    int i = 0;
    List _attrs = pairs.map((pair) {
      i++;
      var _arr = pair.split(':\[');
      String key = _arr[0];
      String value = _arr[1].substring(1);
      if (i == pairs.length) {
        value = value.replaceFirst('\'\]', '');
      } else {
        value = value.substring(0, value.length - 1);
      }
//      print(value);
      if (value.contains('\', \'')) {
        value = value.split('\', \'').join('\n');
      }

      return {'key': key, 'value': value};
    }).toList();

    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: _attrs.mapIndexed((i, e) {
          return _buildItem(context, i, e['key'], e['value']);
        }).toList(),
      ),
    );
  }

  Widget _buildSubFeatures(List<Feature> features) {
    return SubFeatureListWidget(
      features: features,
      skipKeys: [...baseInfoSkipKeys, 'feature_name'],
      chrName: widget.chr.chrName,
    );

    var children = (features)
        .where((f) => f.type != 'intron')
        .map((feature) => MapInfoWidget(
              data: _toDetailJson(feature),
              skipKeys: [...baseInfoSkipKeys, 'feature_name'],
            ))
        .toList();

    return ScrollControllerBuilder(
      builder: (c, controller) {
        return ListView(children: children, controller: controller);
      },
    );
  }

  Map _toDetailJson(Feature feature) {
    Map json = feature.json;
    if (feature.range.isValid) {
      return {
        'position': '${widget.chr.chrName}:${feature.range.print('..')}(${feature.strandStr})',
        ...json,
      };
    }
    return json;
  }
}

Widget _buildItem(BuildContext context, int index, String label, var value) {
  String _value;
  bool isObj = false;
  if (value is Map) {
    _value = prettyJson(value, indent: 2);
    isObj = true;
  } else if (value is List) {
    isObj = true;
    _value = value.join(', ');
  } else {
    _value = '$value';
  }
  // bool moreLength = _value.length > 40;
  bool broken = _value.indexOf('\n') > 0;

  Widget _row = Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Theme.of(context).dividerTheme.color!)),
        // color: Theme.of(context).secondaryHeaderColor.withOpacity(.15),
        // borderRadius: BorderRadius.only(topLeft: Radius.circular(5), topRight: Radius.circular(5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SelectableText(
            '${label.replaceAll('_', ' ')}'.capitalizeFirst!,
            style: Theme.of(context).textTheme.labelMedium,
          ),
          SizedBox(width: 10),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SelectableText(
                  _value,
                  textAlign: isObj
                      ? TextAlign.start
                      : broken
                          ? TextAlign.right
                          : TextAlign.right,
                  style: TextStyle(
                    fontSize: 12,
                    // fontFamily: MONOSPACED_FONT,
                    // fontFamilyFallback: MONOSPACED_FONT_BACK,
                  ),
                );
              },
            ),
          ),
        ],
      ));
  return _row;
  return InkWell(
    onTap: () {},
    child: _row,
  );
}

class MapInfoWidget extends StatelessWidget {
  final Map data;
  final bool simple;
  final List? skipKeys;
  final Function? itemBuilder;

  const MapInfoWidget({
    Key? key,
    required this.data,
    this.simple = false,
    this.skipKeys = null,
    this.itemBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Map _map = data;
    var keys = skipKeys == null ? _map.keys : _map.keys.where((value) => !skipKeys!.contains(value));
    Widget _widget = Column(
      mainAxisSize: MainAxisSize.min,
      children: keys.mapIndexed((i, e) {
        Widget _item = itemBuilder?.call(context, e, _map[e]);
        return _item;
        return _buildItem(context, i, e, _map[e]);
      }).toList(),
    );
    if (!simple)
      _widget = Card(
        elevation: 4,
        child: _widget,
      );
    return _widget;
  }
}

// typedef NodeItemBuilder = Widget (BuildContext context, SimpleMapTreeNode node);

class TreeInfoWidget extends StatelessWidget {
  final Map data;
  final bool expandedAll;
  final bool shrinkWrap;
  final List skipKeys;
  final dx.Function2<BuildContext, SimpleMapTreeNode, Widget>? labelBuilder;
  final dx.Function2<BuildContext, SimpleMapTreeNode, Widget>? valueBuilder;

  const TreeInfoWidget({
    Key? key,
    required this.data,
    this.skipKeys = const [],
    this.expandedAll = false,
    this.shrinkWrap = false,
    this.labelBuilder,
    this.valueBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<SimpleMapTreeNode> nodes = SimpleMapTreeNode.fromMap(data, skipKeys: skipKeys, expandAll: expandedAll);
    return ScrollControllerBuilder(
      builder: (c, controller) {
        return TreeView<SimpleMapTreeNode>(
          controller: controller,
          shrinkWrap: shrinkWrap,
          dataRoots: nodes,
          parentNodeColor: Theme.of(context).colorScheme.primary.withAlpha(20),
          dataDisplayProvider: (item) {
            Widget rowWidget;
            if (item.value != null) {
              rowWidget = Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  (labelBuilder ?? _labelBuilder).call(context, item),
                  // SizedBox(width: 10),
                  (valueBuilder ?? _valueBuilder).call(context, item),
                  SizedBox(width: 10),
                ],
              );
            } else {
              rowWidget = (labelBuilder ?? _labelBuilder).call(context, item);
            }
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 6),
              child: rowWidget,
            ).withBottomBorder(color: Theme.of(context).dividerColor);
          },
        );
      },
    );
  }

  Widget _labelBuilder(BuildContext context, SimpleMapTreeNode node) {
    if (node.children.isNotEmpty) {
      return SelectableText.rich(TextSpan(
        children: [
          TextSpan(text: '${node.title} '.capitalizeFirst),
          WidgetSpan(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                  // color: Colors.grey,
                  // borderRadius: BorderRadius.circular(2),
                  ),
              child: Text(
                '{${node.children.length}}',
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      height: 1.2,
                      // fontFamily: MONOSPACED_FONT,
                      // fontFamilyFallback: MONOSPACED_FONT_BACK,
                    ),
              ),
            ),
          ),
        ],
      ));
    }
    return SelectableText(
      '${node.title}'.capitalizeFirst!.replaceAll('_', ' '),
      style: Theme.of(context).textTheme.labelMedium!.copyWith(
          // fontFamily: MONOSPACED_FONT,
          // fontFamilyFallback: MONOSPACED_FONT_BACK,
          ),
    );
  }

  Widget _valueBuilder(BuildContext context, SimpleMapTreeNode node) {
    return Expanded(
      child: SelectableText(
        '${node.value}',
        textAlign: TextAlign.end,
        style: Theme.of(context).textTheme.bodySmall!.copyWith(
            // fontFamily: MONOSPACED_FONT,
            // fontFamilyFallback: MONOSPACED_FONT_BACK,
            ),
      ),
    );
  }
}

class SubFeatureListWidget extends StatefulWidget {
  final List<Feature> features;
  final List<String>? skipKeys;
  final String chrName;

  const SubFeatureListWidget({Key? key, required this.features, this.skipKeys, required this.chrName}) : super(key: key);

  @override
  State<SubFeatureListWidget> createState() => _SubFeatureListWidgetState();
}

class _SubFeatureListWidgetState extends State<SubFeatureListWidget> {
  Map<int, bool> expandInfo = {};

  Widget _itemBuilder(BuildContext context, int index) {
    Feature f = widget.features[index];
    Map _map = {
      'Position': '${widget.chrName}:${f.range.print('..')}(${f.strandStr})',
      ...f.json,
      'Length': f.range.lengthStr + ' bp',
    };
    var keys = widget.skipKeys == null ? _map.keys : _map.keys.where((value) => !widget.skipKeys!.contains(value));

    return ExpansionTileCard(
      initialElevation: 2.0,
      elevation: 4.0,
      initialPadding: EdgeInsets.only(bottom: 4, top: 4),
      finalPadding: EdgeInsets.only(top: 4, bottom: 6),
      // horizontalTitleGap: 0,
      initiallyExpanded: true,
      contentPadding: EdgeInsets.symmetric(horizontal: 6),
      title: Text('${f.originName ?? f.type}', style: Theme.of(context).textTheme.titleMedium),
      children: keys.mapIndexed((index, k) => _buildItem(context, index, k, _map[k])).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: _itemBuilder,
      itemCount: (widget.features).where((f) => f.type != 'intron').length,
    );
  }
}
