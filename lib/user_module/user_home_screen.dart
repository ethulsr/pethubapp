import 'package:flutter/material.dart';
import 'package:pethub_admin/user_module/bottom_navigation_bar.dart';
import 'package:pethub_admin/user_module/cart_screen.dart';
import 'package:pethub_admin/user_module/home_page.dart';
import 'package:pethub_admin/user_module/profile_screen.dart';
import 'package:pethub_admin/user_module/search_screen.dart';

class UserHomeScreen extends StatefulWidget {
  @override
  _UserHomeScreenState createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.grey[300],
          title: Text(
            'PetHub',
            style: TextStyle(
                fontSize: 30,
                color: Colors.lightBlue,
                fontWeight: FontWeight.bold),
          ),
        ),
        body: _getPage(_currentIndex),
        bottomNavigationBar: CustomBottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),
      ),
    );
  }

  Widget _getPage(int index) {
    switch (index) {
      case 0:
        return HomePage();
      case 1:
        return SearchPage();
      case 2:
        return ProfilePage();
      case 3:
        return CartPage();
      default:
        return Center(child: Text('Invalid Page'));
    }
  }
}
