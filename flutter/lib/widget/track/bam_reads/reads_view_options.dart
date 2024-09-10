import 'package:dartx/dartx.dart';
import 'package:flutter_smart_genome/bean/feature_beans.dart';
import 'package:flutter_smart_genome/components/setting_config_widget.dart';
import 'package:flutter_smart_genome/widget/track/base/track_menu_config.dart';

enum ReadsColorOption {
  strand_default,
  no_color,
  strand,
  mapping_quality,
  // XS_or_TS_tag,
  pair_orientation,
  insert_size,
  melthylation,
  modification,
  XS_tag,
  TS_tag,
}

enum ReadsFilterOption {
  PCR_Optical_duplicate_reads,
  //hide  read failing  vendor QC,
  read_failing_vendor_QC,
  read_with_missing_mate_pairs,
  read_that_with_improper_pairs,
  secondary_alignments,
  supplementary_alignments,
  unmapped_reads,
  read_aligned_to_the_forward_strand,
  read_aligned_to_the_reverse_strand,
  unspliced_reads,
  // re_estimate_insert_size_stats,
}

enum ReadsSortOption {
  start_location,
  strand,
  base_pair,
  tag,
}

Map<ReadsSortOption, Function1<BamReadsFeature, Comparable>> readsSortFunctions = {
  ReadsSortOption.start_location: (f1) => f1.range.start,
  ReadsSortOption.strand: (f1) => -f1.strand,
  ReadsSortOption.base_pair: (f1) => f1.strand,
  ReadsSortOption.tag: (f1) => f1.strand,
};

enum ReadsGroupOption {
  strand,
  sample,
  // pair_orientation,
}

List<SettingItem> colorByMenus({ReadsColorOption checkedOption = ReadsColorOption.strand_default}) {
  var groupItem = SettingItem.checkGroup(
    key: TrackContextMenuKey.bam_color_by,
    value: checkedOption,
    options: ReadsColorOption.values
        .map(
          (e) =>
          OptionItem(
            e.toString().replaceFirst('ReadsColorOption.', 'Color by ').replaceAll('_', ' '),
            e,
          ),
    )
        .toList(),
  );
  return [groupItem];
}

List<SettingItem> filterByMenus({List<ReadsFilterOption>? checked}) {
  return ReadsFilterOption.values
      .map(
        (e) =>
        SettingItem.toggle(
          title: e.toString().replaceFirst('ReadsFilterOption.', 'Filter ').replaceAll('_', ' '),
          value: checked?.contains(e) ?? false,
          key: e,
          // suffix: checked != null && checked.contains(e) ? IconButton(icon: Icon(Icons.check), onPressed: null) : null,
        ),
  )
      .toList();
}

List<SettingItem> groupByMenus({required ReadsGroupOption checkedOption}) {
  var groupItem = SettingItem.checkGroup(
    key: TrackContextMenuKey.bam_group_by,
    value: checkedOption,
    options: ReadsGroupOption.values
        .map(
          (e) =>
          OptionItem(
            e.toString().replaceFirst('ReadsGroupOption.', 'Group by ').replaceAll('_', ' '),
            e,
          ),
    )
        .toList(),
  );
  return [groupItem];
}

List<SettingItem> sortByMenus({ReadsSortOption checkedOption = ReadsSortOption.start_location}) {
  var groupItem = SettingItem.checkGroup(
    key: TrackContextMenuKey.bam_sort_by,
    value: checkedOption,
    options: ReadsSortOption.values
        .map(
          (e) =>
          OptionItem(
            e.toString().replaceFirst('ReadsSortOption.', 'Sort by ').replaceAll('_', ' '),
            e,
          ),
    )
        .toList(),
  );
  return [groupItem];
}