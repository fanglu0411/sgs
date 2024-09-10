import 'package:flutter_smart_genome/widget/basic/alert_widget.dart';
import 'package:flutter_smart_genome/widget/basic/custom_spin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/base/container_config.dart';
import 'package:flutter_smart_genome/bloc/sgs_context/sgs_browse_logic.dart';
import 'package:flutter_smart_genome/network/core/http_error.dart';
import 'package:flutter_smart_genome/service/sgs_app_service.dart';
import 'package:flutter_smart_genome/side/search/track_search_widget.dart';
import 'package:flutter_smart_genome/widget/basic/scroll_controller_builder.dart';
import 'package:flutter_smart_genome/widget/track/base/track_data.dart';
import 'package:flutter_smart_genome/widget/track/common.dart';
import 'package:flutter_smart_genome/widget/track/cross_overlay/cross_overlay_logic.dart';
import 'package:get/get.dart';
import 'package:flutter_smart_genome/extensions/widget_extensions.dart';

class SearchGeneItem {
  String? chrId;
  String? geneId;
  String? trackId;
  num? start;
  num? end;

  ///
  SearchGeneItem.fromMap(Map map) {
    chrId = map['chr_id'];
    geneId = map['gene_id'];
    trackId = map['track_id'];
    start = map['start'];
    end = map['end'];
  }

  Range get range => Range(start: start!, end: end!);
}

class SearchSideLogic extends GetxController {
  static SearchSideLogic? safe() {
    if (Get.isRegistered<SearchSideLogic>()) {
      return Get.find<SearchSideLogic>();
    }
    return null;
  }

  HttpError? _error;
  bool _loading = false;

  bool get loading => _loading;

  String _searchType = 'gff';

  String get searchType => _searchType;

  void setSearchType(String? type) {
    _searchType = type!;
    update();
  }

  HttpError? get error => _error;
  List<SearchGeneItem>? _data = null;
  TextEditingController? textController;
  String? keyword;
  bool searchAllTrack = false;

  List<SearchGeneItem>? get data => _data;

  bool get empty => _data?.isEmpty ?? true;

  bool get wrongState => _loading || _error != null;
  String? selectedId = null;

  @override
  void onInit() {
    super.onInit();
    textController = TextEditingController();
  }

  reset() {
    _data = null;
    _error = null;
    _loading = false;
    update();
  }

  search({String? keyword, inAllTrack = false}) async {
    if (keyword != null) textController!.text = keyword;
    searchAllTrack = inAllTrack;

    var _k = keyword ?? textController!.text;
    // if (_k.length == 1) {
    //   return;
    // }

    this.keyword = _k;
    _loading = true;
    update();
    // var speciesId = SgsAppService.get().session.speciesId;
    // var site = SgsAppService().site;
    // final resp = await SgsServiceDelegate.searchGene(host: site.url, speciesId: speciesId, keyword: keyword, count: 100);
    // // print(resp.body);
    // _loading = false;
    // if (resp.success) {
    //   _error = null;
    //   List genes = resp.body['genes'] ?? [];
    //   _data = genes.map((e) => SearchGeneItem.fromMap(e)).toList();
    // } else {
    //   _error = resp.message ?? 'Search error!';
    // }
    // selectedId = null;
    // update();
  }

  onItemTap(Track track, SearchGeneItem item, BuildContext context) {
    selectedId = item.geneId;
    update();

    CrossOverlayLogic.safe()?.setTarget(targetTrackId: track.id, targetId: item.geneId);
    SgsBrowseLogic.safe()?.jumpToPosition(item.chrId!, item.range, context, track: track);
  }
}

class SearchSide extends StatefulWidget {
  @override
  _SearchSideState createState() => _SearchSideState();
}

class _SearchSideState extends State<SearchSide> {
  SearchSideLogic _logic = Get.put(SearchSideLogic());

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // return Container(
    //   child: Column(
    //     children: [
    //       _searchField(),
    //       // if (_logic.wrongState) Expanded(child: _buildErrorState()),
    //       // if (_logic.wrongState) Expanded(flex: 2, child: SizedBox()),
    //       // if (!_logic.wrongState) Expanded(child: _buildResult()),
    //       if (_keyword != null) Expanded(child: _buildTrackSearchPanelList()),
    //     ],
    //   ),
    // );
    return GetBuilder<SearchSideLogic>(
      init: _logic,
      builder: (logic) {
        return Container(
          child: Column(
            children: [
              _searchField(),
              // if (_logic.wrongState) Expanded(child: _buildErrorState()),
              // if (_logic.wrongState) Expanded(flex: 2, child: SizedBox()),
              // if (!_logic.wrongState) Expanded(child: _buildResult()),
              if (_logic.keyword != null) Expanded(child: _buildTrackSearchPanelList()),
            ],
          ),
        );
      },
    );
  }

  Widget _searchField() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 4),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 4),
          child: TextFormField(
            controller: _logic.textController,
            decoration: InputDecoration(
              hintText: 'input keyword (feature id)',
              filled: true,
              constraints: BoxConstraints(maxHeight: 40),
              border: OutlineInputBorder(borderSide: BorderSide.none),
              contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 8),
              // prefixIcon: Icon(Icons.search),
              prefixIcon: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isDense: true,
                  style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 14),
                  icon: Icon(Icons.arrow_drop_down, size: 16),
                  items: ['gff', 'vcf'].map<DropdownMenuItem<String>>((e) => DropdownMenuItem(child: Text(e), value: e)).toList(),
                  onChanged: _logic.setSearchType,
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                  value: _logic.searchType,
                ),
              ),
              prefixIconConstraints: BoxConstraints.tightFor(),
              suffixIcon: IconButton(
                // icon: Icon(Icons.search),
                constraints: BoxConstraints.tightFor(width: 26, height: 26),
                iconSize: 18,
                icon: Icon(Icons.clear),
                padding: EdgeInsets.zero,
                splashRadius: 15,
                // onPressed: _search,
                onPressed: _clear,
              ),
            ),
            onEditingComplete: () {
              __search(false);
            },
            onFieldSubmitted: (v) {
              // _search();
              __search(false);
            },
          ),
        ),
        SizedBox(height: 10),
        if (_logic.keyword == null) AlertWidget.info(message: Text('Please input feature full name.'), margin: EdgeInsets.symmetric(horizontal: 10)),

        // Padding(
        //   padding: const EdgeInsets.symmetric(horizontal: 4),
        //   child: ButtonGroup(
        //     mainAxisSize: MainAxisSize.max,
        //     border: Border.symmetric(),
        //     // mainAxisAlignment: MainAxisAlignment.spaceAround,
        //     // divider: SizedBox(height: 26, child: VerticalDivider(width: 1.0, thickness: .5, color: Theme.of(context).colorScheme.primary)),
        //     children: [
        //       Text(' Search in '),
        //       Expanded(child: TextButton(onPressed: () => __search(true), child: Text('All track'))),
        //       Expanded(child: TextButton(onPressed: () => __search(false), child: Text('Checked'))),
        //     ],
        //   ),
        // ),
        // SizedBox(height: 10),
      ],
    );
  }

  void _clear() {
    _logic.textController!.text = "";
    _logic.keyword = null;
    _logic.update();
  }

  void __search(bool all) {
    // if (_controller.text.isEmpty) {
    //   _keyword = null;
    // } else {
    //   _keyword = _controller.text;
    // }
    // _searchAll = all;
    // setState(() {});
    _logic.search(inAllTrack: all);
  }

  Widget _buildErrorState() {
    return Container(
      child: Center(
        child: _logic.loading ? CustomSpin(color: Theme.of(context).colorScheme.primary) : Text(_logic.error!.message),
      ),
    );
  }

  Widget _buildTrackSearchPanelList() {
    List<Track> tracks = _logic.searchAllTrack ? SgsAppService.get()!.tracks : SgsAppService.get()!.selectedTracks;

    if (_logic.searchType == 'gff') {
      tracks = tracks.where((t) => t.trackType == TrackType.gff).toList();
    } else if (_logic.searchType == 'vcf') {
      tracks = tracks.where((t) => t.trackType == TrackType.vcf).toList();
    }

    if (tracks.length == 0) {
      return Container(
        alignment: Alignment.topCenter,
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.errorContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Wrap(
            spacing: 10,
            children: [
              Icon(Icons.warning_rounded),
              Text('No ${_logic.searchType} selected!'),
            ],
          ),
        ),
      );
    }

    List<Widget> _children = tracks.map(_buildTrackSearchCard).toList();
    return ListView(children: _children);
  }

  Widget _buildTrackSearchCard(Track track) {
    return TrackSearchWidget(track: track, keyword: _logic.keyword!);
  }

  Widget _buildResult() {
    if (_logic.data == null) {
      return Container();
    }
    if (_logic.data!.isEmpty) {
      return Container(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            'No Gene Found',
            style: Theme.of(context).textTheme.bodySmall!.copyWith(fontWeight: FontWeight.w800, fontSize: 14),
          ),
        ),
      );
    }
    var chrList = SgsAppService.get()!.chromosomes!;
    var tracks = SgsAppService.get()!.tracks;
    return ScrollControllerBuilder(builder: (c, controller) {
      var subStyle = TextStyle(height: 1.5, fontFamily: MONOSPACED_FONT, fontFamilyFallback: MONOSPACED_FONT_BACK);
      return ListView.builder(
        controller: controller,
        itemBuilder: (c, i) {
          SearchGeneItem item = _logic.data![i];
          var chr = chrList.firstWhereOrNull((chr) => chr.id == item.chrId);
          var track = tracks.firstWhereOrNull((t) => t.id == item.trackId);
          return ListTile(
            // dense: true,
            isThreeLine: true,
            selected: _logic.selectedId == item.geneId,
            contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
            title: Text(item.geneId!, style: TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text(
              'Track: ${track?.name}\nLocus: ${chr?.chrName}: ${item.start}..${item.end}',
              style: subStyle,
            ),
            onTap: () => _logic.onItemTap(track!, item, context),
          ).withBottomBorder(color: Get.theme.dividerColor);
        },
        itemCount: _logic.data!.length,
      );
    });
  }
}
