import 'package:flutter/services.dart';
import 'package:flutter_smart_genome/theme/material_theme.dart';
import 'package:yaml/yaml.dart';

import 'package:flutter_smart_genome/extensions/common_extensions.dart' as ce;

Future<List<MaterialTheme>> loadThemes() async {
  var theme = await rootBundle.loadString('assets/theme/themes.yaml');
  var themes = loadYaml(theme);
  var classics = themes['classic'];
  var materials = themes['material'];
  var others = themes['other'];

  List<MaterialTheme> _themes = [];

  for (var theme in classics) {
    _themes.add(_fromYamlNode(theme));
  }
  for (var theme in materials) {
    _themes.add(_fromYamlNode(theme));
  }
  for (var theme in others) {
    _themes.add(_fromYamlNode(theme));
  }
  return _themes;
}

MaterialTheme _fromYamlNode(YamlMap theme) {
  return MaterialTheme(
    name: theme['name'],
    name2: theme['name2'],
    id: theme['id'],
    desc: theme['desc'],
    dark: theme['dark'],
    background: ce.parseHexColor(theme['background']),
    foreground: ce.parseHexColor(theme['foreground']),
    text: ce.parseHexColor(theme['text']),
    selectionBackground: ce.parseHexColor(theme['selectBg']),
    selectionForeground: ce.parseHexColor(theme['selectFg']),
    button: ce.parseHexColor(theme['button']),
    secondBackground: ce.parseHexColor(theme['second']),
    disabled: ce.parseHexColor(theme['disabled']),
    contrast: ce.parseHexColor(theme['contrast']),
    active: ce.parseHexColor(theme['table']),
    border: ce.parseHexColor(theme['border']),
    highlight: ce.parseHexColor(theme['hl']),
    tree: ce.parseHexColor(theme['tree']),
    notification: ce.parseHexColor(theme['notif']),
    accent: ce.parseHexColor(theme['accent']),
    excluded: ce.parseHexColor(theme['excluded']),
    green: ce.parseHexColor(theme['green']),
    yellow: ce.parseHexColor(theme['yellow']),
    blue: ce.parseHexColor(theme['blue']),
    red: ce.parseHexColor(theme['red']),
    purple: ce.parseHexColor(theme['purple']),
    orange: ce.parseHexColor(theme['orange']),
    cyan: ce.parseHexColor(theme['cyan']),
    gray: ce.parseHexColor(theme['gray']),
    whiteOrBlack: ce.parseHexColor(theme['white']),
    error: ce.parseHexColor(theme['error']),
    comments: ce.parseHexColor(theme['comments']),
    variables: ce.parseHexColor(theme['vars']),
    links: ce.parseHexColor(theme['links']),
    functions: ce.parseHexColor(theme['functions']),
    keywords: ce.parseHexColor(theme['keywords']),
    tags: ce.parseHexColor(theme['tags']),
    strings: ce.parseHexColor(theme['strings']),
    operators: ce.parseHexColor(theme['operators']),
    attributes: ce.parseHexColor(theme['attributes']),
    numbers: ce.parseHexColor(theme['numbers']),
    parameters: ce.parseHexColor(theme['parameters']),
  );
}
