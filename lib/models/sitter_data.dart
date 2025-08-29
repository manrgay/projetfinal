// models/sitter.dart
class Sitter {
  final int? id;
  final String name;
  final String address;
  final String service;
  final double price;
  final String phone;
  final String lineId;
  final String facebookLink;
  final String instagramLink;
  final String image;
  final double? latitude;
  final double? longitude;

  Sitter({
    this.id,
    required this.name,
    required this.address,
    required this.service,
    required this.price,
    required this.phone,
    required this.lineId,
    required this.facebookLink,
    required this.instagramLink,
    required this.image,
    this.latitude,
    this.longitude,
  });

  factory Sitter.fromJson(Map<String, dynamic> json) {
    final priceValue = json['price'];
    double priceDouble = 0.0;

    if (priceValue is num) {
      priceDouble = priceValue.toDouble();
    } else if (priceValue is String) {
      priceDouble = double.tryParse(priceValue) ?? 0.0;
    }

    double? latitudeValue;
    if (json['latitude'] is num) {
      latitudeValue = (json['latitude'] as num).toDouble();
    } else if (json['latitude'] is String) {
      latitudeValue = double.tryParse(json['latitude']) ?? null;
    }

    double? longitudeValue;
    if (json['longitude'] is num) {
      longitudeValue = (json['longitude'] as num).toDouble();
    } else if (json['longitude'] is String) {
      longitudeValue = double.tryParse(json['longitude']) ?? null;
    }

    return Sitter(
      id: json['id'],
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      service: json['service'] ?? '',
      price: priceDouble,
      phone: json['phone'] ?? '',
      lineId: json['line_id'] ?? '',
      facebookLink: json['facebook_link'] ?? '',
      instagramLink: json['instagram_link'] ?? '',
      image: json['image'] ?? '',
      latitude: latitudeValue,
      longitude: longitudeValue,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'service': service,
      'price': price,
      'phone': phone,
      'line_id': lineId,
      'facebook_link': facebookLink,
      'instagram_link': instagramLink,
      'image': image,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
