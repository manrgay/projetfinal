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
      title: 'ฟอร์มกรอกข้อมูล',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFF6600), // เพิ่มสี #FF6600 สำหรับ AppBar
          foregroundColor: Colors.white, // ข้อความใน AppBar เป็นสีขาว
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Colors.white, // สีข้อความใน AppBar เป็นสีขาว
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
          iconTheme: IconThemeData(color: Colors.white), // ไอคอนใน AppBar เป็นสีขาว
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFFFFF3E0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide(color: Color(0xFFFF6600), width: 2),
          ),
          labelStyle: TextStyle(color: Colors.black),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFFFF6600), // สีส้มตามที่ต้องการ
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            textStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        switchTheme: SwitchThemeData(
          thumbColor: MaterialStateProperty.all(Color(0xFFFF6600)), // สีส้มสำหรับ switch
        ),
      ),
      home: const FormPage(),
    );
  }
}

class FormPage extends StatefulWidget {
  const FormPage({Key? key}) : super(key: key);

  @override
  State<FormPage> createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController serviceController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController lineController = TextEditingController();
  final TextEditingController facebookController = TextEditingController();
  final TextEditingController instagramController = TextEditingController();

  bool isPetFriendly = false;

  @override
  void dispose() {
    nameController.dispose();
    addressController.dispose();
    serviceController.dispose();
    priceController.dispose();
    phoneController.dispose();
    lineController.dispose();
    facebookController.dispose();
    instagramController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('กรอกข้อมูล'),
        backgroundColor: const Color(0xFFFF6600), // ตั้งค่า backgroundColor เป็น #FF6600
        leading: Navigator.canPop(context)
            ? IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        )
            : null,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            _buildTextField('ชื่อ', nameController, icon: Icons.person),
            const SizedBox(height: 16),
            _buildTextField('ที่อยู่', addressController, icon: Icons.home),
            const SizedBox(height: 16),
            _buildTextField('บริการ', serviceController, icon: Icons.miscellaneous_services),
            const SizedBox(height: 16),
            _buildPriceField(),
            const SizedBox(height: 24),
            _buildSwitch(),
            const SizedBox(height: 24),
            _buildTextField('เบอร์โทรติดต่อ', phoneController, icon: Icons.phone),
            const SizedBox(height: 16),
            _buildTextField('Line', lineController, icon: Icons.chat),
            const SizedBox(height: 16),
            _buildTextField('Facebook (ลิงก์)', facebookController, icon: Icons.facebook),
            const SizedBox(height: 16),
            _buildTextField('Instagram (ลิงก์)', instagramController, icon: Icons.camera_alt),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                _saveData();
              },
              child: const Text('บันทึก'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {IconData? icon, String? iconImage}) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null
            ? Icon(icon, color: Color(0xFFFF6600)) // ใช้สีส้มสำหรับไอคอน
            : (iconImage != null
            ? Padding(
          padding: const EdgeInsets.all(12.0),
          child: Image.asset(iconImage),
        )
            : null),
      ),
    );
  }

  Widget _buildPriceField() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: priceController,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.black),
            decoration: const InputDecoration(
              labelText: 'ราคา',
            ),
          ),
        ),
        const SizedBox(width: 8),
        const Text(
          'บาท/วัน',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildSwitch() {
    return Row(
      children: [
        const Text(
          'พิกัด:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(width: 16),
        Switch(
          value: isPetFriendly,
          activeColor: Color(0xFFFF6600), // สีส้มสำหรับ switch
          onChanged: (value) {
            setState(() {
              isPetFriendly = value;
            });
          },
        ),
      ],
    );
  }

  void _saveData() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('บันทึกข้อมูลเรียบร้อย')),
    );
  }
}
