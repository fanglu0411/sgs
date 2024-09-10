import 'dart:math';

class ScatterLabel {
  String text;
  Point<double> position;

  ScatterLabel(this.text, this.position);

  @override
  String toString() {
    return '{text: $text, position: $position}';
  }
}

// 检测重叠
bool isOverlapping(ScatterLabel a, ScatterLabel b) {
  const double padding = 20.0; // 标签之间的最小间距
  double dx = a.position.x - b.position.x;
  double dy = a.position.y - b.position.y;
  double distance = sqrt(dx * dx + dy * dy);
  return distance < padding;
}

// 移动标签以消除重叠
void resolveOverlaps(List<ScatterLabel> labels, double width, double height) {
  const double step = 2.0; // 每次移动的步长
  bool hasOverlap;

  do {
    hasOverlap = false;

    for (int i = 0; i < labels.length; i++) {
      for (int j = i + 1; j < labels.length; j++) {
        if (isOverlapping(labels[i], labels[j])) {
          // 移动标签以消除重叠
          labels[j].position += Point(step, step);

          // 保持标签在视图范围内
          if (labels[j].position.x > width) labels[j].position = Point(width, labels[j].position.y);
          if (labels[j].position.y > height) labels[j].position = Point(labels[j].position.x, height);

          hasOverlap = true;
        }
      }
    }
  } while (hasOverlap);
}
