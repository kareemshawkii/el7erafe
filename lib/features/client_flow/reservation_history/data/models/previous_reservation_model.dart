class PreviousReservationModel {
  final String? techName;
  final String? techImage;
  final String? serviceType;
  final int? fees;
  final String? techTimeInterval;
  final String? day;
  final bool? isCancelled;

  PreviousReservationModel({
    this.techName,
    this.techImage,
    this.serviceType,
    this.fees,
    this.techTimeInterval,
    this.day,
    this.isCancelled,
  });

  factory PreviousReservationModel.fromJson(Map<String, dynamic> json) {
    return PreviousReservationModel(
      techName: json['techName'],
      techImage: json['techImage'],
      serviceType: json['serviceType'],
      fees: (json['fees'] as num?)?.toInt(),
      techTimeInterval: json['techTimeInterval'],
      day: json['day'],
      isCancelled: json['isCancelled'],
    );
  }
}
