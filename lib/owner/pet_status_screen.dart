import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pet_provider.dart';

class PetStatusExampleScreen extends StatefulWidget {
  const PetStatusExampleScreen({super.key});

  @override
  State<PetStatusExampleScreen> createState() => _PetStatusExampleScreenState();
}

class _PetStatusExampleScreenState extends State<PetStatusExampleScreen> {
  String userEmail = '';

  @override
  void initState() {
    super.initState();
    _loadUserEmail();
  }

  Future<void> _loadUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userEmail = prefs.getString('email') ?? '';
    });
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'กำลังอยู่ในความดูแล':
        return Colors.deepOrange;
      case 'รอรับกลับ':
        return Colors.orange;
      case 'เสร็จสิ้น':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData getStatusIcon(String status) {
    switch (status) {
      case 'กำลังอยู่ในความดูแล':
      case 'รอรับกลับ':
        return Icons.pets;
      case 'เสร็จสิ้น':
        return Icons.check_circle_outline;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final petProvider = context.watch<PetProvider>();

    // กรองเฉพาะสัตว์เลี้ยงของผู้ใช้งานที่ล็อกอินอยู่
    final filteredPets = petProvider.pets
        .where((pet) => pet['ownerEmail'] == userEmail)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('สัตว์ที่กำลังฝากเลี้ยง'),
        backgroundColor: Colors.orange.shade400,
      ),
      body: filteredPets.isEmpty
          ? const Center(child: Text('ไม่มีสัตว์ที่กำลังฝากเลี้ยง'))
          : ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: filteredPets.length,
        itemBuilder: (context, index) {
          final pet = filteredPets[index];
          final status = pet['status'] ?? 'ไม่ระบุ';
          final store = pet['store'] ?? '-';
          final startDate = pet['startDate'] ?? '-';
          final returnDate = pet['returnDate'] ?? '-';
          final ownerEmail = pet['ownerEmail'] ?? '-';

          // แปลงรูปภาพ Base64
          String? imageBase64;
          final img = pet['image'];
          if (img != null) {
            if (img is String) {
              imageBase64 = img;
            } else if (img is List<int>) {
              imageBase64 = base64Encode(img);
            } else if (img is Map && img['data'] != null) {
              imageBase64 = img['data'];
            }
          }

          Widget leadingWidget;
          if (imageBase64 != null && imageBase64.isNotEmpty) {
            leadingWidget = ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.memory(
                base64Decode(imageBase64),
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              ),
            );
          } else {
            leadingWidget = Icon(
              getStatusIcon(status),
              color: getStatusColor(status),
              size: 36,
            );
          }

          return Card(
            margin:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            elevation: 2,
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: leadingWidget,
              title: Text(
                pet['name'] ?? 'ไม่มีชื่อ',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'สถานะ: $status',
                    style: TextStyle(
                      color: getStatusColor(status),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text('เจ้าของ: $ownerEmail'),
                  Text('ร้านรับเลี้ยง: $store'),
                  Text('ฝากเลี้ยงวันที่: $startDate'),
                  Text('รับกลับวันที่: $returnDate'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
