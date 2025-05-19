import 'package:flutter/material.dart';

class EditProfileScreen extends StatefulWidget {
  final String firstName;
  final String email;

  const EditProfileScreen({
    super.key,
    required this.firstName,
    required this.email,
  });

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _firstName;
  late String _email;

  @override
  void initState() {
    super.initState();
    _firstName = widget.firstName;
    _email = widget.email;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('แก้ไขโปรไฟล์'),
        backgroundColor: Colors.orangeAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: _firstName,
                decoration: InputDecoration(labelText: 'ชื่อผู้ใช้'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'กรุณากรอกชื่อผู้ใช้';
                  }
                  return null;
                },
                onSaved: (value) {
                  _firstName = value!;
                },
              ),
              TextFormField(
                initialValue: _email,
                decoration: InputDecoration(labelText: 'อีเมล'),
                validator: (value) {
                  if (value == null || value.isEmpty || !value.contains('@')) {
                    return 'กรุณากรอกอีเมลที่ถูกต้อง';
                  }
                  return null;
                },
                onSaved: (value) {
                  _email = value!;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveProfile,
                child: Text('บันทึกการเปลี่ยนแปลง'),
                style: ElevatedButton.styleFrom(
                  primary: Colors.orangeAccent,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      // แสดงข้อความสำเร็จหรือทำการอัปเดตข้อมูลโปรไฟล์
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('ข้อมูลโปรไฟล์ของคุณได้รับการอัปเดตแล้ว')));

      // หลังจากบันทึกข้อมูลเสร็จ ส่งข้อมูลกลับไปยังหน้า HomeScreen
      Navigator.pop(context, {
        'firstName': _firstName,
        'email': _email,
      });
    }
  }
}
