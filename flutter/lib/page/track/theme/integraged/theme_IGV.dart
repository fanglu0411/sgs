import 'package:flutter/material.dart';

Map<String, dynamic> theme_IGV = {
  "ref_seq": {
    "light": {
      "color_map": {"A": 4283215696, "T": 4294198070, "C": 4280391411, "G": 4294940672},
      "label_font_size": 10.0
    },
    "dark": {
      "color_map": {"A": 4283215696, "T": 4294198070, "C": 4280391411, "G": 4294940672},
      "label_font_size": 10.0
    }
  },
  "gff": {
    "light": {
      "name": "Red-Light",
      "track_color": "ff0000b2",
      "track_height": 200.0,
      "track_max_height": {"enabled": true, "value": 300},
      "feature_height": 8.0,
      "show_label": true,
      "label_font_size": 12.0,
      "label_color": "ff000000",
      "feature_group_color": "10cccccc",
      "featureStyles": {
        "gene": {"color": 4278190258, "height": 1.0, "alpha": 255, "visible": true, "radius": 3.0, "borderColor": 4278190258, "borderWidth": 1.0, "id": "gene", "name": "gene", "isCustom": false},
        "cds": {"color": 4278190258, "height": 1.0, "alpha": 255, "visible": true, "radius": 0.0, "borderColor": 4278190258, "borderWidth": 5.0, "id": "cds", "name": "CDS", "isCustom": false},
        "exon": {"color": 4278190258, "height": 0.8, "alpha": 255, "visible": true, "radius": 0.0, "borderColor": 4278190258, "borderWidth": 1.0, "id": "exon", "name": "exon", "isCustom": false},
        "intron": {
          "color": 4278190258,
          "height": 0.2,
          "alpha": 255,
          "visible": true,
          "radius": 0.0,
          "borderColor": 4278190258,
          "borderWidth": 0.0,
          "id": "intron",
          "name": "intron",
          "isCustom": false
        },
        "five_prime_utr": {
          "color": 4278190258,
          "height": 0.6,
          "alpha": 255,
          "visible": true,
          "radius": 2.0,
          "borderColor": 4278190258,
          "borderWidth": 0.0,
          "id": "five_prime_utr",
          "name": "five_prime_UTR",
          "isCustom": false
        },
        "three_prime_utr": {
          "color": 4278190258,
          "height": 0.6,
          "alpha": 255,
          "visible": true,
          "radius": 2.0,
          "borderColor": 4278190258,
          "borderWidth": 0.0,
          "id": "three_prime_utr",
          "name": "three_prime_UTR",
          "isCustom": false
        },
        "est_match": {
          "color": 4278190258,
          "height": 1.0,
          "alpha": 255,
          "visible": true,
          "radius": 2.0,
          "borderColor": 4278190258,
          "borderWidth": 0.0,
          "id": "est_match",
          "name": "EST_match",
          "isCustom": false
        },
        "match_part": {
          "color": 4278190258,
          "height": 1.0,
          "alpha": 255,
          "visible": true,
          "radius": 2.0,
          "borderColor": 4278190258,
          "borderWidth": 0.0,
          "id": "match_part",
          "name": "match_part",
          "isCustom": false
        },
        "others": {"color": 4278190258, "height": 1.0, "alpha": 255, "visible": true, "radius": 3.0, "borderColor": 4278190258, "borderWidth": 1.0, "id": "others", "name": "others", "isCustom": false}
      }
    },
    "dark": {
      "name": "Red-Dark",
      "track_color": "ff930077",
      "track_height": 200.0,
      "track_max_height": {"enabled": true, "value": 500},
      "feature_height": 8.0,
      "show_label": true,
      "label_font_size": 12.0,
      "label_color": "8affffff",
      "feature_group_color": 1816482887,
      "featureStyles": {
        "gene": {"name": "gene", "id": "gene", "color": 4292745020, "height": 1.0, "alpha": 255, "visible": true, "radius": 3.0, "borderColor": 4288519067, "borderWidth": 0.0},
        "cds": {"name": "CDS", "id": "cds", "color": 4294535697, "height": 1.0, "alpha": 255, "visible": true, "radius": 3.0, "borderColor": 4288585117, "borderWidth": 0.0},
        "exon": {"name": "exon", "id": "exon", "color": 3522222095, "height": 0.5, "alpha": 209, "visible": true, "radius": 4.0, "borderColor": 4291809593, "borderWidth": 0.0},
        "intron": {"name": "intron", "id": "intron", "color": "ff9e9e9e", "alpha": 200, "visible": true, "height": 0.1, "radius": 3, "borderWidth": 0, "borderColor": "ff9e9e9e"},
        "five_prime_utr": {
          "name": "five_prime_UTR",
          "id": "five_prime_utr",
          "color": 2876119,
          "height": 1.0,
          "alpha": 0,
          "visible": true,
          "radius": 2.0,
          "borderColor": 4280404158,
          "borderWidth": 1.0
        },
        "three_prime_utr": {
          "name": "three_prime_UTR",
          "id": "three_prime_utr",
          "color": 1152397,
          "height": 1.0,
          "alpha": 0,
          "visible": true,
          "radius": 2.0,
          "borderColor": 4279146473,
          "borderWidth": 1.0
        },
        "est_match": {"id": "est_match", "name": "EST_match", "alpha": 255, "borderColor": 4294942474, "borderWidth": 0.0, "color": 4291403679, "height": 0.1, "radius": 2.0, "visible": true},
        "match_part": {"id": "match_part", "name": "match_part", "alpha": 255, "borderColor": 4292714250, "borderWidth": 0.0, "color": 4293494663, "height": 1.0, "radius": 3.0, "visible": true},
        "others": {"name": "others", "id": "others", "color": "ff0781ed", "alpha": 255, "visible": true, "height": 1, "radius": 3, "borderWidth": 0, "borderColor": "ff9e9e9e"}
      }
    }
  },
  "bam_coverage": {
    "light": {
      "color_map": {"A": 4283215696, "T": 4294198070, "C": 4280391411, "G": 4294940672, "coverage": 4288585374},
      "track_color": 4290464844,
      "track_height": 120.0,
      "density_mode": false
    },
    "dark": {
      "color_map": {"A": 4283215696, "T": 4294198070, "C": 4280391411, "G": 4294940672, "coverage": 4288585374},
      "track_color": 4288585374,
      "track_height": 120.0,
      "density_mode": false
    }
  },
  "bam_reads": {
    "light": {
      "color_map_strand_default": {
        "fwd": Color(0xFFec8b8b),
        "rev": Color(0xff8f8fd8),
        "fwd_missing_mate": Color(0xFFd11919),
        "rev_missing_mate": Color(0xFF1919d1),
        "fwd_not_proper": Color(0xFFecc8cb),
        "rev_not_proper": Color(0xFFbebed8),
        "fwd_diff_chr": Color(0xFF000000),
        "rev_diff_chr": Color(0xFF969696),
        "no_strand": Color(0xFF999999),
      },
      "color_map_no_color": {"+": Color(0xFF969696), "-": Color(0xFF969696)},
      "color_map_strand": {"+": 3438254746, "-": 3432041209},
      "color_map_mapping_quality": {"start": 3438254746, "end": 3432041209},
      "color_map_insert_size": {"start": 3438254746, "end": 3432041209},
      "color_map_pair_orientation": {'normal': Color(0xD2D2D2), "LR": Color(0xff999999), "LL": Color(0xff70AD47), 'RR': Color(0xff00007F), 'RL': Color(0xff007F7F)},
      "color_map_XS_tag": {"start": 3438254746, "end": 3432041209},
      "color_map_TS_tag": {"start": 3438254746, "end": 3432041209},
      "color_map_modifications": {"modify": Colors.red, "+": 3438254746, "-": 3432041209},
      "color_map_methylation": {"melthy": Colors.red, "un-melthy": Colors.blueAccent, "+": 3438254746, "-": 3432041209},
      "track_color": 4280391411,
      "track_max_height": {"enabled": true, "value": 300},
      "feature_height": 6.0,
      "label_font_size": 12.0,
      "label_color": "8a000000",
      "feature_group_color": 1296871248,
      "show_label": true
    },
    "dark": {
      "color_map_strand_default": {
        "fwd": Color(0xFFec8b8b),
        "rev": Color(0xff8f8fd8),
        "fwd_missing_mate": Color(0xFFd11919),
        "rev_missing_mate": Color(0xFF1919d1),
        "fwd_not_proper": Color(0xFFecc8cb),
        "rev_not_proper": Color(0xFFbebed8),
        "fwd_diff_chr": Color(0xFF000000),
        "rev_diff_chr": Color(0xFF969696),
        "no_strand": Color(0xFF999999),
      },
      "color_map_no_color": {"+": Color(0xFF969696), "-": Color(0xFF969696)},
      "color_map_strand": {"+": 3438254746, "-": 3432041209},
      "color_map_mapping_quality": {"start": 3438254746, "end": 3432041209},
      "color_map_insert_size": {"start": 3438254746, "end": 3432041209},
      "color_map_pair_orientation": {'normal': Color(0xD2D2D2), "LR": Color(0xff999999), "LL": Color(0xff70AD47), 'RR': Color(0xff00007F), 'RL': Color(0xff007F7F)},
      "color_map_XS_tag": {"start": 3438254746, "end": 3432041209},
      "color_map_TS_tag": {"start": 3438254746, "end": 3432041209},
      "color_map_modifications": {"modify": Colors.red, "+": 3438254746, "-": 3432041209},
      "color_map_methylation": {"melthy": Colors.red, "un-melthy": Colors.blueAccent, "+": 3438254746, "-": 3432041209},
      "track_color": 4280391411,
      "track_max_height": {"enabled": false, "value": 300},
      "feature_height": 8.0,
      "label_font_size": 12.0,
      "label_color": "8affffff",
      "feature_group_color": 1296871248,
      "show_label": true
    }
  },
  "bigwig": {
    "light": {
      "color_map": {"+": 4279603682, "-": 4294198070},
      "track_height": 80.0,
      "density_mode": false
    },
    "dark": {
      "color_map": {"+": 4279603682, "-": 4294198070},
      "track_height": 80.0,
      "density_mode": false
    }
  },
  "vcf_sample": {
    "light": {
      "color_map": {"0": 4288585374, "1": 4278430196, "2": 4291604291},
      "track_max_height": {"enabled": true, "value": 350},
      "track_height": 12.0,
      "feature_height": 6.0,
      "label_font_size": 12.0,
      "label_color": "8a000000",
      "feature_group_color": 1296871248,
      "show_label": true,
      "track_color": 4280391411
    },
    "dark": {
      "color_map": {"0": 4288585374, "1": 4278430196, "2": 4285445915},
      "track_max_height": {"enabled": true, "value": 350},
      "track_height": 110.0,
      "feature_height": 6.0,
      "label_font_size": 12.0,
      "label_color": "8affffff",
      "feature_group_color": 1296871248,
      "show_label": true,
      "track_color": 4280391411
    }
  },
  "vcf_coverage": {
    "light": {
      "track_max_height": {"enabled": true, "value": 450},
      "track_height": 120.0,
      "feature_height": 6.0,
      "label_font_size": 12.0,
      "label_color": "8a000000",
      "show_label": true,
      "track_color": 4280391411,
      "feature_group_color": 1841877961,
      "color_map": {"SNV": "ffe040fb", "SV": "ffff6e40", "INDEL": "ff0ec1b2", "MNV": "ff2196f3"}
    },
    "dark": {
      "track_max_height": {"enabled": true, "value": 300},
      "track_height": 120.0,
      "feature_height": 6.0,
      "label_font_size": 12.0,
      "label_color": "8affffff",
      "show_label": true,
      "track_color": 4280391411,
      "feature_group_color": 1841877961,
      "color_map": {"SNV": "ffe040fb", "SV": "ffff6e40", "INDEL": "ff10ecd9", "MNV": "ff448aff"}
    }
  },
  "methylation": {
    "light": {
      "color_map": {"CG": 4279603682, "CHG": 4294940672, "CHH": 4288423856, "deeps": 4288585374},
      "track_height": 120.0,
      "density_mode": false
    },
    "dark": {
      "color_map": {"CG": 4279603682, "CHG": 4294940672, "CHH": 4288423856, "deeps": 4288585374},
      "track_height": 120.0,
      "density_mode": false
    }
  },
  "hic": {
    "light": {
      "track_max_height": {"enabled": true, "value": 300},
      "custom_max_value": {"enabled": false, "value": 100},
      "custom_min_value": {"enabled": false, "value": 1},
      "track_color": 4294198070,
      "hic_display_mode": 0
    },
    "dark": {
      "track_max_height": {"enabled": true, "value": 300},
      "custom_max_value": {"enabled": false, "value": 100},
      "custom_min_value": {"enabled": false, "value": 1},
      "track_color": 4294198070,
      "hic_display_mode": 0
    }
  },
  "interactive": {
    "light": {
      "track_height": 200.0,
      "custom_max_value": {"enabled": false, "value": 100},
      "custom_min_value": {"enabled": false, "value": 1},
      "track_color": 4294198070,
      "relation_display_mode": 1
    },
    "dark": {
      "track_height": 200.0,
      "custom_max_value": {"enabled": false, "value": 100},
      "custom_min_value": {"enabled": false, "value": 1},
      "track_color": 4294198070,
      "relation_display_mode": 1
    }
  },
  // "sc_exp": {
  //   "light": {"color_map": {}, "feature_height": 40.0, "show_label": true, "label_font_size": 12.0, "label_color": "8a000000", "show_legends": false, "bar_width": 4.0},
  //   "dark": {"color_map": {}, "feature_height": 40.0, "show_label": true, "label_font_size": 12.0, "label_color": "8affffff", "show_legends": false, "bar_width": 4.0}
  // },
  "peak": {
    "light": {
      "track_color": "fff44336",
      "track_max_height": {"enabled": false, "value": 300},
      "feature_height": 8.0,
      "label_font_size": 12.0,
      "label_color": "8a000000",
      "show_label": true
    },
    "dark": {
      "line_color": "fff44336",
      "track_color": "fff44336",
      "track_max_height": {"enabled": false, "value": 300},
      "feature_height": 8.0,
      "label_font_size": 12.0,
      "label_color": "8affffff",
      "show_label": true
    }
  },
  // "sc_co_access": {
  //   "light": {
  //     "track_color": "fff44336",
  //     "track_height": 100.0,
  //     "custom_min_value": {"enabled": false, "value": 0},
  //     "custom_max_value": {"enabled": false, "value": 1}
  //   },
  //   "dark": {
  //     "track_color": "fff44336",
  //     "track_height": 100.0,
  //     "custom_min_value": {"enabled": false, "value": 0},
  //     "custom_max_value": {"enabled": false, "value": 1}
  //   }
  // },
  // "sc_group_coverage": {
  //   "light": {
  //     "track_height": 50.0,
  //     "track_max_height": {"enabled": true, "value": 500.0},
  //     "label_font_size": 12.0,
  //     "label_color": "8a000000",
  //     "show_label": true
  //   },
  //   "dark": {
  //     "track_height": 50.0,
  //     "track_max_height": {"enabled": true, "value": 500.0},
  //     "label_font_size": 12.0,
  //     "label_color": "8affffff",
  //     "show_label": true
  //   }
  // },
  "bed": {
    "light": {
      "track_max_height": {"enabled": false, "value": 300},
      "track_height": 120.0,
      "feature_height": 12.0,
      "label_font_size": 12.0,
      "label_color": "8a000000",
      "show_label": true,
      "track_color": "fff44336",
      "feature_group_color": "6dc8d3c9",
      "featureStyles": {
        "line": {
          "name": "line",
          "id": "line",
          "color": Color(0xff575857),
          "alpha": 255,
          "visible": true,
          "height": .1,
          "radius": 0,
          "borderWidth": 0,
          "borderColor": "ff9e9e9e",
        },
        "base": {
          "name": "base",
          "id": "base",
          "color": Color(0xff2a9333),
          "alpha": 255,
          "visible": true,
          "height": .8,
          "radius": 2,
          "borderWidth": 0,
          "borderColor": "ff9e9e9e",
        },
        "thick": {
          "name": "thick",
          "id": "thick",
          "color": Color(0x00000000),
          "alpha": 0,
          "visible": true,
          "height": 0.5,
          "radius": 0,
          "borderWidth": 0,
          "borderColor": "ff9e9e9e",
        },
        "block": {
          "name": "block",
          "id": "block",
          "color": Color(0xd7e28529),
          "alpha": 255,
          "visible": true,
          "height": .8,
          "radius": 3,
          "borderWidth": 0,
          "borderColor": "ff9e9e9e",
        },
      }
    },
    "dark": {
      "track_max_height": {"enabled": false, "value": 300},
      "track_height": 120.0,
      "feature_height": 12.0,
      "label_font_size": 12.0,
      "label_color": "8affffff",
      "show_label": true,
      "track_color": "fff44336",
      "feature_group_color": "6dc8d3c9",
      "featureStyles": {
        "line": {
          "name": "line",
          "id": "line",
          "color": Color(0xFF9E9E9E),
          "alpha": 255,
          "visible": true,
          "height": .1,
          "radius": 0,
          "borderWidth": 0,
          "borderColor": "ff9e9e9e",
        },
        "base": {
          "name": "base",
          "id": "base",
          "color": Color(0xff2a9333),
          "alpha": 255,
          "visible": true,
          "height": .8,
          "radius": 2,
          "borderWidth": 0,
          "borderColor": "ff9e9e9e",
        },
        "thick": {
          "name": "thick",
          "id": "thick",
          "color": Color(0x00000000),
          "alpha": 0,
          "visible": true,
          "height": 0.5,
          "radius": 0,
          "borderWidth": 0,
          "borderColor": "ff9e9e9e",
        },
        "block": {
          "name": "block",
          "id": "block",
          "color": Color(0xd7e28529),
          "alpha": 255,
          "visible": true,
          "height": .8,
          "radius": 3,
          "borderWidth": 0,
          "borderColor": "ff9e9e9e",
        },
      },
    }
  },
  "eqtl": {
    "light": {
      'track_height': 80.0,
      'track_max_height': {'enabled': true, 'value': 200.0},
      'track_color': Colors.blue,
      'radius': 5,
      'custom_max_value': {'enabled': true, 'value': 0.05},
      'value_scale_type': 2,
    },
    "dark": {
      'track_height': 80.0,
      'track_max_height': {'enabled': true, 'value': 200.0},
      'track_color': Colors.blueAccent,
      'radius': 5,
      'custom_max_value': {'enabled': true, 'value': 0.05},
      'value_scale_type': 2,
    },
  },
};
