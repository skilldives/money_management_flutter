import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_management/record/bloc/record_bloc.dart';
import 'package:money_management/record/view/record_filter_dialog.dart';
import 'package:money_management/util/common_util.dart';
import 'package:money_management/util/constants/money_enum.dart';

class RecordTitleView extends StatelessWidget {
  const RecordTitleView({
    super.key,
    required this.viewMode,
  });

  final ViewMode viewMode;

  @override
  Widget build(BuildContext context) {
    DateTime startDateTime = DateTime.now();
    DateTime endDateTime = DateTime.now();
    ViewMode changedViewMode = viewMode;
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: IconButton(
              onPressed: () {
                CommonUtil.showSnackBarMessage(
                  'Coming soon...!',
                  context,
                );
              },
              icon: const Icon(Icons.file_download_outlined),
            ),
          ),
          Expanded(
            child: IconButton(
              onPressed: () {
                context.read<RecordBloc>().add(
                      RecordEventPrevious(
                        startDateTime: startDateTime,
                        endDateTime: endDateTime,
                        viewMode: changedViewMode,
                      ),
                    );
              },
              icon: Icon(
                Icons.keyboard_arrow_left,
                size: textTheme.headlineMedium?.fontSize,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Center(
              child: BlocBuilder<RecordBloc, RecordState>(
                builder: (context, state) {
                  String dateTimeRangeText = state.dateTimeText;
                  startDateTime = state.startDateTime;
                  endDateTime = state.endDateTime;
                  changedViewMode = state.viewMode;
                  return Text(
                    dateTimeRangeText,
                    style: TextStyle(
                      fontSize: textTheme.titleSmall?.fontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
            ),
          ),
          Expanded(
            child: IconButton(
              onPressed: () {
                context.read<RecordBloc>().add(
                      RecordEventNext(
                        startDateTime: startDateTime,
                        endDateTime: endDateTime,
                        viewMode: changedViewMode,
                      ),
                    );
              },
              icon: Icon(
                Icons.keyboard_arrow_right,
                size: textTheme.headlineMedium?.fontSize,
              ),
            ),
          ),
          Expanded(
            child: IconButton(
              onPressed: () {
                showRecordFilterDialog(
                  context: context,
                  viewMode: changedViewMode,
                );
              },
              icon: const Icon(Icons.filter_list),
            ),
          ),
        ],
      ),
    );
  }
}
