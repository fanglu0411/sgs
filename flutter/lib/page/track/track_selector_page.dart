import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/mixin/track_list_mixin.dart';
import 'package:flutter_smart_genome/mixin/view_size_mixin.dart';
import 'package:flutter_smart_genome/service/sgs_app_service.dart';
import 'package:flutter_smart_genome/widget/track/base/track_data.dart';
import 'package:get/get.dart';

class TrackSelectorPage extends StatefulWidget {
  final ValueChanged<List<Track>>? onSelected;
  final bool asPage;

  const TrackSelectorPage({
    Key? key,
    this.onSelected,
    this.asPage = true,
  }) : super(key: key);

  @override
  _TrackSelectorPageState createState() => _TrackSelectorPageState();
}

class _TrackSelectorPageState extends State<TrackSelectorPage> with TrackListMixin, ViewSizeMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget body = GetBuilder(
      init: TrackListLogic(),
      builder: buildWithContext,
    );
    return Scaffold(
      appBar: AppBar(
        title: Text('Track List'),
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => onCheckedChange([]),
        ),
        actions: <Widget>[
          IconButton(
            iconSize: 26,
            icon: Icon(Icons.check),
            // tooltip: 'Apply Changes',
            onPressed: () {
              var _selections = SgsAppService.get()!.selectedTracks;
              onCheckedChange(_selections);
            },
          )
        ],
      ),
      body: body,
    );
  }

  @override
  void onCheckChange(Track track, bool? checked) {
    super.onCheckChange(track, checked);
  }

  @override
  void onCheckedChange(List<Track> tracks) {
    if (widget.onSelected != null) {
      widget.onSelected!.call(tracks);
    } else {
      Navigator.of(context).maybePop(tracks);
    }
  }
}