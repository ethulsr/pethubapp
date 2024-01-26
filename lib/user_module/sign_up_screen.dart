import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pethub_admin/routes/app_routes.dart';
import 'package:pethub_admin/theme/app_decoration.dart';
import 'package:pethub_admin/theme/custom_text_style.dart';
import 'package:pethub_admin/widget/custom_elevated_button.dart';

class SignUpScreen extends StatefulWidget {
  SignUpScreen({Key? key}) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  // Add this line to manage the password visibility
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create a Account'),
        centerTitle: true,
      ),
      backgroundColor: Colors.blueGrey[100],
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 37),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 30),
              _buildSignUpForm(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSignUpForm(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 100), // Adjust the height as needed
          Container(
            padding: EdgeInsets.all(20),
            decoration: AppDecoration.fillWhiteA
                .copyWith(borderRadius: BorderRadius.circular(15)),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text("SIGN UP", style: CustomTextStyles.headlineSmallPrimary),
                  SizedBox(height: 20),
                  _buildInputField("Name", Icons.person, nameController,
                      validator: (value) {
                    print('Name Validator: $value');
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  }),
                  SizedBox(height: 20),
                  _buildInputField("Email", Icons.email, emailController,
                      validator: validateEmail),
                  SizedBox(height: 20),
                  _buildInputField("Password", Icons.lock, passwordController,
                      isPassword: true, validator: (value) {
                    print('Password Validator: $value');
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  }),
                  SizedBox(height: 20),
                  _buildInputField(
                    "Confirm Password",
                    Icons.lock,
                    confirmPasswordController,
                    isPassword: true,
                    validator: (value) {
                      print('Confirm Password Validator: $value');
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      } else if (value != passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  CustomElevatedButton(
                    text: "SIGN UP",
                    onPressed: () => _onTapSignUp(context),
                    backgroundColor: Colors.blue,
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(
    String label,
    IconData prefixIcon,
    TextEditingController controller, {
    bool isPassword = false,
    required String? Function(dynamic value) validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 18)),
        SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey[200],
          ),
          child: TextFormField(
            controller: controller,
            obscureText: isPassword ? _obscureText : false,
            style: TextStyle(fontSize: 16),
            validator: validator,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              prefixIcon: Icon(
                prefixIcon,
                color: Colors.blue,
              ),
              suffixIcon: isPassword
                  ? IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            ),
          ),
        ),
      ],
    );
  }

  // Function to validate email using RegExp
  String? validateEmail(dynamic value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }

    // Regular expression for a valid email format
    RegExp emailRegExp =
        RegExp(r'^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$');

    if (!emailRegExp.hasMatch(value)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  void _onTapSignUp(BuildContext context) async {
    print('Before validation');
    if (_formKey.currentState?.validate() ?? false) {
      print('Validation passed');
      try {
        // Create a new user account
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );

        // Get the newly created user
        User? user = userCredential.user;

        // Store additional user data in Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user?.uid)
            .set({
          'name': nameController.text,
          'email': emailController.text,
          // Add more fields as needed
        });

        print('Before navigation');
        Navigator.pushNamed(context, AppRoutes.userhomeScreen);
        print('After navigation');
      } on FirebaseAuthException catch (e) {
        print('Error during sign-up or Firestore storage: $e');
        // Sign-up failed
        String errorMessage = 'An error occurred.';

        if (e.code == 'weak-password') {
          errorMessage = 'The password provided is too weak.';
        } else if (e.code == 'email-already-in-use') {
          errorMessage = 'The account already exists for that email.';
        }
        // Add more error codes as needed

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Sign-Up Failed'),
              content: Text(errorMessage),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } else {
      print('Validation failed');
    }
  }
}
