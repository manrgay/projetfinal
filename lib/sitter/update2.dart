import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:psoeass/owner/pet_provider.dart';


class PetStatusScreen extends StatelessWidget {
  const PetStatusScreen({super.key});

  Color getStatusColor(String status) {
    switch (status) {
      case 'กำลังอยู่ในความดูแล':
        return Colors.deepOrange;
      case 'รอรับกลับ':
        return Colors.orange;
      case 'เสร็จสิ้น':
        return Colors.green; // เปลี่ยนเป็นสีเขียว
      default:
        return Colors.blue;
    }
  }

  void _showStatusPickerDialog(BuildContext context, int index, List<String> statusOptions, String currentStatus) {
    showDialog(
      context: context,
      builder: (context) {
        String? selectedStatus = currentStatus;
        return AlertDialog(
          title: Text('เลือกสถานะสำหรับ ${context.read<PetProvider>().pets[index]['name']}'),
          content: StatefulBuilder(
            builder: (context, setStateDialog) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: statusOptions.map((status) {
                  return RadioListTile<String>(
                    title: Text(status),
                    value: status,
                    groupValue: selectedStatus,
                    onChanged: (value) {
                      setStateDialog(() {
                        selectedStatus = value;
                      });
                    },
                  );
                }).toList(),
              );
            },
          ),
          actions: [
            TextButton(
              child: const Text('ยกเลิก'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            ElevatedButton(
              child: const Text('บันทึก'),
              onPressed: () {
                if (selectedStatus != null) {
                  context.read<PetProvider>().updateStatus(index, selectedStatus!);
                }
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final petProvider = context.watch<PetProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('สถานะสัตว์เลี้ยงที่รับฝาก'),
        backgroundColor: Colors.deepOrange,
      ),
      body: ListView.builder(
        itemCount: petProvider.pets.length,
        itemBuilder: (context, index) {
          final pet = petProvider.pets[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: 4,
            child: ListTile(
              leading: Icon(
                Icons.pets,
                size: 40,
                color: getStatusColor(pet['status']),
              ),
              title: Text(
                pet['name'],
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                'ชนิด: ${pet['type']}  |  อายุ: ${pet['age']} ปี\nสถานะ: ${pet['status']}',
              ),
              isThreeLine: true,
              trailing: const Icon(
                Icons.arrow_forward_ios,
                size: 18,
                color: Colors.grey,
              ),
              onTap: () {
                _showStatusPickerDialog(context, index, petProvider.statusOptions, pet['status']);
              },
            ),
          );
        },
      ),
      // ลบ floatingActionButton ออกไปเลย ไม่มีตรงนี้
    );
  }
}
