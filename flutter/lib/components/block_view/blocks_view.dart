import 'package:flutter/material.dart';

import 'models.dart';

class BlocksView extends StatefulWidget {
  final List<PageBlock> blocks;
  final EdgeInsetsGeometry blockPadding;

  const BlocksView({
    super.key,
    required this.blocks,
    this.blockPadding = const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
  });

  @override
  State<BlocksView> createState() => _BlocksViewState();
}

class _BlocksViewState extends State<BlocksView> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: _builder);
  }

  Widget _builder(BuildContext context, BoxConstraints constraints) {
    return CustomScrollView(
      slivers: widget.blocks.map((e) => e.renderSliver(context, constraints, widget.blockPadding)).toList(),
    );
  }

  Widget _blockBuilder(PageBlock e, BoxConstraints constraints) {
    switch (e.type) {
      case BlockType.image_list:
      case BlockType.image_grid:
      case BlockType.text:
      case BlockType.title:
      case BlockType.markdown:
      case BlockType.url:
      case BlockType.group:
        return e.renderSliver(context, constraints, widget.blockPadding);
    }
    return SliverToBoxAdapter(
      child: SizedBox(),
    );
  }
}
