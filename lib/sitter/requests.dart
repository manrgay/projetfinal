import 'package:flutter/material.dart';

class DepositRequestListScreen extends StatelessWidget {
  const DepositRequestListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('รายการคำขอรับฝาก'),
        backgroundColor: const Color(0xFFFF6600), // ใช้สี #FF6600 สำหรับ AppBar
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 2, // สมมุติว่ามี 2 รายการ
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.orange.shade200), // สีกรอบอ่อน
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        color: const Color(0xFFFF6600), // ใช้สี #FF6600
                        child: const Center(
                          child: Text(
                            'รูปภาพ',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'ชื่อสัตว์เลี้ยง: ....................',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 4),
                            Text('ประเภทสัตว์เลี้ยง: ....................'),
                            SizedBox(height: 4),
                            Text('ขนาดสัตว์เลี้ยง: ....................'),
                            SizedBox(height: 4),
                            Text('ข้อมูลพิเศษ: ....................'),
                            SizedBox(height: 4),
                            Text('วันรับฝาก: DD/MM/YY'),
                            SizedBox(height: 4),
                            Text('วันรับคืน: DD/MM/YY'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        // เพิ่มฟังก์ชันยืนยันที่นี่
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6600), // ปุ่มใช้สี #FF6600
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                      ),
                      child: const Text(
                        'ยืนยัน',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
