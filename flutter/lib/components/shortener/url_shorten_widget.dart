import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:flutter_smart_genome/components/shortener/url_shortener_logic.dart';
import 'package:flutter_smart_genome/extensions/widget_extensions.dart';
import 'package:flutter_smart_genome/widget/basic/custom_bot_widget.dart';
import 'package:flutter_smart_genome/widget/basic/custom_spin.dart';
import 'package:flutter_smart_genome/widget/toggle_button_group.dart';
import 'package:flutter_smart_genome/widget/track/base/track_session.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'supplier/shorten_supplier.dart';

class UrlShortenWidget extends StatefulWidget {
  final String url;

  const UrlShortenWidget({super.key, required this.url});

  @override
  State<UrlShortenWidget> createState() => _UrlShortenWidgetState();
}

class _UrlShortenWidgetState extends State<UrlShortenWidget> {
  final logic = UrlShortenerLogic();

  TextEditingController? _endpointController;
  TextEditingController? _tokenController;
  TextEditingController? _domainController;

  @override
  initState() {
    super.initState();
    logic.targetUrl = widget.url;
    _endpointController = TextEditingController();
    _domainController = TextEditingController();
    _tokenController = TextEditingController();
  }

  Widget _build(UrlShortenerLogic logic) {
    ShortenSupplier current = logic.shortener;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ToggleButtonGroup(
              selectedIndex: logic.currentIndex,
              constraints: BoxConstraints.tightFor(height: 30),
              borderRadius: BorderRadius.circular(5),
              children: logic.shortenerList.map((e) {
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                  child: Text(e.name),
                );
              }).toList(),
              onChange: (index) => logic.changeCurrent(index, _endpointController!, _domainController!, _tokenController!),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(Icons.help_center).tooltip('Use third api to short url\nYou need config your own token and domain in third party.'),
            ),
            Spacer(),
            if (!current.isOrigin)
              SelectableText(
                '${current.website}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            if (!current.isOrigin)
              IconButton(
                onPressed: () {
                  launchUrlString('${current.website}');
                },
                icon: Icon(CupertinoIcons.arrow_right_square_fill),
                tooltip: 'To Website',
                color: Theme.of(context).primaryColor,
                iconSize: 18,
                constraints: BoxConstraints.tightFor(width: 30, height: 30),
                padding: EdgeInsets.zero,
              ),
          ],
        ),
        if (!current.isOrigin) SizedBox(height: 15),
        if (!current.isOrigin)
          Wrap(
            spacing: 20,
            runSpacing: 20,
            alignment: WrapAlignment.spaceBetween,
            children: [
              TextFormField(
                controller: _endpointController,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 10),
                  constraints: BoxConstraints(minWidth: 140, maxWidth: 240, maxHeight: 36),
                  labelText: 'Api Url',
                  border: OutlineInputBorder(),
                ),
              ),
              TextFormField(
                controller: _domainController,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 10),
                  constraints: BoxConstraints(minWidth: 80, maxWidth: 120, maxHeight: 36),
                  labelText: 'Domain',
                  border: OutlineInputBorder(),
                ),
              ),
              TextFormField(
                controller: _tokenController,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 10),
                  constraints: BoxConstraints(minWidth: 140, maxWidth: 240, maxHeight: 36),
                  labelText: 'Token / Key',
                  border: OutlineInputBorder(),
                ),
              ),
              OutlinedButton(
                onPressed: () => logic.updateSupplier(_endpointController!, _domainController!, _tokenController!),
                child: Text('Update'),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                  minimumSize: Size(40, 42),
                ),
              ),
            ],
          ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 15),
          child: logic.shorting ? CustomSpin(size: 24, color: Theme.of(context).colorScheme.primary) : urlBuilder(logic.shortedUrl, logic.error),
        ),
      ],
    );
  }

  Widget urlBuilder(String? url, String? error) {
    if (url == null) {
      return Text(
        '${error}',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.error),
      );
    }
    return SelectableText.rich(
      TextSpan(
        style: Theme.of(context).textTheme.bodyMedium,
        children: [
          TextSpan(text: '$url'),
          WidgetSpan(
            baseline: TextBaseline.alphabetic,
            alignment: PlaceholderAlignment.middle,
            child: IconButton(
              padding: EdgeInsets.zero,
              color: Theme.of(context).primaryColor,
              constraints: BoxConstraints.tightFor(width: 30, height: 20),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: url!));
                showToast(text: 'Url copied to clipboard');
              },
              icon: Icon(Icons.content_copy, size: 16),
              tooltip: 'Copy url',
              //label: Text('copy url'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<UrlShortenerLogic>(
      init: logic,
      builder: _build,
    );
  }

  shortUrl(String url) {}
}
