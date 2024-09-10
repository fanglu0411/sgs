import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/cell/data_category.dart';
import 'package:vector_math/vector_math_64.dart' hide Colors;

/// A widget that controls [DiTreDi] camera state - position, rotation, zoom.
class CanvasController extends ChangeNotifier {
  /// Scale factor for the model to fit in [-1, 1] bounds.
  double modelScale;

  /// Scale factor for the screen to draw [-1, 1] bounded model.
  double viewScale;

  /// User scale. By default it's 1.0.
  double userScale;

  /// Minimum scale applied by user. By default it's 0.8.
  double minUserScale;

  /// Maximum scale applied by user. By default it's 3.0.
  double maxUserScale;

  /// Camera rotation around X-axis (vertical).
  /// Minus moves camera "above" the model, with plus it's "below".
  double rotationX;

  /// Camera rotation around Y-axis (horizontal).
  double rotationY;

  /// Camera rotation around Z-axis (roll).
  double rotationZ;

  /// Translation of the displayed model on the screen.
  Offset translation;

  /// Light direction for 3D objects.
  Vector3 light;

  /// [light] strength.
  /// Varies from 0.0 to infinity.
  /// Defaults to 1.0.
  double lightStrength;

  /// Ambient light strength.
  /// Varies from 0.0 to 1.0.
  /// Set to 1.0 to use colors without light effect.
  /// Defaults to 0.1.
  double ambientLightStrength;

  Vector3? anchor;

  Matrix4? matrix4;

  Rect? selectedRect;
  bool? interacting;
  late double pointSize;
  double pointOpacity = 1.0;
  bool isSpatial;
  Map<String, DataCategory>? legendMap;
  int? maxDrawCount;

  /// Creates a new [DiTreDiController] instance.
  CanvasController({
    this.modelScale = 1,
    this.viewScale = 1,
    this.userScale = 1,
    this.minUserScale = 0.8,
    this.maxUserScale = 10.0,
    this.rotationX = -45,
    this.rotationY = 45,
    this.rotationZ = 0,
    this.translation = const Offset(0, 0),
    Vector3? light,
    this.anchor,
    this.lightStrength = 1.0,
    this.ambientLightStrength = 0.1,
    this.matrix4,
    this.selectedRect,
    this.interacting = false,
    this.pointSize = 2,
    this.pointOpacity = 1.0,
    this.isSpatial = false,
    this.maxDrawCount = 100000,
    this.legendMap,
  }) : light = light ?? Vector3(10, -20, 20).normalized() {
    assert(
      ambientLightStrength >= 0 && ambientLightStrength <= 1,
      "ambientLight should be between 0.0 and 1.0",
    );
  }

  /// Updates controller and notifies listeners (including [DiTreDi] widget).
  void update({
    double? viewScale,
    double? userScale,
    double? minUserScale,
    double? maxUserScale,
    double? rotationX,
    double? rotationY,
    double? rotationZ,
    Offset? translation,
    Vector3? light,
    double? lightStrength,
    double? ambientLightStrength,
    Vector3? anchor,
    Matrix4? matrix4,
    Rect? selectRect,
    bool? interacting = false,
    double? pointSize,
    double? pointOpacity,
    bool? isSpatial,
    int? maxDrawCount,
    Map<String, DataCategory>? legendMap,
  }) {
    assert(
      ambientLightStrength == null || ambientLightStrength >= 0 && ambientLightStrength <= 1,
      "ambientLight should be between 0.0 and 1.0",
    );

    this.viewScale = viewScale ?? this.viewScale;
    this.minUserScale = (minUserScale ?? this.minUserScale).clamp(0, double.infinity);
    this.maxUserScale = (maxUserScale ?? this.maxUserScale).clamp(this.minUserScale, double.infinity);
    this.userScale = (userScale ?? this.userScale).clamp(this.minUserScale, this.maxUserScale);
    this.rotationX = rotationX ?? this.rotationX;
    this.rotationY = rotationY ?? this.rotationY;
    this.rotationZ = rotationZ ?? this.rotationZ;
    this.translation = translation ?? this.translation;
    this.lightStrength = (lightStrength ?? this.lightStrength).clamp(0, double.infinity);
    this.ambientLightStrength = (ambientLightStrength ?? this.ambientLightStrength).clamp(0, 1);
    if (light != null) {
      light.normalizeInto(this.light);
    }
    this.anchor = anchor ?? this.anchor;
    this.matrix4 = matrix4 ?? this.matrix4;
    this.selectedRect = selectRect ?? this.selectedRect;
    this.interacting = interacting ?? this.interacting;
    this.pointSize = pointSize ?? this.pointSize;
    this.pointOpacity = pointOpacity ?? this.pointOpacity;
    this.isSpatial = isSpatial ?? this.isSpatial;
    this.legendMap = legendMap ?? this.legendMap;
    this.maxDrawCount = maxDrawCount ?? this.maxDrawCount;
    notifyListeners();
  }

  // double get pointScaledSize => (pointSize + (matrix4!.getMaxScaleOnAxis() - 1) / (maxUserScale - 1) * 10) / matrix4!.getMaxScaleOnAxis();

  double get currentPointSize => isSpatial
      ? pointSize * 1.5 //
      : (pointSize + (matrix4!.getMaxScaleOnAxis() - 1) / (maxUserScale - 1) * 10) / matrix4!.getMaxScaleOnAxis();

  /// Combination of all scale factors to pixel coordinates.
  double get scale => modelScale * viewScale * userScale;

  bool groupChecked(String group) {
    return legendMap![group]?.focused ?? false;
  }

  Color getGroupColor(String group, double opacity) {
    return legendMap![group]?.drawColor.withOpacity(opacity) ?? Colors.grey;
  }

  List<String> get orderedGroup {
    return legendMap!.keys.sortedBy((e) => legendMap![e]!.focused ? 2 : (legendMap![e]!.checked ? 1 : -1));
  }
}
