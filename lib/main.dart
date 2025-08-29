import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/home_screen.dart';
import 'screens/login.dart';
import 'owner/petdata.dart';
import 'screens/home2.dart';
import 'owner/petlist.dart';
import 'owner/history.dart';
import 'sitter/address.dart';
import 'sitter/requests.dart';
import 'owner/pet_status_screen.dart';
import 'sitter/update2.dart';
import 'screens/SettingsScreen.dart';

import 'owner/pet_provider.dart';
import 'owner/cancel.dart';
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => PetProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<bool> _hasSavedToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return token != null && token.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pet Boarding',
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<bool>(
        future: _hasSavedToken(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData && snapshot.data == true) {
            return const HomeScreen();
          }
          return const LoginScreen();
        },
      ),
      routes: {
        '/pet-info': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as String?;
          if (args != null) {
            return PetFormScreen(userEmail: args);
          }
          return const Center(child: Text('ไม่มีอีเมลผู้ใช้'));
        },
        '/booking': (context) => HomePage(),
        '/pet-list': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as String?;
          if (args != null) {
            return MyPetsScreen(userEmail: args);
          }
          return const Center(child: Text('ไม่มีอีเมลผู้ใช้'));
        },
        '/history': (context) => DepositHistoryScreen(),
        '/extends': (context) => AddSitterScreen(),
        '/requests': (context) => DepositRequestListScreen(),
        '/update': (context) => const PetStatusExampleScreen(),
        '/update2': (context) => const PetStatusScreen(),
        '/settings': (context) => SettingsScreen(),
        '/login': (context) => const LoginScreen(),

        '/cancel': (context) => const OwnerBookingScreen(),
      },
    );
  }
}
