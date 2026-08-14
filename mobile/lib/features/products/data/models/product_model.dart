class ProductModel {
  final String id;
  final String name;
  final String sku;
  final String? barcode;
  final String? categoryId;
  final String categoryName;
  final String? description;
  final double price;
  final double costPrice;
  final int stockQuantity;
  final int minStockLevel;
  final List<String> sizes;
  final List<String> colors;
  final String? imageUrl;
  final String status;

  ProductModel({
    required this.id,
    required this.name,
    required this.sku,
    this.barcode,
    this.categoryId,
    required this.categoryName,
    this.description,
    required this.price,
    required this.costPrice,
    required this.stockQuantity,
    required this.minStockLevel,
    required this.sizes,
    required this.colors,
    this.imageUrl,
    required this.status,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      sku: json['sku'] ?? '',
      barcode: json['barcode'],
      categoryId: json['categoryId'],
      categoryName: json['categoryName'] ?? 'General',
      description: json['description'],
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      costPrice: (json['costPrice'] as num?)?.toDouble() ?? 0.0,
      stockQuantity: (json['stockQuantity'] as num?)?.toInt() ?? 0,
      minStockLevel: (json['minStockLevel'] as num?)?.toInt() ?? 5,
      sizes: (json['sizes'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      colors: (json['colors'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      imageUrl: json['imageUrl'],
      status: json['status'] ?? 'AVAILABLE',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'sku': sku,
      if (barcode != null) 'barcode': barcode,
      if (categoryId != null) 'categoryId': categoryId,
      'categoryName': categoryName,
      if (description != null) 'description': description,
      'price': price,
      'costPrice': costPrice,
      'stockQuantity': stockQuantity,
      'minStockLevel': minStockLevel,
      'sizes': sizes,
      'colors': colors,
      if (imageUrl != null) 'imageUrl': imageUrl,
    };
  }
}
