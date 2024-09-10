import 'package:flutter/material.dart';

class FragmentWidget extends StatefulWidget {
  final Widget child;

  const FragmentWidget({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  FragmentWidgetState createState() => FragmentWidgetState();
}

abstract class FragmentState<T extends StatefulWidget> extends State<T> {}

class FragmentWidgetState extends State<FragmentWidget> with SingleTickerProviderStateMixin {
  AnimationController? _widgetWitchController;

  List<Widget> children = [];

  Animation<double>? _pushAnimation;
  Animation<double>? _popAnimation;

  Animation<Offset>? _slideAnimation;
  bool _push = true;

  @override
  void initState() {
    super.initState();

    children.add(widget.child);
  
    _widgetWitchController = AnimationController(vsync: this, duration: Duration(milliseconds: 180));
    _pushAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_widgetWitchController!);
    _slideAnimation = Tween<Offset>(begin: Offset(100, 100), end: Offset(1500, 1200)).animate(_widgetWitchController!);
    // _popAnimation = Tween<double>(begin: 1.0, end: 0).animate(_widgetWitchController);
    _widgetWitchController!.forward();
  }

  Future push<T extends Object>(WidgetBuilder builder) async {
    Widget _child = builder(context);
    _widgetWitchController!.reset();
    _widgetWitchController!.forward();
    _push = true;
    children.add(_child);
    setState(() {});
  }

  Future pop<T extends Object>() async {
    _push = false;
    children.removeLast();
    setState(() {});
    // _widgetWitchController.reverse();
  }

  @override
  Widget build(BuildContext context) {
//    if (children.length == 0) return Container();
    Widget topChild = children.length == 0 ? Container() : children.last;
    //
    // return AnimatedContainer(
    //   duration: Duration(milliseconds: 400),
    //   constraints: BoxConstraints.expand(),
    //   alignment: Alignment(_pushAnimation.value, -1),
    //   child: child,
    // );

    // topChild = Container(
    //   constraints: BoxConstraints.expand(),
    //   child: topChild,
    // );

    if (!_push) {
      return topChild;
    }

    return EntrancePageTransition(
      animation: _pushAnimation!,
      child: topChild,
      startFrom: .15,
    );

    return Stack(
      children: [
        // ...children.sublist(0, children.length - 1),
        // AnimatedBuilder(
        //   animation: _pushAnimation,
        //   builder: (c, w) {
        //     print('---> ${_pushAnimation.value}');
        //     return Opacity(
        //       opacity: _pushAnimation.value,
        //       child: topChild,
        //     );
        //   },
        // ),
      ],
      // fit: StackFit.expand,
    );
  }
}

class EntrancePageTransition extends StatelessWidget {
  /// Creates an entrance page transition
  const EntrancePageTransition({
    Key? key,
    required this.child,
    required this.animation,
    this.vertical = true,
    this.reverse = false,
    this.startFrom = 0.25,
  }) : super(key: key);

  /// The widget to be animated
  final Widget child;

  /// The animation to drive this transition
  final Animation<double> animation;

  /// Whether the animation should be done vertically or horizontally
  final bool vertical;

  /// Whether the animation should be done from the left or from the right
  final bool reverse;

  /// From where the animation will begin. By default, 0.25 is used.
  ///
  /// If [reverse] is true, `-startFrom` (negative) is used
  final double startFrom;

  @override
  Widget build(BuildContext context) {
    final value = animation.value + (reverse ? -startFrom : startFrom);
    return SlideTransition(
      child: FadeTransition(
        child: child,
        opacity: animation,
      ),
      position: Tween<Offset>(
        begin: vertical ? Offset(0, value) : Offset(value, 0),
        end: Offset.zero,
      ).animate(animation),
    );
  }
}