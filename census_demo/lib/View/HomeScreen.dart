import 'package:flutter/material.dart';
import 'loginScreen.dart';


class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Screen'),
        backgroundColor: Color.fromARGB(255, 125, 197, 197), // Your custom app bar color
        actions: [
          IconButton(
            icon: Icon(Icons.logout), // Logout icon
            onPressed: () {
              _showLogoutConfirmationDialog(context);
            },
          ),
        ],
      ),
      body: Center(
        child: Text(
          'Welcome to HomeScreen',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  // Function to show the logout confirmation dialog
  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('Logout Confirmation'),
          content: Text('Are you sure you want to logout?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop(); // Close the dialog
              },
              child: Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop(); // Close the dialog
                // Navigate to the login screen
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()), // Navigate to LoginScreen
                );
              },
              child: Text('Yes'),
            ),
          ],
        );
      },
    );
  }
}
