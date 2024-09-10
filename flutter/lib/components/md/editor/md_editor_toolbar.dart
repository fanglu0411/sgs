import 'package:flutter/material.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:flutter_smart_genome/widget/upload/image_grid_upload_widget.dart';

enum MdEditorAction {
  bold,
  italic,
  heading,
  strikethrough,
  unordered_list,
  ordered_list,
  check_list,
  blockquote,
  code,
  table,
  link,
  image,
  newline,
  save,
}

class MdEditorToolbar extends StatefulWidget {
  final ValueChanged<MdEditorAction>? onMenuTap;

  const MdEditorToolbar({super.key, this.onMenuTap});

  @override
  State<MdEditorToolbar> createState() => _MdEditorToolbarState();
}

class _MdEditorToolbarState extends State<MdEditorToolbar> {
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 5,
      runSpacing: 10,
      alignment: WrapAlignment.start,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SizedBox(width: 5),
        _IconButton(
          onPressed: () => widget.onMenuTap?.call(MdEditorAction.bold),
          icon: Icon(Icons.format_bold),
          tooltip: 'Bold',
        ),
        _IconButton(
          onPressed: () => widget.onMenuTap?.call(MdEditorAction.italic),
          icon: Icon(Icons.format_italic),
          tooltip: 'Italic',
        ),
        _IconButton(
          onPressed: () => widget.onMenuTap?.call(MdEditorAction.heading),
          icon: Icon(Icons.format_size),
          tooltip: 'Heading',
        ),
        _IconButton(
          onPressed: () => widget.onMenuTap?.call(MdEditorAction.strikethrough),
          icon: Icon(Icons.format_strikethrough),
          tooltip: 'Strikethrough',
        ),
        _IconButton(
          onPressed: () => widget.onMenuTap?.call(MdEditorAction.unordered_list),
          icon: Icon(Icons.format_list_bulleted),
          tooltip: 'Unordered List',
        ),
        _IconButton(
          onPressed: () => widget.onMenuTap?.call(MdEditorAction.ordered_list),
          icon: Icon(Icons.format_list_bulleted),
          tooltip: 'Ordered List',
        ),
        _IconButton(
          onPressed: () => widget.onMenuTap?.call(MdEditorAction.check_list),
          icon: Icon(Icons.checklist),
          tooltip: 'Check List',
        ),
        _IconButton(
          onPressed: () => widget.onMenuTap?.call(MdEditorAction.blockquote),
          icon: Icon(Icons.format_quote),
          tooltip: 'Blockquote',
        ),
        _IconButton(
          onPressed: () => widget.onMenuTap?.call(MdEditorAction.code),
          icon: Icon(Icons.code),
          tooltip: 'Code',
        ),
        _IconButton(
          onPressed: () => widget.onMenuTap?.call(MdEditorAction.table),
          icon: Icon(FontAwesome.table, size: 16),
          tooltip: 'Table',
        ),
        _IconButton(
          onPressed: () => widget.onMenuTap?.call(MdEditorAction.link),
          icon: Icon(Icons.link),
          tooltip: 'Link',
        ),
        _IconButton(
          onPressed: () => widget.onMenuTap?.call(MdEditorAction.image),
          icon: Icon(Icons.image_rounded),
          tooltip: 'Image',
        ),
        SizedBox(height: 20, child: VerticalDivider(width: 1, thickness: 1)),
        _IconButton(
          onPressed: () => widget.onMenuTap?.call(MdEditorAction.save),
          icon: Icon(Icons.save, color: Theme.of(context).colorScheme.primary),
          tooltip: 'Save',
        ),
      ],
    );
  }

  Widget _IconButton({
    required VoidCallback onPressed,
    required Icon icon,
    String? tooltip,
  }) {
    return IconButton(
      onPressed: onPressed,
      icon: icon,
      iconSize: 18,
      constraints: BoxConstraints.tightFor(width: 32, height: 32),
      padding: EdgeInsets.zero,
      tooltip: tooltip,
    );
  }

  void _showImagePicker() {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: Text('Select Image'),
        content: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 800),
          child: ImageGridUploadWidget(maxFileCount: 5),
        ),
      ),
    );
  }
}
