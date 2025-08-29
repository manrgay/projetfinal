import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'map_picker_page.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

class AddSitterScreen extends StatefulWidget {
  const AddSitterScreen({Key? key}) : super(key: key);

  @override
  State<AddSitterScreen> createState() => _AddSitterScreenState();
}

class _AddSitterScreenState extends State<AddSitterScreen> {
  final nameController = TextEditingController();
  final addressController = TextEditingController();
  final serviceController = TextEditingController();
  final priceController = TextEditingController();
  final phoneController = TextEditingController();
  final lineController = TextEditingController();
  final facebookController = TextEditingController();
  final instagramController = TextEditingController();
  LatLng? _selectedLatLng;
  File? _selectedImage;

  final ImagePicker _picker = ImagePicker();

  void _pickLocation() async {
    final result = await Navigator.push<LatLng>(
      context,
      MaterialPageRoute(builder: (context) => const MapPickerPage()),
    );

    if (result != null && mounted) {
      setState(() {
        _selectedLatLng = result;
      });
    }
  }

  void _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
    );

    if (pickedFile != null && mounted) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  void _saveData() async {
    if (_selectedLatLng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณาเลือกพิกัดจากแผนที่ก่อนบันทึก')),
      );
      return;
    }

    try {
      // ดึง token จาก SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('กรุณาเข้าสู่ระบบก่อนบันทึกข้อมูล')),
        );
        return;
      }

      // แปลงรูปภาพเป็น base64 ถ้ามี
      String? imageBase64;
      if (_selectedImage != null) {
        final bytes = await _selectedImage!.readAsBytes();
        imageBase64 = base64Encode(bytes);
      }

      // เตรียม body
      final body = jsonEncode({
        'name': nameController.text,
        'address': addressController.text,
        'service': serviceController.text,
        'price': double.tryParse(priceController.text) ?? 0,
        'phone': phoneController.text,
        'line_id': lineController.text,
        'facebook_link': facebookController.text,
        'instagram_link': instagramController.text,
        'latitude': _selectedLatLng!.latitude,
        'longitude': _selectedLatLng!.longitude,
        'image': imageBase64,
      });

      // ส่ง POST request
      final url = Uri.parse('http://10.0.2.2:3000/api/auth/sitters');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // ส่ง token
        },
        body: body,
      );

      if (!mounted) return;

      if (response.statusCode == 201) {
        _clearFields();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('บันทึกข้อมูลเรียบร้อย')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เกิดข้อผิดพลาด: ${response.body}')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาดในการส่งข้อมูล: $e')),
      );
    }
  }


  void _clearFields() {
    nameController.clear();
    addressController.clear();
    serviceController.clear();
    priceController.clear();
    phoneController.clear();
    lineController.clear();
    facebookController.clear();
    instagramController.clear();
    setState(() {
      _selectedLatLng = null;
      _selectedImage = null;
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    addressController.dispose();
    serviceController.dispose();
    priceController.dispose();
    phoneController.dispose();
    lineController.dispose();
    facebookController.dispose();
    instagramController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const orange = Color(0xFFFF6600);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: orange,
        leading: const BackButton(color: Colors.white),
        title: const Text('กรอกข้อมูล', style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _inputField(nameController, 'ชื่อ/ชื่อร้านค้า', Icons.person),
            _inputField(addressController, 'ที่อยู่', Icons.home),
            _inputField(serviceController, 'บริการ', Icons.settings),
            _inputFieldWithSuffix(priceController, 'ราคา', Icons.monetization_on, 'บาท/วัน', TextInputType.number),
            _inputField(phoneController, 'เบอร์โทรติดต่อ', Icons.phone, TextInputType.phone),
            _inputField(lineController, 'LineID', Icons.message),
            _inputField(facebookController, 'Facebook ', Icons.facebook),
            _inputField(instagramController, 'Instagram ', Icons.camera_alt),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.image),
              label: const Text('เลือกภาพประกอบ'),
              style: ElevatedButton.styleFrom(
                backgroundColor: orange,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                minimumSize: const Size.fromHeight(48),
              ),
            ),
            if (_selectedImage != null) ...[
              const SizedBox(height: 10),
              Image.file(_selectedImage!, width: 150, height: 150, fit: BoxFit.cover),
            ],
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _pickLocation,
              icon: const Icon(Icons.map),
              label: const Text('เลือกพิกัดจากแผนที่'),
              style: ElevatedButton.styleFrom(
                backgroundColor: orange,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                minimumSize: const Size.fromHeight(48),
              ),
            ),
            if (_selectedLatLng != null) ...[
              const SizedBox(height: 10),
              Text(
                'Lat: ${_selectedLatLng!.latitude.toStringAsFixed(6)} | Lng: ${_selectedLatLng!.longitude.toStringAsFixed(6)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _saveData,
              child: const Text('บันทึกข้อมูล', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEEEFF1),
                foregroundColor: orange,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                minimumSize: const Size.fromHeight(50),
                elevation: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _inputField(TextEditingController controller, String label, IconData icon, [TextInputType type = TextInputType.text]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: type,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: const Color(0xFFFF6600)),
          labelText: label,
          border: const UnderlineInputBorder(),
        ),
      ),
    );
  }

  Widget _inputFieldWithSuffix(TextEditingController controller, String label, IconData icon, String suffix, [TextInputType type = TextInputType.number]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: type,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: const Color(0xFFFF6600)),
          suffixText: suffix,
          suffixStyle: const TextStyle(fontWeight: FontWeight.bold),
          labelText: label,
          border: const UnderlineInputBorder(),
        ),
      ),
    );
  }
}
