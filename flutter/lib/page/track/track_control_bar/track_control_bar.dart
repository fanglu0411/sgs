import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:flutter_smart_genome/base/ui_config.dart';
import 'package:flutter_smart_genome/bean/site_item.dart';
import 'package:flutter_smart_genome/bloc/sgs_context/sgs_browse_logic.dart';
import 'package:flutter_smart_genome/components/setting_config_widget.dart';
import 'package:flutter_smart_genome/page/cell/cell_tool_bar/toggle_button.dart';
import 'package:flutter_smart_genome/page/track/zoom_config.dart';
import 'package:flutter_smart_genome/service/sgs_config_service.dart';

import 'package:flutter_smart_genome/util/undo_redo_manager.dart';
import 'package:flutter_smart_genome/widget/basic/button_group.dart';
import 'package:flutter_smart_genome/widget/basic/chr_position_input_field.dart';
import 'package:flutter_smart_genome/widget/basic/custom_bot_widget.dart';
import 'package:flutter_smart_genome/widget/basic/range_input_field_widget.dart';
import 'package:flutter_smart_genome/widget/toggle_button_group.dart';
import 'package:flutter_smart_genome/widget/track/cartesian/axis_direction.dart';
import 'package:flutter_smart_genome/widget/track/chromosome/chromosome_data.dart';
import 'package:flutter_smart_genome/widget/track/common.dart';
import 'package:get/get.dart';

import 'track_control_bar_logic.dart';

enum TrackControlAction {
  pan_left, // -1
  pan_right, // 1
  pan_start, // -10
  pan_end, //10
  pan_min_scale, // 0
  pan_max_scale, // 10000

  zoom_out_1, //-1,
  zoom_out_2, // -2
  zoom_in_1, // 1.0
  zoom_in_2, //2.0

  tap_site_selector,
  tap_file_upload,
  tap_chromosome,
  tap_locate,
  tap_compare,
  tap_session_list,
  tap_share_session,
  tap_track_list,
  tap_rotation,
  tap_more,
  tap_split_mode,
  tap_undo,
  tap_redo,
}

double actionToZoom(TrackControlAction action) {
  switch (action) {
    case TrackControlAction.zoom_out_1:
      return -1;
    case TrackControlAction.zoom_out_2:
      return -2;
    case TrackControlAction.zoom_in_1:
      return 1;
    case TrackControlAction.zoom_in_2:
      return 2;
    default:
      return 0;
  }
}

class TrackControlBar extends StatefulWidget {
  final ValueChanged<int>? onPanModeChange;
  final ValueChanged<TrackControlAction>? onZoomChange;
  final ValueChanged<TrackControlAction>? onPan;
  final ValueChanged<Range>? onZoomToRange;
  final Function? onTap;
  final Range? range;
  final double? trackViewWidth;
  final ChromosomeData? chromosome;
  final ZoomConfig? zoomConfig;
  final SiteItem? site;
  final bool enabled;
  final bool inIdeMode;

//  final Brightness brightness;
  final bool primary;
  final String tag;
  final ValueChanged<String>? onSearch;

  const TrackControlBar({
    Key? key,
    this.primary = true,
    this.site,
    this.onPanModeChange,
    this.onZoomChange,
    this.onSearch,
    this.onTap,
    this.onPan,
    this.range,
    this.onZoomToRange,
    this.chromosome,
    this.trackViewWidth,
    this.zoomConfig,
    this.enabled = true,
    this.inIdeMode = false,
    this.tag = '1',
//    this.brightness = Brightness.dark,
  }) : super(key: key);

  @override
  TrackControlBarState createState() => TrackControlBarState();
}

class TrackControlBarState extends State<TrackControlBar> {
  late TrackControlBarLogic logic;
  BoxConstraints _buttonConstraints = BoxConstraints.tightFor(width: 40, height: 40);

//  GlobalKey<RangeInputFieldWidgetState> _rangeInputKey = GlobalKey<RangeInputFieldWidgetState>();

  @override
  void initState() {
    logic = TrackControlBarLogic.safe(widget.tag) ?? Get.put(TrackControlBarLogic(), tag: widget.tag);
    logic.range = widget.range;
    super.initState();
  }

  @override
  void didUpdateWidget(TrackControlBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    logic.range = widget.range;
  }

  Widget _builder(BuildContext context, BoxConstraints constraints, TrackControlBarLogic logic) {
    bool _dark = Theme.of(context).brightness == Brightness.dark;
    double _width = constraints.maxWidth;

    bool _mobile = isMobile(context);

    double minWidth = _mobile ? _width : _width.clamp(1100.0, 2000.0);

    List<Widget> _children = [
      Align(alignment: Alignment.centerLeft, child: _left(minWidth)),
      if (!_mobile) Align(alignment: Alignment.center, child: _zoom(minWidth)),
      if (widget.primary && !_mobile) Align(alignment: Alignment.centerRight, child: _right(minWidth)),
      // if (_bigScreen) _scaleInfo(),
    ];

    return ConstrainedBox(
      constraints: BoxConstraints.expand(height: 40),
      // child: Stack(children: _children),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Container(
          constraints: BoxConstraints(minWidth: minWidth, minHeight: 40, maxHeight: 40, maxWidth: minWidth),
          child: Stack(children: _children),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TrackControlBarLogic>(
      tag: widget.tag,
      builder: (logic) {
        return LayoutBuilder(builder: (c, constraints) => _builder(c, constraints, logic));
      },
    );
  }

//  updateRange(Range range) {
//    _range = range;
//    _rangeInputKey.currentState?.updateRange(range);
//  }

  Widget _left(double width) {
    // bool _isBigScreen = isBigScreen(context, constraints.biggest);
    bool _isMobile = false; // isMobile(context, constraints.biggest);
    bool _dark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        // SizedBox(width: 10)
        SizedBox(width: 2),

        // if (!_isMobile && widget.primary)
        //   Builder(
        //     builder: (c) {
        //       return IconButton(
        //         constraints: BoxConstraints.tightFor(width: 32, height: 32),
        //         splashRadius: 18,
        //         iconSize: 20,
        //         icon: Icon(MaterialCommunityIcons.file_upload_outline),
        //         tooltip: ' Load local file ',
        //         onPressed: () => widget.onTap?.call(c, TrackControlAction.tap_file_upload),
        //       );
        //     },
        //   ),

        if (!_isMobile && widget.primary)
          Builder(
            builder: (c) {
              return ToggleButton(
                label: RotatedBox(quarterTurns: 1, child: Icon(MaterialCommunityIcons.select_compare)),
                tooltip: ' Toggle compare mode ',
                padding: EdgeInsets.symmetric(horizontal: 4),
                border: false,
                onChanged: (v) {
                  widget.onTap?.call(c, TrackControlAction.tap_split_mode);
                },
              );
              return RotatedBox(
                quarterTurns: 1,
                child: IconButton(
                  constraints: BoxConstraints.tightFor(width: 32, height: 32),
                  splashRadius: 18,
                  iconSize: 20,
                  icon: Icon(MaterialCommunityIcons.select_compare),
                  tooltip: ' Toggle compare mode ',
                  onPressed: () => widget.onTap?.call(c, TrackControlAction.tap_split_mode),
                ),
              );
            },
          ),

        // if (mobilePlatform() || !widget.inIdeMode || !(TrackContainerLogic.safe()?.serverOpened() ?? false)) _buildSpeciesTitle(context),

        if (!_isMobile) SizedBox(width: 6),

        if (!_isMobile)
          Container(
            constraints: BoxConstraints(minWidth: 200, maxWidth: 280),
            alignment: Alignment.centerLeft,
            child: ChrPositionInputField(
              preferDirection: widget.primary ? null : PreferDirection.topLeft,
              chr: widget.chromosome,
              range: logic.range,
              onSubmit: (range) {
                widget.onZoomToRange?.call(range);
              },
              onChrChange: (chr, range) {
                widget.onTap?.call(context, TrackControlAction.tap_chromosome, chr, range);
              },
              onChangePosition: (ChromosomeData chr, Range range) {
                widget.onZoomToRange?.call(range);
                // widget.onTap?.call(context, TrackControlAction.tap_chromosome, chr, range);
              },
              onSearch: widget.onSearch,
            ),
          ),

        // MaterialButton(
        //   // colorBrightness: Brightness.dark,
        //   padding: EdgeInsets.symmetric(horizontal: 6),
        //   minWidth: 10,
        //   elevation: 0,
        //   onPressed: () => widget.onTap?.call(context, TrackControlAction.tap_chromosome),
        //   //icon: Icon(MaterialCommunityIcons.dna),
        //   textColor: _dark ? Colors.white : Theme.of(context).colorScheme.primary,
        //   child: Row(
        //     mainAxisSize: MainAxisSize.min,
        //     crossAxisAlignment: CrossAxisAlignment.center,
        //     children: [
        //       Text('Chr: ${widget.chromosome?.chrName}'),
        //       Icon(Icons.keyboard_arrow_down, size: 16),
        //     ],
        //   ),
        // ).tooltip(' Change Chromosome '),
        // if (_isBigScreen)
        //   RangeInputFieldWidget(
        //     // brightness: Brightness.dark,
        //     range: _range,
        //     //prefix: Text('${widget.chromosome?.chrName}:  ', style: TextStyle(fontWeight: FontWeight.w300, fontSize: 16)),
        //     inputWidth: 100,
        //     onSubmit: (range) => widget.onZoomToRange?.call(range),
        //     decoration: BoxDecoration(
        //       border: Border.all(color: Theme.of(context).colorScheme.primaryLight),
        //       borderRadius: BorderRadius.all(Radius.elliptical(2, 2)),
        //     ),
        //   ),
        // if (!_isBigScreen)
        //   Builder(builder: (c) {
        //     return MaterialButton(
        //       minWidth: 30,
        //       elevation: 0,
        //       textColor: _dark ? Colors.white : Theme.of(context).colorScheme.primary,
        //       padding: EdgeInsets.symmetric(horizontal: 6),
        //       // colorBrightness: Brightness.dark,
        //       onPressed: () => widget.onTap?.call(c, TrackControlAction.tap_locate),
        //       //icon: Icon(MaterialCommunityIcons.dna),
        //       child: Text('${_range?.start?.floor() ?? ''} - ${_range?.end?.floor() ?? ''}', style: TextStyle(fontSize: 14)),
        //     );
        //   }),
      ],
    );
  }

  Widget _btn({required Icon icon, VoidCallback? onPressed, String? tooltip}) {
    Color _color = Theme.of(context).colorScheme.primary;
    Color _buttonColor = Colors.white;
    double elevation = 3;
    ShapeBorder shape = CircleBorder(side: BorderSide(width: .5, color: Colors.white));
    EdgeInsets _itemPadding = EdgeInsets.symmetric(horizontal: 12, vertical: 12);
    return Tooltip(
      message: tooltip,
      child: TextButton(
        // color: _color,
        // shape: shape,
        // minWidth: 30,
        // elevation: elevation,
        // padding: _itemPadding,
        style: TextButton.styleFrom(
          minimumSize: Size(40, 30),
          maximumSize: Size(40, 30),
          padding: EdgeInsets.symmetric(vertical: 2, horizontal: 2),
          // side: BorderSide(width: .5, color: _color.withOpacity(.5)),
          // shape: RoundedRectangleBorder(
          //   borderRadius: BorderRadius.circular(1),
          // ),
        ),
        child: icon,
        //label: Text('Min Scale'),
        //tooltip: 'Previous session',
        onPressed: onPressed,
      ),
    );
  }

  Widget _zoom(double width) {
    bool _mobilPlatform = mobilePlatform();
    bool _bigScreen = width >= 1200;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _btn(
          // constraints: _buttonConstraints,
          // padding: EdgeInsets.zero,
          // splashRadius: 16,
          onPressed: () => widget.onPan?.call(TrackControlAction.pan_start),
          tooltip: 'move to start',
          icon: Icon(MaterialCommunityIcons.arrow_collapse_left, size: 20),
        ),
        if (_bigScreen)
          _btn(
            // constraints: _buttonConstraints,
            // padding: EdgeInsets.zero,
            // splashRadius: 16,
            onPressed: () => widget.onPan?.call(TrackControlAction.pan_left),
            tooltip: 'pan left',
            icon: Icon(MaterialCommunityIcons.chevron_left),
          ),
        if (_bigScreen)
          _btn(
            // constraints: _buttonConstraints,
            // padding: EdgeInsets.zero,
            // splashRadius: 16,
            // iconSize: 24,
            tooltip: 'zoom out x2',
            icon: Icon(MaterialIcons.exposure_neg_2),
            onPressed: () => widget.onZoomChange?.call(TrackControlAction.zoom_out_2),
          ),
        _btn(
          // constraints: _buttonConstraints,
          // padding: EdgeInsets.zero,
          // splashRadius: 16,
          tooltip: 'zoom out x1',
          icon: Icon(MaterialIcons.exposure_neg_1),
          onPressed: () => widget.onZoomChange?.call(TrackControlAction.zoom_out_1),
        ),
        _btn(
          // constraints: _buttonConstraints,
          // padding: EdgeInsets.zero,
          // splashRadius: 16,
          tooltip: 'zoom in x1',
          icon: Icon(MaterialIcons.exposure_plus_1),
          onPressed: () => widget.onZoomChange?.call(TrackControlAction.zoom_in_1),
        ),
        if (_bigScreen)
          _btn(
            // constraints: _buttonConstraints,
            // padding: EdgeInsets.zero,
            // splashRadius: 16,
            // iconSize: 24,
            tooltip: 'zoom in x2',
            icon: Icon(MaterialIcons.exposure_plus_2),
            onPressed: () => widget.onZoomChange?.call(TrackControlAction.zoom_in_2),
          ),
        if (_bigScreen)
          _btn(
            // constraints: _buttonConstraints,
            // padding: EdgeInsets.zero,
            // splashRadius: 16,
            onPressed: () => widget.onPan?.call(TrackControlAction.pan_right),
            tooltip: 'pan right',
            icon: Icon(MaterialCommunityIcons.chevron_right),
          ),
        _btn(
          // constraints: _buttonConstraints,
          // padding: EdgeInsets.zero,
          // splashRadius: 16,
          // iconSize: 24,
          onPressed: () => widget.onPan?.call(TrackControlAction.pan_end),
          tooltip: 'move to end',
          icon: Icon(MaterialCommunityIcons.arrow_collapse_right, size: 20),
        ),
        SizedBox(width: 20),
        _btn(
          // constraints: _buttonConstraints,
          // padding: EdgeInsets.zero,
          // splashRadius: 16,
          onPressed: () => widget.onPan?.call(TrackControlAction.pan_min_scale),
          tooltip: 'Min Scale',
          icon: Icon(MaterialCommunityIcons.format_horizontal_align_center, size: 22), //arrow-collapse-horizontal
        ),
        _btn(
          // constraints: _buttonConstraints,
          // padding: EdgeInsets.zero,
          // splashRadius: 16,
          onPressed: () => widget.onPan?.call(TrackControlAction.pan_max_scale),
          tooltip: 'Max Scale',
          icon: Icon(MaterialCommunityIcons.arrow_expand_horizontal, size: 20),
        ),
      ],
    );
  }

  Widget _right(double _width) {
    bool _mobile = isMobile(context, Size(_width, 0));
    bool _desktop = isBigScreen(context, Size(_width, 0));
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
//        SizedBox(width: 40),
        Builder(builder: (context) {
          return IconButton(
            icon: Icon(Icons.checklist),
            iconSize: 20,
            padding: EdgeInsets.zero,
            constraints: BoxConstraints.tightFor(width: 34, height: 32),
            splashRadius: 16,
            onPressed: () => _showTrackBatchSettings(context),
            tooltip: 'Track batch setting',
          );
        }),
        if (!_mobile) SizedBox(width: 6),
        if (!_mobile)
          ToggleButtonGroup(
            constraints: BoxConstraints.expand(height: 24, width: 32),
            borderRadius: BorderRadius.circular(4),
            selectedIndex: 1,
            selectedColor: Theme.of(context).colorScheme.primary,
            onChange: widget.onPanModeChange,
            children: <Widget>[
              Tooltip(child: Icon(Icons.photo_size_select_small, size: 18), message: 'Selection Mode'),
              Tooltip(child: Icon(Icons.pan_tool, size: 16), message: 'Drag/Move Mode'),
            ],
          ),
        if (!_mobile) SizedBox(width: 6),
        if (!_mobile)
          ButtonGroup(
            border: Border.all(width: .8, color: Theme.of(context).dividerColor),
            divider: SizedBox(child: VerticalDivider(width: .8), height: 24),
            children: [
              Tooltip(
                message: 'Undo',
                child: TextButton(
                  child: Icon(MaterialCommunityIcons.undo_variant, size: 20),
                  style: TextButton.styleFrom(
                    minimumSize: Size(40, 30),
                    maximumSize: Size(80, 30),
                    padding: EdgeInsets.symmetric(horizontal: 4),
                  ),
                  // padding: EdgeInsets.zero,
                  // constraints: BoxConstraints.tightFor(width: 40, height: 40),
                  // splashRadius: 18,
                  // tooltip: 'Undo',
                  onPressed: widget.enabled && UndoRedoManager.get().canUndo ? () => widget.onTap?.call(context, TrackControlAction.tap_undo) : null,
                ),
              ),
              Tooltip(
                message: 'Redo',
                child: TextButton(
                  child: Icon(MaterialCommunityIcons.redo_variant, size: 20),
                  style: TextButton.styleFrom(
                    minimumSize: Size(40, 30),
                    maximumSize: Size(80, 30),
                    padding: EdgeInsets.symmetric(horizontal: 4),
                  ),
                  // padding: EdgeInsets.zero,
                  // constraints: BoxConstraints.tightFor(width: 40, height: 40),
                  // splashRadius: 18,
                  // tooltip: 'Redo',
                  onPressed: widget.enabled && UndoRedoManager.get().canRedo ? () => widget.onTap?.call(context, TrackControlAction.tap_redo) : null,
                ),
              ),
            ],
          ),
        // Builder(
        //   builder: (context) {
        //     int count = SgsAppService.get().compareList.length;
        //     return IconButton(
        //       padding: EdgeInsets.zero,
        //       constraints: BoxConstraints.tightFor(width: 40, height: 40),
        //       splashRadius: 20,
        //       icon: Icon(Icons.playlist_add),
        //       tooltip: 'Compare List',
        //       onPressed: () => widget.onTap?.call(context, TrackControlAction.tap_compare),
        //     ).withBubble(text: '${count}');
        //   },
        // ),
        // if (!_mobile && !widget.inIdeMode)
        //   IconButton(
        //     padding: EdgeInsets.zero,
        //     constraints: BoxConstraints.tightFor(width: 40, height: 40),
        //     splashRadius: 18,
        //     icon: Icon(MaterialCommunityIcons.format_list_checks),
        //     tooltip: 'Track List',
        //     onPressed: widget.enabled ? () => widget.onTap?.call(context, TrackControlAction.tap_track_list) : null,
        //   ),
        // if (_mobile && !widget.inIdeMode)
        //   IconButton(
        //     padding: EdgeInsets.zero,
        //     constraints: BoxConstraints.tightFor(width: 40, height: 40),
        //     splashRadius: 18,
        //     icon: Icon(MaterialCommunityIcons.history),
        //     tooltip: 'Session List',
        //     onPressed: widget.enabled ? () => widget.onTap?.call(context, TrackControlAction.tap_session_list) : null,
        //   ),
        // if (!_mobile)
        //   IconButton(
        //     padding: EdgeInsets.zero,
        //     constraints: BoxConstraints.tightFor(width: 40, height: 40),
        //     splashRadius: 16,
        //     iconSize: 20,
        //     icon: Icon(MaterialCommunityIcons.share),
        //     tooltip: 'Share Session',
        //     onPressed: widget.enabled ? () => widget.onTap?.call(context, TrackControlAction.tap_share_session) : null,
        //   ),
        if (_mobile && !widget.inIdeMode)
          Builder(
            builder: (context) {
              return IconButton(
                padding: EdgeInsets.zero,
                constraints: BoxConstraints.tightFor(width: 40, height: 40),
                splashRadius: 18,
                icon: Icon(Icons.more_vert),
                tooltip: 'Menu for Track、Share etc',
                onPressed: widget.enabled ? () => widget.onTap?.call(context, TrackControlAction.tap_more) : null,
              );
            },
          ),
//        IconButton(
//          icon: Icon(Icons.compare),
//          tooltip: 'Compare',
//          onPressed: () {
//            PlatformAdapter.create().openUrl(context, '/#/comp.browser');
//          },
//        ),
        SizedBox(width: 8),
      ],
    );
  }

  _buildSpeciesTitle(BuildContext context) {
    bool _dark = Theme.of(context).brightness == Brightness.dark;
    return Builder(
      builder: (targetContext) {
        return Tooltip(
          message: '${widget.site?.url}\nClick to change species',
          child: MaterialButton(
            // colorBrightness: Brightness.dark,
            padding: EdgeInsets.symmetric(horizontal: 6),
            minWidth: 10,
            elevation: 0,
            onPressed: () => widget.onTap?.call(targetContext, TrackControlAction.tap_site_selector),
            //icon: Icon(MaterialCommunityIcons.dna),
            textColor: _dark ? Colors.white : Theme.of(context).colorScheme.primary,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(width: 4),
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 100),
                  child: Text(
                    '${widget.site?.currentSpecies ?? widget.site?.name}',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontWeight: FontWeight.w300, fontSize: 14),
                  ),
                ),
                Icon(Icons.keyboard_arrow_down, size: 16),
                SizedBox(width: 4),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _scaleInfo() {
    if (logic.range == null || widget.trackViewWidth == null) return Container();
    double _size = logic.range?.size ?? 0.0;
    return Padding(
      padding: const EdgeInsets.only(left: 10.0),
      child: Text(
        'Viewing a ${fixRange(_size)} region in ${widget.trackViewWidth}px, 1 pixel spans ${fixRange(_size / widget.trackViewWidth!)}',
        style: TextStyle(fontWeight: FontWeight.w300, fontSize: 14),
      ),
    );
  }

  String fixRange(double range) {
    String _size = '';
    if (range < 1024) return '${range.toStringAsFixed(2)}bp';
    double region = (logic.range?.size ?? 0) / 1024;
    if (region > 1024) {
      _size = '${(region / 1024).toStringAsFixed(2)}Mb';
    } else {
      _size = '${(region).toStringAsFixed(2)}kb';
    }
    return _size;
  }

  void _showRangeInputDialog() {
    double _height = MediaQuery.of(context).size.height;
    var dialog = AlertDialog(
      backgroundColor: Colors.transparent,
      contentPadding: EdgeInsets.zero,
      content: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).canvasColor,
          border: Border.all(color: Theme.of(context).colorScheme.primary),
          borderRadius: BorderRadius.circular(8),
        ),
        constraints: BoxConstraints.tightFor(),
        margin: EdgeInsets.only(bottom: _height * .7),
        child: Row(
          children: [
            Expanded(
              child: RangeInputFieldWidget(
                range: logic.range,
                prefix: Text('Chr ${widget.chromosome?.chrName}:  ', style: TextStyle(fontWeight: FontWeight.w300, fontSize: 16)),
                inputWidth: 90,
                autoFocus: true,
                onSubmit: (range) {
                  Navigator.of(context).pop();
                  widget.onZoomToRange?.call(range);
                },
              ),
            )
          ],
        ),
      ),
    );

    showDialog(context: context, builder: (c) => dialog);
  }

  void _showTrackBatchSettings(BuildContext context) {
    showAttachedWidget(
        targetContext: context,
        preferDirection: PreferDirection.bottomRight,
        attachedBuilder: (c) {
          return ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 300),
            child: Material(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              child: SettingListWidget(
                settings: [
                  SettingItem.toggle(key: "title-visible", title: 'Hide All Track Title', value: SgsConfigService.get()?.hideAllTitle),
                  SettingItem.checkGroup(
                    key: 'axis-position',
                    title: 'Axis Position',
                    value: SgsConfigService.get()?.axisDirection,
                    optionListType: OptionListType.row,
                    options: [
                      OptionItem('Left', TrackAxisDirection.left),
                      OptionItem('Center', TrackAxisDirection.center),
                      // OptionItem('Right', TrackAxisDirection.right),
                    ],
                  ),
                  // SettingItem.button(key: 'batch-color', title: 'Set Grouped Track Color', suffix: Icon(Icons.color_lens_outlined, size: 18)),
                ],
                onItemChanged: (p, item) {
                  c.call();
                  if (item.key == 'title-visible') {
                    SgsConfigService.get()?.hideAllTitle = item.value;
                    SgsBrowseLogic.safe()?.update();
                  } else if (item.key == "axis-position") {
                    SgsConfigService.get()?.axisDirection = item.value;
                    SgsBrowseLogic.safe()?.update();
                  }
                },
                onItemTap: (item, r) {
                  c.call();
                  // if (item.key == 'batch-color') {
                  //   SgsConfigService.get()?.setGroupedTrackColor();
                  //   SgsBrowseLogic.safe()?.update();
                  // }
                },
              ),
            ),
          );
        });
  }

  @override
  void dispose() {
    super.dispose();
  }
}
