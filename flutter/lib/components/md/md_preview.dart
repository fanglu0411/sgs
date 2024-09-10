import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/base/container_config.dart';
import 'package:markdown_widget/markdown_widget.dart';

import 'editor/code_wrapper.dart';
import 'editor/custom_code_node.dart';
import 'editor/custom_config.dart';
import 'editor/custom_node.dart';

class MdPreview extends StatelessWidget {
  final String data;
  final bool shrinkWrap;

  const MdPreview({super.key, required this.data, this.shrinkWrap = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final MarkdownConfig config = (isDark ? MarkdownConfig.darkConfig : MarkdownConfig.defaultConfig).copy(
      configs: [
        HrConfig(height: 2, color: theme.dividerTheme.color!),
        FitH1Config(style: theme.textTheme.headlineLarge!),
        FitH2Config(style: theme.textTheme.headlineMedium!),
        FitH3Config(style: theme.textTheme.headlineSmall!),
        // H2Config.darkConfig,
        // H3Config.darkConfig,
        // H4Config.darkConfig,
        // H5Config.darkConfig,
        // H6Config.darkConfig,
        LinkConfig(style: TextStyle(color: theme.colorScheme.primary)),
        PreConfig(
          decoration: BoxDecoration(
            color: theme.colorScheme.secondaryContainer,
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
          ),
        ),
        TableConfig(
          defaultColumnWidth: FlexColumnWidth(),
          border: TableBorder.all(
            color: theme.dividerTheme.color!,
            width: 1.5,
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        PConfig(textStyle: TextStyle(fontSize: theme.textTheme.bodyLarge?.fontSize)),
        CodeConfig(
          style: TextStyle(
            backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
          ),
        ),
        // BlockquoteConfig.darkConfig,
        (isDark ? PreConfig.darkConfig : PreConfig()).copy(
          textStyle: TextStyle(
            fontFamily: MONOSPACED_FONT,
            fontFamilyFallback: MONOSPACED_FONT_BACK,
            fontSize: theme.textTheme.bodyLarge?.fontSize,
          ),
          styleNotMatched: TextStyle(
            fontFamily: MONOSPACED_FONT,
            fontFamilyFallback: MONOSPACED_FONT_BACK,
            fontSize: theme.textTheme.bodyLarge?.fontSize,
          ),
          wrapper: (child, text, language) => CodeWrapperWidget(child, text, language),
        ),
      ],
    );
    return MarkdownWidget(
      data: data,
      config: config,
      shrinkWrap: shrinkWrap,
      markdownGenerator: MarkdownGenerator(
        generators: [codeGeneratorWithTag],
        textGenerator: (node, config, visitor) => CustomTextNode(node.textContent, config, visitor),
        richTextBuilder: (span) => Text.rich(span, textScaler: TextScaler.linear(1.0)),
      ),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
    );
    ();
  }
}
