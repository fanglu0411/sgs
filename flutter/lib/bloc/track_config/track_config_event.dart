import 'package:flutter_smart_genome/bean/gene.dart';
import 'package:flutter_smart_genome/page/compare/compare_common.dart';
import 'package:flutter_smart_genome/widget/track/base/track_data.dart';
import 'package:flutter_smart_genome/widget/track/base/track_session.dart';
import 'package:flutter_smart_genome/widget/track/chromosome/chromosome_data.dart';
import 'package:flutter_smart_genome/widget/track/common.dart';
import 'package:meta/meta.dart';

@immutable
class TrackConfigEvent {
  final List<Track>? tracks;
  final TrackSession? session;
  final TrackSession? session2;

  TrackConfigEvent({this.tracks, this.session, this.session2});
}

class ForceUpdateTracksEvent extends TrackConfigEvent {
  final bool genomeTrack;
  final bool scTrack;

  ForceUpdateTracksEvent({this.genomeTrack = true, this.scTrack = true});
}

class TrackBasicEvent extends TrackConfigEvent {
  TrackBasicEvent({
    TrackSession? session,
    TrackSession? session2,
  }) : super(session: session, session2: session2);
}

class CheckClipboardEvent extends TrackConfigEvent {
//  final String data;
  CheckClipboardEvent();
}

class SpeciesChangeEvent extends TrackConfigEvent {
  SpeciesChangeEvent({
    required TrackSession session,
  }) : super(session: session);
}

class SetCurrentSessionEvent extends TrackConfigEvent {
  final TrackSession session;

  SetCurrentSessionEvent(this.session);
}

class LoadSessionEvent extends TrackConfigEvent {
  LoadSessionEvent({
    TrackSession? session,
  }) : super(session: session);
}

class PositionRangeChangeEvent extends TrackConfigEvent {
  PositionRangeChangeEvent({
    TrackSession? session,
  }) : super(session: session);
}

class ChromosomeChangeEvent extends TrackConfigEvent {
  final ChromosomeData chromosome;
  final ChromosomeData? chromosome2;
  final Range? range;
  final Range? range2;

  ChromosomeChangeEvent({
    required this.chromosome,
    this.range,
    this.chromosome2,
    this.range2,
  });
}

class ToggleCompareModeEvent extends TrackConfigEvent {}

class TrackFilterEvent extends TrackConfigEvent {
  TrackFilterEvent({
    required List<Track>? tracks,
  }) : super(tracks: tracks);
}

class UpdateTrackListEvent extends TrackConfigEvent {
  UpdateTrackListEvent();
}

class FilterTrackWithKeywordEvent extends TrackConfigEvent {
  final String keyword;

  FilterTrackWithKeywordEvent(this.keyword);
}

class ReorderTrackEvent extends TrackConfigEvent {
  final int old;
  final int newIndex;

  ReorderTrackEvent(this.old, this.newIndex);
}

class ResetOrderTrackListEvent extends TrackConfigEvent {}

class ToggleSelectAllTrackEvent extends TrackConfigEvent {
  final bool selectAll;

  ToggleSelectAllTrackEvent(this.selectAll);
}

class ToggleTrackSelectionEvent extends TrackConfigEvent {
  final Track track;
  final bool selected;

  ToggleTrackSelectionEvent(this.track, this.selected);
}

class AddCustomTrackEvent extends TrackConfigEvent {
  final CustomTrack track;

  AddCustomTrackEvent({required this.track});
}

class AddHistoryEvent extends TrackConfigEvent {
  final PositionInfo positionInfo;

  AddHistoryEvent({required this.positionInfo});
}

/// =========== compare ============
class AddCompareItemEvent extends TrackConfigEvent {
  final CompareItem item;

  AddCompareItemEvent(this.item);
}

/// =========== compare ============
