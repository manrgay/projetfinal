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
        title: const Text('แก้ไขโปรไฟล์'),
        backgroundColor: Colors.orangeAccent,
      ),
      body: SingleChildScrollView(   // รองรับหน้าจอเลื่อนเมื่อคีย์บอร์ดขึ้น
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: _firstName,
                decoration: const InputDecoration(
                  labelText: 'ชื่อผู้ใช้',
                  border: OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'กรุณากรอกชื่อผู้ใช้';
                  }
                  return null;
                },
                onSaved: (value) {
                  _firstName = value!.trim();
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _email,
                decoration: const InputDecoration(
                  labelText: 'อีเมล',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                validator: (value) {
                  if (value == null || value.trim().isEmpty || !value.contains('@')) {
                    return 'กรุณากรอกอีเมลที่ถูกต้อง';
                  }
                  return null;
                },
                onSaved: (value) {
                  _email = value!.trim();
                },
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveProfile,
                  child: const Text('บันทึกการเปลี่ยนแปลง'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orangeAccent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ข้อมูลโปรไฟล์ของคุณได้รับการอัปเดตแล้ว')),
      );

      Navigator.pop(context, {
        'firstName': _firstName,
        'email': _email,
      });
    }
  }
}
