import 'package:flutter/material.dart';

class PetProvider extends ChangeNotifier {
  // รายการข้อมูลสัตว์เลี้ยง (ใช้ List<Map> แบบง่าย)
  List<Map<String, dynamic>> pets = [
    {
      'name': 'มิกกี้',
      'type': 'สุนัข',
      'age': 3,
      'status': 'กำลังอยู่ในความดูแล',
      'store': 'ร้าน Happy Pets',
      'startDate': '2025-08-01',
      'returnDate': '2025-08-10',
    },
    {
      'name': 'เหมียว',
      'type': 'แมว',
      'age': 2,
      'status': 'รอรับกลับ',
      'store': 'ร้าน Pet Care Center',
      'startDate': '2025-07-20',
      'returnDate': '2025-07-29',
    },
    {
      'name': 'โกลด์',
      'type': 'นกแก้ว',
      'age': 1,
      'status': 'เสร็จสิ้น',
      'store': 'ร้าน Cozy Pets',
      'startDate': '2025-07-30',
      'returnDate': '2025-08-05',
    },
  ];

  // ตัวเลือกสถานะที่สามารถเลือกได้
  final List<String> statusOptions = [
    'กำลังอยู่ในความดูแล',
    'รอรับกลับ',
    'เสร็จสิ้น',
  ];

  // ฟังก์ชันอัพเดตสถานะสัตว์เลี้ยง
  void updateStatus(int index, String newStatus) {
    if (index >= 0 && index < pets.length) {
      pets[index]['status'] = newStatus;
      notifyListeners(); // แจ้งให้ widget ที่ฟังอยู่รีเฟรช
    }
  }
}
