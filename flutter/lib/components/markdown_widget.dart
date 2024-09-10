import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;

class SimpleMarkdownWidget extends StatefulWidget {
  final String source;

  const SimpleMarkdownWidget({Key? key, this.source = ''}) : super(key: key);

  @override
  _SimpleMarkdownWidgetState createState() => _SimpleMarkdownWidgetState();
}

class _SimpleMarkdownWidgetState extends State<SimpleMarkdownWidget> {
  @override
  Widget build(BuildContext context) {
    return Markdown(
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      data: widget.source,
      styleSheetTheme: MarkdownStyleSheetBaseTheme.platform,
      extensionSet: md.ExtensionSet(
        md.ExtensionSet.gitHubWeb.blockSyntaxes,
        [
          md.EmojiSyntax(),
          ...md.ExtensionSet.gitHubWeb.inlineSyntaxes,
        ],
      ),
      selectable: true,
    );
  }
}

class SliverMarkdownList extends MarkdownWidget {
  /// Creates a non-scrolling widget that parses and displays Markdown.
  const SliverMarkdownList({
    super.key,
    required super.data,
    super.selectable,
    super.styleSheet,
    super.styleSheetTheme = null,
    super.syntaxHighlighter,
    super.onTapLink,
    super.onTapText,
    super.imageDirectory,
    super.blockSyntaxes,
    super.inlineSyntaxes,
    super.extensionSet,
    super.imageBuilder,
    super.checkboxBuilder,
    super.bulletBuilder,
    super.builders,
    super.paddingBuilders,
    super.listItemCrossAxisAlignment,
    this.shrinkWrap = true,
    super.fitContent = true,
    super.softLineBreak,
  });

  /// If [shrinkWrap] is `true`, [MarkdownBody] will take the minimum height
  /// that wraps its content. Otherwise, [MarkdownBody] will expand to the
  /// maximum allowed height.
  final bool shrinkWrap;

  @override
  Widget build(BuildContext context, List<Widget>? children) {
    return SliverList(delegate: SliverChildListDelegate(children ?? []));
  }
}
