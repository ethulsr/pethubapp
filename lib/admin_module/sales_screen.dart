import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SalesScreen extends StatelessWidget {
  final List<String> years = ['2017', '2018', '2019', '2020', '2021', '2022'];
  final List<String> months = ['Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Navigate back to the previous screen
          },
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'PET SALES',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(height: 20),
          FutureBuilder(
            future: _fetchChartData('chart1'),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                Map<String, dynamic>? chartData =
                    snapshot.data as Map<String, dynamic>?;

                if (chartData != null && chartData.isNotEmpty) {
                  return Container(
                    height: 300,
                    padding: EdgeInsets.all(16.0),
                    child: BarChart(
                      BarChartData(
                        titlesData: FlTitlesData(
                          leftTitles: SideTitles(showTitles: false),
                          bottomTitles: SideTitles(
                            showTitles: true,
                            getTitles: (double value) {
                              return years.elementAt(value.toInt());
                            },
                            margin: 10,
                            reservedSize: 30,
                            getTextStyles: (context, value) => const TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            rotateAngle: 0,
                          ),
                          topTitles: SideTitles(
                            showTitles: false,
                          ),
                        ),
                        borderData: FlBorderData(
                          show: true,
                          border: Border.all(
                            color: Colors.red,
                            width: 1,
                          ),
                        ),
                        barGroups: _buildBarGroups(chartData),
                      ),
                    ),
                  );
                } else {
                  return Text('No data available');
                }
              }
            },
          ),
          SizedBox(height: 20),
          FutureBuilder(
            future: _fetchChartData('chart2'),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                Map<String, dynamic>? chartData =
                    snapshot.data as Map<String, dynamic>?;

                if (chartData != null && chartData.isNotEmpty) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        '2023',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      Container(
                        height: 300,
                        padding: EdgeInsets.all(16.0),
                        child: BarChart(
                          BarChartData(
                            titlesData: FlTitlesData(
                              leftTitles: SideTitles(showTitles: false),
                              bottomTitles: SideTitles(
                                showTitles: true,
                                getTitles: (double value) {
                                  return months.elementAt(value.toInt());
                                },
                                margin: 10,
                                reservedSize: 30,
                                getTextStyles: (context, value) =>
                                    const TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                rotateAngle: 0,
                              ),
                              topTitles: SideTitles(
                                showTitles: false,
                              ),
                            ),
                            borderData: FlBorderData(
                              show: true,
                            ),
                            barGroups: _buildBarGroups(chartData),
                          ),
                        ),
                      ),
                    ],
                  );
                } else {
                  return Text('No data available');
                }
              }
            },
          ),
        ],
      ),
    );
  }

  Future<Map<String, dynamic>> _fetchChartData(String chartType) async {
    try {
      String documentId = chartType == 'chart1' ? 'chartdata1' : 'chartdata2';

      DocumentSnapshot chartSnapshot = await FirebaseFirestore.instance
          .collection('sales')
          .doc(documentId)
          .get();

      if (chartSnapshot.exists) {
        Map<String, dynamic>? chartData =
            chartSnapshot.data() as Map<String, dynamic>;

        print('Retrieved data for chartType: $chartType - $chartData');

        // Modify the data based on the chartType
        if (chartType == 'chart1') {
          // Modify data for chart1 if needed
        } else if (chartType == 'chart2') {
          // Modify data for chart2 if needed
        }

        return chartData; // Return chartData if not null, otherwise an empty map
      } else {
        print('Document not found in the collection');
        return {}; // Return an empty map or handle it as needed
      }
    } catch (e) {
      print('Error fetching chart data: $e');
      throw e;
    }
  }

  List<BarChartGroupData> _buildBarGroups(Map<String, dynamic> chartData) {
    return chartData.entries
        .map((entry) => BarChartGroupData(
              x: chartData.keys.toList().indexOf(entry.key),
              barRods: [
                BarChartRodData(
                  y: _convertToDouble(entry.value),
                  colors: [Colors.green],
                ),
              ],
            ))
        .toList();
  }

  double _convertToDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    } else if (value is String) {
      return double.tryParse(value.replaceAll('"', '')) ?? 0.0;
    } else {
      return 0.0;
    }
  }
}
