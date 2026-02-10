class UserModel {
  final String uid;
  final String username;
  final String email;
  final DateTime createdAt;
  final String? fullName;
  final String? phoneNumber;
  final String? country;

  UserModel({
    required this.uid,
    required this.username,
    required this.email,
    required this.createdAt,
    this.fullName,
    this.phoneNumber,
    this.country,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'username': username,
      'email': email,
      'createdAt': createdAt.toIso8601String(),
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'country': country,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] as String,
      username: map['username'] as String,
      email: map['email'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      fullName: map['fullName'] as String?,
      phoneNumber: map['phoneNumber'] as String?,
      country: map['country'] as String?,
    );
  }

  UserModel copyWith({
    String? uid,
    String? username,
    String? email,
    DateTime? createdAt,
    String? fullName,
    String? phoneNumber,
    String? country,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      username: username ?? this.username,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      country: country ?? this.country,
    );
  }
}

