import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DepositRequestListScreen extends StatefulWidget {
  const DepositRequestListScreen({super.key});

  @override
  State<DepositRequestListScreen> createState() =>
      _DepositRequestListScreenState();
}

class _DepositRequestListScreenState extends State<DepositRequestListScreen> {
  List<Map<String, dynamic>> bookings = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    setState(() => isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    if (token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("กรุณาเข้าสู่ระบบก่อน")),
      );
      setState(() => isLoading = false);
      return;
    }

    try {
      final url =
      Uri.parse('http://10.0.2.2:3000/api/auth/deposit_requests');
      final response = await http.get(url, headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      });

      if (response.statusCode != 200) throw Exception("โหลดการจองไม่สำเร็จ");

      final List<dynamic> bookingList = jsonDecode(response.body);

      setState(() {
        bookings = bookingList.cast<Map<String, dynamic>>();
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Widget _buildPetItem(Map<String, dynamic> pet) {
    String? imageBase64;
    final img = pet['image'];
    if (img != null) {
      if (img is String) {
        imageBase64 = img;
      } else if (img is List<int>) {
        imageBase64 = base64Encode(img);
      } else if (img is Map && img['data'] != null) {
        imageBase64 = img['data'];
      }
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: imageBase64 != null && imageBase64.isNotEmpty
            ? ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.memory(
            base64Decode(imageBase64),
            width: 60,
            height: 60,
            fit: BoxFit.cover,
          ),
        )
            : Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.pets, color: Colors.grey),
        ),
        title: Text(
          pet['name'] ?? 'ไม่ระบุชื่อ',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                '${pet['type'] ?? '-'}, ${pet['age'] ?? '-'} ${pet['age_unit'] ?? ''}'),
            if (pet['additional_info'] != null &&
                pet['additional_info'].toString().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'รายละเอียดเพิ่มเติม: ${pet['additional_info']}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking) {
    final pets = booking['pets'] as List<dynamic>? ?? [];
    final returnDate = booking['return_date']; // ดึง return_date

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.orange[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'ผู้จอง: ${booking['user_email']}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('บริการ: ${booking['service']}'),
                Text('ราคา: ${booking['price']} บาท'),
              ],
            ),
            const SizedBox(height: 4),
            Text('วันที่ฝาก: ${booking['date'].split("T")[0]}'),
            if (returnDate != null && returnDate.toString().isNotEmpty)
              Text('วันที่รับกลับ: ${returnDate.split("T")[0]}'), // แสดง return_date
            if (booking['note'] != null && booking['note'].toString().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text('หมายเหตุ: ${booking['note']}'),
              ),
            const Divider(height: 20, thickness: 1),
            const Text(
              'สัตว์เลี้ยง:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 4),
            ...pets.map((pet) => _buildPetItem(pet as Map<String, dynamic>)),
            const SizedBox(height: 12),
            // ปุ่มยืนยัน / ปฏิเสธ
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade400,
                  ),
                  onPressed: () {
                    // TODO: เรียก API ปฏิเสธการจอง
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(
                              'ปฏิเสธการจอง ${booking['user_email']}')),
                    );
                  },
                  child: const Text('ปฏิเสธ'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade400,
                  ),
                  onPressed: () {
                    // TODO: เรียก API ยืนยันการจอง
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(
                              'ยืนยันการจอง ${booking['user_email']}')),
                    );
                  },
                  child: const Text('ยืนยัน'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("รายการคำขอรับฝาก"),
        backgroundColor: Colors.orange,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : bookings.isEmpty
          ? const Center(child: Text("ยังไม่มีการจอง"))
          : RefreshIndicator(
        onRefresh: _loadBookings,
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: bookings.length,
          itemBuilder: (context, index) {
            return _buildBookingCard(bookings[index]);
          },
        ),
      ),
    );
  }
}
