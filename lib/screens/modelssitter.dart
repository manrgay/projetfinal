class Sitter {
  final int id;   // ✅ ไม่ nullable แล้ว
  final String name;
  final String address;
  final String service;
  final double price;
  final String phone;
  final String? lineId;
  final String? facebookLink;
  final String? instagramLink;
  final String? image;

  Sitter({
    required this.id,
    required this.name,
    required this.address,
    required this.service,
    required this.price,
    required this.phone,
    this.lineId,
    this.facebookLink,
    this.instagramLink,
    this.image,
  });

  factory Sitter.fromJson(Map<String, dynamic> json) {
    return Sitter(
      id: json['id'] as int,
      name: json['name'],
      address: json['address'],
      service: json['service'],
      price: (json['price'] as num).toDouble(),
      phone: json['phone'],
      lineId: json['lineId'],
      facebookLink: json['facebookLink'],
      instagramLink: json['instagramLink'],
      image: json['image'],
    );
  }
}
