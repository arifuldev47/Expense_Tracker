import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../database/db_helper.dart';
import '../models/transaction_model.dart';
class ReportsScreen extends StatefulWidget {
  final String userId;
  const ReportsScreen({
    super.key,
    required this.userId,
  });
  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}
class _ReportsScreenState extends State<ReportsScreen> {
  DateTime selectedMonth = DateTime.now();
  double totalIncome = 0;
  double totalExpense = 0;
  Map<String, double> categoryExpenses = {};
  final List<Color> chartColors = [
    Colors.deepPurple,
    Colors.orange,
    Colors.green,
    Colors.blue,
    Colors.red,
    Colors.teal,
    Colors.pink,
  ];
  @override
  void initState() {
    super.initState();
    loadReport();
  }
  Future<void> loadReport() async {
    final data = await DbHelper().getTransactions(widget.userId);
    double income = 0;
    double expense = 0;
    Map<String, double> categories = {};
    for (var transaction in data) {
      final date = DateTime.tryParse(transaction.date);

      if (date == null ||
          date.year != selectedMonth.year ||
          date.month != selectedMonth.month) {
        continue;
      }
      if (transaction.type == 'Income') {
        income += transaction.amount;
      } else if (transaction.type == 'Expense') {
        expense += transaction.amount;

        categories[transaction.category] =
            (categories[transaction.category] ?? 0) +
                transaction.amount;
      }
    }
    if (!mounted) return;
    setState(() {
      totalIncome = income;
      totalExpense = expense;
      categoryExpenses = categories;
    });
  }
  void changeMonth(int difference) {
    setState(() {
      selectedMonth = DateTime(
        selectedMonth.year,
        selectedMonth.month + difference,
      );
    });

    loadReport();
  }
  String get monthName {
    const months = [
      'January', 'February', 'March',
      'April', 'May', 'June',
      'July', 'August', 'September',
      'October', 'November', 'December'
    ];
    return '${months[selectedMonth.month - 1]} ${selectedMonth.year}';
  }
  Widget summaryCard(
      String title,
      double amount,
      Color color,
      IconData icon,
      ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: color.withOpacity(0.10),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 25),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              '৳ ${amount.toStringAsFixed(2)}',
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget incomeExpensePieChart() {
    final total = totalIncome + totalExpense;

    if (total <= 0) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(25),
          child: Text(
            'No income or expense data available',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }
    final incomePercentage = (totalIncome / total) * 100;
    final expensePercentage = (totalExpense / total) * 100;
    final sections = <PieChartSectionData>[];
    if (totalIncome > 0) {
      sections.add(
        PieChartSectionData(
          color: Colors.green,
          value: totalIncome,
          title: '${incomePercentage.toStringAsFixed(1)}%',
          radius: 75,
          titleStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      );
    }
    if (totalExpense > 0) {
      sections.add(
        PieChartSectionData(
          color: Colors.red,
          value: totalExpense,
          title: '${expensePercentage.toStringAsFixed(1)}%',
          radius: 75,
          titleStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      );
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            height: 230,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 4,
                    centerSpaceRadius: 55,
                    sections: sections,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Total',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '৳ ${total.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildPieLegend(
            title: 'Income',
            amount: totalIncome,
            percentage: incomePercentage,
            color: Colors.green,
          ),
          const SizedBox(height: 15),
          _buildPieLegend(
            title: 'Expense',
            amount: totalExpense,
            percentage: expensePercentage,
            color: Colors.red,
          ),
        ],
      ),
    );
  }
  Widget _buildPieLegend({
    required String title,
    required double amount,
    required double percentage,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          width: 13,
          height: 13,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          '${percentage.toStringAsFixed(1)}%',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 15),
        Text(
          '৳ ${amount.toStringAsFixed(2)}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
  Widget expensePieChart() {
    final entries = categoryExpenses.entries.toList();

    if (entries.isEmpty || totalExpense <= 0) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(25),
          child: Text(
            'No expense data available',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }
    return Column(
      children: [
        SizedBox(
          height: 230,
          child: PieChart(
            PieChartData(
              sectionsSpace: 3,
              centerSpaceRadius: 45,
              sections: List.generate(entries.length, (index) {
                final entry = entries[index];
                final percentage = (entry.value / totalExpense) * 100;
                return PieChartSectionData(
                  color: chartColors[index % chartColors.length],
                  value: entry.value,
                  title: '${percentage.toStringAsFixed(1)}%',
                  radius: 75,
                  titleStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                );
              }),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 15,
          runSpacing: 12,
          children: List.generate(entries.length, (index) {
            final entry = entries[index];

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: chartColors[index % chartColors.length],
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  entry.key,
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            );
          }),
        ),
      ],
    );
  }
  @override
  Widget build(BuildContext context) {
    final balance = totalIncome - totalExpense;

    final highestExpense = categoryExpenses.values.isEmpty
        ? 0.0
        : categoryExpenses.values.reduce(
          (a, b) => a > b ? a : b,
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports & Summary'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: loadReport,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () => changeMonth(-1),
                      icon: const Icon(Icons.chevron_left),
                    ),
                    Text(
                      monthName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                    IconButton(
                      onPressed: () => changeMonth(1),
                      icon: const Icon(Icons.chevron_right),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),
              const Text(
                'Monthly Overview',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  summaryCard(
                    'Income',
                    totalIncome,
                    Colors.green,
                    Icons.arrow_downward,
                  ),
                  const SizedBox(width: 12),
                  summaryCard(
                    'Expense',
                    totalExpense,
                    Colors.red,
                    Icons.arrow_upward,
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF673AB7),
                      Color(0xFF9575CD),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Monthly Balance',
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '৳ ${balance.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 27,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'Income vs Expense',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              incomeExpensePieChart(),
              const SizedBox(height: 30),
              const Text(
                'Category-wise Expenses',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              if (categoryExpenses.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(25),
                    child: Text(
                      'No expense records for this month.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              else
                ...categoryExpenses.entries.map((entry) {
                  final percentage = highestExpense == 0
                      ? 0.0
                      : entry.value / highestExpense;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              entry.key,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '৳ ${entry.value.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: percentage,
                            minHeight: 9,
                            backgroundColor: Colors.grey.shade200,
                            color: Colors.deepPurple,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              const SizedBox(height: 20),
              const Text(
                'Expense Distribution',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              expensePieChart(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}