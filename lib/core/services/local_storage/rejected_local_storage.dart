import 'package:el7erafe/core/services/models/rejected_user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RejectedLocalStorage {
  static const String _name = 'Name';
  static const String _phone = 'Phone';
  static const String _governorate = 'Governorate';
  static const String _city = 'City';
  static const String _serviceType = 'ServiceType';
  static const String _frontId = 'FrontId';
  static const String _backId = 'BackId';
  static const String _criminalRecord = 'CriminalRecord';
  static const String _rejectionReason = 'RejectionReason';

  Future<void> saveRejectedTechnician(RejectedUserModel model) async {
    final prefs = await SharedPreferences.getInstance();

    if (model.name != null) await prefs.setString(_name, model.name!);
    if (model.phone != null) await prefs.setString(_phone, model.phone!);
    if (model.governorate != null) await prefs.setString(_governorate, model.governorate!);
    if (model.city != null) await prefs.setString(_city, model.city!);
    if (model.serviceType != null) await prefs.setString(_serviceType, model.serviceType!);
    if (model.rejectionReason != null) await prefs.setString(_rejectionReason, model.rejectionReason!);
    await prefs.setBool(_frontId, model.frontId!);
    await prefs.setBool(_backId, model.backId!);
    await prefs.setBool(_criminalRecord, model.criminalRecord!);
  }

  Future<RejectedUserModel> getRejectedTechnician() async {
    final prefs = await SharedPreferences.getInstance();

    return RejectedUserModel(
      name: prefs.getString(_name),
      phone: prefs.getString(_phone),
      governorate: prefs.getString(_governorate),
      city: prefs.getString(_city),
      serviceType: prefs.getString(_serviceType),
      rejectionReason: prefs.getString(_rejectionReason),
      frontId: prefs.getBool(_frontId) ?? false,
      backId: prefs.getBool(_backId) ?? false,
      criminalRecord: prefs.getBool(_criminalRecord) ?? false,
    );
  }

  Future<void> clearRejectedTechnician() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_name);
    await prefs.remove(_phone);
    await prefs.remove(_governorate);
    await prefs.remove(_city);
    await prefs.remove(_serviceType);
    await prefs.remove(_rejectionReason);
    await prefs.remove(_frontId);
    await prefs.remove(_backId);
    await prefs.remove(_criminalRecord);
  }
}