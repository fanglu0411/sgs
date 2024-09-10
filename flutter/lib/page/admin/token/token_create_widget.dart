import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';

class TokenCreateWidget extends StatefulWidget {
  final ValueChanged<Map>? onSubmit;
  final VoidCallback? onCancel;

  const TokenCreateWidget({super.key, this.onSubmit, this.onCancel});

  @override
  State<TokenCreateWidget> createState() => _TokenCreateWidgetState();
}

class _TokenCreateWidgetState extends State<TokenCreateWidget> {
  List permissions = [
    {
      'name': 'admin',
      'label': 'Admin',
      'desc': 'Grant as admin user',
      'checked': false,
      'enabled': true,
    },
    {
      'name': 'list',
      'label': 'View',
      'desc': 'Permission for viewing data',
      'checked': true,
      'enabled': true,
    },
    {
      'name': 'add',
      'label': 'Add',
      'desc': 'Permission for adding data',
      'checked': true,
      'enabled': true,
    },
    {
      'name': 'delete',
      'label': 'Delete',
      'desc': 'Permission for deleting data',
      'checked': true,
      'enabled': true,
    },
  ];

  TextEditingController? _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'input username',
              labelText: 'Username',
            ),
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (v) {
              var a = v!.trim().toLowerCase();
              if (a == 'admin') return 'Admin is not permitted';
              if (a.length == 0) return "user name is required";
              return null;
            },
          ),
          SizedBox(height: 20),
          Text('Permissions', style: Theme.of(context).textTheme.titleSmall),
          Divider(height: 1),
          ...ListTile.divideTiles(
              tiles: permissions.map((e) => CheckboxListTile.adaptive(
                    value: e['checked'],
                    enabled: e['enabled'],
                    title: Text(e['label']),
                    subtitle: Text(e['desc']),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
                    onChanged: (v) {
                      e['checked'] = v!;
                      setState(() {});
                    },
                  )),
              context: context),
          SizedBox(height: 10),
          ButtonBar(
            children: [
              OutlinedButton(
                onPressed: widget.onCancel,
                child: Text('CANCEL'),
              ),
              ElevatedButton(
                onPressed: () {
                  var name = _nameController!.text.trim();
                  if (name.toLowerCase() == 'admin' || name.length == 0) return;
                  List roles = permissions.filter((p) => p['checked']).map((e) => e['name']).toList();
                  widget.onSubmit?.call({'username': name, 'roles': roles});
                },
                child: Text('CREATE'),
              ),
            ],
          )
        ],
      ),
    );
  }
}
