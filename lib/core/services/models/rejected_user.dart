class RejectedUser {
  final String? name;
  final String? phone;
  final String? governorate;
  final String? city;
  final String? serviceType;
  final bool? frontId;
  final bool? backId;
  final bool? criminalRecord;
  final String? rejectionReason;

  RejectedUser({this.name, this.phone, this.governorate, this.city, this.serviceType, this.frontId, this.backId, this.criminalRecord, this.rejectionReason});
}

class RejectedUserModel extends RejectedUser {
  RejectedUserModel({super.name, super.phone, super.governorate, super.city, super.serviceType, super.frontId, super.backId, super.criminalRecord, super.rejectionReason});

  factory RejectedUserModel.fromJson(Map<String, dynamic> json) {
  final data = json['data'] ?? {};

  return RejectedUserModel(
    name: data['name'],
    phone: data['phone'],
    governorate: data['governorate'],
    city: data['city'],
    serviceType: data['serviceType'],
    frontId: data['frontId'],
    backId: data['backId'],
    criminalRecord: data['criminalRecord'],
    rejectionReason: json['rejectionReason'], 
  );
}
}

extension RejectedUserHelpers on RejectedUser {
  List<String> get missingFiles {
    final List<String> files = [];

    if (frontId == true) files.add("NationalIdFront");
    if (backId == true) files.add("NationalIdBack");
    if (criminalRecord == true) files.add("CriminalRecord");

    return files;
  }
  bool get needsResubmission =>
      frontId == true || backId == true || criminalRecord == true;
}