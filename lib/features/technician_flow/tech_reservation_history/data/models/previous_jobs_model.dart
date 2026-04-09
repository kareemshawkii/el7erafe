class PreviousJobsModel {
  final bool? isCancelled;
  final String? clientName;
  final String? clientImage;
  final String? serviceType;
  final int? fees;
  final String? day;
  final String? techTimeInterval;

  PreviousJobsModel({
    this.isCancelled,
    this.clientName,
    this.clientImage,
    this.serviceType,
    this.fees,
    this.day,
    this.techTimeInterval,
  });

  factory PreviousJobsModel.fromJson(Map<String, dynamic> json) {
    return PreviousJobsModel(
      isCancelled: json['isCancelled'],
      clientName: json['clientName'],
      clientImage: json['clientImage'],
      serviceType: json['serviceType'],
      fees: json['fees'] != null 
          ? double.tryParse(json['fees'].toString())?.toInt() 
          : null,
      day: json['day'],
      techTimeInterval: json['techTimeInterval'],
    );
  }
}
