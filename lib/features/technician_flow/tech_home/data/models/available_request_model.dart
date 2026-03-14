class AvailableRequestModel {
  final int requestId;
  final String? clientName;
  final String? clientImage;
  final String? day;
  final String? clientTimeInterval;
  final String? serviceType;
  final String? description;
  final List<String> serviceImages;
  final String? governorate;
  final String? city;
  final String? street;
  final String? specialSign;

  AvailableRequestModel({
    required this.requestId,
    this.clientName,
    this.clientImage,
    this.day,
    this.clientTimeInterval,
    this.serviceType,
    this.description,
    this.serviceImages = const [],
    this.governorate,
    this.city,
    this.street,
    this.specialSign,
  });

  factory AvailableRequestModel.fromJson(Map<String, dynamic> json) {
    return AvailableRequestModel(
      requestId: json['requestId'] ?? 0,
      clientName: json['clientName'],
      clientImage: json['clientImage'],
      day: _formatArabicDate(json['day']),
      clientTimeInterval: json['clientTimeInterval'],
      serviceType: json['serviceType'],
      description: json['description'],
      serviceImages: json['serviceImages'] != null
          ? List<String>.from(json['serviceImages'])
          : [],
      governorate: json['governorate'],
      city: json['city'],
      street: json['street'],
      specialSign: json['specialSign'],
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
