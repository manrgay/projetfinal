import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class MyPetsScreen extends StatefulWidget {
  final String userEmail;
  const MyPetsScreen({super.key, required this.userEmail});

  @override
  State<MyPetsScreen> createState() => _MyPetsScreenState();
}

class _MyPetsScreenState extends State<MyPetsScreen> {
  late Future<List<Pet>> _petsFuture;
  final Color themeColor = const Color(0xFFFF6600);

  @override
  void initState() {
    super.initState();
    _petsFuture = fetchPets();
  }

  Future<List<Pet>> fetchPets() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) throw Exception('Token ไม่ถูกต้องหรือหมดอายุ');

    final url = Uri.parse('http://10.0.2.2:3000/api/auth/get-pets');
    final response = await http.get(url, headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      final filtered = jsonList
          .where((jsonItem) => jsonItem['owner_email'] == widget.userEmail)
          .toList();
      return filtered.map((jsonItem) => Pet.fromJson(jsonItem)).toList();
    } else if (response.statusCode == 401) {
      throw Exception('Token หมดอายุหรือไม่ถูกต้อง');
    } else {
      throw Exception(
          'ไม่สามารถโหลดข้อมูลสัตว์เลี้ยงได้ (status: ${response.statusCode})');
    }
  }

  Future<void> deletePet(int petId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Token ไม่ถูกต้องหรือหมดอายุ')));
      return;
    }

    final url = Uri.parse('http://10.0.2.2:3000/api/auth/pets/$petId');
    final response = await http.delete(url, headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ลบข้อมูลสัตว์เลี้ยงเรียบร้อย')));
      setState(() {
        _petsFuture = fetchPets();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ไม่สามารถลบข้อมูลสัตว์เลี้ยงได้')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E0),
      appBar: AppBar(
        title: const Text(
          'รายการสัตว์เลี้ยงของฉัน',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: themeColor,
        elevation: 4,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              setState(() {
                _petsFuture = fetchPets();
              });
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Pet>>(
        future: _petsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'เกิดข้อผิดพลาด: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('ไม่มีข้อมูลสัตว์เลี้ยง'));
          }

          final pets = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: pets.length,
            itemBuilder: (context, index) {
              final pet = pets[index];
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 5,
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // รูปสัตว์เลี้ยง
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: themeColor,
                          borderRadius: BorderRadius.circular(12),
                          image: pet.image != null && pet.image!.isNotEmpty
                              ? DecorationImage(
                            image: MemoryImage(base64Decode(pet.image!)),
                            fit: BoxFit.cover,
                          )
                              : null,
                        ),
                        child: pet.image == null || pet.image!.isEmpty
                            ? const Center(
                          child: Icon(Icons.pets, color: Colors.white, size: 40),
                        )
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ชื่อสัตว์เลี้ยง: ${pet.name}',
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text('ประเภทสัตว์เลี้ยง: ${pet.type}'),
                            Text('อายุสัตว์เลี้ยง: ${pet.age} ${pet.ageUnit}'),
                            Text('อีเมลเจ้าของ: ${pet.ownerEmail}'),
                            Text('ข้อมูลเพิ่มเติม: ${pet.additionalInfo ?? '-'}'),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('ยืนยันการลบ'),
                              content: Text(
                                  'คุณต้องการลบสัตว์เลี้ยง ${pet.name} ใช่หรือไม่?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  child: const Text('ยกเลิก'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(ctx);
                                    deletePet(pet.id!);
                                  },
                                  child: const Text('ลบ', style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class Pet {
  final int id;
  final String name;
  final String type;
  final int age;
  final String ageUnit;
  final String ownerEmail;
  final String? additionalInfo;
  final String? image;

  Pet({
    required this.id,
    required this.name,
    required this.type,
    required this.age,
    required this.ageUnit,
    required this.ownerEmail,
    this.additionalInfo,
    this.image,
  });

  factory Pet.fromJson(Map<String, dynamic> json) {
    return Pet(
      id: json['id'] ?? 0,
      name: json['name']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      age: json['age'] ?? 0,
      ageUnit: json['age_unit']?.toString() ?? 'ขวบ',
      ownerEmail: json['owner_email']?.toString() ?? '',
      additionalInfo: json['additional_info']?.toString(),
      image: json['image']?.toString(),
    );
  }
}
