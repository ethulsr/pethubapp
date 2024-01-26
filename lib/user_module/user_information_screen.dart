import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pethub_admin/user_module/cart_screen.dart';
import 'package:pethub_admin/user_module/home_page.dart';
import 'package:pethub_admin/user_module/search_screen.dart';

class UserInformationScreen extends StatefulWidget {
  const UserInformationScreen({Key? key}) : super(key: key);

  @override
  _UserInformationScreenState createState() => _UserInformationScreenState();
}

class _UserInformationScreenState extends State<UserInformationScreen> {
  int _currentIndex = 2;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _currentIndex == 2 // Check if it's the User Information screen
          ? AppBar(
              title: Text(_getPageTitle(_currentIndex)),
            )
          : AppBar(
              title: Text(_getPageTitle(_currentIndex)),
              automaticallyImplyLeading: false, // Disable back button
            ),
      body: Container(
        color: Colors.white,
        child: PageView(
          controller: _pageController,
          children: [
            HomePage(),
            SearchPage(),
            ProfileContent(), // Separate widget for User Information content
            CartPage(),
          ],
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.pink, // Customize selected item color
        unselectedItemColor: Colors.black, // Customize unselected item color
        iconSize: 30,
        onTap: (index) {
          _pageController.animateToPage(
            index,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
        ],
      ),
    );
  }

  String _getPageTitle(int index) {
    switch (index) {
      case 0:
        return '';
      case 1:
        return '';
      case 2:
        return ''; // Empty string for the User Information screen
      case 3:
        return '';
      default:
        return '';
    }
  }
}

class ProfileContent extends StatefulWidget {
  @override
  _ProfileContentState createState() => _ProfileContentState();
}

class _ProfileContentState extends State<ProfileContent> {
  late GlobalKey<FormState> _formKey;
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _addressWorkController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
    _nameController = TextEditingController();
    _addressController = TextEditingController();
    _addressWorkController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userSnapshot.exists) {
        Map<String, dynamic> userData =
            userSnapshot.data() as Map<String, dynamic>;

        _nameController = TextEditingController(text: userData['name']);
        _addressController = TextEditingController(text: userData['address']);
        _addressWorkController.text = userData['addressWork'];
        _emailController = TextEditingController(text: user.email);
        _phoneController = TextEditingController(text: userData['phonenumber']);
      }
    }

    setState(() {});
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Personal Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(),
                        filled:
                            true, // Set filled to true to enable background color
                        fillColor: Colors.grey[200]),
                    style: TextStyle(
                      fontWeight:
                          FontWeight.bold, // Set background color to white
                    ),

                    // You can add validation logic if needed
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _addressController,
                    decoration: InputDecoration(
                        labelText: 'Address',
                        border: OutlineInputBorder(),
                        filled:
                            true, // Set filled to true to enable background color
                        fillColor: Colors.grey[200]),
                    style: TextStyle(
                      fontWeight:
                          FontWeight.bold, // Set background color to white
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Address cannot be empty';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _addressWorkController,
                    decoration: InputDecoration(
                      labelText: 'Work Address',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.grey[200],
                    ),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                          filled:
                              true, // Set filled to true to enable background color
                          fillColor: Colors.grey[200]),
                      style: TextStyle(
                        fontWeight:
                            FontWeight.bold, // Set background color to white
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Email cannot be empty';
                        } else if (!RegExp(
                                r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$')
                            .hasMatch(value)) {
                          return 'Invalid email format';
                        }
                        return null;
                      }),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneController,
                    decoration: InputDecoration(
                        labelText: 'Phone Number',
                        border: OutlineInputBorder(),
                        filled:
                            true, // Set filled to true to enable background color
                        fillColor: Colors.grey[200]),
                    style: TextStyle(
                      fontWeight:
                          FontWeight.bold, // Set background color to white
                    ),
                    keyboardType: TextInputType
                        .phone, // Set keyboardType to TextInputType.phone
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly
                    ], // Allow only digits
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Phone Number cannot be empty';
                      } else if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
                        return 'Invalid phone number format';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      print('Submit button pressed');
                      // Check if the form is valid before submission
                      if (_formKey.currentState!.validate()) {
                        // Handle form submission here
                        // Update the user data in Firestore (example)
                        _updateUserData();

                        // Show the "Updated successfully" message
                        _showSnackBar('Updated successfully');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Colors.black, // Background color of the button
                      padding: EdgeInsets.symmetric(
                          vertical: 36.0, horizontal: 160.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: Text(
                      'Submit',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Function to update user data in Firestore (example)
  void _updateUserData() {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      print('Updating user data...');
      FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'name': _nameController.text,
        'address': _addressController.text,
        'addressWork': _addressWorkController.text,
        'phonenumber': _phoneController.text,
      }).then((_) {
        print('Update successful');
      }).catchError((error) {
        print('Error updating user data: $error');
      });
    }
  }
}
