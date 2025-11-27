class ApiLoginModel {
  final String token;
  final int expiresIn;
  final String userId;
  final String? lastLogin;

  ApiLoginModel({
    required this.token,
    required this.expiresIn,
    required this.userId,
    this.lastLogin,
  });

  factory ApiLoginModel.fromJson(Map<String, dynamic> json) {
    return ApiLoginModel(
      token: json['token'] as String,
      expiresIn: json['expiresIn'] as int,
      userId: json['userId'] as String,
      lastLogin: json['lastLogin'] as String?,
    );
  }
}
