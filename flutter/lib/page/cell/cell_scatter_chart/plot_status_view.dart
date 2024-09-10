import 'package:flutter_smart_genome/widget/basic/custom_spin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/page/cell/cell_scatter_chart/plot_states.dart';

class PlotStatusView extends StatelessWidget {
  final PlotDrawState state;

  const PlotStatusView({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(10),
      color: Theme.of(context).dialogBackgroundColor.withOpacity(.95),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (state.loading) CustomSpin(color: Theme.of(context).colorScheme.primary),
            if (state.msg != null) Text('${state.msg}'),
          ],
        ),
      ),
    );
  }
}
