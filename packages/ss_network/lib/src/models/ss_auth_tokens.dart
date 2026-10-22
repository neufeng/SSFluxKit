import 'ss_user.dart';

class SSAuthTokens {
  const SSAuthTokens({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
    this.user,
  });

  final String accessToken;
  final String refreshToken;
  final int expiresIn;
  final SSUser? user;

  factory SSAuthTokens.fromJson(Map<String, dynamic> json) {
    return SSAuthTokens(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      expiresIn: (json['expiresIn'] as num).toInt(),
      user: json['user'] is Map<String, dynamic>
          ? SSUser.fromJson(json['user'] as Map<String, dynamic>)
          : null,
    );
  }
}
