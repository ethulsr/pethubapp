import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pethub_admin/user_module/pet_screen.dart';

class HomePage extends StatelessWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder(
              // Fetch banner image URL from the database (replace with your logic)
              future: fetchBannerImageUrl(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error loading banner');
                } else if (!snapshot.hasData || snapshot.data == null) {
                  return Container(); // Display nothing if there's no banner
                } else {
                  return Image.network(
                    snapshot.data as String,
                    fit: BoxFit.cover,
                  );
                }
              },
            ),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "Pets",
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: ProductList(
                sortOption: '',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<String> fetchBannerImageUrl() async {
    // Example: Fetch banner image URL from Firestore
    DocumentSnapshot bannerSnapshot = await FirebaseFirestore.instance
        .collection('banners')
        .doc('bannerId')
        .get();

    // Replace 'bannerImageUrl' with the actual field name in your database
    return bannerSnapshot['bannerImageUrl'] ?? '';
  }
}
