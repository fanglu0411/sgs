import 'package:bot_toast/bot_toast.dart';
import 'package:dio/dio.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:flutter_smart_genome/widget/basic/chips_input.dart';
import 'package:flutter_smart_genome/widget/basic/custom_spin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/page/cell/cell_page/cell_page_logic.dart';
import 'package:flutter_smart_genome/service/sgs_app_service.dart';
import 'package:flutter_smart_genome/service/single_cell_service.dart';
import 'package:flutter_smart_genome/util/debouncer.dart';
import 'package:flutter_smart_genome/widget/basic/custom_bot_widget.dart';

class FeatureSearchInput extends StatefulWidget {
  final ValueChanged<List<Map>>? onChange;
  final VoidCallback? onCollapse;
  final bool showCollapse;
  final VoidCallback? onTapOutside;

  FeatureSearchInput({
    super.key,
    this.onChange,
    this.showCollapse = false,
    this.onCollapse,
    this.onTapOutside,
  });

  @override
  State<FeatureSearchInput> createState() => _FeatureSearchInputState();
}

class _FeatureSearchInputState extends State<FeatureSearchInput> {
  late Debounce searchDebounce;

  CancelFunc? featureListDismiss;

  late TextEditingController _controller;
  CancelToken? _cancelToken;

  List<Map> _features = [];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    searchDebounce = Debounce(milliseconds: 350);
  }

  debounceSearch(BuildContext context, String keyword) {
    var _keyword = keyword.trim();
    if (_keyword.length == 0) {
      featureListDismiss?.call();
    } else {
      searchDebounce.run(() => _search(context, _keyword));
    }
  }

  _search(BuildContext context, String keyword) async {
    _showFeatureListPop(context, loading: true);
    var site = SgsAppService.get()!.site;
    _cancelToken?.cancel('user-interrupt');
    _cancelToken = CancelToken();
    var resp = await searchGeneByKeyword(
      host: site!.url,
      track: CellPageLogic.safe()!.track!,
      matrixId: CellPageLogic.safe()!.currentChartLogic.state.mod!.id,
      keyword: keyword,
      cancelToken: _cancelToken,
    );
    if (resp.success) {
      Map body = resp.body;
      List _features = body['match_features'] ?? {};
      List<Map> features = _features.map((e) {
        Map m = e as Map;
        var entry = m.entries.first;
        return {'name': entry.key, 'id': entry.value};
      }).toList();
      _showFeatureListPop(context, data: features, error: features.length > 0 ? null : 'Search Empty!');
    } else {
      if (!(resp.error!.type == DioExceptionType.cancel)) {
        _showFeatureListPop(context, error: resp.error!.message);
      }
    }
  }

  _showFeatureListPop(BuildContext context, {List<Map> data = const [], String? error, bool loading = false}) {
    featureListDismiss?.call();
    featureListDismiss = showAttachedWidget(
        targetContext: context,
        preferDirection: PreferDirection.bottomLeft,
        backgroundColor: Colors.transparent,
        attachedBuilder: (call) {
          Widget? errorWidget = loading
              ? Center(
                  child: Wrap(
                    spacing: 10,
                    children: [
                      CustomSpin(size: 22, color: Theme.of(context).colorScheme.primary),
                      // CustomSpin(radius: 10),
                      // Text('Loading'),
                    ],
                  ),
                )
              : (error != null ? Container(child: Text(error), alignment: Alignment.center) : null);
          return Material(
            elevation: 6,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 240, maxHeight: error != null || loading ? 100 : 400),
              child: errorWidget ?? ChipOptionList(options: data, selectedList: _features, onFeatureTap: _onOptionFeatureTap),
            ),
          );
        });
  }

  void _onOptionFeatureTap(Map feature) {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      Widget field = ChipsInput<Map>(
        values: _features,
        decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 10),
            constraints: BoxConstraints(maxWidth: 350, minHeight: 30, maxHeight: 36),
            prefixIcon: widget.showCollapse
                ? IconButton(
                    icon: Icon(Icons.arrow_forward_ios_rounded),
                    constraints: BoxConstraints.tightFor(width: 30, height: 30),
                    padding: EdgeInsets.zero,
                    tooltip: 'Collapse',
                    iconSize: 16,
                    onPressed: () {
                      widget.onCollapse?.call();
                    },
                  )
                : Icon(Icons.search, size: 18),
            hintText: 'search gene',
            filled: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(5), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(5), borderSide: BorderSide.none),
            suffixIcon: _features.length > 0
                ? IconButton(
                    icon: Icon(AntDesign.enter),
                    constraints: BoxConstraints.tightFor(width: 30, height: 30),
                    padding: EdgeInsets.zero,
                    tooltip: 'Confirm',
                    iconSize: 16,
                    onPressed: () {
                      if (_features.length > 0) widget.onChange?.call(_features);
                      // _features.clear();
                      // setState(() {});
                      // debounceSearch(context, '');
                    },
                  )
                : null),
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 14),
        strutStyle: const StrutStyle(fontSize: 14),
        onChanged: (list) {
          // print(list);
        },
        onSubmitted: (v) {
          if (v.length == 0) {
            widget.onChange?.call(_features);
          } else {
            debounceSearch(context, v);
          }
        },
        chipBuilder: _chipBuilder,
        onTextChanged: (v) {
          debounceSearch(context, v);
        },
        onTap: () {
          _showFeatureListPop(context, data: _features);
        },
        onTapOutside: (d) {
          // widget.onCollapse?.call();
        },
      );
      // Widget field2 = TextField(
      //   controller: _controller,
      //   decoration: InputDecoration(
      //       contentPadding: EdgeInsets.symmetric(horizontal: 4),
      //       constraints: BoxConstraints(maxWidth: 200, minHeight: 36, maxHeight: 40),
      //       filled: true,
      //       border: OutlineInputBorder(borderRadius: BorderRadius.circular(5), borderSide: BorderSide.none),
      //       focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(5), borderSide: BorderSide.none),
      //       hintText: 'search gene',
      //       prefixIcon: Icon(Icons.search_rounded, size: 20),
      //       hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
      //       suffixIcon: _controller.text.length > 0
      //           ? IconButton(
      //               icon: Icon(Icons.clear),
      //               constraints: BoxConstraints.tightFor(width: 30, height: 30),
      //               padding: EdgeInsets.zero,
      //               iconSize: 16,
      //               onPressed: () {
      //                 _controller.text = '';
      //                 setState(() {});
      //                 debounceSearch(context, '');
      //               },
      //             )
      //           : null),
      //   cursorColor: Theme.of(context).textTheme.bodyMedium!.color,
      //   cursorWidth: 1,
      //   cursorHeight: 14,
      //   onChanged: (v) {
      //     setState(() {});
      //     debounceSearch(context, v);
      //   },
      //   onSubmitted: (v) {
      //     if (v.length == 0) {
      //       if (_features.length > 0) widget.onChange?.call(_features);
      //     } else {
      //       debounceSearch(context, v);
      //     }
      //   },
      // );
      // if (widget.showCollapse) {
      //   field = Row(
      //     mainAxisSize: MainAxisSize.min,
      //     children: [
      //       ElevatedButton(
      //         onPressed: () {},
      //         child: Icon(Icons.arrow_forward_ios_rounded),
      //         style: ElevatedButton.styleFrom(
      //           minimumSize: Size(30, 36),
      //           padding: EdgeInsets.symmetric(horizontal: 4),
      //         ),
      //       ),
      //       // IconButton(
      //       //   padding: EdgeInsets.zero,
      //       //   constraints: BoxConstraints.tightFor(width: 36, height: 32),
      //       //   icon: Icon(Icons.arrow_forward_ios_rounded),
      //       //   onPressed: widget.onCollapse,
      //       //   tooltip: 'Collapse',
      //       // ),
      //       field,
      //     ],
      //   );
      // }
      return field;
    });
  }

  Widget _chipBuilder(BuildContext context, Map data) {
    return Container(
      margin: const EdgeInsets.only(right: 3),
      child: InputChip(
        key: ObjectKey(data),
        label: Text(data['name'] ?? data['id'] ?? '-', style: Theme.of(context).textTheme.bodySmall),
        labelPadding: EdgeInsets.zero,
        side: BorderSide.none,
        elevation: 0,
        onDeleted: () {
          _features.remove(data);
          setState(() {});
          if (_features.length == 0) widget.onChange?.call(_features);
        },
        // onSelected: (bool value) {},
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        padding: const EdgeInsets.only(left: 6),
      ),
    );
  }
}

class ChipOptionList extends StatefulWidget {
  final List<Map> options;
  final List<Map> selectedList;
  final ValueChanged<Map>? onFeatureTap;

  const ChipOptionList({
    super.key,
    required this.options,
    this.selectedList = const [],
    this.onFeatureTap,
  });

  @override
  State<ChipOptionList> createState() => _ChipOptionListState();
}

class _ChipOptionListState extends State<ChipOptionList> {
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      itemCount: widget.options.length,
      separatorBuilder: (c, i) => Divider(height: 1, thickness: 1),
      itemBuilder: (c, i) {
        Map item = widget.options[i];
        bool selected = widget.selectedList.contains(widget.options[i]);
        return ListTile(
          title: Text(item['name'] ?? ''),
          subtitle: Text(item['id'] ?? ''),
          selected: selected,
          trailing: selected ? Icon(Icons.check) : null,
          onTap: () => _onOptionFeatureTap(widget.options[i]),
        );
      },
    );
  }

  void _onOptionFeatureTap(Map feature) {
    if (widget.selectedList.contains(feature)) {
      widget.selectedList.remove(feature);
    } else {
      widget.selectedList.add(feature);
    }
    setState(() {});
    widget.onFeatureTap?.call(feature);
  }
}
