import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pethub_admin/database_functions/order_data.dart';

class OrderRepository {
  Future<List<OrderData>> getOrders() async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance.collection('orders').get();

      return snapshot.docs.map((doc) {
        return OrderData.fromMap(doc.id, doc.data());
      }).toList();
    } catch (e) {
      // Handle the error or return an empty list
      return [];
    }
  }

  Future<void> updateOrderStatus(String documentId, String newStatus) async {
    try {
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(documentId)
          .update({'status': newStatus});
    } catch (e) {
      // Handle the error
    }
  }
}
