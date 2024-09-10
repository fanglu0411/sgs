import 'package:flutter_smart_genome/widget/track/common.dart';

class TrackLineEntry {
  late Range range;

  TrackLineEntry(this.range);

  get start => range.start;

  get end => range.end;
}