import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UsermanagementScreen extends StatefulWidget {
  const UsermanagementScreen({Key? key}) : super(key: key);

  @override
  _UsermanagementScreenState createState() => _UsermanagementScreenState();
}

class _UsermanagementScreenState extends State<UsermanagementScreen> {
  late List<String> items;
  late List<String> filteredItems;
  TextEditingController searchController = TextEditingController();
  Map<String, bool> userBlockedState = {};

  @override
  void initState() {
    super.initState();
    // Initialize the blocked state map
    userBlockedState = {};

    // Initialize the items list
    items = [];

    // Fetch data from Firestore and update the items list
    fetchUserDataFromFirestore();

    // Initialize the filtered items
    filteredItems = List.from(items);
  }

  Future<void> fetchUserDataFromFirestore() async {
    try {
      // Reference to the 'users' collection
      CollectionReference users =
          FirebaseFirestore.instance.collection('users');

      // Get documents from the collection
      QuerySnapshot querySnapshot = await users.get();

      // Extract data from the documents
      items = querySnapshot.docs
          .map((doc) => '${doc['name']} - ${doc['email']}')
          .toList();

      print('Fetched items: $items');

      setState(() {
        filteredItems = List.from(items);
      });
    } catch (e) {
      // Handle errors
      print('Error fetching data: $e');
    }
  }

  void filterSearchResults(String query) {
    List<String> searchResults = [];

    if (query.isNotEmpty) {
      items.forEach((item) {
        if (item.toLowerCase().contains(query.toLowerCase())) {
          searchResults.add(item);
        }
      });
    } else {
      searchResults = List.from(items);
    }

    setState(() {
      filteredItems = searchResults;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: Container(
        padding: EdgeInsets.only(left: 4, top: 20, right: 4),
        child: Column(
          children: [
            SizedBox(height: 10),
            _buildSearchBar(context),
            SizedBox(height: 16),
            _buildPrice(context),
            SizedBox(height: 16),
            _buildUserList(context),
            SizedBox(height: 5),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: searchController,
        onChanged: (value) {
          filterSearchResults(value);
        },
        decoration: InputDecoration(
          labelText: 'Search',
          hintText: 'Enter a user name or email',
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
          ),
        ),
      ),
    );
  }

  Widget _buildUserList(BuildContext context) {
    return Expanded(
      child: filteredItems.isEmpty
          ? Center(
              child: Text(
                'No Results',
                style: TextStyle(fontSize: 16.0),
              ),
            )
          : ListView.builder(
              itemCount: filteredItems.length,
              itemBuilder: (context, index) {
                List<String> userDetail = filteredItems[index].split(' - ');

                bool isBlocked =
                    userBlockedState[filteredItems[index]] ?? false;

                return ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 150.0,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userDetail[0],
                              style: TextStyle(fontSize: 18.0),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 8.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userDetail[1],
                              style: TextStyle(fontSize: 15.0),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            userBlockedState[filteredItems[index]] = !isBlocked;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              isBlocked ? Colors.red : Colors.green,
                        ),
                        child: Text(
                          isBlocked ? 'Unblock' : 'Block',
                          style: TextStyle(fontSize: 12.0, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildPrice(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 12, right: 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("USER NAME",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Spacer(flex: 34),
          Text("EMAIL",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Spacer(flex: 35),
          Text("ACTIONS",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text("USER MANAGEMENT"),
    );
  }

  onTapBackToMenu(BuildContext context) {
    Navigator.pop(context);
  }
}
