class OfferModel {
  final int offerId;
  final int requestId;
  final String techName;
  final String? techImage;
  final String serviceType;
  final int fees;
  final String techTimeInterval;
  final String day;
  final num rate;
  final int? numberOfDays;

  OfferModel({
    required this.offerId,
    required this.requestId,
    required this.techName,
    this.techImage,
    required this.serviceType,
    required this.fees,
    required this.techTimeInterval,
    required this.day,
    required this.rate,
    this.numberOfDays,
  });

  factory OfferModel.fromJson(Map<String, dynamic> json) {
    return OfferModel(
      offerId: (json['offerId'] as num?)?.toInt() ?? 0,
      requestId: (json['requestId'] as num?)?.toInt() ?? 0,
      techName: json['techName']?.toString() ?? '',
      techImage: json['techImage']?.toString(),
      serviceType: json['serviceType']?.toString() ?? '',
      fees: (json['fees'] as num?)?.toInt() ?? 0,
      techTimeInterval: json['techTimeInterval']?.toString() ?? '',
      day: json['day']?.toString() ?? '',
      rate: json['rate'] as num? ?? 0.0,
      numberOfDays: (json['numberOfDays'] as num?)?.toInt(),
    );
  }
}