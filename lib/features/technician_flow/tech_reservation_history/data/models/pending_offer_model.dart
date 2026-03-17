class PendingOfferModel {
  final int offerId;
  final String? description;
  final String? clientName;
  final String? clientImage;
  final num fees;
  final String? serviceType;
  final String? techTimeInterval;
  final String day;
  final String? endDay;
  final List<String>? serviceImages;
  final String? governorate;
  final String? city;
  final String? street;
  final String? specialSign;

  PendingOfferModel({
    required this.offerId,
    this.description,
    this.clientName,
    this.clientImage,
    required this.fees,
    this.serviceType,
    this.techTimeInterval,
    required this.day,
    this.endDay,
    this.serviceImages,
    this.governorate,
    this.city,
    this.street,
    this.specialSign,
  });

  factory PendingOfferModel.fromJson(Map<String, dynamic> json) {
    return PendingOfferModel(
      offerId: (json['offerId'] as num?)?.toInt() ?? 0,
      description: json['description']?.toString(),
      clientName: json['clientName']?.toString(),
      clientImage: json['clientImage']?.toString(),
      fees: (json['fees'] as num?)?.toInt() ?? 0,
      serviceType: json['serviceType']?.toString(),
      techTimeInterval: json['techTimeInterval']?.toString(),
      day: json['day']?.toString() ?? '',
      endDay: json['endDay']?.toString(),
      serviceImages: (json['serviceImages'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      governorate: json['governorate']?.toString(),
      city: json['city']?.toString(),
      street: json['street']?.toString(),
      specialSign: json['specialSign']?.toString(),
    );
  }
}