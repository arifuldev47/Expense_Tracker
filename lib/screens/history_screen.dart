import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/transaction_model.dart';
import '../widgets/category_helper.dart';
import 'add_transaction_screen.dart';

class HistoryScreen extends StatefulWidget {
  final String userId;

  const HistoryScreen({
    super.key,
    required this.userId,
  });
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}
class _HistoryScreenState extends State<HistoryScreen> {
  final DbHelper dbHelper = DbHelper();
  List<TransactionModel> transactions = [];
  String selectedFilter = 'All';
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    loadTransactions();
  }
  Future<void> loadTransactions() async {
    setState(() {
      isLoading = true;
    });
    final data = await dbHelper.getTransactions(widget.userId);
    if (!mounted) return;
    setState(() {
      transactions = data;
      isLoading = false;
    });
  }
  List<TransactionModel> get filteredTransactions {
    if (selectedFilter == 'All') {
      return transactions;
    }

    return transactions.where((transaction) {
      return transaction.type.toLowerCase() ==
          selectedFilter.toLowerCase();
    }).toList();
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
      builder: (context) => AlertDialog(
        title: const Text('Delete Transaction'),
        content: const Text(
          'Are you sure you want to delete this transaction?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
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
          content: Text('Transaction deleted successfully'),
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
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
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
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                  ),
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
  @override
  Widget build(BuildContext context) {
    final filtered = filteredTransactions;
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FB),
      appBar: AppBar(
        title: const Text(
          'Transaction History',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: ['All', 'Income', 'Expense'].map((filter) {
                final isSelected = selectedFilter == filter;

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedFilter = filter;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF6C63FF)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          filter,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : Colors.black87,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(
              child: CircularProgressIndicator(),
            )
                : filtered.isEmpty
                ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 65,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'No Transactions Found',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            )
                : RefreshIndicator(
              onRefresh: loadTransactions,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final transaction = filtered[index];

                  final isIncome =
                      transaction.type.toLowerCase() == 'income';

                  final parsedDate =
                  DateTime.tryParse(transaction.date);

                  final formattedDate = parsedDate == null
                      ? transaction.date
                      : '${parsedDate.day}/${parsedDate.month}/${parsedDate.year}';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: CategoryHelper.getBackgroundColor(
                              transaction.category,
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            CategoryHelper.getEmoji(
                              transaction.category,
                            ),
                            style: const TextStyle(fontSize: 25),
                          ),
                        ),

                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Text(
                                transaction.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                '${transaction.category} • $formattedDate',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                '${isIncome ? 'Income' : 'Expense'}',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isIncome
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 5),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${isIncome ? '+' : '-'}৳${transaction.amount.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: isIncome
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),

                            const SizedBox(height: 8),

                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  tooltip: 'Details',
                                  visualDensity:
                                  VisualDensity.compact,
                                  padding: EdgeInsets.zero,
                                  constraints:
                                  const BoxConstraints(
                                    minWidth: 30,
                                    minHeight: 30,
                                  ),
                                  onPressed: () {
                                    showTransactionDetails(
                                      transaction,
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.visibility_outlined,
                                    size: 19,
                                    color: Colors.deepPurple,
                                  ),
                                ),
                                IconButton(
                                  tooltip: 'Edit',
                                  visualDensity:
                                  VisualDensity.compact,
                                  padding: EdgeInsets.zero,
                                  constraints:
                                  const BoxConstraints(
                                    minWidth: 30,
                                    minHeight: 30,
                                  ),
                                  onPressed: () {
                                    editTransaction(transaction);
                                  },
                                  icon: const Icon(
                                    Icons.edit_outlined,
                                    size: 19,
                                    color: Colors.blue,
                                  ),
                                ),
                                IconButton(
                                  tooltip: 'Delete',
                                  visualDensity:
                                  VisualDensity.compact,
                                  padding: EdgeInsets.zero,
                                  constraints:
                                  const BoxConstraints(
                                    minWidth: 30,
                                    minHeight: 30,
                                  ),
                                  onPressed: () {
                                    deleteTransaction(transaction);
                                  },
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    size: 19,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}