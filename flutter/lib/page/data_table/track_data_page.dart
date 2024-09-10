import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/side/data_viewer_side.dart';
import 'package:flutter_smart_genome/widget/track/base/track_data.dart';

class TrackDataPage extends StatefulWidget {
  final Track track;
  const TrackDataPage({Key? key, required this.track}) : super(key: key);

  @override
  State<TrackDataPage> createState() => _TrackDataPageState();
}

class _TrackDataPageState extends State<TrackDataPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TrackData-${widget.track.trackName}'),
      ),
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: DataViewerSide(),
      ),
    );
  }
}