import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/page/track/theme/tracks_style_detail_widget.dart';
import 'package:flutter_smart_genome/util/debouncer.dart';
import 'package:flutter_smart_genome/widget/fragment/fragment_widget.dart';
import 'package:flutter_smart_genome/widget/track/base/track_data.dart';
import 'package:flutter_smart_genome/widget/track/base/track_theme.dart';

import 'track_theme_list_widget.dart';

typedef TrackThemeChanged<T, D> = void Function(T trackTheme, D trackType);

class TrackThemeSelectorWidget extends StatefulWidget {
  final int? currentFeatureTheme;
  final TrackThemeChanged<TrackTheme, TrackType?>? onThemeChange;
  final List<String> featureTypes;
  final bool smallSize;
  final TrackType? trackType;

  const TrackThemeSelectorWidget({
    Key? key,
//    this.baseFeatures,
    this.currentFeatureTheme,
    this.onThemeChange,
    this.featureTypes = const [],
    this.smallSize = false,
    this.trackType,
  }) : super(key: key);

  @override
  _TrackThemeSelectorWidgetState createState() => _TrackThemeSelectorWidgetState();
}

class _TrackThemeSelectorWidgetState extends State<TrackThemeSelectorWidget> with WidgetsBindingObserver {
  GlobalKey<FragmentWidgetState> _key = GlobalKey<FragmentWidgetState>();
  int? _currentFeatureTheme;

  Debounce? _debounce;

  @override
  void initState() {
    super.initState();
    _debounce = Debounce(milliseconds: 80);
    WidgetsBinding.instance.addObserver(this);
    _currentFeatureTheme = widget.currentFeatureTheme;
  }

  @override
  void didUpdateWidget(TrackThemeSelectorWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _currentFeatureTheme = widget.currentFeatureTheme;
  }

  @override
  void dispose() {
    super.dispose();
    _debounce?.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();
    // _key = GlobalKey<FragmentWidgetState>();
    // setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return FragmentWidget(
      key: _key,
      child: TrackThemeListWidget(
        smallSize: widget.smallSize,
        currentFeatureTheme: _currentFeatureTheme,
        onThemeChange: _onThemeChange,
        onMore: _showThemeDetail,
      ),
    );
  }

  void _onThemeChange(TrackTheme trackTheme) {
    _currentFeatureTheme = trackTheme.name.hashCode;
    widget.onThemeChange?.call(trackTheme, null);
    // BlocProvider.of<SgsContextBloc>(context).setTrackTheme(trackTheme, true);
    // SgsBrowseLogic.safe().setTrackTheme(trackTheme, true);
  }

  void _showThemeDetail(TrackTheme trackTheme) {
    var detailWidget = TrackThemeDetailWidget(
      trackTheme: trackTheme,
      featureTypes: widget.featureTypes,
      trackType: widget.trackType,
      onClose: () {
        _key.currentState?.pop();
      },
      onChanged: _debounceThemeChange,
    );
    _key.currentState?.push((context) => detailWidget);
  }

  _debounceThemeChange(TrackTheme trackTheme, TrackType trackType) {
    // if (featureTheme.name.hashCode == _currentFeatureTheme) {
    _debounce!.run(() async {
      // SgsBrowseLogic.safe().setTrackTheme(trackTheme);
      // BlocProvider.of<SgsContextBloc>(context).setTrackTheme(trackTheme);
      widget.onThemeChange?.call(trackTheme, trackType);
    });
    // }
  }
}