import 'package:flutter_smart_genome/parser/track_parser.dart';

class BigWigParser extends TrackDataParser {
  late String content;

  @override
  Future<Map> parse() async {
    var arr = content.split('\n');

    List<Map> data = [];
    Map obj = {
      'header': [],
      'data': data,
    };

    Map item;

    for (String line in arr) {
      if (line.startsWith('#')) {
        obj['header'].add(line);
      } else {
        var row = line.split('\t');
        if (row.length != 4) continue;
        item = <String, dynamic>{
          'start': double.tryParse(row[1]),
          'end': double.tryParse(row[2]),
          'value': double.tryParse(row[3]),
        };
        data.add(item);
      }
    }
    return obj;
  }
}