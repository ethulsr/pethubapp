import 'package:flutter/material.dart';
import 'package:pethub_admin/database_functions/order_data_helper.dart';
import 'package:pethub_admin/user_module/order_item.dart';

class OrderHistoryPage extends StatefulWidget {
  static bool isOrderBoxOpened = false;

  @override
  _OrderHistoryPageState createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  late Future<List<OrderItem>> _fetchOrdersFuture;

  @override
  void initState() {
    super.initState();
    _fetchOrdersFuture = OrderDataHelper.fetchOrdersFromFirebase();
  }

  @override
  Widget build(BuildContext context) {
    print("Build method called");

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Your Adoptions'),
      ),
      body: FutureBuilder<List<OrderItem>>(
        future: _fetchOrdersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            print("Waiting for data");
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            print("Error loading orders: ${snapshot.error}");
            return Center(child: Text('Error loading orders'));
          } else if (snapshot.data?.isEmpty ?? true) {
            print("No orders yet");
            return Center(child: Text('No orders yet.'));
          } else {
            print("Displaying orders from FutureBuilder");
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final order = snapshot.data![index];
                return Card(
                  color: Colors.white,
                  child: ListTile(
                    leading: Image.network(
                      order.productImage,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                    title: Text(
                      order.productName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Status: ${order.status}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        Text(
                          'Total Price: \$${order.totalPrice.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
