import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_genome/base/container_config.dart';

class CodeWrapperWidget extends StatefulWidget {
  final Widget child;
  final String text;
  final String language;

  const CodeWrapperWidget(this.child, this.text, this.language, {Key? key}) : super(key: key);

  @override
  State<CodeWrapperWidget> createState() => _PreWrapperState();
}

class _PreWrapperState extends State<CodeWrapperWidget> {
  late Widget _switchWidget;
  bool hasCopied = false;

  @override
  void initState() {
    super.initState();
    _switchWidget = Icon(Icons.copy_rounded, key: UniqueKey(), size: 18);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Stack(
      children: [
        widget.child,
        Positioned(
          right: 10,
          top: 16,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.language.isNotEmpty)
                SelectionContainer.disabled(
                  child: Container(
                    child: Text(
                      widget.language,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontFamily: MONOSPACED_FONT,
                            fontFamilyFallback: MONOSPACED_FONT_BACK,
                          ),
                    ),
                    margin: EdgeInsets.only(right: 6),
                    padding: EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(width: 0.5, color: isDark ? Colors.white60 : Colors.black54),
                    ),
                  ),
                ),
              InkWell(
                child: AnimatedSwitcher(
                  child: _switchWidget,
                  duration: Duration(milliseconds: 200),
                ),
                onTap: () async {
                  if (hasCopied) return;
                  await Clipboard.setData(ClipboardData(text: widget.text));
                  _switchWidget = Icon(Icons.check, key: UniqueKey(), size: 18);
                  refresh();
                  Future.delayed(Duration(seconds: 2), () {
                    hasCopied = false;
                    _switchWidget = Icon(Icons.copy_rounded, key: UniqueKey(), size: 18);
                    refresh();
                  });
                },
              ),
            ],
          ),
        )
      ],
    );
  }

  void refresh() {
    if (mounted) setState(() {});
  }
}
