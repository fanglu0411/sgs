import 'package:flutter/material.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:flutter_smart_genome/bloc/track_config/track_config_event.dart';
import 'package:flutter_smart_genome/extensions/widget_extensions.dart';
import 'package:flutter_smart_genome/network/core/http_error.dart';
import 'package:flutter_smart_genome/service/sgs_app_service.dart';
import 'package:flutter_smart_genome/service/sgs_config_service.dart';
import 'package:flutter_smart_genome/widget/basic/custom_bot_widget.dart';
import 'package:flutter_smart_genome/widget/loading_widget.dart';
import 'package:flutter_smart_genome/widget/track/base/track_data.dart';
import 'package:dartx/dartx.dart' as dx;
import 'package:get/get.dart';
import 'package:sticky_grouped_list/sticky_grouped_list.dart';

class TrackListLogic extends GetxController {
  static TrackListLogic? safe() {
    if (Get.isRegistered<TrackListLogic>()) {
      return Get.find<TrackListLogic>();
    }
    return null;
  }

  bool _loading = true;
  HttpError? _error = null;
  List<Track> tracks = [];

  bool get isLoading => _loading;

  HttpError? get errors => _error;

  TextEditingController? _searchFieldController;

  TextEditingController? get searchFieldController => _searchFieldController;

  bool _grouped = true;

  bool get grouped => _grouped;

  void toggleGrouped() {
    _grouped = !grouped;
    update();
  }

  onViewDispose() {
    _searchFieldController?.dispose();
    _searchFieldController = null;
  }

  TrackListLogic();

  @override
  void onInit() {
    super.onInit();
    _searchFieldController = TextEditingController();
  }

  void loading(bool loading) {
    _loading = loading;
    _error = null;
    update();
  }

  void error(String error) {
    _loading = false;
    _error = HttpError(-1, error);
    update();
  }

  void setTracks(List<Track> filterTracks) {
    _loading = false;
    _error = null;
    tracks = filterTracks;
    _searchFieldController ??= TextEditingController();
    _searchFieldController?.clear();
    update();
  }

  void setData({
    bool loading = false,
    String? error = null,
    List<Track> tracks = const [],
    bool clearFilter = false,
  }) {
    this._loading = loading;
    _error = error == null ? null : HttpError(-1, error);
    this.tracks = tracks;
    _searchFieldController ??= TextEditingController();
    if (clearFilter) _searchFieldController?.text = '';
    update();
  }

  void clearFilter() {
    _searchFieldController?.clear();
    update();
  }

  void filterTrack(String keyword) {
    update();
  }

  List<Track> get filteredTrack => (_searchFieldController?.text.length ?? 0) == 0
      ? tracks //
      : tracks.where((track) => track.trackName.contains(_searchFieldController!.text)).toList();

  Map<TrackType, List<Track>> get groupedTracks {
    return filteredTrack.groupBy((t) => t.trackType);
  }

  void _toggleGroupByType(Track track) {
    bool checked = SgsConfigService.get()!.isTrackGrouped(track);
    SgsConfigService.get()!.toggleGroupByTrackType(track, !checked);
    update();
  }

  @override
  void onReady() {
    super.onReady();
    Future.delayed(Duration(milliseconds: 50)).then((value) {
      setData(tracks: SgsAppService.get()!.tracks);
      // SgsAppService.get()!.sendEvent(ForceUpdateTracksEvent());
    });
  }

  @override
  void onClose() {
    super.onClose();
    _searchFieldController?.dispose();
    _searchFieldController = null;
  }

  autoGroupedColor(Track t) {
    SgsConfigService.get()!.setGroupedTrackColor(t.trackType, (groupedTracks[t.trackType] ?? []).map((e) => e.id!).toList());
  }
}

mixin TrackListMixin<T extends StatefulWidget> on State<T> {
  bool _checkAll = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TrackListLogic>(
      init: TrackListLogic(),
      // autoRemove: false,
      builder: buildWithContext,
    );
  }

  Widget buildWithContext(TrackListLogic logic) {
    if (logic.isLoading) {
      return LoadingWidget(loadingState: LoadingState.loading);
    }
    if (logic.errors != null) {
      return LoadingWidget(loadingState: LoadingState.error, message: logic.errors!.message);
    }
    return buildList(context, logic);
  }

  Widget buildList(BuildContext context, TrackListLogic logic) {
    _checkAll = (logic.tracks).every((t) => t.checked);

    List<Widget> trackWidgets;
    Widget _listWidget;

    if (logic.grouped) {
      Map<TrackType, List<Track>> _groupedTracks = logic.groupedTracks;
      _listWidget = _groupedTracks.length == 0
          ? SizedBox()
          : StickyGroupedListView<Track, TrackType>(
              groupBy: (t) => t.trackType,
              elements: logic.filteredTrack,
              groupComparator: (a, b) => a.index - b.index,
              itemComparator: (a, b) => a.trackName.compareTo(b.trackName),
              stickyHeaderBackgroundColor: Theme.of(context).colorScheme.secondaryContainer,
              groupSeparatorBuilder: (t) => ListTile(
                tileColor: Theme.of(context).colorScheme.secondaryContainer.withAlpha(80),
                minVerticalPadding: 0,
                dense: true,
                contentPadding: EdgeInsets.symmetric(),
                horizontalTitleGap: 4,
                title: Text('${t.trackType.name.capitalizeFirst}', style: TextStyle(fontWeight: FontWeight.w600)),
                leading: IconButton(
                  isSelected: SgsConfigService.get()!.isTrackGrouped(t),
                  icon: Icon(Icons.library_add_check_outlined),
                  selectedIcon: Icon(Icons.library_add_check, color: Theme.of(context).colorScheme.primary),
                  tooltip: 'Batch control',
                  constraints: BoxConstraints.tightFor(width: 30, height: 30),
                  style: IconButton.styleFrom(
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    iconSize: 20,
                  ),
                  onPressed: () => logic._toggleGroupByType(t),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (SgsConfigService.get()!.isTrackGrouped(t))
                      IconButton(
                        onPressed: () => logic.autoGroupedColor(t),
                        icon: Icon(Icons.format_color_fill, color: Theme.of(context).colorScheme.primary),
                        constraints: BoxConstraints.tightFor(width: 30, height: 30),
                        tooltip: 'Auto Color',
                        style: IconButton.styleFrom(
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          iconSize: 18,
                        ),
                      ),
                    SizedBox(width: 12),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(width: 1.0, color: Theme.of(context).primaryColor),
                      ),
                      constraints: BoxConstraints(minWidth: 30, maxHeight: 20),
                      alignment: Alignment.center,
                      child: Text('${_groupedTracks[t.trackType]!.length}'),
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                    ),
                    SizedBox(width: 12),
                  ],
                ),
              ),
              itemBuilder: _trackItemBuilder,
            );
    } else {
      trackWidgets = (logic.filteredTrack).mapIndexed((idx, track) {
        // return [_trackItemBuilder(context, track, idx),if (track.hasChildren) ...track.children.map((e) => _subTrackItemBuilder(context, e, idx))];
        return _trackItemBuilder(context, track, idx: idx);
      }).toList();
      _listWidget = ReorderableListView(
        buildDefaultDragHandles: false,
        onReorder: (int old, int newIndex) => _onReorderList(context, old, newIndex),
        children: trackWidgets,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: 10),
        _buildSearchField(context, logic),
        Row(
          children: [
            CheckboxMenuButton(
              value: _checkAll,
              onChanged: (v) {
                _checkAll = (v ?? false);
                SgsAppService.get()!.sendEvent(ToggleSelectAllTrackEvent(_checkAll));
              },
              style: MenuItemButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 6),
                minimumSize: Size(30, 42),
                textStyle: TextStyle(fontSize: 14),
              ),
              child: Text('Check All'),
            ),
            // SizedBox(width: 4),
            MenuItemButton(
              leadingIcon: Icon(Icons.sort, size: 20),
              requestFocusOnHover: false,
              child: Text('Re-Sort'),
              style: MenuItemButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 6),
                minimumSize: Size(30, 42),
                textStyle: TextStyle(fontSize: 14),
              ),
              onPressed: () {
                SgsAppService.get()!.sendEvent(ResetOrderTrackListEvent());
              },
            ),
            Spacer(),
            MenuItemButton(
              leadingIcon: Icon(
                logic.grouped ? Icons.library_add_check : MaterialCommunityIcons.check_box_multiple_outline,
                size: 16,
                color: logic.grouped ? Theme.of(context).colorScheme.primary : null,
              ),
              child: Text('Group'),
              onPressed: logic.toggleGrouped,
              style: MenuItemButton.styleFrom(
                minimumSize: Size(40, 42),
                textStyle: TextStyle(fontSize: 14),
              ),
            ).tooltip('Group by Type'),
            MenuItemButton(
              child: Icon(Icons.refresh, size: 20),
              requestFocusOnHover: false,
              onPressed: _reloadTracks,
              style: MenuItemButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 8),
                minimumSize: Size(40, 42),
                textStyle: TextStyle(fontSize: 14),
              ),
            ).tooltip('Refresh'),
            // MenuItemButton(
            //   child: Icon(Icons.edit_note, size: 20),
            //   style: MenuItemButton.styleFrom(
            //     padding: EdgeInsets.symmetric(horizontal: 8),
            //     minimumSize: Size(40, 42),
            //     textStyle: TextStyle(fontSize: 14),
            //   ),
            //   onPressed: () {
            //     _editMode = true;
            //     setState(() {});
            //   },
            // ).tooltip('Edit Mode'),
          ],
        ),
        Divider(height: 1),
        Expanded(child: _listWidget),
      ],
    );
  }

  Widget _trackItemBuilder(BuildContext context, Track track, {int? idx}) {
    var theme = Theme.of(context);
    bool _dark = Theme.of(context).brightness == Brightness.dark;
    var _primaryColor = theme.colorScheme.primary;
    var sortIcon = idx != null
        ? Padding(
            padding: const EdgeInsets.only(right: 10),
            child: ReorderableDragStartListener(
              index: idx,
              child: Icon(Icons.drag_indicator, size: 20, color: theme.colorScheme.secondary),
            ),
          )
        : null;

    bool? _checked = track.hasChildren ? (track.childrenCheckedAll ? true : (track.childrenHasChecked ? null : false)) : track.checked;
    bool _tristate = track.hasChildren ? (track.childrenHasChecked ? true : false) : false;
    // bool _checked = track.hasChildren ? (track.childrenHasChecked) : track.checked;

    Widget tile = ListTile(
      horizontalTitleGap: 4,
      enabled: track.statusDone,
      contentPadding: EdgeInsets.symmetric(vertical: 0),
      visualDensity: VisualDensity(horizontal: VisualDensity.minimumDensity, vertical: VisualDensity.minimumDensity),
      leading: Checkbox(
        value: _checked,
        tristate: _tristate,
        splashRadius: 15,
        shape: RoundedRectangleBorder(side: BorderSide(width: 1.0), borderRadius: BorderRadius.circular(2)),
        side: BorderSide(width: 1.5, color: Theme.of(context).textTheme.bodyMedium!.color!),
        onChanged: !track.statusDone ? null : (c) => onCheckChange(track, c),
      ),
      selectedTileColor: _dark ? _primaryColor.withOpacity(.08) : _primaryColor.withOpacity(.05),
      title: Text(
        '${track.name}',
        style: TextStyle(fontWeight: FontWeight.w400, fontSize: 13),
      ),
      trailing: track.hasChildren
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  constraints: BoxConstraints.tightFor(width: 36, height: 36),
                  padding: EdgeInsets.zero,
                  splashRadius: 18,
                  color: Theme.of(context).colorScheme.primary,
                  icon: Icon(track.expanded ? Icons.expand_less : Icons.expand_more),
                  onPressed: () {
                    setState(() {
                      track.expanded = !track.expanded;
                    });
                  },
                  tooltip: track.expanded ? 'fold' : 'expand sub-track',
                ),
                if (sortIcon != null) sortIcon,
              ],
            )
          : sortIcon,
      onTap: () {},
    );
    // if (track.hasChildren) tile = Container(color: _primaryColor.withOpacity(.1), child: tile);
    return Container(
      key: Key('${track.hashCode}'),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(width: 1.0, color: Theme.of(context).dividerColor)),
      ),
      child: track.hasChildren && track.expanded
          ? Column(
              children: [tile, ...track.children!.map((e) => _subTrackItemBuilder(context, e))],
            )
          : tile,
    );
  }

  Widget _subTrackItemBuilder(BuildContext context, Track track) {
    var theme = Theme.of(context);
    bool _dark = Theme.of(context).brightness == Brightness.dark;
    var _primaryColor = theme.primaryColor;
    return Container(
      key: Key('${track.hashCode}'),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(width: 1, color: Theme.of(context).dividerColor))),
      padding: EdgeInsets.only(left: 20),
      child: ListTile(
        horizontalTitleGap: 4,
        enabled: track.statusDone && (track.parent?.statusDone ?? true),
        dense: true,
        contentPadding: EdgeInsets.symmetric(vertical: 0),
        visualDensity: VisualDensity(horizontal: VisualDensity.minimumDensity, vertical: VisualDensity.minimumDensity),
        leading: Checkbox(
          value: track.checked,
          splashRadius: 15,
          shape: RoundedRectangleBorder(side: BorderSide(width: 1.0), borderRadius: BorderRadius.circular(2)),
          side: BorderSide(width: 1.5, color: Theme.of(context).textTheme.bodyMedium!.color!),
          onChanged: !track.statusDone ? null : (c) => onCheckChange(track, c!),
        ),
        selectedTileColor: _dark ? _primaryColor.withOpacity(.08) : _primaryColor.withOpacity(.08),
        title: Text('${track.name}'),
        onTap: () {},
      ),
    );
  }

  void onCheckChange(Track track, bool? checked) {
    if (checked == null && track.hasChildren) checked = false;
    if (checked == null) return;
    SgsAppService.get()!.sendEvent(ToggleTrackSelectionEvent(track, checked));
    if (checked && SgsAppService.get()!.selectedTracks.length >= 7) {
      // BotToast.showCustomNotification(toastBuilder: toastBuilder)
      showWarnNotification(title: Text('Warning'), subtitle: Text('Too many track selected, this may slow down your sgs!'));
    }
  }

  void _reloadTracks() {
    TrackListLogic.safe()?.loading(true);
    SgsAppService.get()!.sendEvent(ForceUpdateTracksEvent(genomeTrack: true, scTrack: false));
  }

  void onCheckedChange(List<Track> tracks) {}

  Widget _buildSearchField(BuildContext context, TrackListLogic logic) {
    return Container(
      height: 32,
      child: TextField(
        controller: logic.searchFieldController,
        decoration: InputDecoration(
          hintText: 'track name keyword',
          prefixIcon: Icon(Icons.search),
          contentPadding: EdgeInsets.symmetric(vertical: 0),
          suffixIcon: IconButton(
            iconSize: 20,
            splashRadius: 15,
            padding: EdgeInsets.zero,
            icon: Icon(Icons.close),
            onPressed: () {
              logic.clearFilter();
            },
          ),
        ),
        textInputAction: TextInputAction.go,
        onSubmitted: logic.filterTrack,
        onChanged: logic.filterTrack,
      ),
    );
  }

  void _onReorderList(BuildContext context, int old, int newIndex) {
    SgsAppService.get()!.sendEvent(ReorderTrackEvent(old, newIndex));
  }

  void _onFilterTrack(BuildContext context, String value) {
    // SgsAppService.get()!.sendEvent(FilterTrackWithKeywordEvent(value));
  }

  @override
  void dispose() {
    super.dispose();
  }
}
