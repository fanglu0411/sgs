import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/util/logger.dart';

class BlastAlignment {
  String description;
  int length;
  String totalScore;
  int queryCover;
  List<HSP> hsps;

  BlastAlignment(
    this.description,
    this.length,
    this.totalScore,
    this.queryCover,
    this.hsps,
  );

  @override
  String toString() {
    return 'BlastAlignment{description: $description, length: $length, totalScore: $totalScore, queryCover: $queryCover, hsp: $hsps}';
  }
}

class HSP {
  String score;
  var eValue;
  String identities;
  var positives;
  var gaps;
  var queryStart;
  String query;
  var queryEnd;
  var comparison;
  var subjectStart;
  var subject;
  var subjectEnd;

  HSP(
    this.score,
    this.eValue,
    this.identities,
    this.positives,
    this.gaps,
    this.queryStart,
    this.query,
    this.queryEnd,
    this.comparison,
    this.subjectStart,
    this.subject,
    this.subjectEnd,
  );

  @override
  String toString() {
    return 'HSP{score: $score, eValue: $eValue, identities: $identities, positives: $positives, gaps: $gaps, queryStart: $queryStart, query: $query, queryEnd: $queryEnd, comparison: $comparison, subjectStart: $subjectStart, subject: $subject, subjectEnd: $subjectEnd}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HSP &&
          runtimeType == other.runtimeType &&
          score == other.score &&
          eValue == other.eValue &&
          identities == other.identities &&
          positives == other.positives &&
          gaps == other.gaps &&
          queryStart == other.queryStart &&
          query == other.query &&
          queryEnd == other.queryEnd &&
          comparison == other.comparison &&
          subjectStart == other.subjectStart &&
          subject == other.subject &&
          subjectEnd == other.subjectEnd;

  @override
  int get hashCode =>
      score.hashCode ^
      eValue.hashCode ^
      identities.hashCode ^
      positives.hashCode ^
      gaps.hashCode ^
      queryStart.hashCode ^
      query.hashCode ^
      queryEnd.hashCode ^
      comparison.hashCode ^
      subjectStart.hashCode ^
      subject.hashCode ^
      subjectEnd.hashCode;
}

class Blaster {
  bool colored = true;

  late List<String> queryList;

  int currentQueryIndex = 0;
  late List<BlastAlignment> currentAlignments;

  void setQuery(int queryIndex) {
    currentQueryIndex = queryIndex;
    currentAlignments = getAlignments(queryList[currentQueryIndex]);
  }

  Blaster(String result) {
    queryList = getQueries(result);
    if (queryList.length > 0) {
      setQuery(0);
    }
  }

  void displayAlignments(String content) {
    var queries = getQueries(content);
    logger.d('queries:');
    logger.d(queries);
    List<BlastAlignment> alignemnts = getAlignments(queries[0]);
    logger.d('alignemnts:');

    for (var align in alignemnts) {
      logger.d(align.description);
      logger.d(align.hsps);
    }
  }

  List<String> getQueries(String content) {
    var lines = content.split('\n');
    if (lines[2].startsWith("<BlastOutput>")) {
      return getXMLQueries(content);
    } else {
      return getTextQueries(content);
    }
  }

  List<BlastAlignment> getAlignments(String content) {
    List<String> lines = content.split('\n');
    if (lines[2].startsWith("<BlastOutput>")) {
      return parseBlastXML(content);
    } else {
      return parseBlastText(content);
    }
  }

  List<String> getXMLQueries(content) {
    List<String> queries = [];
    var lines = content.split('\n');
    var count = 0;
    for (var i = 0; i < lines.length; i++) {
      if (lines[i].startsWith('<Iteration>')) {
        count++;
      }
    }
    if (count == 1) {
      queries.add(content);
    } else {
      var j = 0;
      var init = '';
      for (var i = 0; i < lines.length; i++) {
        j = i;
        if (lines[i].startsWith('<Iteration>')) {
          break;
        } else {
          init = init + lines[i] + '\n';
        }
      }
      for (var x = 0; x < count; x++) {
        var query = init + lines[j] + '\n';
        j++;
        while (lines[j] != null && !lines[j].startsWith('<Iteration>')) {
          query = query + lines[j] + '\n';
          j++;
        }
        queries.add(query);
      }
    }
    return queries;
  }

  List<String> getTextQueries(String content) {
    List<String> queries = [];
    List<String> lines = content.split('\n');
    var count = 0;
    for (var i = 0; i < lines.length; i++) {
      if (lines[i].startsWith('Query=')) {
        count++;
      }
    }
    if (count == 1) {
      queries.add(content);
    } else {
      var j = 0;
      var init = '';
      for (var i = 0; i < lines.length; i++) {
        j = i;
        if (lines[i].startsWith('Query=')) {
          break;
        } else {
          init = init + lines[i] + '\n';
        }
      }
      for (var x = 0; x < count; x++) {
        var query = init + lines[j] + '\n';
        j++;
        while (j < lines.length && !lines[j].startsWith('Query=')) {
          query = query + lines[j] + '\n';
          j++;
        }
        query = query + '\nend\n';
        queries.add(query);
      }
    }
    return queries;
  }

  int getQueryLength(content) {
    var lines = content.split('\n');
    if (lines[2].startsWith("<BlastOutput>")) {
      return getXMLQueryLength(content);
    } else {
      return getTextQueryLength(content);
    }
  }

  int getXMLQueryLength(content) {
    var lines = content.split('\n');
    var length = 0;
    for (var i = 0; i < lines.length; i++) {
      if (lines[i].includes('<Iteration_query-len>')) {
        length = lines[i].split('>')[1].split('</')[0];
        break;
      }
    }
    return length;
  }

  int getTextQueryLength(String content) {
    List<String> lines = content.split('\n');
    var length = 0;
    for (var i = 0; i < lines.length; i++) {
      if (lines[i].startsWith('Length=')) {
        length = int.parse(lines[i].split('=')[1]);
        break;
      }
    }
    return length;
  }

  List<BlastAlignment> parseBlastXML(String content) {
    var lines = content.split('\n');
    var alignments = <BlastAlignment>[];
    for (var i = 0; i < lines.length; i++) {
      if (lines[i].startsWith('<Hit>')) {
        var hit = '';
        for (var c = i; c < lines.length; c++) {
          hit += lines[c];
          if (lines[c].contains("</Hit>")) {
            break;
          }
        }
        var id = hit.split("<Hit_id>")[1].split("</")[0];
        var def = hit.split("<Hit_def>")[1].split("</")[0];
        var description = '$id $def'; // id.concat(' ').concat(def);
        var length = hit.split("<Hit_len>")[1].split("</")[0];
        List<HSP> hsps_a = [];
        var multiple = false;
        var hsps_s = hit.split('<Hit_hsps>')[1].split('</Hit_hsps>')[0];
        var hsps = hsps_s.split("</Hsp>");
        for (var h = 0; h < hsps.length - 1; h++) {
          var score = hsps[h].split("<Hsp_bit-score>")[1].split("</")[0];
          var eValue = hsps[h].split("<Hsp_evalue>")[1].split("</")[0];
          var idnt = hsps[h].split("<Hsp_identity>")[1].split("</")[0];
          var a_length = hsps[h].split("<Hsp_align-len>")[1].split("</")[0];
          var identities = int.parse(idnt) / int.parse(a_length) * 100;
          var positives;
          var gaps;
          if (lines[3].contains('<BlastOutput_program>blastn</BlastOutput_program>')) {
            positives = 'N/A';
            var gps = hsps[h].split("<Hsp_gaps>")[1].split("</")[0];
            gaps = int.parse(gps) ~/ int.parse(a_length) * 100;
          } else {
            var pstves = hsps[h].split("<Hsp_positive>")[1].split("</")[0];
            positives = (int.parse(pstves) / int.parse(a_length) * 100).toStringAsFixed(0);
            var gps = hsps[h].split("<Hsp_gaps>")[1].split("</")[0];
            gaps = int.parse(gps) ~/ int.parse(a_length) * 100;
          }
          var queryStart = hsps[h].split("<Hsp_query-from>")[1].split("</")[0];
          var query = hsps[h].split("<Hsp_qseq>")[1].split("</")[0];
          var queryEnd = hsps[h].split("<Hsp_query-to>")[1].split("</")[0];
          var comparison = hsps[h].split("<Hsp_midline>")[1].split("</")[0];
          var sbjctStart = hsps[h].split("<Hsp_hit-from>")[1].split("</")[0];
          var sbjct = hsps[h].split("<Hsp_hseq>")[1].split("</")[0];
          var sbjctEnd = hsps[h].split("<Hsp_hit-to>")[1].split("</")[0];
          var hsp = new HSP(score, eValue, identities.toString(), positives, gaps, queryStart, query, queryEnd, comparison, sbjctStart, sbjct, sbjctEnd);
          hsps_a.add(hsp);
        }
        double totalScore = double.parse(hsps_a[0].score);
        for (var x = 1; x < hsps_a.length; x++) {
          totalScore = totalScore + double.parse(hsps_a[x].score);
        }
        var alignment = BlastAlignment(description, int.parse(length), totalScore.toString(), getQueryCover(hsps_a, getQueryLength(content)), hsps_a);
        alignments.add(alignment);
      }
    }
    return alignments;
  }

  List<BlastAlignment> parseBlastText(String content) {
    List<String> lines = content.split('\n');
    List<BlastAlignment> alignments = [];
    for (var i = 0; i < lines.length; i++) {
      if (lines[i].startsWith('>')) {
        var line1 = lines[i].split('>')[1];
        var line2 = "";
        var currentLine = i;
        while (line2 == "") {
          currentLine = currentLine + 1;
          if (lines[currentLine].startsWith('Length=')) {
            line2 = lines[currentLine];
          } else {
            line1 += lines[currentLine];
          }
        }
        var description = line1;
        var length = line2.split('=')[1];
        List<HSP> hsps = [];
        var multiple = false;
        do {
          if (multiple) {
            currentLine = currentLine - 1;
          }
          if (lines[currentLine + 2].startsWith(' Features in this part of subject sequence:')) {
            currentLine = currentLine + 3;
            while (!lines[currentLine + 2].startsWith(" Score =")) {
              currentLine++;
            }
          }
          var regx = RegExp('\s\s+');
          String _score = lines[currentLine + 2].split(',')[0];
          _score = _score.replaceAll(regx, ' ');
          var score = _score.split(' ')[3];
          var eValue = lines[currentLine + 2].split(',')[1].split(' ')[4];
          var identities = lines[currentLine + 3].split(',')[0].split('(')[1].substring(0, lines[currentLine + 3].split(',')[0].split('(')[1].length - 2);
          var positives;
          var gaps;
          if (lines[0].startsWith('BLASTN')) {
            positives = 'N/A';
            gaps = lines[currentLine + 3].split(',')[1].split('(')[1].substring(0, lines[currentLine + 3].split(',')[1].split('(')[1].length - 2);
          } else {
            positives = lines[currentLine + 3].split(',')[1].split('(')[1].substring(0, lines[currentLine + 3].split(',')[1].split('(')[1].length - 2);
            gaps = lines[currentLine + 3].split(',')[2].split('(')[1].substring(0, lines[currentLine + 3].split(',')[2].split('(')[1].length - 2);
          }
          List<String> _arr = lines[currentLine + 4].split(',')[0].split(' ');
          if ((_arr.length > 1 && _arr[1] == 'Frame') || lines[currentLine + 4].startsWith(' Strand')) {
            currentLine = currentLine + 1;
          }
          var queryStart = lines[currentLine + 5]
              .substring(5)
              .trim()
//              .replaceAll(RegExp('^\s+'), '')
              .split(' ')[0];
          var query = lines[currentLine + 5].substring(12).replaceAll(RegExp('\s+'), '').replaceAll(RegExp('[0-9]'), '');
          var queryEnd = lines[currentLine + 5].substring(5).replaceAll(RegExp('^\s+'), '').split(' ')[lines[currentLine + 5].substring(5).replaceAll(RegExp('^\s+'), '').split(' ').length - 1];
          var comparison = lines[currentLine + 6].replaceAll(RegExp('^\s+'), '');
          var sbjctStart = lines[currentLine + 7]
              .substring(5)
              .trim()
//              .replaceAll(RegExp('^\s+'), '')
              .split(' ')[0];
          var sbjct = lines[currentLine + 7].substring(12).replaceAll(RegExp('\s+'), '').replaceAll(RegExp('[0-9]'), '');
          var sbjctEnd = lines[currentLine + 7].substring(5).replaceAll(RegExp('^\s+'), '').split(' ')[lines[currentLine + 7].substring(5).replaceAll(RegExp('^\s+'), '').split(' ').length - 1];

          currentLine = currentLine + 9;
          while (lines[currentLine].startsWith('Query')) {
            var nextQuery = lines[currentLine].substring(12).replaceAll(RegExp('\s+'), '').replaceAll(RegExp('[0-9]'), '');
            query += nextQuery;
            queryEnd = lines[currentLine].substring(5).replaceAll(RegExp('^\s+'), '').split(' ')[lines[currentLine].substring(5).replaceAll(RegExp('^\s+'), '').split(' ').length - 1];
            sbjct += lines[currentLine + 2].substring(12).replaceAll(RegExp('\s+'), '').replaceAll(RegExp('[0-9]'), '');
            sbjctEnd = lines[currentLine + 2].substring(5).replaceAll(RegExp('^\s+'), '').split(' ')[lines[currentLine + 2].substring(5).replaceAll(RegExp('^\s+'), '').split(' ').length - 1];

            var nextComparison = lines[currentLine + 1].replaceAll(RegExp('^\s+'), '');
            if (nextQuery.length > nextComparison.length) {
              var diference = nextQuery.length - nextComparison.length;
              for (var j = 0; j < diference; j++) {
                nextComparison = ' ' + nextComparison;
              }
            }
            comparison += nextComparison;
            currentLine = currentLine + 4;
          }
          var hsp = new HSP(score, eValue, identities, positives, gaps, queryStart, query, queryEnd, comparison, sbjctStart, sbjct, sbjctEnd);
          hsps.add(hsp);
          multiple = true;
        } while (lines[currentLine + 1].startsWith(' Score'));
        var totalScore = double.parse(hsps[0].score);
        for (var x = 1; x < hsps.length; x++) {
          totalScore = totalScore + double.parse(hsps[x].score);
        }
        BlastAlignment alignment = new BlastAlignment(description, int.parse(length), totalScore.toStringAsFixed(1), getQueryCover(hsps, getQueryLength(content)), hsps);
        alignments.add(alignment);
      }
    }
    return alignments;
  }

  int getQueryCover(List<HSP> hsps, length) {
    var cover = 0;
    var noOver = getHSPWithoutOverlapping(hsps);
    for (var i = 0; i < noOver.length; i++) {
      cover = cover + (100 * (noOver[i]['end'] - noOver[i]['start'] + 1) ~/ length);
    }
    return cover;
  }

  List<Map> getHSPWithoutOverlapping(List<HSP> hsps) {
    List<Map> hspNoOver = [];
    for (var i = 0; i < hsps.length; i++) {
      if (int.tryParse(hsps[i].queryStart)! > int.tryParse(hsps[i].queryEnd)!) {
        hspNoOver.add({'start': int.tryParse(hsps[i].queryEnd), 'end': int.tryParse(hsps[i].queryStart)});
      } else {
        hspNoOver.add({'start': int.tryParse(hsps[i].queryStart), 'end': int.tryParse(hsps[i].queryEnd)});
      }
    }
    return getNoOverlappingArray(partitionIntoOverlappingRanges(hspNoOver));
  }

  List<List<Map>> partitionIntoOverlappingRanges(List<Map> array) {
    int sortStart(a, b) {
      if (a['start'] < b['start']) return -1;
      if (a['start'] > b['start']) return 1;
      return 0;
    }

    array.sort(sortStart);

    int getMaxEnd(List array) {
      if (array.length == 0) return -1;

      int _sortEnd(a, b) {
        if (a['end'] < b['end']) return 1;
        if (a['end'] > b['end']) return -1;
        return 0;
      }

      array.sort(_sortEnd);
      return array[0]['end'];
    }

    List<List<Map>> rarray = [];
    var g = 0;
    rarray.add([array[0]]);

    for (var i = 1, l = array.length; i < l; i++) {
      if ((array[i]['start'] >= array[i - 1]['end']) && (array[i]['start'] < getMaxEnd(rarray[g]))) {
        rarray[g].add(array[i]);
      } else {
        g++;
        rarray.add([array[i]]);
//        rarray[g] = [array[i]];
      }
    }
    return rarray;
  }

  List<Map> getNoOverlappingArray(List<List<Map>> array) {
    List<Map> result = [];
    for (var i = 0; i < array.length; i++) {
      var start = array[i][0]['start'];
      var end = array[i][0]['end'];
      for (var j = 0; j < array[i].length; j++) {
        if (array[i][j]['start'] < start) start = array[i][j]['start'];
        if (array[i][j]['end'] > end) end = array[i][j]['end'];
      }
      result.add({'start': start, 'end': end});
    }
    return result;
  }

  Color getColor(colored, scoring, score, evalue) {
    var colorNb;
    if (!scoring) {
      if (evalue > 100) {
        colorNb = 1;
      } else if (evalue <= 100 && evalue > 1) {
        colorNb = 2;
      } else if (evalue <= 1 && evalue > 0.01) {
        colorNb = 3;
      } else if (evalue <= 0.01 && evalue > 0.00001) {
        colorNb = 4;
      } else {
        colorNb = 5;
      }
    } else {
      if (score < 40) {
        colorNb = 1;
      } else if (score >= 40 && score < 50) {
        colorNb = 2;
      } else if (score >= 50 && score < 80) {
        colorNb = 3;
      } else if (score >= 80 && score < 200) {
        colorNb = 4;
      } else {
        colorNb = 5;
      }
    }
    return getDivColor(colored, colorNb);
  }

  String getDivColorText(scoring, div) {
    if (!scoring) {
      switch (div) {
        case 1:
          return '>100';

        case 2:
          return '100-1';

        case 3:
          return '1-1e<sup>-2</sup>';

        case 4:
          return '1e<sup>-2</sup>-1e<sup>-5</sup>';

        case 5:
          return '<1e<sup>-5</sup>';

        default:
          return '0';
      }
    } else {
      switch (div) {
        case 1:
          return '<40';

        case 2:
          return '40-50';

        case 3:
          return '50-80';

        case 4:
          return '80-200';

        case 5:
          return '>=200';

        default:
          return '0';
      }
    }
  }

  Color getDivColor(colored, div) {
    if (colored) {
      switch (div) {
        case 1:
          return Color(0xff5C6D7E);

        case 2:
          return Color(0xff9B59B6);

        case 3:
          return Color(0xff5CACE2);

        case 4:
          return Color(0xff57D68D);

        case 5:
          return Color(0xffC0392B);

        default:
          return Color(0xffffffff);
      }
    } else {
      switch (div) {
        case 1:
          return Color(0xffBCBCBC);

        case 2:
          return Color(0xff989898);

        case 3:
          return Color(0xff747474);

        case 4:
          return Color(0xff565656);

        case 5:
          return Color(0xff343434);

        default:
          return Color(0xffFFFFFF);
      }
    }
  }

  String? getQueryText(String content) {
    var lines = content.split('\n');
    if (lines[2].startsWith("<BlastOutput>")) {
      return getXMLQueryText(content);
    } else {
      return getTextQueryText(content);
    }
  }

  String? getXMLQueryText(String content) {
    var lines = content.split('\n');
    for (var i = 0; i < lines.length; i++) {
      if (lines[i].contains('<Iteration_query-def>')) {
        return lines[i].split('>')[1].split('</')[0];
      }
    }
    return null;
  }

  String getTextQueryText(String content) {
    var lines = content.split('\n');
    var text = '';
    for (var i = 0; i < lines.length; i++) {
      if (lines[i].startsWith('Query=')) {
        text = lines[i].split('=')[1];
        i++;
        while (!lines[i].startsWith('Length=')) {
          text = text + ' ' + lines[i];
          i++;
        }
        break;
      }
    }
    return text;
  }

  static Color getAminoColor(char) {
    switch (char) {
      case 'A':
        return Color(0xffDBFA60);

      case 'C':
        return Color(0xffF9FA60);

      case 'D':
        return Color(0xffF9605F);

      case 'E':
        return Color(0xffF9609C);

      case 'F':
        return Color(0xff5FF99D);

      case 'G':
        return Color(0xffF9BC5F);

      case 'H':
        return Color(0xff609DF9);

      case 'I':
        return Color(0xff99F95A);

      case 'K':
        return Color(0xffA062FF);

      case 'L':
        return Color(0xff7EF960);

      case 'M':
        return Color(0xff63FF63);

      case 'N':
        return Color(0xffD95DF9);

      case 'P':
        return Color(0xffF9DA60);

      case 'Q':
        return Color(0xffF955D8);

      case 'R':
        return Color(0xff5360FB);

      case 'S':
        return Color(0xffF97E60);

      case 'T':
        return Color(0xffFFA563);

      case 'V':
        return Color(0xffC0F86B);

      case 'W':
        return Color(0xffFDD9F9);

      case 'Y':
        return Color(0xff60F9DA);

      default:
        return Color(0xffFFFFFF);
    }
  }
}
