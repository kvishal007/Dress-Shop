class CustomerModel {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final String? address;
  final int loyaltyPoints;
  final double totalSpent;
  final String status;
  final DateTime? createdAt;

  CustomerModel({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.address,
    this.loyaltyPoints = 0,
    this.totalSpent = 0,
    this.status = 'ACTIVE',
    this.createdAt,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'],
      address: json['address'],
      loyaltyPoints: json['loyaltyPoints'] ?? 0,
      totalSpent: (json['totalSpent'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? 'ACTIVE',
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      if (email != null && email!.isNotEmpty) 'email': email,
      if (address != null && address!.isNotEmpty) 'address': address,
    };
  }
}
