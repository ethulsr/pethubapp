import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:pethub_admin/user_module/pet_details_screen.dart';
import 'package:pethub_admin/user_module/wishlist_item.dart'; // Import your WishlistItem

class WishlistPage extends StatefulWidget {
  @override
  _WishlistPageState createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  late List<WishlistItem> wishlistItems = [];

  @override
  void initState() {
    super.initState();
    fetchWishlist();
  }

  // Method to fetch wishlist items from Hive
  void fetchWishlist() {
    final wishlistBox = Hive.box<WishlistItem>('wishlistBox');
    final List<WishlistItem> uniqueWishlistItems = wishlistBox.values.toList();

    setState(() {
      wishlistItems = uniqueWishlistItems.toSet().toList();
    });
  }

  // Method to remove an item from the wishlist
  // Method to remove an item from the wishlist
  void removeFromWishlist(WishlistItem product) async {
    try {
      final wishlistBox = await Hive.openBox<WishlistItem>('wishlistBox');

      // Find the index of the item to remove based on the product name
      final indexToRemove = wishlistBox.values.toList().indexWhere(
            (item) => item.name == product.name,
          );

      if (indexToRemove != -1) {
        wishlistBox.deleteAt(indexToRemove);
        fetchWishlist(); // Refresh the wishlist after removing the item
      }
    } catch (e) {
      print("Error removing from wishlist: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Wishlist'),
      ),
      body: wishlistItems.isEmpty
          ? Center(
              child: Text('Wishlist is empty.'),
            )
          : ListView.builder(
              itemCount: wishlistItems.length,
              itemBuilder: (context, index) {
                final product = wishlistItems[index];
                return buildProductCard(product);
              },
            ),
    );
  }

  Widget buildProductCard(WishlistItem product) {
    return Card(
      elevation: 5,
      margin: EdgeInsets.all(8.0),
      color: Colors.grey[300],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: InkWell(
        onTap: () {
          // Navigate to product details page
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailsPage(
                name: product.name,
                price: product.price,
                imageUrl: product.imageUrl,
                description: product.description,
                sex: product.sex,
                color: product.color,
                age: product.age,
              ),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(15.0)),
              child: Image.network(
                product.imageUrl,
                width: double.infinity,
                height: 200, // Adjust the height as needed
                fit: BoxFit.cover,
              ),
            ),
            // Product Details
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name
                  Text(
                    product.name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  // Product Price
                  Text(
                    product.price,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
            // Delete Button
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      // Call a method to remove the product from the wishlist
                      removeFromWishlist(product);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
