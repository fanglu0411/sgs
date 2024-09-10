import 'package:flutter_smart_genome/widget/track/common.dart';

const binSizes = [
  5000000,
  2000000,
  1000000,
  500000,
  200000,
  100000,
  50000,
  20000,
  10000,
  5000,
  2000,
  1000,
  //max_bin_size= chr_size / 1000
];

const desiredZoomLevels = [
  1 / 5000000,
  1 / 2500000,
  1 / 1000000,
  1 / 500000,
  1 / 250000,
  1 / 100000,
  1 / 50000,
  1 / 25000,
  1 / 10000,
  1 / 5000,
  1 / 2500,
  1 / 1000,
  1 / 500,
  1 / 250,
  1 / 100,
  1 / 50,
  1 / 25,
  1 / 10,
  1 / 5,
  1 / 2.5,
  1,
  2.5,
  5,
  10,
  25,
  50,
];
const desiredZoomLevels2 = [
  1 / 4194304,
  1 / 2097152,
  1 / 1048576,
  1 / 524288,
  1 / 262144,
  1 / 131072,
  1 / 65536,
  1 / 32768,
  1 / 16384,
  1 / 9192,
  1 / 4096,
  1 / 2048,
  1 / 1024,
  1 / 512,
  1 / 256,
  1 / 128,
  1 / 64,
  1 / 32,
  1 / 16,
  1 / 8,
  1 / 4,
  1 / 2,
  1,
  2,
  4,
  8,
  16,
  32,
];

class ZoomConfig {
  double maxPxPerBp = 50;

  List<double> zoomLevels = [];

  late Range refRange;
  late double viewWidth;

  double? currentScale;

  bool isMinScale(double pixelOfRange) => pixelOfRange <= zoomLevels.first;

  bool isMaxScale(double pixelOfRange) => pixelOfRange.ceil() >= zoomLevels.last;

  List<double> get reversedZoomLevels => zoomLevels.reversed.toList();

  ZoomConfig(Range range, double viewWidth) {
    refRange = range;
    this.viewWidth = viewWidth;
    for (var i = 0; i < desiredZoomLevels.length; i++) {
      var _level = desiredZoomLevels[i];
      if (_level < maxPxPerBp)
        zoomLevels.add(_level.toDouble());
      else
        break; // once get to zoom level >= maxPxPerBp, quit
    }
    zoomLevels.add(maxPxPerBp);

    //make sure we don't zoom out too far
    while ((refRange.size * zoomLevels[0]) < viewWidth) {
      zoomLevels.removeAt(0);
    }
    zoomLevels.insert(0, viewWidth / (refRange.size));
  }

  double nextZoomLevel(double scale) {
    var index = zoomLevels.indexOf(scale);
    return zoomLevels[(index + 1).clamp(0, zoomLevels.length - 1)];
  }

  double nextLevel(double scale, int count) {
    var index = zoomLevels.indexOf(scale);
    int a = index + count;
    return zoomLevels[a.clamp(0, zoomLevels.length - 1)];
  }

  @override
  String toString() {
    return 'ZoomConfig{zoomLevels: $zoomLevels}';
  }

  void updateTargetScale(double pixelOfSeq) {
    currentScale = findTargetScale(pixelOfSeq);
  }

  /// 二分法查找缩放值对应的索引值
  double findTargetScale(double scale) {
    List<double> scales = reversedZoomLevels;
    final int size = scales.length;
    int min = 0;
    int max = size - 1;
    int mid = (min + max) >> 1;
    while (!(scale >= scales[mid] && scale < scales[mid - 1])) {
      if (scale >= scales[mid - 1]) {
        // 因为值往小区，index往大取，所以不能为mid -1
        max = mid;
      } else {
        min = mid + 1;
      }
      mid = (min + max) >> 1;
      if (min >= max) {
        break;
      }
      if (mid == 0) {
        break;
      }
    }
    return scales[mid];
  }
}
