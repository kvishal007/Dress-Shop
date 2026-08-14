class SettingsModel {
  final String shopName;
  final String currency;
  final double taxRate;
  final String receiptFormat;
  final String address;
  final String phone;

  SettingsModel({
    required this.shopName,
    required this.currency,
    required this.taxRate,
    required this.receiptFormat,
    required this.address,
    required this.phone,
  });

  factory SettingsModel.fromJson(Map<String, dynamic> json) {
    return SettingsModel(
      shopName: json['shopName'] ?? 'Smart Dress Shop',
      currency: json['currency'] ?? 'INR',
      taxRate: (json['taxRate'] as num?)?.toDouble() ?? 0.0,
      receiptFormat: json['receiptFormat'] ?? 'THERMAL',
      address: json['address'] ?? '',
      phone: json['phone'] ?? '',
    );
  }
}
