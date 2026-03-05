class TechnicianProfileModel {
  final String name;
  final String email;
  final String phone;
  final String profileImage;
  final String? aboutMe; 
  final List<String> portfolioImages;

  TechnicianProfileModel({
    required this.name,
    required this.email,
    required this.phone,
    required this.profileImage,
    this.aboutMe,
    required this.portfolioImages,
  });

  factory TechnicianProfileModel.fromJson(Map<String, dynamic> json) {
    return TechnicianProfileModel(
      name: json['name'] ?? "",
      email: json['email'] ?? "",
      phone: json['phone'] ?? "",
      profileImage: json['profileImage'] ?? "",
      aboutMe: json['aboutMe'], 
      portfolioImages: json['portifolioImages'] != null
          ? List<String>.from(json['portifolioImages'])
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'profileImage': profileImage,
      'aboutMe': aboutMe,
      'portifolioImages': portfolioImages,
    };
  }
}