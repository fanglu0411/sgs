import 'package:d4_scale/d4_scale.dart';
import 'dart:math' as math;

extension ScaleExtend<X extends num, Y extends num> on Scale<X, Y> {
  num get rangeWidth => (range.last - range[0]).abs();

  num get domainWidth => (domain.last - domain[0]).abs();

  double? operator [](X x) => this.call(x)?.toDouble();

  double? scale(X x) => this.call(x)?.toDouble();

  num get domainMin => math.min(domain.last, domain[0]);

  num get domainMax => math.max(domain.last, domain[0]);

  Y get rangeMin => math.min(range.last, range[0]);

  Y get rangeMax => math.max(range.last, range[0]);
}

ScaleLog<num> scaleLogFixed({
  List<num> domain = const [1, 10],
  List<num> range = const [0, 1],
  num base = 10,
}) {
  return ScaleLog.number(domain: domain.first == 0 ? fixLogScaleDomain(domain) : domain, range: range)..base = base;
}

List<num> fixLogScaleDomain(List<num> domain) {
  List<num> fixedDomain = domain;
  if (domain.last > 100)
    fixedDomain[0] = 1;
  else if (domain.last > 1)
    fixedDomain[0] = 0.1;
  else if (domain.last > .1)
    fixedDomain[0] = 0.01;
  else if (domain.last > .01)
    fixedDomain[0] = 0.001;
  else if (domain.last > .001)
    fixedDomain[0] = 0.0001;
  else
    fixedDomain[0] = 0.000001;
  return fixedDomain;
}

extension ScaleLogExt<X extends num> on ScaleLog<X> {
  fixDomain() {
    if (domain.first == 0) {
      this.domain = fixLogScaleDomain(domain);
    }
  }
}
