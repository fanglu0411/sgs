import 'package:bot_toast/bot_toast.dart';
import 'package:dartx/dartx.dart' as dx;
import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/base/container_config.dart';
import 'package:flutter_smart_genome/page/chromosome_list/chromosome_list_page.dart';
import 'package:flutter_smart_genome/service/sgs_app_service.dart';
import 'package:flutter_smart_genome/util/device_info.dart';
import 'package:flutter_smart_genome/widget/basic/custom_bot_widget.dart';
import 'package:flutter_smart_genome/widget/track/chromosome/chromosome_data.dart';
import 'package:flutter_smart_genome/widget/track/common.dart';
import 'dart:math' show min, max;

class ChrPositionInputField extends StatefulWidget {
  final ChromosomeData? chr;
  final Range? range;
  final dx.Function2<ChromosomeData, Range, void>? onChangePosition;
  final ValueChanged<Range>? onSubmit;
  final ValueChanged<String>? onSearch;
  final dx.Function2<ChromosomeData, Range, void>? onChrChange;
  final PreferDirection? preferDirection;

  const ChrPositionInputField({
    Key? key,
    required this.chr,
    this.range,
    this.onSubmit,
    this.onSearch,
    this.onChrChange,
    this.onChangePosition,
    this.preferDirection = PreferDirection.bottomLeft,
  }) : super(key: key);

  @override
  _ChrPositionInputFieldState createState() => _ChrPositionInputFieldState();
}

class _ChrPositionInputFieldState extends State<ChrPositionInputField> {
  late TextEditingController _textEditingController;

  String? _value;
  late RegExp _regExp;
  late RegExp _searchKeywordRegExp;
  bool showCharList = false;
  Range? _range;

  CancelFunc? _chrDialog;

  ChromosomeData? _chromosome;

  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _chromosome = widget.chr;
    _range = widget.range;
    _regExp = RegExp('([^:]+):([0-9,]+)*-([0-9,]+)');
    _searchKeywordRegExp = RegExp('([0-9a-zA-Z:-]+)');
    _value = '${_chromosome?.chrName}:${_range?.print2('-')}';
    _textEditingController = TextEditingController(text: _value);
    _textEditingController.addListener(_checkShowChrList);
    _scrollController = ScrollController();
  }

  _checkShowChrList() {
    if (_autoUpdate) {
      _autoUpdate = false;
      return;
    }
    var start = _textEditingController.selection.start;
    var selEnd = _textEditingController.selection.end;
    int selLength = selEnd - start;
    if (selLength > 0 || (start == -1 && selEnd == -1)) return;
    var text = _textEditingController.text;
    var _showCharList = selLength == 0 && start > 0 && (text.length == 0 || start <= text.indexOf(':'));
    showCharList = _showCharList;
    if (_showCharList) {
      if (_chrDialog == null) _showChrListPop();
    } else {
      _chrDialog?.call();
      _chrDialog = null;
    }
  }

  bool _autoUpdate = true;

  double _width = 300;

  @override
  void didUpdateWidget(ChrPositionInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    _chromosome = widget.chr;
    if (widget.range != null && widget.range!.isValid) {
      _range = widget.range;
      _value = '${_chromosome?.chrName}:${_range?.print2('-')}';
    }
    _focusNode.unfocus();
    _autoUpdate = true;
    _textEditingController.text = _value!;
  }

  _showChrListPop() {
    List<ChromosomeData> chrs = SgsAppService.get()!.chromosomes ?? [];
    var _sh = MediaQuery.of(context).size.height;
    if (chrs.length == 0 || _chromosome == null) return;
    _chrDialog = showAttachedWidget(
      targetContext: context,
      preferDirection: widget.preferDirection ?? PreferDirection.bottomLeft,
      onClose: () {
        _chrDialog = null;
      },
      attachedBuilder: (c) {
        double height = (chrs.length * 30.0);
        List list = [min(height, 60.0), 600.0, _sh * .75]..sort();
        height = height.clamp(list.first, _sh * .75) as double;
        return Material(
          elevation: 6,
          shape: modelShape(),
          color: Theme.of(context).dialogBackgroundColor,
          child: Container(
            constraints: BoxConstraints.tightFor(width: _width, height: height),
            child: _buildChrList(chrs, c),
          ),
        );
      },
    );
  }

  String? _validate(String v) {
    if (_regExp.hasMatch(v)) return null;
    return 'input format not valid!(chrName:start-end)';
  }

  Widget _buildChrList(List<ChromosomeData> chrs, CancelFunc cancel) {
    List<num> sizeList = (chrs ?? []).map<num>((e) => e.range.size).toList();
    var _maxSize = sizeList.length > 0 ? sizeList.reduce(max) : 0;
    return Scrollbar(
      controller: _scrollController,
      thickness: 8,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 10),
        controller: _scrollController,
        separatorBuilder: (c, i) => Divider(height: 1, thickness: 1, color: Theme.of(context).dividerColor),
        itemBuilder: (c, i) {
          double progress = _maxSize != null ? chrs[i].range.size / _maxSize : 0;
          return CustomPaint(
            painter: ProgressPainter(progress: progress, color: Theme.of(context).colorScheme.primary.withAlpha(190)),
            child: ListTile(
              title: Text('${chrs[i].chrName}'),
              contentPadding: EdgeInsets.symmetric(horizontal: 0),
              minLeadingWidth: 18,
              horizontalTitleGap: 4,
              leading: _chromosome?.id == chrs[i].id ? Icon(Icons.check_circle, size: 18, color: Theme.of(context).colorScheme.primary) : SizedBox(width: 14),
              dense: true,
              visualDensity: VisualDensity(vertical: VisualDensity.minimumDensity),
              trailing: Text('${chrs[i].sizeStr}', style: Theme.of(context).textTheme.labelSmall),
              onTap: () {
                if (_chromosome!.id == chrs[i].id) return;
                _chromosome = chrs[i];
                if (_range!.end > _chromosome!.rangeEnd) {
                  _range = _range!.copy(end: _chromosome!.rangeEnd);
                }
                if (_range!.start > _chromosome!.rangeEnd) {
                  _range = _range!.copy(start: 0);
                }
                var text = '${_chromosome!.chrName}:${_range!.print('-')}';
                int cursor = text.indexOf(":");
                _textEditingController.value = _textEditingController.value.copyWith(
                  text: text,
                  selection: TextSelection(baseOffset: cursor, extentOffset: cursor),
                  composing: TextRange.empty,
                );
                widget.onChrChange?.call(_chromosome!, _range!);
                cancel.call();
              },
            ),
          );
        },
        itemCount: chrs.length,
      ),
    );
  }

  late FocusNode _focusNode;

  bool get _mobileDevice => DeviceOS.isMobile;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (c, constraints) {
      _width = constraints.maxWidth;
      return Container(
        height: 32,
        child: TextField(
          maxLines: 1,
          minLines: 1,
          // focusNode: _focusNode,
          controller: _textEditingController,
          style: TextStyle(fontWeight: FontWeight.w300, fontSize: 14, fontFamily: MONOSPACED_FONT, fontFamilyFallback: MONOSPACED_FONT_BACK),
          scrollPhysics: ClampingScrollPhysics(),
          decoration: InputDecoration(
            // errorText: _error,
            filled: true,
            // fillColor: Colors.white,
            hintText: 'chr:start-end or gene_id',
            contentPadding: EdgeInsets.only(left: 8),
            isDense: true,
            border: OutlineInputBorder(
              borderSide: BorderSide.none, //(width: .5),
              borderRadius: BorderRadius.circular(4),
            ),
            prefixIcon: _mobileDevice
                ? TextButton(
                    onPressed: _showChrListPop,
                    style: TextButton.styleFrom(
                      minimumSize: Size(30, 24),
                    ),
                    child: Text('${_chromosome?.chrName}', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                  )
                : null,
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  iconSize: 16,
                  splashRadius: 10,
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints.tightFor(width: 24, height: 20),
                  icon: Icon(Icons.clear),
                  tooltip: 'clear',
                  onPressed: () {
                    _textEditingController.text = '';
                  },
                ),
                MaterialButton(
                  minWidth: 30,
                  elevation: 0,
                  focusElevation: 0,
                  textColor: Theme.of(context).colorScheme.primary,
                  onPressed: _onSubmit,
                  child: Text('GO'),
                ),
              ],
            ),
          ),
          onTap: _checkShowChrList,
          // onChanged: (v) {},
          onSubmitted: (v) {
            _onSubmit();
          },
        ),
      );
    });
  }

  _onSubmit() {
    var text = _textEditingController.text;
    if (_regExp.hasMatch(text)) {
      RegExpMatch? m = _regExp.firstMatch(text);
      print(m!.groupCount);
      String chr = m.group(1)!;
      String start = m.group(2)!.replaceAll(',', '');
      String end = m.group(3)!.replaceAll(',', '');
      // print('CHR: ${chr}: ${start}-${end}');

      List<ChromosomeData> chrs = SgsAppService.get()!.chromosomes!;
      ChromosomeData? _chr = chrs.firstOrNullWhere((c) => c.chrName == chr);
      if (_chr == null) {
        showToast(text: 'Chr name「${chr}」not found', align: Alignment(0, -.75));
        return;
      }
      _range = _range!.copy(start: num.tryParse(start), end: num.tryParse(end));
      if (_range!.size == 0) {
        showToast(text: 'end must greater than start', align: Alignment(0, -.75));
        return;
      }
      if (_chromosome!.id == _chr.id) {
        widget.onChangePosition?.call(_chr, _range!);
      } else {
        // widget.onSubmit?.call(_range);
        widget.onChrChange?.call(_chr, _range!);
      }
    } else if (_searchKeywordRegExp.hasMatch(text)) {
      RegExpMatch m = _searchKeywordRegExp.firstMatch(text)!;
      String keyword = m.group(1)!;
      widget.onSearch?.call(keyword);
    } else {
      showToast(
        text: 'input format not valid! ( ChrName:start-end )',
        align: Alignment(0, -.75),
        duration: Duration(seconds: 5),
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
    _textEditingController.dispose();
  }
}
