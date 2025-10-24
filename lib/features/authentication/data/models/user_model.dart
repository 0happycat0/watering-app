import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int id;
  final String username;
  final String email;
  final String password;
  final String accessToken;
  final String refreshToken;
  final bool verified;

  const User({
    this.id = 0,
    this.username = '',
    this.email = '',
    this.password = '',
    this.accessToken = '',
    this.refreshToken = '',
    this.verified = false,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'] ?? 0,
    username: json['username'] ?? '',
    email: json['email'] ?? '',
    password: json['password'] ?? '',
    accessToken: json['accessToken'] ?? '',
    refreshToken: json['refreshToken'] ?? '',
    verified: json['verified'] ?? false,
  );

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'username': username,
      'email': email,
      'password': password,
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'verified': verified,
    };
  }

  @override
  List<Object?> get props => [
    id,
    username,
    email,
    password,
    accessToken,
    refreshToken,
    verified,
  ];
}
