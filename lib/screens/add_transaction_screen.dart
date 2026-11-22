import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/transaction_model.dart';
class AddTransactionScreen extends StatefulWidget {
  final String userId;
  final TransactionModel? transaction;
  const AddTransactionScreen({
    super.key,
    required this.userId,
    this.transaction,
  });
  @override
  State<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}
class _AddTransactionScreenState
    extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final amountController = TextEditingController();
  final descriptionController = TextEditingController();
  final customCategoryController = TextEditingController();
  String selectedType = 'Expense';
  String selectedCategory = 'Food';
  DateTime selectedDate = DateTime.now();
  final List<String> incomeCategories = [
    'Salary',
    'Business',
    'Freelancing',
    'Investment',
    'Gift',
    'Others',
  ];
  final List<String> expenseCategories = [
    'Food',
    'Shopping',
    'Transport',
    'Bills',
    'Health',
    'Education',
    'Entertainment',
    'Rent',
    'Others',
  ];
  bool get isEditing => widget.transaction != null;
  List<String> get categories {
    return selectedType == 'Income'
        ? incomeCategories
        : expenseCategories;
  }
  @override
  void initState() {
    super.initState();
    if (isEditing) {
      final transaction = widget.transaction!;
      titleController.text = transaction.title;
      amountController.text = transaction.amount.toString();
      descriptionController.text = transaction.description;

      selectedType = transaction.type;
      selectedDate = DateTime.parse(transaction.date);
      if (categories.contains(transaction.category)) {
        selectedCategory = transaction.category;
      } else {
        selectedCategory = 'Others';
        customCategoryController.text = transaction.category;
      }
    }
  }
  void changeType(String value) {
    setState(() {
      selectedType = value;
      selectedCategory = value == 'Income' ? 'Salary' : 'Food';
      customCategoryController.clear();
    });
  }
  Future<void> pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }
  Future<void> saveTransaction() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final categoryToSave = selectedCategory == 'Others'
        ? customCategoryController.text.trim()
        : selectedCategory;
    final transaction = TransactionModel(
      id: widget.transaction?.id,
      userId: widget.userId,
      title: titleController.text.trim(),
      amount: double.parse(amountController.text.trim()),
      type: selectedType,
      category: categoryToSave,
      date: selectedDate.toIso8601String(),
      description: descriptionController.text.trim(),
    );
    if (isEditing) {
      await DbHelper().updateTransaction(transaction);
    } else {
      await DbHelper().insertTransaction(transaction);
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isEditing
              ? 'Transaction Updated Successfully!'
              : 'Transaction Saved Successfully!',
        ),
      ),
    );
    Navigator.pop(context, true);
  }
  @override
  void dispose() {
    titleController.dispose();
    amountController.dispose();
    descriptionController.dispose();
    customCategoryController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? 'Edit Transaction' : 'Add Transaction',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Transaction Type',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: selectedType,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                items: ['Income', 'Expense']
                    .map(
                      (type) => DropdownMenuItem(
                    value: type,
                    child: Text(
                      type,
                      style: TextStyle(
                        color: type == 'Income'
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                  ),
                )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    changeType(value);
                  }
                },
              ),
              const SizedBox(height: 20),
              const Text(
                'Title',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(
                  hintText: 'Enter title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              const Text(
                'Amount',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  hintText: 'Enter amount',
                  prefixText: '৳ ',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final amount = double.tryParse(value ?? '');

                  if (amount == null || amount <= 0) {
                    return 'Enter a valid amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              const Text(
                'Category',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                items: categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedCategory = value;

                      if (value != 'Others') {
                        customCategoryController.clear();
                      }
                    });
                  }
                },
              ),
              if (selectedCategory == 'Others') ...[
                const SizedBox(height: 15),
                Text(
                  selectedType == 'Income'
                      ? 'Where is this income coming from?'
                      : 'What is this expense for?',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: customCategoryController,
                  decoration: InputDecoration(
                    hintText: selectedType == 'Income'
                        ? 'Example: Freelance Project Payment'
                        : 'Example: Birthday Party',
                    prefixIcon: const Icon(Icons.edit_note),
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (selectedCategory == 'Others' &&
                        (value == null || value.trim().isEmpty)) {
                      return 'Please enter the category name';
                    }

                    return null;
                  },
                ),
              ],
              const SizedBox(height: 20),
              const Text(
                'Date',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: pickDate,
                icon: const Icon(Icons.calendar_month),
                label: Text(
                  '${selectedDate.day}/'
                      '${selectedDate.month}/'
                      '${selectedDate.year}',
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Description',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Write something...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: saveTransaction,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    isEditing
                        ? 'Update Transaction'
                        : 'Save Transaction',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}