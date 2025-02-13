// home.dart
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
      'image': 'assets/pet_sitter_1.jpg'
    },
    {
      'name': 'ผู้รับฝากสัตว์เลี้ยง 2',
      'location': 'ในเมืองพะเยา',
      'distance': 1.5,
      'price': 200.0,
      'image': 'assets/pet_sitter_2.jpg'
    },
    {
      'name': 'ผู้รับฝากสัตว์เลี้ยง 3',
      'location': 'หน้ามหาวิทยาลัยพะเยา',
      'distance': 1.5,
      'price': 180.0,
      'image': 'assets/pet_sitter_3.jpg'
    },
    {
      'name': 'ผู้รับฝากสัตว์เลี้ยง 4',
      'location': 'ในเมืองพะเยา',
      'distance': 17.5,
      'price': 220.0,
      'image': 'assets/pet_sitter_4.jpg'
    }
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('ค้นหาผู้รับฝากสัตว์เลี้ยง'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _reloadPage,
          ),
        ],
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: AssetImage(sitter['image']),
                    ),
                    title: Text(sitter['name']),
                    subtitle: Text('ที่อยู่: ${sitter['location']}\nระยะทาง: ${distance.toStringAsFixed(1)} กม.\nราคา: ${price.toStringAsFixed(0)} บาท'),
                    trailing: const Icon(Icons.arrow_forward_ios),
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
    );
  }

  @override
  void dispose() {
    distanceController.dispose();
    priceController.dispose();
    super.dispose();
  }
}