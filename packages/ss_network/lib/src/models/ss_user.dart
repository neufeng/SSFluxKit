class SSUser {
  const SSUser({
    required this.id,
    required this.email,
    required this.displayName,
    required this.disabled,
    this.createdAt,
    this.updatedAt,
  });

  final int id;
  final String email;
  final String displayName;
  final bool disabled;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory SSUser.fromJson(Map<String, dynamic> json) {
    return SSUser(
      id: json['id'] as int,
      email: json['email'] as String? ?? '',
      displayName: json['displayName'] as String? ?? '',
      disabled: json['disabled'] as bool? ?? false,
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
    );
  }

  static DateTime? _parseDate(Object? value) {
    if (value is! String || value.isEmpty) {
      return null;
    }
    return DateTime.tryParse(value);
  }
}
