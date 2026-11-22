import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/transaction_model.dart';
import '../widgets/category_helper.dart';
import 'add_transaction_screen.dart';
import 'report_screen.dart';
class HomeScreen extends StatefulWidget {
  final String userName;
  final String userId;
  final Future<void> Function() onLogout;
  const HomeScreen({
    super.key,
    required this.userName,
    required this.userId,
    required this.onLogout,
  });
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}
class _HomeScreenState extends State<HomeScreen> {
  final DbHelper dbHelper = DbHelper();
  List<TransactionModel> transactions = [];
  String selectedFilter = 'All';
  String selectedCategory = 'All';
  DateTime? selectedDate;
  double totalIncome = 0;
  double totalExpense = 0;
  double totalBalance = 0;
  @override
  void initState() {
    super.initState();
    loadTransactions();
  }
  Future<void> loadTransactions() async {
    final data = await dbHelper.getTransactions(widget.userId);

    double income = 0;
    double expense = 0;

    for (var transaction in data) {
      if (transaction.type.toLowerCase() == 'income') {
        income += transaction.amount;
      } else {
        expense += transaction.amount;
      }
    }

    if (!mounted) return;

    setState(() {
      transactions = data;
      totalIncome = income;
      totalExpense = expense;
      totalBalance = income - expense;

      if (selectedCategory != 'All' &&
          !data.any((t) => t.category == selectedCategory)) {
        selectedCategory = 'All';
      }
    });
  }
  Future<void> addTransaction() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTransactionScreen(
          userId: widget.userId,
        ),
      ),
    );
    if (result == true) {
      await loadTransactions();
    }
  }
  Future<void> editTransaction(TransactionModel transaction) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTransactionScreen(
          userId: widget.userId,
          transaction: transaction,
        ),
      ),
    );
    if (result == true) {
      await loadTransactions();
    }
  }
  Future<void> deleteTransaction(TransactionModel transaction) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Transaction?'),
          content: Text(
            'Are you sure you want to delete "${transaction.title}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
    if (confirm == true && transaction.id != null) {
      await dbHelper.deleteTransaction(
        transaction.id!,
        widget.userId,
      );
      await loadTransactions();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Transaction Deleted Successfully!'),
        ),
      );
    }
  }
  void showTransactionDetails(TransactionModel transaction) {
    final isIncome = transaction.type.toLowerCase() == 'income';

    final parsedDate = DateTime.tryParse(transaction.date);

    final formattedDate = parsedDate == null
        ? transaction.date
        : '${parsedDate.day}/${parsedDate.month}/${parsedDate.year}';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Transaction Details',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  height: 65,
                  width: 65,
                  decoration: BoxDecoration(
                    color: CategoryHelper.getBackgroundColor(
                      transaction.category,
                    ),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    CategoryHelper.getEmoji(transaction.category),
                    style: const TextStyle(fontSize: 32),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Center(
                child: Text(
                  '${isIncome ? '+' : '-'}৳${transaction.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: isIncome ? Colors.green : Colors.red,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              detailRow('Title', transaction.title),
              detailRow('Type', transaction.type),
              detailRow('Category', transaction.category),
              detailRow('Date', formattedDate),
              const SizedBox(height: 12),
              const Text(
                'Description',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F6FA),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  transaction.description.trim().isEmpty
                      ? 'No description added'
                      : transaction.description,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
  Widget detailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 85,
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ),
          const Text(': '),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
  Future<void> pickFilterDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }
  List<String> get categoryOptions {
    final categories = transactions
        .map((transaction) => transaction.category)
        .where((category) => category.trim().isNotEmpty)
        .toSet()
        .toList();

    categories.sort();

    return ['All', ...categories];
  }
  List<TransactionModel> get filteredTransactions {
    return transactions.where((transaction) {
      final matchesType = selectedFilter == 'All' ||
          transaction.type.toLowerCase() == selectedFilter.toLowerCase();

      final matchesCategory = selectedCategory == 'All' ||
          transaction.category == selectedCategory;
      final transactionDate = DateTime.tryParse(transaction.date);
      final matchesDate = selectedDate == null ||
          (transactionDate != null &&
              transactionDate.year == selectedDate!.year &&
              transactionDate.month == selectedDate!.month &&
              transactionDate.day == selectedDate!.day);

      return matchesType && matchesCategory && matchesDate;
    }).toList();
  }
  Widget buildBalanceCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF673AB7),
            Color(0xFF9575CD),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Total Balance',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '৳ ${totalBalance.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              buildBalanceInfo(
                icon: Icons.arrow_downward,
                title: 'Income',
                amount: totalIncome,
              ),
              buildBalanceInfo(
                icon: Icons.arrow_upward,
                title: 'Expense',
                amount: totalExpense,
              ),
            ],
          ),
        ],
      ),
    );
  }
  Widget buildBalanceInfo({
    required IconData icon,
    required String title,
    required double amount,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 5),
            Text(
              title,
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Text(
          '৳ ${amount.toStringAsFixed(2)}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
  Widget buildTransactionCard(TransactionModel transaction) {
    final isIncome = transaction.type.toLowerCase() == 'income';
    final color = isIncome ? Colors.green : Colors.red;
    final parsedDate = DateTime.tryParse(transaction.date);

    final formattedDate = parsedDate == null
        ? transaction.date
        : '${parsedDate.day}/${parsedDate.month}/${parsedDate.year}';
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: CategoryHelper.getBackgroundColor(
                      transaction.category,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    CategoryHelper.getEmoji(transaction.category),
                    style: const TextStyle(fontSize: 29),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${transaction.category} • $formattedDate',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '${isIncome ? '+' : '-'} ৳ ${transaction.amount.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      showTransactionDetails(transaction);
                    },
                    icon: const Icon(Icons.visibility_outlined, size: 17),
                    label: const Text('Details'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.deepPurple,
                      padding: const EdgeInsets.symmetric(vertical: 11),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => editTransaction(transaction),
                    icon: const Icon(Icons.edit, size: 17),
                    label: const Text('Edit'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 11),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => deleteTransaction(transaction),
                    icon: const Icon(Icons.delete, size: 17),
                    label: const Text('Delete'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 11),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Expense Tracker',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 19,
              ),
            ),
            Text(
              'Welcome, ${widget.userName}',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white70,
              ),
            ),
          ],
        ),
        centerTitle: false,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: loadTransactions,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ReportsScreen(
                    userId: widget.userId,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.bar_chart),
            tooltip: 'Reports',
          ),
          IconButton(
            onPressed: widget.onLogout,
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: loadTransactions,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildBalanceCard(),
              const SizedBox(height: 25),
              const Text(
                'Recent Transactions',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              Row(
                children: ['All', 'Income', 'Expense'].map((filter) {
                  final isSelected = selectedFilter == filter;

                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            selectedFilter = filter;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isSelected
                              ? Colors.deepPurple
                              : Colors.grey.shade200,
                          foregroundColor: isSelected
                              ? Colors.white
                              : Colors.black87,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(filter),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: 'Filter by Category',
                  prefixIcon: const Icon(
                    Icons.category,
                    color: Colors.deepPurple,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
                items: categoryOptions.map((category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Row(
                      children: [
                        Text(
                          category == 'All'
                              ? '📋'
                              : CategoryHelper.getEmoji(category),
                          style: const TextStyle(fontSize: 21),
                        ),

                        const SizedBox(width: 10),

                        Text(
                          category == 'All'
                              ? 'All Categories'
                              : category,
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedCategory = value;
                    });
                  }
                },
              ),

              const SizedBox(height: 12),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: pickFilterDate,
                    icon: const Icon(Icons.calendar_month),
                    label: Text(
                      selectedDate == null
                          ? 'Select Date'
                          : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                    ),
                  ),

                  if (selectedDate != null)
                    IconButton(
                      onPressed: () {
                        setState(() {
                          selectedDate = null;
                        });
                      },
                      icon: const Icon(
                        Icons.clear,
                        color: Colors.red,
                      ),
                      tooltip: 'Clear date filter',
                    ),
                ],
              ),
              const SizedBox(height: 15),
              if (filteredTransactions.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(30),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.receipt_long,
                          size: 55,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 10),
                        Text(
                          'No Transactions Found',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...filteredTransactions.map(
                      (transaction) => buildTransactionCard(transaction),
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: addTransaction,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Transaction'),
      ),
    );
  }
}
