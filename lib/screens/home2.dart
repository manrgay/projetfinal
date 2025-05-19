import 'package:flutter/material.dart';
import 'sitter_detail_page.dart';

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

  final List<Map<String, dynamic>> sitters = [
    {
      'name': 'ผู้รับฝากสัตว์เลี้ยง 1',
      'location': 'หน้ามหาวิทยาลัยพะเยา',
      'distance': 1.0,
      'price': 150.0,
      'image': 'assets/1234.png'
    },
    {
      'name': 'ผู้รับฝากสัตว์เลี้ยง 2',
      'location': 'ในเมืองพะเยา',
      'distance': 1.5,
      'price': 200.0,
      'image': 'assets/1.png'
    },


  ];

  void _reloadPage() {
    setState(() {
      maxDistance = null;
      maxPrice = null;
      distanceController.clear();
      priceController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFFFF6600);

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
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: primaryColor.withOpacity(0.05),
            child: Column(
              children: [
                TextField(
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
                      borderSide: BorderSide(color: primaryColor, width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: distanceController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'ระยะทางสูงสุด (กม.)',
                          filled: true,
                          fillColor: Colors.white,
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: primaryColor),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: primaryColor, width: 2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            maxDistance = double.tryParse(value);
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: priceController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'เรทราคาสูงสุด (บาท)',
                          filled: true,
                          fillColor: Colors.white,
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: primaryColor),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: primaryColor, width: 2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            maxPrice = double.tryParse(value);
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: sitters.length,
              itemBuilder: (context, index) {
                final sitter = sitters[index];
                double distance = sitter['distance'];
                double price = sitter['price'];

                if ((maxDistance != null && distance > maxDistance!) ||
                    (maxPrice != null && price > maxPrice!)) {
                  return const SizedBox.shrink();
                }

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        sitter['image'],
                        width: 50, // ขนาดรูปใหม่
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Text(
                      sitter['name'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'ที่อยู่: ${sitter['location']}\n'
                            'ระยะทาง: ${distance.toStringAsFixed(1)} กม.\n'
                            'ราคา: ${price.toStringAsFixed(0)} บาท',
                        style: const TextStyle(height: 1.4),
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SitterDetailPage(
                            name: sitter['name'],
                            location: sitter['location'],
                            distance: sitter['distance'],
                            price: sitter['price'],
                            imageAsset: sitter['image'],
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

  @override
  void dispose() {
    distanceController.dispose();
    priceController.dispose();
    super.dispose();
  }
}
