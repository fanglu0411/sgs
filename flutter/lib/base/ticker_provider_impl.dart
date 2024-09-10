import 'package:flutter/src/scheduler/ticker.dart';

class TickerProviderImpl extends TickerProvider {
  @override
  Ticker createTicker(onTick) {
    return Ticker(onTick);
  }
}
