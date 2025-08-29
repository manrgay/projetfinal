import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PetFormScreen extends StatefulWidget {
  final String userEmail;
  const PetFormScreen({super.key, required this.userEmail});

  @override
  _PetFormScreenState createState() => _PetFormScreenState();
}

class _PetFormScreenState extends State<PetFormScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController additionalInfoController = TextEditingController();

  File? _image;
  String? base64Image;
  String? selectedPetType;
  String selectedAgeUnit = 'ขวบ';
  final Color themeColor = Color(0xFFFF6600);

  Future<void> pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final imageBytes = File(pickedFile.path).readAsBytesSync();
      setState(() {
        _image = File(pickedFile.path);
        base64Image = base64Encode(imageBytes);
      });
    }
  }

  Future<void> submitPetData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Token ไม่ถูกต้องหรือหมดอายุ')),
      );
      return;
    }

    if (selectedPetType == null || nameController.text.isEmpty || ageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('กรุณากรอกข้อมูลให้ครบถ้วน')),
      );
      return;
    }

    final url = Uri.parse('http://10.0.2.2:3000/api/auth/pets');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'name': nameController.text,
        'type': selectedPetType,
        'age': int.parse(ageController.text),
        'age_unit': selectedAgeUnit,
        'owner_email': widget.userEmail,
        'additional_info': additionalInfoController.text,
        'image': base64Image ?? '',
      }),
    );

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('บันทึกข้อมูลสัตว์เลี้ยงสำเร็จ')),
      );
      Navigator.pop(context, true); // ส่งค่า true กลับเพื่อ refresh list
    } else if (response.statusCode == 401) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Token หมดอายุหรือไม่ถูกต้อง')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาดในการบันทึกข้อมูล')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('กรอกข้อมูลสัตว์เลี้ยง'),
        backgroundColor: themeColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'ชื่อสัตว์เลี้ยง',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        prefixIcon: Icon(Icons.pets),
                      ),
                    ),
                    SizedBox(height: 15),
                    DropdownButtonFormField<String>(
                      value: selectedPetType,
                      items: ['Dog', 'Cat']
                          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (v) => setState(() => selectedPetType = v),
                      decoration: InputDecoration(
                        labelText: 'ประเภทสัตว์เลี้ยง',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        prefixIcon: Icon(Icons.category),
                      ),
                    ),
                    SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: ageController,
                            decoration: InputDecoration(
                              labelText: 'อายุ',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              prefixIcon: Icon(Icons.calendar_today),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          flex: 1,
                          child: DropdownButtonFormField<String>(
                            value: selectedAgeUnit,
                            items: ['ขวบ', 'เดือน']
                                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                                .toList(),
                            onChanged: (value) => setState(() => selectedAgeUnit = value!),
                            decoration: InputDecoration(
                              labelText: 'หน่วย',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 15),
                    TextField(
                      controller: additionalInfoController,
                      decoration: InputDecoration(
                        labelText: 'ข้อมูลเพิ่มเติม',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        prefixIcon: Icon(Icons.info),
                      ),
                    ),
                    SizedBox(height: 20),
                    GestureDetector(
                      onTap: pickImage,
                      child: _image != null
                          ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          _image!,
                          height: 150,
                          width: 150,
                          fit: BoxFit.cover,
                        ),
                      )
                          : Container(
                        height: 150,
                        width: 150,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.grey[300],
                        ),
                        child: Icon(
                          Icons.add_a_photo,
                          size: 50,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: submitPetData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: themeColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          'บันทึกข้อมูล',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
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
