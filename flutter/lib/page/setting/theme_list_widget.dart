import 'package:dartx/dartx.dart';
import 'package:flutter_smart_genome/base/background_mode.dart';
import 'package:flutter_smart_genome/m3/material_color_source.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/base/ui_config.dart';
import 'package:flutter_smart_genome/page/setting/theme_preview_widget.dart';
import 'package:flutter_smart_genome/service/public_service.dart';
import 'package:flutter_smart_genome/storage/base_store_provider.dart';

import 'package:flutter_smart_genome/theme/material_theme.dart';
import 'package:flutter_smart_genome/widget/toggle_button_group.dart';

class ThemeListWidget extends StatefulWidget {
  final ValueChanged<int>? onColorSelect;
  final double itemSpace;
  final EdgeInsetsGeometry? padding;
  final int? columns;

  const ThemeListWidget({
    Key? key,
    this.onColorSelect,
    this.itemSpace = 10,
    this.padding,
    this.columns,
  }) : super(key: key);

  @override
  _ThemeListWidgetState createState() => _ThemeListWidgetState();
}

class _ThemeListWidgetState extends State<ThemeListWidget> {
  late int _index = 0;

  @override
  void initState() {
    super.initState();
    _loadColor();
  }

  _loadColor() async {
    _index = await BaseStoreProvider.get().getThemeColor();
    setState(() {});
  }

  Widget _builder(BuildContext context, BoxConstraints constraints) {
    double _width = constraints.maxWidth;
    bool _isMobile = isMobile(context);

    // var list = PublicService.get()!.materialThemes.mapIndexed<Widget>(_buildItem).toList();
    var list = materialColorSources.mapIndexed(_buildColorSourceItem).toList();
    int column = widget.columns ?? _width ~/ (_isMobile ? 100 : 200);

    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(vertical: 6, horizontal: 2),
          child: Row(
            children: [
              Text('Theme Mode', style: Theme.of(context).textTheme.labelLarge),
              Spacer(),
              ToggleButtonGroup(
                constraints: BoxConstraints(maxHeight: 30, minHeight: 24),
                borderRadius: BorderRadius.circular(5),
                selectedIndex: PublicService.get()!.themeMode.index,
                onChange: PublicService.get()!.changeThemeMode,
                children: ThemeMode.values
                    .map(
                      (e) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6.0),
                        child: Text(e.name.capitalize()),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
          child: Row(
            children: [
              Text('Background', style: Theme.of(context).textTheme.labelLarge),
              Spacer(),
              ToggleButtonGroup(
                constraints: BoxConstraints(maxHeight: 30, minHeight: 24),
                borderRadius: BorderRadius.circular(5),
                selectedIndex: PublicService.get()!.backgroundMode.index,
                onChange: PublicService.get()!.setBackgroundMode,
                children: BackgroundMode.values
                    .map(
                      (e) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6.0),
                        child: Text(e.name.capitalize()),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
        SizedBox(height: 4),
        Expanded(
          child: GridView.count(
            crossAxisCount: column,
            shrinkWrap: true,
            children: list,
            childAspectRatio: 16 / 9,
            mainAxisSpacing: widget.itemSpace,
            crossAxisSpacing: widget.itemSpace,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: _builder);
  }

  Widget _buildColorSourceItem(int i, MaterialColorSource source) {
    bool isCurrent = PublicService.get()!.themeIndex == i;
    return InkWell(
      hoverColor: Theme.of(context).colorScheme.secondaryContainer,
      radius: 5,
      onTap: () {
        if (widget.onColorSelect != null) {
          widget.onColorSelect!(i);
          setState(() {
            _index = i;
          });
        }
      },
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: source.color,
          image: source.provider != null ? DecorationImage(image: source.provider!, fit: BoxFit.cover) : null,
        ),
        clipBehavior: Clip.antiAlias,
        child: isCurrent
            ? Container(
                child: Icon(Icons.check_circle, color: Colors.white, size: 36),
                color: Theme.of(context).colorScheme.inversePrimary.withOpacity(.45),
                alignment: Alignment.center,
              )
            : null,
      ),
    );
  }

  Widget _buildItem(int index, MaterialTheme theme) {
    Widget child = Container(
      alignment: Alignment.bottomCenter,
      padding: EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: theme.primary,
      ),
      child: _index == index ? Icon(Icons.check, color: Colors.white) : Text('${theme.name}'),
    );
    child = ThemePreviewWidget(theme: theme, checked: _index == index);
    return InkWell(
      onTap: () {
        if (widget.onColorSelect != null) {
          widget.onColorSelect!(index);
          setState(() {
            _index = index;
          });
        }
      },
      child: child,
    );
  }
}
