class PendingRequestModel {
  final int requestId;
  final bool isQuickReserve;
  final int? numberOfOffers;
  final String? clientTimeInterval;
  final String? techTimeInterval;
  final String serviceType;
  final String? techName;
  final String? techImage;
  final String day;
  final int? fees;
  final int? offerId;
  final int? numberOfDays;

  PendingRequestModel({
    required this.requestId,
    required this.isQuickReserve,
    this.numberOfOffers,
    this.clientTimeInterval,
    this.techTimeInterval,
    required this.serviceType,
    this.techName,
    this.techImage,
    required this.day,
    this.fees,
    this.offerId,
    this.numberOfDays,
  });

  factory PendingRequestModel.fromJson(Map<String, dynamic> json) {
    return PendingRequestModel(
      requestId: json['requestId'] ?? 0,
      isQuickReserve: json['isQuickReserve'] ?? false,
      numberOfOffers: json['numberOfOffers'],
      clientTimeInterval: json['clientTimeInterval'],
      techTimeInterval: json['techTimeInterval'],
      serviceType: json['serviceType'] ?? '',
      techName: json['techName'],
      techImage: json['techImage'],
      day: _formatArabicDate(json['day']),
      fees: json['fees'] != null ? int.parse(json['fees'].toString()) : null,
      offerId: json['offerId'],
      numberOfDays: json['numberOfDays'],
    );
  }

  static String _formatArabicDate(dynamic rawDate) {
    if (rawDate == null || rawDate.toString().isEmpty) return '';

    try {
      DateTime parsedDate = DateTime.parse(rawDate.toString());

      const List<String> arabicDays = [
        'الاثنين',
        'الثلاثاء',
        'الأربعاء',
        'الخميس',
        'الجمعة',
        'السبت',
        'الأحد'
      ];

      String dayName = arabicDays[parsedDate.weekday - 1];

      String dd = parsedDate.day.toString().padLeft(2, '0');
      String mm = parsedDate.month.toString().padLeft(2, '0');
      String yyyy = parsedDate.year.toString();

      return '$dayName $dd-$mm-$yyyy';
    } catch (e) {
      return rawDate.toString();
    }
  }
}
