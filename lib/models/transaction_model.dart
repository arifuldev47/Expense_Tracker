class TransactionModel {
  final int? id;
  final String userId;
  final String title;
  final double amount;
  final String type;
  final String category;
  final String date;
  final String description;
  const TransactionModel({
    this.id,
    required this.userId,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    required this.description,
  });
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'amount': amount,
      'type': type,
      'category': category,
      'date': date,
      'description': description,
    };
  }
  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] as int?,
      userId: map['user_id'] ?? '',
      title: map['title'],
      amount: (map['amount'] as num).toDouble(),
      type: map['type'],
      category: map['category'],
      date: map['date'],
      description: map['description'],
    );
  }
}