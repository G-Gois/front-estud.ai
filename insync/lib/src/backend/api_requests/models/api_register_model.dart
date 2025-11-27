class ApiRegisterResponseModel {
  final String userId;
  final String login;
  final String email;
  final bool status;
  final String? createdAt;
  final List<dynamic> resources;

  ApiRegisterResponseModel({
    required this.userId,
    required this.login,
    required this.email,
    required this.status,
    this.createdAt,
    required this.resources,
  });

  factory ApiRegisterResponseModel.fromJson(Map<String, dynamic> json) {
    return ApiRegisterResponseModel(
      userId: json['userId'] as String,
      login: json['login'] as String,
      email: json['email'] as String,
      status: json['status'] as bool,
      createdAt: json['createdAt'] as String?,
      resources: json['resources'] as List<dynamic>,
    );
  }
}
