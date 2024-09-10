import 'package:flutter/material.dart';

class ShortAppBar extends StatelessWidget {
  final VoidCallback? onBackPressed;
  final Widget? title;

  ShortAppBar({Key? key, this.onBackPressed, this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: Material(
        color: Theme.of(context).colorScheme.primary,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(bottomRight: Radius.circular(20)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              tooltip: 'Back',
              onPressed: onBackPressed,
            ),
            if (title != null) Padding(padding: EdgeInsets.only(right: 16), child: title),
          ],
        ),
      ),
    );
  }
}
