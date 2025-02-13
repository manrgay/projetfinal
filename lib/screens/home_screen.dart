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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('หน้าหลัก'),
        actions: [
          // ไอคอนตั้งค่า
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
          // ไอคอนออกจากระบบ
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
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
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: GestureDetector(
          onTap: _pickImage, // เมื่อกดที่รูปโปรไฟล์ให้เปลี่ยนภาพ
          child: CircleAvatar(
            radius: 30,
            backgroundColor: Colors.blueAccent,
            backgroundImage: _profileImage != null
                ? FileImage(_profileImage!) // แสดงรูปใหม่หากมี
                : null,
            child: _profileImage == null ? Icon(Icons.person, color: Colors.white) : null, // แสดงไอคอนหากยังไม่มีภาพ
          ),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(widget.firstName, style: TextStyle(fontWeight: FontWeight.bold)),
            // ไอคอน Edit สำหรับแก้ไขข้อมูลผู้ใช้งาน
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                Navigator.pushNamed(context, '/edit-profile');
              },
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.email),
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
          _menuItem(context, Icons.history, 'ติดตามสถานะของสัตว์เลี่้ยง', '/update'),
          _menuItem(context, Icons.history, 'ประวัติการฝาก', '/history'),
          _menuItem(context, Icons.chat, 'แชทกับผู้รับฝาก', '/chat'),
        ],
      );
    } else if (widget.userType == 'sitter') {
      return Column(
        children: [
          _menuItem(context, Icons.pets, 'จองการรับฝากสัตว์เลี้ยง', '/booking'),
          _menuItem(context, Icons.edit, 'กรอกข้อมูลแนะตัวในหน้าหลัก', '/name'),
          _menuItem(context, Icons.list, 'รายการคำขอรับฝาก', '/requests'),
          _menuItem(context, Icons.list, 'แจ้งสถานะของสัตว์เลี้ยง', '/update2'),
          _menuItem(context, Icons.chat, 'แชทกับลูกค้า', '/chat'),
        ],
      );
    } else {
      return Center(child: Text('เกิดข้อผิดพลาดในการโหลดเมนู'));
    }
  }

  // ฟังก์ชันสร้างไอเท็มเมนู พร้อมเพิ่มฟังก์ชันการนำทาง
  Widget _menuItem(BuildContext context, IconData icon, String title, String route, {String? userEmail}) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Colors.blueAccent),
        title: Text(title),
        onTap: () {
          // ส่งอีเมลของผู้ใช้ไปยังหน้าถัดไปในกรณีที่มี
          if (userEmail != null) {
            Navigator.pushNamed(context, route, arguments: userEmail); // ส่งอีเมลไปที่หน้า PetListScreen
          } else {
            Navigator.pushNamed(context, route);
          }
        },
      ),
    );
  }
}
