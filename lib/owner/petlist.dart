import 'package:flutter/material.dart';

class PetListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // รับอีเมลที่ส่งมาจากหน้า Home
    final String email = ModalRoute.of(context)?.settings.arguments as String;

    return Scaffold(
      appBar: AppBar(
        title: Text('รายการสัตว์เลี้ยงของฉัน'),
      ),
      body: Center(
        child: Text(
          'แสดงรายการสัตว์เลี้ยงสำหรับ: $email',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
