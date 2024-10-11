enum RecordType { income, expense, transfer }

enum MenuAction { edit, delete, ignore }

enum ViewMode {
  daily,
  weekly,
  monthly,
  yearly, /*custom*/
}

enum AnalysisType {
  expenseOverview(name: 'Expense overview'),
  incomeOverview(name: 'Income overview');
  // expenseFlow(name: 'Expense flow'),
  // incomeFlow(name: 'Income flow'),
  // accountAnalysis(name: 'Account analysis');

  final String name;
  const AnalysisType({
    required this.name,
  });
}

enum ShowTotal { yes, no }

enum CarryOver { on, off }

const String loginRequired = 'loginRequired';
