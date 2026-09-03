enum CategoryType { income, expense }

class CategoryModel {
  final String id;
  final String name;
  final CategoryType type;

  CategoryModel({
    required this.id,
    required this.name,
    required this.type,
  });
}
