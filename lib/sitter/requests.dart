import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:psoeass/owner/pet_provider.dart';

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
      final url = Uri.parse('http://10.0.2.2:3000/api/auth/deposit_requests');
      final response = await http.get(url, headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      });

      if (response.statusCode != 200) throw Exception("โหลดการจองไม่สำเร็จ");

      final List<dynamic> bookingList = jsonDecode(response.body);

      setState(() {
        bookings = bookingList
            .cast<Map<String, dynamic>>()
            .where((b) => b['status'] == 'pending')
            .toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Widget _buildPetItem(Map<String, dynamic> pet, {String? ownerEmail}) {
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
            Text('เจ้าของ: ${ownerEmail ?? pet['ownerEmail'] ?? '-'}'),
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

  Future<void> _updateBookingStatus(
      Map<String, dynamic> booking, int index, String status) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    if (token.isEmpty) return;

    try {
      final url = Uri.parse(
        'http://10.0.2.2:3000/api/auth/deposit_requests/${booking['id']}/status',
      );

      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'status': status}),
      );

      if (response.statusCode == 200) {
        setState(() {
          bookings.removeAt(index);
        });

        if (status == 'confirmed') {
          final petProvider = context.read<PetProvider>();
          final pets = booking['pets'] as List<dynamic>? ?? [];
          for (var pet in pets) {
            petProvider.addPet({
              'name': pet['name'] ?? '-',
              'type': pet['type'] ?? '-',
              'age': pet['age'] ?? 0,
              'status': 'กำลังอยู่ในความดูแล',
              'store': booking['service'] ?? '-',
              'startDate': booking['date'] ?? '',
              'returnDate': booking['return_date'] ?? '',
              'image': pet['image'] ?? null,
              'additional_info': pet['additional_info'] ?? '',
              'ownerEmail': booking['user_email'] ?? '-',
            });
          }
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${status == 'confirmed' ? 'ยืนยัน' : 'ปฏิเสธ'}การจอง',
            ),
          ),
        );
      } else {
        throw Exception('ไม่สามารถอัพเดต booking ได้');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
      );
    }
  }

  void _onConfirmBooking(Map<String, dynamic> booking, int index) {
    _updateBookingStatus(booking, index, 'confirmed');
  }

  void _onRejectBooking(int index) {
    final booking = bookings[index];
    _updateBookingStatus(booking, index, 'rejected');
  }

  String formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '-';
    return dateStr.split('T')[0];
  }

  Widget _buildBookingCard(Map<String, dynamic> booking, int index) {
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
            ...pets.map((pet) => _buildPetItem(
              pet as Map<String, dynamic>,
              ownerEmail: booking['user_email'],
            )),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade400,
                  ),
                  onPressed: () => _onRejectBooking(index),
                  child: const Text('ปฏิเสธ'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade400,
                  ),
                  onPressed: () => _onConfirmBooking(booking, index),
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
            return _buildBookingCard(bookings[index], index);
          },
        ),
      ),
    );
  }
}
