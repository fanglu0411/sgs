import 'package:bot_toast/bot_toast.dart';
import 'package:dartx/dartx.dart';
import 'package:flutter_smart_genome/components/window/multi_window_controller.dart';
import 'package:flutter_smart_genome/widget/basic/custom_bot_widget.dart';
import 'package:flutter_smart_genome/widget/basic/custom_spin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:flutter_smart_genome/bean/account_bean.dart';
import 'package:flutter_smart_genome/bean/site_item.dart';
import 'package:flutter_smart_genome/bean/datasets.dart';
import 'package:flutter_smart_genome/network/core/http_error.dart';
import 'package:flutter_smart_genome/network/http_response.dart';
import 'package:flutter_smart_genome/page/admin/sc/cell_cluster_selector/cell_cluster_selector_view.dart';
import 'package:flutter_smart_genome/page/admin/species/species_edit_page.dart';
import 'package:flutter_smart_genome/page/admin/track/track_category.dart';
import 'package:flutter_smart_genome/page/admin/track/track_item.dart';
import 'package:flutter_smart_genome/routes.dart';
import 'package:flutter_smart_genome/service/abs_platform_service.dart';
import 'package:flutter_smart_genome/service/single_cell_service.dart';
import 'package:flutter_smart_genome/util/debouncer.dart';
import 'package:flutter_smart_genome/widget/loading_widget.dart';
import 'package:flutter_smart_genome/widget/toggle_button_group.dart';
import 'package:flutter_smart_genome/widget/track/base/track_data.dart';
import 'package:get/get.dart';

class TrackListPage extends StatefulWidget {
  final Species species;
  final SiteItem site;
  final AccountBean account;
  final bool cardView;

  const TrackListPage({
    Key? key,
    required this.species,
    required this.site,
    required this.account,
    this.cardView = false,
  }) : super(key: key);

  @override
  _TrackListPageState createState() => _TrackListPageState();
}

enum ListType {
  list,
  grid,
  tile,
}

enum OrderType {
  normal('Default'),
  name('Name'),
  trackType('TrackType');

  final String label;

  const OrderType(this.label);
}

class _TrackListPageState extends State<TrackListPage> {
  List<Track>? _genomeTracks;
  List<Track>? _scTracks;
  List<Track>? _filteredTracks;

  Map<TrackType, bool> _checkedTypes = {};

  bool _loading = false;
  HttpError? _error = null;

  List<Track> get _tracks => [...(_genomeTracks ?? []), ...(_scTracks ?? [])];

  Debounce? _debouncer;

  late ListType _listType;
  late OrderType _orderType;

  @override
  void initState() {
    super.initState();
    _debouncer = Debounce(milliseconds: 10000);
    _listType = ListType.tile;
    _orderType = OrderType.normal;
    _filterController = TextEditingController();
    _loadTracks();
  }

  void _loadTracks({bool refresh = true}) async {
    if (refresh) {
      setState(() {
        _loading = true;
        _genomeTracks = null;
        _scTracks = null;
        _filteredTracks = null;
        _error = null;
      });
    }
    List<HttpResponseBean<List<Track>>> trackResp = await Future.wait([
      AbsPlatformService.get(widget.site)!.loadAllTrackList(
        species: '${widget.species.id}',
        host: widget.site.url,
        refresh: true,
      ),
      loadCellTrackList(host: widget.site.url, speciesId: widget.species.id, refresh: true),
    ]);

    _genomeTracks = trackResp[0].body ?? [];
    _scTracks = trackResp[1].body ?? [];

    if (!trackResp[0].success || !trackResp[1].success) {
      _error = trackResp[0].error ?? trackResp[1].error;
    } else {
      _error = null;
    }

    _filteredTracks = _filterTrack();
    var _types = [...Set.from(_tracks.map((e) => e.trackType))];
    _checkedTypes = Map.fromIterable(_types, value: (v) => true);
    _loading = false;

    if (!mounted) return;
    setState(() {});
    if ((_tracks).any((t) => !(t.statusDone || t.statusError))) {
      _debouncer!.run(() => _loadTracks(refresh: false));
    }
  }

  String? _keyword;

  List<Track>? _filterTrack() {
    var __tracks = _tracks.where((t) => _checkedTypes[t.trackType] ?? true);
    if (null != _keyword && !_keyword!.isEmpty) {
      __tracks = __tracks.where((t) => '${t.name}-${t.trackType.toString()}'.toLowerCase().contains(_keyword!.toLowerCase()));
    }
    if (_orderType == OrderType.normal) {
      return __tracks.toList();
    }
    return __tracks.sortedBy(_orderType == OrderType.name ? sortName : sortType).toList();
  }

  Comparable sortName(Track t) {
    return t.name;
  }

  Comparable sortType(Track t) {
    return t.trackType.name;
  }

  void _onFilterChange(String keyword) {
    _keyword = keyword;
    _filteredTracks = _filterTrack();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: _builder,
    );
  }

  Widget _builder(BuildContext context, BoxConstraints constraints) {
    var body;
    if (_loading) {
      body = LoadingWidget(loadingState: LoadingState.loading);
    } else if (_tracks.length == 0) {
      body = LoadingWidget(loadingState: LoadingState.noData, message: 'No data in this project!');
    } else {
      if (ListType.grid == _listType) {
        int columns = constraints.maxWidth ~/ 400;
        var itemWidth = (constraints.maxWidth - 20 * (columns + 1)) / columns;
        var height = 90;
        body = GridView.builder(
          padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 20),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: 20,
            crossAxisSpacing: 20,
            childAspectRatio: itemWidth / height,
          ),
          itemBuilder: _cardItemBuilderIndexed,
          itemCount: _filteredTracks!.length,
        );
      } else if (_listType == ListType.tile) {
        int columns = constraints.maxWidth ~/ 400;
        double padding = 15;
        var itemWidth = (constraints.maxWidth - padding * (columns + 1)) / columns;
        var height = 40;
        body = GridView.builder(
          padding: EdgeInsets.only(left: padding, right: padding, top: padding, bottom: padding),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: 0,
            crossAxisSpacing: padding,
            childAspectRatio: itemWidth / height,
          ),
          itemBuilder: _tileBuilder,
          itemCount: _filteredTracks!.length,
        );
      } else {
        body = ListView.separated(
          separatorBuilder: (c, i) => Divider(height: 1, thickness: 1),
          itemBuilder: _itemBuilder,
          itemCount: _filteredTracks!.length,
        );
      }
    }
    bool _dark = Theme.of(context).brightness == Brightness.dark;
    Color priColor = Theme.of(context).colorScheme.primary;
    return Scaffold(
      // backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          'Data List - ${widget.species.name}',
          // style: TextStyle(color: Colors.black),
        ),
        // backgroundColor: priColor.withAlpha(10),
        elevation: 0,
        // foregroundColor: priColor,
        // systemOverlayStyle: SystemUiOverlayStyle.light,
        centerTitle: false,
        // shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8))),
        // shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
        actions: [
          if (Get.width >= 700) _header(),
          SizedBox(width: 16),
          Container(
            child: Center(
              child: ToggleButtonGroup(
                constraints: BoxConstraints.tightFor(height: 30, width: 40),
                selectedIndex: _listType.index,
                borderRadius: BorderRadius.circular(4),
                onChange: (i) {
                  setState(() {
                    _listType = ListType.values[i];
                  });
                },
                children: [
                  Tooltip(child: Icon(Icons.view_list_rounded, size: 18), message: 'List View'),
                  Tooltip(child: Icon(Icons.grid_view_rounded, size: 18), message: 'Grid View'),
                  Tooltip(child: Icon(Icons.view_comfortable, size: 18), message: 'Tile View'),
                ],
              ),
            ),
          ),
          SizedBox(width: 10),
          PopupMenuButton<OrderType>(
            onSelected: (v) {
              _orderType = v;
              _filteredTracks = _filterTrack();
              setState(() {});
            },
            child: Icon(Icons.sort, size: 20),
            padding: EdgeInsets.all(0),
            initialValue: _orderType,
            tooltip: 'Sort',
            position: PopupMenuPosition.under,
            itemBuilder: (c) => OrderType.values
                .map((e) => CheckedPopupMenuItem<OrderType>(
                      value: e,
                      checked: _orderType == e,
                      child: Text(e.label),
                    ))
                .toList(),
          ),

          SizedBox(width: 10),
          IconButton(
            onPressed: _loadTracks,
            icon: Icon(Icons.refresh),
            color: priColor,
            splashRadius: 20,
            tooltip: 'Reload Data List',
          ),
          SizedBox(width: 10),
          IconButton(
            onPressed: _addTrack,
            //_trackDataTypeSelector,
            icon: Icon(Icons.add_box),
            color: priColor,
            splashRadius: 20,
            tooltip: 'Add Data',
          ),
          SizedBox(width: 12),
          // TextButton.icon(
          //   onPressed: () => _addTrack(TrackBioCategory.GENOME),
          //   icon: Icon(Icons.add_box),
          //   style: TextButton.styleFrom(foregroundColor: priColor),
          //   label: Text('Add Track'),
          // ),
        ],
      ),
      body: body,
    );
  }

  late TextEditingController _filterController;

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTypeIndicators(),
          SizedBox(width: 20),
          TextField(
            controller: _filterController,
            cursorHeight: 16,
            decoration: InputDecoration(
              filled: true,
              prefixIcon: Icon(Feather.filter, size: 16),
              hintText: 'input file name / type to filter',
              hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w300),
              constraints: BoxConstraints(maxHeight: 30, maxWidth: 260),
              contentPadding: EdgeInsets.symmetric(vertical: 2, horizontal: 10),
              border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(20)),
              suffixIcon: _filterController.text.length > 0
                  ? IconButton(
                      icon: Icon(Icons.close),
                      iconSize: 18,
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints.tightFor(width: 30, height: 30),
                      onPressed: () {
                        _filterController.text = '';
                        _onFilterChange('');
                      },
                    )
                  : null,
            ),
            onChanged: _onFilterChange,
          ),
          // Spacer(),
          // SizedBox(width: 160),
        ],
      ),
    );
  }

  Widget _buildTypeIndicators() {
    return Wrap(
      spacing: 5,
      children: _checkedTypes.keys
          .map((e) => IconButton(
                tooltip: e.name,
                padding: EdgeInsets.zero,
                style: IconButton.styleFrom(
                  foregroundColor: trackTypeColorMapper[e],
                  // foregroundColor: Colors.white,
                ),
                constraints: BoxConstraints.tightFor(width: 20, height: 20),
                iconSize: 16,
                icon: Icon(
                  _checkedTypes[e]! ? Icons.check_circle_rounded : Icons.check_circle_outline_rounded,
                  size: 20,
                  color: trackTypeColorMapper[e],
                ),
                onPressed: () {
                  _checkedTypes[e] = !_checkedTypes[e]!;
                  _filteredTracks = _filterTrack();
                  setState(() {});
                },
              ))
          .toList(),
    );
  }

  Widget _tileBuilder(context, index) {
    Track _track = _filteredTracks![index];
    return TrackTileWidget(track: _track, onDelete: _deleteConfirm);
  }

  Widget _itemBuilder(context, index) {
    Track _track = _filteredTracks![index];
    return TrackListItemWidget(track: _track, onDelete: _deleteConfirm);
  }

  Widget statusWidget(Track _track) {
    Widget statusWidget;
    if (_track.statusDone) {
      statusWidget = Chip(
        avatar: Icon(Icons.check_circle, color: Colors.green),
        label: Text('${_track.status}'),
        visualDensity: VisualDensity.compact,
        backgroundColor: Colors.green.withOpacity(.25),
        side: BorderSide.none,
      );
    } else if (_track.statusError) {
      statusWidget = Chip(
        side: BorderSide.none,
        visualDensity: VisualDensity.compact,
        avatar: Icon(Icons.error, color: Colors.redAccent),
        label: Text('${_track.status}', style: TextStyle(color: Colors.redAccent)),
        backgroundColor: Colors.red.withOpacity(.15),
      );
    } else {
      statusWidget = Chip(
        side: BorderSide.none,
        visualDensity: VisualDensity.compact,
        avatar: CustomSpin(color: Theme.of(context).colorScheme.primary),
        label: Text(_track.progress == null ? '${_track.status}' : '${_track.progress}%'),
        backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(.15),
      );
    }
    return statusWidget;
  }

  Widget _cardItemBuilderIndexed(context, index) {
    Track _track = _filteredTracks![index];
    return TrackCardItemWidget(track: _track, onDelete: _deleteConfirm);
  }

  _updateCluster(Track track) async {
    var resp = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) {
        return AlertDialog(
          title: Text('Select columns you want to set as Cluster'),
          // scrollable: true,
          content: Container(
            // constraints: BoxConstraints.tightFor(width: 200, height: Get.context.height * .6),
            child: CellClusterSelectorView(
              site: widget.site,
              scId: track.scId!,
              onCancel: () => Navigator.pop(c, false),
              onCommit: () => Navigator.pop(c, true),
            ),
          ),
        );
      },
    );
  }

  _deleteConfirm(Track track) async {
    var dialog = (context) => AlertDialog(
          title: Text('Delete Data?'),
          content: Text("Are you sure want to delete track { ${track.name} } ?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text('CANCEL'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text('DELETE'),
            ),
            SizedBox(width: 10),
          ],
        );
    var result = await showDialog(context: context, builder: dialog);
    if (result) {
      _deleteTrack(track);
    }
  }

  _addTrack([TrackBioCategory category = TrackBioCategory.GENOME]) async {
    var path = category == TrackBioCategory.GENOME ? RoutePath.manage_genome_track_add : RoutePath.manage_sc_add;
    var resp = await Navigator.of(context).pushNamed(path, arguments: SpeciesEditParams(widget.site, widget.species, widget.account));
    if (null != resp && resp == true) {
      _loadTracks();
    }
  }

  // auto recognize
  void _trackDataTypeSelector() async {
    var result = await showDialog<TrackBioCategory?>(
        context: context,
        builder: (c) {
          return AlertDialog(
            title: Text('Select Data Type'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: Text('GENOME'),
                  onTap: () {
                    Navigator.of(c).pop(TrackBioCategory.GENOME);
                  },
                ),
                ListTile(
                  title: Text('SINGLE CELL'),
                  onTap: () {
                    Navigator.of(c).pop(TrackBioCategory.ATAC);
                  },
                ),
              ],
            ),
          );
        });
    if (null != result) {
      _addTrack(result);
    }
  }

  _deleteTrack(Track track) async {
    BotToast.showLoading(clickClose: false);
    var fetch = track.isSCTrack
        ? deleteSingleCell(host: widget.site.url, scId: track.scId!) //
        : AbsPlatformService.get(widget.site)!.deleteTrack(host: widget.site.url, trackId: track.id);
    HttpResponseBean resp = await fetch;
    BotToast.closeAllLoading();
    if (resp.success) {
      showSuccessNotification(title: Text('Delete success'));
      if (track.isSCTrack) {
        _tracks.removeWhere((t) => t.scId == track.scId);
        _filteredTracks?.removeWhere((t) => t.scId == track.scId);
      } else {
        _tracks.removeWhere((t) => t.id == track.id);
        _filteredTracks?.removeWhere((t) => t.id == track.id);
      }
      setState(() {});
      multiWindowController.notifyMainWindow(WindowCallEvent.deleteData.name, {
        "id": track.id,
        "speciesId": widget.species.id,
      });
    } else {
      showErrorNotification(title: Text('${resp.error}'));
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
