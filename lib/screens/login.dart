import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'home_screen.dart';
import 'sigup.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  bool _obscurePassword = true;

  Future<void> login() async {
    final String email = emailController.text.trim();
    final String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showDialog("ข้อผิดพลาด", "กรุณากรอกอีเมลและรหัสผ่าน");
      return;
    }

    setState(() {
      isLoading = true;
    });

    final url = Uri.parse('http://10.0.2.2:3000/api/auth/login');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      print('DEBUG response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final String token = data['token'] ?? '';
        final String userType = (data['userType'] ?? '').toLowerCase();

        // เก็บค่า sitterId ถ้ามี
        final int? sitterId = data['sitterId'];

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await prefs.setString('email', data['email'] ?? email);
        await prefs.setString('userType', userType);
        if (sitterId != null) {
          await prefs.setInt('sitterId', sitterId);
        }

        // debug print
        print('DEBUG: token=$token, userType=$userType, sitterId=$sitterId');

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        final errorData = json.decode(response.body);
        _showDialog(
          "เข้าสู่ระบบไม่สำเร็จ",
          errorData['message'] ?? 'เกิดข้อผิดพลาด',
        );
      }
    } catch (e) {
      _showDialog("ข้อผิดพลาด", "ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์");
      print('ERROR: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("ตกลง"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('เข้าสู่ระบบ'),
        backgroundColor: const Color(0xFFFF6600),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 32.0, top: 16),
              child: Center(
                child: Image.asset(
                  'assets/logo.png',
                  width: 120,
                  height: 120,
                ),
              ),
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'อีเมล',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'รหัสผ่าน',
                border: const OutlineInputBorder(),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        passwordController.clear();
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: login,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6600),
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'เข้าสู่ระบบ',
                style: TextStyle(color: Colors.black, fontSize: 16),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignupPage()),
                );
              },
              child: const Text(
                'สมัครสมาชิก',
                style: TextStyle(color: Color(0xFFFF6600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
