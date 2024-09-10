//import 'dart:html' as html;
//import 'dart:ui' as ui;
//import 'package:flutter/material.dart';
//
//class TextArea extends StatefulWidget {
//  @override
//  _TextAreaState createState() => _TextAreaState();
//}
//
//class _TextAreaState extends State<TextArea> {
//  html.TextAreaElement _textArea;
//
//  @override
//  void initState() {
//    super.initState();
//    ui.platformViewRegistry.registerViewFactory('custom-iframe', _getHtmlElement);
//  }
//
//  html.Element _getHtmlElement(int viewId) {
////    var styleElement = html.StyleElement()..type = 'text/css';
////    html.CssStyleSheet styleSheet = styleElement.sheet;
//
//    _textArea = html.TextAreaElement()
//      ..rows = 20
//      ..style.cssText = 'width: 100%;height:100%;'
//      ..onChange.listen((event) {
//        print(event);
//        print(_textArea.value);
//      })
//      ..className = 'custom-text-area';
//
//    return html.DivElement()
//      ..style.cssText = 'padding: 10px 10px;'
//      ..append(_textArea);
//  }
//
//  void _onValueChange() {}
//
//  @override
//  Widget build(BuildContext context) {
//    return Container(
//      child: HtmlElementView(viewType: 'custom-iframe'),
//    );
//  }
//}
