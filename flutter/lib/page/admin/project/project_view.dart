import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'project_logic.dart';

class ProjectPage extends StatefulWidget {
  @override
  State<ProjectPage> createState() => _ProjectPageState();
}

class _ProjectPageState extends State<ProjectPage> {
  final logic = Get.put(ProjectLogic());

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProjectLogic>(init: logic,builder: _builder);
  }

  Widget _builder(ProjectLogic logic) {
  return Scaffold(
    body: Container(

    ),
  );
  }

  @override
  void dispose() {
    Get.delete<ProjectLogic>();
    super.dispose();
  }
}