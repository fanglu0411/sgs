import 'dart:math';

class KdNode {
  List point;
  KdNode? left;
  KdNode? right;

  KdNode(this.point, {this.left, this.right});
}

class KdTree {
  KdNode? root;

  KdTree(List<List> points) {
    root = buildTree(points, 0);
  }

  KdNode? buildTree(List<List> points, int depth) {
    if (points.isEmpty) return null;

    int axis = depth % 2; // 0 for x, 1 for y
    points.sort((a, b) => axis == 0 ? a[1].compareTo(b[1]) : a[2].compareTo(b[2]));

    int medianIndex = points.length ~/ 2;
    List median = points[medianIndex];

    return KdNode(
      median,
      left: buildTree(points.sublist(0, medianIndex), depth + 1),
      right: buildTree(points.sublist(medianIndex + 1), depth + 1),
    );
  }

  void nearestNeighbors(List target, double radius, List<List> result, {KdNode? node, int depth = 0}) {
    if (node == null) return;

    int axis = depth % 2;
    double distance = sqrt(pow(target[1] - node.point[1], 2) + pow(target[2] - node.point[2], 2));

    if (distance <= radius) {
      result.add(node.point);
    }

    double delta = (axis == 0 ? target[1] - node.point[1] : target[2] - node.point[2]);
    double delta2 = delta * delta;

    KdNode? nearBranch = delta <= 0 ? node.left : node.right;
    KdNode? farBranch = delta <= 0 ? node.right : node.left;

    nearestNeighbors(target, radius, result, node: nearBranch, depth: depth + 1);

    if (delta2 < radius * radius) {
      nearestNeighbors(target, radius, result, node: farBranch, depth: depth + 1);
    }
  }
}

double gaussianKernel(double distance, double bandwidth) {
  return (1 / (bandwidth * sqrt(2 * pi))) * exp(-0.5 * pow(distance / bandwidth, 2));
}

double calculateDensity(List p, List<List> neighbors, double bandwidth) {
  double density = 0.0;
  for (var neighbor in neighbors) {
    double distance = sqrt(pow(p[1] - neighbor[1], 2) + pow(p[2] - neighbor[2], 2));
    density += gaussianKernel(distance, bandwidth);
  }
  return density;
}

class DensityPoint {
  double x;
  double y;
  double density;

  DensityPoint(this.x, this.y, this.density);
}

List<DensityPoint> calculateDensities(List<List> points, double bandwidth) {
  KdTree kdTree = KdTree(points);
  List<DensityPoint> densityPoints = [];

  for (var point in points) {
    List<List> neighbors = [];
    kdTree.nearestNeighbors(point, bandwidth * 3, neighbors); // 搜索半径为 bandwidth 的 3 倍
    double density = calculateDensity(point, neighbors, bandwidth);
    densityPoints.add(DensityPoint(point[1], point[2], density));
  }

  return densityPoints;
}
