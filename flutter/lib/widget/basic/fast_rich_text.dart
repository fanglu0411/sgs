import 'package:flutter/material.dart';

class FastRichText extends StatelessWidget {
  final List<InlineSpan> children;
  final TextStyle? textStyle;
  const FastRichText({Key? key, this.children = const [], this.textStyle}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: textStyle,
        children: children,
      ),
    );
  }
}