import 'package:flutter/material.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:flutter_smart_genome/page/track/track_control_bar/track_control_bar.dart';
import 'package:flutter_smart_genome/widget/track/common.dart';

class FloatTrackControlBar extends StatefulWidget {
  final Axis orientation;
  final bool simple;
  final ValueChanged<int>? onPanModeChange;
  final ValueChanged<TrackControlAction>? onZoomChange;
  final ValueChanged<TrackControlAction>? onPan;
  final ValueChanged<Range>? onZoomToRange;

  const FloatTrackControlBar({
    Key? key,
    this.onPanModeChange,
    this.onZoomChange,
    this.onPan,
    this.onZoomToRange,
    this.orientation = Axis.horizontal,
    this.simple = false,
  }) : super(key: key);

  @override
  _FloatTrackControlBarState createState() => _FloatTrackControlBarState();
}

class _FloatTrackControlBarState extends State<FloatTrackControlBar> {
  @override
  Widget build(BuildContext context) {
    Color _color = Theme.of(context).colorScheme.primary;
    Color _buttonColor = Colors.white;
    double elevation = 3;
    ShapeBorder shape = CircleBorder(side: BorderSide(width: 2, color: Colors.white));
    EdgeInsets _itemPadding = EdgeInsets.symmetric(horizontal: 12);
    bool _horizontal = widget.orientation == Axis.horizontal;

    var _children = [
      Tooltip(
        message: 'Min Scale',
        child: MaterialButton(
          color: _color,
          shape: shape,
          minWidth: 30,
          elevation: elevation,
          padding: _itemPadding,
          child: Icon(MaterialCommunityIcons.format_horizontal_align_center, color: _buttonColor),
          //label: Text('Min Scale'),
          //tooltip: 'Previous session',
          onPressed: () => widget.onPan?.call(TrackControlAction.pan_min_scale),
        ),
      ),
      Tooltip(
        message: 'move to start',
        child: MaterialButton(
          elevation: elevation,
          minWidth: 20,
          onPressed: () => widget.onPan?.call(TrackControlAction.pan_start),
//            tooltip: 'pan left',
          padding: _itemPadding,
          child: Icon(
            _horizontal ? MaterialCommunityIcons.chevron_double_left : MaterialCommunityIcons.chevron_double_up,
            color: _buttonColor,
          ),
          color: _color,
          shape: shape,
        ),
      ),
      if (!widget.simple)
        Tooltip(
          message: 'pan left',
          child: MaterialButton(
            elevation: elevation,
            minWidth: 20,
            onPressed: () => widget.onPan?.call(TrackControlAction.pan_left),
//            tooltip: 'pan left',
            padding: _itemPadding,
            child: Icon(
              _horizontal ? Icons.chevron_left : Icons.keyboard_arrow_up,
              color: _buttonColor,
            ),
            color: _color,
            shape: shape,
          ),
        ),
      if (!widget.simple)
        Tooltip(
          message: 'zoom out x2',
          child: MaterialButton(
            elevation: elevation,
            minWidth: 20,
            padding: _itemPadding,
            child: Icon(
              MaterialIcons.exposure_neg_2,
              color: _buttonColor,
            ),
            onPressed: () => widget.onZoomChange?.call(TrackControlAction.zoom_out_2),
            color: _color,
            shape: shape,
          ),
        ),
      Tooltip(
        message: 'zoom out x1',
        child: MaterialButton(
          elevation: elevation,
          minWidth: 20,
          padding: _itemPadding,
          child: Icon(
            MaterialIcons.exposure_neg_1,
            color: _buttonColor,
          ),
          onPressed: () => widget.onZoomChange?.call(TrackControlAction.zoom_out_1),
          color: _color,
          shape: shape,
        ),
      ),
      Tooltip(
        message: 'zoom in x1',
        child: MaterialButton(
          elevation: elevation,
          minWidth: 20,
          padding: _itemPadding,
          child: Icon(
            MaterialIcons.exposure_plus_1,
            color: _buttonColor,
          ),
          onPressed: () => widget.onZoomChange?.call(TrackControlAction.zoom_in_1),
          color: _color,
          shape: shape,
        ),
      ),
      if (!widget.simple)
        Tooltip(
          message: 'zoom in x2',
          child: MaterialButton(
            elevation: elevation,
            minWidth: 20,
            padding: _itemPadding,
            child: Icon(
              MaterialIcons.exposure_plus_2,
              color: _buttonColor,
            ),
            onPressed: () => widget.onZoomChange?.call(TrackControlAction.zoom_in_2),
            color: _color,
            shape: shape,
          ),
        ),
      if (!widget.simple)
        Tooltip(
          message: 'pan to right',
          child: MaterialButton(
            elevation: elevation,
            minWidth: 20,
            padding: _itemPadding,
            child: Icon(
              _horizontal ? Icons.chevron_right : Icons.keyboard_arrow_down,
              color: _buttonColor,
            ),
            onPressed: () => widget.onPan?.call(TrackControlAction.pan_right),
            color: _color,
            shape: shape,
          ),
        ),
      Tooltip(
        message: 'move to end',
        child: MaterialButton(
          elevation: elevation,
          minWidth: 20,
          padding: _itemPadding,
          child: Icon(
            _horizontal ? MaterialCommunityIcons.chevron_double_right : MaterialCommunityIcons.chevron_double_down,
            color: _buttonColor,
          ),
          onPressed: () => widget.onPan?.call(TrackControlAction.pan_end),
          color: _color,
          shape: shape,
        ),
      ),
      Tooltip(
        message: 'Max Scale',
        child: MaterialButton(
          color: _color,
          shape: shape,
          minWidth: 30,
          elevation: elevation,
          padding: _itemPadding,
          child: Icon(MaterialCommunityIcons.arrow_expand_horizontal, color: _buttonColor),
//        tooltip: 'Save session',
//        label: Text('Max Scale'),
          onPressed: () => widget.onPan?.call(TrackControlAction.pan_max_scale),
        ),
      ),
    ];

    return Container(
      padding: EdgeInsets.symmetric(vertical: _horizontal ? 0 : 10, horizontal: _horizontal ? 10 : 0),
      decoration: BoxDecoration(
//        border: Border.all(color: Colors.white, width: 1),
        borderRadius: BorderRadius.circular(8),
//        color: Theme.of(context).backgroundColor.withAlpha(180),
      ),
      child: widget.orientation == Axis.vertical
          ? Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _children,
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _children,
            ),
    );
  }
}
