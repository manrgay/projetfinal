import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class OwnerBookingScreen extends StatefulWidget {
  const OwnerBookingScreen({super.key});

  @override
  State<OwnerBookingScreen> createState() => _OwnerBookingScreenState();
}

class _OwnerBookingScreenState extends State<OwnerBookingScreen> {
  List<Map<String, dynamic>> bookings = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    setState(() {
      isLoading = true;
      bookings = [];
    });

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
      final url = Uri.parse('http://10.0.2.2:3000/api/auth/owner/deposit_requests');
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

  Future<void> _cancelBooking(String bookingId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    if (token.isEmpty) return;

    try {
      final url = Uri.parse('http://10.0.2.2:3000/api/auth/bookings/$bookingId/cancel');
      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ยกเลิกการจองสำเร็จ')),
        );
        _loadBookings(); // โหลดใหม่หลังยกเลิก
      } else {
        throw Exception('ไม่สามารถยกเลิกการจองได้');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
      );
    }
  }

  String formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '-';
    return dateStr.split('T')[0];
  }

  Widget _buildBookingCard(Map<String, dynamic> booking) {
    final pets = booking['pets'] as List<dynamic>? ?? [];
    final returnDate = booking['return_date'];

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
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16),
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
            Text('วันที่ฝาก: ${formatDate(booking['date'])}'),
            if (returnDate != null && returnDate.toString().isNotEmpty)
              Text('วันที่รับกลับ: ${formatDate(returnDate)}'),
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
            ...pets.map((pet) => ListTile(
              title: Text(pet['name'] ?? '-'),
              subtitle: Text('${pet['type'] ?? '-'}, ${pet['age'] ?? '-'} ${pet['age_unit'] ?? ''}'),
            )),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                  ),
                  onPressed: () => _cancelBooking(booking['id'].toString()),
                  child: const Text('ยกเลิกการจอง'),
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
        title: const Text("รายการคำขอรับฝากของฉัน"),
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
