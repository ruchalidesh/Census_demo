import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'HomeScreen.dart';
import 'registerScreen.dart';

class AppBarColor {
  static Color appBarColor = Color.fromARGB(255, 125, 197, 197);
}

class OtpScreen extends StatefulWidget {
  final String username; // Username from login screen
  final String otp; // OTP from the server response
  final String phoneNumber = "8657974925";
  final String token;

  OtpScreen({
    required this.username,
    required this.otp,
    required this.token,
  });

  @override
  _OtpScreenState createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> with TickerProviderStateMixin {
  final List<TextEditingController> _otpControllers = List.generate(6, (_) => TextEditingController());
  late Timer _timer;
  int _start = 20;
  bool _isResendAvailable = false;

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;
  String apiUrlOTP = 'http://10.210.4.106:8091/validateOTP1';

  @override
  void initState() {
    super.initState();
    _startTimer();

    // Set up scale animation for auto-filling OTP
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300), // Speed of the animation
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _colorAnimation = ColorTween(
      begin: Colors.grey,
      end: AppBarColor.appBarColor,
    ).animate(_animationController);

    // Auto-fill OTP with animation
    _autoFillOtp(widget.otp);
  }

  @override
  void dispose() {
    _timer.cancel();
    _animationController.dispose();
    _otpControllers.forEach((controller) => controller.dispose());
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_start > 0) {
        setState(() {
          _start--;
        });
      } else {
        setState(() {
          _isResendAvailable = true;
          _animationController.forward();
        });
        _timer.cancel();
      }
    });
  }

  void _autoFillOtp(String otp) {
    Future.delayed(Duration(milliseconds: 500), () {
      for (int i = 0; i < otp.length; i++) {
        _otpControllers[i].text = otp[i];
        _animationController.forward().then((_) {
          _animationController.reverse();
        });
      }
    });
  }

  void _resendOtp() {
    setState(() {
      _start = 60;
      _isResendAvailable = false;
      _animationController.stop();
      _startTimer();
      _otpControllers.forEach((controller) => controller.clear());
    });
  }

  Future<void> _verifyOtp() async {
    String enteredOtp = _otpControllers.map((controller) => controller.text).join();

    try {
      final response = await http.post(
        Uri.parse(apiUrlOTP),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'username': widget.username,
          'otp': enteredOtp,
          'token': widget.token,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print("Response_from_API_For_Otp: $responseData");
        print("Status_Message_OTP: ${responseData['message']}");

        if (responseData['status'] == true) {
          print("Success_OTP");
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                title: Column(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      color: Colors.green,
                      size: 60,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Registration Successful!',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                content: Text(
                  'Your device is successfully registered!!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18),
                ),
                actions: <Widget>[
                  TextButton(
                    child: Text("OK"),
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HomeScreen(),
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Incorrect OTP, please try again.'),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${response.statusCode}. Please try again.'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Network error. Please try again.'),
        ),
      );
    }
  }

  String _hideMobileNumber(String mobileNumber) {
    return mobileNumber.replaceRange(3, 7, '****');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('OTP Verification'),
        backgroundColor: AppBarColor.appBarColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => RegisterScreen()),
            );
          },
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, AppBarColor.appBarColor.withOpacity(0.1)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Hello ${widget.username},',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Thank you for registering with us. Please type the OTP as shared on your mobile ${_hideMobileNumber(widget.phoneNumber)}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(6, (index) {
                return ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    width: 40,
                    child: TextField(
                      controller: _otpControllers[index],
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        counterText: '',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: AppBarColor.appBarColor,
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      onChanged: (value) {
                        if (value.length == 1 && index < 5) {
                          FocusScope.of(context).nextFocus();
                        } else if (value.isEmpty && index > 0) {
                          FocusScope.of(context).previousFocus();
                        }
                      },
                    ),
                  ),
                );
              }),
            ),
            SizedBox(height: 40),
            SizedBox(
              width: 250,
              child: ElevatedButton(
                onPressed: _verifyOtp,
                child: Text('Submit'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppBarColor.appBarColor,
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  textStyle: TextStyle(fontSize: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            SizedBox(height: 30),
            AnimatedBuilder(
              animation: _colorAnimation,
              builder: (context, child) {
                return TextButton(
                  onPressed: _isResendAvailable ? _resendOtp : null,
                  child: Text(
                    'OTP not received? RESEND',
                    style: TextStyle(
                      color: _isResendAvailable ? _colorAnimation.value : Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                );
              },
            ),
            if (!_isResendAvailable)
              Text(
                'Resend OTP in $_start seconds',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
