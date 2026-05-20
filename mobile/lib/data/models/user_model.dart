class UserModel {
  const UserModel({
    required this.id,
    required this.name,
    this.username,
    this.email,
    required this.role,
    this.phone,
    this.schoolId,
    this.schoolName,
    this.grade,
  });

  final int id;
  final String name;
  final String? username;
  final String? email;
  final String role;
  final String? phone;
  final int? schoolId;
  final String? schoolName;
  final String? grade;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] is int ? json['id'] as int : int.parse('${json['id']}'),
      name: json['name'] as String,
      username: json['username'] as String?,
      email: json['email'] as String?,
      role: (json['role'] as String?) ?? 'user',
      phone: json['phone'] as String?,
      schoolId: json['school_id'] == null
          ? null
          : (json['school_id'] is int
              ? json['school_id'] as int
              : int.tryParse('${json['school_id']}')),
      schoolName: json['school_name'] as String?,
      grade: json['grade'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'username': username,
        'email': email,
        'role': role,
        'phone': phone,
        'school_id': schoolId,
        'school_name': schoolName,
        'grade': grade,
      };
}
