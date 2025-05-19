import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'home_screen.dart';
import 'sigup.dart';  // นำเข้า SignupScreen

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  // ฟังก์ชันล็อกอิน
  Future<void> login() async {
    final String email = emailController.text;
    final String password = passwordController.text;

    // ตรวจสอบกรอกข้อมูล
    if (email.isEmpty || password.isEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('ข้อผิดพลาด'),
            content: Text('กรุณากรอกอีเมลและรหัสผ่าน'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // ปิด Dialog
                },
                child: Text('ปิด'),
              ),
            ],
          );
        },
      );
      return;
    }

    setState(() {
      isLoading = true; // ตั้งค่า isLoading เป็น true เพื่อแสดง CircularProgressIndicator
    });

    final url = Uri.parse('http://10.0.2.2:3000/api/auth/login'); // URL ของ API

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        // ถ้าการล็อกอินสำเร็จ
        final Map<String, dynamic> data = json.decode(response.body);
        final String token = data['token'];
        final String firstName = data['firstName'];
        final String userType = data['userType'];

        // แสดง Dialog แจ้งผลการเข้าสู่ระบบสำเร็จ
        showDialog(
          context: context,
          barrierDismissible: false, // ไม่ให้ปิด dialog โดยการคลิกที่บริเวณนอก dialog
          builder: (context) {
            return AlertDialog(
              title: Text('เข้าสู่ระบบสำเร็จ'),
              content: Text('ยินดีต้อนรับ $firstName!'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HomeScreen(
                          firstName: firstName,
                          email: email,
                          userType: userType,
                        ),
                      ),
                    );
                  },
                  child: Text('ปิด'),
                ),
              ],
            );
          },
        );
      } else {
        // ถ้าการล็อกอินไม่สำเร็จ
        final Map<String, dynamic> errorData = json.decode(response.body);

        // แสดง Dialog แจ้งข้อผิดพลาด
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('เข้าสู่ระบบไม่สำเร็จ'),
              content: Text(errorData['message']),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // ปิด Dialog
                  },
                  child: Text('ปิด'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      // แสดง Dialog เมื่อไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('ข้อผิดพลาด'),
            content: Text('ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // ปิด Dialog
                },
                child: Text('ปิด'),
              ),
            ],
          );
        },
      );
    } finally {
      setState(() {
        isLoading = false; // ตั้งค่า isLoading เป็น false เมื่อโหลดเสร็จ
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('เข้าสู่ระบบ'),
        backgroundColor: Color(0xFFFF6600), // เปลี่ยนสีของ AppBar เป็น #FF6600
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // เพิ่มโลโก้ที่นี่
              Image.asset(
                'assets/logo.png', // เปลี่ยน path ตามไฟล์ของคุณ
                height: 150, // ขนาดความสูงของโลโก้
                width: 150, // ขนาดความกว้างของโลโก้
              ),
              SizedBox(height: 30), // เพิ่มช่องว่าง
              Text(
                'ยินดีต้อนรับ!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black, // ตัวหนังสือสีดำ
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'อีเมล',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email, color: Color(0xFFFF6600)), // เปลี่ยนสีไอคอนเป็น #FF6600
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'รหัสผ่าน',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock, color: Color(0xFFFF6600)), // เปลี่ยนสีไอคอนเป็น #FF6600
                ),
              ),
              SizedBox(height: 20),
              isLoading
                  ? CircularProgressIndicator() // แสดง loading indicator
                  : ElevatedButton(
                onPressed: login,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                  backgroundColor: Color(0xFFFF6600), // เปลี่ยนสีปุ่มเป็น #FF6600
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30), // ทำให้มุมปุ่มโค้ง
                  ),
                ),
                child: Text(
                  'เข้าสู่ระบบ',
                  style: TextStyle(fontSize: 16, color: Colors.black), // ตัวหนังสือสีดำ
                ),
              ),
              SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  // นำทางไปยังหน้าสมัครสมาชิก
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SignupPage()),
                  );
                },
                child: Text(
                  'สมัครสมาชิก',
                  style: TextStyle(color: Color(0xFFFF6600)), // เปลี่ยนสีข้อความเป็น #FF6600
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
