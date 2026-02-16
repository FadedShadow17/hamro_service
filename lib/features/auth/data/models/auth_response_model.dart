class AuthResponseModel {
  final String token;
  final Map<String, dynamic> user;
  final String? message;

  AuthResponseModel({
    required this.token,
    required this.user,
    this.message,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    final token = (json["token"] ?? "") as String;
    final user = (json["user"] ?? {}) as Map<String, dynamic>;
    final message = json["message"] as String?;
    return AuthResponseModel(token: token, user: user, message: message);
  }
}
