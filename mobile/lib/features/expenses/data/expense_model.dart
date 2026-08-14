class ExpenseModel {
  final String id;
  final String category;
  final double amount;
  final DateTime date;
  final String note;
  final Map<String, dynamic> recordedBy;

  ExpenseModel({
    required this.id,
    required this.category,
    required this.amount,
    required this.date,
    required this.note,
    required this.recordedBy,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['_id'] ?? json['id'] ?? '',
      category: json['category'] ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      date: DateTime.parse(json['date']),
      note: json['note'] ?? '',
      recordedBy: json['recordedBy'] ?? {},
    );
  }
}
