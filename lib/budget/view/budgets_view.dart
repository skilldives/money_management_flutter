import 'package:flutter/material.dart';

class BudgetsView extends StatelessWidget {
  const BudgetsView({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: Center(
        child: Text(
          'Coming soon...',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: textTheme.titleMedium?.fontSize,
            color: colorScheme.tertiary,
          ),
        ),
      ),
    );
  }
}
