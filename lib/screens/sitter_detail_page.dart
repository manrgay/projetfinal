import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SitterDetailPage extends StatelessWidget {
  final String name;
  final String location;
  final double distance;
  final double price;
  final String imageAsset;

  const SitterDetailPage({
    Key? key,
    required this.name,
    required this.location,
    required this.distance,
    required this.price,
    required this.imageAsset,
  }) : super(key: key);

  void _openGoogleMaps(String query) async {
    final Uri url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not open Google Maps';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage(imageAsset),
              ),
            ),
            const SizedBox(height: 16),
            Text('ชื่อ: $name', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => _openGoogleMaps(location),
              child: Text(
                '📍 ที่อยู่: $location',
                style: const TextStyle(fontSize: 16, color: Colors.blue, decoration: TextDecoration.underline),
              ),
            ),
            const SizedBox(height: 8),
            Text('ระยะทาง: ${distance.toStringAsFixed(1)} กม.', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text('ค่าบริการ: ${price.toStringAsFixed(0)} บาท', style: const TextStyle(fontSize: 16)),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.calendar_today),
                  label: const Text('จอง'),
                ),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.phone),
                  label: const Text('ติดต่อ'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
