import 'package:flutter/material.dart';
import 'package:pethub_admin/core/app_export.dart';
import 'package:pethub_admin/routes/app_routes.dart';

// ignore_for_file: must_be_immutable
class AddproductScreen extends StatelessWidget {
  AddproductScreen({Key? key}) : super(key: key);

  TextEditingController productDescriptionController = TextEditingController();

  TextEditingController productPriceController = TextEditingController();

  TextEditingController editTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    mediaQueryData = MediaQuery.of(context);
    return const SafeArea(child: Scaffold());
  }

  onTapADD(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.productScreen);
  }
}
