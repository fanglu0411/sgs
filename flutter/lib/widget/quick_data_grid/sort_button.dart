import 'dart:math';

import 'package:flutter/material.dart';

enum SortState {
  desc,
  asc,
  none;

  String? get type => this == none ? null : this.name;
}

typedef SortCallback = void Function(SortState state);

class SortButton extends StatefulWidget {
  final SortCallback? onSort;
  final SortState? state;

  const SortButton({super.key, this.onSort, this.state});

  @override
  State<SortButton> createState() => _SortButtonState();
}

class _SortButtonState extends State<SortButton> {
  late SortState _sortState;

  @override
  void initState() {
    super.initState();
    _sortState = widget.state ?? SortState.none;
  }

  @override
  void didUpdateWidget(covariant SortButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state != null) _sortState = widget.state!;
  }

  _onPress() {
    _sortState = nextState;
    setState(() {});
    widget.onSort?.call(_sortState);
  }

  SortState get nextState => switch (_sortState) {
        SortState.desc => SortState.asc,
        SortState.asc => SortState.none,
        SortState.none => SortState.desc,
      };

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: _onPress,
      child: icon,
      style: TextButton.styleFrom(
        minimumSize: Size(30, 30),
        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        foregroundColor: _sortState == SortState.none ? Theme.of(context).colorScheme.outline : Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget get icon => switch (_sortState) {
        SortState.desc => Icon(Icons.sort_rounded, size: 18),
        SortState.asc => Transform.flip(flipY: true, child: Icon(Icons.sort_rounded, size: 18)),
        SortState.none => Icon(Icons.sort_rounded, size: 18),
      };
}
