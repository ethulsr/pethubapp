import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pethub_admin/core/app_export.dart';
import 'package:pethub_admin/database_functions/order_data.dart';
import 'package:pethub_admin/database_functions/order_repository.dart';
import 'package:pethub_admin/theme/app_decoration.dart';
import 'package:pethub_admin/theme/theme_helper.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({Key? key}) : super(key: key);

  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  late TextEditingController searchController;
  List<OrderData> allOrders = [];
  List<OrderData> filteredOrders = [];
  final OrderRepository orderRepository = OrderRepository();

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    List<OrderData> orders = await orderRepository.getOrders();

    setState(() {
      allOrders = orders;
      filteredOrders = List.from(allOrders);
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    mediaQueryData = MediaQuery.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Navigate back to the previous screen
          },
        ),
      ),
      body: Container(
        width: double.maxFinite,
        padding: EdgeInsets.symmetric(horizontal: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 10),
            Padding(
              padding: EdgeInsets.only(left: 12),
              child: Text("ORDERS", style: theme.textTheme.headlineLarge),
            ),
            SizedBox(height: 10),
            _buildSearchBar(),
            SizedBox(height: 20),
            _buildOrderDetailsColumn(filteredOrders),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: TextField(
        controller: searchController,
        decoration: InputDecoration(
          hintText: 'Search by Name or Product ID',
          prefixIcon: Icon(Icons.search),
        ),
        onChanged: (value) {
          filterOrders(value);
        },
      ),
    );
  }

  void filterOrders(String query) {
    setState(() {
      filteredOrders = allOrders
          .where((order) =>
              order.name.toLowerCase().contains(query.toLowerCase()) ||
              order.productID.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Widget _buildOrderDetailsColumn(List<OrderData> orders) {
    if (orders.isEmpty) {
      return Center(
        child: Text("No results found", style: theme.textTheme.bodyMedium),
      );
    }

    return Expanded(
      child: ListView.builder(
        itemCount: orders.length,
        itemBuilder: (context, index) {
          return _buildOrderItem(orders[index]);
        },
      ),
    );
  }

  Widget _buildOrderItem(OrderData order) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        margin: EdgeInsets.only(bottom: 16),
        padding: EdgeInsets.all(10),
        decoration: AppDecoration.outlinePrimary3
            .copyWith(borderRadius: BorderRadiusStyle.roundedBorder10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            _buildRow("Name", order.name),
            _buildRow("Address", order.address),
            _buildEditableStatusRow(order),
            _buildRow("Product ID", order.productID),
            _buildRow("Product Name", order.productName),
            _buildRow("Total Price", order.totalPrice),
            _buildRow("Timestamp", order.timestamp),
            _buildRow("Payment Method", order.paymentMethod),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableStatusRow(OrderData order) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text("Status", style: theme.textTheme.titleSmall),
          ),
          SizedBox(width: 10),
          Text(":", style: theme.textTheme.titleSmall),
          SizedBox(width: 10),
          Expanded(
            child: Row(
              children: [
                DropdownButton<String>(
                  value: order.status,
                  items: ['Delivered', 'Pending'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        order.status = newValue;
                      });
                      _updateStatus(order, newValue);
                    }
                  },
                ),
                SizedBox(width: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateStatus(OrderData order, String newStatus) async {
    await orderRepository.updateOrderStatus(order.documentId, newStatus);

    // Update the local state
    setState(() {
      order.status = newStatus;
    });
  }

  Widget _buildRow(String label, dynamic value) {
    String displayValue = '';

    if (value is double) {
      displayValue = '\$${value.toStringAsFixed(2)}';
    } else if (value is Timestamp) {
      displayValue = value.toDate().toString();
    } else {
      displayValue = value.toString();
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: theme.textTheme.titleSmall),
          ),
          SizedBox(width: 10),
          Text(":", style: theme.textTheme.titleSmall),
          SizedBox(width: 10),
          Expanded(
            child: Text(displayValue, style: theme.textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
