import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: PetBoardingHistory(),
    );
  }
}

class PetBoardingHistory extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ประวัติการฝากสัตว์เลี้ยง'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text('สุนัขชื่อ "Buddy"'),
            subtitle: Text('ประเภท: สุนัข, วันที่ฝาก: 10/12/2024, สถานะ: กำลังอยู่ในการดูแล'),
            onTap: () {
              // เข้าสู่หน้ารายละเอียด
            },
          ),
          ListTile(
            title: Text('แมวชื่อ "Mimi"'),
            subtitle: Text('ประเภท: แมว, วันที่ฝาก: 15/12/2024, สถานะ: คืนแล้ว'),
            onTap: () {
              // เข้าสู่หน้ารายละเอียด
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // ฟังก์ชันการเพิ่มการฝากใหม่
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
