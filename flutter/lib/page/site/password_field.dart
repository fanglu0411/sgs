import 'package:flutter/material.dart';

class PasswordField extends StatefulWidget {
  final ValueChanged<String>? onSubmitted;
  final TextEditingController? controller;
  final String hint;
  const PasswordField({
    Key? key,
    this.controller,
    this.onSubmitted,
    this.hint = "password",
  }) : super(key: key);

  @override
  _PasswordFieldState createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _passwordVisible = false;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      textInputAction: TextInputAction.go,
      obscureText: !_passwordVisible,
      autofocus: true,
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        hintText: widget.hint,
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              iconSize: 20,
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
              icon: Icon(Icons.close),
              iconSize: 20,
              constraints: BoxConstraints.tightFor(width: 20, height: 20),
              splashRadius: 15,
              padding: EdgeInsets.zero,
              onPressed: () {
                widget.controller?.clear();
              },
            ),
            SizedBox(width: 10),
          ],
        ),
      ),
      onSubmitted: widget.onSubmitted,
    );
  }
}