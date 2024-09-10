import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/components/markdown_widget.dart';
import 'package:flutter_smart_genome/page/help/user_manual.dart';

class UserManualWidget extends StatefulWidget {
  @override
  _UserManualWidgetState createState() => _UserManualWidgetState();
}

class _UserManualWidgetState extends State<UserManualWidget> {
  @override
  Widget build(BuildContext context) {
    return SimpleMarkdownWidget(source: userManual);
  }
}
