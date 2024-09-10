import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:flutter_smart_genome/page/cell/cell_page/cell_page_logic.dart';
import 'package:flutter_smart_genome/service/sgs_app_service.dart';
import 'package:flutter_smart_genome/widget/basic/custom_bot_widget.dart';
import 'package:flutter_smart_genome/widget/track/base/track_data.dart';
import 'package:get/get.dart';

class CellTrackSelectorLogic extends GetxController {
  static CellTrackSelectorLogic? get() {
    if (Get.isRegistered<CellTrackSelectorLogic>()) {
      return Get.find<CellTrackSelectorLogic>();
    }
    return null;
  }

  Track? _currentTrack;

  @override
  void onReady() {
    super.onReady();
    _currentTrack = CellPageLogic.safe()?.track;
  }

  void setTrack() {
    Future.delayed(Duration(milliseconds: 300)).then((value) {
      _currentTrack = CellPageLogic.safe()?.track;
      update();
    });
  }

  void onChangeTrack(Track? track) async {
    _currentTrack = track;
    update();

    await Future.delayed(Duration(milliseconds: 200));
    CellPageLogic.safe()?.changeTrack(track!);
  }

  void resetTracks() {
    _currentTrack = CellPageLogic.safe()?.track;
    update();
  }

  void clearTrack() {
    CellPageLogic.safe()?.changeTrack(null);
    _currentTrack = CellPageLogic.safe()?.track;
    update();
  }
}

class CellTrackSelectorWidget extends StatefulWidget {
  final Widget? prefix;

  const CellTrackSelectorWidget({Key? key, this.prefix}) : super(key: key);

  @override
  State<CellTrackSelectorWidget> createState() => _CellTrackSelectorWidgetState();
}

class _CellTrackSelectorWidgetState extends State<CellTrackSelectorWidget> {
  Widget _build(CellTrackSelectorLogic logic) {
    // List<Track> tracks = (SgsAppService.get()!.tracks ?? []).where((e) => e.isSCTrack).toList();
    List<Track> tracks = (SgsAppService.get()!.scTracks);

    List<DropdownMenuItem<Track>> items = tracks.map((e) {
      return DropdownMenuItem<Track>(
        value: e,
        child: Text('${e.scName}', style: Theme.of(context).textTheme.bodyMedium),
      );
    }).toList();

    List<Widget> _selectedBuilder(BuildContext c) {
      return tracks.map((e) {
        return DropdownMenuItem<Track>(
          value: e,
          child: Text('${e.scName}', style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w500)),
        );
      }).toList();
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.prefix != null) widget.prefix!,
        Container(
          height: 28,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: Theme.of(context).colorScheme.primary.withAlpha(25),
          ),
          padding: EdgeInsets.symmetric(vertical: 0, horizontal: 6),
          margin: EdgeInsets.symmetric(horizontal: 10),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<Track>(
              hint: Text('select single-cell'),
              isDense: true,
              iconEnabledColor: Theme.of(context).colorScheme.primary,
              items: items,
              selectedItemBuilder: _selectedBuilder,
              value: logic._currentTrack,
              onChanged: logic.onChangeTrack,
            ),
          ),
        ),
      ],
    );
  }

  Widget _build2(CellTrackSelectorLogic logic) {
    // List<Track> tracks = (SgsAppService.get()!.tracks ?? []).where((e) => e.isSCTrack).toList();
    List<Track> tracks = (SgsAppService.get()!.scTracks);

    List<PopupMenuItem<Track>> items = tracks.map((e) {
      return PopupMenuItem<Track>(
        value: e,
        child: Text('${e.scName} (${e.matrixList?.length} mods)'),
      );
    }).toList();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.prefix != null) widget.prefix!,
        if (widget.prefix != null) SizedBox(width: 10),
        PopupMenuButton<Track>(
          padding: EdgeInsets.zero,
          itemBuilder: (c) => items,
          tooltip: 'Change single cell data',
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          initialValue: logic._currentTrack,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: Theme.of(context).colorScheme.primary.withAlpha(55),
            ),
            padding: EdgeInsets.symmetric(vertical: 4, horizontal: 6),
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 4,
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 400),
                  child: Text('${logic._currentTrack?.name ?? 'select sc'}', overflow: TextOverflow.ellipsis),
                ),
                Icon(Icons.expand_more, size: 16, color: Theme.of(context).colorScheme.primary),
              ],
            ),
          ),
          onSelected: logic.onChangeTrack,
        ),
        SizedBox(width: 10),
        if (logic._currentTrack != null)
          IconButton(
            onPressed: logic.clearTrack,
            constraints: BoxConstraints.tightFor(width: 30, height: 30),
            padding: EdgeInsets.zero,
            iconSize: 16,
            icon: Icon(Icons.clear),
            tooltip: 'Clear SC',
          ),
      ],
    );
  }

  Widget _build3(CellTrackSelectorLogic logic) {
    return Row(
      children: [
        Builder(builder: (context) {
          return TextButton(
            onPressed: () => _showScTrackListPop(context, logic),
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 4,
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 400),
                  child: Text('${logic._currentTrack?.name ?? 'select sc'}', overflow: TextOverflow.ellipsis),
                ),
                Icon(Icons.expand_more, size: 16, color: Theme.of(context).colorScheme.primary),
              ],
            ),
          );
        }),
        if (logic._currentTrack != null)
          IconButton(
            onPressed: logic.clearTrack,
            constraints: BoxConstraints.tightFor(width: 30, height: 30),
            padding: EdgeInsets.zero,
            iconSize: 16,
            icon: Icon(Icons.clear),
            tooltip: 'Clear SC',
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CellTrackSelectorLogic>(
      init: CellTrackSelectorLogic(),
      autoRemove: false,
      builder: _build3,
    );
  }

  @override
  void initState() {
    super.initState();
    CellTrackSelectorLogic.get()?.setTrack();
  }

  void _showScTrackListPop(BuildContext context, CellTrackSelectorLogic logic) {
    showAttachedWidget(
        preferDirection: PreferDirection.topLeft,
        targetContext: context,
        attachedBuilder: (cancel) {
          List<Track> tracks = (SgsAppService.get()!.scTracks);
          RenderObject renderObject = context.findRenderObject()!;
          double targetBottom = 100;
          if (renderObject is RenderBox) {
            final position = renderObject.localToGlobal(Offset.zero);
            targetBottom = position.dy + 50;
          }
          double maxHeight = MediaQuery.of(context).size.height - targetBottom;
          double h = (tracks.length * 41.0).clamp(40, maxHeight);
          return Material(
            borderRadius: BorderRadius.circular(10),
            shadowColor: Theme.of(context).colorScheme.primary,
            // borderOnForeground: false,
            elevation: 6,
            child: Container(
              constraints: BoxConstraints(maxWidth: 500, minWidth: 400, maxHeight: h),
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: tracks.length == 0
                  ? _emptyView()
                  : CustomScrollView(
                      slivers: [
                        SliverList.separated(
                          itemCount: tracks.length,
                          itemBuilder: (c, i) {
                            Track t = tracks[i];
                            bool selected = t.scId == logic._currentTrack?.scId;
                            return ListTile(
                              dense: true,
                              minVerticalPadding: 0,
                              selected: selected,
                              enabled: (t.matrixList?.length ?? 0) > 0,
                              trailing: Text('Mod: ${t.matrixList?.length}'),
                              title: Text(t.name),
                              onTap: (t.matrixList?.length ?? 0) == 0
                                  ? null
                                  : () {
                                      cancel();
                                      logic.onChangeTrack(t);
                                    },
                            );
                          },
                          separatorBuilder: (c, i) => Divider(height: 1),
                        ),
                      ],
                    ),
            ),
          );
        });
  }

  Widget _emptyView() {
    return Center(child: Text('No Single-Cell Data'));
  }
}
