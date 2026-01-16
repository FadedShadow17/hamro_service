class AuthResponseModel {
  final String token;
  final Map<String, dynamic> user;

  AuthResponseModel({
    required this.token,
    required this.user,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    final token = (json["token"] ?? "") as String;
    final user = (json["user"] ?? {}) as Map<String, dynamic>;
    return AuthResponseModel(token: token, user: user);
  }
}
