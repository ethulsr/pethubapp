import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pethub_admin/database_functions/product_repository.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({Key? key}) : super(key: key);

  @override
  _ProductScreenState createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  List<Product> products = [];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance.collection('products').get();

      setState(() {
        products = snapshot.docs
            .map((doc) => Product.fromMap(doc.id, doc.data()))
            .toList();
      });
    } catch (e) {
      print('Error loading products: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: ListView.separated(
          itemBuilder: (context, index) {
            if (index == 0) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 50),
                child: Text(
                  "PET MANAGEMENT",
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
              );
            } else if (index == 1) {
              return _buildProductListHeader(context);
            } else {
              int productIndex = index - 2;
              return _buildProductListItem(context, productIndex);
            }
          },
          separatorBuilder: (context, index) {
            return SizedBox(height: 20);
          },
          itemCount: products.length + 2,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            onTapADDPRODUCT(context);
          },
          child: Icon(Icons.add),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }

  Widget _buildProductListItem(BuildContext context, int index) {
    if (index < products.length) {
      Product product = products[index];
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              child: Text(product.name),
            ),
            Spacer(),
            Text(product.price),
            Spacer(),
            Text(product.category), // Display category
            Spacer(),
            IconButton(
              icon: Icon(Icons.edit, color: Colors.black),
              onPressed: () {
                _handleEditProduct(context, product);
              },
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                _handleDeleteProduct(context, product);
              },
            ),
          ],
        ),
      );
    } else {
      return Container();
    }
  }

  Widget _buildProductListHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Text(
            "TITLE",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Spacer(flex: 32),
          Text(
            "PRICE",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Spacer(flex: 22),
          Text(
            "CATEGORY",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Spacer(flex: 20),
          Text(
            "ACTIONS",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Spacer(flex: 5),
        ],
      ),
    );
  }

  void _handleEditProduct(BuildContext context, Product product) async {
    TextEditingController nameController =
        TextEditingController(text: product.name);
    TextEditingController priceController =
        TextEditingController(text: product.price);
    TextEditingController categoryController =
        TextEditingController(text: product.category);

    List<String> categories = await _loadCategories();

    // ignore: use_build_context_synchronously
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Product'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Product Name'),
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: priceController,
                  decoration: InputDecoration(labelText: 'Product Price'),
                ),
                SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: categories.contains(categoryController.text)
                      ? categoryController.text
                      : null,
                  items: categories.map((String category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    if (value != null) {
                      categoryController.text = value;
                    }
                  },
                  decoration: InputDecoration(labelText: 'Product Category'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _saveEditedProduct(context, product, nameController.text,
                    priceController.text, categoryController.text);
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _handleDeleteProduct(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Product'),
          content: Text('Are you sure you want to delete ${product.name}?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _deleteProduct(context, product);
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _saveEditedProduct(BuildContext context, Product product, String newName,
      String newPrice, String newCategory) async {
    Product editedProduct = Product(
        id: product.id, name: newName, price: newPrice, category: newCategory);

    try {
      await FirebaseFirestore.instance
          .collection('products')
          .doc(product.id)
          .update(editedProduct.toMap());
    } catch (e) {
      print('Error updating product: $e');
    }

    setState(() {
      // Update the local state with the edited product
      products[products.indexOf(product)] = editedProduct;
    });

    print(
        "Product Edited - ID: ${editedProduct.id}, Name: $newName, Price: $newPrice, Category: $newCategory");
  }

  void _deleteProduct(BuildContext context, Product product) async {
    try {
      await FirebaseFirestore.instance
          .collection('products')
          .doc(product.id)
          .delete();
    } catch (e) {
      print('Error deleting product: $e');
    }

    setState(() {
      // Remove the deleted product from the local state
      products.remove(product);
    });

    print("Product Deleted - ID: ${product.id}, Name: ${product.name}");
  }

  void onTapADDPRODUCT(BuildContext context) async {
    TextEditingController nameController = TextEditingController();
    TextEditingController priceController = TextEditingController();
    TextEditingController categoryController = TextEditingController();

    List<String> categories = await _loadCategories();

    // ignore: use_build_context_synchronously
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Product'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Product Name'),
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: priceController,
                  decoration: InputDecoration(labelText: 'Product Price'),
                ),
                SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: categories.contains(categoryController.text)
                      ? categoryController.text
                      : null,
                  items: categories.map((String category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    if (value != null) {
                      categoryController.text = value;
                    }
                  },
                  decoration: InputDecoration(labelText: 'Product Category'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _addNewProduct(context, nameController.text,
                    priceController.text, categoryController.text);
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _addNewProduct(BuildContext context, String newName, String newPrice,
      String newCategory) {
    Product newProduct =
        Product(id: '', name: newName, price: newPrice, category: newCategory);

    DocumentReference documentReference =
        FirebaseFirestore.instance.collection('products').doc();

    try {
      documentReference.set(newProduct.toMap());
    } catch (e) {
      print('Error adding new product: $e');
    }

    setState(() {
      newProduct.id = documentReference.id;
      products.add(newProduct);
    });

    print(
        "Adding a new product - ID: ${newProduct.id}, Name: $newName, Price: $newPrice, Category: $newCategory");
  }

  Future<List<String>> _loadCategories() async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance.collection('categories').get();

      List<String> categories =
          snapshot.docs.map((doc) => doc['name'] as String).toList();

      // Remove duplicates
      categories = categories.toSet().toList();

      return categories;
    } catch (e) {
      print('Error loading categories: $e');
      return [];
    }
  }
}
