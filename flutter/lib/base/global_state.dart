import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/bean/account_bean.dart';
import 'package:flutter_smart_genome/components/window/multi_window_controller.dart';
import 'package:get/get.dart';

final globalKey = GlobalKey<NavigatorState>();

///当前窗口的id
int kWindowId = 0;
WindowType kWindowType = WindowType.main;

List<String> kBootArgs = [];

Rx<AccountBean?> accountObs = Rx(null);