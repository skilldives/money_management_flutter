import 'package:currency_picker/currency_picker.dart';
import 'package:flutter/foundation.dart' show immutable;

@immutable
abstract class AuthEvent {
  const AuthEvent();
}

class AuthEventInitialize extends AuthEvent {
  const AuthEventInitialize();
}

class AuthEventGoogleLogIn extends AuthEvent {
  final Currency currency;
  const AuthEventGoogleLogIn({
    required this.currency,
  });
}

class AuthEventLogOut extends AuthEvent {
  const AuthEventLogOut();
}

class AuthEventSync extends AuthEvent {
  final Currency currency;
  const AuthEventSync({
    required this.currency,
  });
}

class AuthEventDownLoadComplete extends AuthEvent {
  const AuthEventDownLoadComplete();
}

class AuthEventDownLoadFail extends AuthEvent {
  const AuthEventDownLoadFail();
}

class AuthEventLoginNotRequired extends AuthEvent {
  const AuthEventLoginNotRequired();
}
