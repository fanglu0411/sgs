import 'package:dbio_utils/generic_filehandle/local_file.dart';
import 'package:dbio_utils/gff/api.dart';
import 'package:dbio_utils/tabix/tabix_indexed_file.dart';
import 'package:flutter_smart_genome/parser/track_parser.dart';
import 'package:flutter_smart_genome/widget/upload/platform_entry.dart';

class IndexedGff extends TrackDataParser {
  late TabixIndexedFile tabixIndexedFile;

  IndexedGff({
    required UploadFileItem tbi,
    UploadFileItem? csi,
    UploadFileItem? gff,
    int chunkSizeLimit = 1000000,
  }) {
    tabixIndexedFile = TabixIndexedFile(
      fileHandle: LocalFile(tbi.file),
      // csiFileHandle: csi != null ? LocalFile(csi.file) : null,
      // tbiFileHandle: gff != null ? LocalFile(gff.file) : null,
      chunkSizeLimit: chunkSizeLimit,
    );
    tabixIndexedFile.lineCount('nonexistent').then((v) {});
  }

  _parseLine(Map columnNumbers, String line, int fileOffset) {
    var fields = line.split("\t");
    // note: index column numbers are 1-based
    return {
      'start': int.parse(fields[columnNumbers['start'] - 1]),
      'end': int.parse(fields[columnNumbers['end'] - 1]),
      'lineHash': fileOffset,
      'fields': fields,
    };
  }

  getFeatures({required String ref, required num start, required num end}) async {
    var metadata = await tabixIndexedFile.getMetadata({});
    var regularizedReferenceName = tabixIndexedFile.renameRefSeq(ref);
    List lines = [];
    void _lineCallback(line, fileOffset) {
      lines.add(_parseLine(metadata['columnNumbers'], line, fileOffset));
    }

    await tabixIndexedFile.getLines(
      refName: regularizedReferenceName,
      start: start.toInt(),
      end: end.toInt(),
      callback: _lineCallback,
    );

    var gff3 = lines.map((lineRecord) {
      if (lineRecord['fields'][8] != null && lineRecord['fields'][8] != '.') {
        if (!lineRecord['fields'][8].includes('_lineHash')) {
          lineRecord['fields'][8] += ';_lineHash=${lineRecord['lineHash']}';
        }
      } else {
        lineRecord['fields'][8] = '_lineHash=${lineRecord['lineHash']}';
      }
      return lineRecord['fields'].join('\t');
    }).join('\n');
    var features = parseStringSync(gff3, {
      'parseFeatures': true,
      'parseComments': false,
      'parseDirectives': false,
      'parseSequences': false,
    });
    print(features);
  }

  @override
  Future parse() async {}
}