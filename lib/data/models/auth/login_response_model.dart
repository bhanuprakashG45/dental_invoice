import 'dart:convert';

LoginResponseModel loginResponseModelFromJson(String str) =>
    LoginResponseModel.fromJson(json.decode(str));

String loginResponseModelToJson(LoginResponseModel data) =>
    json.encode(data.toJson());

class LoginResponseModel {
  final bool success;
  final String message;
  final LoginResponseData? data;

  LoginResponseModel({required this.success, required this.message, this.data});

  factory LoginResponseModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return LoginResponseModel(success: false, message: '', data: null);
    }

    return LoginResponseModel(
      success: json['success'] is bool ? json['success'] : false,
      message: json['message'] is String ? json['message'] : '',
      data: json['data'] is Map<String, dynamic>
          ? LoginResponseData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'success': success, 'message': message, 'data': data?.toJson()};
  }
}

class LoginResponseData {
  final LoginUser? user;
  final String? accessToken;
  final String? refreshToken;

  LoginResponseData({this.user, this.accessToken, this.refreshToken});

  factory LoginResponseData.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return LoginResponseData(
        user: null,
        accessToken: null,
        refreshToken: null,
      );
    }

    return LoginResponseData(
      user: json['user'] is Map<String, dynamic>
          ? LoginUser.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      accessToken: json['accessToken'] is String ? json['accessToken'] : null,
      refreshToken: json['refreshToken'] is String
          ? json['refreshToken']
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user?.toJson(),
      'accessToken': accessToken,
      'refreshToken': refreshToken,
    };
  }
}

class LoginUser {
  final String? id;
  final String? email;
  final String? role;
  final bool isActive;
  final String? name;
  final String? phone;
  final String? clinicName;
  final String? address;

  LoginUser({
    this.id,
    this.email,
    this.role,
    this.isActive = false,
    this.name,
    this.phone,
    this.clinicName,
    this.address,
  });

  factory LoginUser.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return LoginUser();
    }

    return LoginUser(
      id: json['id'] is String ? json['id'] : null,
      email: json['email'] is String ? json['email'] : null,
      role: json['role'] is String ? json['role'] : null,
      isActive: json['isActive'] is bool ? json['isActive'] : false,
      name: json['name'] is String ? json['name'] : null,
      phone: json['phone'] is String ? json['phone'] : null,
      clinicName: json['clinicName'] is String ? json['clinicName'] : null,
      address: json['address'] is String ? json['address'] : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'role': role,
      'isActive': isActive,
      'name': name,
      'phone': phone,
      'clinicName': clinicName,
      'address': address,
    };
  }
}
