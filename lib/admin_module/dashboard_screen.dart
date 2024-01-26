import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int totalOrders = 0;
  int totalUsers = 0;
  double totalRevenues = 0.0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        // Retrieve all orders from Firestore
        QuerySnapshot ordersSnapshot =
            await FirebaseFirestore.instance.collection('orders').get();

        QuerySnapshot usersSnapshot =
            await FirebaseFirestore.instance.collection('users').get();

        // Calculate total revenues
        double totalRevenues = 0.0;

        // Iterate through each order document and sum up the totalPrice
        ordersSnapshot.docs.forEach((orderDoc) {
          totalRevenues += (orderDoc['totalPrice'] ?? 0.0) as double;
        });

        print('Orders Count: ${ordersSnapshot.size}');
        print('Users Count: ${usersSnapshot.size}');
        print('Total Revenues: $totalRevenues');

        // Update the state with real values
        setState(() {
          totalOrders = ordersSnapshot.size;
          totalUsers = usersSnapshot.size;
          this.totalRevenues = double.parse(totalRevenues.toStringAsFixed(2));
        });
      } catch (e) {
        print('Error loading data: $e');
      }
    } else {
      print('User is not authenticated.');
    }
  }

  List<PieChartSectionData> generatePieChartSections() {
    double total = totalRevenues + totalOrders + totalUsers;

    double revenuePercentage = (totalRevenues / total) * 100;
    double ordersPercentage = (totalOrders / total) * 100;
    double usersPercentage = (totalUsers / total) * 100;

    return [
      PieChartSectionData(
        color: Colors.blue,
        value: revenuePercentage,
        title: '${revenuePercentage.toStringAsFixed(1)}%',
        radius: 50,
      ),
      PieChartSectionData(
        color: Colors.green,
        value: ordersPercentage,
        title: '${ordersPercentage.toStringAsFixed(1)}%',
        radius: 50,
      ),
      PieChartSectionData(
        color: Colors.orange,
        value: usersPercentage,
        title: '${usersPercentage.toStringAsFixed(1)}%',
        radius: 50,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'DASHBOARD',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 50,
            ),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 150,
                    child: DashboardCard(
                      title: 'TOTAL REVENUES',
                      value: '\$$totalRevenues',
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 150,
                    child: DashboardCard(
                      title: 'TOTAL ORDERS',
                      value: '$totalOrders',
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 150,
                    child: DashboardCard(
                      title: 'TOTAL USERS',
                      value: '$totalUsers',
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 50,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
              child: Text(
                'Over View',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              height: 180, // Adjust this height as needed
              child: PieChart(
                PieChartData(
                  sections: generatePieChartSections(),
                  // Adjust the spacing between sections
                ),
              ),
            ),
            SizedBox(
              height: 40,
            ),
            Column(
              children: [
                LegendItem(color: Colors.blue, label: 'Total Revenues'),
                LegendItem(color: Colors.green, label: 'Total Orders'),
                LegendItem(color: Colors.orange, label: 'Total Users'),
                SizedBox(height: 15),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardCard extends StatelessWidget {
  final String title;
  final String value;

  const DashboardCard({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      color: Colors.red,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const LegendItem({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          color: color,
        ),
        SizedBox(width: 8),
        Text(label),
      ],
    );
  }
}
