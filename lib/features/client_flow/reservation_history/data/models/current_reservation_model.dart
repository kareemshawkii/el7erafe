class CurrentReservationModel {
  final int reservationId;
  final String type;
  final String? techName;
  final String? techImage;
  final String? serviceType;
  final int? fees;
  final String? techTimeInterval;
  final String? day;

  CurrentReservationModel({
    required this.reservationId,
    required this.type,
    this.techName,
    this.techImage,
    this.serviceType,
    this.fees,
    this.techTimeInterval,
    this.day,
  });

  factory CurrentReservationModel.fromJson(Map<String, dynamic> json) {
    return CurrentReservationModel(
      reservationId: json['reservationId'] ?? 0,
      type: json['type'] ?? 'غير معروف',
      techName: json['techName'],
      techImage: json['techImage'],
      serviceType: json['serviceType'],
      fees: (json['fees'] as num?)?.toInt(),
      techTimeInterval: json['techTimeInterval'],
      day: json['day'],
    );
  }

  CurrentReservationModel copyWith({
    int? reservationId,
    String? type,
    String? techName,
    String? techImage,
    String? serviceType,
    int? fees,
    String? techTimeInterval,
    String? day,
  }) {
    return CurrentReservationModel(
      reservationId: reservationId ?? this.reservationId,
      type: type ?? this.type,
      techName: techName ?? this.techName,
      techImage: techImage ?? this.techImage,
      serviceType: serviceType ?? this.serviceType,
      fees: fees ?? this.fees,
      techTimeInterval: techTimeInterval ?? this.techTimeInterval,
      day: day ?? this.day,
    );
  }
}
