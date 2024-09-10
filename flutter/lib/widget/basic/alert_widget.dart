import 'package:flutter/material.dart';

enum AlertType {
  primary,
  warning,
  info,
  error,
}

class AlertWidget extends StatelessWidget {
  final Widget message;
  final Widget? icon;
  final AlertType type;
  final BoxConstraints? constraints;
  final EdgeInsetsGeometry? margin;

  const AlertWidget({
    super.key,
    this.icon,
    required this.message,
    this.type = AlertType.info,
    this.constraints,
    this.margin,
  });

  const AlertWidget.warning({
    super.key,
    this.icon = const Icon(Icons.warning_rounded, size: 20),
    required this.message,
    this.type = AlertType.warning,
    this.constraints,
    this.margin,
  });

  const AlertWidget.info({
    super.key,
    this.icon = const Icon(Icons.info, size: 20),
    required this.message,
    this.type = AlertType.info,
    this.constraints,
    this.margin,
  });

  const AlertWidget.error({
    super.key,
    this.icon = const Icon(Icons.error_rounded, size: 20),
    required this.message,
    this.type = AlertType.error,
    this.constraints,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: containerColor(context),
        borderRadius: BorderRadius.circular(8),
      ),
      constraints: constraints,
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (icon != null) IconTheme(data: IconThemeData(color: contentColor(context), size: 20), child: icon!),
          if (icon != null) SizedBox(width: 10),
          DefaultTextStyle(
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: contentColor(context)),
            child: message,
            softWrap: true,
          ),
        ],
      ),
    );
  }

  Color contentColor(BuildContext context) {
    switch (type) {
      case AlertType.warning:
        return Colors.orange;
      case AlertType.info:
        return Theme.of(context).textTheme.bodyMedium!.color!;
      case AlertType.error:
        return Theme.of(context).colorScheme.error;
      case AlertType.primary:
        return Theme.of(context).colorScheme.primary;
    }
  }

  Color containerColor(BuildContext context) {
    switch (type) {
      case AlertType.warning:
        return Colors.orange.shade200.withOpacity(.3);
      case AlertType.info:
        return Theme.of(context).colorScheme.secondaryContainer;
      case AlertType.error:
        return Theme.of(context).colorScheme.errorContainer;
      case AlertType.primary:
        return Theme.of(context).colorScheme.primaryContainer;
    }
  }

  TextStyle messageStyle(BuildContext context) {
    return Theme.of(context).textTheme.bodyMedium!.copyWith(color: contentColor(context));
    switch (type) {
      case AlertType.warning:
        return Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.orange);
      case AlertType.info:
        return Theme.of(context).textTheme.bodyMedium!;
      case AlertType.error:
        return Theme.of(context).textTheme.bodyMedium!.copyWith(color: Theme.of(context).colorScheme.error);
      case AlertType.primary:
        return Theme.of(context).textTheme.bodyMedium!.copyWith(color: Theme.of(context).colorScheme.primary);
        break;
    }
  }
}
