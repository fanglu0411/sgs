import 'package:flutter/material.dart';

class MaterialTheme {
  late final String name;
  late final String name2;
  late final String id;
  late final String desc;
  late final bool dark;

  late final Color background;
  late final Color foreground;
  late final Color text;
  late final Color selectionBackground;
  late final Color selectionForeground;
  late final Color button;
  late final Color secondBackground;
  late final Color disabled;
  late final Color contrast;
  late final Color active;
  late final Color border;
  late final Color highlight;
  late final Color tree;
  late final Color notification;
  late final Color accent;
  late final Color excluded;

  late final Color green;
  late final Color yellow;
  late final Color blue;
  late final Color red;
  late final Color purple;
  late final Color orange;
  late final Color cyan;
  late final Color gray;
  late final Color whiteOrBlack;

  late final Color error;
  late final Color comments;
  late final Color variables;
  late final Color links;
  late final Color functions;
  late final Color keywords;
  late final Color tags;
  late final Color strings;
  late final Color operators;
  late final Color attributes;
  late final Color numbers;
  late final Color parameters;

  Color get primary => accent;

  Color get appBarBackground => contrast;

  Color get dividerColor => border; // dark ? Colors.black54 : Colors.grey[300];

  MaterialTheme({
    required this.name,
    required this.name2,
    required this.id,
    required this.desc,
    required this.dark,
    required this.background,
    required this.foreground,
    required this.text,
    required this.selectionBackground,
    required this.selectionForeground,
    required this.button,
    required this.secondBackground,
    required this.disabled,
    required this.contrast,
    required this.active,
    required this.border,
    required this.highlight,
    required this.tree,
    required this.notification,
    required this.accent,
    required this.excluded,
    required this.green,
    required this.yellow,
    required this.blue,
    required this.red,
    required this.purple,
    required this.orange,
    required this.cyan,
    required this.gray,
    required this.whiteOrBlack,
    required this.error,
    required this.comments,
    required this.variables,
    required this.links,
    required this.functions,
    required this.keywords,
    required this.tags,
    required this.strings,
    required this.operators,
    required this.attributes,
    required this.numbers,
    required this.parameters,
  });

  @override
  String toString() {
    return 'MaterialTheme{name: $name, name2: $name2, id: $id, desc: $desc, dark: $dark, background: $background, foreground: $foreground, text: $text, selectionBackground: $selectionBackground, selectionForeground: $selectionForeground, button: $button, secondBackground: $secondBackground, disabled: $disabled, contrast: $contrast, active: $active, border: $border, highlight: $highlight, tree: $tree, notification: $notification, accent: $accent, excluded: $excluded, green: $green, yellow: $yellow, blue: $blue, red: $red, purple: $purple, orange: $orange, cyan: $cyan, gray: $gray, whiteOrBlack: $whiteOrBlack, error: $error, comments: $comments, variables: $variables, links: $links, functions: $functions, keywords: $keywords, tags: $tags, strings: $strings, operators: $operators, attributes: $attributes, numbers: $numbers, parameters: $parameters}';
  }
}