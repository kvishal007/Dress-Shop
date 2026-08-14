class InventoryMovementModel {
  final String id;
  final String productId;
  final String type; // IN, OUT, ADJUSTMENT
  final int quantityChange;
  final String reason;
  final Map<String, dynamic> adjustedBy;
  final DateTime createdAt;

  InventoryMovementModel({
    required this.id,
    required this.productId,
    required this.type,
    required this.quantityChange,
    required this.reason,
    required this.adjustedBy,
    required this.createdAt,
  });

  factory InventoryMovementModel.fromJson(Map<String, dynamic> json) {
    return InventoryMovementModel(
      id: json['_id'] ?? json['id'] ?? '',
      productId: json['productId'] ?? '',
      type: json['type'] ?? '',
      quantityChange: (json['quantityChange'] as num?)?.toInt() ?? 0,
      reason: json['reason'] ?? '',
      adjustedBy: json['adjustedBy'] ?? {},
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
