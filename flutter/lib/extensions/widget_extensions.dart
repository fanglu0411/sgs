import 'package:flutter_smart_genome/widget/basic/custom_spin.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

extension WidgetExtensions on Widget {
  Widget centerTablet({double maxWidth = 1200}) {
    return this;
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: ClipRRect(
          child: this,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget withPadding(EdgeInsets padding) {
    return Padding(
      child: this,
      padding: padding,
    );
  }

  Widget withHeight(double height) {
    return SizedBox(
      height: height,
      child: this,
    );
  }

  Widget withBottomBorder({Color color = Colors.grey, double width = 1.0, Color? background}) {
    return Container(
      decoration: BoxDecoration(
        color: background,
        border: Border(bottom: BorderSide(color: color, width: width)),
      ),
      child: this,
    );
  }

  Widget withTopBorder({Color color = Colors.grey, double width = 1.0, Color? background}) {
    return Container(
      decoration: BoxDecoration(
        color: background,
        border: Border(top: BorderSide(color: color, width: width)),
      ),
      child: this,
    );
  }

  Widget withVerticalBorder({Color color = Colors.grey, double width = 1.0, Color? background}) {
    return Container(
      decoration: BoxDecoration(
        color: background,
        border: Border(top: BorderSide(color: color, width: width), bottom: BorderSide(color: color, width: width)),
      ),
      child: this,
    );
  }

  Widget withBorder(Border border, {Color? background}) {
    return Container(
      child: this,
      decoration: BoxDecoration(
        color: background,
        border: border,
      ),
    );
  }

  Widget tooltip(String? message) {
    if (null == message) return this;
    return Tooltip(message: message, child: this);
  }

  Widget overlay() {
    return Overlay(
      initialEntries: [OverlayEntry(builder: (_) => this)],
    );
  }

  Expanded expand([int flex = 1]) {
    return Expanded(child: this, flex: flex);
  }
}

class LeftWelcomeWidget extends StatefulWidget {
  @override
  _LeftWelcomeWidgetState createState() => _LeftWelcomeWidgetState();
}

class _LeftWelcomeWidgetState extends State<LeftWelcomeWidget> {
  @override
  Widget build(BuildContext context) {
    bool _dark = Theme.of(context).brightness == Brightness.dark;
    Color _tabViewColor = _dark ? Colors.grey[700]! : Colors.grey[700]!;
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Spacer(),
          Padding(
            padding: EdgeInsets.only(bottom: 50),
            child: ShaderTitle(),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            clipBehavior: Clip.antiAlias,
            child: AspectRatio(
              aspectRatio: 1.6,
              child: PageView(
                children: [
                  _buildPage('https://w.wallhaven.cc/full/lm/wallhaven-lmorgr.png', _tabViewColor),
                  _buildPage('https://w.wallhaven.cc/full/ne/wallhaven-ne2oxk.jpg', _tabViewColor),
                  _buildPage('https://w.wallhaven.cc/full/4l/wallhaven-4lqw1r.jpg', _tabViewColor),
                ],
              ),
            ),
          ),
          Spacer(),
          Padding(
            padding: EdgeInsets.only(bottom: 20),
            child: Text(
              'Copyright @2020-2030 SouthWest University. All rights reserved.\n\nDeveloped by Wang. Contact: xxxxx@mail.com',
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w200,
                    color: Colors.white54,
                  ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPage(String url, Color color) {
    return Container(
      color: color,
//      child: Image.network(
//        url,
//        fit: BoxFit.cover,
//        loadingBuilder: _imageLoadingBuilder,
//      ),
    );
  }

  Widget _imageLoadingBuilder(
    BuildContext context,
    Widget child,
    ImageChunkEvent loadingProgress,
  ) {
    return Center(
      child: CustomSpin(color: Theme.of(context).colorScheme.primary),
    );
  }
}

class ShaderTitle extends StatefulWidget {
  @override
  _ShaderTitleState createState() => _ShaderTitleState();
}

class _ShaderTitleState extends State<ShaderTitle> with SingleTickerProviderStateMixin {
  AnimationController? _animationController;
  Animation? _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 2000),
      reverseDuration: Duration(milliseconds: 2500),
    );
    _animation = Tween(begin: 0.0, end: 1.0).animate(_animationController!);

    _animation!
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _animationController!.reverse();
        } else if (status == AnimationStatus.dismissed) {
          _animationController!.forward();
        }
      })
      ..addListener(() {
        if (mounted) setState(() {});
      });

//    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    double stop1 = (_animation!.value + .5).clamp(0.0, 1.0);
    double stop2 = (stop1 + .5).clamp(0.0, 1.0);
    var text = Text('Welcome to\nSmart Genome Db', style: Theme.of(context).textTheme.displaySmall!.copyWith(color: Colors.white70));
    if (kIsWeb) {
      return text;
    }
    return ShaderMask(
      child: text,
      shaderCallback: (Rect bounds) {
        return RadialGradient(
          center: Alignment.center,
          radius: 1.0,
          colors: [Colors.white, Colors.grey],
          tileMode: TileMode.mirror,
          stops: [_animation!.value, stop1],
        ).createShader(bounds);
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    _animationController?.stop();
    _animationController?.dispose();
  }
}

class AnimatedBackground extends StatefulWidget {
  @override
  _AnimatedBackgroundState createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground> with SingleTickerProviderStateMixin {
  Animation? _animation;
  AnimationController? _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 800));
  }

  @override
  Widget build(BuildContext context) {
    AnimatedContainer(
      duration: Duration(milliseconds: 800),
    );
    return Container(
      constraints: BoxConstraints.expand(),
      color: Colors.grey[800],
//      child: Image.network(
//        'https://w.wallhaven.cc/full/nr/wallhaven-nr7wjw.jpg',
//        fit: BoxFit.cover,
//        loadingBuilder: (_, child, event) {
//          return Container(
//            color: Colors.grey[800],
//          );
//        },
//      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _animationController?.dispose();
  }
}
