import 'dart:io';

class ReservationRequest {
  int? serviceId;
  String? serviceName; // Stored from Home Page
  String? description;
  List<File>? images;
  String? governorate;
  String? city;
  String? street;
  String? specialSign;
  DateTime? day;
  bool allDayAvailability;
  String? availableFrom; // format "HH:mm"
  String? availableTo;   // format "HH:mm"

  ReservationRequest({
    this.serviceId,
    this.serviceName,
    this.description,
    this.images,
    this.governorate,
    this.city,
    this.street,
    this.specialSign,
    this.day,
    this.allDayAvailability = true, // Default to true
    this.availableFrom,
    this.availableTo,
  });

  // Convert to FormData for the API upload
  Map<String, dynamic> toMap() {
    return {
      'service_id': serviceId,
      'description': description,
      'governorate': governorate,
      'city': city,
      'street': street,
      'special_sign': specialSign,
      'day': day?.toIso8601String(),
      'allDayAvialabilty': allDayAvailability ? 1 : 0,
      'avialable_from': availableFrom,
      'avialable_to': availableTo,
      // Images usually handled separately in MultipartRequest
    };
  }
}