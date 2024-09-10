import 'package:flutter/material.dart';

class FloatingBarScaffold extends StatelessWidget {
  final AppBar? appBar;
  final Widget body;
  final Color? backgroundColor;

  const FloatingBarScaffold({
    Key? key,
    this.appBar,
    this.backgroundColor,
    required this.body,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          Container(
            constraints: const BoxConstraints.expand(),
            child: body,
          ),
          if (appBar != null) PreferredSize(child: appBar!, preferredSize: Size.fromHeight(kToolbarHeight)),
        ],
      ),
    );
  }
}