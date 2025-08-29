import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:psoeass/owner/petlist.dart'; // โมเดล Pet ของคุณ

class BookingPage extends StatefulWidget {
  final String name;
  final String service;
  final double price;
  final String address;
  final int sitterId;

  const BookingPage({
    super.key,
    required this.name,
    required this.service,
    required this.price,
    required this.address,
    required this.sitterId,
  });

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  List<Pet> pets = [];
  Set<int> selectedPetIds = {};
  DateTime? _selectedDate;
  DateTime? _selectedReturnDate;
  final TextEditingController _noteController = TextEditingController();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPets();
  }

  Future<void> _loadPets() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final userEmail = prefs.getString('email') ?? '';

    if (userEmail.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ไม่พบ email ของผู้ใช้')),
      );
      return;
    }

    final url = Uri.parse('http://10.0.2.2:3000/api/auth/get-pets');
    final response = await http.get(url, headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      final filtered = jsonList.where((item) {
        final emailFromApi =
        (item['owner_email'] ?? '').toString().trim().toLowerCase();
        return emailFromApi == userEmail.trim().toLowerCase();
      }).toList();

      setState(() {
        pets = filtered.map((jsonItem) => Pet.fromJson(jsonItem)).toList();
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('โหลดสัตว์เลี้ยงไม่สำเร็จ')));
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 1),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        // ถ้าวันรับกลับก่อนวันฝาก ให้รีเซ็ต
        if (_selectedReturnDate != null &&
            _selectedReturnDate!.isBefore(_selectedDate!)) {
          _selectedReturnDate = null;
        }
      });
    }
  }

  Future<void> _pickReturnDate() async {
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณาเลือกวันที่ฝากก่อน')),
      );
      return;
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate!,
      firstDate: _selectedDate!,
      lastDate: DateTime(_selectedDate!.year + 1),
    );
    if (picked != null) {
      setState(() {
        _selectedReturnDate = picked;
      });
    }
  }

  Future<void> _submitBooking() async {
    if (_selectedDate == null ||
        _selectedReturnDate == null ||
        selectedPetIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("กรุณาเลือกสัตว์เลี้ยง, วันที่ฝาก และวันที่รับกลับ")),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    if (token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณาเข้าสู่ระบบก่อน')),
      );
      return;
    }

    if (JwtDecoder.isExpired(token)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Token หมดอายุ กรุณาเข้าสู่ระบบใหม่')),
      );
      return;
    }

    final decodedToken = JwtDecoder.decode(token);
    final userId = decodedToken['id'];

    final dateStr = _selectedDate!.toIso8601String().split("T")[0];
    final returnDateStr = _selectedReturnDate!.toIso8601String().split("T")[0];

    final body = {
      'user_id': userId,
      'sitter_id': widget.sitterId,
      'service': widget.service,
      'price': widget.price,
      'date': dateStr,
      'return_date': returnDateStr,
      'note': _noteController.text,
      'pet_ids': selectedPetIds.toList(),
    };

    print("Booking Body: ${jsonEncode(body)}");

    final url = Uri.parse('http://10.0.2.2:3000/api/auth/bookings');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    print("Response Status: ${response.statusCode}");
    print("Response Body: ${response.body}");

    try {
      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("จองสำเร็จ")));
        Navigator.pop(context);
      } else {
        final resp = jsonDecode(response.body);
        final msg = resp['message'] ?? 'เกิดข้อผิดพลาดในการจอง';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("เกิดข้อผิดพลาด: ${response.body}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("จองบริการ"),
        backgroundColor: Colors.orange,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("ผู้ให้บริการ: ${widget.name}",
                style: const TextStyle(fontSize: 18)),
            Text("บริการ: ${widget.service}",
                style: const TextStyle(fontSize: 16)),
            Text("ราคา: ${widget.price.toStringAsFixed(0)} บาท",
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            const Text("เลือกสัตว์เลี้ยงที่จะฝาก:",
                style: TextStyle(fontSize: 16)),
            Expanded(
              child: pets.isEmpty
                  ? const Center(child: Text("ไม่มีสัตว์เลี้ยง"))
                  : ListView.builder(
                itemCount: pets.length,
                itemBuilder: (context, index) {
                  final pet = pets[index];
                  return CheckboxListTile(
                    title: Text(pet.name),
                    subtitle:
                    Text('${pet.type}, ${pet.age} ${pet.ageUnit}'),
                    value: selectedPetIds.contains(pet.id),
                    onChanged: (val) {
                      setState(() {
                        if (val == true) {
                          selectedPetIds.add(pet.id);
                        } else {
                          selectedPetIds.remove(pet.id);
                        }
                      });
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            // เลือกวันที่ฝาก
            Row(
              children: [
                Expanded(
                  child: Text(_selectedDate == null
                      ? "ยังไม่ได้เลือกวันที่ฝาก"
                      : "วันที่ฝาก: ${_selectedDate!.toLocal()}"
                      .split(" ")[0]),
                ),
                ElevatedButton(
                  onPressed: _pickDate,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                  child: const Text("เลือกวันที่ฝาก"),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // เลือกวันที่รับกลับ
            Row(
              children: [
                Expanded(
                  child: Text(_selectedReturnDate == null
                      ? "ยังไม่ได้เลือกวันที่รับกลับ"
                      : "วันที่รับกลับ: ${_selectedReturnDate!.toLocal()}"
                      .split(" ")[0]),
                ),
                ElevatedButton(
                  onPressed: _pickReturnDate,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                  child: const Text("เลือกวันที่รับกลับ"),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: "หมายเหตุ (ถ้ามี)",
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitBooking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "ยืนยันการจอง",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
