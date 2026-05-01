class UserModel {
  final int id;
  final String username;
  final String email;
  final String role;
  final String? fotoProfil;

  const UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    this.fotoProfil,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['user_id'] ?? json['id'] ?? 0,
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'User',
      fotoProfil: json['foto_profil'],
    );
  }
}
