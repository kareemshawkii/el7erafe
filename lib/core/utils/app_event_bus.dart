import 'dart:async';

class AppEventBus {
  static final AppEventBus _instance = AppEventBus._internal();
  factory AppEventBus() => _instance;
  AppEventBus._internal();

  final _controller = StreamController<String>.broadcast();
  Stream<String> get stream => _controller.stream;

  void emit(String eventAction) {
    _controller.add(eventAction);
  }
}