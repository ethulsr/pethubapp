import 'package:flutter/material.dart';
import 'package:pethub_admin/admin_module/addproduct_screen.dart';
import 'package:pethub_admin/admin_module/app_navigation_screen.dart';
import 'package:pethub_admin/admin_module/category_screen.dart';
import 'package:pethub_admin/admin_module/dashboard_screen.dart';
import 'package:pethub_admin/admin_module/enquries_screen.dart';
import 'package:pethub_admin/admin_module/forgotpassword_screen.dart';
import 'package:pethub_admin/admin_module/home_screen.dart';
import 'package:pethub_admin/admin_module/login_screen.dart';
import 'package:pethub_admin/admin_module/orders_screen.dart';
import 'package:pethub_admin/admin_module/product_screen.dart';
import 'package:pethub_admin/admin_module/sales_screen.dart';
import 'package:pethub_admin/admin_module/usermanagement_screen.dart';
import 'package:pethub_admin/user_module/sign_up_screen.dart';
import 'package:pethub_admin/user_module/user_home_screen.dart';

class AppRoutes {
  static const String loginScreen = '/login_screen';

  static const String addproductScreen = '/addproduct_screen';

  static const String dashboardScreen = '/dashboard_screen';

  static const String categoryScreen = '/category_screen';

  static const String productScreen = '/product_screen';

  static const String forgotpasswordScreen = '/forgotpassword_screen';

  static const String homeScreen = '/home_screen';

  static const String usermanagementScreen = '/usermanagement_screen';

  static const String ordersScreen = '/orders_screen';

  static const String enquriesScreen = '/enquries_screen';

  static const String salesScreen = '/sales_screen';

  static const String appNavigationScreen = '/app_navigation_screen';

  static const String signUpScreen = '/sign_up_screen';

  static const String userhomeScreen = '/user_home_screen';

  static Map<String, WidgetBuilder> routes = {
    userhomeScreen: (context) => UserHomeScreen(),
    signUpScreen: (context) => SignUpScreen(),
    loginScreen: (context) => LoginScreen(),
    addproductScreen: (context) => AddproductScreen(),
    dashboardScreen: (context) => DashboardScreen(),
    categoryScreen: (context) => CategoryScreen(),
    productScreen: (context) => ProductScreen(),
    forgotpasswordScreen: (context) => ForgotpasswordScreen(),
    homeScreen: (context) => HomeScreen(),
    usermanagementScreen: (context) => UsermanagementScreen(),
    ordersScreen: (context) => OrdersScreen(),
    enquriesScreen: (context) => EnquiriesScreen(),
    salesScreen: (context) => SalesScreen(),
    appNavigationScreen: (context) => AppNavigationScreen()
  };
}
