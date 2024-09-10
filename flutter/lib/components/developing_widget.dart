import 'package:flutter/material.dart';

class DevelopingWidget extends StatelessWidget {
  final String title;

  const DevelopingWidget({Key? key, this.title = ''}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ModalRoute<dynamic>? parentRoute = ModalRoute.of(context);
    final bool canPop = parentRoute?.canPop ?? false;

    var body = Container(
      alignment: Alignment.center,
      color: Colors.white,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/developing.png',
            fit: BoxFit.contain,
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Text(
                '${title}',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w300, shadows: [
                  Shadow(color: Theme.of(context).colorScheme.primary, blurRadius: 20, offset: Offset(1, 1)),
                  Shadow(color: Colors.blue, blurRadius: 10, offset: Offset(1, 1)),
                ]),
              ),
            ),
          ),
        ],
      ),
    );

    if (!canPop) {
      return body;
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Developing'),
      ),
      body: body,
    );
  }
}
