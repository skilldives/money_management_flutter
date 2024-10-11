import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_management/auth/bloc/auth_bloc.dart';
import 'package:money_management/auth/bloc/auth_event.dart';
import 'package:money_management/auth/bloc/auth_state.dart';
import 'package:money_management/backup/bloc/bloc/backup_bloc.dart';
import 'package:money_management/money_management/bloc/bloc/money_management_bloc.dart';
import 'package:money_management/record/view/create_record_view.dart';
import 'package:money_management/auth/service/login_service.dart';
import 'package:money_management/service/exception/auth_exception.dart';
import 'package:money_management/util/common_util.dart';
import 'package:money_management/util/constants/routes.dart';
import 'package:money_management/util/loading_screen.dart';
import 'package:money_management/auth/view/login_view.dart';
import 'package:money_management/money_management/view/money_management_view.dart';
import 'package:money_management/views/syncing_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();

  /// InheritedWidget style accessor to our State object.
  // ignore: library_private_types_in_public_api
  static _MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>()!;
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.

  ThemeMode themeColorMode = ThemeMode.system;
  void changeTheme(ThemeMode themeMode) {
    setState(() {
      themeColorMode = themeMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      themeMode: themeColorMode,
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
        ),
        useMaterial3: true,
      ),
      home: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(LoginService()),
          ),
          BlocProvider(
            create: (context) => BackupBloc(),
          ),
          BlocProvider(
            create: (context) => MoneyManagementBloc(),
          ),
        ],
        child: const HomePage(),
      ),
      routes: {
        createRecordRoute: (context) => const CreateRecordView(),
      },
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<AuthBloc>().add(const AuthEventInitialize());
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.isLoading) {
          LoadingScreen().show(
            context: context,
            text: state.loadingText ?? 'Please wait a moment',
          );
        } else {
          LoadingScreen().hide();
        }

        if (state is AuthStateSyncing) {
          CommonUtil.showSnackBarMessage('Login Successful!', context);
        }

        if (state is AuthStateLoggedOut && state.exception != null) {
          if (state.exception is SynchronizationFailedException ||
              state.exception is DownloadFailException ||
              state.exception is DriveApiNotFoundException ||
              state.exception is UploadFailedException) {
            CommonUtil.showSnackBarMessage(
              'Sync failed, Check Internet connection!',
              context,
            );
          }
        }
      },
      builder: (context, state) {
        if (state is AuthStateLoggedOut) {
          return const LoginView();
        } else if (state is AuthStateLoggedIn ||
            state is AuthStateLoginNotRequired) {
          return const MoneyManagementView();
        } else if (state is AuthStateSyncing) {
          return SyncingView(
            currency: state.currency,
          );
        } else {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator.adaptive()),
          );
        }
      },
    );
  }
}
