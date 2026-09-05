class UserModel {
  final String id;
  final String name;
  final String displayName;
  final String email;
  final String currency;

  UserModel({
    required this.id,
    required this.name,
    String? displayName,
    String? email,
    this.currency = 'IDR',
  })  : displayName = displayName ?? name,
        email = email ?? 'user@fintrack.local';
}
