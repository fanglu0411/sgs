import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/base/ui_config.dart';
import 'package:flutter_smart_genome/bean/gene.dart';

enum TrackAction {
  info,
  favor,
  previous,
  current,
  next,
  share,
  setting,
  play_list,
}

class TrackPlayController extends StatefulWidget {
  final bool isMobile;

  final ValueChanged<TrackAction>? onTap;
  final PositionInfo? gene;

  const TrackPlayController({
    Key? key,
    this.gene,
    this.isMobile = false,
    this.onTap,
  }) : super(key: key);

  @override
  _TrackPlayControllerState createState() => _TrackPlayControllerState();
}

class _TrackPlayControllerState extends State<TrackPlayController> {
  double _space = 20;

  bool _favor = false;

  @override
  void initState() {
    super.initState();
    if (widget.isMobile) _space = 6;
  }

  @override
  Widget build(BuildContext context) {
    var infoWidget = _buildTrackInfo(widget.isMobile);
    var centerWidget = _buildCenterController();
    var rightWidget = _buildRight();
    //bool dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      constraints: BoxConstraints.tightFor(height: 64),
      child: Material(
        color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
        child: Row(
          children: <Widget>[
            widget.isMobile ? infoWidget : Expanded(child: infoWidget),
            Expanded(child: centerWidget),
            widget.isMobile ? rightWidget : Expanded(child: rightWidget),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackInfo(bool isMobile) {
    if (isMobile) {
      return IconButton(
        padding: EdgeInsets.all(4),
        tooltip: 'Session History',
//            color: Colors.grey,
        icon: Icon(Icons.playlist_play, size: 30),
        onPressed: () => _onActionTap(TrackAction.play_list),
      );
//      return IconButton(
//        padding: EdgeInsets.all(4),
//        color: Colors.grey,
//        icon: Icon(Icons.info, size: 24),
//        tooltip: 'Gene Info',
//        onPressed: () {
//          _onActionTap(TrackAction.info);
//        },
//      );
    }
    PositionInfo? geneInfo = widget.gene;
    return ListTile(
      leading: widget.isMobile ? null : Icon(Icons.location_on, size: 40),
      title: Text('${geneInfo?.range.print()}'),
      subtitle: Text('${geneInfo?.print()}'),
      onTap: () => _onActionTap(TrackAction.info),
    );
  }

  _onActionTap(TrackAction action) {
    if (widget.onTap != null) widget.onTap!(action);
  }

  Widget _buildCenterController() {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        IconButton(
          padding: EdgeInsets.all(4),
          tooltip: 'Previous Session',
          icon: Icon(Icons.skip_previous, size: 30),
          onPressed: () => _onActionTap(TrackAction.previous),
        ),
//        SizedBox(width: _space),
//        IconButton(
//          padding: EdgeInsets.all(4),
//          tooltip: 'Current Session',
//          icon: Icon(Icons.my_location, size: 24),
//          onPressed: () => _onActionTap(TrackAction.current),
//        ),
        SizedBox(width: _space),
        IconButton(
          padding: EdgeInsets.all(4),
//          color: _favor ? null : Colors.grey,
          icon: Icon(_favor ? Icons.playlist_add : Icons.playlist_add, size: 24),
          tooltip: 'Save Session',
          onPressed: () {
            setState(() {
              _favor = !_favor;
            });
            _onActionTap(TrackAction.favor);
          },
        ),
        SizedBox(width: _space),
        IconButton(
          padding: EdgeInsets.all(4),
          tooltip: 'Next Session',
          icon: Icon(Icons.skip_next, size: 30),
          onPressed: () => _onActionTap(TrackAction.next),
        ),
      ],
    );
  }

  Widget _buildRight() {
    if (isMobile(context)) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          IconButton(
            padding: EdgeInsets.all(4),
            tooltip: 'More setting',
//            color: Colors.grey,
            icon: Icon(Icons.more_horiz, size: 24),
            onPressed: () => _showMoreMenu(),
          ),
        ],
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        IconButton(
          padding: EdgeInsets.all(4),
          tooltip: 'UI Config',
//          color: Colors.grey,
          icon: Icon(Icons.settings, size: 24),
          onPressed: () => _onActionTap(TrackAction.setting),
        ),
        IconButton(
          padding: EdgeInsets.all(4),
          tooltip: 'Session History',
//          color: Colors.grey,
          icon: Icon(Icons.playlist_play, size: 30),
          onPressed: () => _onActionTap(TrackAction.play_list),
        ),
        IconButton(
          padding: EdgeInsets.all(4),
//          color: Colors.grey,
          tooltip: 'Share',
          icon: Icon(Icons.share, size: 24),
          onPressed: () => _onActionTap(TrackAction.share),
        ),
      ],
    );
  }

  _showMoreMenu() async {
    Size _size = MediaQuery.of(context).size;
    TrackAction? result = await showMenu<TrackAction>(
      context: context,
//      color: Colors.white,
      position: RelativeRect.fromLTRB(_size.width - 100.0, _size.height - 190, 10.0, _size.height - context.size!.height),
      items: <PopupMenuItem<TrackAction>>[
        new PopupMenuItem<TrackAction>(
          value: TrackAction.setting,
          child: customPopMenuItem(
            icon: Icon(Icons.format_paint),
            label: Text('UI Config'),
          ),
        ),
        new PopupMenuItem<TrackAction>(
          value: TrackAction.share,
          child: customPopMenuItem(
            label: new Text('Share'),
            icon: Icon(Icons.share),
          ),
        ),
      ],
    );
    if (result != null) _onActionTap(result);
  }

  Widget customPopMenuItem({required Widget label, Icon? icon}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (icon != null) icon,
        if (icon != null) SizedBox(width: 10),
        label,
      ],
    );
  }
}
