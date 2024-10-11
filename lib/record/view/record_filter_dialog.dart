import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:money_management/record/bloc/record_bloc.dart';
import 'package:money_management/util/constants/money_enum.dart';

class RecordFilterDialog extends StatefulWidget {
  final ViewMode viewMode;
  const RecordFilterDialog({
    super.key,
    required this.viewMode,
  });

  @override
  State<RecordFilterDialog> createState() => _RecordFilterDialogState();
}

class _RecordFilterDialogState extends State<RecordFilterDialog> {
  late ViewMode _viewMode;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    _viewMode = widget.viewMode;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return AlertDialog(
      title: Center(
        child: Text(
          'Display options',
          style: TextStyle(
            fontSize: textTheme.titleMedium?.fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: ViewMode.values.map((mode) {
            return RadioListTile<ViewMode>(
              title: Text(
                mode.name.toUpperCase(),
                style: TextStyle(
                  fontSize: textTheme.titleSmall?.fontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
              value: mode,
              groupValue: _viewMode,
              onChanged: (ViewMode? value) {
                setState(() {
                  _viewMode = mode;
                  context.read<RecordBloc>().add(RecordEventViewMode(
                        viewMode: mode,
                        isDeleteOperation: false,
                        isDeleted: false,
                        isUpdateOperation: false,
                        isUpdated: false,
                      ));
                });
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}

void showRecordFilterDialog({
  required BuildContext context,
  required ViewMode viewMode,
}) {
  showDialog(
    context: context,
    builder: (context2) {
      return BlocProvider.value(
        value: BlocProvider.of<RecordBloc>(context),
        child: RecordFilterDialog(
          viewMode: viewMode,
        ),
      );
    },
  );
}
