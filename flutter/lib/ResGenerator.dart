import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:yaml/yaml.dart';

///
/// to generate id for assets
/// in project root, in terminal run cmd: dart lib/ResGenerator.dart
/// or in idea, run ResGenerator.dart
///

List drawableFields = [];
List stringFields = [];
List audioFields = [];
List videoFields = [];
List tableFields = [];
List otherFields = [];

List drawableExt = ['.jpg', '.jpeg', '.png'];
List audioExt = ['.mp3', '.wav'];
List videoExt = ['.mp4', '.avi', '.flv'];
List stringExt = ['.json', '.txt'];
List csvExt = ['.vsv', '.tsv'];

main(List<String> arguments) {
  if (path.basename(Directory.current.path) == 'lib') {
    print('run in: ${Directory.current.path}');
    print('you should run on project root path.');
    return;
  }

  var doc = loadYaml(new File(path.absolute('pubspec.yaml')).readAsStringSync());

  var assets = doc['flutter']['assets'];
  var version = doc['version'];
  var versionCode = doc['version_code'];
  var buildTime = doc['buildTime'];

  for (var item in assets) {
    field(item);
  }
  StringBuffer sb = new StringBuffer();
  sb.writeln('/// this file is auto generated.');
  sb.writeln("class R {");
  sb.writeln("${Indent.field()}static final version = '${version}';");
  sb.writeln("${Indent.field()}static final versionCode = ${versionCode};");
  sb.writeln("${Indent.field()}static final buildTime = '${buildTime}';");
  sb.writeln("${Indent.field()}static final drawable = new DrawableRes();");
  sb.writeln("${Indent.field()}static final string = new StringRes();");
  sb.writeln("${Indent.field()}static final audio = new AudioRes();");
  sb.writeln("${Indent.field()}static final video = new VideoRes();");
  sb.writeln("${Indent.field()}static final table = new TableRes();");
  sb.writeln("${Indent.field()}static final other = new OtherRes();");
  sb.writeln("}");

  sb.writeln(genClass("DrawableRes", drawableFields));
  sb.writeln(genClass("AudioRes", audioFields));
  sb.writeln(genClass("VideoRes", videoFields));
  sb.writeln(genClass("StringRes", stringFields));
  sb.writeln(genClass("TableRes", tableFields));
  sb.writeln(genClass("OtherRes", otherFields));

  File gen = new File(path.absolute('lib/R.dart'));
  gen.createSync();
  gen.writeAsStringSync(sb.toString());
}

String genClass(String name, List items) {
  ClassGenerator classGenerator = new ClassGenerator.create(name);
  for (var field in items) {
    classGenerator.addField(field);
  }
  classGenerator.close();
  return classGenerator.print();
}

class ClassGenerator {
  late StringBuffer sb;
  ClassGenerator.create(String name) {
    sb = new StringBuffer();
    sb.writeln("class $name {");
  }

  addField(String filePath) {
    String filename = path.basename(filePath);
    String name = path.basenameWithoutExtension(filename);
    if (name.startsWith(new RegExp("^[0-9]"))) {
      name = "_$name";
    }
    String field = 'final String ${name.replaceAll("-", '_').replaceAll('\.', '_')} = "$filePath";';
    sb.writeln("${Indent.field()}$field");
  }

  close() {
    sb.writeln("}");
  }

  String print() {
    return sb.toString();
  }
}

void field(String v) {
  String ext = path.extension(v);
  if (drawableExt.contains(ext)) {
    drawableFields.add(v);
  } else if (audioExt.contains(ext)) {
    audioFields.add(v);
  } else if (videoExt.contains(ext)) {
    videoFields.add(v);
  } else if (stringExt.contains(ext)) {
    stringFields.add(v);
  } else if (csvExt.contains(ext)) {
    tableFields.add(v);
  } else {
    otherFields.add(v);
  }
}

class Indent {
  static String field() {
    return indent(2);
  }

  static String innerClass() {
    return indent(2);
  }

  static String innerClassField() {
    return indent(4);
  }

  static String indent(int count) {
    String s = "";
    int i = 1;
    while (i <= count) {
      s += ' ';
      i++;
    }
    return s;
  }
}