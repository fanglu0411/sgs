import 'package:dbio_utils/fasta/indexed_fasta.dart';
import 'package:dbio_utils/generic_filehandle/generic_file_handle.dart';
import 'package:dbio_utils/generic_filehandle/local_file.dart';
import 'package:flutter_smart_genome/widget/upload/platform_entry.dart';

import 'track_parser.dart';

class IndexedFastaStore extends TrackDataParser {
  late IndexedFasta _indexedFasta;

  IndexedFastaStore({
    required UploadFileItem fastaFile,
    required UploadFileItem faiFile,
  }) {
    GenericFileHandle fasta = LocalFile(fastaFile.file);
    GenericFileHandle fai = LocalFile(faiFile.file);
    _indexedFasta = IndexedFasta(fasta: fasta, fai: fai);
  }

  Future getFeatures({int start = 0, required int end, required String ref}) async {
    String result = await _indexedFasta.getResiduesByName(ref, start, end);
    return result;
  }

  Future<bool> hasRefSeq(String seqName) async {
    int size = await _indexedFasta.getSequenceSize(seqName);
    return size != null;
  }

  Future<List> getRefSeqs() async {
    Map sizes = await _indexedFasta.getSequenceSizes();
    return sizes.keys.map((key) {
      return {
        'name': key,
        'length': sizes[key],
        'end': sizes[key],
        'start': 0,
      };
    }).toList();
  }

  @override
  Future parse() async {}
}
