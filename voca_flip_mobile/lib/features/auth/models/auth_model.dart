// Auth models matching the BE DTOs.

class UserModel {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final int? totalWords;
  final int? masteredWords;
  final int? learningWords;
  final int? streakDays;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.totalWords,
    this.masteredWords,
    this.learningWords,
    this.streakDays,
  });

  static int? _toNullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'] as String,
    name: json['name'] as String,
    email: json['email'] as String,
    avatarUrl: json['avatarUrl'] as String?,
    totalWords: _toNullableInt(json['totalWords']),
    masteredWords: _toNullableInt(json['masteredWords']),
    learningWords: _toNullableInt(json['learningWords']),
    streakDays: _toNullableInt(json['streakDays']),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'avatarUrl': avatarUrl,
    'totalWords': totalWords,
    'masteredWords': masteredWords,
    'learningWords': learningWords,
    'streakDays': streakDays,
  };
}

class AuthResponseModel {
  final String accessToken;
  final String refreshToken;
  final String? tokenType;
  final int? expiresIn;
  final UserModel? user;

  const AuthResponseModel({
    required this.accessToken,
    required this.refreshToken,
    this.tokenType,
    this.expiresIn,
    this.user,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) =>
      AuthResponseModel(
        accessToken: json['accessToken'] as String,
        refreshToken: json['refreshToken'] as String,
        tokenType: json['tokenType'] as String?,
        expiresIn: json['expiresIn'] as int?,
        user: json['user'] != null
            ? UserModel.fromJson(json['user'] as Map<String, dynamic>)
            : null,
      );
}
