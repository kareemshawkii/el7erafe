class ServiceItem {
  final int id;
  final String name;
  final String imageUrl;

  ServiceItem({
    required this.id, 
    required this.name, 
    required this.imageUrl
  });

  factory ServiceItem.fromJson(Map<String, dynamic> json) {
    return ServiceItem(
      id: json['id'],
      name: json['name'],
      imageUrl: json['imageURL'] ?? '', 
    );
  }
}