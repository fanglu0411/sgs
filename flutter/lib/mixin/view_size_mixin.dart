import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/base/ui_config.dart' as uiConfig;

mixin ViewSizeMixin<T extends StatefulWidget> on State<T> {
  bool get isWeb => kIsWeb;

  uiConfig.ViewSize getViewSize() {
    return uiConfig.getViewSize(context);
  }

  bool isMobile() {
    return uiConfig.getViewSize(context) == uiConfig.ViewSize.mobile;
  }

  bool isTablet() {
    return uiConfig.getViewSize(context) == uiConfig.ViewSize.tablet;
  }

  bool isBigScreen() {
    return uiConfig.getViewSize(context) == uiConfig.ViewSize.big_screen;
  }

  TargetPlatform get targetPlatform => Theme.of(context).platform;

  bool get isAndroidOrIOS {
    TargetPlatform _targetPlatform = targetPlatform;
    return !isWeb && (_targetPlatform == TargetPlatform.android || _targetPlatform == TargetPlatform.iOS);
  }
}
