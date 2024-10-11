import 'package:currency_picker/currency_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show immutable;

@immutable
class AuthState {
  final bool isLoading;
  final String? loadingText;

  const AuthState({
    required this.isLoading,
    this.loadingText = 'Please wait a moment',
  });
}

class AuthStateUninitialized extends AuthState {
  const AuthStateUninitialized({required super.isLoading});
}

class AuthStateLoggedIn extends AuthState {
  final User user;
  const AuthStateLoggedIn({required this.user, required super.isLoading});
}

class AuthStateLoggedOut extends AuthState {
  final Exception? exception;
  const AuthStateLoggedOut({
    required this.exception,
    required super.isLoading,
    super.loadingText = null,
  });
}

class AuthStateSyncing extends AuthState {
  final Currency currency;
  const AuthStateSyncing({
    required this.currency,
    required super.isLoading,
  });
}

class AuthStateLoginNotRequired extends AuthState {
  const AuthStateLoginNotRequired({required super.isLoading});
}
