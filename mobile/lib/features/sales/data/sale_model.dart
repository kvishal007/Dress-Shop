class SaleItemModel {
  final String productId;
  final String productName;
  final String sku;
  final int quantity;
  final double unitPrice;
  final double subtotal;

  SaleItemModel({
    required this.productId,
    required this.productName,
    required this.sku,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
  });

  factory SaleItemModel.fromJson(Map<String, dynamic> json) {
    return SaleItemModel(
      productId: json['productId'] ?? '',
      productName: json['productName'] ?? '',
      sku: json['sku'] ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0.0,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class SaleModel {
  final String id;
  final String invoiceNumber;
  final String cashierId;
  final String? customerId;
  final List<SaleItemModel> items;
  final double subtotal;
  final double taxAmount;
  final double discountAmount;
  final double totalAmount;
  final String paymentMethod;
  final String status;
  final DateTime? createdAt;

  SaleModel({
    required this.id,
    required this.invoiceNumber,
    required this.cashierId,
    this.customerId,
    required this.items,
    required this.subtotal,
    required this.taxAmount,
    required this.discountAmount,
    required this.totalAmount,
    required this.paymentMethod,
    required this.status,
    this.createdAt,
  });

  factory SaleModel.fromJson(Map<String, dynamic> json) {
    return SaleModel(
      id: json['_id'] ?? json['id'] ?? '',
      invoiceNumber: json['invoiceNumber'] ?? '',
      cashierId: json['cashierId'] ?? '',
      customerId: json['customerId'],
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => SaleItemModel.fromJson(item))
              .toList() ??
          [],
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      taxAmount: (json['taxAmount'] as num?)?.toDouble() ?? 0.0,
      discountAmount: (json['discountAmount'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: json['paymentMethod'] ?? 'CASH',
      status: json['status'] ?? 'COMPLETED',
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
    );
  }
}
