import 'user_model.dart';

class LoginResponse {
  const LoginResponse({
    required this.success,
    required this.isNewUser,
    required this.user,
  });

  final bool success;
  final bool isNewUser;
  final UserModel user;

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      success: json['success'] as bool? ?? false,
      isNewUser: json['isNewUser'] as bool? ?? false,
      user: UserModel.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}
