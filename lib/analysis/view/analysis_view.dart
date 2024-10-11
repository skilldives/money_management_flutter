import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_management/analysis/bloc/analysis_bloc.dart';
import 'package:money_management/analysis/model/analysis_data.dart';
import 'package:money_management/analysis/service/analysis_service.dart';
import 'package:money_management/analysis/view/analysis_nested_list.dart';
import 'package:money_management/analysis/view/indicator.dart';
import 'package:money_management/record/bloc/record_bloc.dart';
import 'package:money_management/record/view/record_bottom_view.dart';
import 'package:money_management/record/view/record_title_view.dart';
import 'package:money_management/util/constants/money_enum.dart';
import 'package:money_management/category/model/category.dart' as ct;

class AnalysisView extends StatefulWidget {
  const AnalysisView({super.key});

  @override
  State<AnalysisView> createState() => _AnalysisViewState();
}

class _AnalysisViewState extends State<AnalysisView> {
  ViewMode viewMode = ViewMode.monthly;
  int parentTouchedIndex = 0;
  int childTouchedIndex = 0;
  AnalysisType analysisType = AnalysisType.expenseOverview;

  @override
  void initState() {
    super.initState();
    context.read<RecordBloc>().add(RecordEventViewMode(
        isDeleteOperation: false,
        isDeleted: false,
        isUpdateOperation: false,
        isUpdated: false,
        viewMode: viewMode));
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.inversePrimary,
        notificationPredicate: (ScrollNotification notification) {
          return notification.depth == 1;
        },
        scrolledUnderElevation: 4.0,
        shadowColor: Theme.of(context).shadowColor,
        title: RecordTitleView(
          viewMode: viewMode,
        ),
        bottom: const PreferredSize(
          preferredSize: Size(double.infinity, kBottomNavigationBarHeight),
          child: RecordBottomView(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownMenu<AnalysisType>(
              initialSelection: AnalysisType.expenseOverview,
              hintText: 'Select Analysis',
              onSelected: (AnalysisType? analysis) {
                setState(() {
                  analysisType = analysis!;
                  parentTouchedIndex = 0;
                  childTouchedIndex = 0;
                });
              },
              dropdownMenuEntries:
                  AnalysisType.values.map<DropdownMenuEntry<AnalysisType>>((e) {
                return DropdownMenuEntry<AnalysisType>(
                  value: e,
                  label: e.name.toUpperCase(),
                );
              }).toList(),
            ),
            BlocListener<RecordBloc, RecordState>(
              listener: (context, state) {
                if (state is RecordStateEmptyFetch) {
                  context.read<AnalysisBloc>().add(AnalysisEventFetch(
                      records: const [],
                      categoryMap: const {},
                      accountMap: const {}));
                } else if (state is RecordStateFetched) {
                  context.read<AnalysisBloc>().add(AnalysisEventFetch(
                        records: state.records,
                        categoryMap: state.categoryMap,
                        accountMap: state.accountMap,
                      ));
                  setState(() {
                    parentTouchedIndex = 0;
                  });
                } else {
                  context.read<AnalysisBloc>().add(AnalysisEventLoading());
                }
              },
              child: BlocBuilder<AnalysisBloc, AnalysisState>(
                builder: (context, state) {
                  if (state is AnalysisStateCompleted) {
                    AnalysisData analysisParentData =
                        AnalysisService.prepareParentData(
                      analysisType: analysisType,
                      expenseOverview: state.expenseOverview,
                      incomeOverview: state.incomeOverview,
                    );
                    AnalysisData analysisChildData =
                        AnalysisService.prepareChildData(
                      analysisType: analysisType,
                      expenseOverview: state.expenseOverview,
                      incomeOverview: state.incomeOverview,
                      parentTouchedIndex: parentTouchedIndex,
                    );
                    AnalysisListData analysisListData =
                        AnalysisService.prepareAnalysisListData(
                      analysisType: analysisType,
                      expenseOverview: state.expenseOverview,
                      incomeOverview: state.incomeOverview,
                      parentData: analysisParentData,
                    );
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: AspectRatio(
                                aspectRatio: 1,
                                child: PieChart(
                                  PieChartData(
                                      pieTouchData: PieTouchData(
                                        touchCallback: (FlTouchEvent event,
                                            pieTouchResponse) {
                                          setState(() {
                                            if (!event
                                                    .isInterestedForInteractions ||
                                                pieTouchResponse == null ||
                                                pieTouchResponse
                                                        .touchedSection ==
                                                    null) {
                                              return;
                                            }
                                            if (pieTouchResponse.touchedSection!
                                                    .touchedSectionIndex >=
                                                0) {
                                              parentTouchedIndex =
                                                  pieTouchResponse
                                                      .touchedSection!
                                                      .touchedSectionIndex;
                                              childTouchedIndex = 0;
                                            }
                                          });
                                        },
                                      ),
                                      sections: showParentSection(
                                        analysisData: analysisParentData,
                                      ),
                                      centerSpaceRadius: 60,
                                      sectionsSpace: 0),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: List.generate(
                                    analysisParentData.colorData.length,
                                    (index) {
                                  return Indicator(
                                    color: analysisParentData.colorData.values
                                        .elementAt(index),
                                    text: analysisParentData.colorData.keys
                                        .elementAt(index)
                                        .name,
                                    isSquare: false,
                                  );
                                }),
                              ),
                            ),
                          ],
                        ),
                        const Divider(
                          indent: 5,
                          endIndent: 5,
                        ),
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: AspectRatio(
                                aspectRatio: 1,
                                child: PieChart(
                                  PieChartData(
                                      pieTouchData: PieTouchData(
                                        touchCallback: (FlTouchEvent event,
                                            pieTouchResponse) {
                                          setState(() {
                                            if (!event
                                                    .isInterestedForInteractions ||
                                                pieTouchResponse == null ||
                                                pieTouchResponse
                                                        .touchedSection ==
                                                    null) {
                                              return;
                                            }
                                            if (pieTouchResponse.touchedSection!
                                                    .touchedSectionIndex >=
                                                0) {
                                              childTouchedIndex =
                                                  pieTouchResponse
                                                      .touchedSection!
                                                      .touchedSectionIndex;
                                            }
                                          });
                                        },
                                      ),
                                      sections: showChildSection(
                                        analysisData: analysisChildData,
                                      ),
                                      centerSpaceRadius: 60,
                                      sectionsSpace: 0),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: List.generate(
                                    analysisChildData.colorData.length,
                                    (index) {
                                  return Indicator(
                                    color: analysisChildData.colorData.values
                                        .elementAt(index),
                                    text: analysisChildData.colorData.keys
                                        .elementAt(index)
                                        .name,
                                    isSquare: false,
                                  );
                                }),
                              ),
                            ),
                          ],
                        ),
                        AnalysisNestedList(
                          key: UniqueKey(),
                          analysisListData: analysisListData,
                        )
                      ],
                    );
                  } else if (state is AnalysisStateEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.wysiwyg_outlined,
                            size: 70,
                            color: colorScheme.outline,
                          ),
                          const Text('No analysis for this period')
                        ],
                      ),
                    );
                  } else {
                    return const Center(
                        child: CircularProgressIndicator.adaptive());
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> showParentSection({
    required AnalysisData analysisData,
  }) {
    List<MapEntry<ct.Category, num>> listEntry = analysisData.listEntry;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return List.generate(listEntry.length, (i) {
      final isTouched = i == parentTouchedIndex;
      final radius = isTouched ? 50.0 : 40.0;
      double value =
          double.parse(listEntry.elementAt(i).value.toStringAsFixed(2));
      return PieChartSectionData(
        color: analysisData.colorData[listEntry.elementAt(i).key],
        value: value,
        showTitle: false,
        radius: radius,
        badgePositionPercentageOffset: .0001,
        badgeWidget: Visibility(
          visible: isTouched,
          child: Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: colorScheme.tertiaryContainer),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  listEntry.elementAt(i).key.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '$value%',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                )
              ],
            ),
          ),
        ),
      );
    });
  }

  List<PieChartSectionData> showChildSection({
    required AnalysisData analysisData,
  }) {
    List<MapEntry<ct.Category, num>> listEntry = analysisData.listEntry;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return List.generate(listEntry.length, (i) {
      final isTouched = i == childTouchedIndex;
      final radius = isTouched ? 50.0 : 40.0;
      double value =
          double.parse(listEntry.elementAt(i).value.toStringAsFixed(2));
      return PieChartSectionData(
        color: analysisData.colorData[listEntry.elementAt(i).key],
        value: value,
        showTitle: false,
        radius: radius,
        badgePositionPercentageOffset: .0001,
        badgeWidget: Visibility(
          visible: isTouched,
          child: Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: colorScheme.tertiaryContainer),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  listEntry.elementAt(i).key.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '$value%',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                )
              ],
            ),
          ),
        ),
      );
    });
  }
}
