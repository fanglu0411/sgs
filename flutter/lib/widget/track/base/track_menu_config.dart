import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:flutter_smart_genome/chart/scale/value_sale_type.dart';
import 'package:flutter_smart_genome/components/setting_config_widget.dart';
import 'package:flutter_smart_genome/page/track/track_ui_config_bean.dart';
import 'package:flutter_smart_genome/widget/track/base/track_data.dart';
import 'package:flutter_smart_genome/widget/track/cartesian/cartesian_track_painter.dart';
import 'package:flutter_smart_genome/widget/track/hic/hic_track_widget.dart';
import 'package:flutter_smart_genome/widget/track/relation/relation_view_type.dart';

const Map menuKeyMap = const {
  TrackContextMenuKey.track_height: 'track_height',
  TrackContextMenuKey.track_color: 'track_color',
  TrackContextMenuKey.track_max_height: 'track_max_height',
  TrackContextMenuKey.feature_height: 'feature_height',
  TrackContextMenuKey.label_font_size: 'label_font_size',
  TrackContextMenuKey.label_font_color: 'label_color',
  TrackContextMenuKey.show_label: 'show_label',
  TrackContextMenuKey.show_child_label: 'show_child_label',
  TrackContextMenuKey.feature_group_color: 'feature_group_color',
  TrackContextMenuKey.feature_legends_visible: 'show_legends',
  TrackContextMenuKey.densityMode: 'density_mode',
  TrackContextMenuKey.track_collapse_mode: 'collapse_mode',
  TrackContextMenuKey.cartesian_chart_type: 'cartesian_chart_type',
  TrackContextMenuKey.value_scale_type: 'value_scale_type',
  TrackContextMenuKey.max_value: 'custom_max_value',
  TrackContextMenuKey.min_value: 'custom_min_value',
  TrackContextMenuKey.cartesian_value_type: 'cartesian_value_type',
  TrackContextMenuKey.color_map: 'color_map',
  TrackContextMenuKey.bar_width: 'bar_width',
  TrackContextMenuKey.line_color: 'line_color',
  TrackContextMenuKey.peak_co_access: 'peak_co_access',
  TrackContextMenuKey.hic_view_type: 'hic_display_mode',
  TrackContextMenuKey.hic_normalize: 'hic_normalize',
  TrackContextMenuKey.relation_view_type: 'relation_display_mode',
  TrackContextMenuKey.radius: 'radius',
  TrackContextMenuKey.stack_mode: 'stack_mode',
};

enum TrackContextMenuKey {
  range_info,
  meta_data,
  zoom_to_feature,
  add_compare,
  show_track_title,
  pin_top,
  gene_info,
  cartesian_chart_type,
  track_color,
  track_theme,
  feature_legends_visible,
  track_height,
  feature_height,
  track_max_height,
  show_label,
  show_child_label,
  label_font_size,
  label_font_color,
  rename_track,
  remove_track,
  save_image,
  track_info,
  track_collapse_mode,
  search,
  ref_seq,
  ref_protein,
  densityMode,
  value_scale_type,
  track_animation_enabled,
  track_animation_speed,
  feature_group_color,
  histogram_scale,
  active_data_view,
  bam_view_as,
  bam_color_by,
  bam_filter_by,
  bam_sort_by,
  bam_group_by,
  stack_chart_split,
  max_value,
  min_value,
  cartesian_value_type,
  color_map,
  stack_mode,

  //hic
  data_current_view,
  interactive_circle_view,
  hic_view_type,
  relation_view_type,
  hic_normalize,
  cell_browse,
  bar_width,
  efp,
  r_terminal,
  peak_co_access,
  line_color,
  force_load_feature,
  radius,
  search_in_sc,
}

class TrackMenuConfig {
  static List<SettingItem> efpMenus = fromKeys([
    TrackContextMenuKey.efp,
    TrackContextMenuKey.save_image,
  ]);

  static List<SettingItem> rangeSettings = fromKeys([
    TrackContextMenuKey.range_info,
    TrackContextMenuKey.meta_data,
    TrackContextMenuKey.zoom_to_feature,
    // TrackContextMenuKey.add_compare,
  ]);

  static List<SettingItem> geneSettings = fromKeys([
//    TrackContextMenuKey.gene_info,
    TrackContextMenuKey.range_info,
    TrackContextMenuKey.meta_data,
    TrackContextMenuKey.search_in_sc,
    TrackContextMenuKey.zoom_to_feature,
    // TrackContextMenuKey.add_compare,
  ]);

  static List<SettingItem> rootTrackSettings = fromKeys([
    TrackContextMenuKey.pin_top,
    TrackContextMenuKey.rename_track,
    TrackContextMenuKey.remove_track,
    TrackContextMenuKey.track_info,
  ]);

  static List<SettingItem> cartesianTrackSettings = fromKeys([
    TrackContextMenuKey.cartesian_chart_type,
    TrackContextMenuKey.cartesian_value_type,
    TrackContextMenuKey.stack_chart_split,
    TrackContextMenuKey.max_value,
    TrackContextMenuKey.track_color,
    // TrackContextMenuKey.color_map,
//    TrackContextMenuKey.feature_style,
    TrackContextMenuKey.track_height,
    // TrackContextMenuKey.r_terminal,
    TrackContextMenuKey.active_data_view,
    TrackContextMenuKey.rename_track,
    TrackContextMenuKey.remove_track,
    TrackContextMenuKey.save_image,
  ], OptionListType.row);

  static List<SettingItem> rangeTrackSettings = fromKeys([
    TrackContextMenuKey.track_collapse_mode,
//    TrackContextMenuKey.search,
//    TrackContextMenuKey.track_color,
    TrackContextMenuKey.track_max_height,
    TrackContextMenuKey.feature_height,
    TrackContextMenuKey.track_theme,
    // TrackContextMenuKey.histogram_scale,
    // TrackContextMenuKey.feature_group_color,
    TrackContextMenuKey.feature_legends_visible,
    TrackContextMenuKey.show_label,
    TrackContextMenuKey.show_child_label,
    TrackContextMenuKey.label_font_size,
    TrackContextMenuKey.label_font_color,
    TrackContextMenuKey.active_data_view,
    TrackContextMenuKey.rename_track,
    TrackContextMenuKey.remove_track,
    TrackContextMenuKey.save_image,
  ], OptionListType.row);

  static List<SettingItem> cellExpTrackSettings = fromKeys([
    // TrackContextMenuKey.track_collapse_mode,
//    TrackContextMenuKey.search,
//    TrackContextMenuKey.track_color,
    TrackContextMenuKey.track_max_height,
    TrackContextMenuKey.feature_height,
    // TrackContextMenuKey.track_theme,
    TrackContextMenuKey.bar_width,
    // TrackContextMenuKey.histogram_scale,
    // TrackContextMenuKey.feature_group_color,
    TrackContextMenuKey.feature_legends_visible,
    TrackContextMenuKey.show_label,
    TrackContextMenuKey.label_font_size,
    TrackContextMenuKey.label_font_color,
    TrackContextMenuKey.cell_browse,
    TrackContextMenuKey.active_data_view,
    TrackContextMenuKey.rename_track,
    TrackContextMenuKey.remove_track,
    TrackContextMenuKey.save_image,
  ], OptionListType.row);

  static List<SettingItem> bedCartesianTrackSettings = fromKeys([
//    TrackContextMenuKey.track_collapse_mode,
    TrackContextMenuKey.cartesian_chart_type,
    TrackContextMenuKey.cartesian_value_type,
    TrackContextMenuKey.max_value,
    // TrackContextMenuKey.stack_chart_split,
//    TrackContextMenuKey.feature_legends_visible,
    TrackContextMenuKey.track_color,
    TrackContextMenuKey.track_height,
    TrackContextMenuKey.active_data_view,
    TrackContextMenuKey.rename_track,
    TrackContextMenuKey.remove_track,
    TrackContextMenuKey.save_image,
  ]);

  static List<SettingItem> bedFeatureTrackSettings = fromKeys([
    TrackContextMenuKey.track_max_height,
    TrackContextMenuKey.feature_height,
    TrackContextMenuKey.show_label,
    TrackContextMenuKey.meta_data,
    TrackContextMenuKey.active_data_view,
    TrackContextMenuKey.rename_track,
    TrackContextMenuKey.remove_track,
    TrackContextMenuKey.save_image,
  ]);

  static List<SettingItem> vcfCartesianTrackSettings = fromKeys([
//    TrackContextMenuKey.track_collapse_mode,
    TrackContextMenuKey.track_color,
    TrackContextMenuKey.cartesian_chart_type,
    TrackContextMenuKey.cartesian_value_type,
    TrackContextMenuKey.max_value,
    TrackContextMenuKey.stack_chart_split,
//    TrackContextMenuKey.feature_legends_visible,
//     TrackContextMenuKey.show_label,
    TrackContextMenuKey.active_data_view,
    TrackContextMenuKey.rename_track,
    TrackContextMenuKey.remove_track,
    TrackContextMenuKey.save_image,
  ]);

  static List<SettingItem> vcfTrackSettings = fromKeys([
//    TrackContextMenuKey.track_collapse_mode,
    TrackContextMenuKey.color_map,
    TrackContextMenuKey.track_max_height,
    TrackContextMenuKey.feature_height,
//    TrackContextMenuKey.feature_legends_visible,
    TrackContextMenuKey.show_label,
    TrackContextMenuKey.label_font_size,
//     TrackContextMenuKey.label_font_color,
//     TrackContextMenuKey.track_theme,
    TrackContextMenuKey.meta_data,
    TrackContextMenuKey.active_data_view,
    TrackContextMenuKey.rename_track,
    TrackContextMenuKey.remove_track,
    TrackContextMenuKey.save_image,
  ]);

  static List<SettingItem> vcfSampleTrackSettings = fromKeys([
//    TrackContextMenuKey.track_collapse_mode,
    TrackContextMenuKey.color_map,
    TrackContextMenuKey.track_max_height,
    TrackContextMenuKey.feature_height,
//    TrackContextMenuKey.feature_legends_visible,
//     TrackContextMenuKey.show_label,
    TrackContextMenuKey.label_font_size,
    TrackContextMenuKey.label_font_color,
    TrackContextMenuKey.show_label,
    TrackContextMenuKey.active_data_view,
    TrackContextMenuKey.rename_track,
    TrackContextMenuKey.remove_track,
    TrackContextMenuKey.save_image,
  ]);

  static List<SettingItem> hicTrackSettings = fromKeys([
//    TrackContextMenuKey.track_collapse_mode,
    TrackContextMenuKey.hic_normalize,
    TrackContextMenuKey.hic_view_type,
    // TrackContextMenuKey.data_current_view,
    TrackContextMenuKey.track_color,
    TrackContextMenuKey.track_max_height,
    TrackContextMenuKey.max_value,
    TrackContextMenuKey.min_value,
    TrackContextMenuKey.active_data_view,
    TrackContextMenuKey.rename_track,
    TrackContextMenuKey.remove_track,
    TrackContextMenuKey.save_image,
  ]);

  static List<SettingItem> bigWigTrackSettings = fromKeys([
//    TrackContextMenuKey.track_collapse_mode,
//     TrackContextMenuKey.cartesian_chart_type,
    TrackContextMenuKey.value_scale_type,
    TrackContextMenuKey.cartesian_value_type,
    TrackContextMenuKey.max_value,
    TrackContextMenuKey.color_map,
    TrackContextMenuKey.track_height,
    TrackContextMenuKey.stack_chart_split,
    TrackContextMenuKey.active_data_view,
    TrackContextMenuKey.rename_track,
    TrackContextMenuKey.remove_track,
    TrackContextMenuKey.save_image,
  ], OptionListType.row);

  static List<SettingItem> methyTrackSettings = fromKeys([
//    TrackContextMenuKey.track_collapse_mode,
//     TrackContextMenuKey.value_scale_type,
//     TrackContextMenuKey.cartesian_value_type,
    TrackContextMenuKey.stack_mode,
    TrackContextMenuKey.max_value,
    TrackContextMenuKey.color_map,
    TrackContextMenuKey.track_height,
    TrackContextMenuKey.stack_chart_split,
    TrackContextMenuKey.active_data_view,
    TrackContextMenuKey.rename_track,
    TrackContextMenuKey.remove_track,
    TrackContextMenuKey.save_image,
  ], OptionListType.row);

  static List<SettingItem> basicTrackContextMenus = fromKeys([
    // TrackContextMenuKey.pin_top,
    TrackContextMenuKey.track_height,
    TrackContextMenuKey.track_color,
    TrackContextMenuKey.active_data_view,
    TrackContextMenuKey.rename_track,
    TrackContextMenuKey.remove_track,
    TrackContextMenuKey.save_image,
  ], OptionListType.row);

  static List<SettingItem> basicTrackItemContextMenus = fromKeys([
    TrackContextMenuKey.range_info,
    TrackContextMenuKey.meta_data,
    TrackContextMenuKey.zoom_to_feature,
    // TrackContextMenuKey.add_compare,
  ]);

  static List<SettingItem> bamTrackSettings = fromKeys([
//    TrackContextMenuKey.track_collapse_mode,
//     TrackContextMenuKey.pin_top,
    TrackContextMenuKey.cartesian_chart_type,
    TrackContextMenuKey.value_scale_type,
    TrackContextMenuKey.cartesian_value_type,
    TrackContextMenuKey.max_value,
    TrackContextMenuKey.track_height,
    TrackContextMenuKey.track_color,
    TrackContextMenuKey.active_data_view,
    TrackContextMenuKey.rename_track,
    TrackContextMenuKey.remove_track,
    TrackContextMenuKey.save_image,
  ], OptionListType.row);

  static List<SettingItem> bamReadsTrackSettings = fromKeys([
//    TrackContextMenuKey.track_collapse_mode,
    TrackContextMenuKey.track_max_height,
    TrackContextMenuKey.feature_height,

    TrackContextMenuKey.bam_view_as,
    TrackContextMenuKey.bam_color_by,
    TrackContextMenuKey.bam_filter_by,
    TrackContextMenuKey.bam_sort_by,
    // TrackContextMenuKey.bam_group_by,
    TrackContextMenuKey.meta_data,
    TrackContextMenuKey.active_data_view,
    TrackContextMenuKey.rename_track,
    TrackContextMenuKey.remove_track,
    TrackContextMenuKey.save_image,
  ], OptionListType.row);

  static List<SettingItem> refTrackSettings = fromKeys([
//    TrackContextMenuKey.track_height,
//    TrackContextMenuKey.feature_theme,
    TrackContextMenuKey.ref_seq,
    TrackContextMenuKey.ref_protein,
    TrackContextMenuKey.label_font_size,
//    TrackContextMenuKey.label_font_color,
    TrackContextMenuKey.track_theme,
    TrackContextMenuKey.rename_track,
    TrackContextMenuKey.remove_track,
    TrackContextMenuKey.save_image,
  ]);

  static List<SettingItem> FeatureTrackTitleSettings = fromKeys([
    TrackContextMenuKey.track_color,
    TrackContextMenuKey.track_theme,
    TrackContextMenuKey.show_label,
    TrackContextMenuKey.save_image,
  ]);

  static List<SettingItem> globalTrackSettings = fromKeys([
//    TrackContextMenuKey.cartesian_group,
//    TrackContextMenuKey.track_collapse_mode,
    TrackContextMenuKey.track_animation_enabled,
//    TrackContextMenuKey.track_animation_speed,
    TrackContextMenuKey.track_color,
    TrackContextMenuKey.track_height,
//    TrackContextMenuKey.feature_style,
//    TrackContextMenuKey.feature_group_color,
//    TrackContextMenuKey.feature_legends_visible,
//    TrackContextMenuKey.show_label,
//    TrackContextMenuKey.label_font_size,
//    TrackContextMenuKey.label_font_color,
    TrackContextMenuKey.save_image,
  ], OptionListType.collapse);

  static List<SettingItem> gffTrackBasicStyleSettings = fromKeys([
//    TrackContextMenuKey.track_collapse_mode,
    TrackContextMenuKey.track_color,
    TrackContextMenuKey.feature_height,
//    TrackContextMenuKey.feature_theme,
    TrackContextMenuKey.feature_group_color,
//    TrackContextMenuKey.feature_legends_visible,
    TrackContextMenuKey.show_label,
    TrackContextMenuKey.label_font_size,
    TrackContextMenuKey.label_font_color,
  ]);

  static List<SettingItem> interactiveSettings = fromKeys([
//    TrackContextMenuKey.track_collapse_mode,
    TrackContextMenuKey.track_color,
    TrackContextMenuKey.track_height,
    TrackContextMenuKey.max_value,
    TrackContextMenuKey.min_value,
    TrackContextMenuKey.data_current_view,
    TrackContextMenuKey.relation_view_type,
    TrackContextMenuKey.interactive_circle_view,
    TrackContextMenuKey.active_data_view,
    TrackContextMenuKey.rename_track,
    TrackContextMenuKey.remove_track,
    TrackContextMenuKey.save_image,
  ]);

  static List<SettingItem> peakTrackSettings = fromKeys([
//    TrackContextMenuKey.track_collapse_mode,
    TrackContextMenuKey.track_color,
    TrackContextMenuKey.track_max_height,
    TrackContextMenuKey.feature_height,
    TrackContextMenuKey.peak_co_access,
    TrackContextMenuKey.cell_browse,
    TrackContextMenuKey.active_data_view,
    TrackContextMenuKey.rename_track,
    TrackContextMenuKey.remove_track,
    TrackContextMenuKey.save_image,
  ], OptionListType.row);

  static List<SettingItem> coAccessTrackSettings = fromKeys([
//    TrackContextMenuKey.track_collapse_mode,
//     TrackContextMenuKey.track_max_height,
    TrackContextMenuKey.track_color,
    TrackContextMenuKey.track_height,
    TrackContextMenuKey.max_value,
    TrackContextMenuKey.min_value,
    TrackContextMenuKey.peak_co_access,
    TrackContextMenuKey.active_data_view,
    TrackContextMenuKey.rename_track,
    TrackContextMenuKey.remove_track,
    TrackContextMenuKey.save_image,
  ], OptionListType.row);

  static List<SettingItem> groupCoverageTrackSettings = fromKeys([
//    TrackContextMenuKey.track_collapse_mode,
    TrackContextMenuKey.value_scale_type,
    TrackContextMenuKey.cartesian_value_type,
    // TrackContextMenuKey.stack_chart_split,
    TrackContextMenuKey.color_map,
    TrackContextMenuKey.track_max_height,
    TrackContextMenuKey.track_height,
    TrackContextMenuKey.cell_browse,
    TrackContextMenuKey.active_data_view,
    TrackContextMenuKey.rename_track,
    TrackContextMenuKey.remove_track,
    TrackContextMenuKey.save_image,
  ], OptionListType.row);

  static List<SettingItem> eqtlTrackSettings = fromKeys([
    // TrackContextMenuKey.value_scale_type,
    TrackContextMenuKey.min_value,
    TrackContextMenuKey.max_value,
    TrackContextMenuKey.track_color,
    TrackContextMenuKey.radius,
    TrackContextMenuKey.track_height,
    TrackContextMenuKey.active_data_view,
    TrackContextMenuKey.rename_track,
    TrackContextMenuKey.remove_track,
    TrackContextMenuKey.save_image,
  ], OptionListType.row);

  static List<SettingItem> fromKeys(List<TrackContextMenuKey?> keys, [OptionListType optionListType = OptionListType.row]) {
    return keys.map((key) => fromKey(key, optionListType)).toList();
  }

  static SettingItem fromKey(TrackContextMenuKey? key, [OptionListType optionListType = OptionListType.expanded]) {
    SettingItem item;
    switch (key!) {
      case TrackContextMenuKey.search_in_sc:
        item = SettingItem.button(title: 'SC Gene Expression', key: key, suffix: Icon(Icons.scatter_plot));
        break;
      case TrackContextMenuKey.range_info:
        item = SettingItem.button(title: 'Feature Info', key: key, suffix: Icon(Icons.info_outline));
        break;
      case TrackContextMenuKey.meta_data:
        item = SettingItem.button(title: 'Metadata', key: key, suffix: Icon(Icons.code));
        break;
      case TrackContextMenuKey.zoom_to_feature:
        item = SettingItem.button(title: 'Zoom in to Range', key: key, suffix: Icon(Icons.zoom_in));
        break;
      case TrackContextMenuKey.add_compare:
        item = SettingItem.button(title: 'Add to Compare List', key: key, suffix: Icon(Icons.compare));
        break;
      case TrackContextMenuKey.gene_info:
        item = SettingItem.button(title: 'Gene Info', key: key, suffix: Icon(Icons.info_outline));
        break;
      case TrackContextMenuKey.cartesian_chart_type:
        item = SettingItem.checkGroup(
          title: 'Chart Type',
          key: key,
          value: CartesianChartType.bar,
          optionListType: optionListType,
          options: <OptionItem>[
            OptionItem('Bar', CartesianChartType.bar, Icon(Foundation.graph_bar)),
            OptionItem('Linear', CartesianChartType.linear, Icon(AntDesign.linechart)),
            OptionItem('Area', CartesianChartType.area, Icon(AntDesign.areachart)),
            // OptionItem('Heatmap', CartesianChartType.heatmap, Icon(MaterialIcons.map)),
            // OptionItem('Dot plot', CartesianChartType.plot, Icon(AntDesign.dotchart)),
          ],
        );
        break;
      case TrackContextMenuKey.track_animation_enabled:
        item = SettingItem.toggle(title: 'Animation', key: key, value: !kIsWeb);
        break;
      case TrackContextMenuKey.track_animation_speed:
        item = SettingItem.range(title: 'Animation speed', key: key, value: 300.0, min: 100.0, max: 500.0, step: 10.0);
        break;
      case TrackContextMenuKey.track_color:
        item = SettingItem.color(title: 'Track Color', key: key, value: Colors.green);
        break;
      case TrackContextMenuKey.histogram_scale:
        item = SettingItem.range(title: 'Feature Visible Scale', key: key, value: 100.0, min: 20.0, max: 1000.0, step: 100.0);
        break;
      case TrackContextMenuKey.track_theme:
        item = SettingItem.button(
          title: 'Track Theme',
          key: key,
          suffix: IconButton(icon: Icon(Icons.keyboard_arrow_right, size: 24), onPressed: null),
        );
        break;
      case TrackContextMenuKey.feature_group_color:
        item = SettingItem.color(title: 'Feature Group Color', key: key, value: Colors.green.withAlpha(30));
        break;
      case TrackContextMenuKey.feature_legends_visible:
        item = SettingItem.toggle(title: 'Show Legends', key: key, value: false);
        break;
      case TrackContextMenuKey.show_label:
        item = SettingItem.toggle(title: 'Show Label', key: key, value: true);
        break;
      case TrackContextMenuKey.show_child_label:
        item = SettingItem.toggle(title: 'Show Child Label', key: key, value: false);
        break;
      case TrackContextMenuKey.label_font_size:
        item = SettingItem.range(title: 'Font Size', key: key, value: 10.0, min: 6.0, max: 20.0, step: 1.0);
        break;
      case TrackContextMenuKey.label_font_color:
        item = SettingItem.color(title: 'Text Color', key: key, value: Colors.black54);
        break;
      case TrackContextMenuKey.line_color:
        item = SettingItem.color(title: 'Line Color', key: key, value: Colors.grey);
        break;
      case TrackContextMenuKey.track_height:
        item = SettingItem.range(title: 'Track Height', key: key, value: 100.0, min: 20.0, max: 1000.0, step: 10);
        break;
      case TrackContextMenuKey.feature_height:
        item = SettingItem.range(title: 'Feature Height', key: key, value: 12.0, min: 4.0, max: 100.0, step: 2);
        break;
      case TrackContextMenuKey.track_max_height:
        item = SettingItem.range(title: 'Track Max Height', key: key, enabled: false, value: 300.0, min: 50.0, max: 1000.0, step: 50);
        break;
      case TrackContextMenuKey.rename_track:
        item = SettingItem.button(title: 'Rename Track', key: key, suffix: Icon(Icons.edit));
        break;
      case TrackContextMenuKey.remove_track:
        item = SettingItem.button(title: 'Remove Track', key: key, suffix: Icon(Icons.delete));
        break;
      case TrackContextMenuKey.save_image:
        item = SettingItem.button(title: 'Save Image', key: key, suffix: Icon(Icons.image));
        break;
      case TrackContextMenuKey.track_collapse_mode:
        item = SettingItem.checkGroup(
          title: 'Track Mode',
          key: key,
          value: TrackCollapseMode.expand,
          optionListType: optionListType,
          options: <OptionItem>[
            OptionItem('Expand', TrackCollapseMode.expand),
            OptionItem('Collapse', TrackCollapseMode.collapse),
          ],
        );
        break;
      case TrackContextMenuKey.efp:
        item = SettingItem.button(title: 'Multi Analysis of eFP', key: key);
        break;
      case TrackContextMenuKey.search:
        item = SettingItem.button(
          title: 'Local Feature Search',
          key: key,
          suffix: Icon(Icons.search),
        );
        break;
      case TrackContextMenuKey.ref_seq:
        item = SettingItem.row(
          key: key,
          title: 'Sequence',
          children: [
            SettingItem.color(title: 'A', key: 'A', value: Colors.black54, fieldType: FieldType.row_color),
            SettingItem.color(title: 'T', key: 'T', value: Colors.black54, fieldType: FieldType.row_color),
            SettingItem.color(title: 'C', key: 'C', value: Colors.black54, fieldType: FieldType.row_color),
            SettingItem.color(title: 'G', key: 'G', value: Colors.black54, fieldType: FieldType.row_color),
          ],
        );
        break;
      case TrackContextMenuKey.ref_protein:
        item = SettingItem.toggle(title: 'Show Protein', key: key, value: true);
        break;
      case TrackContextMenuKey.color_map:
        item = SettingItem.row(
          key: key,
          title: 'Color Type',
          children: [
            SettingItem.color(title: 'G', key: 'G', value: Colors.black54, fieldType: FieldType.row_color),
          ],
        );
        break;
      case TrackContextMenuKey.densityMode:
        item = SettingItem.toggle(title: 'Density Mode', key: key, value: false);
        break;
      case TrackContextMenuKey.pin_top:
        item = SettingItem.toggle(title: 'Pin to top', key: key, value: false);
        break;
      case TrackContextMenuKey.value_scale_type:
        item = SettingItem.checkGroup(
          title: 'Value Scale',
          key: key,
          value: ValueScaleType.LINEAR,
          optionListType: optionListType,
          options: <OptionItem>[
            OptionItem('Linear', ValueScaleType.LINEAR),
            // OptionItem('Max Limit', ValueScaleType.MAX_LIMIT),
            OptionItem('Pow .5', ValueScaleType.POW_HALF),
            OptionItem('Log', ValueScaleType.LOG),
          ],
        );
        break;
      case TrackContextMenuKey.active_data_view:
        item = SettingItem.button(title: 'View Track Data', key: key, value: false);
        break;
      case TrackContextMenuKey.bam_view_as:
        item = SettingItem.checkGroup(
          title: 'View as paired',
          key: key,
          value: false,
          optionListType: optionListType,
          options: <OptionItem>[
            OptionItem('Un-pair', false),
            OptionItem('pair', true),
          ],
        );
        break;
      case TrackContextMenuKey.bam_color_by:
        item = SettingItem.hover(title: 'Color by', key: key, suffix: Icon(Icons.chevron_right));
        break;
      case TrackContextMenuKey.bam_filter_by:
        item = SettingItem.hover(title: 'Filter by', key: key, suffix: Icon(Icons.chevron_right));
        break;
      case TrackContextMenuKey.bam_group_by:
        item = SettingItem.hover(title: 'Group by', key: key, suffix: Icon(Icons.chevron_right));
        break;
      case TrackContextMenuKey.bam_sort_by:
        item = SettingItem.hover(title: 'Sort by', key: key, suffix: Icon(Icons.chevron_right));
        break;
      case TrackContextMenuKey.max_value:
        item = SettingItem.range(title: 'Max Value', key: key, enabled: false, value: 100.0, step: 10.0);
        break;
      case TrackContextMenuKey.min_value:
        item = SettingItem.range(title: 'Min Value', key: key, enabled: false, value: 100.0, step: 10.0);
        break;
      case TrackContextMenuKey.stack_chart_split:
        item = SettingItem.toggle(title: 'Split Chart', key: key, value: false);
        break;
      case TrackContextMenuKey.data_current_view:
        item = SettingItem.toggle(title: 'Data in current view', key: key, value: true);
        break;
      case TrackContextMenuKey.r_terminal:
        item = SettingItem.button(title: 'Open R Terminal', key: key, suffix: Icon(Icons.chevron_right));
        break;
      case TrackContextMenuKey.interactive_circle_view:
        item = SettingItem.button(title: 'Circle View', key: key, suffix: Icon(Icons.pie_chart_outline_rounded));
        break;
      case TrackContextMenuKey.cell_browse:
        item = SettingItem.button(title: 'Show Cell-Browse', key: key, suffix: Icon(MaterialCommunityIcons.chart_scatter_plot));
        break;
      case TrackContextMenuKey.bar_width:
        item = SettingItem.range(title: 'Bar Width', key: key, value: 2.0, step: 1.0, min: 2.0, max: 10.0);
        break;
      case TrackContextMenuKey.cartesian_value_type:
        item = SettingItem.checkGroup(
          title: 'Value Type',
          key: key,
          value: 'mean',
          optionListType: optionListType,
          options: <OptionItem>[
            OptionItem('mean', 'mean'),
            OptionItem('min', 'min'),
            OptionItem('max', 'max'),
            OptionItem('sum', 'sum'),
            OptionItem('std', 'std'),
            // OptionItem('coverage', 'coverage'),
          ],
        );
        break;
      case TrackContextMenuKey.hic_view_type:
        item = SettingItem.checkGroup(
          title: 'Display Mode',
          key: key,
          value: HicDisplayMode.heatmap,
          optionListType: optionListType,
          options: <OptionItem>[
            OptionItem('Heatmap', HicDisplayMode.heatmap),
            // OptionItem('FlatArc', HicDisplayMode.flatArc),
            OptionItem('Arc', HicDisplayMode.arc),
          ],
        );
        break;
      case TrackContextMenuKey.hic_normalize:
        item = SettingItem.checkGroup(
          title: 'Normalize',
          key: key,
          value: HicNormalize.VC,
          optionListType: optionListType,
          options: HicNormalize.values.map<OptionItem>((e) => OptionItem(e.name, e)).toList(),
        );
        break;
      case TrackContextMenuKey.relation_view_type:
        item = SettingItem.checkGroup(
          title: 'Display Mode',
          key: key,
          value: RelationViewType.line,
          optionListType: optionListType,
          options: <OptionItem>[
            OptionItem('Line', RelationViewType.line),
            OptionItem('Arc', RelationViewType.arc),
          ],
        );
        break;
      case TrackContextMenuKey.peak_co_access:
        item = SettingItem.toggle(title: 'CoAccessibility', key: key, value: false);
        break;
      case TrackContextMenuKey.track_info:
        item = SettingItem.button(title: 'Track info', key: key, suffix: Icon(Icons.info_outline));
        break;
      case TrackContextMenuKey.force_load_feature:
        item = SettingItem.button(title: 'Force load feature', key: key, suffix: Icon(Icons.file_download_rounded));
        break;
      case TrackContextMenuKey.show_track_title:
        item = SettingItem.toggle(title: 'Show Track Title', key: key, value: true);
        break;
      case TrackContextMenuKey.radius:
        item = SettingItem.range(title: 'Radius', key: key, value: 10, min: 1.0, max: 50, step: 1);
        break;
      case TrackContextMenuKey.stack_mode:
        item = SettingItem.checkGroup(
          title: 'Chart Mode',
          key: key,
          value: StackMode.stack,
          optionListType: optionListType,
          options: <OptionItem>[
            OptionItem('Stack', StackMode.stack),
            OptionItem('Overlap', StackMode.overlap),
          ],
        );
        break;
    }
    return item;
  }
}
