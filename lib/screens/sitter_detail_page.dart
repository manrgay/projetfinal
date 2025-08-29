import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:psoeass/screens/BookingPage.dart';
/// ==========================
/// Model & Service Review
/// ==========================
class Review {
  final int id;
  final String user;
  final int rating;
  final String comment;
  final String createdAt;


  Review({
    required this.id,
    required this.user,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      user: json['user'],
      rating: json['rating'],
      comment: json['comment'],
      createdAt: json['created_at'],
    );
  }
}

class ReviewService {
  final String baseUrl = "http://10.0.2.2:3000/api/auth";

  Future<List<Review>> fetchReviews(int sitterId) async {
    final response = await http.get(Uri.parse("$baseUrl/reviews/$sitterId"));
    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((e) => Review.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load reviews");
    }
  }

  Future<bool> addReview(int sitterId, int rating, String comment) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    if (token.isEmpty) return false;

    final response = await http.post(
      Uri.parse("$baseUrl/reviews"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "sitterId": sitterId,
        "rating": rating,
        "comment": comment,
      }),
    );
    return response.statusCode == 200 || response.statusCode == 201;
  }

  Future<bool> deleteReview(int reviewId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    if (token.isEmpty) return false;

    final response = await http.delete(
      Uri.parse("$baseUrl/reviews/$reviewId"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );
    return response.statusCode == 200;
  }
}

/// ==========================
/// ReviewTab Widget
/// ==========================
class ReviewTab extends StatefulWidget {
  final int sitterId;
  const ReviewTab({super.key, required this.sitterId});

  @override
  State<ReviewTab> createState() => _ReviewTabState();
}

class _ReviewTabState extends State<ReviewTab> {
  final ReviewService _reviewService = ReviewService();
  List<Review> _reviews = [];
  bool _loading = true;
  final TextEditingController _commentController = TextEditingController();
  int _rating = 5;
  String currentUser = "";

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _loadReviews();
  }

  Future<void> _loadCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    if (token.isNotEmpty) {
      final payload = jsonDecode(
          utf8.decode(base64Decode(base64.normalize(token.split(".")[1]))));
      setState(() {
        currentUser = payload['firstName'];
      });
    }
  }

  Future<void> _loadReviews() async {
    try {
      final reviews = await _reviewService.fetchReviews(widget.sitterId);
      setState(() {
        _reviews = reviews;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  Future<void> _submitReview() async {
    if (_commentController.text.isEmpty) return;

    bool success = await _reviewService.addReview(
      widget.sitterId,
      _rating,
      _commentController.text,
    );

    if (success) {
      _commentController.clear();
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("รีวิวสำเร็จ")));
      _loadReviews();
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("เกิดข้อผิดพลาด")));
    }
  }

  Future<void> _deleteReview(int reviewId) async {
    bool success = await _reviewService.deleteReview(reviewId);
    if (success) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("ลบรีวิวสำเร็จ")));
      _loadReviews();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("ไม่สามารถลบรีวิวนี้ได้")));
    }
  }

  Widget _buildStarRating(int rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        return Icon(
          i < rating ? Icons.star : Icons.star_border,
          color: Colors.orange,
          size: 18,
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _reviews.isEmpty
              ? const Center(child: Text("ยังไม่มีรีวิว"))
              : ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: _reviews.length,
            itemBuilder: (context, index) {
              final r = _reviews[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            r.user,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                          ),
                          Text(
                            r.createdAt.split(" ")[0],
                            style: TextStyle(
                                color: Colors.grey[600], fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      _buildStarRating(r.rating),
                      const SizedBox(height: 6),
                      Text(
                        r.comment,
                        style: const TextStyle(fontSize: 14),
                      ),
                      if (r.user == currentUser)
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: () => _deleteReview(r.id),
                            icon: const Icon(Icons.delete,
                                color: Colors.red, size: 18),
                            label: const Text(
                              "ลบ",
                              style: TextStyle(
                                  color: Colors.red, fontSize: 12),
                            ),
                            style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(40, 20),
                                tapTargetSize:
                                MaterialTapTargetSize.shrinkWrap),
                          ),
                        )
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Container(
          color: Colors.grey[100],
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Column(
            children: [
              Row(
                children: [
                  const Text("Rating:"),
                  const SizedBox(width: 8),
                  DropdownButton<int>(
                    value: _rating,
                    items: List.generate(5, (i) => i + 1)
                        .map(
                          (e) => DropdownMenuItem(
                        value: e,
                        child: Row(
                          children: List.generate(
                            e,
                                (index) => const Icon(Icons.star,
                                color: Colors.orange, size: 16),
                          ),
                        ),
                      ),
                    )
                        .toList(),
                    onChanged: (v) => setState(() => _rating = v!),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _commentController,
                decoration: InputDecoration(
                  hintText: "พิมพ์รีวิวของคุณ...",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  fillColor: Colors.white,
                  filled: true,
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 6),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitReview,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text("ส่งรีวิว"),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// ==========================
/// SitterDetailPage
/// ==========================
class SitterDetailPage extends StatelessWidget {
  final int sitterId;
  final String name;
  final String address;
  final String service;
  final double price;
  final String phone;
  final String lineId;
  final String facebookLink;
  final String instagramLink;
  final String imageAsset;
  final String userEmail;
  const SitterDetailPage({
    super.key,
    required this.sitterId,
    required this.name,
    required this.address,
    required this.service,
    required this.price,
    required this.phone,
    required this.lineId,
    required this.facebookLink,
    required this.instagramLink,
    required this.imageAsset,
    required this.userEmail,
  });

  void _openGoogleMaps(String query) async {
    final Uri url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(query)}',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFFF6600);

    Widget buildImage(double width, double height, {BoxFit fit = BoxFit.cover}) {
      if (imageAsset.isNotEmpty) {
        try {
          return ClipRRect(
            borderRadius: BorderRadius.circular(90),
            child: Image.memory(
              base64Decode(imageAsset),
              width: width,
              height: height,
              fit: fit,
            ),
          );
        } catch (_) {
          return Container(
            width: width,
            height: height,
            color: Colors.grey[300],
            child: const Icon(Icons.pets, size: 60, color: Colors.grey),
          );
        }
      } else {
        return Container(
          width: width,
          height: height,
          color: Colors.grey[300],
          child: const Icon(Icons.pets, size: 60, color: Colors.grey),
        );
      }
    }

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: primaryColor,
          title: Text(name),
          centerTitle: true,
          elevation: 3,
          bottom: const TabBar(
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: "ข้อมูลร้าน"),
              Tab(text: "บริการ & ราคา"),
              Tab(text: "รีวิว"),
              Tab(text: "รูปภาพ"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // ข้อมูลร้าน
            SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  buildImage(130, 130),
                  const SizedBox(height: 20),
                  Text(name,
                      style: const TextStyle(
                          fontSize: 30, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () => _openGoogleMaps(address),
                    icon: const Icon(Icons.location_on, color: primaryColor),
                    label: Flexible(
                      child: Text(
                        address,
                        style: const TextStyle(
                            fontSize: 16,
                            color: primaryColor,
                            decoration: TextDecoration.underline),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 5,
                    shadowColor: Colors.orange.withOpacity(0.3),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 24, horizontal: 28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InfoRow(
                              label: 'เบอร์โทรศัพท์',
                              value: phone,
                              icon: Icons.phone),
                          const SizedBox(height: 18),
                          InfoRow(label: 'LINE ID', value: lineId, icon: Icons.message),
                          if (facebookLink.isNotEmpty) ...[
                            const SizedBox(height: 18),
                            InfoRow(
                                label: 'Facebook',
                                value: facebookLink,
                                icon: Icons.facebook),
                          ],
                          if (instagramLink.isNotEmpty) ...[
                            const SizedBox(height: 18),
                            InfoRow(
                                label: 'Instagram',
                                value: instagramLink,
                                icon: Icons.camera_alt),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // บริการ & ราคา
            SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 5,
                    shadowColor: Colors.orange.withOpacity(0.3),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 24, horizontal: 28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InfoRow(
                              label: 'บริการ',
                              value: service,
                              icon: Icons.room_service),
                          const SizedBox(height: 18),
                          InfoRow(
                              label: 'ค่าบริการ',
                              value: '${price.toStringAsFixed(0)} บาท',
                              icon: Icons.attach_money),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BookingPage(
                              name: name,
                              address: address,
                              service: service,
                              price: price,
                              sitterId: sitterId, // <-- แก้ตรงนี้จาก sitter.id เป็น sitterId
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      icon: const Icon(Icons.calendar_month, color: Colors.white),
                      label: const Text(
                        "จองบริการ",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // รีวิว
            ReviewTab(sitterId: sitterId),
            // รูปภาพ
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: imageAsset.isNotEmpty
                      ? Image.memory(base64Decode(imageAsset),
                      fit: BoxFit.contain,
                      width: double.infinity,
                      height: 300)
                      : Container(
                      width: double.infinity,
                      height: 300,
                      color: Colors.grey[300],
                      child: const Icon(Icons.pets,
                          size: 60, color: Colors.grey)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// InfoRow Widget
class InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const InfoRow(
      {super.key, required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[700]),
        const SizedBox(width: 14),
        Expanded(
            flex: 3,
            child: Text(label,
                style: const TextStyle(
                    fontSize: 17, fontWeight: FontWeight.w500))),
        Expanded(
            flex: 4,
            child: Text(value,
                style: const TextStyle(
                    fontSize: 17, fontWeight: FontWeight.bold),
                softWrap: true,
                maxLines: null)),
      ],
    );
  }
}