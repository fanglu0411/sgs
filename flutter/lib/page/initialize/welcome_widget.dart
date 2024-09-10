import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_genome/bean/site_item.dart';
import 'package:flutter_smart_genome/components/sgs_logo.dart';
import 'package:flutter_smart_genome/extensions/widget_extensions.dart';
import 'package:flutter_smart_genome/platform/platform_adapter.dart';
import 'package:flutter_smart_genome/routes.dart';
import 'package:flutter_smart_genome/service/public_service.dart';
import 'package:flutter_smart_genome/service/sgs_app_service.dart';
import 'package:flutter_smart_genome/storage/base_store_provider.dart';

import 'package:flutter_smart_genome/widget/basic/custom_multi_size_layout.dart';
import 'package:flutter_smart_genome/widget/basic/fast_rich_text.dart';

class WelcomeWidget extends StatelessWidget {
  final List<SiteItem> sites;
  final VoidCallback? onNewProject;
  final ValueChanged<SiteItem>? onRemove;

  const WelcomeWidget({
    Key? key,
    this.sites = const [],
    this.onNewProject,
    this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomMultiSizeLayout.builder(
      tablet: (c) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: _buildLeft(context), flex: 2),
            // SizedBox(width: 10),
            VerticalDivider(width: 1),
            SizedBox(width: 10),
            Expanded(
              flex: 3,
              child: _buildRecentList(context),
            ),
            SizedBox(width: 20),
          ],
        );
      },
      mobile: (c) {
        return _buildRecentList(c);
      },
    );
  }

  Widget _buildLeft(BuildContext context) {
    var appInfo = PublicService.get()!.appInfo;
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: [
            Theme.of(context).colorScheme.primaryContainer,
            Theme.of(context).scaffoldBackgroundColor,
          ],
          radius: 4,
          stops: [0, .5],
          center: Alignment(-1.5, 1.5),
        ),
        color: Theme.of(context).colorScheme.secondaryContainer,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(child: SizedBox(), flex: 1),
          Container(
            child: SgsLogo(fontSize: 80),
            margin: EdgeInsets.symmetric(vertical: 20, horizontal: 12),
          ),
          Text('SGS', style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w900, color: Theme.of(context).colorScheme.primary)),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Text('⎯ ⎧ Smart Genome System ⎭ ⎯', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900, color: Theme.of(context).colorScheme.secondary)),
          ),
          Text('v${appInfo?.version} ',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.secondary,
                  )),

          Expanded(child: SizedBox(), flex: 2),
          // Text('SGS\nv ${appInfo?.version}', style: TextStyle(), textScaleFactor: 1.2)
        ],
      ),
    );
  }

  Widget _buildRecentList(BuildContext context) {
    var recent = BaseStoreProvider.get().getCurrentSite();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                  child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.search),
                  contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                ),
              )),
              SizedBox(width: 10),
              TextButton(
                  onPressed: () {
                    onNewProject?.call();
                  },
                  child: Text('NEW CONNECTION')),
              SizedBox(width: 10),
            ],
          ),
          SizedBox(height: 4),
          Expanded(
            child: ListView.builder(
              itemExtent: 60,
              itemCount: sites.length,
              itemBuilder: (c, i) {
                SiteItem s = sites[i];
                return ListTile(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
                        title: Text(s.nameEmpty ? s.url : s.name!),
                        subtitle: s.nameEmpty ? null : Text(s.url),
                        onTap: () => _onItemTap(context, s),
                        autofocus: true,
                        selected: recent?.url == s.url && recent?.name == s.name,
                        trailing: s.isDemoServer
                            ? null
                            : PopupMenuButton<String>(
                                itemBuilder: (c) {
                                  return <PopupMenuEntry<String>>[
                                    PopupMenuItem(
                                      child: Text('Copy Url'),
                                      value: 'copy',
                                    ),
                                    PopupMenuDivider(height: 1),
                                    PopupMenuItem(
                                      child: Text('Remove'),
                                      value: 'remove',
                                    ),
                                  ];
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                  child: Icon(Icons.more_vert_rounded),
                                ),
                                padding: EdgeInsets.zero,
                                position: PopupMenuPosition.under,
                                onSelected: (v) {
                                  if (v == 'copy') {
                                    Clipboard.setData(ClipboardData(text: s.url));
                                  } else if (v == 'remove') {
                                    onRemove?.call(s);
                                  }
                                },
                              ))
                    .withBottomBorder(color: Theme.of(context).dividerColor);
              },
            ),
          ),
        ],
      ),
    );
  }

  _onItemTap(BuildContext context, SiteItem site) async {
    // PlatformAdapter.create().setWindowSize(Size.zero, fullscreen: true);
    // await Future.delayed(Duration(milliseconds: 200));
    // setState(() {
    //   _resizing = false;
    // });
    SgsAppService.get()!.setSite(site);
    Navigator.of(context).popAndPushNamed(RoutePath.home);
  }
}
