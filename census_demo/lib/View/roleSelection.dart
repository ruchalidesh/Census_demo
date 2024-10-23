import 'package:flutter/material.dart';
import '../colors/appbarcolor.dart';
import 'registerScreen.dart';

class RoleSelection extends StatefulWidget {
  @override
  _RoleSelectionState createState() => _RoleSelectionState();
}

class _RoleSelectionState extends State<RoleSelection> {
  String? _selectedRole; // To store selected role

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Role Selection',
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
        backgroundColor: AppBarColor.appBarColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              print('No previous screen to go back to.');
            }
          },
        ),
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Please select your role:',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppBarColor.appBarColor,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 30),
            _buildRoleOption('HLO', Icons.person_outline),
            SizedBox(height: 20),
            _buildRoleOption('NPR', Icons.people_alt_outlined),
            SizedBox(height: 20),
            _buildRoleOption('PE', Icons.business_outlined),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: _selectedRole != null
                  ? () {
                 login(); // Navigate to login screen
              }
                  : null, // Disable button if no role is selected
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                backgroundColor: _selectedRole != null
                    ? AppBarColor.appBarColor
                    : Colors.grey, // Disable button color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                elevation: 5,
              ),
              child: Text(
                'Confirm',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build a card for each role option
  Widget _buildRoleOption(String role, IconData icon) {
    bool isSelected = _selectedRole == role;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedRole = role; // Update selected role
        });
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0), // Rounded corners
        ),
        elevation: 8,
        color: isSelected ? AppBarColor.appBarColor : Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          child: Row(
            children: [
              Icon(
                icon,
                size: 28,
                color: isSelected ? Colors.white : AppBarColor.appBarColor,
              ),
              SizedBox(width: 15),
              Expanded(
                child: Text(
                  role,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : Colors.black,
                  ),
                ),
              ),
              if (isSelected) Icon(Icons.check, color: Colors.white), // Check icon when selected
            ],
          ),
        ),
      ),
    );
  }

void login() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => RegisterScreen()),
    );
  }
}
