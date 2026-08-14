class ReturnModel {
  final String id;
  final String invoiceNumber;
  final double totalRefund;
  final String reason;
  final Map<String, dynamic> processedBy;
  final DateTime createdAt;

  ReturnModel({
    required this.id,
    required this.invoiceNumber,
    required this.totalRefund,
    required this.reason,
    required this.processedBy,
    required this.createdAt,
  });

  factory ReturnModel.fromJson(Map<String, dynamic> json) {
    return ReturnModel(
      id: json['_id'] ?? json['id'] ?? '',
      invoiceNumber: json['invoiceNumber'] ?? '',
      totalRefund: (json['totalRefund'] as num?)?.toDouble() ?? 0.0,
      reason: json['reason'] ?? '',
      processedBy: json['processedBy'] ?? {},
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
