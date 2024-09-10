import 'package:flutter/material.dart';

class RestartWidget extends StatefulWidget {
  RestartWidget({required this.child});

  final Widget child;

  static void restartApp(BuildContext context) {
    context.findAncestorStateOfType<_RestartWidgetState>()?.restartApp();
  }

  @override
  _RestartWidgetState createState() => _RestartWidgetState();
}

class _RestartWidgetState extends State<RestartWidget> {
  Key key = UniqueKey();

  void restartApp() {
    setState(() {
      key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: key,
      child: widget.child,
    );
  }
}

// class RestartWidget extends StatefulWidget {
//   final Widget child;
//
//   const RestartWidget({
//     Key? key,
//     this.child,
//   }) : super(key: key);
//
//   @override
//   _RestartWidgetState createState() => _RestartWidgetState();
//
//   static _RestartWidgetState of(BuildContext context) {
//     assert(context != null);
//
//     return (context.getElementForInheritedWidgetOfExactType<_RestartInheritedWidget>().widget as _RestartInheritedWidget).state;
//   }
// }
//
// class _RestartWidgetState extends State<RestartWidget> {
//   Key _key = UniqueKey();
//
//   /// Change the key to a new one which will make the widget tree
//   /// re render.
//   void restartApp() async {
//     setState(() {
//       _key = UniqueKey();
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return _RestartInheritedWidget(
//       key: _key,
//       state: this,
//       child: widget.child,
//     );
//   }
// }
//
// class _RestartInheritedWidget extends InheritedWidget {
//   final _RestartWidgetState state;
//
//   _RestartInheritedWidget({
//     Key? key,
//     this.state,
//     Widget child,
//   }) : super(key: key, child: child);
//
//   @override
//   bool updateShouldNotify(InheritedWidget oldWidget) {
//     return false;
//   }
// }