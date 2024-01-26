import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  double _fontSize = 16.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              Text(
                'Font Size',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Slider(
                value: _fontSize,
                min: 12.0,
                max: 24.0,
                onChanged: (value) {
                  setState(() {
                    _fontSize = value;
                  });
                },
                label: 'Font Size: ${_fontSize.toStringAsFixed(1)}',
              ),
              SizedBox(height: 20),
              Center(
                child: Text(
                  'Privacy Policy',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width *
                      1.8, // Adjust the width as needed
                  margin: EdgeInsets.symmetric(vertical: 10.0),
                  padding: EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: _fontSize,
                        color: Colors.black, // Set your desired text color
                      ),
                      children: const [
                        TextSpan(
                          text: '1. Introduction\n',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text:
                              'Welcome to PetAdopt App ("we", "us", "our"). This Privacy Policy outlines our practices regarding the collection, use, and disclosure of personal information when you use our mobile application and services.\n\n',
                        ),
                        TextSpan(
                          text: '2. Information We Collect\n',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text:
                              '- Personal Information: We may collect personal information such as your name, email address, and phone number when you register or use our services.\n\n'
                              '- Device Information: We may collect information about your device, including device type, operating system, and unique device identifiers.\n\n',
                        ),
                        // Add similar TextSpan for other sections
                        TextSpan(
                          text: '3. How We Use Your Information\n',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text:
                              'We use the collected information for purposes such as:\n\n'
                              '- Providing and improving our services\n'
                              '- Communicating with you\n'
                              '- Personalizing your experience\n'
                              '- Analyzing usage and trends\n\n',
                        ),
                        TextSpan(
                          text: '4. Third-Party Services\n',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text:
                              'We may use third-party services that may collect information used to identify you. Please review their privacy policies.\n\n',
                        ),
                        TextSpan(
                          text: '5. Security\n',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text:
                              'We prioritize the security of your information but cannot guarantee absolute security. Please use our services responsibly and notify us of any security concerns.\n\n',
                        ),
                        TextSpan(
                          text: '6. Changes to This Privacy Policy\n',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text:
                              'We may update our Privacy Policy from time to time. You are advised to review this Privacy Policy periodically for changes.\n\n',
                        ),
                        TextSpan(
                          text: '7. Contact Us\n',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text:
                              'If you have any questions or concerns about this Privacy Policy, please contact us at privacy@petadoptapp.com.\n\n'
                              'This Privacy Policy is effective as of the date mentioned above and will remain in effect except regarding any changes in its provisions in the future, which will be in effect immediately after being posted on this page.\n',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: Text(
                  'Version 1.0.1',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
