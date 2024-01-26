import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ignore: must_be_immutable
class ProductDetailsPage extends StatefulWidget {
  final String name;
  final String price;
  final String imageUrl;
  String description;

  ProductDetailsPage({
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.description,
    required String sex,
    required String color,
    required String age,
  });

  @override
  _ProductDetailsPageState createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  bool isFavorite = false;
  bool isLoading = true;
  late String sex = '';
  late String color = '';
  late String age = '';
  late User? user;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    fetchData();
  }

  void fetchData() async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('products')
              .where('name', isEqualTo: widget.name)
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        var data = querySnapshot.docs.first.data();
        setState(() {
          sex = data['sex'] ?? '';
          color = data['color'] ?? '';
          age = data['age'] ?? '';
          widget.description = data['description'] ?? '';
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Pet Details'),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10.0),
                      child: AspectRatio(
                        aspectRatio: 1.5,
                        child: CachedNetworkImage(
                          imageUrl: widget.imageUrl,
                          placeholder: (context, url) => Center(
                            child: CircularProgressIndicator(),
                          ),
                          errorWidget: (context, url, error) =>
                              Icon(Icons.error),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        setState(() {
                          if (isLoading) return;
                          if (user != null) {
                            isFavorite ? removeFromWishlist() : addToWishlist();
                          }
                          isFavorite = !isFavorite;
                        });
                      },
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.0),
                Text(
                  widget.name,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.0),
                Row(
                  children: [
                    Expanded(child: _buildDetailCard('Sex', sex)),
                    SizedBox(width: 8),
                    Expanded(child: _buildDetailCard('Color', color)),
                    SizedBox(width: 8),
                    Expanded(child: _buildDetailCard('Age', age)),
                  ],
                ),
                SizedBox(height: 16.0),
                _buildDescriptionCard(widget.description),
                SizedBox(height: 16.0),
                _buildPriceAndCartButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailCard(String title, String value) {
    return Card(
      elevation: 15,
      color: Colors.greenAccent,
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
              ),
            ),
            SizedBox(height: 4.0),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionCard(String description) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: Card(
        elevation: 10,
        color: Colors.blue[100],
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 8.0),
              Text(
                description,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriceAndCartButton() {
    return Row(
      children: [
        Expanded(
          flex: 4,
          child: _buildPriceCard(),
        ),
        Expanded(
          flex: 6,
          child: _buildAddToCartCard(),
        ),
      ],
    );
  }

  Widget _buildPriceCard() {
    return Card(
      color: Colors.black,
      elevation: 5,
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              widget.price,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddToCartCard() {
    return InkWell(
      onTap: () {
        if (user != null) {
          addToCart(context);
          // You can add additional logic here, e.g., show a confirmation message.
        }
      },
      child: Card(
        elevation: 15,
        color: Colors.red,
        child: SizedBox(
          height: 55.0,
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Add to Cart',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void addToCart(BuildContext context) async {
    try {
      if (user != null) {
        // Get user's document reference
        DocumentReference userDoc =
            FirebaseFirestore.instance.collection('users').doc(user!.uid);

        // Create a map with product details
        Map<String, dynamic> productDetails = {
          'name': widget.name,
          'price': widget.price,
          'imageUrl': widget.imageUrl,
        };

        // Add product details to the 'cart' array
        await userDoc.update({
          'cart': FieldValue.arrayUnion([productDetails]),
        });

        // Show a SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added to Cart'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print("Error adding to cart: $e");
      // Handle the error, e.g., show an error message to the user.
    }
  }

  void addToWishlist() async {
    try {
      if (user != null) {
        // Get user's document reference
        DocumentReference userDoc =
            FirebaseFirestore.instance.collection('users').doc(user!.uid);

        // Create a map with product details
        Map<String, dynamic> productDetails = {
          'name': widget.name,
          'price': widget.price,
          'imageUrl': widget.imageUrl,
        };

        // Add product details to the 'wishlist' array
        await userDoc.update({
          'wishlist': FieldValue.arrayUnion([productDetails]),
        });
      }
    } catch (e) {
      print("Error adding to wishlist: $e");
    }
  }

  void removeFromWishlist() async {
    try {
      if (user != null) {
        // Get user's document reference
        DocumentReference userDoc =
            FirebaseFirestore.instance.collection('users').doc(user!.uid);

        // Create a map with product details
        Map<String, dynamic> productDetails = {
          'name': widget.name,
          'price': widget.price,
          'imageUrl': widget.imageUrl,
        };

        // Remove product details from the 'wishlist' array
        await userDoc.update({
          'wishlist': FieldValue.arrayRemove([productDetails]),
        });
      }
    } catch (e) {
      print("Error removing from wishlist: $e");
    }
  }
}
