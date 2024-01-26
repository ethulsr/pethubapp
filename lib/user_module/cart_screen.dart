import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pethub_admin/user_module/order_summary_screen.dart';
import 'package:pethub_admin/user_module/pet_details_screen.dart';

class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  late List<Map<String, dynamic>> cartItems = [];

  @override
  void initState() {
    super.initState();
    fetchCart();
  }

  void fetchCart() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc =
          FirebaseFirestore.instance.collection('users').doc(user.uid);

      final userData = await userDoc.get();

      setState(() {
        if (userData.exists &&
            userData.data() != null &&
            userData.data()!['cart'] is List) {
          cartItems = (userData.data()!['cart'] as List)
              .whereType<Map>()
              .cast<Map<String, dynamic>>()
              .toList();
        } else {
          cartItems = [];
        }
      });
    }
  }

  void removeFromCart(BuildContext context, int index) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userDoc =
            FirebaseFirestore.instance.collection('users').doc(user.uid);

        Map<String, dynamic> removedProduct = cartItems[index];

        await userDoc.update({
          'cart': FieldValue.arrayRemove([cartItems[index]]),
        });

        fetchCart();

        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${removedProduct['name']} removed from cart'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // Handle the error, e.g., show an error message to the user.
    }
  }

  double calculateTotalPrice(List<Map<String, dynamic>> cartItems) {
    double totalPrice = 0.0;

    for (var item in cartItems) {
      if (item.containsKey('price') && item['price'] is String) {
        final cleanedPrice = item['price'].replaceAll(RegExp(r'[^0-9.]'), '');
        totalPrice += double.tryParse(cleanedPrice) ?? 0.0;
      }
    }

    return totalPrice + 40.0; // Add the fixed delivery fee here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Cart',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // Conditionally render the "Place Order All" button only when there are items in the cart
                if (cartItems.isNotEmpty)
                  ElevatedButton(
                    onPressed: () {
                      // Implement logic to place the order for all items
                      if (cartItems.isNotEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OrderSummaryPage(
                              cartItems: cartItems,
                              totalPrice: calculateTotalPrice(cartItems),
                            ),
                          ),
                        );
                      } else {
                        // Show a message if the cart is empty
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Your cart is empty.'),
                          ),
                        );
                      }
                    },
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.red),
                      minimumSize: MaterialStateProperty.all<Size>(
                          Size(140, 50)), // Set the width and height
                    ),
                    child: Text(
                      'Place Order All',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // The rest of your code goes here...
          cartItems.isEmpty
              ? SizedBox(
                  height: 500,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.shopping_cart,
                          size: 100,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Your cart is empty.',
                          style: TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                )
              : Expanded(
                  child: ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      Map<String, dynamic> product = cartItems[index];

                      return Card(
                        elevation: 5,
                        margin: EdgeInsets.all(20.0),
                        color: Colors.grey[300],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProductDetailsPage(
                                  name: product['name'] ?? '',
                                  price: product['price'] ?? '',
                                  imageUrl: product['imageUrl'] ?? '',
                                  description: product['description'] ?? '',
                                  sex: product['sex'] ?? '',
                                  color: product['color'] ?? '',
                                  age: product['age'] ?? '',
                                ),
                              ),
                            );
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(15.0)),
                                child: Image.network(
                                  product['imageUrl'] ?? '',
                                  width: double.infinity,
                                  height: 200,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width:
                                              80, // Fixed width for the labels
                                          child: Text(
                                            'Name',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          ': ${product['name'] ?? ''}',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width:
                                              80, // Fixed width for the labels
                                          child: Text(
                                            'Price',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          ': ${product['price'] ?? ''}',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: 80, // Fixed width for the labels
                                      child: Text(
                                        'Total',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Text(
                                      ': \$${calculateTotalPrice(cartItems).toStringAsFixed(2)}',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.5,
                                      height: 40,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  OrderSummaryPage(
                                                cartItems: [cartItems[index]],
                                                totalPrice: calculateTotalPrice(
                                                  [cartItems[index]],
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                        ),
                                        child: Text(
                                          'Place Order',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.2,
                                      height: 40,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          removeFromCart(context, index);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.black,
                                        ),
                                        child: Text(
                                          'Remove',
                                          style: TextStyle(
                                            color: Colors.white,
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
                      );
                    },
                  ),
                ),
        ],
      ),
    );
  }
}
