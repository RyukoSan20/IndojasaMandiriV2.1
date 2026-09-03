enum CategoryType { income, expense, transfer }

class CategoryModel {
  final String id;
  final String? userId;
  final String name;
  final dynamic type;
  final String? parentId;
  final bool isSystem;
  final String? icon;
  final String? color;
  final DateTime? createdAt;

  CategoryModel({
    required this.id,
    this.userId,
    required this.name,
    required this.type,
    this.parentId,
    this.isSystem = false,
    this.icon,
    this.color,
    this.createdAt,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] ?? '',
      userId: json['userId'],
      name: json['name'] ?? '',
      type: json['type'] ?? CategoryType.expense,
      parentId: json['parentId'],
      isSystem: json['isSystem'] ?? false,
      icon: json['icon'],
      color: json['color'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'type': type is CategoryType ? (type as CategoryType).name : type,
      'parentId': parentId,
      'isSystem': isSystem,
      'icon': icon,
      'color': color,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}
