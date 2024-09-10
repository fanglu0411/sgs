import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/base/container_config.dart';
import 'package:flutter_smart_genome/extensions/widget_extensions.dart';
import 'package:flutter_smart_genome/page/track/theme/gff_style.dart';
import 'package:flutter_smart_genome/page/track/theme/gff_style_widget.dart';
import 'package:flutter_smart_genome/widget/basic/custom_bot_widget.dart';
import 'package:flutter_smart_genome/widget/track/base/track_data.dart';
import 'package:flutter_smart_genome/widget/track/base/track_theme.dart';
import 'package:flutter_smart_genome/widget/track/base/track_style.dart';
import 'package:dartx/dartx.dart' as dx;
import 'package:flutter_smart_genome/widget/track/bed/bed_style.dart';
import 'common_track_style_detail_widget.dart';
import 'track_theme_selector_widget.dart';

class TrackThemeDetailWidget extends StatefulWidget {
  final VoidCallback? onClose;
  final TrackTheme trackTheme;
  final TrackThemeChanged<TrackTheme, TrackType>? onChanged;
  final List<String> featureTypes;
  final TrackType? trackType;

  const TrackThemeDetailWidget({
    Key? key,
    required this.trackTheme,
    this.onChanged,
    this.onClose,
    this.featureTypes = const [],
    this.trackType = TrackType.ref_seq,
  }) : super(key: key);
  @override
  _TrackThemeDetailWidgetState createState() => _TrackThemeDetailWidgetState();
}

class _TrackThemeDetailWidgetState extends State<TrackThemeDetailWidget> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    List<TrackType> trackTypes = widget.trackTheme.trackTypes as List<TrackType>;
    int index = widget.trackType != null ? trackTypes.indexOf(widget.trackType!) : 0;
    _tabController = TabController(length: widget.trackTheme.trackTypes.length, vsync: this, initialIndex: index);
  }

  @override
  Widget build(BuildContext context) {
    // var tabs = widget.trackTheme.trackTypes
    //     .map((e) => Tab(
    //           child: Text(
    //             '${trackTypeString(e)}'.replaceAll('_', ' '),
    //             style: Theme.of(context).textTheme.bodyText2,
    //           ),
    //           height: 30,
    //         ))
    //     .toList();
    return Scaffold(
      appBar: AppBar(
        leading: widget.onClose != null ? CloseButton(onPressed: widget.onClose) : null,
        title: Text('Theme - ${widget.trackTheme.name}'),
        toolbarHeight: 40,
        titleTextStyle: Theme.of(context).textTheme.titleMedium,
        centerTitle: true,
        actions: [
          Builder(builder: (c) {
            return IconButton(
              icon: Icon(Icons.help),
              padding: EdgeInsets.zero,
              constraints: BoxConstraints.tightFor(width: 30, height: 30),
              splashRadius: 15,
              onPressed: () => _showThemeHelp(c),
            );
          }),
          SizedBox(width: 6),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(30),
          child: _buildTrackTypeDropDownButton().withVerticalBorder(color: Theme.of(context).dividerColor),
          // TabBar(
          //   tabs: tabs,
          //   indicatorColor: Theme.of(context).colorScheme.primary,
          //   controller: _tabController,
          //   isScrollable: true,
          // ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildTrackTypeDropDownButton() {
    var items = widget.trackTheme.trackTypes.mapIndexed<DropdownMenuItem<int>>((i, e) {
      return DropdownMenuItem<int>(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              '${trackTypeString(e)}'.replaceAll('_', ' '),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          value: i);
    }).toList();
    return Row(
      children: [
        SizedBox(width: 10),
        Text('Track type: '),
        SizedBox(width: 10),
        Expanded(
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              items: items,
              value: _tabController.index,
              isDense: true,
              onChanged: (index) {
                _tabController.animateTo(index!);
                setState(() {});
              },
            ),
          ),
        ),
        SizedBox(width: 10),
      ],
    );
  }

  void _showThemeHelp(BuildContext context) {
    dialogBuilder(BuildContext context, [CancelFunc? cancel]) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Tips', style: Theme.of(context).textTheme.titleLarge),
          SizedBox(height: 10),
          Text('Tis is global track theme (which will override track ui settings set by context menu)'),
          ButtonBar(
            children: [
              ElevatedButton(
                onPressed: () {
                  // Navigator.of(c).pop();
                  cancel?.call();
                },
                child: Text('Got it'),
              ),
            ],
          ),
        ],
      );
    }

    showAttachedWidget(
      targetContext: context,
      preferDirection: PreferDirection.bottomLeft,
      backgroundColor: menuBackgroundColor,
      attachedBuilder: (cancel) {
        return Material(
          elevation: 6,
          color: Theme.of(context).dialogBackgroundColor,
          shape: modelShape(),
          child: Container(
            constraints: BoxConstraints.tightFor(width: 300),
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: dialogBuilder(context, cancel),
          ),
        );
      },
    );

    // showDialog(
    //   context: context,
    //   builder: (c) {
    //     return ;
    //   },
    // );
  }

  Widget _buildBody() {
    widget.trackTheme.brightness = Theme.of(context).brightness;
    List<Widget> children = widget.trackTheme.trackTypes.map((e) {
      if (e == TrackType.gff) {
        GffStyle trackStyle = widget.trackTheme.getTrackStyle(e) as GffStyle;
        return GffThemeDetailWidget<GffStyle>(
          trackStyle: trackStyle,
          trackType: e,
          trackThemeName: widget.trackTheme.name,
          onChanged: (gffStyle) => _onTrackStyleChange(e, gffStyle),
        );
      } else if (e == TrackType.bed) {
        BedStyle bedStyle = widget.trackTheme.getTrackStyle(e) as BedStyle;
        return GffThemeDetailWidget<BedStyle>(
          trackStyle: bedStyle,
          trackType: e,
          trackThemeName: widget.trackTheme.name,
          onChanged: (gffStyle) => _onTrackStyleChange(e, gffStyle),
        );
      }
      return CommonTrackStyleDetailWidget(
        trackStyle: widget.trackTheme.getTrackStyle(e),
        onChanged: (trackStyle) => _onTrackStyleChange(e, trackStyle),
      );
    }).toList();
    return TabBarView(
      children: children,
      controller: _tabController,
      physics: NeverScrollableScrollPhysics(),
    );
  }

  void _onTrackStyleChange(TrackType trackType, TrackStyle trackStyle) {
    widget.trackTheme.setTrackStyle(trackType, trackStyle);
    widget.onChanged?.call(widget.trackTheme, trackType);
  }
}
