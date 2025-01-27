import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('หน้าหลัก'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildUserInfoCard(),
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
    );
  }

  // ส่วนแสดงข้อมูลผู้ใช้งาน
  Widget _buildUserInfoCard() {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blueAccent,
          child: Icon(Icons.person, color: Colors.white),
        ),
        title: Text(firstName, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(email),
            SizedBox(height: 5),
            Row(
              children: [
                Icon(
                  userType == 'owner' ? Icons.pets : Icons.business,
                  size: 18,
                  color: Colors.green,
                ),
                SizedBox(width: 5),
                Text(
                  userType == 'owner' ? 'เจ้าของสัตว์เลี้ยง' : 'ผู้รับฝากสัตว์เลี้ยง',
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
    if (userType == 'owner') {
      return Column(
        children: [
          _menuItem(context, Icons.pets, 'จองการรับฝากสัตว์เลี้ยง', '/booking'),
          _menuItem(context, Icons.edit, 'กรอกข้อมูลสัตว์เลี้ยง', '/pet-info'),
          _menuItem(context, Icons.pets, 'ข้อมูลสัตว์เลี้ยง', '/pet-name'),
          _menuItem(context, Icons.history, 'ประวัติการฝาก', '/history'),
          _menuItem(context, Icons.chat, 'แชทกับผู้รับฝาก', '/chat'),
          // เมนูใหม่สำหรับแสดงรายการสัตว์เลี้ยงที่ตรงกับอีเมลผู้ใช้
          _menuItem(context, Icons.pets, 'รายการสัตว์เลี้ยงของฉัน', '/pet-list', userEmail: email),
        ],
      );
    } else if (userType == 'sitter') {
      return Column(
        children: [
          _menuItem(context, Icons.pets, 'จองการรับฝากสัตว์เลี้ยง', '/booking'),
          _menuItem(context, Icons.edit, 'กรอกข้อมูลแนะตัวในหน้าหลัก', '/name'),
          _menuItem(context, Icons.list, 'รายการคำขอรับฝาก', '/requests'),
          _menuItem(context, Icons.calendar_today, 'ตารางงานของฉัน', '/schedule'),
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
