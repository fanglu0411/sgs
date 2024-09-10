import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/base/container_config.dart';

import 'package:flutter_smart_genome/components/markdown_widget.dart';
import 'package:flutter_smart_genome/components/md/md_preview.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:flutter_smart_genome/components/md/editor/md_editor_toolbar.dart';
import 'package:flutter_smart_genome/widget/split_widget.dart' as sp;
import 'package:get/get.dart';

import 'editor/code_wrapper.dart';
import 'editor/custom_code_node.dart';
import 'editor/custom_config.dart';
import 'editor/custom_node.dart';

class MarkdownEditor extends StatefulWidget {
  final ValueChanged<String>? onChange;
  final ValueChanged<String>? onSave;
  final String? content;

  const MarkdownEditor({
    super.key,
    this.onChange,
    this.onSave,
    this.content,
  });

  @override
  State<MarkdownEditor> createState() => _MarkdownEditorState();
}

class _MarkdownEditorState extends State<MarkdownEditor> {
  TextEditingController? _editingController;

  RxString? content;
  FocusNode? _focus;

  @override
  void initState() {
    super.initState();
    _focus = FocusNode();
    _editingController = TextEditingController(text: widget.content ?? '');
    content = _editingController!.text.obs;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MdEditorToolbar(onMenuTap: _onMdToolTap),
        Divider(height: 1, thickness: 1),
        Expanded(
          child: sp.Split(
            axis: Axis.horizontal,
            initialFractions: [.5, .5],
            minSizes: [200, 200],
            children: [
              TextField(
                focusNode: _focus,
                controller: _editingController,
                scrollPhysics: ClampingScrollPhysics(),
                expands: true,
                maxLines: null,
                autofocus: true,
                textInputAction: TextInputAction.go,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      textBaseline: TextBaseline.alphabetic,
                      fontWeight: FontWeight.w400,
                    ),
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(10),
                  border: InputBorder.none,
                  hintText: 'Input Here...',
                  hintStyle: TextStyle(color: Colors.grey),
                ),
                onChanged: (s) {
                  content!.value = s;
                  widget.onChange?.call(s);
                },
                onEditingComplete: () {
                  _onMdToolTap(MdEditorAction.newline);
                },
              ),
              ObxValue<RxString>((c) => MdPreview(data: c.value), content!),
            ],
          ),
        )
      ],
    );
  }

  void _onMdToolTap(MdEditorAction action) {
    TextSelection selection = _editingController!.selection;
    var (start, end) = (selection.start, selection.end);
    TextRange range = _editingController!.value.composing;
    TextEditingValue value = _editingController!.value;
    String text = _editingController!.text;
    switch (action) {
      case MdEditorAction.newline:
        String before = selection.textBefore(text);
        var beforeLines = before.split("\n");
        var inserted = '';
        if (beforeLines.length > 0) {
          if (beforeLines.last.startsWith('- [ ]')) {
            inserted = '- [ ] ';
          } else if (beforeLines.last.startsWith('- [x]')) {
            inserted = '- [x] ';
          } else if (beforeLines.last.startsWith('- ')) {
            inserted = '- ';
          } else if (RegExp(r'^(\d+).').hasMatch(beforeLines.last)) {
            var reg = RegExp(r'^(\d+).');
            var _match = reg.firstMatch(beforeLines.last);
            if (_match != null) {
              var n = num.parse(_match.group(1)!);
              inserted = '${n + 1}. ';
            }
          } else if (RegExp(r'^\|(.*\|)+').hasMatch(beforeLines.last)) {
            inserted = beforeLines.last.replaceAll(r'[^\|]', ' ');
          }
        }
        _editingController!.value = TextEditingValue(
          text: '${selection.textBefore(text)}${selection.textInside(text)}\n${inserted}${selection.textAfter(text)}',
          selection: TextSelection.collapsed(offset: end + inserted.length + 1),
        );
        break;
      case MdEditorAction.bold:
        _editingController!.value = TextEditingValue(
          text: '${selection.textBefore(text)}**${selection.textInside(text)}**${selection.textAfter(text)}',
          selection: TextSelection.collapsed(offset: end + 2),
        );
        break;
      case MdEditorAction.italic:
        _editingController!.value = TextEditingValue(
          text: '${selection.textBefore(text)}*${selection.textInside(text)}*${selection.textAfter(text)}',
          selection: TextSelection.collapsed(offset: end + 1),
        );
        break;
      case MdEditorAction.strikethrough:
        _editingController!.value = TextEditingValue(
          text: '${selection.textBefore(text)}~~${selection.textInside(text)}~~${selection.textAfter(text)}',
          selection: TextSelection.collapsed(offset: end + 2),
        );
        break;
      case MdEditorAction.heading:
        _editingController!.value = TextEditingValue(
          text: '${selection.textBefore(text)}# ${selection.textInside(text)} ${selection.textAfter(text)}',
          selection: TextSelection.collapsed(offset: end + 2),
        );
        break;
      case MdEditorAction.unordered_list:
        _editingController!.value = TextEditingValue(
          text: '${selection.textBefore(text)}\n- ${selection.textInside(text)} ${selection.textAfter(text)}',
          selection: TextSelection.collapsed(offset: end + 3),
        );
        break;
      case MdEditorAction.ordered_list:
        _editingController!.value = TextEditingValue(
          text: '${selection.textBefore(text)}\n\1. ${selection.textInside(text)} ${selection.textAfter(text)}',
          selection: TextSelection.collapsed(offset: end + 4),
        );
        break;
      case MdEditorAction.check_list:
        _editingController!.value = TextEditingValue(
          text: '${selection.textBefore(text)}\n- [x] ${selection.textInside(text)} \n${selection.textAfter(text)}',
          selection: TextSelection.collapsed(offset: end + 7),
        );
        break;
      case MdEditorAction.blockquote:
        _editingController!.value = TextEditingValue(
          text: '${selection.textBefore(text)}\n> ${selection.textInside(text)} ${selection.textAfter(text)}',
          selection: TextSelection.collapsed(offset: end + 2),
        );
        break;
      case MdEditorAction.code:
        _editingController!.value = TextEditingValue(
          text: '${selection.textBefore(text)}\n```\n ${selection.textInside(text)}\n```${selection.textAfter(text)}',
          selection: TextSelection.collapsed(offset: end + 4),
        );
        break;
      case MdEditorAction.table:
        String table = '''| h             | h             | h             | h             |
|----------|----------|----------|----------|
|                |                |                |                |
|                |                |                |                |''';
        _editingController!.value = TextEditingValue(
          text: '${selection.textBefore(text)}${selection.textInside(text)}\n${table}\n${selection.textAfter(text)}',
          selection: TextSelection.collapsed(offset: end),
        );
      case MdEditorAction.link:
        //[I'm link](https://github.com)
        _editingController!.value = TextEditingValue(
          text: '${selection.textBefore(text)}[${selection.textInside(text)}](url)${selection.textAfter(text)}',
          selection: TextSelection(baseOffset: end + 3, extentOffset: end + 6),
        );

        break;
      case MdEditorAction.image:
        //![support](assets/script_medias/1675527935336.png)
        _editingController!.value = TextEditingValue(
          text: '${selection.textBefore(text)}![${selection.textInside(text)}](url)${selection.textAfter(text)}',
          selection: TextSelection(baseOffset: end + 4, extentOffset: end + 7),
        );
        break;
      case MdEditorAction.save:
        widget.onSave?.call(_editingController!.text);
        break;
    }
    _focus?.requestFocus();
    content!.value = _editingController!.text;
  }

  @override
  void dispose() {
    super.dispose();
    _editingController?.dispose();
    _focus?.dispose();
  }
}
