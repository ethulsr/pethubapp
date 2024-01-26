import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive/hive.dart';
import 'package:pethub_admin/user_module/pet_item.dart';
import 'package:pethub_admin/user_module/wishlist_item.dart';

class ProductList extends StatefulWidget {
  final String? searchQuery;
  final String? categoryFilter;
  final String sortOption;

  const ProductList({
    Key? key,
    this.searchQuery,
    this.categoryFilter,
    required this.sortOption,
  }) : super(key: key);

  @override
  _ProductListState createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  Set<String> wishlist = <String>{};
  User? user;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _auth.authStateChanges().listen((User? currentUser) {
      setState(() {
        user = currentUser;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('products').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        var products = snapshot.data!.docs;

        if ((widget.searchQuery != null && widget.searchQuery!.isNotEmpty) ||
            (widget.categoryFilter != null &&
                widget.categoryFilter!.isNotEmpty)) {
          products = products.where((product) {
            var productName =
                (product.data() as Map<String, dynamic>)['name'] ?? '';
            var productCategory =
                (product.data() as Map<String, dynamic>)['category'] ?? '';

            bool nameMatch = productName
                .toLowerCase()
                .contains(widget.searchQuery!.toLowerCase());

            bool categoryMatch = productCategory
                .toLowerCase()
                .contains(widget.categoryFilter!.toLowerCase());

            return nameMatch && categoryMatch;
          }).toList();
        }

        if (widget.sortOption == 'Price (Low to High)') {
          products.sort((a, b) => (a.data() as Map<String, dynamic>)['price']
              .compareTo((b.data() as Map<String, dynamic>)['price']));
        } else if (widget.sortOption == 'Price (High to Low)') {
          products.sort((a, b) => (b.data() as Map<String, dynamic>)['price']
              .compareTo((a.data() as Map<String, dynamic>)['price']));
        }

        if (products.isEmpty) {
          return Center(
            child: Text('No results found.'),
          );
        }

        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 7.0,
            mainAxisSpacing: 30.0,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            var product = products[index].data() as Map<String, dynamic>;
            var productName = product['name'] ?? '';
            var productPrice = product['price'] ?? '';
            var productImageUrl = product['imageUrl'] ?? '';

            return ProductItem(
              name: productName,
              price: '\$$productPrice',
              imageUrl: productImageUrl,
              description: product['description'] ?? '',
              isFavorite: wishlist.contains(productName),
              onToggleFavorite: () {
                toggleFavorite(productName, productPrice, productImageUrl);
              },
            );
          },
        );
      },
    );
  }

  void toggleFavorite(
      String productName, String productPrice, String productImageUrl) {
    setState(() {
      if (wishlist.contains(productName)) {
        removeFromWishlist(productName);
      } else {
        addToWishlist(productName, productPrice, productImageUrl);
      }
    });
  }

  void addToWishlist(
      String productName, String productPrice, String productImageUrl) async {
    try {
      if (user != null) {
        // Add item to Firestore
        DocumentReference userDoc =
            FirebaseFirestore.instance.collection('users').doc(user!.uid);

        Map<String, dynamic> productDetails = {
          'name': productName,
          'price': productPrice,
          'imageUrl': productImageUrl,
        };

        await userDoc.update({
          'wishlist': FieldValue.arrayUnion([productDetails]),
        });

        // Add item to Hive
        var wishlistBox = await Hive.openBox<WishlistItem>('wishlistBox');
        var wishlistItem = WishlistItem(
          name: productName,
          price: productPrice,
          imageUrl: productImageUrl,
          description: '',
          sex: '',
          color: '',
          age: '',
        );

        // Check if the item is already in the Hive box
        var existingItemIndex = wishlistBox.values.toList().indexWhere((item) =>
            item.name == wishlistItem.name &&
            item.price == wishlistItem.price &&
            item.imageUrl == wishlistItem.imageUrl);

        if (existingItemIndex == -1) {
          // Item is not in the wishlist, add it
          await wishlistBox.add(wishlistItem);

          final snackBar = SnackBar(
            content: Text('$productName added to wishlist'),
            duration: Duration(seconds: 2),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        } else {
          // Item already exists in the wishlist
          final snackBar = SnackBar(
            content: Text('$productName is already in the wishlist.'),
            duration: Duration(seconds: 2),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      }
    } catch (e) {
      print("Error adding to wishlist: $e");
    }
  }

  void removeFromWishlist(String productName) async {
    try {
      if (user != null) {
        DocumentReference userDoc =
            FirebaseFirestore.instance.collection('users').doc(user!.uid);

        Map<String, dynamic> productDetails = {
          'name': productName,
          'price': '', // You can add the correct value if available
          'imageUrl': '', // You can add the correct value if available
        };

        await userDoc.update({
          'wishlist': FieldValue.arrayRemove([productDetails]),
        });

        final snackBar = SnackBar(
          content: Text('$productName removed from wishlist'),
          duration: Duration(seconds: 2),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } catch (e) {
      print("Error removing from wishlist: $e");
    }
  }
}
