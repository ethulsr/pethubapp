import 'package:flutter/material.dart';
import 'package:pethub_admin/core/app_export.dart';
import 'package:pethub_admin/main.dart';
import 'package:pethub_admin/routes/app_routes.dart';

class AppNavigationScreen extends StatelessWidget {
  const AppNavigationScreen({Key? key})
      : super(
          key: key,
        );

  @override
  Widget build(BuildContext context) {
    mediaQueryData = MediaQuery.of(context);

    return SafeArea(
      child: Scaffold(
        backgroundColor: Color(0XFFFFFFFF),
        body: SizedBox(
          width: 375,
          child: Column(
            children: [
              _buildAppNavigation(context),
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(0XFFFFFFFF),
                    ),
                    child: Column(
                      children: [
                        _buildScreenTitle(
                          context,
                          screenTitle: "LOGIN",
                          onTapScreenTitle: () =>
                              onTapScreenTitle(context, AppRoutes.loginScreen),
                        ),
                        _buildScreenTitle(
                          context,
                          screenTitle: "ADDPRODUCT",
                          onTapScreenTitle: () => onTapScreenTitle(
                              context, AppRoutes.addproductScreen),
                        ),
                        _buildScreenTitle(
                          context,
                          screenTitle: "DASHBOARD",
                          onTapScreenTitle: () => onTapScreenTitle(
                              context, AppRoutes.dashboardScreen),
                        ),
                        _buildScreenTitle(
                          context,
                          screenTitle: "CATEGORY",
                          onTapScreenTitle: () => onTapScreenTitle(
                              context, AppRoutes.categoryScreen),
                        ),
                        _buildScreenTitle(
                          context,
                          screenTitle: "PRODUCT",
                          onTapScreenTitle: () => onTapScreenTitle(
                              context, AppRoutes.productScreen),
                        ),
                        _buildScreenTitle(
                          context,
                          screenTitle: "FORGOTPASSWORD",
                          onTapScreenTitle: () => onTapScreenTitle(
                              context, AppRoutes.forgotpasswordScreen),
                        ),
                        if (isAuthenticated)
                          _buildScreenTitle(
                            context,
                            screenTitle: "HOME",
                            onTapScreenTitle: () =>
                                onTapScreenTitle(context, AppRoutes.homeScreen),
                          )
                        else
                          _buildScreenTitle(
                            context,
                            screenTitle: "LOGIN",
                            onTapScreenTitle: () => onTapScreenTitle(
                                context, AppRoutes.loginScreen),
                          ),
                        _buildScreenTitle(
                          context,
                          screenTitle: "USERMANAGEMENT",
                          onTapScreenTitle: () => onTapScreenTitle(
                              context, AppRoutes.usermanagementScreen),
                        ),
                        _buildScreenTitle(
                          context,
                          screenTitle: "ORDERS",
                          onTapScreenTitle: () =>
                              onTapScreenTitle(context, AppRoutes.ordersScreen),
                        ),
                        _buildScreenTitle(
                          context,
                          screenTitle: "ENQURIES",
                          onTapScreenTitle: () => onTapScreenTitle(
                              context, AppRoutes.enquriesScreen),
                        ),
                        _buildScreenTitle(
                          context,
                          screenTitle: "SALES",
                          onTapScreenTitle: () =>
                              onTapScreenTitle(context, AppRoutes.salesScreen),
                        ),
                        _buildScreenTitle(
                          context,
                          screenTitle: "SIGNUP",
                          onTapScreenTitle: () =>
                              onTapScreenTitle(context, AppRoutes.signUpScreen),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Section Widget
  Widget _buildAppNavigation(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0XFFFFFFFF),
      ),
      child: Column(
        children: const [
          SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "App Navigation",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0XFF000000),
                  fontSize: 20,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
          SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(left: 20),
              child: Text(
                "Check your app's UI from the below demo screens of your app.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0XFF888888),
                  fontSize: 16,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
          SizedBox(height: 5),
          Divider(
            height: 1,
            thickness: 1,
            color: Color(0XFF000000),
          ),
        ],
      ),
    );
  }

  /// Common widget
  Widget _buildScreenTitle(
    BuildContext context, {
    required String screenTitle,
    Function? onTapScreenTitle,
  }) {
    return GestureDetector(
      onTap: () {
        onTapScreenTitle!.call();
      },
      child: Container(
        decoration: BoxDecoration(
          color: Color(0XFFFFFFFF),
        ),
        child: Column(
          children: [
            SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  screenTitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0XFF000000),
                    fontSize: 20,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            SizedBox(height: 5),
            Divider(
              height: 1,
              thickness: 1,
              color: Color(0XFF888888),
            ),
          ],
        ),
      ),
    );
  }

  /// Common click event
  void onTapScreenTitle(
    BuildContext context,
    String routeName,
  ) {
    Navigator.pushNamed(context, routeName);
  }
}
