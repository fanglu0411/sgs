import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter_smart_genome/widget/basic/custom_spin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/bloc/sgs_context/sgs_browse_logic.dart';
import 'package:flutter_smart_genome/service/sgs_app_service.dart';
import 'package:flutter_smart_genome/side/search/search_in_track_logic.dart';
import 'package:flutter_smart_genome/widget/loading_widget.dart';
import 'package:flutter_smart_genome/widget/track/base/track_data.dart';
import 'package:get/get.dart';

class TrackSearchWidget extends StatefulWidget {
  final Track track;
  final String keyword;

  const TrackSearchWidget({Key? key, required this.track, required this.keyword}) : super(key: key);

  @override
  State<TrackSearchWidget> createState() => _TrackSearchWidgetState();
}

class _TrackSearchWidgetState extends State<TrackSearchWidget> {
  late SearchInTrackLogic _logic;
  late String _keyword;

  @override
  void initState() {
    super.initState();
    _keyword = widget.keyword;
    _logic = SearchInTrackLogic.get(widget.track)!;
    _logic.track = widget.track;
    _logic.search(widget.keyword);
  }

  @override
  void didUpdateWidget(covariant TrackSearchWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.keyword != _keyword || widget.track != _logic.track) {
      _keyword = widget.keyword;
      Future.delayed(Duration(milliseconds: 200)).then((v) {
        _logic.track = widget.track;
        _logic.search(_keyword);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget title = widget.track.parent != null ? Text('${widget.track.parent!.name}', style: Theme.of(context).textTheme.bodySmall) : Text('${widget.track.name}');
    Widget? subtitle = widget.track.parent != null ? Text('${widget.track.name}') : null;
    return GetBuilder<SearchInTrackLogic>(
      init: _logic,
      tag: widget.track.id,
      id: widget.track.id,
      autoRemove: false,
      builder: (logic) {
        return ExpansionTileCard(
          contentPadding: EdgeInsets.symmetric(horizontal: 6),
          // horizontalTitleGap: 4,
          leading: _logic.loading ? CustomSpin(color: Theme.of(context).colorScheme.primary) : null,
          title: title,
          subtitle: subtitle,
          initiallyExpanded: true,
          children: [
            if (_logic.loading)
              Container(
                  child: LoadingWidget(
                loadingState: LoadingState.loading,
                message: 'searching',
              ))
            else if (_logic.error != null)
              Container(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: LoadingWidget(
                  loadingState: LoadingState.error,
                  color: Theme.of(context).colorScheme.error,
                  message: '${_logic.error}',
                ),
              )
            else if (_logic.dataEmpty)
              Container(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: LoadingWidget(
                  loadingState: LoadingState.noData,
                  color: Theme.of(context).colorScheme.tertiaryContainer,
                  message: 'no result found',
                  simple: true,
                ),
              )
            else
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildResultList(),
                  // PaginationWidget(
                  //   totalCount: _logic.count,
                  //   pageSize: _logic.pageSize,
                  //   page: logic.page,
                  //   onPageChange: _logic.onPageChange,
                  // ),
                  // SizedBox(height: 4),
                ],
              ),
          ],
        );
      },
    );
  }

  ListView _buildResultList() {
    return ListView.separated(
      shrinkWrap: true,
      itemBuilder: _itemBuilder,
      itemCount: _logic.data!.length,
      separatorBuilder: (c, i) => Divider(height: 1, thickness: 1),
    );
  }

  Widget _itemBuilder(BuildContext context, int i) {
    var item = _logic.data![i];
    final chr = SgsAppService.get()!.chr1;
    return ListTile(
      dense: true,
      title: Text('${item.featureName}'),
      subtitle: Text('${chr?.chrName}: ${item.start}..${item.end}'),
      onTap: () {
        SgsBrowseLogic.safe()?.jumpToPosition(chr!.id, item.range, context, track: widget.track);
      },
    );
  }
}
