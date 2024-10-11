import 'dart:async';

import 'package:currency_picker/currency_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:googleapis/drive/v3.dart';
import 'package:money_management/auth/bloc/auth_event.dart';
import 'package:money_management/auth/bloc/auth_state.dart';
import 'package:money_management/auth/service/login_service.dart';
import 'package:money_management/service/exception/auth_exception.dart';
import 'package:money_management/service/storage_service_sql.dart';
import 'package:money_management/util/constants/money_enum.dart';
import 'package:path/path.dart';
import 'dart:io' as dd;

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  StorageService storageService = StorageService();
  LoginService loginService = LoginService();
  AuthBloc(LoginService loginService)
      : super(const AuthStateUninitialized(isLoading: true)) {
    // Initialize
    on<AuthEventInitialize>(
      (event, emit) async {
        await loginService.initialize();
        final user = loginService.currentUser;
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        final bool? loginRequiredVar = prefs.getBool(loginRequired);
        if (user == null) {
          if (loginRequiredVar == null || loginRequiredVar) {
            emit(const AuthStateLoggedOut(
              exception: null,
              isLoading: false,
            ));
          } else {
            emit(const AuthStateLoginNotRequired(isLoading: false));
          }
        } else if (loginRequiredVar == null) {
          emit(const AuthStateLoggedOut(
            exception: null,
            isLoading: false,
          ));
        } else {
          emit(AuthStateLoggedIn(
            user: user,
            isLoading: false,
          ));
        }
      },
    );

    // Google Log in
    on<AuthEventGoogleLogIn>((event, emit) async {
      emit(const AuthStateLoggedOut(
        exception: null,
        isLoading: true,
        loadingText: 'Please wait while I log you in',
      ));
      try {
        await loginService.googleLogIn();
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setBool(loginRequired, true);
        emit(const AuthStateLoggedOut(
          exception: null,
          isLoading: false,
        ));
        emit(AuthStateSyncing(
          isLoading: false,
          currency: event.currency,
        ));
      } on Exception catch (e) {
        emit(AuthStateLoggedOut(exception: e, isLoading: false));
      }
    });

    // Log out
    on<AuthEventLogOut>((event, emit) async {
      try {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.remove(loginRequired);
        await loginService.logOut();
        emit(const AuthStateLoggedOut(exception: null, isLoading: false));
      } on Exception catch (e) {
        emit(AuthStateLoggedOut(exception: e, isLoading: false));
      }
    });
    on<AuthEventDownLoadComplete>((event, emit) async {
      final user = loginService.currentUser;
      emit(
        AuthStateLoggedIn(
          user: user!,
          isLoading: false,
        ),
      );
    });

    on<AuthEventDownLoadFail>(authEventDownloadFail);
    on<AuthEventSync>((event, emit) async {
      Currency currency = event.currency;
      try {
        Media? response = await storageService.syncDataWithDrive(currency);

        if (response != null) {
          // Read the file content as bytes
          List<int> fileBytes = [];

          response.stream.listen((event) {
            fileBytes.addAll(event);
          }, onDone: () async {
            // Convert the file content to a string (assuming it's a text file)
            final docsPath = await getApplicationDocumentsDirectory();
            final dbPath = join(docsPath.path, dbName);
            dd.File databaseFile = dd.File(dbPath);
            await databaseFile.writeAsBytes(fileBytes);

            add(const AuthEventDownLoadComplete());
          }, onError: (object, stack) {
            add(const AuthEventDownLoadFail());
          });
        } else {
          final user = loginService.currentUser;
          emit(
            AuthStateLoggedIn(
              user: user!,
              isLoading: false,
            ),
          );
        }
      } on Exception catch (e) {
        emit(AuthStateLoggedOut(
          exception: e,
          isLoading: false,
        ));
      }
    });

    on<AuthEventLoginNotRequired>(authEventLoginNotRequired);
  }

  FutureOr<void> authEventDownloadFail(event, emit) async {
    emit(
      AuthStateLoggedOut(
        exception: DownloadFailException(),
        isLoading: false,
      ),
    );
  }

  FutureOr<void> authEventLoginNotRequired(
    AuthEventLoginNotRequired event,
    Emitter<AuthState> emit,
  ) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(loginRequired, false);
    emit(const AuthStateLoginNotRequired(isLoading: false));
  }
}
