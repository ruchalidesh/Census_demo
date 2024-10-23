import 'dart:convert';
import 'package:census_demo/View/HomeScreen.dart';
import 'package:census_demo/View/registerScreen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'otpScreen.dart'; // Replace with actual OTP screen

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _obscurePassword = true;
  late String otp;
  late String token;
  late String message;
  String apiUrl = 'http://10.210.4.106:8091/validateLogin';


  Future<void> login() async {
    String username = usernameController.text.trim();
    String password = passwordController.text.trim();

    // Validate fields before making API call
    if (username.isEmpty) {
      _showErrorDialog('Username cannot be empty.');
      return;
    }

    if (password.isEmpty) {
      _showErrorDialog('Password cannot be empty.');
      return;
    }

    // Create the request body
    Map<String, dynamic> requestBody = {
      'username': username,
      'password': password,
    };

    try {
      // Making the API call
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      // Log the response for debugging
      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        if (responseData['status'] == true) {
          // Login successful, navigate to OTP screen
          otp = responseData['otp'];
          token = responseData['token'];
          message = responseData['message'];

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(
              ),
            ),
          );
        }else {
          _showErrorDialog('Invalid credentials. Please try again.');
        }
      }else {
          _showErrorDialog('Error: ${responseData['message']},Invalid Credentials');

      }
    } catch (error) {
      print("Error occurred: $error");
      _showErrorDialog('An error occurred. Please check your connection.');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing the dialog by tapping outside
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0), // Rounded corners
          ),
          elevation: 0, // No shadow
          backgroundColor: Colors.white, // Background color
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 40.0,
                ),
                SizedBox(height: 16.0),
                Text(
                  'Error',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0,
                  ),
                ),
                SizedBox(height: 10.0),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 20.0),
                TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: Colors.red, // Text color
                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0), // Rounded button
                    ),
                  ),
                  child: Text(
                    'OK',
                    style: TextStyle(fontSize: 16.0),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Colors.grey.shade300,
            ],
          ),
        ),
        child: Column(
          children: [
            // Full-width Banner (Same as Register screen)
            Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.2,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/banner_census3.jpeg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.6),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    padding: EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 20),
                        // Username field
                        TextField(
                          controller: usernameController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Username',
                            hintText: 'Enter Username',
                          ),
                        ),
                        SizedBox(height: 20),
                        // Password field
                        TextField(
                          controller: passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Password',
                            hintText: 'Enter Password',
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                        ),
                        SizedBox(height: 30),
                        // Login button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                             login();
                              print("Login Button Pressed");
                            },
                            child: Text('Login'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppBarColor.appBarColor, // Match appBar color
                              padding: EdgeInsets.symmetric(vertical: 16.0),
                              textStyle: TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Center(
                          child: TextButton(
                            onPressed: () {
                              // Implement forgot password functionality here
                              print("Forgot Password Button Pressed");
                            },
                            child: Text(
                              'Forgot Password?',
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        Center(
                          child: TextButton(
                            onPressed: () {
                              // Navigate to RegisterScreen when clicked
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => RegisterScreen()),
                              );
                            },
                            child: Text(
                              'Don\'t have an account? Register here.',
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
