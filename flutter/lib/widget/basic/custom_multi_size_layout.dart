import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/util/device_info.dart';
import 'package:responsive_builder/responsive_builder.dart' as rb;

const defaultBreakPoints = rb.ScreenBreakpoints(watch: 300, tablet: 900, desktop: 1680);

class CustomMultiSizeLayout extends StatelessWidget {
  final rb.ScreenBreakpoints breakpoints;

  final rb.WidgetBuilder? watch;
  final rb.WidgetBuilder? mobile;
  final rb.WidgetBuilder? tablet;
  final rb.WidgetBuilder? desktop;

  CustomMultiSizeLayout({Key? key, this.breakpoints = defaultBreakPoints, Widget? watch, Widget? mobile, Widget? tablet, Widget? desktop})
      : this.watch = _builderOrNull(watch),
        this.mobile = _builderOrNull(mobile),
        this.tablet = _builderOrNull(tablet),
        this.desktop = _builderOrNull(desktop),
        super(key: key);

  const CustomMultiSizeLayout.builder({
    Key? key,
    this.breakpoints = defaultBreakPoints,
    this.watch,
    required this.mobile,
    this.tablet,
    this.desktop,
  }) : super(key: key);

  static WidgetBuilder? _builderOrNull(Widget? widget) {
    return widget == null ? null : ((_) => widget);
  }

  @override
  Widget build(BuildContext context) {
    return CustomResponsiveBuilder(
      breakpoints: breakpoints,
      builder: (context, sizingInformation) {
        rb.DeviceScreenType deviceScreenType = sizingInformation.deviceScreenType;
        // If we're at desktop size
        if (deviceScreenType == rb.DeviceScreenType.desktop) {
          // If we have supplied the desktop layout then display that
          if (desktop != null) return desktop!(context);
          // If no desktop layout is supplied we want to check if we have the size below it and display that
          if (tablet != null) return tablet!(context);
        }

        if (deviceScreenType == rb.DeviceScreenType.tablet) {
          if (tablet != null) return tablet!(context);
        }

        if (deviceScreenType == rb.DeviceScreenType.watch && watch != null) {
          return watch!(context);
        }

        // If none of the layouts above are supplied or we're on the mobile layout then we show the mobile layout
        return mobile!(context);
      },
    );
  }
}

class CustomResponsiveBuilder extends StatelessWidget {
  final Widget Function(
    BuildContext context,
    rb.SizingInformation sizingInformation,
  ) builder;

  final rb.ScreenBreakpoints breakpoints;

  const CustomResponsiveBuilder({Key? key, required this.builder, required this.breakpoints}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, boxConstraints) {
      var mediaQuery = MediaQuery.of(context);
      var sizingInformation = rb.SizingInformation(
        deviceScreenType: getDeviceType(mediaQuery, breakpoint: breakpoints),
        refinedSize: rb.getRefinedSize(mediaQuery.size, isWebOrDesktop: !(DeviceOS.isMobile)),
        screenSize: mediaQuery.size,
        localWidgetSize: Size(boxConstraints.maxWidth, boxConstraints.maxHeight),
      );
      return builder(context, sizingInformation);
    });
  }
}

rb.DeviceScreenType getDeviceType(
  MediaQueryData mediaQuery, {
  rb.ScreenBreakpoints breakpoint = defaultBreakPoints,
}) {
  double deviceWidth = mediaQuery.size.shortestSide;

  if (DeviceOS.isDesktopOrWeb) {
    deviceWidth = mediaQuery.size.width;
  }

  if (deviceWidth >= breakpoint.desktop) {
    return rb.DeviceScreenType.desktop;
  }

  if (deviceWidth >= breakpoint.tablet) {
    return rb.DeviceScreenType.tablet;
  }

  if (deviceWidth < breakpoint.watch) {
    return rb.DeviceScreenType.watch;
  }

  return rb.DeviceScreenType.mobile;
}
