import 'package:flutter/material.dart';
import 'package:census_demo/View/roleSelection.dart';
import 'registerScreen.dart';

class AppBarColor {
  static Color appBarColor = Color.fromARGB(255, 125, 197, 197);
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Add a 3-second delay before navigating to LoginScreen
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => RegisterScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppBarColor.appBarColor, // Start color
              Colors.lightBlueAccent, // End color
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Load the image asset with shadow effect
              Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: Offset(0, 5), // changes position of shadow
                    ),
                  ],
                ),
                child: Image.asset(
                  'assets/images/logo_census.png',
                  width: 200, // Adjust the size as needed
                  height: 200,
                ),
              ),
              SizedBox(height: 20), // Add space between the image and the text
              // Display the main text with a shadow
              Text(
                'National Population Center',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // Change the color for better visibility
                  shadows: [
                    Shadow(
                      blurRadius: 10.0,
                      color: Colors.black.withOpacity(0.5),
                      offset: Offset(0.0, 2.0),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10), // Add space between the two text elements
              // Display the subtext with a shadow
              Text(
                'Developed and Managed by CDAC Mumbai',
                style: TextStyle(
                  fontSize: 18,
                  fontStyle: FontStyle.italic,
                  color: Colors.white70, // Lighter color for subtle effect
                  shadows: [
                    Shadow(
                      blurRadius: 10.0,
                      color: Colors.black.withOpacity(0.5),
                      offset: Offset(0.0, 2.0),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
