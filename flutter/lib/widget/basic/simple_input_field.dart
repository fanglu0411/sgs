import 'package:flutter/material.dart';

class SimpleInputField extends StatefulWidget {
  final ValueChanged<String>? onSubmitted;

  const SimpleInputField({Key? key, this.onSubmitted}) : super(key: key);

  @override
  _SimpleInputFieldState createState() => _SimpleInputFieldState();
}

class _SimpleInputFieldState extends State<SimpleInputField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    Color color = Theme.of(context).brightness == Brightness.light ? Colors.black87 : Colors.white;

    return TextField(
      controller: _controller,
      maxLines: 1,
      cursorColor: color,
      cursorWidth: 2.0,
      style: TextStyle(color: color),
      onSubmitted: widget.onSubmitted,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
//                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
        focusColor: color,
//                  hintText: 'intput gene/range',
//                  prefixIcon: Icon(Icons.search, color: Colors.white),
//        suffixIcon: IconButton(
//          onPressed: () {
//            var text = _controller.value.text;
//            if (null != widget.onSubmitted && text.isNotEmpty) {
//              widget.onSubmitted(_controller.value.text);
//            }
//          },
//          icon: Icon(Icons.search),
//          color: color,
//        ),
        hintText: '500,0000',
//                  suffix: Icon(Icons.search, color: Colors.white),
//        labelText: 'intput gene/range to search',
        hintStyle: TextStyle(color: color.withOpacity(.8)),
        labelStyle: TextStyle(color: color.withOpacity(.8)),
        border: InputBorder.none,
        fillColor: Colors.white10,
      ),
    );
  }
}