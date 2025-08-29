import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('การตั้งค่า'),
        backgroundColor: Color(0xFFFF6600),
      ),
      body: Center(
        child: Text('นี่คือหน้าการตั้งค่า'),
      ),
    );
  }
}
