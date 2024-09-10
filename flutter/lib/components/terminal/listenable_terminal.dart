import 'package:xterm/xterm.dart';

class ListenableTerminal extends Terminal {
  ListenableTerminal({
    int maxLines = 1000,
    Function()? onBell,
    Function(String title)? onTitleChange,
    Function(String icon)? onIconChange,
    Function(String data)? onOutput,
    Function(int width, int height, int pixelWidth, int pixelHeight)? onResize,
    TerminalTargetPlatform platform = TerminalTargetPlatform.unknown,
    CascadeInputHandler inputHandler = defaultInputHandler,
    this.onWrite,
  }) : super(
          maxLines: maxLines,
          onBell: onBell,
          onTitleChange: onTitleChange,
          onIconChange: onIconChange,
          onOutput: onOutput,
          onResize: onResize,
          platform: platform,
          inputHandler: inputHandler,
        );

  Function(String data)? onWrite;

  @override
  void write(String data) {
    super.write(data);
    onWrite?.call(data);
  }
}