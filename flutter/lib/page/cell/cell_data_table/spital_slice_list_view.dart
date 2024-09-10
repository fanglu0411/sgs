import 'package:flutter_smart_genome/widget/basic/custom_spin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/page/cell/cell_data_table/table_data_state.dart';
import 'package:flutter_smart_genome/service/sgs_app_service.dart';
import 'package:flutter_smart_genome/widget/track/base/track_data.dart';

class SpatialSliceView extends StatefulWidget {
  final SpatialSliceState state;
  final ValueChanged<Spatial>? onItemTap;

  SpatialSliceView({super.key, required this.state, this.onItemTap});

  @override
  State<SpatialSliceView> createState() => _SpatialSliceViewState();
}

class _SpatialSliceViewState extends State<SpatialSliceView> {
  late double? _itemWidth;

  double space = 12;

  @override
  Widget build(BuildContext context) {
    if (widget.state.loading) {
      return Center(child: CustomSpin(color: Theme.of(context).colorScheme.primary));
    }
    if (widget.state.error != null) {
      return Center(child: Text(widget.state.error!));
    }

    return LayoutBuilder(
      builder: (c, cc) {
        double width = cc.biggest.width;
        int columnCount = width ~/ 210;
        _itemWidth = (width - (columnCount - 1) * space) ~/ columnCount * 1.0;
        return SingleChildScrollView(
          padding: EdgeInsets.only(top: 12),
          child: Wrap(
            spacing: space,
            runSpacing: space,
            children: (widget.state.data ?? []).map<Widget>(_itemBuilder).toList(),
          ),
        );
      },
    );
  }

  Widget _itemBuilder(Spatial item) {
    bool current = widget.state.selectedSlice == item;
    return InkWell(
      hoverColor: Colors.green.withOpacity(.4),
      splashColor: Colors.green.withOpacity(.6),
      borderRadius: BorderRadius.circular(10),
      onTap: () {
        widget.state.selectedSlice = item;
        setState(() {});
        widget.onItemTap?.call(item);
      },
      child: Material(
        borderRadius: BorderRadius.circular(10),
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          width: _itemWidth! - 10,
          height: _itemWidth! - 10,
          child: GridTile(
            child: Image.network(
              '${SgsAppService.get()!.staticBaseUrl}${item.safeLowSlice.image}',
              fit: BoxFit.fill,
              width: _itemWidth! - 10,
              height: _itemWidth! - 10,
            ),
            // footer: Container(
            //   padding: const EdgeInsets.all(8.0),
            //   child: ElevatedButton(
            //     child: Text('View'),
            //     onPressed: () {},
            //   ),
            // ),
            header: Container(
              color: Colors.black87.withOpacity(.13),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              alignment: Alignment.center,
              child: Text('${item.key}',
                  style: TextStyle(
                    color: current ? Theme.of(context).colorScheme.primary : Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  )),
            ),
          ),
        ),
      ),
    );
  }
}
