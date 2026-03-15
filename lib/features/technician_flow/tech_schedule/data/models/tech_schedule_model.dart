class TechScheduleModel {
  final int? dayOfWeek;
  final String fromTime;
  final String toTime;

  TechScheduleModel({
    this.dayOfWeek,
    required this.fromTime,
    required this.toTime,
  });

  factory TechScheduleModel.fromJson(Map<String, dynamic> json) {
    return TechScheduleModel(
      dayOfWeek: json['dayOfWeek'],
      fromTime: json['fromTime'],
      toTime: json['toTime'],
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'fromTime': fromTime,
      'toTime': toTime,
    };
    if (dayOfWeek != null) {
      map['dayOfWeek'] = dayOfWeek;
    }
    return map;
  }
}
