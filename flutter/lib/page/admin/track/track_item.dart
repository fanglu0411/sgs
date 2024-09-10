import 'package:flutter_smart_genome/widget/basic/custom_spin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_genome/widget/track/base/track_data.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

abstract class BaseTrackItemWidget extends StatefulWidget {
  final Track track;

  final ValueChanged<Track>? onDelete;

  const BaseTrackItemWidget({
    super.key,
    required this.track,
    this.onDelete,
  });
}

mixin TrackItemMixin<T extends BaseTrackItemWidget> on State<T> {
  bool _hover = false;

  _showError(Track track) async {
    await showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(track.name),
        content: SelectableText(track.status!),
      ),
    );
  }

  Widget statusWidget(Track _track, Color? color) {
    if (_track.statusDone) {
      return Icon(Icons.check_circle, color: color ?? Colors.green, size: 16);
    } else if (_track.statusError) {
      return IconButton(
        onPressed: () => _showError(_track),
        icon: Icon(Icons.error, color: Colors.redAccent),
        padding: EdgeInsets.zero,
        color: Colors.red,
        iconSize: 18,
        constraints: BoxConstraints.tightFor(width: 30, height: 30),
      );
    } else {
      return SpinKitThreeBounce(color: color, size: 20, duration: Duration(milliseconds: 1200));
      return CustomSpin(color: Theme.of(context).colorScheme.primary);
    }
  }

  void _showModList() {
    Track track = widget.track;
    showDialog(
        context: context,
        builder: (c) {
          return AlertDialog(
            title: Text('Mods of - ${track.scName}'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: (track.matrixList ?? []).map((e) => ListTile(title: Text(e.name))).toList(),
            ),
          );
        });
  }
}

class TrackTileWidget extends BaseTrackItemWidget {
  const TrackTileWidget({
    super.key,
    required super.track,
    super.onDelete,
  });

  @override
  State<TrackTileWidget> createState() => _TrackTileWidgetState();
}

class _TrackTileWidgetState extends State<TrackTileWidget> with TrackItemMixin<TrackTileWidget> {
  void _onEnter(PointerEnterEvent e) {
    _hover = true;
    setState(() {});
  }

  void _onExit(PointerExitEvent e) {
    _hover = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var color = trackTypeColorMapper[widget.track.trackType];
    return MouseRegion(
      // cursor: SystemMouseCursors.click,
      onEnter: _onEnter,
      onExit: _onExit,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: _hover ? Theme.of(context).hoverColor : null,
          border: _hover ? Border(bottom: BorderSide(color: Theme.of(context).dividerColor)) : null,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Tooltip(child: Icon(Icons.circle, color: color, size: 10), message: widget.track.trackType.name),
            SizedBox(width: 10),
            Expanded(child: Text('${widget.track.name}', style: TextStyle(overflow: TextOverflow.ellipsis))),
            statusWidget(widget.track, color!),
            SizedBox(width: 10),
            if (_hover)
              IconButton(
                onPressed: () => widget.onDelete?.call(widget.track),
                icon: Icon(Icons.delete),
                padding: EdgeInsets.zero,
                color: Colors.red,
                iconSize: 20,
                constraints: BoxConstraints.tightFor(width: 30, height: 30),
              )
            else
              SizedBox(width: 30),
          ],
        ),
      ),
    );
  }
}

class TrackListItemWidget extends BaseTrackItemWidget {
  const TrackListItemWidget({
    super.key,
    required super.track,
    super.onDelete,
  });

  @override
  State<TrackListItemWidget> createState() => _TrackListItemWidgetState();
}

class _TrackListItemWidgetState extends State<TrackListItemWidget> with TrackItemMixin<TrackListItemWidget> {
  void _onEnter(PointerEnterEvent e) {
    _hover = true;
    setState(() {});
  }

  void _onExit(PointerExitEvent e) {
    _hover = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var color = trackTypeColorMapper[widget.track.trackType];
    return ListTile(
      onTap: () {},
      title: Text('${widget.track.name}'),
      subtitle: Text('${widget.track.id ?? widget.track.scId}'),
      leading: Tooltip(
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Icon(Icons.circle, color: color, size: 20),
          ),
          message: widget.track.trackType.name),
      trailing: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.track.isSCTrack)
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: Size(40, 30),
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              ),
              child: Text('Mod: ${widget.track.matrixList?.length ?? 0}'),
              onPressed: _showModList,
            ),
          SizedBox(width: 10),
          statusWidget(widget.track, color),
          SizedBox(width: 10),
          IconButton(
            onPressed: () => widget.onDelete?.call(widget.track),
            icon: Icon(Icons.delete),
            padding: EdgeInsets.zero,
            color: Colors.red,
            iconSize: 20,
            constraints: BoxConstraints.tightFor(width: 30, height: 30),
          )
        ],
      ),
    );
  }
}

class TrackCardItemWidget extends BaseTrackItemWidget {
  const TrackCardItemWidget({
    super.key,
    required super.track,
    super.onDelete,
  });

  @override
  State<TrackCardItemWidget> createState() => _TrackCardItemWidgetState();
}

class _TrackCardItemWidgetState extends State<TrackCardItemWidget> with TrackItemMixin<TrackCardItemWidget> {
  void _onEnter(PointerEnterEvent e) {
    _hover = true;
    setState(() {});
  }

  void _onExit(PointerExitEvent e) {
    _hover = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var color = trackTypeColorMapper[widget.track.trackType];
    return MouseRegion(
      onEnter: _onEnter,
      onExit: _onExit,
      child: Material(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
          side: BorderSide(color: Theme.of(context).dividerColor, width: 1),
        ),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: _hover
              ? BoxDecoration(
                  color: Theme.of(context).hoverColor,
                  borderRadius: BorderRadius.circular(5),
                )
              : null,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Tooltip(child: Icon(Icons.circle, color: color, size: 10), message: widget.track.trackType.name),
                  // SizedBox(width: 10),
                  Expanded(
                    child: Text('${widget.track.name}', style: Theme.of(context).textTheme.titleMedium!.copyWith(overflow: TextOverflow.ellipsis)),
                  ),
                  statusWidget(widget.track, color),
                  SizedBox(width: 7),
                ],
              ),
              Text('ID: ${widget.track.id ?? widget.track.scId}', style: Theme.of(context).textTheme.bodySmall),
              Row(
                children: [
                  TrackTypeWidget(widget.track.trackType),
                  SizedBox(width: 10),
                  if (widget.track.isSCTrack)
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        minimumSize: Size(30, 24),
                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      ),
                      child: Text('Mod: ${widget.track.matrixList?.length ?? 0}'),
                      onPressed: _showModList,
                    ),
                  Spacer(),
                  if (widget.onDelete != null)
                    IconButton(
                      onPressed: () => widget.onDelete?.call(widget.track),
                      icon: Icon(Icons.delete),
                      padding: EdgeInsets.zero,
                      color: Colors.red,
                      iconSize: 20,
                      constraints: BoxConstraints.tightFor(width: 30, height: 30),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget TrackTypeWidget(TrackType type) {
  var color = trackTypeColorMapper[type];
  return Container(
    padding: EdgeInsets.only(left: 10, right: 10, bottom: 2),
    alignment: Alignment.center,
    // constraints: BoxConstraints(minWidth: 26, maxHeight: 30),
    decoration: BoxDecoration(
      color: color ?? Colors.red.shade800,
      borderRadius: BorderRadius.circular(15),
      // border:isUnknown ? null: Border.all(color: color),
    ),
    child: Text(
      type == TrackType.sc_transcript || type == TrackType.sc_atac ? 'sc' : '${type}'.split('.').last,
      style: TextStyle(color: Colors.white, fontSize: 12),
    ),
  );
}
