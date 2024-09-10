import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/base/ui_config.dart';
import 'package:flutter_smart_genome/bean/site_item.dart';
import 'package:flutter_smart_genome/components/sgs_logo.dart';
import 'package:flutter_smart_genome/routes.dart';
import 'package:flutter_smart_genome/service/sgs_app_service.dart';
import 'package:flutter_smart_genome/storage/base_store_provider.dart';
import 'package:flutter_smart_genome/storage/isar/site_provider.dart';

class NewProjectWidget extends StatefulWidget {
  final bool showBack;
  final VoidCallback? onBack;
  final VoidCallback? onViewExample;
  final ValueChanged<SiteItem>? onSubmit;

  const NewProjectWidget({Key? key, this.showBack = false, this.onBack, this.onViewExample, this.onSubmit}) : super(key: key);

  @override
  State<NewProjectWidget> createState() => _NewProjectWidgetState();
}

class _NewProjectWidgetState extends State<NewProjectWidget> {
  late GlobalKey<FormState> _formKey;
  late SiteItem _siteItem;

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey();
    _siteItem = SiteItem(url: '');
  }

  @override
  Widget build(BuildContext context) {
    // var size = MediaQuery.of(context).size;
    // if (size.width > 10000) {
    //   return Row(
    //     children: [
    //       Container(
    //         width: 280,
    //         child: Center(
    //           child: SizedBox(
    //             child: SgsLogo(fontSize: 40),
    //           ),
    //         ),
    //       ),
    //       Expanded(child: _buildRight(showLogo: false)),
    //     ],
    //   );
    // }
    return _buildRight(showLogo: true);
  }

  Widget _buildRight({
    showLogo = false,
  }) {
    bool _smallLandscape = smallLandscape(context);
    double itemSpace = _smallLandscape ? 10 : 20;

    return Stack(
      children: [
        Center(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 30),
            constraints: BoxConstraints(maxWidth: 500.0, minWidth: 300.0),
            child: Form(
              key: _formKey,
              child: Column(
                // mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  SizedBox(height: itemSpace),
                  if (showLogo && !_smallLandscape)
                    Center(
                      child: SizedBox(
                        child: SgsLogo(fontSize: 40),
                      ),
                    ),
                  if (!_smallLandscape) SizedBox(height: itemSpace),
                  if (!_smallLandscape)
                    Center(
                      child: Text(
                        'Welcome to SGS'.toUpperCase(),
                        style: Theme.of(context).textTheme.displaySmall,
                      ),
                    ),
                  if (!_smallLandscape) SizedBox(height: itemSpace),
                  Center(
                    child: Text(
                      'Connect to new server!',
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w300),
                    ),
                  ),
                  SizedBox(height: itemSpace),
                  SizedBox(
                    // width: 400,
                    child: TextFormField(
                      maxLines: 1,
                      decoration: InputDecoration(
                        hintText: 'http://www.sgs.com:6102',
                        labelText: 'Server Address',
                        helperText: 'server url is required',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value!.length == 0) return 'url is empty';
                        var regexp = RegExp('(https?|ftp|file)://[-A-Za-z0-9+&@#/%?=~_|!:,.;]+[-A-Za-z0-9+&@#/%=~_|]');
                        bool match = regexp.hasMatch(value);
                        return match ? null : 'server url is not valid';
                      },
                      onSaved: (url) {
                        _siteItem.url = url!;
                      },
                    ),
                  ),
                  SizedBox(height: itemSpace),
                  SizedBox(
                    // width: 400,
                    child: TextFormField(
                      maxLines: 1,
                      decoration: InputDecoration(
                        hintText: 'Server Name (Optional)',
                        labelText: 'Server Name (Optional)',
                        border: OutlineInputBorder(),
                      ),
                      onSaved: (name) {
                        _siteItem.name = name ?? '';
                      },
                    ),
                  ),
                  SizedBox(height: itemSpace),
                  ElevatedButton.icon(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(100, 40),
                    ),
                    icon: Icon(Icons.computer, size: 18),
                    label: Text('CONNECT'),
                  ),
                  SizedBox(height: itemSpace),
                  Wrap(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: Text("Don't have server? "),
                      ),
                      Tooltip(
                        message: 'Show the official example！',
                        child: TextButton(
                          style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.primary),
                          onPressed: widget.onViewExample,
                          child: Text('View Example'),
                        ),
                      ),
                      SizedBox(width: 10),
                      Tooltip(
                        message: 'Deploy SGS Service to your own Server!',
                        child: ElevatedButton.icon(
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                            elevation: 2,
                          ),
                          onPressed: () {
                            Navigator.of(context).pushNamed(RoutePath.server_create);
                          },
                          icon: Icon(Icons.add),
                          label: Text('Deploy SGS Server'),
                        ),
                      ),
                      SizedBox(width: 20),
                    ],
                    crossAxisAlignment: WrapCrossAlignment.center,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (widget.showBack)
          Positioned(
              left: 14,
              top: 14,
              child: IconButton.filledTonal(
                icon: Icon(Icons.arrow_back_rounded),
                iconSize: 20,
                onPressed: () {
                  widget.onBack?.call();
                },
                tooltip: 'BACK',
              ))
      ],
    );
  }

  _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    await BaseStoreProvider.get().addSite(_siteItem);
    SgsAppService.get()!.setSite(_siteItem);
    Navigator.of(context).popAndPushNamed(RoutePath.home);
  }
}
