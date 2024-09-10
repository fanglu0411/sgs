import 'package:flutter/material.dart';

mixin AbsTrackPageMixin<T extends StatefulWidget> on State<T> {
  Widget buildControlBar();

  Widget buildBottomBar();

  Widget buildAppBar();

  @override
  Widget build(BuildContext context) {
//    super.build(context);
    return Container();
  }
}