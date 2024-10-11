import 'package:flutter/material.dart';
import 'package:money_management/analysis/model/analysis_data.dart';

class AnalysisNestedList extends StatefulWidget {
  const AnalysisNestedList({required this.analysisListData, super.key});
  final AnalysisListData analysisListData;

  @override
  State<AnalysisNestedList> createState() => _AnalysisNestedListState();
}

class _AnalysisNestedListState extends State<AnalysisNestedList> {
  late AnalysisListData analysisListData;

  @override
  void initState() {
    analysisListData = widget.analysisListData;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return ListView.builder(
      shrinkWrap: true,
      itemCount: analysisListData.parentPercentEntry.length,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, parentIndex) {
        var parentItem =
            analysisListData.parentPercentEntry.elementAt(parentIndex);
        double parentPercentValue =
            double.parse(parentItem.value.toStringAsFixed(2));
        var parentValueItem =
            analysisListData.parentValueEntry.elementAt(parentIndex);
        return Column(
          children: [
            ListTile(
              tileColor: colorScheme.surfaceVariant,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      parentItem.key.name,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      parentValueItem.value,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              trailing: Text(
                '$parentPercentValue%',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              leading: Icon(
                IconData(
                  parentItem.key.iconDataCodePoint,
                  fontFamily: 'MaterialIcons',
                ),
                size: textTheme.headlineMedium?.fontSize,
              ),
              onTap: () {
                setState(() {
                  analysisListData.parentEnabledEntry[parentItem.key] =
                      !analysisListData.parentEnabledEntry[parentItem.key]!;
                });
              },
              subtitle: LinearProgressIndicator(
                value: parentPercentValue / 100.00,
              ),
            ),
            const Divider(
              color: Colors.transparent,
            ),
            Visibility(
              visible: analysisListData.parentEnabledEntry[parentItem.key]!,
              child: ListView.builder(
                padding: const EdgeInsets.only(left: 15),
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount:
                    analysisListData.childPercentEntry[parentItem.key]!.length,
                itemBuilder: (context, index) {
                  var childItems =
                      analysisListData.childPercentEntry[parentItem.key]!;
                  var childItem = childItems.elementAt(index);
                  double childPercentValue =
                      double.parse(childItem.value.toStringAsFixed(2));
                  var childValueItems =
                      analysisListData.childValueEntry[parentItem.key]!;
                  var childValueItem = childValueItems.elementAt(index);
                  return Column(
                    children: [
                      ListTile(
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                childItem.key.name,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                childValueItem.value,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            )
                          ],
                        ),
                        leading: Icon(
                          IconData(
                            childItem.key.iconDataCodePoint,
                            fontFamily: 'MaterialIcons',
                          ),
                        ),
                        trailing: Text(
                          '$childPercentValue%',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: LinearProgressIndicator(
                          value: childPercentValue / 100.00,
                        ),
                      ),
                      const Divider(),
                    ],
                  );
                },
              ),
            )
          ],
        );
      },
    );
  }
}
