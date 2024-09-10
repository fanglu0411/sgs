import 'dart:async';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_genome/base/container_config.dart';
import 'package:flutter_smart_genome/components/sequence/sequence_widget.dart';
import 'package:flutter_smart_genome/platform/platform_adapter.dart';
import 'package:flutter_smart_genome/service/abs_platform_service.dart';
import 'package:flutter_smart_genome/service/beans.dart';
import 'package:flutter_smart_genome/service/sgs_app_service.dart';
import 'package:flutter_smart_genome/widget/basic/custom_bot_widget.dart';
import 'package:flutter_smart_genome/widget/basic/custom_spin.dart';
import 'package:flutter_smart_genome/widget/basic/scroll_controller_builder.dart';
import 'package:flutter_smart_genome/widget/loading_widget.dart';
import 'package:flutter_smart_genome/widget/track/common.dart';

class AsyncSequenceWidget extends StatefulWidget {
  final Range range;
  final String? host;
  final String chr;
  final String species;
  final bool simple;
  final String? header;
  final int strand;
  final String? featureId;

  const AsyncSequenceWidget({
    Key? key,
    required this.range,
    this.host,
    required this.chr,
    required this.species,
    this.simple = true,
    this.header,
    this.strand = 1,
    this.featureId,
  }) : super(key: key);

  @override
  _AsyncSequenceWidgetState createState() => _AsyncSequenceWidgetState();
}

class _AsyncSequenceWidgetState extends State<AsyncSequenceWidget> {
  bool _loading = true;
  bool _downloading = false;
  bool _simple = true;

  bool _isHoleSequence = false;
  String? _showSequence;

  int maxViewLength = 10000;

  @override
  void initState() {
    super.initState();
    _simple = widget.simple;
    _loadSequence(download: false);
  }

  void _loadSequence({required bool download}) async {
    setState(() {
      if (download) {
        _downloading = true;
      } else {
        _loading = true;
      }
    });
    await Future.delayed(Duration(milliseconds: 800));
    String host = widget.host ?? SgsAppService.get()!.site!.url;
    _isHoleSequence = widget.range.size <= maxViewLength;
    var range = !download && !_isHoleSequence ? Range.fromSize(start: widget.strand == -1 ? widget.range.end - maxViewLength : widget.range.start, width: maxViewLength) : widget.range;
    RangeSequence rangeSequence = await AbsPlatformService.get()!.loadSequence(
      host: host,
      range: range,
      chr: widget.chr,
      species: widget.species,
    );
    if (!mounted) return;

    String? __sequence = rangeSequence.subSequence(range);
    if (widget.strand == -1 && null != __sequence) {
      __sequence = reversedComplementSequence(__sequence);
    }

    if (download) {
      _downloading = false;
      setState(() {});
      _saveSequence(__sequence);
    } else {
      setState(() {
        _loading = false;
        _showSequence = __sequence;
      });
    }
  }

  void _saveSequence(String? seq) async {
    if (seq == null) return;
    var sps = SgsAppService.get()!.site!.currentSpecies;
    String name = '${widget.featureId ?? widget.range.print2('-')}.txt';
    String content = '# Species: ${sps}\n${widget.header}\n${_formatSequence(seq)}';
    await PlatformAdapter.create().saveFile(filename: name, content: content);
  }

  String _formatSequence(String sequence) {
    RegExp reg = RegExp(r'(.{1,80})');
    var matches = reg.allMatches(sequence);
    var _seqList = matches.map((e) => e.group(0)!).toList();
    return _seqList.join('\n');
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Center(
        child: CustomSpin(color: Theme.of(context).colorScheme.primary),
      );
    }
    if (null == _showSequence) {
      return LoadingWidget(
        loadingState: LoadingState.error,
        simple: true,
        onErrorClick: (s) => _loadSequence(download: false),
      );
    }

    Widget _seqWidget = _simple
        ? _simpleSequence()
        : SequenceWidget(
            sequence: _showSequence!,
            colored: !widget.simple,
            seqSize: 20,
            header: widget.header,
          );

    return _seqWidget;
  }

  String reversedComplementSequence(String sequence) {
    Map complementMap = {
      'a': 't',
      't': 'a',
      'c': 'g',
      'g': 'c',
      'A': 't',
      'T': 'A',
      'C': 'G',
      'G': 'C',
    };
    var reversed = sequence.split('').reversed;
    var complement = reversed.map((e) => complementMap[e] ?? e).join('');
    return complement;
  }

  Widget _simpleSequence() {
    Color textColor = Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: 10),
        Row(
          children: [
            if (widget.header == null) Spacer(),
            if (widget.header != null)
              Expanded(
                child: SelectionArea(
                  child: Text(
                    widget.header!,
                    softWrap: true,
                    style: TextStyle(fontFamily: MONOSPACED_FONT, fontFamilyFallback: MONOSPACED_FONT_BACK),
                  ),
                ),
              ),
            if (_isHoleSequence)
              IconButton(
                iconSize: 14,
                icon: Icon(Icons.content_copy),
                tooltip: 'Copy',
                padding: EdgeInsets.zero,
                constraints: BoxConstraints.tightFor(width: 30, height: 28),
                style: IconButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
                splashRadius: 15,
                onPressed: _showSequence == null
                    ? null
                    : () {
                        Clipboard.setData(ClipboardData(text: '${widget.header ?? ''}\n$_showSequence'));
                        showToast(text: 'Sequence Copied');
                      },
              ),
            IconButton(
              iconSize: 16,
              icon: _downloading ? CustomSpin(size: 20, color: Theme.of(context).colorScheme.primary) : Icon(Icons.download),
              tooltip: 'Download sequence',
              padding: EdgeInsets.zero,
              style: IconButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
              constraints: BoxConstraints.tightFor(width: 30, height: 28),
              splashRadius: 15,
              onPressed: _downloading ? null : () => _loadSequence(download: true),
            ),
          ],
        ),
        Expanded(
          child: ScrollControllerBuilder(
            builder: (c, controller) {
              return SingleChildScrollView(
                physics: ClampingScrollPhysics(),
                controller: controller,
                child: SelectionArea(
                  child: Text(
                    _showSequence!,
                    style: TextStyle(
                      fontSize: 14,
                      // fontWeight: FontWeight.w300,
                      letterSpacing: 1.0,
                      height: 1.0,
                      color: textColor,
                      fontFamily: MONOSPACED_FONT,
                      fontFamilyFallback: MONOSPACED_FONT_BACK,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        if (!_isHoleSequence)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: TextButton.icon(
              onPressed: _downloading ? null : () => _loadSequence(download: true),
              icon: _downloading ? CustomSpin(size: 20, color: Theme.of(context).colorScheme.primary) : Icon(Icons.download, size: 16),
              label: Text('Download to view hole sequence'),
            ),
          ),
      ],
    );
  }
}
