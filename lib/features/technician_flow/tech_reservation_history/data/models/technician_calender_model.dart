class TechReservationModel {
  final int reservationId;
  final String? clientName;
  final String? clientImage;
  final String? description;
  final String? techTimeInterval;
  final String? day;
  final List<String>? serviceImages;
  final String? governorate;
  final String? city;
  final String? street;
  final String? specialSign;
  final String? serviceType;

  TechReservationModel({
    required this.reservationId,
    this.clientName,
    this.clientImage,
    this.description,
    this.techTimeInterval,
    this.day,
    this.serviceImages,
    this.governorate,
    this.city,
    this.street,
    this.specialSign,
    this.serviceType,
  });

  factory TechReservationModel.fromJson(Map<String, dynamic> json) {
    return TechReservationModel(
      reservationId: (json['reservationId'] as num?)?.toInt() ?? 0,
      clientName: json['clientName']?.toString(),
      clientImage: json['clientImage']?.toString(),
      description: json['description']?.toString(),
      techTimeInterval: json['techTimeInterval']?.toString(),
      day: json['day']?.toString(),
      serviceImages: (json['serviceImages'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      governorate: json['governorate']?.toString(),
      city: json['city']?.toString(),
      street: json['street']?.toString(),
      specialSign: json['specialSign']?.toString(),
      serviceType: json['serviceType']?.toString(),
    );
  }
}
