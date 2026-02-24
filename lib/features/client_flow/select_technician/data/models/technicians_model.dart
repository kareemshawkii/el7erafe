class TechniciansModel {
  final String id;
  final String name;
  final String serviceName;
  final double rating;
  final String city;
  final String about;
  final String profilePicture;
  final List<String> portfolioImages;

  TechniciansModel({
    required this.id,
    required this.name,
    required this.serviceName,
    required this.rating,
    required this.city,
    required this.about,
    required this.profilePicture,
    required this.portfolioImages,
  });

  factory TechniciansModel.fromJson(Map<String, dynamic> json) {
    return TechniciansModel(
      id: json['id']?.toString() ?? '', 
      name: json['name'] ?? 'اسم غير متوفر',
      serviceName: json['serviceName'] ?? '', 
      rating: (json['rating'] ?? 0.0).toDouble(), 
      city: json['city'] ?? '',
      about: json['about'] ?? '', 
      profilePicture: json['profilePicture'] ?? '', 
      portfolioImages: json['portfolioImages'] != null
          ? List<String>.from(json['portfolioImages'])
          : [], 
    );
  }
}