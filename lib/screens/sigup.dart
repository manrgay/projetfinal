import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  String _userType = 'owner'; // Default to 'owner'
  bool _isLoading = false;

  Future<void> _signup() async {
    setState(() {
      _isLoading = true;
    });

    final response = await http.post(
      Uri.parse('http://10.0.2.2:3000/api/auth/signup'), // API URL
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': _emailController.text,
        'password': _passwordController.text,
        'firstName': _firstNameController.text,
        'lastName': _lastNameController.text,
        'userType': _userType, // Send user type
      }),
    );

    setState(() {
      _isLoading = false;
    });

    if (response.statusCode == 200) {
      // Handle successful signup (e.g., show a success message or redirect to login)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Signup successful!')),
      );
    } else {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Signup failed! Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Signup')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _firstNameController,
              decoration: InputDecoration(labelText: 'First Name'),
            ),
            TextField(
              controller: _lastNameController,
              decoration: InputDecoration(labelText: 'Last Name'),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Password'),
            ),
            DropdownButton<String>(
              value: _userType,
              onChanged: (String? newValue) {
                setState(() {
                  _userType = newValue!;
                });
              },
              items: <String>['owner', 'sitter']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _signup,
              child: _isLoading
                  ? CircularProgressIndicator()
                  : Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}
