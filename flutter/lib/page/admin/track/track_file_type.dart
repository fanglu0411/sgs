import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/d3/color/schemes.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as path;

enum TrackFileType {
  fasta,
  gff,
  bed,
  bam,
  vcf,
  bigwig,
  melthy,
  longrange,
  biginteract,
  hic,
  bedgraph,
  eqtl,
  sc_h5ad,
  unknown,
}

String toServerTrackType(TrackFileType type) {
  switch (type) {
    case TrackFileType.bigwig:
      return 'big';
    case TrackFileType.bed:
      return 'normal_bed';
    case TrackFileType.hic:
      return 'hic_bin';
    case TrackFileType.longrange:
    case TrackFileType.biginteract:
      return 'hic_interactive';
    case TrackFileType.melthy:
      return 'methy';
    case TrackFileType.eqtl:
      return 'eqtl';
    case TrackFileType.sc_h5ad:
      return 'sc';
    default:
      return type.name;
  }
}

Map<TrackFileType, List> trackFileTypeMapper = {
  TrackFileType.fasta: ['fasta', '.fasta', '.fasta.gz', '.fasta.tar', '.fa', '.fa.gz', '.fna', '.fna.gz'],
  TrackFileType.gff: ['gff', '.gff', '.gff.gz', '.gff.tar', 'gff3', '.gff3', '.gff3.gz', '.gff3.tar'],
  TrackFileType.bed: ['bed', '.bed', '.bed.gz', '.bed.tar'],
  TrackFileType.bam: ['bam', '.bam', '.bam.gz', '.bam.tar', '.bam'],
  TrackFileType.vcf: ['vcf', '.vcf', '.vcf.gz', '.vcf.tar'],
  TrackFileType.bigwig: ['bw', '.bw', '.bw.gz', '.bw.tar', '.bigwig', '.bigwig.gz'],
  TrackFileType.melthy: ['methy', 'melthy', '.methy', '.methy.gz', '.melthy', '.melthy.gz', '.melthyc', '.melthyC', '.melthyc.gz', '.melthyC.gz'],
  TrackFileType.longrange: ['longrange', '.longrange', '.longrange.gz', '.longrange.tar'],
  TrackFileType.biginteract: ['biginteract', '.biginteract', '.biginteract.gz', '.biginteract.tar', '.bb', '.bb.gz'],
  TrackFileType.hic: ['hic', '.hic', '.hic.gz'],
  TrackFileType.bedgraph: ['bgd', '.bgd', '.bgd.gz', '.bedgraph', '.bedgraph.gz'],
  TrackFileType.eqtl: ['gwas', '.gwas', 'gwas.gz', '.gwas.gz'],
  TrackFileType.sc_h5ad: ['h5ad', '.h5ad', '.h5mu', 'h5mu', 'adata', '.adata', '.zarr', 'zarr'],
};

TrackFileType findTrackFileType(String filePath) {
  var ext = path.extension(filePath, 2).toLowerCase();
  var es = trackFileTypeMapper.entries;
  for (var e in es) {
    if (e.value.contains(ext)) {
      return e.key;
    }
  }
  ext = path.extension(filePath, 1).toLowerCase();
  for (var e in es) {
    if (e.value.contains(ext)) {
      return e.key;
    }
  }

  return TrackFileType.unknown;
}

Map<TrackFileType, Color> trackFileColorMapper = Map.fromIterables(trackFileTypeMapper.keys, (Get.isDarkMode ? schemeRainbowDark : schemeRainbowLight).call(trackFileTypeMapper.length));
