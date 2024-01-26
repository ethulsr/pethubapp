import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pethub_admin/theme/theme_helper.dart';

class CategoryScreen extends StatefulWidget {
  CategoryScreen({Key? key}) : super(key: key);

  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final CategoryRepository categoryRepository = CategoryRepository();
  TextEditingController categoryController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context); // Navigate back to the previous screen
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Container(
            width: double.maxFinite,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SizedBox(height: 23),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.only(left: 11),
                    child: Text(
                      "CATEGORY MANAGEMENT",
                      style: theme.textTheme.headlineLarge,
                    ),
                  ),
                ),
                SizedBox(height: 23),
                _buildViewHierarchyList(context),
                SizedBox(height: 1),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _showAddCategoryDialog(context);
          },
          backgroundColor: appTheme.blueA700,
          child: Icon(Icons.add),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }

  Widget _buildViewHierarchyList(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: categoryRepository.getCategoriesStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          print("Error: ${snapshot.error}");
          return Text("Error fetching data");
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          print("No data available");
          return Text("No data available");
        }

        var categories =
            snapshot.data!.docs.map((doc) => doc['name'] as String).toList();
        print("Categories: $categories");

        return Align(
          alignment: Alignment.center,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 23),
            child: ListView.separated(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              separatorBuilder: (context, index) {
                return SizedBox(height: 12);
              },
              itemCount: categories.length,
              itemBuilder: (context, index) {
                return _buildCategoryRow(context, categories[index]);
              },
            ),
          ),
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(String category) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Category'),
          content:
              Text('Are you sure you want to delete the category "$category"?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _handleDeleteCategory(category);
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Padding _buildCategoryRow(BuildContext context, String category) {
    return Padding(
      padding: EdgeInsets.only(left: 23, right: 23),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 3),
            child: Text(
              category,
              style: theme.textTheme.bodyMedium!
                  .copyWith(color: theme.colorScheme.primary),
            ),
          ),
          Spacer(flex: 67),
          IconButton(
            onPressed: () {
              _showDeleteConfirmationDialog(category);
            },
            icon: Icon(
              Icons.delete,
              color: theme.colorScheme.primary,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Category'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextFormField(
                  controller: categoryController,
                  decoration: InputDecoration(labelText: 'Category Name'),
                  onChanged: (value) {
                    // You can handle onChanged to update the category name in real-time
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _handleSaveCategory(categoryController.text.trim());
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _handleSaveCategory(String enteredCategory) {
    enteredCategory = enteredCategory.trim();
    if (enteredCategory.isNotEmpty) {
      categoryRepository.addCategory(enteredCategory);
    }
  }

  void _handleDeleteCategory(String category) {
    categoryRepository.deleteCategory(category);
  }
}

class CategoryRepository {
  final CollectionReference categories =
      FirebaseFirestore.instance.collection('categories');

  Stream<QuerySnapshot> getCategoriesStream() {
    return categories.snapshots();
  }

  Future<void> addCategory(String categoryName) {
    return categories.add({'name': categoryName});
  }

  Future<void> deleteCategory(String categoryName) async {
    QuerySnapshot querySnapshot =
        await categories.where('name', isEqualTo: categoryName).get();
    querySnapshot.docs.forEach((doc) {
      doc.reference.delete();
    });
  }
}
