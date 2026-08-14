class SupplierModel {
  final String id;
  final String name;
  final String contactPerson;
  final String phone;
  final String? email;
  final double payablesDue;
  final bool isActive;

  SupplierModel({
    required this.id,
    required this.name,
    required this.contactPerson,
    required this.phone,
    this.email,
    required this.payablesDue,
    required this.isActive,
  });

  factory SupplierModel.fromJson(Map<String, dynamic> json) {
    return SupplierModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      contactPerson: json['contactPerson'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'],
      payablesDue: (json['payablesDue'] as num?)?.toDouble() ?? 0.0,
      isActive: json['isActive'] ?? true,
    );
  }
}
