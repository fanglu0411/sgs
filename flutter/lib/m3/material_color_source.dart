import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/base/background_mode.dart';

List<MaterialColorSource> materialColorSources = createMaterialColorSources();

List<MaterialColorSource> createMaterialColorSources() {
  return [
    MaterialColorSource.color(Colors.purple),
    MaterialColorSource.color(Colors.blue),
    MaterialColorSource.color(Colors.teal),
    MaterialColorSource.color(Colors.orange),
    MaterialColorSource.color(Colors.cyan),
    MaterialColorSource.color(Colors.green),
    MaterialColorSource.color(Colors.pink),
    MaterialColorSource.color(Colors.indigo),
    MaterialColorSource.color(Colors.brown),
    MaterialColorSource.image(AssetImage('assets/images/theme/theme_image1.png')),
    MaterialColorSource.image(AssetImage('assets/images/theme/theme_image2.jpg')),
    MaterialColorSource.image(AssetImage('assets/images/theme/theme_image3.jpg')),
    MaterialColorSource.image(AssetImage('assets/images/theme/theme_image4.jpg')),
    MaterialColorSource.image(AssetImage('assets/images/theme/theme_image5.jpg')),
    MaterialColorSource.image(AssetImage('assets/images/theme/theme_image6.jpg')),
    MaterialColorSource.image(AssetImage('assets/images/theme/theme_image7.png')),
    MaterialColorSource.image(AssetImage('assets/images/theme/theme_image8.jpg')),
    MaterialColorSource.image(AssetImage('assets/images/theme/theme_image9.png')),
  ];
}

class MaterialColorSource {
  Color? color;

  ImageProvider? provider;

  MaterialColorSource.color(Color color) {
    this.color = color;
  }

  MaterialColorSource.image(ImageProvider provider) {
    this.provider = provider;
  }

  bool get isColor => this.color != null;

  bool get isImage => this.provider != null;

  Future<ColorScheme> colorScheme({
    Brightness brightness = Brightness.light,
    BackgroundMode backgroundMode = BackgroundMode.auto,
  }) async {
    Color? background = backgroundMode == BackgroundMode.classic && brightness == Brightness.light ? Colors.white : null;
    if (color != null) return ColorScheme.fromSeed(seedColor: color!, brightness: brightness, background: background);
    return ColorScheme.fromImageProvider(provider: provider!, brightness: brightness, background: background);
  }
}
