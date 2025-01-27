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

    if (email.isEmpty || password.isEmpty) {
      // ถ้าผู้ใช้ไม่กรอกข้อมูล
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('กรุณากรอกอีเมลและรหัสผ่าน')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    // URL ของ API สำหรับการล็อกอิน
    final url = Uri.parse('http://10.0.2.2:3000/api/auth/login'); // ใช้ 10.0.2.2 เมื่อใช้ Android Emulator

    // ส่งคำขอล็อกอิน
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        // การล็อกอินสำเร็จ
        final Map<String, dynamic> data = json.decode(response.body);
        final String token = data['token'];
        final String firstName = data['firstName'];
        final String userType = data['userType'];

        // แสดงข้อความสำเร็จ
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เข้าสู่ระบบสำเร็จ')),
        );

        // เก็บ JWT token ใน SharedPreferences (หรือ local storage)
        // navigate to home screen
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
      } else {
        // การล็อกอินไม่สำเร็จ
        final Map<String, dynamic> errorData = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorData['message'])),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('เข้าสู่ระบบ'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'อีเมล',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'รหัสผ่าน',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            isLoading
                ? CircularProgressIndicator()  // แสดง loading indicator
                : ElevatedButton(
              onPressed: login,
              child: Text('เข้าสู่ระบบ'),
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
              child: Text('สมัครสมาชิก'),
            ),
          ],
        ),
      ),
    );
  }
}
