import 'package:currency_picker/currency_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_management/auth/bloc/auth_bloc.dart';
import 'package:money_management/auth/bloc/auth_event.dart';

class SyncingView extends StatefulWidget {
  final Currency currency;
  const SyncingView({super.key, required this.currency});

  @override
  State<SyncingView> createState() => _SyncingViewState();
}

class _SyncingViewState extends State<SyncingView> {
  late Currency currency;
  @override
  void initState() {
    currency = widget.currency;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    context.read<AuthBloc>().add(AuthEventSync(currency: currency));
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/icon/icon.png',
              height: 300,
            ),
            const SizedBox(
              height: 20,
            ),
            const CircularProgressIndicator.adaptive(),
            const SizedBox(
              height: 20,
            ),
            Text(
              'Syncing data, please wait...',
              style: TextStyle(
                fontSize: textTheme.titleLarge?.fontSize,
              ),
            )
          ],
        ),
      ),
    );
  }
}
