import 'package:shared_preferences/shared_preferences.dart';

class UserLocalStorage {
  static const _keyUserId = 'user_id';
  static const _keyEmail = 'email';
  static const _keyUserRole = 'user_role';
  static const _keyIsActive = 'is_active';
  static const _keyName = 'name';
  static const _keyPhone = 'phone';
  static const _keyClinicName = 'clinic_name';
  static const _keyAddress = 'address';

  static const _keyAccessToken = 'access_token';
  static const _keyRefreshToken = 'refresh_token';

  static Future<SharedPreferences> get _prefs async =>
      await SharedPreferences.getInstance();

  static Future<void> saveUserDetails({
    required String userId,
    required String email,
    required String role,
    required bool isActive,
    required String name,
    required String phone,
    required String clinicName,
    required String address,
    required String accessToken,
    required String refreshToken,
  }) async {
    final prefs = await _prefs;

    await prefs.setString(_keyUserId, userId);
    await prefs.setString(_keyEmail, email);
    await prefs.setString(_keyUserRole, role);
    await prefs.setBool(_keyIsActive, isActive);
    await prefs.setString(_keyName, name);
    await prefs.setString(_keyPhone, phone);
    await prefs.setString(_keyClinicName, clinicName);
    await prefs.setString(_keyAddress, address);

    await prefs.setString(_keyAccessToken, accessToken);
    await prefs.setString(_keyRefreshToken, refreshToken);
  }

  static Future<String?> getUserId() async {
    final prefs = await _prefs;
    return prefs.getString(_keyUserId);
  }

  static Future<String?> getEmail() async {
    final prefs = await _prefs;
    return prefs.getString(_keyEmail);
  }

  static Future<String?> getUserRole() async {
    final prefs = await _prefs;
    return prefs.getString(_keyUserRole);
  }

  static Future<bool?> getIsActive() async {
    final prefs = await _prefs;
    return prefs.getBool(_keyIsActive);
  }

  static Future<String?> getName() async {
    final prefs = await _prefs;
    return prefs.getString(_keyName);
  }

  static Future<String?> getPhone() async {
    final prefs = await _prefs;
    return prefs.getString(_keyPhone);
  }

  static Future<String?> getClinicName() async {
    final prefs = await _prefs;
    return prefs.getString(_keyClinicName);
  }

  static Future<String?> getAddress() async {
    final prefs = await _prefs;
    return prefs.getString(_keyAddress);
  }

  static Future<String?> getAccessToken() async {
    final prefs = await _prefs;
    return prefs.getString(_keyAccessToken);
  }

  static Future<String?> getRefreshToken() async {
    final prefs = await _prefs;
    return prefs.getString(_keyRefreshToken);
  }

  static Future<bool> isLoggedIn() async {
    final accessToken = await getAccessToken();
    return accessToken != null && accessToken.isNotEmpty;
  }

  static Future<void> clearUserDetails() async {
    final prefs = await _prefs;

    await prefs.remove(_keyUserId);
    await prefs.remove(_keyEmail);
    await prefs.remove(_keyUserRole);
    await prefs.remove(_keyIsActive);
    await prefs.remove(_keyName);
    await prefs.remove(_keyPhone);
    await prefs.remove(_keyClinicName);
    await prefs.remove(_keyAddress);

    await prefs.remove(_keyAccessToken);
    await prefs.remove(_keyRefreshToken);
  }
}
