import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pethub_admin/user_module/pet_screen.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = '';
  String _selectedSortOption = 'Price (Low to High)';
  List<String> _categories = [];

  @override
  void initState() {
    super.initState();
    _fetchCategoriesFromDatabase();
  }

  Future<void> _fetchCategoriesFromDatabase() async {
    try {
      CollectionReference productsCollection =
          FirebaseFirestore.instance.collection('products');

      // Fetch distinct values of the 'category' field
      QuerySnapshot querySnapshot =
          await productsCollection.get(GetOptions(source: Source.server));

      // Extract unique categories from the query snapshot
      List<String> uniqueCategories = querySnapshot.docs
          .map((doc) =>
              (doc.data() as Map<String, dynamic>)['category'] as String)
          .toSet()
          .toList();

      // Update the state with the fetched categories
      setState(() {
        _categories = uniqueCategories;
      });
      // ignore: empty_catches
    } catch (error) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search by Name',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    setState(() {});
                  },
                ),
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField(
                    value: _selectedCategory,
                    onChanged: (newValue) {
                      setState(() {
                        _selectedCategory = newValue.toString();
                      });
                    },
                    items: [
                      DropdownMenuItem(
                        value: '',
                        child: Text('All Categories'),
                      ),
                      for (var category in _categories)
                        DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        ),
                    ],
                    decoration: InputDecoration(
                      labelText: 'Select Category',
                    ),
                  ),
                ),
                SizedBox(width: 16.0),
                Expanded(
                  child: DropdownButtonFormField(
                    value: _selectedSortOption,
                    onChanged: (newValue) {
                      setState(() {
                        _selectedSortOption = newValue.toString();
                      });
                    },
                    items: const [
                      DropdownMenuItem(
                        value: 'Price (Low to High)',
                        child: Text('Price (Low to High)'),
                      ),
                      DropdownMenuItem(
                        value: 'Price (High to Low)',
                        child: Text('Price (High to Low)'),
                      ),
                    ],
                    decoration: InputDecoration(
                      labelText: 'Sort By',
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ProductList(
              searchQuery: _searchController.text,
              categoryFilter: _selectedCategory,
              sortOption: _selectedSortOption,
            ),
          ),
        ],
      ),
    );
  }
}
