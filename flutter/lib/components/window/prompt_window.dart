import 'dart:convert';

enum DataType {
  image_list,
  image_grid,
  html,
  text,
  md,
}

class WindowDataItem {
  late DataType type;
  late var data;

  WindowDataItem.imageList(List<String> images) {
    data = images;
    type = DataType.image_list;
  }

  WindowDataItem.imageGrid(List<String> images) {
    data = images;
    type = DataType.image_grid;
  }

  WindowDataItem.md(this.data) {
    type = DataType.md;
  }

  WindowDataItem.text(this.data) {
    type = DataType.text;
  }

  WindowDataItem.html(this.data) {
    type = DataType.html;
  }

  Map toMap() => {
        'type': type.index,
        'data': data,
      };

  @override
  String toString() {
    return json.encode(toMap());
  }

  WindowDataItem.fromMap(Map map) {
    type = DataType.values[map['type']];
    data = map['data'];
  }
}

class WindowDataSource {
  late String title;
  late Map windowConfig;
  late List<WindowDataItem> contents;

  WindowDataSource({required this.title, required this.windowConfig, required this.contents});

  WindowDataSource.image({
    required this.title,
    required String image,
  }) {
    this.contents = [
      WindowDataItem.imageList([image])
    ];
  }

  WindowDataSource.fromMap(Map map) {
    title = map['title'];
    windowConfig = map['windowConfig'];
    List _contents = map['contents'];
    contents = _contents.map<WindowDataItem>((e) => WindowDataItem.fromMap(e)).toList();
  }

  Map toMap() => {
        'title': title,
        'windowConfig': windowConfig,
        'contents': contents.map((e) => e.toMap()).toList(),
      };

  @override
  String toString() {
    return json.encode(toMap());
  }
}