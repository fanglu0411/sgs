import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/widget/basic/fast_rich_text.dart';
import 'package:get/get.dart';

const menuBackgroundColor = const Color(0x11000000);

Widget attachedAnimation(AnimationController controller, CancelFunc cancelFunc, Widget child) => NormalAnimation(controller: controller, child: child);

CancelFunc showAttachedWidget({
  required ToastBuilder attachedBuilder,
  Offset? target,
  BuildContext? targetContext,
  PreferDirection? preferDirection,
  Color backgroundColor = menuBackgroundColor,
  bool ignoreContentClick = false,
  VoidCallback? onClose,
  Offset offset = Offset.zero,
}) {
  return BotToast.showAttachedWidget(
    attachedBuilder: attachedBuilder,
    target: target,
    targetContext: targetContext,
    preferDirection: preferDirection,
    backgroundColor: backgroundColor,
    ignoreContentClick: ignoreContentClick,
    onClose: onClose,
    verticalOffset: offset.dy,
    horizontalOffset: offset.dx,
    enableSafeArea: false,
    animationDuration: Duration(milliseconds: 250),
    animationReverseDuration: Duration(milliseconds: 150),
    wrapToastAnimation: attachedAnimation,
  );
}

CancelFunc showErrorToast({
  required String text,
  Duration? duration,
  Alignment? align,
}) =>
    showToast(
      text: text,
      // backgroundColor: Get.theme.colorScheme.errorContainer,
      duration: duration,
      align: align,
      // foregroundColor: Colors.white,
    );

CancelFunc showToast({
  required String text,
  Color? backgroundColor,
  Duration? duration,
  Alignment? align,
  Color? foregroundColor,
}) {
  return BotToast.showCustomText(
    align: align ?? Alignment(0, 0.5),
    duration: duration ?? Duration(milliseconds: 2500),
    onlyOne: true,
    toastBuilder: (c) {
      return Material(
        borderRadius: BorderRadius.circular(10),
        elevation: 4,
        color: backgroundColor ?? (Get.isDarkMode ? Colors.grey[800] : Colors.grey[100]),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Text(
            '${text}',
            textScaler: TextScaler.linear(1.2),
            style: foregroundColor != null ? TextStyle(color: foregroundColor) : null,
          ),
        ),
      );
    },
  );
}

CancelFunc showSuccessNotification({required Text title, Text? subtitle, Duration? duration}) {
  return showCustomNotification(
    title: title,
    subtitle: subtitle,
    icon: Icon(Icons.check_circle, color: Colors.green, size: 40),
    duration: duration,
  );
}

CancelFunc showWarnNotification({required Text title, Text? subtitle, Duration? duration}) {
  return showCustomNotification(
    title: title,
    subtitle: subtitle,
    icon: Icon(Icons.warning_rounded, color: Colors.orange, size: 40),
    duration: duration,
  );
}

CancelFunc showErrorNotification({required Text title, Text? subtitle, Duration? duration}) {
  return showCustomNotification(
    title: title,
    subtitle: subtitle,
    icon: Icon(Icons.error, color: Colors.red, size: 40),
    duration: duration,
  );
}

CancelFunc showCustomNotification({
  required Widget title,
  Widget? subtitle,
  Widget? icon,
  Alignment align = const Alignment(0.98, -.98),
  Duration? duration = const Duration(milliseconds: 5000),
}) {
  return BotToast.showCustomNotification(
    toastBuilder: (c) {
      return Material(
        color: Get.isDarkMode ? Colors.grey[800] : Colors.grey[100],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 8,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) icon,
              if (icon != null) SizedBox(width: 12),
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 500),
                child: FastRichText(
                  textStyle: TextStyle(),
                  children: [
                    WidgetSpan(child: title),
                    if (subtitle != null) TextSpan(text: '\n'),
                    if (subtitle != null) WidgetSpan(child: subtitle),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
    duration: duration ?? Duration(milliseconds: 5000),
    align: align,
  );
}

class NormalAnimation extends StatefulWidget {
  final Widget child;
  final bool reverse;
  final AnimationController controller;

  const NormalAnimation({Key? key, required this.child, this.reverse = false, required this.controller}) : super(key: key);

  @override
  NormalAnimationState createState() => NormalAnimationState();
}

class NormalAnimationState extends State<NormalAnimation> with SingleTickerProviderStateMixin {
  static final Tween<Offset> reverseTweenOffset = Tween<Offset>(
    begin: const Offset(0, -40),
    end: const Offset(0, 0),
  );
  static final Tween<Offset> tweenOffset = Tween<Offset>(
    begin: const Offset(0, 40),
    end: const Offset(0, 0),
  );
  static final Tween<double> tweenOpacity = Tween<double>(begin: 0, end: 1);
  Animation<double>? animation;

  Animation<Offset>? animationOffset;
  Animation<double>? animationOpacity;

  @override
  void initState() {
    animation = CurvedAnimation(parent: widget.controller, curve: Curves.decelerate);

    animationOffset = (widget.reverse ? reverseTweenOffset : tweenOffset).animate(animation!);
    animationOpacity = tweenOpacity.animate(animation!);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (_, child) {
        return Transform.translate(
          offset: animationOffset!.value,
          child: Opacity(
            opacity: animationOpacity!.value,
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}

//淡出淡入动画
class FadeAnimation extends StatefulWidget {
  final Widget child;
  final AnimationController controller;

  const FadeAnimation({Key? key, required this.child, required this.controller}) : super(key: key);

  @override
  FadeAnimationState createState() => FadeAnimationState();
}

class FadeAnimationState extends State<FadeAnimation> with SingleTickerProviderStateMixin {
  static final Tween<double> tweenOpacity = Tween<double>(begin: 0, end: 1);
  Animation<double>? animation;
  Animation<double>? animationOpacity;

  @override
  void initState() {
    animation = CurvedAnimation(parent: widget.controller, curve: Curves.decelerate);
    animationOpacity = tweenOpacity.animate(animation!);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animationOpacity!,
      child: widget.child,
    );
  }
}
