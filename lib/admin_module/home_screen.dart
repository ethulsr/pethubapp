import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pethub_admin/routes/app_routes.dart';
import 'package:pethub_admin/theme/theme_helper.dart';
import 'package:pethub_admin/widget/custom_outlined_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: appTheme.pink100,
        body: SingleChildScrollView(
          // Wrap the Column with SingleChildScrollView
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _buildLogOutButton(context),
                  ],
                ),
                SizedBox(height: 20),
                _buildDashboardButton(context),
                _buildDivider(),
                _buildCategoryManagementButton(context),
                _buildDivider(),
                _buildProductManagementButton(context),
                _buildDivider(),
                _buildUserManagementButton(context),
                _buildDivider(),
                _buildOrderManagementButton(context),
                _buildDivider(),
                _buildSalesReportButton(context),
                _buildDivider(),
                //_buildEnquiriesButton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      color: Colors.white,
      margin: EdgeInsets.symmetric(vertical: 10),
    );
  }

  Widget _buildLogOutButton(BuildContext context) {
    return CustomOutlinedButton(
      height: 34,
      width: 89,
      text: "Log Out",
      buttonStyle: CustomButtonStyles.outlinePrimaryTL151,
      buttonTextStyle:
          theme.textTheme.titleMedium!.copyWith(color: Colors.black),
      onPressed: () {
        _signOut(); // Call the _signOut function when the Log Out button is pressed
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.loginScreen,
          (route) => false, // This line clears the entire navigation stack
        );
      },
    );
  }

  void _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  Widget _buildDashboardButton(BuildContext context) {
    return CustomOutlinedButton(
      text: "DASHBOARD",
      buttonStyle: CustomButtonStyles.outlineWhiteATL15,
      onPressed: () {
        onTapDashboardButton(context);
      },
    );
  }

  Widget _buildCategoryManagementButton(BuildContext context) {
    return CustomOutlinedButton(
      text: "CATEGORY MANAGEMENT",
      buttonStyle: CustomButtonStyles.outlineWhiteATL15,
      onPressed: () {
        onTapCategoryManagementButton(context);
      },
    );
  }

  Widget _buildProductManagementButton(BuildContext context) {
    return CustomOutlinedButton(
      text: "PET MANAGEMENT",
      buttonStyle: CustomButtonStyles.outlineWhiteATL15,
      onPressed: () {
        onTapProductManagementButton(context);
      },
    );
  }

  Widget _buildUserManagementButton(BuildContext context) {
    return CustomOutlinedButton(
      text: "USER MANAGEMENT",
      buttonStyle: CustomButtonStyles.outlineWhiteATL15,
      onPressed: () {
        onTapUserManagementButton(context);
      },
    );
  }

  Widget _buildOrderManagementButton(BuildContext context) {
    return CustomOutlinedButton(
      text: "ORDER MANAGEMENT",
      buttonStyle: CustomButtonStyles.outlineWhiteATL15,
      onPressed: () {
        onTapOrderManagementButton(context);
      },
    );
  }

  Widget _buildSalesReportButton(BuildContext context) {
    return CustomOutlinedButton(
      text: "SALES REPORT",
      buttonStyle: CustomButtonStyles.outlineWhiteATL15,
      onPressed: () {
        onTapSalesReportButton(context);
      },
    );
  }

  /*Widget _buildEnquiriesButton(BuildContext context) {
    return CustomOutlinedButton(
      text: "ENQURIES",
      buttonStyle: CustomButtonStyles.outlineWhiteATL15,
      onPressed: () {
        onTapEnquiriesButton(context);
      },
    );
  }*/

  onTapDashboardButton(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.dashboardScreen);
  }

  onTapCategoryManagementButton(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.categoryScreen);
  }

  onTapProductManagementButton(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.productScreen);
  }

  onTapUserManagementButton(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.usermanagementScreen);
  }

  onTapOrderManagementButton(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.ordersScreen);
  }

  onTapSalesReportButton(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.salesScreen);
  }

  /* onTapEnquiriesButton(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.enquriesScreen);
  }*/
}
