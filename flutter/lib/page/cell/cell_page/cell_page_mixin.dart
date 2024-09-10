import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/bloc/track_config/bloc.dart';
import 'package:flutter_smart_genome/page/cell/cell_page/cell_page_logic.dart';
import 'package:flutter_smart_genome/page/cell/cell_page/local_cell_cord_selector.dart';
import 'package:flutter_smart_genome/page/cell/cell_tool_bar/cell_track_selector_widget.dart';
import 'package:flutter_smart_genome/service/sgs_app_service.dart';
import 'package:flutter_smart_genome/widget/basic/svg_icons.dart';
import 'package:flutter_smart_genome/widget/loading_widget.dart';
import 'package:flutter_smart_genome/widget/track/base/track_data.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

abstract class BaseCellPageWidget extends StatefulWidget {
  final Track? track;
  final bool asPage;
  final bool showTitleBar;

  const BaseCellPageWidget({
    this.track,
    Key? key,
    this.asPage = false,
    this.showTitleBar = false,
  }) : super(key: key);
}

mixin CellPageMixin<T extends BaseCellPageWidget> on State<T> {
  CellPageLogic? logic; // = Get.put(CellPageLogic());

  TextEditingController? _searchFieldController;

  @override
  void initState() {
    super.initState();
    logic = CellPageLogic.safe() ?? Get.put(CellPageLogic());
    if (widget.track != null) {
      logic!.changeTrack(widget.track!);
    }
    _searchFieldController = TextEditingController(text: logic!.trackFilterKey ?? "");
  }

  @override
  void didUpdateWidget(covariant oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    Widget body = GetBuilder<CellPageLogic>(
      init: logic,
      autoRemove: false,
      builder: (logic) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.showTitleBar) _titleBar(),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) => _builder(context, constraints, logic),
              ),
            ),
          ],
        );
      },
    );
    return _wrap(body);
  }

  Widget _builder(BuildContext context, BoxConstraints constraints, CellPageLogic logic) {
    Widget _body;
    if (logic.loading) {
      _body = LoadingWidget(
        loadingState: LoadingState.loading,
        message: 'Loading sc data',
      );
    } else if (logic.error != null) {
      _body = LoadingWidget.error(
        message: logic.error,
        onErrorClick: (s) {
          SgsAppService.get()!.sendEvent(ForceUpdateTracksEvent());
        },
      );
    } else if (logic.track != null || (logic.metaFile != null && logic.cordFile != null)) {
      _body = buildSingleCell(context, constraints, logic);
    } else {
      List<Track> tracks = SgsAppService.get()!.scTracks;
      // List<Track> tracks = SgsAppService.get()!.tracks.where((e) => e.isSCTrack).toList();
      if (tracks.isEmpty) {
        // Widget body = _buildEmptyWidget(_dark, context, logic);
        _body = _buildErrorWidget();
      } else {
        _body = Column(
          children: [
            _trackFilterBar(),
            Expanded(child: _buildTrackList(constraints, logic)),
          ],
        );
      }
    }
    return _body;
  }

  Widget _trackFilterBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(),
      constraints: BoxConstraints(maxWidth: 800),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchFieldController,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                constraints: BoxConstraints.expand(height: 32),
                hintText: 'sc name keyword',
                prefixIcon: Icon(Icons.search),
                contentPadding: EdgeInsets.symmetric(vertical: 0),
                suffixIcon: IconButton(
                  iconSize: 20,
                  splashRadius: 15,
                  padding: EdgeInsets.zero,
                  icon: Icon(Icons.close),
                  onPressed: () {
                    _searchFieldController?.clear();
                    logic?.clearFilter();
                  },
                ),
              ),
              textInputAction: TextInputAction.go,
              onSubmitted: logic?.filterTrack,
              onChanged: logic?.filterTrack,
            ),
          ),
          SizedBox(width: 20),
          IconButton(
            icon: Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () {
              logic?.updateStatus(true);
              SgsAppService.get()!.sendEvent(ForceUpdateTracksEvent(genomeTrack: false, scTrack: true));
            },
          ),
        ],
      ),
    );
  }

  Widget _titleBar() {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      height: 30,
      child: Row(
        children: [
          SizedBox(width: 8),
          Text('Single Cell'),
          SizedBox(width: 20),
          CellTrackSelectorWidget(),
        ],
      ),
    );
  }

  Widget _wrap(Widget body) {
    if (widget.asPage) {
      return Scaffold(
        appBar: AppBar(title: Text('Single Cell')),
        body: body,
      );
    }
    return body;
  }

  Widget _buildErrorWidget() {
    return LoadingWidget(
      loadingState: LoadingState.noData,
      icon: SvgPicture.string(
        iconEmpty,
        width: 80,
        height: 80,
        colorFilter: ColorFilter.mode(Theme.of(context).textTheme.bodyMedium!.color!, BlendMode.srcIn),
      ),
      message: 'No single-cell data',
    );
  }

  Widget _trackCardItemBuilder(BuildContext context, Track e) {
    // Track e = SgsAppService.get()!.scTracks[index];
    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color: Theme.of(context).dividerColor)),
      onTap: () => logic!.changeTrack(e),
      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      title: Text('${e.scName}'),
      enabled: e.statusDone,
      isThreeLine: true,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            child: Text('${e.matrixList?.length} Mod', style: TextStyle(color: Colors.white, fontSize: 12)),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Theme.of(context).colorScheme.primary.withAlpha(200),
            ),
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          ),
          // Icon(Icons.keyboard_arrow_right_rounded),
        ],
      ),
      subtitle: Text('ID: ${e.scId}'),
    );
  }

  Widget _trackItemBuilder(BuildContext context, Track e) {
    // Track e = SgsAppService.get()!.scTracks[index];
    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
      onTap: () => logic!.changeTrack(e),
      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      title: Text('${e.scName}'),
      enabled: e.statusDone,
      isThreeLine: true,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            child: Text('${e.matrixList?.length} Mod', style: TextStyle(color: Colors.white, fontSize: 12)),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Theme.of(context).colorScheme.primary.withAlpha(200),
            ),
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          ),
          // Icon(Icons.keyboard_arrow_right_rounded),
        ],
      ),
      subtitle: Text('scId: ${e.scId}'),
    );
  }

  Widget _buildTrackList(BoxConstraints constraints, CellPageLogic logic) {
    List<Track> tracks = logic.scTracks;
    int columns = constraints.maxWidth ~/ 400;
    double padding = 15;
    var itemWidth = (constraints.maxWidth - padding * (columns + 1)) / columns;
    var height = 80;
    return columns > 1
        ? GridView.builder(
            padding: EdgeInsets.only(left: padding, right: padding, top: padding, bottom: padding),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              mainAxisSpacing: 20,
              crossAxisSpacing: padding,
              childAspectRatio: itemWidth / height,
            ),
            itemBuilder: (BuildContext c, int i) => _trackCardItemBuilder(c, tracks[i]),
            itemCount: tracks.length,
          )
        : ListView.separated(
            itemCount: tracks.length,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            separatorBuilder: (c, i) {
              return Divider(height: 1, thickness: 1);
            },
            itemBuilder: (BuildContext c, int i) => _trackItemBuilder(c, tracks[i]),
          );
  }

  Column _buildEmptyWidget(bool _dark, BuildContext context, CellPageLogic logic) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Spacer(),
        Text(
          'No single-cell track',
          style: Theme.of(context).textTheme.bodySmall!.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
        ),
        Text(
          'Your can select local cord file to view.',
          style: Theme.of(context).textTheme.bodySmall!.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w300,
              ),
        ),
        SizedBox(height: 30),
        Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: 200, maxWidth: 400),
            child: LocalCellCordSelector(
              onSubmit: (files) {
                // print('${files}');
                CellPageLogic.safe()?.onNativeFileSelected(files['cord'], files['meta']);
              },
            ),
          ),
        ),

        // OutlinedButton.icon(
        //   onPressed: () async {
        //     logic.cordFile = await FileUtil.selectFile();
        //     logic.update();
        //   },
        //   icon: Icon(Icons.file_upload_outlined),
        //   label: Text('Cord File'),
        // ),
        // SizedBox(height: 10),
        // OutlinedButton.icon(
        //   onPressed: () async {
        //     logic.metaFile = await FileUtil.selectFile();
        //     logic.update();
        //   },
        //   icon: Icon(Icons.file_upload_outlined),
        //   label: Text('Meta File'),
        // ),
        // SizedBox(height: 20),
        // Padding(
        //   padding: const EdgeInsets.symmetric(horizontal: 30),
        //   child: OutlinedButton.icon(
        //     style: OutlinedButton.styleFrom(
        //       side: BorderSide(color: Theme.of(context).colorScheme.primary, width: .8),
        //     ),
        //     icon: Icon(MaterialCommunityIcons.language_r),
        //     onPressed: logic.openRStudio,
        //     label: Text('Open R'),
        //   ),
        // ),
        Spacer(flex: 2),
      ],
    );
  }

  Widget buildSingleCell(BuildContext context, BoxConstraints constraints, CellPageLogic logic);
}
