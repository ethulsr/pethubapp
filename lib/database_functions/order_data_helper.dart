import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'package:pethub_admin/user_module/order_item.dart';

class OrderDataHelper {
  static Future<List<OrderItem>> fetchOrdersFromFirebase() async {
    try {
      final User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        final DocumentSnapshot<Map<String, dynamic>> userSnapshot =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(currentUser.uid)
                .get();

        if (userSnapshot.exists) {
          final List<dynamic> userProductIDs = userSnapshot['productIDs'] ?? [];

          final QuerySnapshot<Map<String, dynamic>> ordersSnapshot =
              await FirebaseFirestore.instance
                  .collection('orders')
                  .where('productID', whereIn: userProductIDs)
                  .get();

          final List<OrderItem> newOrders = ordersSnapshot.docs
              .map((doc) =>
                  OrderItem.fromMap(doc.data() as Map<String, dynamic>))
              .toList();

          if (newOrders.isNotEmpty) {
            Hive.box<OrderItem>('orderBox').clear();
            Hive.box<OrderItem>('orderBox').addAll(newOrders);
            print("Orders fetched from Firebase: $newOrders");
            print(
                "Orders in the box after update: ${Hive.box<OrderItem>('orderBox').values}");
          }

          return newOrders;
        }
      }

      return [];
    } catch (e) {
      print("Error fetching orders from Firebase: $e");
      return [];
    }
  }
}
