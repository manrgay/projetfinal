import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProfileScreen extends StatefulWidget {
  final String token;

  ProfileScreen({required this.token});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late String firstName;
  late String email;
  late String userType;
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  // ฟังก์ชันดึงข้อมูลจาก API
  Future<void> fetchUserProfile() async {
    final url = Uri.parse('http://localhost:3000/profile');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer ${widget.token}', // ส่ง token ใน header
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          firstName = data['firstName'];
          email = data['email'];
          userType = data['userType'];
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load profile. Please try again.';
          isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        errorMessage = 'An error occurred. Please try again.';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: errorMessage.isNotEmpty
            ? Center(child: Text(errorMessage))
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'First Name: $firstName',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              'Email: $email',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              'User Type: $userType',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
