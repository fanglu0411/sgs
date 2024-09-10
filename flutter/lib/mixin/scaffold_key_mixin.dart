import 'package:flutter/material.dart';

mixin ScaffoldKeyMixin<T extends StatefulWidget> on State<T> {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  showSnackBar(SnackBar snackBar) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  showSnackBarWithMsg(String msg, {Icon? icon}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("$msg"),
    ));
  }
}