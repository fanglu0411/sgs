import 'package:flutter_smart_genome/widget/basic/custom_spin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';

enum LoadingState {
  loading,
  noData,
  error,
  notImplemented,
}

typedef OnErrorClick(LoadingState state);

class LoadingWidget extends StatefulWidget {
  final LoadingState loadingState;
  final String? message;
  final OnErrorClick? onErrorClick;
  final Widget? icon;
  final bool simple;
  final Color? color;
  final VoidCallback? onCancel;

  LoadingWidget({
    Key? key,
    required this.loadingState,
    this.message,
    this.onErrorClick,
    this.icon,
    this.color,
    this.simple = true,
    this.onCancel,
  }) : super(key: key);

  LoadingWidget.error({
    Key? key,
    this.color,
    this.message,
    this.simple = true,
    this.icon,
    this.loadingState = LoadingState.error,
    this.onErrorClick,
    this.onCancel,
  }) : super(key: key) {}

  LoadingWidget.loading({
    Key? key,
    this.color,
    this.message,
    this.simple = true,
    this.icon,
    this.loadingState = LoadingState.loading,
    this.onErrorClick = null,
    this.onCancel,
  }) : super(key: key) {}

  LoadingWidget.noData({
    Key? key,
    this.color,
    this.message,
    this.simple = true,
    this.icon,
    this.loadingState = LoadingState.noData,
    this.onErrorClick = null,
    this.onCancel,
  }) : super(key: key) {}

  LoadingWidget.notImplemented({
    Key? key,
    this.color,
    this.message,
    this.simple = true,
    this.icon,
    this.loadingState = LoadingState.notImplemented,
    this.onErrorClick = null,
    this.onCancel,
  }) : super(key: key) {}

  @override
  State<StatefulWidget> createState() => new _LoadingWidgetState();
}

class _LoadingWidgetState extends State<LoadingWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(LoadingWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.loadingState != oldWidget.loadingState || widget.message != oldWidget.message) {
      debugPrint('update loading widget ${widget.loadingState}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: _builder,
    );
  }

  Widget _builder(BuildContext context, BoxConstraints constraints) {
    return GestureDetector(
      onTap: widget.onErrorClick == null
          ? null
          : () {
              widget.onErrorClick!(widget.loadingState);
            },
      child: _buildView(),
    );
  }

  Widget _buildView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _stateIcon(),
          SizedBox(height: 10),
          _stateMessage(),
          SizedBox(height: 10),
          _buildButton(),
          if (widget.loadingState == LoadingState.loading && widget.onCancel != null)
            IconButton(
              onPressed: widget.onCancel,
              icon: Icon(Icons.clear),
              iconSize: 16,
              tooltip: 'Cancel',
              padding: EdgeInsets.zero,
              splashRadius: 18,
              constraints: BoxConstraints.tightFor(width: 32, height: 32),
            ),
        ],
      ),
    );
  }

  Widget _stateIcon() {
    if (widget.icon != null) return widget.icon!;
    double iconSize = widget.simple ? 80 : 160;
    switch (widget.loadingState) {
      case LoadingState.loading:
        return CustomSpin(size: 36, color: widget.color ?? Theme.of(context).colorScheme.primary);
      case LoadingState.noData:
        return Icon(
          MaterialCommunityIcons.emoticon_cry,
          size: iconSize,
          color: widget.color,
        );
      case LoadingState.error:
        return Icon(MaterialCommunityIcons.emoticon_cry, size: iconSize, color: widget.color);
      case LoadingState.notImplemented:
        return Icon(
          MaterialCommunityIcons.emoticon_cry,
          size: iconSize,
          color: widget.color,
        );
    }
  }

  Widget _stateMessage() {
    String _message = widget.message ??
        switch (widget.loadingState) {
          LoadingState.loading => 'Loading',
          LoadingState.noData => 'Data is empty!',
          LoadingState.error => 'Load data error!',
          LoadingState.notImplemented => 'Not implemented!'
        };
    return Text(_message, style: Theme.of(context).textTheme.bodyMedium);
  }

  Widget _buildButton() {
    if (widget.onErrorClick == null) return Offstage();
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        minimumSize: Size(100, 42),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: EdgeInsets.symmetric(horizontal: 20),
        textStyle: TextStyle(fontWeight: FontWeight.w800),
      ),
      onPressed: () {
        widget.onErrorClick?.call(widget.loadingState);
      },
      icon: Icon(Icons.refresh),
      label: Text(' Reload '),
    );
  }
}
