import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:markdown_widget/markdown_widget.dart';

class CustomCodeNode extends ElementNode {
  final CodeConfig codeConfig;
  final String text;

  CustomCodeNode(this.text, this.codeConfig);

  @override
  InlineSpan build() => WidgetSpan(
        child: SelectionArea(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: codeConfig.style.backgroundColor?.withOpacity(.6),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(text, style: codeConfig.style?.copyWith(backgroundColor: Colors.transparent)),
          ),
        ),
      );

  @override
  TextStyle get style => codeConfig.style.merge(parentStyle);
}

SpanNodeGeneratorWithTag codeGeneratorWithTag = SpanNodeGeneratorWithTag(tag: MarkdownTag.code.name, generator: (e, config, visitor) => CustomCodeNode(e.textContent, config.code));
