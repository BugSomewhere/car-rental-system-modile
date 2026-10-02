class UserProfile {
  const UserProfile({
    required this.email,
    required this.fullName,
    this.gender,
    this.phone,
    this.avatarUrl,
    this.roles = const [],
  });

  final String email;
  final String fullName;
  final String? gender;
  final String? phone;
  final String? avatarUrl;
  final List<String> roles;

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        email: json['email'] as String? ?? '',
        fullName: json['fullName'] as String? ?? '',
        gender: json['gender'] as String?,
        phone: json['phone'] as String?,
        avatarUrl: json['avatarUrl'] as String?,
        roles: (json['roles'] as List<dynamic>? ?? const []).cast<String>(),
      );
}
