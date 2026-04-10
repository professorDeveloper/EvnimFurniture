class SendOtpResponse {
  const SendOtpResponse({
    required this.success,
    required this.message,
    this.phone,
    this.email,
  });

  final bool success;
  final String message;
  final String? phone;
  final String? email;

  factory SendOtpResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    return SendOtpResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      phone: data['phone'] as String?,
      email: data['email'] as String?,
    );
  }
}

class VerifyOtpResponse {
  const VerifyOtpResponse({
    required this.success,
    required this.message,
    required this.customToken,
    required this.isNewUser,
  });

  final bool success;
  final String message;
  final String customToken;
  final bool isNewUser;

  factory VerifyOtpResponse.fromJson(Map<String, dynamic> json) {
    return VerifyOtpResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      customToken: json['customToken'] as String? ?? '',
      isNewUser: json['isNewUser'] as bool? ?? true,
    );
  }
}
