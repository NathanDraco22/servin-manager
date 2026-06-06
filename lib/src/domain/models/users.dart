class BaseUser {
  final String username;
  final String password;
  final bool isActive;

  BaseUser({
    required this.username,
    required this.password,
    this.isActive = true,
  });

  factory BaseUser.fromJson(Map<String, dynamic> json) => BaseUser(
    username: json['username'],
    password: json['password'],
    isActive: json['isActive'] ?? true,
  );

  Map<String, dynamic> toJson() => {
    'username': username,
    'password': password,
    'isActive': isActive,
  };
}

class CreateUser extends BaseUser {
  CreateUser({
    required super.username,
    required super.password,
    super.isActive,
  });

  factory CreateUser.fromJson(Map<String, dynamic> json) => CreateUser(
    username: json['username'],
    password: json['password'],
    isActive: json['isActive'] ?? true,
  );
}

class UpdateUser {
  String? username;
  String? password;
  bool? isActive;

  UpdateUser({
    this.username,
    this.password,
    this.isActive,
  });

  factory UpdateUser.fromJson(Map<String, dynamic> json) => UpdateUser(
    username: json['username'],
    password: json['password'],
    isActive: json['isActive'],
  );

  Map<String, dynamic> toJson() {
    final data = {
      'username': username,
      'password': password,
      'isActive': isActive,
    };
    data.removeWhere((key, value) => value == null);
    return data;
  }
}

class UserInDb extends BaseUser {
  final String id;
  final int createdAt;
  final int? updatedAt;

  UserInDb({
    required this.id,
    required super.username,
    required super.password,
    super.isActive,
    required this.createdAt,
    this.updatedAt,
  });

  factory UserInDb.fromJson(Map<String, dynamic> json) => UserInDb(
    id: json['id'],
    username: json['username'],
    password: json['password'],
    isActive: json['isActive'] ?? true,
    createdAt: json['createdAt'],
    updatedAt: json['updatedAt'],
  );

  @override
  Map<String, dynamic> toJson() {
    final data = super.toJson();
    data.addAll({
      'id': id,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    });
    return data;
  }
}
