import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

final logger = Logger(
  filter: LOG_ENABLED ? DevelopmentFilter() : ProductionFilter(),
  printer: LOG_ENABLED ? null : SimplePrinter(),
  level: LOG_ENABLED ? Level.debug : Level.error,
);

const bool LOG_ENABLED = !kIsWeb && kDebugMode;
// const bool LOG_ENABLED = !kIsWeb;
// const bool LOG_ENABLED = false;