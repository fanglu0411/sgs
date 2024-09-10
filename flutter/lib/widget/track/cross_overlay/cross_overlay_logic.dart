import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/bean/feature_beans.dart';
import 'package:flutter_smart_genome/util/debouncer.dart';
import 'package:flutter_smart_genome/widget/track/base/track_data.dart';
import 'package:flutter_smart_genome/widget/track/common.dart';
import 'package:flutter_smart_genome/widget/track/track_group_logic.dart';
import 'package:get/get.dart';

class CrossOverlayLogic extends GetxController {
  static CrossOverlayLogic? safe() {
    if (Get.isRegistered<CrossOverlayLogic>()) {
      return Get.find<CrossOverlayLogic>();
    }
    return null;
  }

  Color? flashColor;

  AnimationController? animationController;
  Animation? _animation;

  late Debounce _debounce;

  @override
  void onInit() {
    super.onInit();
    _debounce = Debounce(milliseconds: 10000);
  }

  int _repeatCount = 0;

  void setAnimationController(AnimationController animationController) {
    this.animationController = animationController;
    this.animationController!.addListener(() {
      flashColor = _animation?.value;
      print('${flashColor}');
      update();
    });
    this.animationController!.addStatusListener((status) {
      if (status == AnimationStatus.reverse) {
        _repeatCount++;
      }
      if (status == AnimationStatus.completed) {
        flashColor = null;
        _flashRange = null;
        update();
      }
    });
  }

  CursorSelection? _selection;

  CursorSelection? get selection => _selection;

  void set selection(CursorSelection? selection) {
    _selection = selection;
    update();
  }

  Range? _flashRange;

  Range? get flashRange => _flashRange;

  Animation<double>? flashAnimation;

  String? targetTrackId;
  String? targetId;

  setTarget({String? targetTrackId, String? targetId}) {
    this.targetTrackId = targetTrackId;
    this.targetId = targetId;
  }

  addFlashRange(Range range) {
    _flashRange = range;
    flashColor = Colors.yellow;
    update();
    _debounce.run(_clearFlash);

    // _repeatCount = 0;
    // animationController.reset();
    // animationController.duration = Duration(milliseconds: 800);
    // _animation = ColorTween(begin: Colors.yellow, end: Colors.red).animate(CurvedAnimation(parent: animationController, curve: Curves.easeInCubic));
    // animationController.forward();
  }

  void _clearFlash() {
    _flashRange = null;
    flashColor = null;
    targetTrackId = null;
    targetId = null;
    update();
  }

  void disposeAnimationController() {
    animationController?.dispose();
    animationController = null;
  }

  bool checkFeature(RangeFeature feature, Track track) {
    return _flashRange != null && (targetTrackId == null || targetTrackId == track.id) && targetId != null && (feature.featureId.toLowerCase() == targetId?.toLowerCase() || feature.name.toLowerCase() == targetId?.toLowerCase());
  }

  @override
  void onClose() {
    super.onClose();
    _debounce.dispose();
  }
}