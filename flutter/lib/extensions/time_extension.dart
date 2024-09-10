import 'package:intl/intl.dart';

extension TimeExtension on DateTime {
  String show() {
    return DateFormat('y-M-d H:m:s').format(this);
  }
}
