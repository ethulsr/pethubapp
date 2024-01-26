import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pethub_admin/user_module/Thank_you_screen.dart';
import 'package:uuid/uuid.dart';

class OrderSummaryPage extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  final double totalPrice;

  OrderSummaryPage({required this.cartItems, required this.totalPrice});

  @override
  _OrderSummaryPageState createState() => _OrderSummaryPageState();
}

class _OrderSummaryPageState extends State<OrderSummaryPage> {
  late String userAddress = '';
  bool cashOnDelivery = true; // Default to cash on delivery

  @override
  void initState() {
    super.initState();
    fetchUserAddress();
  }

  Future<void> fetchUserAddress() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists && userDoc.data() != null) {
        final userData = userDoc.data()!;

        if (userData.containsKey('name') &&
            userData.containsKey('address') &&
            userData.containsKey('email') &&
            userData.containsKey('phonenumber') &&
            userData['name'] is String &&
            userData['address'] is String &&
            userData['email'] is String &&
            userData['phonenumber'] is String) {
          final name = userData['name'];
          final phoneNumber = userData['phonenumber'];
          final email = userData['email'];
          final address = userData['address'];

          setState(() {
            userAddress = '$name\n$phoneNumber\n$email\n$address';
          });
        }
      }
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

  Future<void> clearCart() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc =
          FirebaseFirestore.instance.collection('users').doc(user.uid);

      await userDoc.update({'cart': []});
    }
  }

  Future<void> placeOrder(
    String userName,
    String userEmail,
    String userPhoneNumber,
    String userAddress,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final paymentMethod = 'Cash on Delivery';
      final uuid = Uuid();

      double itemsTotal =
          0.0; // Separate variable to accumulate the total of product prices

      for (var product in widget.cartItems) {
        double productPrice = double.tryParse(
                product['price'].replaceAll(RegExp(r'[^0-9.]'), '')) ??
            0.0;
        itemsTotal += productPrice;

        final productID = uuid.v4(); // Generate a random ID for the product
        final orderData = {
          'name': userName,
          'address': userAddress,
          'productID': productID, // Include productID in the orderData
          'productName': product['name'],
          'productImage': product['imageUrl'],
          'totalPrice': productPrice +
              40.0, // Store individual product price with delivery fee
          'paymentMethod': paymentMethod,
          'status': 'Pending',
          'timestamp': DateTime.now(),
        };

        await FirebaseFirestore.instance.collection('orders').add(orderData);

        // If you want to store product IDs in the user's document as well, you can update the user document
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'name': userName,
          'email': userEmail,
          'phonenumber': userPhoneNumber,
          'orderTotal': itemsTotal + 40.0,
          'status': 'Pending',
          'productIDs': FieldValue.arrayUnion([productID]),
        });
      }

      await clearCart();

      // Show the "Thank You" screen after placing the order
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ThankYouScreen()),
      );
    }
  }

  Future<void> _showAddressSelectionDialog() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists && userDoc.data() != null) {
        final userData = userDoc.data()!;

        // Extract the 'address' and 'addressWork' from the user data
        final String? address = userData['address'];
        final String? addressWork = userData['addressWork'];

        // Create a list of addresses with null check
        final List<String> addresses = [];
        if (address != null) {
          addresses.add('Home: $address');
        }
        if (addressWork != null) {
          addresses.add('Work: $addressWork');
        }

        // Add an explicit option for changing the address
        addresses.add('Change Address');

        // Display the dialog with the list of addresses
        // ignore: use_build_context_synchronously
        final selectedAddress = await showDialog<String>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Select Address'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: [
                    // Display the list of addresses
                    ...addresses.map((address) {
                      return ListTile(
                        title: Text(address),
                        onTap: () {
                          Navigator.pop(context, address);
                        },
                      );
                    }).toList(),
                    // Add a "Cancel" button
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context,
                            null); // Pass null to indicate cancellation
                      },
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );

        if (selectedAddress != null && selectedAddress != 'Change Address') {
          setState(() {
            // Preserve other user-related information
            userAddress = selectedAddress.split(': ')[1];

            // Update other user-related information in the UI
            final name = userData['name'];
            final phoneNumber = userData['phonenumber'];
            final email = userData['email'];

            userAddress = '$name\n$phoneNumber\n$email\n$userAddress';
          });
        } else if (selectedAddress == 'Change Address') {
          // Handle the logic for changing the address
          // You can navigate to another screen or show another dialog for this purpose
          // For simplicity, you can print a message for now
          print('User wants to change the address');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Summary'),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 5,
              color: Colors.grey[300],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Container(
                width: 400,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Shipping to',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        userAddress,
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 8),
                      TextButton(
                        onPressed: () {
                          _showAddressSelectionDialog();
                        },
                        child: Text(
                          'Change Address',
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 50,
            ),
            Text(
              'Payment Method',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              children: [
                Radio(
                  value: true,
                  groupValue: cashOnDelivery,
                  onChanged: (value) {
                    setState(() {
                      cashOnDelivery = true;
                    });
                  },
                ),
                Text('Cash on Delivery'),
              ],
            ),
            SizedBox(
              height: 50,
            ),
            Text(
              'Order Summary',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: widget.cartItems.length,
                itemBuilder: (context, index) {
                  Map<String, dynamic> product = widget.cartItems[index];

                  return Card(
                    elevation: 5,
                    margin: EdgeInsets.all(20.0),
                    color: Colors.grey[300],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(15.0)),
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
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    product['name'] ?? '',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.remove_circle),
                                    onPressed: () {
                                      // Implement remove logic here
                                      setState(() {
                                        widget.cartItems.removeAt(index);
                                      });
                                    },
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Text(
                                product['price'] ?? '',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Text(
                              'Total: \$${calculateTotalPrice(widget.cartItems).toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 10),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  final user = FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    final userDoc = await FirebaseFirestore.instance
                        .collection('users')
                        .doc(user.uid)
                        .get();

                    if (userDoc.exists && userDoc.data() != null) {
                      final userData = userDoc.data()!;

                      if (userData.containsKey('name') &&
                          userData['name'] is String) {
                        final userName = userData['name'];
                        final userEmail = userData['email'];
                        final userPhoneNumber = userData['phonenumber'];

                        await placeOrder(
                          userName,
                          userEmail,
                          userPhoneNumber,
                          userAddress,
                        );
                      }
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  fixedSize: Size(340, 50),
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
          ],
        ),
      ),
    );
  }
}
