class AuditLogModel {
  final String id;
  final String action;
  final String entity;
  final Map<String, dynamic> userId;
  final String details;
  final DateTime createdAt;

  AuditLogModel({
    required this.id,
    required this.action,
    required this.entity,
    required this.userId,
    required this.details,
    required this.createdAt,
  });

  factory AuditLogModel.fromJson(Map<String, dynamic> json) {
    return AuditLogModel(
      id: json['_id'] ?? json['id'] ?? '',
      action: json['action'] ?? '',
      entity: json['entity'] ?? '',
      userId: json['userId'] ?? {},
      details: json['details'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
