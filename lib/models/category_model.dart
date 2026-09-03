enum CategoryType {
  income,
  expense,
}

class CategoryModel {
  final String id;
  final String name;
  final String icon;
  final CategoryType type;
  final String? color;
  final bool isSystem;

  CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.type,
    this.color,
    this.isSystem = false,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      icon: json['icon'] ?? '',
      type: json['type'] == 'income' ? CategoryType.income : CategoryType.expense,
      color: json['color'],
      isSystem: json['isSystem'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'type': type == CategoryType.income ? 'income' : 'expense',
      'color': color,
      'isSystem': isSystem,
    };
  }
}
