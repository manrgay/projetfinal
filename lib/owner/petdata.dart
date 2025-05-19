import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class PetFormScreen extends StatefulWidget {
  @override
  _PetFormScreenState createState() => _PetFormScreenState();
}

class _PetFormScreenState extends State<PetFormScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController ownerEmailController = TextEditingController(); // Add the owner email controller
  final TextEditingController additionalInfoController = TextEditingController(); // Controller for additional information
  File? _image;
  String? base64Image;
  String? selectedPetType; // Variable to store pet type
  final Color themeColor = Color(0xFFFF6600); // Hex color for theme

  // Function to pick and convert the image to Base64
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

  // Function to submit pet data with Base64 image
  Future<void> submitPetData() async {
    if (selectedPetType == null || nameController.text.isEmpty || ageController.text.isEmpty || ownerEmailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('กรุณากรอกข้อมูลให้ครบถ้วน')),
      );
      return;
    }

    final url = Uri.parse('http://10.0.2.2:3000/api/auth/pets');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'name': nameController.text,
        'type': selectedPetType, // Use the selected pet type
        'age': int.parse(ageController.text),
        'owner_email': ownerEmailController.text, // Send the owner email
        'additional_info': additionalInfoController.text, // Send additional information
        'image': base64Image ?? '', // Send the image as Base64
      }),
    );

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('บันทึกข้อมูลสัตว์เลี้ยงสำเร็จ')));
      nameController.clear();
      ageController.clear();
      ownerEmailController.clear(); // Clear owner email
      additionalInfoController.clear(); // Clear additional information
      setState(() {
        _image = null;
        base64Image = null;
        selectedPetType = null; // Reset pet type
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('เกิดข้อผิดพลาดในการบันทึกข้อมูล')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: themeColor,
        title: Text('กรอกข้อมูลสัตว์เลี้ยง'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          children: [
            // TextField for Pet Name
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'ชื่อสัตว์เลี้ยง',
                labelStyle: TextStyle(color: themeColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: themeColor),
                ),
              ),
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.next,
            ),
            SizedBox(height: 16),

            // DropdownButton for Pet Type
            DropdownButtonFormField<String>(
              value: selectedPetType,
              items: ['Dog', 'Cat'].map((String type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedPetType = value;
                });
              },
              decoration: InputDecoration(
                labelText: 'ประเภทสัตว์เลี้ยง',
                labelStyle: TextStyle(color: themeColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: themeColor),
                ),
              ),
            ),
            SizedBox(height: 16),

            // TextField for Pet Age
            TextField(
              controller: ageController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'อายุสัตว์เลี้ยง',
                labelStyle: TextStyle(color: themeColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: themeColor),
                ),
              ),
            ),
            SizedBox(height: 16),

            // TextField for Owner Email
            TextField(
              controller: ownerEmailController, // Bind to the owner email field
              decoration: InputDecoration(
                labelText: 'อีเมลเจ้าของ',
                labelStyle: TextStyle(color: themeColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: themeColor),
                ),
              ),
              keyboardType: TextInputType.emailAddress, // For email input
            ),
            SizedBox(height: 16),

            // TextField for Additional Information
            TextField(
              controller: additionalInfoController,
              decoration: InputDecoration(
                labelText: 'ข้อมูลเพิ่มเติม',
                labelStyle: TextStyle(color: themeColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: themeColor),
                ),
              ),
              maxLines: 4,
              keyboardType: TextInputType.text,
            ),
            SizedBox(height: 16),

            // Display Image or Text if no image selected
            _image != null
                ? Image.file(_image!, height: 150, width: 150, fit: BoxFit.cover)
                : Text(
              'ยังไม่มีรูปภาพ',
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 16),

            // Button to pick Image
            ElevatedButton.icon(
              icon: Icon(Icons.image),
              label: Text('เลือกรูปภาพ'),
              onPressed: pickImage,
              style: ElevatedButton.styleFrom(
                backgroundColor: themeColor,
                padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                textStyle: TextStyle(fontSize: 16),
              ),
            ),
            SizedBox(height: 24),

            // Submit Button
            ElevatedButton(
              onPressed: submitPetData,
              child: Text('บันทึกข้อมูล'),
              style: ElevatedButton.styleFrom(
                backgroundColor: themeColor,
                padding: EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
                textStyle: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
