import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pethub_admin/routes/app_routes.dart';
import 'package:pethub_admin/user_module/adoption_history.dart';
import 'package:pethub_admin/user_module/settings_screen.dart';
import 'package:pethub_admin/user_module/user_information_screen.dart';
import 'package:pethub_admin/user_module/wishlist_screen.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late User? _user;
  late Map<String, dynamic>? _userData = {};
  File? _pickedImage;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    _user = FirebaseAuth.instance.currentUser;

    if (_user != null) {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(_user!.uid)
          .get();

      if (userSnapshot.exists) {
        _userData = userSnapshot.data() as Map<String, dynamic>;
      }

      setState(() {});
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();

    try {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          _pickedImage = File(pickedFile.path);
        });

        // Call uploadProfileImage only when an image is selected
        await uploadProfileImage();
      } else {
        print("No image selected");
        // Handle the case where no image is selected
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("No image selected")));
      }
    } catch (e) {
      print("Error picking image: $e");
      // Handle the error as needed
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error picking image")));
    }
  }

  Future<void> uploadProfileImage() async {
    if (_pickedImage != null) {
      var filename = DateTime.now().millisecondsSinceEpoch.toString();
      var destination = 'user_profile_images/$filename.jpg';
      Reference ref = FirebaseStorage.instance.ref().child(destination);

      try {
        await ref.putFile(_pickedImage!);
        String downloadURL = await ref.getDownloadURL();

        print("Image uploaded successfully. Download URL: $downloadURL");

        // Update the profileImageURL field in Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(_user!.uid)
            .update({'profileImageURL': downloadURL});

        print("Firestore update successful.");

        // If the update is successful, you might want to refresh the user data
        await _loadCurrentUser();
      } catch (e) {
        print("Error uploading profile image: $e");
        // Print the specific error message returned by Firebase Storage
        print("Firebase Storage error: ${e.toString()}");

        // Handle the error as needed
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error uploading profile image")));
      }
    } else {
      print("No image selected");
      // Handle the case where no image is selected
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("No image selected")));
    }
  }

  Widget buildCard(String title, IconData leadingIcon, VoidCallback onTap,
      IconData trailingIcon) {
    return Card(
      color: Colors.grey[300],
      margin: const EdgeInsets.only(left: 35, right: 35, bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      child: ListTile(
        leading: Icon(leadingIcon, color: Colors.black),
        title: Text(
          title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        trailing: Icon(trailingIcon, color: Colors.black),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      // Display a loading indicator or handle the case when the user is null
      return CircularProgressIndicator();
    }
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Container(
          color: Colors.white,
          child: Column(
            children: [
              const SizedBox(
                height: 15,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    children: [
                      GestureDetector(
                        onTap: () => _pickImage(),
                        child: CircleAvatar(
                          maxRadius: 65,
                          child: _pickedImage != null
                              ? ClipOval(
                                  child: Image.file(
                                    _pickedImage!,
                                    fit: BoxFit.cover,
                                    width: 130.0,
                                    height: 130.0,
                                  ),
                                )
                              : (_userData != null &&
                                      _userData!.isNotEmpty &&
                                      _userData!['profileImageURL'] is String)
                                  ? ClipOval(
                                      child: Image.network(
                                        _userData!['profileImageURL'],
                                        fit: BoxFit.cover,
                                        width: 130.0,
                                        height: 130.0,
                                      ),
                                    )
                                  : Icon(
                                      Icons.person,
                                      size: 65,
                                      color: Colors.white,
                                    ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: EdgeInsets.all(4.0),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          child: Icon(
                            Icons.photo_camera,
                            size: 20.0,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(
                height: 15,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    (_userData != null &&
                            _userData!.isNotEmpty &&
                            _userData!['name'] is String)
                        ? _userData!['name']
                        : "User",
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 26),
                  )
                ],
              ),
              const SizedBox(
                height: 15,
              ),
              Expanded(
                child: ListView(
                  children: [
                    const SizedBox(height: 10),
                    buildCard("User Information", Icons.person, () {
                      _onTapUserInformation(context);
                    }, Icons.arrow_forward_ios_outlined),
                    const SizedBox(height: 10),
                    buildCard("Adoption History", Icons.receipt, () {
                      _onTapAdoptionHistory(context);
                    }, Icons.arrow_forward_ios_outlined),
                    const SizedBox(height: 10),
                    buildCard("Wish List", Icons.favorite, () {
                      _onTapWishlist(context);
                    }, Icons.arrow_forward_ios_outlined),
                    const SizedBox(height: 10),
                    buildCard("Settings", Icons.settings, () {
                      _onTapSettings(context);
                    }, Icons.arrow_forward_ios_outlined),
                    const SizedBox(
                      height: 10,
                    ),
                    buildCard("Logout", Icons.logout, () {
                      _onTapLogout(context);
                    }, Icons.arrow_forward_ios_outlined),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onTapSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SettingsScreen()),
    );
  }

  void _onTapAdoptionHistory(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => OrderHistoryPage()),
    );
  }

  void _onTapWishlist(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => WishlistPage()),
    );
  }

  void _onTapUserInformation(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserInformationScreen(),
      ),
    );
  }

  void _onTapLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Log Out",
            style: TextStyle(color: Colors.black),
          ),
          content: Text("Are you sure you want to log out?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                // ignore: use_build_context_synchronously
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.loginScreen,
                  (route) => false,
                );
              },
              child: Text("Log Out"),
            ),
          ],
        );
      },
    );
  }
}
