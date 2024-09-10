import 'package:dartx/dartx.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/bean/field_item.dart';

class SshFormWidget extends StatefulWidget {
  final Function4? onSubmit;

  const SshFormWidget({
    Key? key,
    this.onSubmit,
  }) : super(key: key);

  @override
  _SshFormWidgetState createState() => _SshFormWidgetState();
}

class _SshFormWidgetState extends State<SshFormWidget> {
  String? _host;
  int? _port;
  String? _username;
  String? _password;
  bool _passwordVisible = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late TextEditingController _hostController;
  late TextEditingController _portController;
  late TextEditingController _nameController;
  late TextEditingController _passController;

  final RegExp hostReg = RegExp(r'^\d{1,3}.\d{1,3}.\d{1,3}.\d{1,3}$');

  List<FieldItem> _fields = [
    FieldItem(
      label: 'host',
      name: 'host',
      required: true,
    ),
    FieldItem(
      label: 'port',
      name: 'port',
      required: true,
    ),
    FieldItem(
      label: 'username',
      name: 'username',
      required: true,
    ),
    FieldItem(
      label: 'password',
      name: 'password',
      required: true,
    ),
  ];

  @override
  void initState() {
    super.initState();

    _hostController = TextEditingController(text: kDebugMode ? '192.168.1.202' : '');
    _portController = TextEditingController(text: kDebugMode ? '22' : '22');
    _nameController = TextEditingController(text: 'root');
    _passController = TextEditingController();
  }

  void _checkFormValue() {
    bool validate = _formKey.currentState!.validate();
    if (validate) {
      _formKey.currentState!.save();
      _onSubmit();
    }
  }

  void _onSubmit() {
    widget.onSubmit?.call(
      _host,
      _port,
      _username,
      _password,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: _build,
    );
  }

  Widget _build(BuildContext context, BoxConstraints constraints) {
    double width = 400; //constraints.maxWidth;

    bool horizontal = false; //width >= 840;
    double? _fieldHeight; //horizontal ? 48 : 48;
    SizedBox _space = horizontal ? SizedBox(width: 10) : SizedBox(height: 10);

    List<Widget> _children = [
      SizedBox(
        width: width,
        height: _fieldHeight,
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _hostController,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400, letterSpacing: 2),
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 6),
                  border: OutlineInputBorder(),
                  // labelText: 'host',
                  hintText: 'host',
                  suffixIcon: IconButton(
                    iconSize: 18,
                    icon: Icon(Icons.clear),
                    constraints: BoxConstraints.tightFor(width: 30, height: 30),
                    splashRadius: 15,
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      _hostController.clear();
                    },
                  ),
                ),
                onSaved: (v) {
                  _host = v;
                },
                validator: (v) {
                  if (v!.length == 0) return 'Host is empty!';
                  if (!hostReg.hasMatch(v)) {
                    return 'Host is not valid';
                  }
                  return null;
                },
              ),
              flex: 3,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Text(' : ', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: TextFormField(
                controller: _portController,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400, letterSpacing: 2),
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 6),
                  border: OutlineInputBorder(),
                  hintText: '22',
                  // labelText: 'port',
                ),
                onSaved: (v) {
                  _port = int.tryParse(v!) ?? 22;
                },
                validator: (v) {
                  return null;
                },
              ),
              flex: 1,
            ),
          ],
        ),
      ),
      _space,
      SizedBox(
        width: width,
        height: _fieldHeight,
        child: TextFormField(
          controller: _nameController,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400, letterSpacing: 2),
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 6),
            border: OutlineInputBorder(),
            labelText: 'Username',
            suffixIcon: IconButton(
              icon: Icon(Icons.clear),
              iconSize: 18,
              constraints: BoxConstraints.tightFor(width: 30, height: 30),
              splashRadius: 15,
              padding: EdgeInsets.zero,
              onPressed: () {
                _nameController.clear();
              },
            ),
          ),
          onSaved: (v) => _username = v,
          validator: (v) => v!.length > 0 ? null : 'Username is empty!',
        ),
      ),
      _space,
      SizedBox(
        width: horizontal ? 200 : width,
        height: _fieldHeight,
        child: TextFormField(
          controller: _passController,
          // keyboardType: TextInputType.visiblePassword,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400, letterSpacing: 2),
          obscureText: !_passwordVisible,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 6),
            border: OutlineInputBorder(),
            labelText: 'Password',
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  iconSize: 18,
                  icon: Icon(_passwordVisible ? Icons.visibility : Icons.visibility_off),
                  constraints: BoxConstraints.tightFor(width: 20, height: 20),
                  splashRadius: 15,
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    _passwordVisible = !_passwordVisible;
                    setState(() {});
                  },
                ),
                SizedBox(width: 10),
                IconButton(
                  icon: Icon(Icons.clear),
                  iconSize: 18,
                  constraints: BoxConstraints.tightFor(width: 30, height: 30),
                  splashRadius: 15,
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    _passController.clear();
                  },
                ),
                SizedBox(width: 10),
              ],
            ),
          ),
          onSaved: (v) => _password = v,
          validator: (v) => v!.length > 0 ? null : 'Password is empty!',
        ),
      ),
      _space,
      FilledButton(
        onPressed: _checkFormValue,
        style: FilledButton.styleFrom(
          minimumSize: horizontal ? null : Size(width, 48),
        ),
        child: Text('Connect to Server'),
      )
    ];

    Widget _widget;

    if (horizontal) {
      _widget = Wrap(
        crossAxisAlignment: WrapCrossAlignment.start,
        spacing: 10,
        runSpacing: 12,
        direction: Axis.horizontal,
        children: _children,
      );
    } else {
      _widget = Wrap(
        spacing: 10,
        runSpacing: 12,
        direction: Axis.vertical,
        // mainAxisSize: MainAxisSize.min,
        // crossAxisAlignment: CrossAxisAlignment.start,
        children: _children,
      );
    }
    return Form(
      key: _formKey,
      child: _widget,
    );
  }
}
