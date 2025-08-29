import 'package:flutter/material.dart';

class PetProvider extends ChangeNotifier {
  List<Map<String, dynamic>> pets = [];

  final List<String> statusOptions = [
    'กำลังอยู่ในความดูแล',
    'รอรับกลับ',
    'เสร็จสิ้น',
  ];

  void addPet(Map<String, dynamic> pet) {
    // ถ้าไม่มี ownerEmail ให้กำหนดเป็น '-'
    pet['ownerEmail'] ??= '-';
    pets.add(pet);
    notifyListeners();
  }

  void updateStatus(int index, String newStatus) {
    if (index >= 0 && index < pets.length) {
      pets[index]['status'] = newStatus;
      notifyListeners();
    }
  }
}
