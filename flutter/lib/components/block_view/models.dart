import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_smart_genome/components/markdown_widget.dart';
import 'package:flutter_smart_genome/widget/basic/custom_spin.dart';

enum BlockType {
  image_list,
  image_grid,
  text,
  title,
  markdown,
  url,
  group,
}

abstract class PageBlock {
  late BlockType type;
  double? maxWidth;

  PageBlock({required this.type, this.maxWidth});

  Widget render(BuildContext context, BoxConstraints constraints, EdgeInsetsGeometry padding);

  Widget renderSliver(BuildContext context, BoxConstraints constraints, EdgeInsetsGeometry padding);
}

class ImageBlock extends PageBlock {
  late String image;

  ImageBlock(this.image, {double? maxWidth}) : super(type: BlockType.image_grid, maxWidth: maxWidth) {}

  Widget renderImage(BuildContext context, BoxConstraints constraints) {
    return Image.network(
      image,
      width: maxWidth,
      fit: BoxFit.contain,
      alignment: Alignment.center,
    );
  }

  @override
  Widget render(BuildContext context, BoxConstraints constraints, EdgeInsetsGeometry padding) {
    return renderImage(context, constraints);
  }

  @override
  Widget renderSliver(BuildContext context, BoxConstraints constraints, EdgeInsetsGeometry padding) {
    return SliverPadding(
      padding: padding,
      sliver: SliverToBoxAdapter(
        child: renderImage(context, constraints),
      ),
    );
  }
}

abstract class ImagesBlock extends PageBlock {
  late List<String> images;

  ImagesBlock(this.images, {required super.type, super.maxWidth});

  Widget buildItem(BuildContext context, int index) {
    return Image.network(
      images[index],
      fit: BoxFit.cover,
      width: maxWidth,
      alignment: Alignment.center,
      errorBuilder: (c, e, s) {
        print(e);
        print(s);
        return Icon(Icons.broken_image_outlined, size: 36);
      },
      loadingBuilder: (c, child, progress) {
        if (progress == null || progress.expectedTotalBytes == progress.cumulativeBytesLoaded) return child;
        print(progress);
        return CustomSpin(size: 32, color: Theme.of(context).colorScheme.primary);
      },
    );
  }
}

class ImageGridBlock extends ImagesBlock {
  int columns;

  ImageGridBlock(super.images, {this.columns = 2, double? maxWidth}) : super(type: BlockType.image_grid, maxWidth: maxWidth) {}

  @override
  Widget render(BuildContext context, BoxConstraints constraints, EdgeInsetsGeometry padding) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 400.0),
      itemBuilder: buildItem,
    );
  }

  @override
  Widget renderSliver(BuildContext context, BoxConstraints constraints, EdgeInsetsGeometry padding) {
    return SliverPadding(
      padding: padding,
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(buildItem, childCount: images.length),
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 800,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          childAspectRatio: 1.618,
        ),
      ),
    );
  }
}

class ImageListBlock extends ImagesBlock {
  ImageListBlock(super.images, {double? maxWidth}) : super(type: BlockType.image_list, maxWidth: maxWidth) {}

  @override
  Widget render(BuildContext context, BoxConstraints constraints, EdgeInsetsGeometry padding) {
    return ListView.builder(itemBuilder: buildItem);
  }

  @override
  Widget renderSliver(BuildContext context, BoxConstraints constraints, EdgeInsetsGeometry padding) {
    return SliverPadding(
      padding: padding,
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(buildItem, childCount: images.length),
      ),
    );
  }
}

abstract class GroupBlock extends PageBlock {
  List<PageBlock> blocks;
  List<int>? fractions;

  GroupBlock({required this.blocks, this.fractions, required super.type}) {
    fractions ??= _defaultFractions();
  }

  List<int> _defaultFractions() {
    return blocks.map((e) => 1).toList();
  }
}

class RowBlock extends GroupBlock {
  RowBlock({required super.blocks, super.fractions}) : super(type: BlockType.group);

  @override
  Widget render(BuildContext context, BoxConstraints constraints, EdgeInsetsGeometry padding) {
    int i = 0;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: blocks
          .map((e) => Expanded(
                child: e.render(context, constraints, padding),
                flex: fractions![i++],
              ))
          .toList(),
    );
  }

  @override
  Widget renderSliver(BuildContext context, BoxConstraints constraints, EdgeInsetsGeometry padding) {
    int i = 0;
    return SliverPadding(
      padding: padding,
      sliver: SliverToBoxAdapter(
        child: render(context, constraints, padding),
      ),
    );
  }
}

class TextBlock extends PageBlock {
  late String content;
  TextStyle? textStyle;

  TextBlock(
    this.content, {
    this.textStyle,
  }) : super(type: BlockType.text) {}

  @override
  Widget render(BuildContext context, BoxConstraints constraints, EdgeInsetsGeometry padding) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(content, style: textStyle),
    );
  }

  @override
  Widget renderSliver(BuildContext context, BoxConstraints constraints, EdgeInsetsGeometry padding) {
    return SliverPadding(
      padding: padding,
      sliver: SliverToBoxAdapter(child: this.render(context, constraints, padding)),
    );
  }
}

class ParagraphBlock extends TextBlock {
  ParagraphBlock(super.content, {super.textStyle = const TextStyle(fontSize: 14)}) {}
}

class TitleBlock extends TextBlock {
  TitleBlock(super.content, {super.textStyle = const TextStyle(fontSize: 16)}) {}
}

class MarkdownBlock extends TextBlock {
  MarkdownBlock(super.content, {super.textStyle = const TextStyle(fontSize: 16)}) {}

  @override
  Widget render(BuildContext context, BoxConstraints constraints, EdgeInsetsGeometry padding) {
    return Padding(
      padding: padding,
      child: MarkdownBody(data: content),
    );
  }

  @override
  Widget renderSliver(BuildContext context, BoxConstraints constraints, EdgeInsetsGeometry padding) {
    return SliverPadding(
      padding: padding,
      sliver: SliverMarkdownList(data: content),
    );
  }
}
