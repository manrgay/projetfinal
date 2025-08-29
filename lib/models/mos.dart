import 'package:flutter/material.dart';

void main() {
  runApp(const PetBoardingApp());
}

class PetBoardingApp extends StatelessWidget {
  const PetBoardingApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pet Boarding Demo',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        useMaterial3: true,
      ),
      home: const PetBoardingShopPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class PetBoardingShopPage extends StatefulWidget {
  const PetBoardingShopPage({Key? key}) : super(key: key);

  @override
  State<PetBoardingShopPage> createState() => _PetBoardingShopPageState();
}

class _PetBoardingShopPageState extends State<PetBoardingShopPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _nameCtrl = TextEditingController();
  final _petNameCtrl = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String _selectedService = 'ฝากเลี้ยงรายวัน';

  final Map<String, int> _prices = {
    'ฝากเลี้ยงรายวัน': 300,
    'ฝากเลี้ยงรายคืน': 500,
    'อาบน้ำ ตัดขน': 250,
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameCtrl.dispose();
    _petNameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Puppy Paradise'),
        backgroundColor: Colors.orange,
      ),
      body: Column(
        children: [
          // Header
          Container(
            color: Colors.orange[50],
            child: Column(
              children: [
                SizedBox(
                  height: 180,
                  width: double.infinity,
                  child: Image.network(
                    'https://images.unsplash.com/photo-1517423440428-a5a00ad493e8?auto=format&fit=crop&w=1200&q=60',
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Puppy Paradise',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.star, color: Colors.orange, size: 20),
                    Icon(Icons.star, color: Colors.orange, size: 20),
                    Icon(Icons.star, color: Colors.orange, size: 20),
                    Icon(Icons.star, color: Colors.orange, size: 20),
                    Icon(Icons.star_half, color: Colors.orange, size: 20),
                    SizedBox(width: 6),
                    Text('4.5 (120 รีวิว)'),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),

          // TabBar
          TabBar(
            controller: _tabController,
            labelColor: Colors.orange,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.orange,
            tabs: const [
              Tab(text: 'ข้อมูลร้าน'),
              Tab(text: 'บริการ & ราคา'),
              Tab(text: 'รีวิว'),
              Tab(text: 'แกลเลอรี'),
            ],
          ),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildShopInfo(),
                _buildServices(),
                _buildReviews(),
                _buildGallery(),
              ],
            ),
          ),
        ],
      ),

      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(12),
          color: Colors.white,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: () => _openBookingSheet(context),
            child: const Text(
              'จองเลย',
              style: TextStyle(fontSize: 18),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShopInfo() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        ListTile(
          leading: Icon(Icons.location_on),
          title: Text('ที่อยู่'),
          subtitle: Text('123 ถนนสัตว์เลี้ยง เขตบางรัก กรุงเทพฯ'),
        ),
        ListTile(
          leading: Icon(Icons.access_time),
          title: Text('เวลาเปิด–ปิด'),
          subtitle: Text('09:00 - 20:00'),
        ),
        ListTile(
          leading: Icon(Icons.phone),
          title: Text('เบอร์ติดต่อ'),
          subtitle: Text('081-234-5678'),
        ),
        Divider(),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Text(
              'ร้านรับฝากเลี้ยงสุนัขและแมว บรรยากาศอบอุ่น ปลอดภัย มีกล้องวงจรปิดและพนักงานดูแล 24 ชั่วโมง'),
        ),
      ],
    );
  }

  Widget _buildServices() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: _prices.entries.map((e) {
        return Card(
          child: ListTile(
            title: Text(e.key),
            trailing: Text('฿${e.value}'),
            onTap: () {
              setState(() => _selectedService = e.key);
              _openBookingSheet(context);
            },
          ),
        );
      }).toList(),
    );
  }

  Widget _buildReviews() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        ListTile(
          leading: CircleAvatar(child: Icon(Icons.person)),
          title: Text('คุณเอ'),
          subtitle: Text('ดูแลดีมาก น้องหมากลับมามีความสุข'),
        ),
        ListTile(
          leading: CircleAvatar(child: Icon(Icons.person)),
          title: Text('คุณบี'),
          subtitle: Text('บริการดี อาหารสะอาด'),
        ),
      ],
    );
  }

  Widget _buildGallery() {
    final imgs =
    List.generate(6, (i) => 'https://place-puppy.com/300x300?img=${i + 1}');
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: imgs.length,
      itemBuilder: (context, index) {
        return Image.network(imgs[index], fit: BoxFit.cover);
      },
    );
  }

  void _openBookingSheet(BuildContext context) {
    _selectedDate ??= DateTime.now().add(const Duration(days: 1));
    _selectedTime ??= const TimeOfDay(hour: 10, minute: 0);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom),
        child: StatefulBuilder(
          builder: (context, setState) {
            final price = _prices[_selectedService] ?? 0;
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _nameCtrl,
                    decoration:
                    const InputDecoration(labelText: 'ชื่อผู้จอง'),
                  ),
                  TextField(
                    controller: _petNameCtrl,
                    decoration:
                    const InputDecoration(labelText: 'ชื่อสัตว์เลี้ยง'),
                  ),
                  DropdownButtonFormField<String>(
                    value: _selectedService,
                    items: _prices.keys
                        .map((s) =>
                        DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (v) =>
                        setState(() => _selectedService = v ?? _selectedService),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('ยืนยันการจอง ฿$price'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
