import 'package:currency_picker/currency_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_management/auth/bloc/auth_bloc.dart';
import 'package:money_management/auth/bloc/auth_event.dart';
import 'package:money_management/auth/view/not_now_dialog.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  Currency cur = CurrencyService().findByCode('INR')!;
  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.inversePrimary,
        title: const Center(
          child: Text('Login'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              Image.asset(
                'assets/images/login.png',
                height: 400,
              ),
              OutlinedButton.icon(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(kTextTabBarHeight),
                ),
                onPressed: () async {
                  await HapticFeedback.mediumImpact();
                  // ignore: use_build_context_synchronously
                  showCurrencyPicker(
                    context: context,
                    onSelect: (Currency currency) {
                      setState(() {
                        cur = currency;
                      });
                    },
                  );
                },
                icon: const Icon(Icons.edit),
                label: Text('${cur.symbol}  ${cur.name}'),
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(kTextTabBarHeight),
                ),
                onPressed: () async {
                  context
                      .read<AuthBloc>()
                      .add(AuthEventGoogleLogIn(currency: cur));
                  await HapticFeedback.mediumImpact();
                },
                icon: Image.asset(
                  'assets/images/google.png',
                  height: 50,
                ),
                label: const Text(
                  'Login with Google',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              TextButton(
                onPressed: () async {
                  bool shouldProceed = await showNotNowDialog(context: context);
                  if (shouldProceed) {
                    // ignore: use_build_context_synchronously
                    context
                        .read<AuthBloc>()
                        .add(const AuthEventLoginNotRequired());
                  }
                },
                child: const Text('Not Now'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
