import 'package:bot_toast/bot_toast.dart';
import 'package:dartx/dartx.dart' as dx;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/extensions/widget_extensions.dart';
import 'package:flutter_smart_genome/widget/basic/custom_bot_widget.dart';

Widget SimplePopMenuButton<T>({
  required BuildContext context,
  required List<T> items,
  required T? initialValue,
  dx.Function1<T, Widget>? itemBuilder,
  dx.Function1<T?, String>? buttonTextBuilder,
  String? tooltip,
  Offset? offset,
  EdgeInsets? buttonPadding,
  BoxConstraints? buttonConstraints,
  PopupMenuItemSelected<T>? onSelected,
  BorderRadius? borderRadius,
  bool enabled = true,
}) {
  return Padding(
    padding: buttonPadding ?? EdgeInsets.zero,
    child: PopupMenuButton<T>(
      initialValue: initialValue,
      position: PopupMenuPosition.under,
      padding: EdgeInsets.zero,
      offset: offset ?? Offset.zero,
      tooltip: tooltip,
      enabled: enabled,
      constraints: BoxConstraints(maxWidth: 450),
      shape: RoundedRectangleBorder(borderRadius: borderRadius ?? BorderRadius.circular(10)),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
        constraints: buttonConstraints,
        decoration: BoxDecoration(
          borderRadius: borderRadius ?? BorderRadius.circular(10),
          border: Border.all(color: Theme.of(context).dividerColor, width: 1.0),
        ),
        child: Wrap(
          spacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 220),
              child: Text(
                buttonTextBuilder?.call(initialValue) ?? '${initialValue}',
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(overflow: TextOverflow.ellipsis),
              ),
            ),
            Icon(Icons.expand_more, size: 18, color: Theme.of(context).colorScheme.primary),
          ],
        ),
      ),
      itemBuilder: (c) {
        return items
            .map<PopupMenuEntry<T>>(
              (e) => PopupMenuItem<T>(
                child: itemBuilder?.call(e) ?? Text('${e}'),
                value: e,
              ),
            )
            .toList();
      },
      onSelected: onSelected,
    ),
  );
}

class SimpleDropdownButton<T> extends StatefulWidget {
  final dx.Function1<T?, String>? buttonTextBuilder;
  final BorderRadius? borderRadius;
  final List<T> items;
  final T? initialValue;
  final EdgeInsets? buttonPadding;
  final BoxConstraints buttonConstraints;
  final ValueChanged<T>? onSelectedChange;
  final dx.Function1<T, (Widget?, Widget)>? itemBuilder;
  final dx.Function1<T?, Widget>? childBuilder;
  final Size? minimumSize;
  final bool enabled;
  final BorderSide? borderSide;
  final double? itemWidth;
  final String? tooltip;
  final PreferDirection preferDirection;

  const SimpleDropdownButton({
    super.key,
    required this.items,
    this.initialValue,
    this.buttonTextBuilder,
    this.borderRadius,
    this.borderSide,
    this.buttonPadding = const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
    this.buttonConstraints = const BoxConstraints(maxWidth: 200),
    this.onSelectedChange,
    this.itemBuilder,
    this.minimumSize,
    this.enabled = true,
    this.childBuilder,
    this.itemWidth,
    this.tooltip,
    this.preferDirection = PreferDirection.bottomLeft,
  });

  @override
  State<SimpleDropdownButton<T>> createState() => _SimpleDropdownButtonState<T>();
}

class _SimpleDropdownButtonState<T> extends State<SimpleDropdownButton<T>> {
  T? _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
  }

  CancelFunc? _pop;

  @override
  void didUpdateWidget(covariant SimpleDropdownButton<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(widget.items, oldWidget.items) || widget.initialValue != oldWidget.initialValue) {
      _value = widget.initialValue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (c) {
      return OutlinedButton(
        style: OutlinedButton.styleFrom(
          padding: widget.buttonPadding,
          minimumSize: widget.minimumSize,
          side: widget.borderSide ?? BorderSide(color: Theme.of(context).dividerColor),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        ),
        child: widget.childBuilder?.call(_value) ??
            Wrap(
              spacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                ConstrainedBox(
                  constraints: widget.buttonConstraints,
                  child: Text(
                    widget.buttonTextBuilder?.call(_value) ?? '${_value}',
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(overflow: TextOverflow.ellipsis),
                  ),
                ),
                Icon(Icons.expand_more, size: 18, color: Theme.of(context).colorScheme.primary),
              ],
            ),
        onPressed: () {
          if (widget.enabled) _showSelectionListPop(c, widget.items);
        },
      ).tooltip(widget.tooltip);
    });
  }

  _showSelectionListPop(BuildContext context, List<T> items) {
    if (_pop != null) return;
    _pop = showAttachedWidget(
      targetContext: context,
      preferDirection: widget.preferDirection,
      onClose: () {
        _pop = null;
      },
      attachedBuilder: (call) {
        double h = (items.length * 42.0).clamp(42.0, MediaQuery.of(context).size.height * .65);
        double w = widget.itemWidth ?? (items.length > 0 ? '${items.maxBy((e) => '$e'.length)}'.length * 7.5 + 90 : 200);
        return Material(
          borderRadius: BorderRadius.circular(10),
          elevation: 6,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: w, maxHeight: h),
            child: ListView.separated(
              itemBuilder: (c, i) {
                bool checked = items[i] == _value;
                var (Widget? icon, Widget title) = widget.itemBuilder?.call(items[i]) ?? (null, Text('${items[i]}'));
                return ListTile(
                  title: title,
                  leading: icon,
                  horizontalTitleGap: 4,
                  dense: true,
                  selected: checked,
                  trailing: checked ? Icon(Icons.check, size: 16) : null,
                  onTap: () {
                    _value = items[i];
                    call.call();
                    setState(() {});
                    if (!checked) {
                      widget.onSelectedChange?.call(items[i]);
                    }
                  },
                );
              },
              separatorBuilder: (c, i) => Divider(height: 1, thickness: 1),
              itemCount: items.length,
            ),
          ),
        );
      },
    );
  }
}
