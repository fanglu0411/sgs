import 'package:flutter/material.dart';

class ScrollTopButton extends StatefulWidget {
  final double opacity;

  final VoidCallback? onPressed;

  const ScrollTopButton({Key? key, required this.opacity, this.onPressed}) : super(key: key);

  @override
  ScrollTopButtonState createState() => ScrollTopButtonState();
}

class ScrollTopButtonState extends State<ScrollTopButton> {
  late double _opacity;

  @override
  void initState() {
    super.initState();
    _opacity = widget.opacity;
  }

  setOpacity(double opacity) {
    _opacity = opacity;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_opacity == 0) {
      return SizedBox();
    }
    return AnimatedOpacity(
      opacity: _opacity,
      duration: Duration(milliseconds: 300),
      child: Tooltip(
        message: 'Scroll to Top',
        child: MaterialButton(
          child: Icon(Icons.keyboard_arrow_up),
          minWidth: 30,
          shape: CircleBorder(),
          textColor: Colors.white,
          color: Theme.of(context).colorScheme.primary,
          onPressed: widget.onPressed,
        ),
      ),
    );
  }
}
