import 'package:flutter/material.dart';
import 'screens/home_screen.dart'; // หน้า Home
import 'screens/login.dart'; // หน้า Login
import 'owner/petdata.dart'; // หน้าเพิ่มข้อมูลสัตว์เลี้ยง
import 'screens/home2.dart';
import 'owner/petlist.dart';
import 'owner/history.dart';
import 'sitter/address.dart';
import 'sitter/requests.dart';
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pet Boarding',
      initialRoute: '/login',
      debugShowCheckedModeBanner: false,  // ลบ debug banner ออก
      routes: {
        '/login': (context) => LoginScreen(),
        '/home': (context) => HomeScreen(
          firstName: '', // Pass the necessary data
          email: '',
          userType: '',
        ),
        '/pet-info': (context) => PetFormScreen(),
        '/booking': (context) => HomePage(),
        '/pet-list': (context) => MyPetsScreen(),
        '/history': (context) => DepositHistoryScreen(),
        '/extends': (context) => FormPage(),
        '/requests': (context) => DepositRequestListScreen(),

      },
    );
  }
}
