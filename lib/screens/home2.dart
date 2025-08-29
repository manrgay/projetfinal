import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:psoeass/models/sitter_data.dart'; // import model
import 'sitter_detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Sitter> sitters = [];
  String searchQuery = '';
  String sortOption = 'none';
  bool isLoading = false;
  String? errorMessage;

  String userEmail = ''; // ✅ เพิ่มตัวแปร userEmail

  @override
  void initState() {
    super.initState();
    _loadUserEmail(); // ✅ โหลด email จาก SharedPreferences
    fetchSitters();
  }

  Future<void> _loadUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userEmail = prefs.getString('email') ?? '';
    });
  }

  Future<void> fetchSitters() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:3000/api/auth/sitters'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        sitters = data.map((json) => Sitter.fromJson(json)).toList();
      } else {
        errorMessage = 'Failed to load sitters: ${response.statusCode}';
      }
    } catch (e) {
      errorMessage = 'Error: $e';
    }

    setState(() {
      isLoading = false;
    });
  }

  void _reloadPage() {
    setState(() {
      searchQuery = '';
      sortOption = 'none';
    });
    fetchSitters();
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFFFF6600);

    // Filter & Sort
    List<Sitter> filteredSitters = sitters.where((sitter) {
      final name = sitter.name.toLowerCase();
      return searchQuery.isEmpty || name.contains(searchQuery);
    }).toList();

    if (sortOption == 'low_to_high') {
      filteredSitters.sort((a, b) => a.price.compareTo(b.price));
    } else if (sortOption == 'high_to_low') {
      filteredSitters.sort((a, b) => b.price.compareTo(a.price));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('ค้นหาผู้รับฝากสัตว์เลี้ยง'),
        centerTitle: true,
        backgroundColor: primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _reloadPage,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
          ? Center(child: Text(errorMessage!))
          : Column(
        children: [
          // 🔎 Search + Sort
          Container(
            padding: const EdgeInsets.all(16),
            color: primaryColor.withOpacity(0.05),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Box
                TextField(
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value.toLowerCase();
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'ค้นหาผู้รับฝากสัตว์เลี้ยง...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: primaryColor),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: primaryColor,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Sort Dropdown
                Row(
                  children: [
                    const Text("เรียงราคา: "),
                    const SizedBox(width: 8),
                    DropdownButton<String>(
                      value: sortOption,
                      items: const [
                        DropdownMenuItem(
                          value: 'none',
                          child: Text('ไม่เรียง'),
                        ),
                        DropdownMenuItem(
                          value: 'low_to_high',
                          child: Text('น้อยไปมาก'),
                        ),
                        DropdownMenuItem(
                          value: 'high_to_low',
                          child: Text('มากไปน้อย'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          sortOption = value!;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // 📝 List of Sitters
          Expanded(
            child: ListView.builder(
              itemCount: filteredSitters.length,
              itemBuilder: (context, index) {
                final sitter = filteredSitters[index];

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: sitter.image != null &&
                          sitter.image!.isNotEmpty
                          ? Image.memory(
                        base64Decode(sitter.image!),
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      )
                          : const Icon(Icons.person, size: 50),
                    ),
                    title: Text(
                      sitter.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'ที่อยู่: ${sitter.address}\n'
                            'บริการ: ${sitter.service}\n'
                            'ราคา: ${sitter.price.toStringAsFixed(0)} บาท',
                        style: const TextStyle(height: 1.4),
                      ),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 18,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SitterDetailPage(
                            sitterId: sitter.id!,
                            name: sitter.name,
                            address: sitter.address,
                            service: sitter.service,
                            price: sitter.price,
                            phone: sitter.phone,
                            lineId: sitter.lineId,
                            facebookLink: sitter.facebookLink,
                            instagramLink: sitter.instagramLink,
                            imageAsset: sitter.image,
                            userEmail: userEmail, // ✅ ส่งค่า email
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      backgroundColor: Colors.grey[100],
    );
  }
}
