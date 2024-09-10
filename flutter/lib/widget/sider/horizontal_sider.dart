// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui' show lerpDouble;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';


import 'package:flutter/src/material/bottom_sheet_theme.dart';
import 'package:flutter/src/material/colors.dart';
import 'package:flutter/src/material/curves.dart';
import 'package:flutter/src/material/debug.dart';
import 'package:flutter/src/material/material.dart';
import 'package:flutter/src/material/material_localizations.dart';
import 'package:flutter/src/material/scaffold.dart';
import 'package:flutter/src/material/theme.dart';

const Duration _HorizontalSheetEnterDuration = Duration(milliseconds: 250);
const Duration _HorizontalSheetExitDuration = Duration(milliseconds: 200);
const Curve _modalHorizontalSheetCurve = decelerateEasing;
const double _minFlingVelocity = 700.0;
const double _closeProgressThreshold = 0.5;

/// A callback for when the user begins dragging the Horizontal sheet.
///
/// Used by [HorizontalSheet.onDragStart].
typedef HorizontalSheetDragStartHandler = void Function(DragStartDetails details);

/// A callback for when the user stops dragging the Horizontal sheet.
///
/// Used by [HorizontalSheet.onDragEnd].
typedef HorizontalSheetDragEndHandler = void Function(
    DragEndDetails details, {
    required bool isClosing,
    });

/// A Material Design Horizontal sheet.
///
/// There are two kinds of Horizontal sheets in Material Design:
///
///  * _Persistent_. A persistent Horizontal sheet shows information that
///    supplements the primary content of the app. A persistent Horizontal sheet
///    remains visible even when the user interacts with other parts of the app.
///    Persistent Horizontal sheets can be created and displayed with the
///    [ScaffoldState.showHorizontalSheet] function or by specifying the
///    [Scaffold.HorizontalSheet] constructor parameter.
///
///  * _Modal_. A modal Horizontal sheet is an alternative to a menu or a dialog and
///    prevents the user from interacting with the rest of the app. Modal Horizontal
///    sheets can be created and displayed with the [showModalHorizontalSheet]
///    function.
///
/// The [HorizontalSheet] widget itself is rarely used directly. Instead, prefer to
/// create a persistent Horizontal sheet with [ScaffoldState.showHorizontalSheet] or
/// [Scaffold.HorizontalSheet], and a modal Horizontal sheet with [showModalHorizontalSheet].
///
/// See also:
///
///  * [showHorizontalSheet] and [ScaffoldState.showHorizontalSheet], for showing
///    non-modal "persistent" Horizontal sheets.
///  * [showModalHorizontalSheet], which can be used to display a modal Horizontal
///    sheet.
///  * [BottomSheetThemeData], which can be used to customize the default
///    Horizontal sheet property values.
///  * <https://material.io/design/components/sheets-Horizontal.html>
class HorizontalSheet extends StatefulWidget {
  /// Creates a Horizontal sheet.
  ///
  /// Typically, Horizontal sheets are created implicitly by
  /// [ScaffoldState.showHorizontalSheet], for persistent Horizontal sheets, or by
  /// [showModalHorizontalSheet], for modal Horizontal sheets.
  const HorizontalSheet({
    super.key,
    this.animationController,
    this.enableDrag = true,
    this.onDragStart,
    this.onDragEnd,
    this.backgroundColor,
    this.elevation,
    this.shape,
    this.clipBehavior,
    this.constraints,
    required this.onClosing,
    required this.builder,
  }) : assert(elevation == null || elevation >= 0.0);

  /// The animation controller that controls the Horizontal sheet's entrance and
  /// exit animations.
  ///
  /// The HorizontalSheet widget will manipulate the position of this animation, it
  /// is not just a passive observer.
  final AnimationController? animationController;

  /// Called when the Horizontal sheet begins to close.
  ///
  /// A Horizontal sheet might be prevented from closing (e.g., by user
  /// interaction) even after this callback is called. For this reason, this
  /// callback might be call multiple times for a given Horizontal sheet.
  final VoidCallback onClosing;

  /// A builder for the contents of the sheet.
  ///
  /// The Horizontal sheet will wrap the widget produced by this builder in a
  /// [Material] widget.
  final WidgetBuilder builder;

  /// If true, the Horizontal sheet can be dragged up and down and dismissed by
  /// swiping downwards.
  ///
  /// Default is true.
  final bool enableDrag;

  /// Called when the user begins dragging the Horizontal sheet vertically, if
  /// [enableDrag] is true.
  ///
  /// Would typically be used to change the Horizontal sheet animation curve so
  /// that it tracks the user's finger accurately.
  final HorizontalSheetDragStartHandler? onDragStart;

  /// Called when the user stops dragging the Horizontal sheet, if [enableDrag]
  /// is true.
  ///
  /// Would typically be used to reset the Horizontal sheet animation curve, so
  /// that it animates non-linearly. Called before [onClosing] if the Horizontal
  /// sheet is closing.
  final HorizontalSheetDragEndHandler? onDragEnd;

  /// The Horizontal sheet's background color.
  ///
  /// Defines the Horizontal sheet's [Material.color].
  ///
  /// Defaults to null and falls back to [Material]'s default.
  final Color? backgroundColor;

  /// The z-coordinate at which to place this material relative to its parent.
  ///
  /// This controls the size of the shadow below the material.
  ///
  /// Defaults to 0. The value is non-negative.
  final double? elevation;

  /// The shape of the Horizontal sheet.
  ///
  /// Defines the Horizontal sheet's [Material.shape].
  ///
  /// Defaults to null and falls back to [Material]'s default.
  final ShapeBorder? shape;

  /// {@macro flutter.material.Material.clipBehavior}
  ///
  /// Defines the Horizontal sheet's [Material.clipBehavior].
  ///
  /// Use this property to enable clipping of content when the Horizontal sheet has
  /// a custom [shape] and the content can extend past this shape. For example,
  /// a Horizontal sheet with rounded corners and an edge-to-edge [Image] at the
  /// top.
  ///
  /// If this property is null then [BottomSheetThemeData.clipBehavior] of
  /// [ThemeData.BottomSheetTheme] is used. If that's null then the behavior
  /// will be [Clip.none].
  final Clip? clipBehavior;

  /// Defines minimum and maximum sizes for a [HorizontalSheet].
  ///
  /// Typically a Horizontal sheet will cover the entire width of its
  /// parent. Consider limiting the width by setting smaller constraints
  /// for large screens.
  ///
  /// If null, then the ambient [ThemeData.BottomSheetTheme]'s
  /// [BottomSheetThemeData.constraints] will be used. If that
  /// is null then the Horizontal sheet's size will be constrained
  /// by its parent (usually a [Scaffold]).
  ///
  /// If constraints are specified (either in this property or in the
  /// theme), the Horizontal sheet will be aligned to the Horizontal-center of
  /// the available space. Otherwise, no alignment is applied.
  final BoxConstraints? constraints;

  @override
  State<HorizontalSheet> createState() => _HorizontalSheetState();

  /// Creates an [AnimationController] suitable for a
  /// [HorizontalSheet.animationController].
  ///
  /// This API available as a convenience for a Material compliant Horizontal sheet
  /// animation. If alternative animation durations are required, a different
  /// animation controller could be provided.
  static AnimationController createAnimationController(TickerProvider vsync) {
    return AnimationController(
      duration: _HorizontalSheetEnterDuration,
      reverseDuration: _HorizontalSheetExitDuration,
      debugLabel: 'HorizontalSheet',
      vsync: vsync,
    );
  }
}

class _HorizontalSheetState extends State<HorizontalSheet> {

  final GlobalKey _childKey = GlobalKey(debugLabel: 'HorizontalSheet child');

  double get _childHeight {
    final RenderBox renderBox = _childKey.currentContext!.findRenderObject()! as RenderBox;
    return renderBox.size.height;
  }

  bool get _dismissUnderway => widget.animationController!.status == AnimationStatus.reverse;

  void _handleDragStart(DragStartDetails details) {
    widget.onDragStart?.call(details);
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    assert(
    widget.enableDrag && widget.animationController != null,
    "'HorizontalSheet.animationController' can not be null when 'HorizontalSheet.enableDrag' is true. "
        "Use 'HorizontalSheet.createAnimationController' to create one, or provide another AnimationController.",
    );
    if (_dismissUnderway) {
      return;
    }
    widget.animationController!.value -= details.primaryDelta! / _childHeight;
  }

  void _handleDragEnd(DragEndDetails details) {
    assert(
    widget.enableDrag && widget.animationController != null,
    "'HorizontalSheet.animationController' can not be null when 'HorizontalSheet.enableDrag' is true. "
        "Use 'HorizontalSheet.createAnimationController' to create one, or provide another AnimationController.",
    );
    if (_dismissUnderway) {
      return;
    }
    bool isClosing = false;
    if (details.velocity.pixelsPerSecond.dy > _minFlingVelocity) {
      final double flingVelocity = -details.velocity.pixelsPerSecond.dy / _childHeight;
      if (widget.animationController!.value > 0.0) {
        widget.animationController!.fling(velocity: flingVelocity);
      }
      if (flingVelocity < 0.0) {
        isClosing = true;
      }
    } else if (widget.animationController!.value < _closeProgressThreshold) {
      if (widget.animationController!.value > 0.0) {
        widget.animationController!.fling(velocity: -1.0);
      }
      isClosing = true;
    } else {
      widget.animationController!.forward();
    }

    widget.onDragEnd?.call(
      details,
      isClosing: isClosing,
    );

    if (isClosing) {
      widget.onClosing();
    }
  }

  bool extentChanged(DraggableScrollableNotification notification) {
    if (notification.extent == notification.minExtent) {
      widget.onClosing();
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final BottomSheetThemeData BottomSheetTheme = Theme.of(context).bottomSheetTheme;
    final BottomSheetThemeData defaults = Theme.of(context).useMaterial3 ? _HorizontalSheetDefaultsM3(context) : const BottomSheetThemeData();
    final BoxConstraints? constraints = widget.constraints ?? BottomSheetTheme.constraints;
    final Color? color = widget.backgroundColor ?? BottomSheetTheme.backgroundColor ?? defaults.backgroundColor;
    final Color? surfaceTintColor = BottomSheetTheme.surfaceTintColor ?? defaults.surfaceTintColor;
    final double elevation = widget.elevation ?? BottomSheetTheme.elevation ?? defaults.elevation ?? 0;
    final ShapeBorder? shape = widget.shape ?? BottomSheetTheme.shape ?? defaults.shape;
    final Clip clipBehavior = widget.clipBehavior ?? BottomSheetTheme.clipBehavior ?? Clip.none;

    Widget HorizontalSheet = Material(
      key: _childKey,
      color: color,
      elevation: elevation,
      surfaceTintColor: surfaceTintColor,
      shape: shape,
      clipBehavior: clipBehavior,
      child: NotificationListener<DraggableScrollableNotification>(
        onNotification: extentChanged,
        child: widget.builder(context),
      ),
    );

    if (constraints != null) {
      HorizontalSheet = Align(
        alignment: Alignment.center,
        heightFactor: 1.0,
        child: ConstrainedBox(
          constraints: constraints,
          child: HorizontalSheet,
        ),
      );
    }

    return !widget.enableDrag ? HorizontalSheet : GestureDetector(
      onVerticalDragStart: _handleDragStart,
      onVerticalDragUpdate: _handleDragUpdate,
      onVerticalDragEnd: _handleDragEnd,
      excludeFromSemantics: true,
      child: HorizontalSheet,
    );
  }
}

// PERSISTENT Horizontal SHEETS

// See scaffold.dart


// MODAL Horizontal SHEETS
class _ModalHorizontalSheetLayout extends SingleChildLayoutDelegate {
  _ModalHorizontalSheetLayout(this.progress, this.isScrollControlled);

  final double progress;
  final bool isScrollControlled;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return BoxConstraints(
      minWidth: 0,
      // maxWidth: constraints.maxWidth,
      maxWidth: isScrollControlled ? constraints.maxWidth : constraints.maxWidth * .5,
      minHeight: 0,
      maxHeight: constraints.maxHeight,
      // maxHeight: isScrollControlled ? constraints.maxHeight : constraints.maxHeight * 9.0 / 16.0,
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    // return Offset(0.0, size.height - childSize.height * progress);
    // if (align == HorizontalSheetAlign.left) {
    //   return Offset(childSize.width - childSize.width * progress, 0);
    // }
    return Offset(size.width - childSize.width * progress, 0);
  }

  @override
  bool shouldRelayout(_ModalHorizontalSheetLayout oldDelegate) {
    return progress != oldDelegate.progress;
  }
}

class _ModalHorizontalSheet<T> extends StatefulWidget {
  const _ModalHorizontalSheet({
    super.key,
    required this.route,
    this.backgroundColor,
    this.elevation,
    this.shape,
    this.clipBehavior,
    this.constraints,
    this.isScrollControlled = false,
    this.enableDrag = true,
  });

  final ModalHorizontalSheetRoute<T> route;
  final bool isScrollControlled;
  final Color? backgroundColor;
  final double? elevation;
  final ShapeBorder? shape;
  final Clip? clipBehavior;
  final BoxConstraints? constraints;
  final bool enableDrag;

  @override
  _ModalHorizontalSheetState<T> createState() => _ModalHorizontalSheetState<T>();
}

class _ModalHorizontalSheetState<T> extends State<_ModalHorizontalSheet<T>> {
  ParametricCurve<double> animationCurve = _modalHorizontalSheetCurve;

  String _getRouteLabel(MaterialLocalizations localizations) {
    switch (Theme.of(context).platform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return '';
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return localizations.dialogLabel;
    }
  }

  void handleDragStart(DragStartDetails details) {
    // Allow the Horizontal sheet to track the user's finger accurately.
    animationCurve = Curves.linear;
  }

  void handleDragEnd(DragEndDetails details, {bool? isClosing}) {
    // Allow the Horizontal sheet to animate smoothly from its current position.
    animationCurve = _HorizontalSheetSuspendedCurve(
      widget.route.animation!.value,
      curve: _modalHorizontalSheetCurve,
    );
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMediaQuery(context));
    assert(debugCheckHasMaterialLocalizations(context));
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final MaterialLocalizations localizations = MaterialLocalizations.of(context);
    final String routeLabel = _getRouteLabel(localizations);

    return AnimatedBuilder(
      animation: widget.route.animation!,
      child: HorizontalSheet(
        animationController: widget.route._animationController,
        onClosing: () {
          if (widget.route.isCurrent) {
            Navigator.pop(context);
          }
        },
        builder: widget.route.builder,
        backgroundColor: widget.backgroundColor,
        elevation: widget.elevation,
        shape: widget.shape,
        clipBehavior: widget.clipBehavior,
        constraints: widget.constraints,
        enableDrag: widget.enableDrag,
        onDragStart: handleDragStart,
        onDragEnd: handleDragEnd,
      ),
      builder: (BuildContext context, Widget? child) {
        // Disable the initial animation when accessible navigation is on so
        // that the semantics are added to the tree at the correct time.
        final double animationValue = animationCurve.transform(
          mediaQuery.accessibleNavigation ? 1.0 : widget.route.animation!.value,
        );
        return Semantics(
          scopesRoute: true,
          namesRoute: true,
          label: routeLabel,
          explicitChildNodes: true,
          child: ClipRect(
            child: CustomSingleChildLayout(
              delegate: _ModalHorizontalSheetLayout(animationValue, widget.isScrollControlled),
              child: child,
            ),
          ),
        );
      },
    );
  }
}

/// A route that represents a Material Design modal Horizontal sheet.
///
/// {@template flutter.material.ModalHorizontalSheetRoute}
/// A modal Horizontal sheet is an alternative to a menu or a dialog and prevents
/// the user from interacting with the rest of the app.
///
/// A closely related widget is a persistent Horizontal sheet, which shows
/// information that supplements the primary content of the app without
/// preventing the user from interacting with the app. Persistent Horizontal sheets
/// can be created and displayed with the [showHorizontalSheet] function or the
/// [ScaffoldState.showHorizontalSheet] method.
///
/// The [isScrollControlled] parameter specifies whether this is a route for
/// a Horizontal sheet that will utilize [DraggableScrollableSheet]. Consider
/// setting this parameter to true if this Horizontal sheet has
/// a scrollable child, such as a [ListView] or a [GridView],
/// to have the Horizontal sheet be draggable.
///
/// The [isDismissible] parameter specifies whether the Horizontal sheet will be
/// dismissed when user taps on the scrim.
///
/// The [enableDrag] parameter specifies whether the Horizontal sheet can be
/// dragged up and down and dismissed by swiping downwards.
///
/// The [useSafeArea] parameter specifies whether a [SafeArea] is inserted. Defaults to false.
/// If false, no SafeArea is added and the top padding is consumed using [MediaQuery.removePadding].
///
/// The optional [backgroundColor], [elevation], [shape], [clipBehavior],
/// [constraints] and [transitionAnimationController]
/// parameters can be passed in to customize the appearance and behavior of
/// modal Horizontal sheets (see the documentation for these on [HorizontalSheet]
/// for more details).
///
/// The [transitionAnimationController] controls the Horizontal sheet's entrance and
/// exit animations. It's up to the owner of the controller to call
/// [AnimationController.dispose] when the controller is no longer needed.
///
/// The optional `settings` parameter sets the [RouteSettings] of the modal Horizontal sheet
/// sheet. This is particularly useful in the case that a user wants to observe
/// [PopupRoute]s within a [NavigatorObserver].
/// {@endtemplate}
///
/// {@macro flutter.widgets.RawDialogRoute}
///
/// See also:
///
///  * [showModalHorizontalSheet], which is a way to display a ModalHorizontalSheetRoute.
///  * [HorizontalSheet], which becomes the parent of the widget returned by the
///    function passed as the `builder` argument to [showModalHorizontalSheet].
///  * [showHorizontalSheet] and [ScaffoldState.showHorizontalSheet], for showing
///    non-modal Horizontal sheets.
///  * [DraggableScrollableSheet], creates a Horizontal sheet that grows
///    and then becomes scrollable once it reaches its maximum size.
///  * [DisplayFeatureSubScreen], which documents the specifics of how
///    [DisplayFeature]s can split the screen into sub-screens.
///  * <https://material.io/design/components/sheets-Horizontal.html#modal-Horizontal-sheet>
class ModalHorizontalSheetRoute<T> extends PopupRoute<T> {
  /// A modal Horizontal sheet route.
  ModalHorizontalSheetRoute({
    required this.builder,
    this.capturedThemes,
    this.barrierLabel,
    this.backgroundColor,
    this.elevation,
    this.shape,
    this.clipBehavior,
    this.constraints,
    this.modalBarrierColor,
    this.isDismissible = true,
    this.enableDrag = true,
    required this.isScrollControlled,
    super.settings,
    this.transitionAnimationController,
    this.anchorPoint,
    this.useSafeArea = false,
  });

  /// A builder for the contents of the sheet.
  ///
  /// The Horizontal sheet will wrap the widget produced by this builder in a
  /// [Material] widget.
  final WidgetBuilder builder;

  /// Stores a list of captured [InheritedTheme]s that are wrapped around the
  /// Horizontal sheet.
  ///
  /// Consider setting this attribute when the [ModalHorizontalSheetRoute]
  /// is created through [Navigator.push] and its friends.
  final CapturedThemes? capturedThemes;

  /// Specifies whether this is a route for a Horizontal sheet that will utilize
  /// [DraggableScrollableSheet].
  ///
  /// Consider setting this parameter to true if this Horizontal sheet has
  /// a scrollable child, such as a [ListView] or a [GridView],
  /// to have the Horizontal sheet be draggable.
  final bool isScrollControlled;

  /// The Horizontal sheet's background color.
  ///
  /// Defines the Horizontal sheet's [Material.color].
  ///
  /// If this property is not provided, it falls back to [Material]'s default.
  final Color? backgroundColor;

  /// The z-coordinate at which to place this material relative to its parent.
  ///
  /// This controls the size of the shadow below the material.
  ///
  /// Defaults to 0, must not be negative.
  final double? elevation;

  /// The shape of the Horizontal sheet.
  ///
  /// Defines the Horizontal sheet's [Material.shape].
  ///
  /// If this property is not provided, it falls back to [Material]'s default.
  final ShapeBorder? shape;

  /// {@macro flutter.material.Material.clipBehavior}
  ///
  /// Defines the Horizontal sheet's [Material.clipBehavior].
  ///
  /// Use this property to enable clipping of content when the Horizontal sheet has
  /// a custom [shape] and the content can extend past this shape. For example,
  /// a Horizontal sheet with rounded corners and an edge-to-edge [Image] at the
  /// top.
  ///
  /// If this property is null, the [BottomSheetThemeData.clipBehavior] of
  /// [ThemeData.BottomSheetTheme] is used. If that's null, the behavior defaults to [Clip.none]
  /// will be [Clip.none].
  final Clip? clipBehavior;

  /// Defines minimum and maximum sizes for a [HorizontalSheet].
  ///
  /// Typically a Horizontal sheet will cover the entire width of its
  /// parent. Consider limiting the width by setting smaller constraints
  /// for large screens.
  ///
  /// If null, the ambient [ThemeData.BottomSheetTheme]'s
  /// [BottomSheetThemeData.constraints] will be used. If that
  /// is null, the Horizontal sheet's size will be constrained
  /// by its parent (usually a [Scaffold]).
  ///
  /// If constraints are specified (either in this property or in the
  /// theme), the Horizontal sheet will be aligned to the Horizontal-center of
  /// the available space. Otherwise, no alignment is applied.
  final BoxConstraints? constraints;

  /// Specifies the color of the modal barrier that darkens everything below the
  /// Horizontal sheet.
  ///
  /// Defaults to `Colors.black54` if not provided.
  final Color? modalBarrierColor;

  /// Specifies whether the Horizontal sheet will be dismissed
  /// when user taps on the scrim.
  ///
  /// If true, the Horizontal sheet will be dismissed when user taps on the scrim.
  ///
  /// Defaults to true.
  final bool isDismissible;

  /// Specifies whether the Horizontal sheet can be dragged up and down
  /// and dismissed by swiping downwards.
  ///
  /// If true, the Horizontal sheet can be dragged up and down and dismissed by
  /// swiping downwards.
  ///
  /// Defaults is true.
  final bool enableDrag;

  /// The animation controller that controls the Horizontal sheet's entrance and
  /// exit animations.
  ///
  /// The HorizontalSheet widget will manipulate the position of this animation, it
  /// is not just a passive observer.
  final AnimationController? transitionAnimationController;

  /// {@macro flutter.widgets.DisplayFeatureSubScreen.anchorPoint}
  final Offset? anchorPoint;

  /// If useSafeArea is true, a [SafeArea] is inserted.
  ///
  /// If useSafeArea is false, the Horizontal sheet is aligned to the Horizontal of the page
  /// and isn't exposed to the top padding of the MediaQuery.
  ///
  /// Default is false.
  final bool useSafeArea;

  @override
  Duration get transitionDuration => _HorizontalSheetEnterDuration;

  @override
  Duration get reverseTransitionDuration => _HorizontalSheetExitDuration;

  @override
  bool get barrierDismissible => isDismissible;

  @override
  final String? barrierLabel;

  @override
  Color get barrierColor => modalBarrierColor ?? Colors.black54;

  AnimationController? _animationController;

  @override
  AnimationController createAnimationController() {
    assert(_animationController == null);
    if (transitionAnimationController != null) {
      _animationController = transitionAnimationController;
      willDisposeAnimationController = false;
    } else {
      _animationController = HorizontalSheet.createAnimationController(navigator!);
    }
    return _animationController!;
  }

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    final Widget content = DisplayFeatureSubScreen(
      anchorPoint: anchorPoint,
      child: Builder(
        builder: (BuildContext context) {
          final BottomSheetThemeData sheetTheme = Theme.of(context).bottomSheetTheme;
          final BottomSheetThemeData defaults = Theme.of(context).useMaterial3 ? _HorizontalSheetDefaultsM3(context) : const BottomSheetThemeData();
          return _ModalHorizontalSheet<T>(
            route: this,
            backgroundColor: backgroundColor ?? sheetTheme.modalBackgroundColor ?? sheetTheme.backgroundColor ?? defaults.backgroundColor,
            elevation: elevation ?? sheetTheme.modalElevation ?? defaults.modalElevation ?? sheetTheme.elevation,
            shape: shape,
            clipBehavior: clipBehavior,
            constraints: constraints,
            isScrollControlled: isScrollControlled,
            enableDrag: enableDrag,
          );
        },
      ),
    );

    // If useSafeArea is true, a SafeArea is inserted.
    // If useSafeArea is false, the Horizontal sheet is aligned to the Horizontal of the page
    // and isn't exposed to the top padding of the MediaQuery.
    final Widget HorizontalSheet = useSafeArea
        ? SafeArea(child: content)
        : MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: content,
    );

    return capturedThemes?.wrap(HorizontalSheet) ?? HorizontalSheet;
  }
}

// TODO(guidezpl): Look into making this public. A copy of this class is in
//  scaffold.dart, for now, https://github.com/flutter/flutter/issues/51627
/// A curve that progresses linearly until a specified [startingPoint], at which
/// point [curve] will begin. Unlike [Interval], [curve] will not start at zero,
/// but will use [startingPoint] as the Y position.
///
/// For example, if [startingPoint] is set to `0.5`, and [curve] is set to
/// [Curves.easeOut], then the Horizontal-left quarter of the curve will be a
/// straight line, and the top-right quarter will contain the entire contents of
/// [Curves.easeOut].
///
/// This is useful in situations where a widget must track the user's finger
/// (which requires a linear animation), and afterwards can be flung using a
/// curve specified with the [curve] argument, after the finger is released. In
/// such a case, the value of [startingPoint] would be the progress of the
/// animation at the time when the finger was released.
///
/// The [startingPoint] and [curve] arguments must not be null.
class _HorizontalSheetSuspendedCurve extends ParametricCurve<double> {
  /// Creates a suspended curve.
  const _HorizontalSheetSuspendedCurve(
      this.startingPoint, {
        this.curve = Curves.easeOutCubic,
      });

  /// The progress value at which [curve] should begin.
  ///
  /// This defaults to [Curves.easeOutCubic].
  final double startingPoint;

  /// The curve to use when [startingPoint] is reached.
  final Curve curve;

  @override
  double transform(double t) {
    assert(t >= 0.0 && t <= 1.0);
    assert(startingPoint >= 0.0 && startingPoint <= 1.0);

    if (t < startingPoint) {
      return t;
    }

    if (t == 1.0) {
      return t;
    }

    final double curveProgress = (t - startingPoint) / (1 - startingPoint);
    final double transformed = curve.transform(curveProgress);
    return lerpDouble(startingPoint, 1, transformed)!;
  }

  @override
  String toString() {
    return '${describeIdentity(this)}($startingPoint, $curve)';
  }
}

/// Shows a modal Material Design Horizontal sheet.
///
/// {@macro flutter.material.ModalHorizontalSheetRoute}
///
/// {@macro flutter.widgets.RawDialogRoute}
///
/// The `context` argument is used to look up the [Navigator] and [Theme] for
/// the Horizontal sheet. It is only used when the method is called. Its
/// corresponding widget can be safely removed from the tree before the Horizontal
/// sheet is closed.
///
/// The `useRootNavigator` parameter ensures that the root navigator is used to
/// display the [HorizontalSheet] when set to `true`. This is useful in the case
/// that a modal [HorizontalSheet] needs to be displayed above all other content
/// but the caller is inside another [Navigator].
///
/// Returns a `Future` that resolves to the value (if any) that was passed to
/// [Navigator.pop] when the modal Horizontal sheet was closed.
///
/// {@tool dartpad}
/// This example demonstrates how to use [showModalHorizontalSheet] to display a
/// Horizontal sheet that obscures the content behind it when a user taps a button.
/// It also demonstrates how to close the Horizontal sheet using the [Navigator]
/// when a user taps on a button inside the Horizontal sheet.
///
/// ** See code in examples/api/lib/material/Horizontal_sheet/show_modal_Horizontal_sheet.0.dart **
/// {@end-tool}
///
/// {@tool dartpad}
/// This sample shows the creation of [showModalHorizontalSheet], as described in:
/// https://m3.material.io/components/Horizontal-sheets/overview
///
/// ** See code in examples/api/lib/material/Horizontal_sheet/show_modal_Horizontal_sheet.1.dart **
/// {@end-tool}
///
/// See also:
///
///  * [HorizontalSheet], which becomes the parent of the widget returned by the
///    function passed as the `builder` argument to [showModalHorizontalSheet].
///  * [showHorizontalSheet] and [ScaffoldState.showHorizontalSheet], for showing
///    non-modal Horizontal sheets.
///  * [DraggableScrollableSheet], creates a Horizontal sheet that grows
///    and then becomes scrollable once it reaches its maximum size.
///  * [DisplayFeatureSubScreen], which documents the specifics of how
///    [DisplayFeature]s can split the screen into sub-screens.
///  * <https://material.io/design/components/sheets-Horizontal.html#modal-Horizontal-sheet>
Future<T?> showModalHorizontalSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  Color? backgroundColor,
  double? elevation,
  ShapeBorder? shape,
  Clip? clipBehavior,
  BoxConstraints? constraints,
  Color? barrierColor,
  bool isScrollControlled = false,
  bool useRootNavigator = false,
  bool isDismissible = true,
  bool enableDrag = true,
  bool useSafeArea = false,
  RouteSettings? routeSettings,
  AnimationController? transitionAnimationController,
  Offset? anchorPoint,
}) {
  assert(debugCheckHasMediaQuery(context));
  assert(debugCheckHasMaterialLocalizations(context));

  final NavigatorState navigator = Navigator.of(context, rootNavigator: useRootNavigator);
  return navigator.push(ModalHorizontalSheetRoute<T>(
    builder: builder,
    capturedThemes: InheritedTheme.capture(from: context, to: navigator.context),
    isScrollControlled: isScrollControlled,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    backgroundColor: backgroundColor,
    elevation: elevation,
    shape: shape,
    clipBehavior: clipBehavior,
    constraints: constraints,
    isDismissible: isDismissible,
    modalBarrierColor: barrierColor ?? Theme.of(context).bottomSheetTheme.modalBarrierColor,
    enableDrag: enableDrag,
    settings: routeSettings,
    transitionAnimationController: transitionAnimationController,
    anchorPoint: anchorPoint,
    useSafeArea: useSafeArea,
  ));
}

/// Shows a Material Design Horizontal sheet in the nearest [Scaffold] ancestor. To
/// show a persistent Horizontal sheet, use the [Scaffold.HorizontalSheet].
///
/// Returns a controller that can be used to close and otherwise manipulate the
/// Horizontal sheet.
///
/// The optional [backgroundColor], [elevation], [shape], [clipBehavior],
/// [constraints] and [transitionAnimationController]
/// parameters can be passed in to customize the appearance and behavior of
/// persistent Horizontal sheets (see the documentation for these on [HorizontalSheet]
/// for more details).
///
/// The [enableDrag] parameter specifies whether the Horizontal sheet can be
/// dragged up and down and dismissed by swiping downwards.
///
/// To rebuild the Horizontal sheet (e.g. if it is stateful), call
/// [PersistentHorizontalSheetController.setState] on the controller returned by
/// this method.
///
/// The new Horizontal sheet becomes a [LocalHistoryEntry] for the enclosing
/// [ModalRoute] and a back button is added to the app bar of the [Scaffold]
/// that closes the Horizontal sheet.
///
/// To create a persistent Horizontal sheet that is not a [LocalHistoryEntry] and
/// does not add a back button to the enclosing Scaffold's app bar, use the
/// [Scaffold.HorizontalSheet] constructor parameter.
///
/// A closely related widget is a modal Horizontal sheet, which is an alternative
/// to a menu or a dialog and prevents the user from interacting with the rest
/// of the app. Modal Horizontal sheets can be created and displayed with the
/// [showModalHorizontalSheet] function.
///
/// The `context` argument is used to look up the [Scaffold] for the Horizontal
/// sheet. It is only used when the method is called. Its corresponding widget
/// can be safely removed from the tree before the Horizontal sheet is closed.
///
/// See also:
///
///  * [HorizontalSheet], which becomes the parent of the widget returned by the
///    `builder`.
///  * [showModalHorizontalSheet], which can be used to display a modal Horizontal
///    sheet.
///  * [Scaffold.of], for information about how to obtain the [BuildContext].
///  * <https://material.io/design/components/sheets-Horizontal.html#standard-Horizontal-sheet>
PersistentBottomSheetController showHorizontalSheet({
  required BuildContext context,
  required WidgetBuilder builder,
  Color? backgroundColor,
  double? elevation,
  ShapeBorder? shape,
  Clip? clipBehavior,
  BoxConstraints? constraints,
  bool? enableDrag,
  AnimationController? transitionAnimationController,
}) {
  assert(debugCheckHasScaffold(context));

  return Scaffold.of(context).showBottomSheet(
    builder,
    backgroundColor: backgroundColor,
    elevation: elevation,
    shape: shape,
    clipBehavior: clipBehavior,
    constraints: constraints,
    enableDrag: enableDrag,
    transitionAnimationController: transitionAnimationController,
  );
}



// BEGIN GENERATED TOKEN PROPERTIES - HorizontalSheet

// Do not edit by hand. The code between the "BEGIN GENERATED" and
// "END GENERATED" comments are generated from data in the Material
// Design token database by the script:
//   dev/tools/gen_defaults/bin/gen_defaults.dart.

// Token database version: v0_143

class _HorizontalSheetDefaultsM3 extends BottomSheetThemeData {
  const _HorizontalSheetDefaultsM3(this.context)
      : super(
    elevation: 1.0,
    modalElevation: 1.0,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28.0))),
  );

  final BuildContext context;

  @override
  Color? get backgroundColor => Theme.of(context).colorScheme.surface;

  @override
  Color? get surfaceTintColor => Theme.of(context).colorScheme.surfaceTint;
}

// END GENERATED TOKEN PROPERTIES - HorizontalSheet