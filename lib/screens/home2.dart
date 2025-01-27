import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pet Sitter Finder',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController distanceController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  double? maxDistance;
  double? maxPrice;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ค้นหาผู้รับฝากสัตว์เลี้ยง'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'ค้นหาผู้รับฝากสัตว์เลี้ยง...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: distanceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'ระยะทางสูงสุด (กม.)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      maxDistance = double.tryParse(value);
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'เรทราคาสูงสุด (บาท)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      maxPrice = double.tryParse(value);
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: 10, // จำนวนผู้รับฝากสัตว์เลี้ยง (แก้ไขได้)
              itemBuilder: (context, index) {
                // ตัวอย่างข้อมูลระยะทางและราคา
                double distance = (index + 1) * 2.5; // ระยะทาง (สมมติ)
                double price = (index + 1) * 100; // ราคา (สมมติ)

                if ((maxDistance != null && distance > maxDistance!) ||
                    (maxPrice != null && price > maxPrice!)) {
                  return const SizedBox.shrink(); // ซ่อนรายการที่ไม่ตรงเงื่อนไข
                }

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: AssetImage('assets/pet_sitter_${index + 1}.jpg'), // ใส่รูปภาพจาก asset
                    ),
                    title: Text('ผู้รับฝากสัตว์เลี้ยง ${index + 1}'),
                    subtitle: Text('ที่อยู่: บางนา, กรุงเทพฯ\nระยะทาง: ${distance.toStringAsFixed(1)} กม.\nราคา: ${price.toStringAsFixed(0)} บาท'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      // เพิ่มการทำงานเมื่อคลิกที่ผู้รับฝากสัตว์เลี้ยง
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    distanceController.dispose();
    priceController.dispose();
    super.dispose();
  }
}
