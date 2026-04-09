class UserModel {
  const UserModel({
    required this.uid,
    this.email,
    this.phone,
    this.name,
    this.picture,
    this.provider,
    this.userType,
    this.emailVerified = false,
    this.phoneVerified = false,
    this.profileCompleted = false,
    this.lastLoginAt,
  });

  final String uid;
  final String? email;
  final String? phone;
  final String? name;
  final String? picture;
  final String? provider;
  final String? userType;
  final bool emailVerified;
  final bool phoneVerified;
  final bool profileCompleted;
  final String? lastLoginAt;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String? ?? '',
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      name: json['name'] as String?,
      picture: json['picture'] as String?,
      provider: json['provider'] as String?,
      userType: json['userType'] as String?,
      emailVerified: json['emailVerified'] as bool? ?? false,
      phoneVerified: json['phoneVerified'] as bool? ?? false,
      profileCompleted: json['profileCompleted'] as bool? ?? false,
      lastLoginAt: json['lastLoginAt'] as String?,
    );
  }

  String get displayName => name ?? 'Foydalanuvchi';

  String get displayContact {
    if (phone != null && phone!.isNotEmpty) return '+$phone';
    if (email != null && email!.isNotEmpty) return email!;
    return '';
  }
}
