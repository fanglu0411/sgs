import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/base/app_layout.dart';

class AppLayoutPreviewWidget extends StatelessWidget {
  final ValueChanged<AppLayout>? onItemClick;
  final AppLayout currentLayout;

  const AppLayoutPreviewWidget({Key? key, required this.currentLayout, this.onItemClick}) : super(key: key);

  final List<Map> appLayoutList = const [
    {
      'name': 'Gnome Browser',
      'type': AppLayout.gnome,
      'preview': 'assets/images/layout/genome_Browser.png',
    },
    {
      'name': 'SG Browser 1',
      'type': AppLayout.SG_h,
      'preview': 'assets/images/layout/SG_Browser1.png',
    },
    {
      'name': 'SG Browser 2',
      'type': AppLayout.SG_v,
      'preview': 'assets/images/layout/SG_Browser2.png',
    },
    {
      'name': 'scBrowser',
      'type': AppLayout.SC,
      'preview': 'assets/images/layout/scBrowser.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    var _primaryColor = Theme.of(context).colorScheme.primary;
    return GridView.builder(
      padding: EdgeInsets.all(20),
      itemCount: appLayoutList.length,
      itemBuilder: (c, i) {
        var item = appLayoutList[i];
        bool current = item['type'] == currentLayout;
        return InkWell(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: current ? _primaryColor : _primaryColor.withOpacity(.25), width: current ? 1.5 : 1.0),
              borderRadius: BorderRadius.circular(5),
            ),
            child: GridTile(
              child: Image.asset(
                item['preview'],
                errorBuilder: (c, s, e) {
                  return Icon(Icons.broken_image, size: 60);
                },
              ),
              footer: Container(
                color: Colors.grey[200]!.withOpacity(.5),
                alignment: Alignment.center,
                margin: EdgeInsets.all(2),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    item['name'],
                    textScaleFactor: current ? 1.2 : null,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          fontWeight: FontWeight.w600,
                          color: current ? _primaryColor : null,
                        ),
                  ),
                ),
              ),
            ),
          ),
          onTap: () => onItemClick?.call(item['type']),
        );
      },
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
        childAspectRatio: 1.6,
      ),
    );
  }
}
