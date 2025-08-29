import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File? _profileImage;
  String? firstName;
  String? lastName;
  String? email;
  String? userType;
  bool isLoading = true;
  String? token;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadTokenAndProfile();
  }

  Future<void> _loadTokenAndProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');

    if (token == null || JwtDecoder.isExpired(token!)) {
      // token ไม่มีหรือหมดอายุ → ไป login
      await prefs.remove('token');
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      // token ถูกต้อง → decode และ fetch profile
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token!);
      email = decodedToken['email'];
      userType = decodedToken['userType']?.toLowerCase();
      await _fetchProfile();
    }
  }

  Future<void> _fetchProfile() async {
    try {
      final response = await http.get(
        Uri.parse("http://10.0.2.2:3000/api/auth/user/profile"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          firstName = data["firstName"];
          lastName = data["lastName"];
          email = data["email"];
          userType = data["userType"]?.toLowerCase();
          isLoading = false;
        });

        if (firstName == null || email == null || userType == null) {
          setState(() {
            errorMessage = "ข้อมูลผู้ใช้ไม่ครบถ้วน: ${data.toString()}";
          });
        }
      } else if (response.statusCode == 401) {
        setState(() {
          errorMessage = "Token หมดอายุหรือไม่ถูกต้อง กรุณา login ใหม่";
          isLoading = false;
        });
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.remove('token');
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        setState(() {
          errorMessage = "โหลดข้อมูลไม่สำเร็จ: ${response.body}";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "เกิดข้อผิดพลาด: $e";
        isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _profileImage = File(image.path);
      });
    }
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('ออกจากระบบ'),
          content: Text('คุณแน่ใจไหม ว่าจะออกจากระบบ?'),
          actions: [
            TextButton(
              child: Text('ยกเลิก', style: TextStyle(color: Colors.grey)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFFF6600)),
              child: Text('ยืนยัน', style: TextStyle(color: Colors.white)),
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.remove('token');
                Navigator.of(context).pop();
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('หน้าหลัก'), backgroundColor: Color(0xFFFF6600)),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: Text('หน้าหลัก'), backgroundColor: Color(0xFFFF6600)),
        body: Center(
          child: Text(errorMessage!, style: TextStyle(color: Colors.red, fontSize: 16)),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('หน้าหลัก', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Color(0xFFFF6600),
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(icon: Icon(Icons.settings, color: Colors.white), onPressed: () => Navigator.pushNamed(context, '/settings')),
          IconButton(icon: Icon(Icons.logout, color: Colors.white), onPressed: () => _showLogoutConfirmationDialog(context)),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildUserInfoCard(),
                SizedBox(height: 20),
                Text('เมนูการใช้งาน', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
                SizedBox(height: 10),
                _buildUserMenu(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfoCard() {
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
            Text(firstName ?? "", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black)),
            IconButton(icon: Icon(Icons.edit, color: Color(0xFFFF6600)), onPressed: () => Navigator.pushNamed(context, '/edit-profile')),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(email ?? "", style: TextStyle(color: Colors.black, fontSize: 16)),
            SizedBox(height: 5),
            Row(
              children: [
                Icon(userType == 'owner' ? Icons.pets : Icons.business, size: 18, color: Colors.green),
                SizedBox(width: 5),
                Text(userType == 'owner' ? 'เจ้าของสัตว์เลี้ยง' : 'ผู้รับฝากสัตว์เลี้ยง', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserMenu(BuildContext context) {
    if (userType == 'owner') {
      return Column(
        children: [
          _menuItem(context, Icons.pets, 'จองการรับฝากสัตว์เลี้ยง', '/booking'),
          _menuItem(context, Icons.edit, 'กรอกข้อมูลสัตว์เลี้ยง', '/pet-info', userEmail: email),
          _menuItem(context, Icons.pets, 'รายการสัตว์เลี้ยงของฉัน', '/pet-list', userEmail: email),
          _menuItem(context, Icons.history, 'ติดตามสัตว์เลี้ยง', '/update'),
          _menuItem(context, Icons.history, 'ประวัติการฝาก', '/history'),
        ],
      );
    } else if (userType == 'sitter') {
      return Column(
        children: [
          _menuItem(context, Icons.edit, 'กรอกข้อมูลแนะตัวในหน้าหลัก', '/extends', userEmail: email),
          _menuItem(context, Icons.list, 'รายการคำขอรับฝาก', '/requests', userEmail: email),
          _menuItem(context, Icons.list, 'สถานะของสัตว์เลี้ยงที่รับฝาก', '/update2', userEmail: email),
          _menuItem(context, Icons.edit, 'ดูโปรไฟส์หน้าร้าน', '/homey', userEmail: email),
        ],
      );
    } else {
      return Center(
        child: Text('เกิดข้อผิดพลาดในการโหลดเมนู', style: TextStyle(color: Colors.black, fontSize: 16)),
      );
    }
  }

  Widget _menuItem(
      BuildContext context,
      IconData icon,
      String title,
      String route, {
        String? userEmail,
      }) {
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
