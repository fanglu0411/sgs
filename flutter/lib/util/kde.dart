import 'dart:math';

class KernelDensityEstimation {
  final int bandwidth;

  KernelDensityEstimation(this.bandwidth);

  // Gaussian 拉普拉斯核
  double kernel(double x) {
    return (1 / (sqrt(2 * pi) * bandwidth)) * exp(-(x * x) / (2 * bandwidth * bandwidth));
  }

  double density(List<Point> points, Point point) {
    double result = 0;
    for (var p in points) {
      double dist = sqrt((p.x - point.x) * (p.x - point.x) + (p.y - point.y) * (p.y - point.y));
      result += kernel(dist);
    }
    return result;
  }
}

class Point {
  final double x;
  final double y;

  Point(this.x, this.y);
}