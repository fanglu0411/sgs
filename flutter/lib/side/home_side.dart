import 'package:flutter/material.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:flutter_smart_genome/R.dart';
import 'package:flutter_smart_genome/components/sgs_logo.dart';
import 'package:flutter_smart_genome/page/help/help_widget.dart';
import 'package:flutter_smart_genome/page/setting/setting_page.dart';
import 'package:flutter_smart_genome/routes.dart';
import 'package:get/get.dart';

class HomeSide extends StatefulWidget {
  final bool pop;
  const HomeSide({Key? key, this.pop = true}) : super(key: key);

  @override
  State<HomeSide> createState() => _HomeSideState();
}

class _HomeSideState extends State<HomeSide> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // _buildUserHeader(),
          // ExpansionTile(
          //   initiallyExpanded: true,
          //   leading: Icon(MaterialCommunityIcons.file_upload),
          //   title: Text('Load Local File'),
          //   children: [
          //     Padding(
          //       padding: EdgeInsets.only(left: 20),
          //       child: ListTile(
          //         dense: true,
          //         leading: Icon(MaterialCommunityIcons.file_document),
          //         title: Text('1. Genome (fasta) File'),
          //         onTap: () {},
          //       ),
          //     ),
          //     Padding(
          //       padding: EdgeInsets.only(left: 20),
          //       child: ListTile(
          //         dense: true,
          //         leading: Icon(MaterialCommunityIcons.file),
          //         title: Text('2. Track File'),
          //         onTap: () {
          //           Navigator.of(context).pop();
          //           widget.onTapMenu?.call('track-file');
          //         },
          //       ),
          //     ),
          //     Padding(
          //       padding: EdgeInsets.only(left: 20),
          //       child: ListTile(
          //         dense: true,
          //         leading: Icon(MaterialCommunityIcons.history),
          //         title: Text('3. History'),
          //         onTap: () {
          //           Navigator.of(context).pop();
          //           widget.onTapMenu?.call('locale-history');
          //         },
          //       ),
          //     ),
          //   ],
          // ),
          //          ListTile(
          //            leading: Icon(MaterialCommunityIcons.file_document_box_outline),
          //            title: Text('Sessions'),
          //            onTap: () {
          //              Navigator.of(context).pop();
          //              widget.onTapMenu?.call('session');
          //            },
          //          ),

          // Divider(thickness: 1, height: 1),
          ListTile(
            leading: Icon(MaterialCommunityIcons.database_plus),
            title: Text('Create SGS server'),
            // subtitle: Text('deploy a new sgs server'),
            onTap: () {
              if (widget.pop) Navigator.pop(context);
              Get.toNamed(RoutePath.server_create);
            },
          ),
          Divider(thickness: 1, height: 1),

          // ExpansionTile(
          //   leading: Icon(MaterialCommunityIcons.toolbox),
          //   title: Text('Tools'),
          //   children: [
          //     Padding(
          //       padding: EdgeInsets.only(left: 20),
          //       child: ListTile(
          //         dense: true,
          //         leading: Icon(MaterialCommunityIcons.file_document),
          //         title: Text('Pangenome'),
          //         onTap: () {},
          //       ),
          //     ),
          //     Divider(thickness: 1, height: 1),
          //     Padding(
          //       padding: EdgeInsets.only(left: 20),
          //       child: ListTile(
          //         dense: true,
          //         leading: Icon(MaterialCommunityIcons.file),
          //         title: Text('Synteny'),
          //         onTap: () {},
          //       ),
          //     ),
          //   ],
          // ),
          // Divider(thickness: 1, height: 1),
          ListTile(
            leading: Icon(Icons.help),
            title: Text('Help'),
            onTap: () => showHelpDialog(context),
          ),
          Divider(thickness: 1, height: 1),
          //          Spacer(),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
            onTap: () {
              // if (_mobile) {
              //   Navigator.of(context).popAndPushNamed(RoutePath.settings);
              // } else
              {
                if (widget.pop) Navigator.of(context).pop();
                _showSettingDialog(context);
              }
            },
          ),
          Divider(thickness: 1, height: 1),
          ListTile(
            leading: Icon(Icons.info),
            title: Text('About'),
            onTap: _showAboutDialog,
          ),
        ],
      ),
    );
  }

  void _showSettingDialog(BuildContext context) async {
    await showSettingDialog(context);
  }

  void _showAboutDialog() {
    var dialog = AlertDialog(
      content: ListBody(
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
//                width: 40,
                height: 40,
                child: SgsLogo(
                  color: Theme.of(context).colorScheme.primary,
                  padding: EdgeInsets.zero,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: ListBody(
                    children: <Widget>[
                      Text('Smart Genome DB', style: Theme.of(context).textTheme.titleLarge),
                      SizedBox(height: 10),
                      Text('v:${R.version} ${R.buildTime}', style: Theme.of(context).textTheme.bodyMedium),
                      Container(height: 18.0),
                      Text('@2020 SouthWest University', style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Text('Smart Genome DB is an open-source genome browser to help researchers build high-fidelity cross platform apps.'),
        ],
      ),
      actions: <Widget>[
        TextButton(
          child: Text(MaterialLocalizations.of(context).closeButtonLabel),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ],
      scrollable: true,
    );
    showDialog(context: context, builder: (c) => dialog);
  }
}
