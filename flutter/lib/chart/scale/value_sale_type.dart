import 'dart:math' as math;

enum ValueScaleType {
  LINEAR(),
  MAX_LIMIT(),
  LOG(),
  POW_HALF(),
}

enum LogType {
  LOG(base: math.e),
  LOG10(base: math.ln10),
  NEG_LOG10(base: math.ln10, po: -1);

  const LogType({
    required this.base,
    this.po = 1.0,
  });

  final double base;
  final double po;
}
