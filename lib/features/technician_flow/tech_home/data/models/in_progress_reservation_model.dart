class InProgressReservationModel {
  final int reservationId;
  final String? clientName;
  final String? clientImage;
  final String? day;
  final String? techTimeInterval;
  final String? description;
  final int fees;

  InProgressReservationModel({
    required this.reservationId,
    this.clientName,
    this.clientImage,
    this.day,
    this.techTimeInterval,
    this.description,
    required this.fees,
  });

  factory InProgressReservationModel.fromJson(Map<String, dynamic> json) {
    return InProgressReservationModel(
      reservationId: (json['reservationId'] as num?)?.toInt() ?? 0,
      clientName: json['clientName']?.toString(),
      clientImage: json['clientImage']?.toString(),
      day: json['day']?.toString(),
      techTimeInterval: json['techTimeInterval']?.toString(),
      description: json['description']?.toString(),
      fees: (json['fees'] as num?)?.toInt() ?? 0,
    );
  }
}