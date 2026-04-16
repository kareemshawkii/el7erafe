import 'package:el7erafe/core/services/signal_r/signal_r_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:el7erafe/core/services/models/user.dart'
    show TempTechnician, User;

class AuthLocalStorage {
  final _storage = const FlutterSecureStorage();

  static const String _tokenKey = "token";
  static const String _userNameKey = "userName";
  static const String _userIdKey = "userId";
  static const String _tempTokenKey = "tempToken";
  static const String _typeKey = "type";
  static const String _emailKey = "email";
  static const String _userProfileImage = "userImage";
  static const String _phoneNumberKey = "phoneNumber";
  static const String _resetTempToken = "resetTempToken";
  static const String _technicianEmail = "technicianEmail";

  Future<void> saveUserSession(User user) async {
    if (user.token != null) {
      await _storage.write(key: _tokenKey, value: user.token!);
    } else {
      await _storage.delete(key: _tokenKey);
    }

    if (user.name != null) {
      await _storage.write(key: _userNameKey, value: user.name!);
    } else {
      await _storage.delete(key: _userNameKey);
    }

    if (user.id != null) {
      await _storage.write(key: _userIdKey, value: user.id.toString());
    } else {
      await _storage.delete(key: _userIdKey);
    }

    if (user.type != null) {
      await _storage.write(key: _typeKey, value: user.type!);
    } else {
      await _storage.delete(key: _typeKey);
    }
  }

  Future<void> saveUserName(String name) async {
    await _storage.write(key: _userNameKey, value: name);
  }

  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }

  Future<void> savePhoneNumber(String phoneNumber) async {
    await _storage.write(key: _phoneNumberKey, value: phoneNumber);
  }

  Future<String?> getPhoneNumber() async {
    return await _storage.read(key: _phoneNumberKey);
  }

  Future<void> saveUserProfileImage(String image) async {
    await _storage.write(key: _userProfileImage, value: image);
  }

  Future<String?> getUserProfileImage() async {
    return await _storage.read(key: _userProfileImage);
  }

  Future<void> deleteUserProfileImage() async {
    await _storage.delete(key: _userProfileImage);
  }

  Future<void> saveTempToken(TempTechnician temptech) async {
    if (temptech.tempToken != null) {
      await _storage.write(key: _tempTokenKey, value: temptech.tempToken!);
    } else {
      await _storage.delete(key: _tempTokenKey);
    }
  }

  Future<void> saveResetTempToken(String tempToken) async {
    await _storage.write(key: _resetTempToken, value: tempToken);
  }

  Future<void> saveEmail(String email) async {
    await _storage.write(key: _emailKey, value: email);
  }

  Future<void> saveTechnicianEmail(String email) async {
    await _storage.write(key: _technicianEmail, value: email);
  }

  Future<String?> getTechnicianEmail() async {
    return await _storage.read(key: _technicianEmail);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<String?> getResetTempToken() async {
    return await _storage.read(key: _resetTempToken);
  }

  Future<String?> getUserName() async {
    return await _storage.read(key: _userNameKey);
  }

  Future<String?> getUserId() async {
    return await _storage.read(key: _userIdKey);
  }

  Future<String?> getTempToken() async {
    return await _storage.read(key: _tempTokenKey);
  }

  Future<String?> getUserType() async {
    return await _storage.read(key: _typeKey);
  }

  Future<String?> getEmail() async {
    return await _storage.read(key: _emailKey);
  }

  Future<void> deleteTempToken() async {
    await _storage.delete(key: _tempTokenKey);
  }

  Future<void> deleteResetTempToken() async {
    await _storage.delete(key: _resetTempToken);
  }

  Future<void> deleteEmail() async {
    await _storage.delete(key: _emailKey);
  }

  Future<void> deleteUserName() async {
    await _storage.delete(key: _userNameKey);
  }

  Future<void> deleteTechnicianEmail() async {
    await _storage.delete(key: _technicianEmail);
  }

  Future<void> clearSession() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userNameKey);
    await _storage.delete(key: _userIdKey);
    await _storage.delete(key: _tempTokenKey);
    await _storage.delete(key: _typeKey);
    await _storage.delete(key: _emailKey);
    await _storage.delete(key: _phoneNumberKey);
    await _storage.delete(key: _userProfileImage);
    SignalRService.instance.disconnect();
  }
}
