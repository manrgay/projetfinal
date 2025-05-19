import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class HomeScreen extends StatefulWidget {
  final String firstName;
  final String email;
  final String userType;

  const HomeScreen({
    super.key,
    required this.firstName,
    required this.email,
    required this.userType,
  });

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File? _profileImage; // ตัวแปรเก็บรูปโปรไฟล์

  // ฟังก์ชันสำหรับเลือกภาพจากแกลเลอรีหรือถ่ายจากกล้อง
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery); // เลือกรูปจากแกลเลอรี
    if (image != null) {
      setState(() {
        _profileImage = File(image.path); // อัปเดตรูปโปรไฟล์
      });
    }
  }

  // ฟังก์ชันแสดง Dialog ยืนยันการออกจากระบบ
  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('ออกจากระบบ'),
          content: Text('คุณแน่ใจไหม ว่าจะออกจากระบบ?'),
          actions: <Widget>[
            TextButton(
              child: Text('ยกเลิก', style: TextStyle(color: Colors.grey)),
              onPressed: () {
                Navigator.of(context).pop(); // ปิด dialog
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFFF6600), // ปุ่มสีส้ม
              ),
              child: Text('ยืนยัน', style: TextStyle(color: Colors.white)),
              onPressed: () {
                Navigator.of(context).pop(); // ปิด dialog ก่อน
                Navigator.pushReplacementNamed(context, '/login'); // ไปหน้า login
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('หน้าหลัก', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Color(0xFFFF6600),
        elevation: 0,
        automaticallyImplyLeading: false, // ไม่มีปุ่มย้อนกลับ
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              _showLogoutConfirmationDialog(context); // ใช้ Dialog เมื่อกด logout
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildUserInfoCard(context),
                SizedBox(height: 20),
                Text(
                  'เมนูการใช้งาน',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                SizedBox(height: 10),
                _buildUserMenu(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ส่วนแสดงข้อมูลผู้ใช้งาน พร้อมไอคอน Edit และการเปลี่ยนรูปโปรไฟล์
  Widget _buildUserInfoCard(BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Colors.white,
      child: ListTile(
        leading: GestureDetector(
          onTap: _pickImage,
          child: CircleAvatar(
            radius: 35,
            backgroundColor: Color(0xFFFF6600),
            backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
            child: _profileImage == null ? Icon(Icons.person, color: Colors.white) : null,
          ),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(widget.firstName, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 18)),
            IconButton(
              icon: Icon(Icons.edit, color: Color(0xFFFF6600)),
              onPressed: () {
                Navigator.pushNamed(context, '/edit-profile');
              },
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.email, style: TextStyle(color: Colors.black, fontSize: 16)),
            SizedBox(height: 5),
            Row(
              children: [
                Icon(
                  widget.userType == 'owner' ? Icons.pets : Icons.business,
                  size: 18,
                  color: Colors.green,
                ),
                SizedBox(width: 5),
                Text(
                  widget.userType == 'owner' ? 'เจ้าของสัตว์เลี้ยง' : 'ผู้รับฝากสัตว์เลี้ยง',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // เมนูสำหรับแต่ละประเภทผู้ใช้
  Widget _buildUserMenu(BuildContext context) {
    if (widget.userType == 'owner') {
      return Column(
        children: [
          _menuItem(context, Icons.pets, 'จองการรับฝากสัตว์เลี้ยง', '/booking'),
          _menuItem(context, Icons.edit, 'กรอกข้อมูลสัตว์เลี้ยง', '/pet-info'),
          _menuItem(context, Icons.pets, 'รายการสัตว์เลี้ยงของฉัน', '/pet-list', userEmail: widget.email),
          _menuItem(context, Icons.history, 'ติดตามสถานะของสัตว์เลี้ยง', '/update'),
          _menuItem(context, Icons.history, 'ประวัติการฝาก', '/history'),
        ],
      );
    } else if (widget.userType == 'sitter') {
      return Column(
        children: [
          _menuItem(context, Icons.pets, 'จองการรับฝากสัตว์เลี้ยง', '/booking'),
          _menuItem(context, Icons.edit, 'กรอกข้อมูลแนะตัวในหน้าหลัก', '/extends'),
          _menuItem(context, Icons.list, 'รายการคำขอรับฝาก', '/requests'),
          _menuItem(context, Icons.list, 'แจ้งสถานะของสัตว์เลี้ยง', '/update2'),
        ],
      );
    } else {
      return Center(child: Text('เกิดข้อผิดพลาดในการโหลดเมนู', style: TextStyle(color: Colors.black, fontSize: 16)));
    }
  }

  // ฟังก์ชันสร้างไอเท็มเมนู พร้อมเพิ่มฟังก์ชันการนำทาง
  Widget _menuItem(BuildContext context, IconData icon, String title, String route, {String? userEmail}) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 5,
      child: ListTile(
        leading: Icon(icon, color: Color(0xFFFF6600)),
        title: Text(title, style: TextStyle(color: Colors.black, fontSize: 16)),
        onTap: () {
          if (userEmail != null) {
            Navigator.pushNamed(context, route, arguments: userEmail);
          } else {
            Navigator.pushNamed(context, route);
          }
        },
      ),
    );
  }
}
