import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'pet_provider.dart';

class PetStatusExampleScreen extends StatelessWidget {
  const PetStatusExampleScreen({super.key});

  Color getStatusColor(String status) {
    switch (status) {
      case 'กำลังอยู่ในความดูแล':
        return Colors.green;
      case 'รอรับกลับ':
        return Colors.orange;
      case 'เสร็จสิ้น':
        return Colors.green; // เปลี่ยนเป็นสีเขียว
      default:
        return Colors.blue;
    }
  }


  IconData getStatusIcon(String status) {
    switch (status) {
      case 'กำลังอยู่ในความดูแล':
      case 'รอรับกลับ':
        return Icons.pets;
      case 'เสร็จสิ้น':
        return Icons.check_circle_outline;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final petProvider = context.watch<PetProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('สัตว์ที่กำลังฝากเลี้ยง'),
        backgroundColor: Colors.orange.shade400,
      ),
      body: petProvider.pets.isEmpty
          ? const Center(child: Text('ไม่มีสัตว์ที่กำลังฝากเลี้ยง'))
          : ListView.builder(
        itemCount: petProvider.pets.length,
        itemBuilder: (context, index) {
          final pet = petProvider.pets[index];
          final status = pet['status'] ?? 'ไม่ระบุ';
          final store = pet['store'] ?? '-';
          final startDate = pet['startDate'] ?? '-';
          final returnDate = pet['returnDate'] ?? '-';

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: Icon(getStatusIcon(status), color: getStatusColor(status), size: 36),
              title: Text(pet['name'] ?? 'ไม่มีชื่อ'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('สถานะ: $status'),
                  Text('ร้านรับเลี้ยง: $store'),
                  Text('ฝากเลี้ยงวันที่: $startDate'),
                  Text('รับกลับวันที่: $returnDate'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
