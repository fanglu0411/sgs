import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/bean/site_item.dart';
import 'package:flutter_smart_genome/bloc/track_config/bloc.dart';
import 'package:d4_scale/d4_scale.dart';
import 'package:flutter_smart_genome/d3/d3_mixin.dart';
import 'package:flutter_smart_genome/page/track/zoom_config.dart';
import 'package:flutter_smart_genome/service/sgs_app_service.dart';
import 'package:flutter_smart_genome/widget/relation/base/relation_params.dart';
import 'package:flutter_smart_genome/widget/relation/hic_relation/hic_relation_widget.dart';
import 'package:flutter_smart_genome/widget/track/track_group_logic.dart';
import 'package:get/get.dart';

import 'base/track_data.dart';

class InteractiveGroupLogic extends GetxController {
  static InteractiveGroupLogic? safe() {
    if (Get.isRegistered<InteractiveGroupLogic>()) {
      return Get.find<InteractiveGroupLogic>();
    }
    return null;
  }
}

class InteractiveGroupWidget extends StatefulWidget {
  final SiteItem site;
  final List<Track> tracks;
  final RelationParams relationParams;
  final bool touchScaling;

  const InteractiveGroupWidget({
    Key? key,
    this.tracks = const [],
    required this.relationParams,
    required this.site,
    this.touchScaling = false,
  }) : super(key: key);

  @override
  InteractiveGroupWidgetState createState() => InteractiveGroupWidgetState();
}

class InteractiveGroupWidgetState extends State<InteractiveGroupWidget> {
  final InteractiveGroupLogic logic = Get.put(InteractiveGroupLogic());

  late RelationParams _relationParams;

  String _listMode = 'expand';

  Map<String, GlobalKey<HicRelationWidgetState>> _interactiveKeyMap = {};

  GlobalKey _getInteractiveKey(Track track) {
    String key = '${track.key}-${Theme.of(context).brightness}';
    if (!_interactiveKeyMap.containsKey(key)) {
      _interactiveKeyMap[key] = GlobalKey(debugLabel: key);
    }
    return _interactiveKeyMap[key]!;
  }

  Size? _size;

  @override
  void initState() {
    super.initState();
    _relationParams = widget.relationParams;
  }

  @override
  void didUpdateWidget(covariant InteractiveGroupWidget oldWidget) {
    _relationParams = widget.relationParams;
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: _builder);
    //
    // return GetBuilder<InteractiveGroupLogic>(builder: (c) => );
  }

  Widget _builder(BuildContext context, BoxConstraints constraints) {
    _size = constraints.biggest;
    _updateScale();

    int trackLength = widget.tracks.length;
    List<Widget> children = widget.tracks.map(_relationWidget).toList();
    Widget content;
    bool _scroll = _listMode == 'scroll';
    // bool _single = _listMode == 'single';

    if (trackLength > 2 && _scroll) {
      content = Container(
        constraints: BoxConstraints.expand(height: 240),
        child: ListView(children: children),
      );
    } else if (trackLength == 1) {
      content = children.first;
    } else {
      content = Column(
        mainAxisSize: MainAxisSize.min,
        children: children,
      );
    }
    return Stack(
      children: [
        content,
        if (trackLength > 1)
          Align(
            alignment: Alignment.topRight,
            child: _groupAction(),
          )
      ],
    );
  }

  void _updateScale() {
    if (_size == null || _relationParams.range2 == null) return;
    _relationParams
      ..scale1 = ScaleLinear.number(
        domain: [_relationParams.range1.start, _relationParams.range1.end],
        range: [.0, _size!.width],
      )
      ..scale2 = ScaleLinear.number(
        domain: [_relationParams.range2!.start, _relationParams.range2!.end],
        range: [0, _size!.width],
      )
      ..zoomConfig2 = ZoomConfig(_relationParams.chr2.range, _size!.width)
      ..sizeOfPixel2 = _relationParams.range2!.size / _size!.width
      ..pixelPerSeq2 = _size!.width / _relationParams.range2!.size;
    ;
  }

  Widget _groupAction() {
    return ClipRRect(
      borderRadius: BorderRadius.only(bottomLeft: Radius.circular(15)),
      clipBehavior: Clip.antiAlias,
      child: Container(
        height: 22,
        padding: EdgeInsets.only(left: 10),
        color: Theme.of(context).colorScheme.primary.withAlpha(20),
        child: DropdownButton<String>(
          value: _listMode,
          focusColor: Theme.of(context).colorScheme.primary.withAlpha(200),
          isDense: true,
          onChanged: (v) {
            setState(() {
              _listMode = v!;
            });
          },
          style: Theme.of(context).textTheme.labelLarge!.copyWith(fontWeight: FontWeight.w300),
          items: [
            // DropdownMenuItem(
            //   child: Text('Single Mode'),
            //   value: 'single',
            // ),
            DropdownMenuItem(
              child: Text('Expand Mode'),
              value: 'expand',
            ),
            DropdownMenuItem(
              child: Text('Scroll Mode'),
              value: 'scroll',
            ),
          ],
        ),
      ),
    );
  }

  Widget _relationWidget(Track interactiveTrack) {
    return HicRelationWidget(
      track: interactiveTrack,
      key: _getInteractiveKey(interactiveTrack),
      site: widget.site,
      // maxHeight: 200,
      relationParams: _relationParams,
      fixTitle: false,
      background: Theme.of(context).scaffoldBackgroundColor,
      touchScaling: widget.touchScaling,
      trackEventCallback: _eventCallback,
      gestureBuilder: TrackGroupLogic.safe()?.gestureDetector,
      gestureBuilder2: TrackGroupLogic.safe(tag: TrackGroupLogic.TAG_2)?.gestureDetector,
    );
  }

  void _eventCallback<String, Object>(action, data) {
    if (action == 'hideTrack') {
      Track _track = data;
      SgsAppService.get()!.sendEvent(ToggleTrackSelectionEvent(_track, false));
    }
  }

  void updateParams(RelationParams params, [bool touching = true]) {
    // print('touching: $touching');
    // print(params);
    if (touching) return;
    if (!_relationParams.rangeChanged(params)) return;
    _relationParams = params;
    _updateScale();
    setState(() {});
    // _interactiveKeyMap.values.forEach((relationKey) {
    //   relationKey.currentState?.updateParams(_relationParams);
    // });
  }
}
