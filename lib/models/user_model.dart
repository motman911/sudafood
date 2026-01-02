class UserModel {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final String role; // 'customer', 'vendor', 'driver'

  UserModel({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.role = 'customer',
  });

  // تحويل من JSON (جاي من السيرفر)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      email: json['email'],
      role: json['role'] ?? 'customer',
    );
  }

  // تحويل إلى JSON (رايح للسيرفر)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'role': role,
    };
  }
}
