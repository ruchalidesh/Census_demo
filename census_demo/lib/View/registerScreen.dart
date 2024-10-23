import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http; // Import http package
import 'dart:convert';
import '../colors/appbarcolor.dart';
import 'loginScreen.dart';
import 'otpScreen.dart'; // Import for JSON encoding/decoding

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  String? selectedRole;
  String? selectedSubRole;
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController enumeratorIdController = TextEditingController();
  final TextEditingController supervisorIdController = TextEditingController();

  static Color appBarColor = Color.fromARGB(255, 125, 197, 197);
  List<String> roles = ['HLO','NPR','PE'];
  List<String> subRoles = ['Enumerator', 'Supervisor'];

  late String username;
  late String password;
  late String phoneNumber;
  late String enumeratorId;
  late String supervisorId;
  late String modelName;
  late String imeiNumber;
  late String otp;
  late String token;

  // API endpoint (Replace with your actual endpoint)
  String apiUrl = 'http://10.210.4.106:8091/validate';
  bool _obscurePassword = true;

  Future<Map<String, String>> fetchDeviceInfo() async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    Map<String, String> deviceData = {};

    try {
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        deviceData['modelName'] = androidInfo.model ?? "Unknown";
        deviceData['imeiNumber'] = androidInfo.id; // Note: using id instead of IMEI
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        deviceData['modelName'] = iosInfo.utsname.machine ?? "Unknown";
        deviceData['imeiNumber'] = "Not Available on iOS"; // iOS does not expose IMEI directly
      }
    } on PlatformException {
      deviceData['modelName'] = "Failed to get device info.";
      deviceData['imeiNumber'] = "Failed to get device info.";
    }

    return deviceData;
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
            // Full-width Banner
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
                          'Register',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),
                        DropdownButtonFormField<String>(
                          value: selectedRole,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Select Phase',
                          ),
                          items: roles.map((String role) {
                            return DropdownMenuItem<String>(
                              value: role,
                              child: Text(role),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedRole = value;
                              selectedSubRole = null; // Reset sub-role when role changes
                            });
                          },
                        ),
                        if (selectedRole != null) ...[
                          SizedBox(height: 20),
                          Text(
                            'Select Role',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          DropdownButtonFormField<String>(
                            value: selectedSubRole,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Select Role',
                            ),
                            items: subRoles.map((String subRole) {
                              return DropdownMenuItem<String>(
                                value: subRole,
                                child: Text(subRole),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedSubRole = value;
                              });
                            },
                          ),
                        ],
                        // Conditional field for Enumerator ID
                        if (selectedSubRole == 'Enumerator') ...[
                          SizedBox(height: 20),
                          TextField(
                            controller: enumeratorIdController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Enumerator ID',
                              hintText: 'Enter Enumerator ID',
                            ),
                          ),
                        ],
                        // Conditional field for Supervisor ID
                        if (selectedSubRole == 'Supervisor') ...[
                          SizedBox(height: 20),
                          TextField(
                            controller: supervisorIdController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Supervisor ID',
                              hintText: 'Enter Supervisor ID',
                            ),
                          ),
                        ],
                        SizedBox(height: 20),
                        TextField(
                          controller: usernameController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Username',
                            hintText: 'Enter Username',
                          ),
                        ),
                        SizedBox(height: 20),
                        TextField(
                          controller: phoneController,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(10),
                          ],
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Phone Number',
                            hintText: 'Enter Phone Number',
                          ),
                        ),
                        SizedBox(height: 20),
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
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              // Call registration method on button press
                              register();
                              print("Register Button Pressed");
                            },
                            child: Text('Register'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                              appBarColor, // Match appBar color
                              padding: EdgeInsets.symmetric(vertical: 16.0),
                              textStyle: TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Center(
                          child: TextButton(
                            onPressed: () {
                              // Navigate to LoginScreen when clicked
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => LoginScreen()),
                              );
                            },
                            child: Text(
                              'Already registered? Click here to login.',
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


  Future<void> register() async {
    username = usernameController.text.trim();
    password = passwordController.text.trim();
    phoneNumber = phoneController.text.trim();
    enumeratorId = enumeratorIdController.text.trim();
    supervisorId = supervisorIdController.text.trim();


    // Validate fields before making API call
    if (username.isEmpty) {
      _showErrorDialog('Username cannot be empty.');
      return;
    }

    if (password.isEmpty) {
      _showErrorDialog('Password cannot be empty.');
      return;
    }

    if (phoneNumber.isEmpty || !RegExp(r'^\d{10}$').hasMatch(phoneNumber)) {
      _showErrorDialog('Please enter a valid 10-digit phone number.');
      return;
    }

    if (enumeratorId.isEmpty) {
      _showErrorDialog('Enumerator ID cannot be empty.');
      return;
    }

    // Fetch device info
    Map<String, String> deviceInfo = await fetchDeviceInfo();
    modelName = deviceInfo['modelName'] ?? "Unknown";
    imeiNumber = deviceInfo['imeiNumber'] ?? "Unknown";

    // Create a map of the request body
    Map<String, dynamic> requestBody = {
      'username': username,
      'enumeratorId': enumeratorId,
      'supervisorId': null,
      'password': password,
      'phoneNumber': phoneNumber,
      'deviceId': imeiNumber,
      'modelName': modelName,
    };

    // Print the details being sent to the API
    print("Sending the following details to the API:");
    print(json.encode(requestBody));

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

      // Decode the response body regardless of the status code
      final responseData = json.decode(response.body);

      // Check if the response is successful
      if (response.statusCode == 200) {
        print("Response from API: $responseData");
        print("Status Message: ${responseData['message']}");
        print("token: ${responseData['token']}");

        if (responseData['status'] == true) {
          // Login successful
          otp = responseData['otp'];
          token = responseData['token'];
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => OtpScreen(
                username: username,
                otp: otp,
                token: token,
              ),
            ),
          );
        } else {
          // Handle failure case for successful response code
          if (responseData['message'] == "Different userid is logged with same device") {
            _showErrorDialog('Different user ID is logged with the same device.');
          }else if (responseData['message'] == "User is registered with different device") {
            _showErrorDialog('User is registered with different device.');
          }else {
            _showErrorDialog('Error: ${responseData['message']}');
          }
        }
      } else {
        // For non-200 responses, show the appropriate message
        if(responseData['message'] == "Different userid is logged with same device") {
          _showErrorDialog('Different user ID is logged with the same device.');
        }else if (responseData['message'] == "User is registered with different device") {
          _showErrorDialog('User is registered with different device.');
        }else {
          _showErrorDialog('Error: ${responseData['message']}');
        }
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



 /* @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Register',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: appBarColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              print('No previous screen to go back to.');
            } // Navigate back to the previous screen
          },
        ),
      ),
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
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(0),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        height: MediaQuery.of(context).size.height * 0.1,
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
                      // Login form
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Container(
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
                                    'Select Phase',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  DropdownButtonFormField<String>(
                                    value: selectedRole,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: 'Select Phase',
                                    ),
                                    items: roles.map((String role) {
                                      return DropdownMenuItem<String>(
                                        value: role,
                                        child: Text(role),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        selectedRole = value;
                                        selectedSubRole = null; // Reset sub-role when role changes
                                      });
                                    },
                                  ),
                                  if (selectedRole != null) ...[
                                    SizedBox(height: 20),
                                    Text(
                                      'Select Role',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    DropdownButtonFormField<String>(
                                      value: selectedSubRole,
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(),
                                        labelText: 'Select Role',
                                      ),
                                      items: subRoles.map((String subRole) {
                                        return DropdownMenuItem<String>(
                                          value: subRole,
                                          child: Text(subRole),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          selectedSubRole = value;
                                        });
                                      },
                                    ),
                                  ],
                                  // Conditional field for Enumerator ID
                                  if (selectedSubRole == 'Enumerator') ...[
                                    SizedBox(height: 20),
                                    TextField(
                                      controller: enumeratorIdController,
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(),
                                        labelText: 'Enumerator ID',
                                        hintText: 'Enter Enumerator ID',
                                      ),
                                    ),
                                  ],
                                  // Conditional field for Supervisor ID
                                  if (selectedSubRole == 'Supervisor') ...[
                                    SizedBox(height: 20),
                                    TextField(
                                      controller: supervisorIdController,
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(),
                                        labelText: 'Supervisor ID',
                                        hintText: 'Enter Supervisor ID',
                                      ),
                                    ),
                                  ],
                                  SizedBox(height: 20),
                                  TextField(
                                    controller: usernameController,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: 'Username',
                                      hintText: 'Enter Username',
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                  TextField(
                                    controller: phoneController,
                                    keyboardType: TextInputType.phone,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(10),
                                    ],
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: 'Phone Number',
                                      hintText: 'Enter Phone Number',
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                  TextField(
                                    controller: passwordController,
                                    obscureText: _obscurePassword,
                                    //obscureText: true,
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
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        // Call login method on button press
                                        login();
                                        //otpScreen();
                                        print("login_Button_pressed");
                                      },
                                      child: Text('Register'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                        appBarColor, // Match appBar color
                                        padding: EdgeInsets.symmetric(vertical: 16.0),
                                        textStyle: TextStyle(fontSize: 18),
                                      ),
                                    ),
                                  ),
                                  // Informative text about logging in
                                  SizedBox(height: 20),
                                  Center(
                                    child: TextButton(
                                      onPressed: () {
                                        // Navigate to LoginScreen when clicked
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(builder: (context) => LoginScreen()),
                                        );
                                      },
                                      child: Text(
                                        'Already registered? Click here to login.',
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
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }*/








/*
  void otpScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => OtpScreen(
        username: username, // Pass the username here
        otp: otp,
      )),
    );
  }
*/


}
