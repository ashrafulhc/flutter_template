import 'dart:async';

import 'package:injectable/injectable.dart';

enum AuthEvent { sessionExpired }

@singleton
class AuthEventBus {
  final _controller = StreamController<AuthEvent>.broadcast();

  Stream<AuthEvent> get stream => _controller.stream;

  void dispatchSessionExpired() => _controller.add(AuthEvent.sessionExpired);

  @disposeMethod
  void dispose() => _controller.close();
}
