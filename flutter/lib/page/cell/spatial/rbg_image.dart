import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:dartx/dartx.dart';
import 'package:flutter_smart_genome/service/sgs_config_service.dart';
import 'package:image/image.dart' as img;

Future<Uint8List> imageBytesFromRBG2(List<List> rgb) async {
  int height = rgb.length;
  int width = rgb.length;

  // img.Image image = img.Image(width: width, height: height);
  List _list = rgb.flatten();
  List<int> __list = _list
      .map<List<int>>((e) => [
            ...e.map<int>((n) {
              double _n = n;
              return (_n * 255).toInt();
            }),
            255
          ])
      .flatten()
      .toList();
  Uint8List bytes = Uint8List.fromList(__list);
  return bytes;
}

Future<Uint8List> imageBytesFromRBG(List<List> rgb) async {
  int height = rgb.length;
  int width = rgb.length;
  // img.Image image = img.Image(width: width, height: height);
  List _list = rgb.flatten();
  List<int> __list = _list
      .map<List<int>>((e) => e.map<int>((n) {
            double _n = n;
            return (_n * 255).toInt();
          }).toList())
      .flatten()
      .toList();
  Uint8List bytes = Uint8List.fromList(__list);
  return bytes;
}

Future<img.Image> fromRBG(List<List> rgb) async {
  int height = rgb.length;
  int width = rgb.length;

  Uint8List bytes = await imageBytesFromRBG(rgb);
  var image = img.Image.fromBytes(width: width, height: height, bytes: bytes.buffer, numChannels: 3, order: img.ChannelOrder.rgb);

  return image;
}

Future<img.Image?> fromFile(String file) async {
  return img.decodeImageFile(file);
}

Future<img.Image> fromImage(Uint8List bytes) async {
  final image = await img.decodeImage(bytes);
  return image!;
}

Future<Uint8List> imageToUint8List(img.Image image) async {
  if (image.format != img.Format.uint8 || image.numChannels != 4) {
    final cmd = img.Command()
      ..image(image)
      ..convert(format: img.Format.uint8, numChannels: 4);
    final rgba8 = await cmd.getImageThread();
    if (rgba8 != null) {
      image = rgba8;
    }
  }
  return image.toUint8List();
}

Future saveSpatialImage(img.Image image, String filename) async {
  var path = '${SgsConfigService.get()!.applicationDocumentsPath}/${filename}';
  print('saving to ${path}');
  await img.Command()
    ..image(image)
    ..writeToFile(path)
    ..executeThread();
}

// Future<Image> fromList(List<List> rgb) async {
//   Image.memory(bytes);
//   List _list = rgb.flatten();
//   Uint8List bytes = Uint8List.fromList(_list.flatten());
//   decodeImageFromPixels(
//       bytes,
//     1080,1080,
//       PixelFormat.rgba8888,
//   );
// }

Future<ui.Image> convertImageToFlutterUi(img.Image image) async {
  if (image.format != img.Format.uint8 || image.numChannels != 4) {
    final cmd = img.Command()
      ..image(image)
      ..convert(format: img.Format.uint8, numChannels: 4);
    final rgba8 = await cmd.getImageThread();
    if (rgba8 != null) {
      image = rgba8;
    }
  }
  ui.ImmutableBuffer buffer = await ui.ImmutableBuffer.fromUint8List(image.toUint8List());
  ui.ImageDescriptor id = ui.ImageDescriptor.raw(buffer, height: image.height, width: image.width, pixelFormat: ui.PixelFormat.rgba8888);
  ui.Codec codec = await id.instantiateCodec(targetHeight: image.height, targetWidth: image.width);
  ui.FrameInfo fi = await codec.getNextFrame();
  ui.Image uiImage = fi.image;

  return uiImage;
}
