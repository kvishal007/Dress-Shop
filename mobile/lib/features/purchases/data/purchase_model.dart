class PurchaseItemModel {
  final String productId;
  final String productName;
  final String sku;
  final int quantity;
  final double costPrice;
  final double subtotal;

  PurchaseItemModel({
    required this.productId,
    required this.productName,
    required this.sku,
    required this.quantity,
    required this.costPrice,
    required this.subtotal,
  });

  factory PurchaseItemModel.fromJson(Map<String, dynamic> json) {
    return PurchaseItemModel(
      productId: json['productId'] ?? '',
      productName: json['productName'] ?? '',
      sku: json['sku'] ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      costPrice: (json['costPrice'] as num?)?.toDouble() ?? 0.0,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class PurchaseModel {
  final String id;
  final String poNumber;
  final Map<String, dynamic> supplierId;
  final List<PurchaseItemModel> items;
  final double totalAmount;
  final String status;
  final DateTime? receivedAt;
  final DateTime createdAt;

  PurchaseModel({
    required this.id,
    required this.poNumber,
    required this.supplierId,
    required this.items,
    required this.totalAmount,
    required this.status,
    this.receivedAt,
    required this.createdAt,
  });

  factory PurchaseModel.fromJson(Map<String, dynamic> json) {
    return PurchaseModel(
      id: json['_id'] ?? json['id'] ?? '',
      poNumber: json['poNumber'] ?? '',
      supplierId: json['supplierId'] ?? {},
      items: (json['items'] as List<dynamic>?)
              ?.map((i) => PurchaseItemModel.fromJson(i))
              .toList() ??
          [],
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? 'PENDING',
      receivedAt: json['receivedAt'] != null ? DateTime.tryParse(json['receivedAt']) : null,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    );
  }
}
