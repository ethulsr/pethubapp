import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pethub_admin/routes/app_routes.dart';
import 'package:pethub_admin/theme/custom_text_style.dart';
import 'package:pethub_admin/widget/custom_elevated_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool _obscureTextPassword = true; // Added for password visibility

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 37),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Welcome Back",
              style: TextStyle(
                color: Colors.red[800],
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 6),
            _buildLoginForm(context),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 16),
          Text(
            "Log in with your email and password",
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20), // Adjust the spacing as needed
          TextFormField(
            decoration: InputDecoration(
              labelText: "Email",
              prefixIcon: Icon(Icons.email),
            ),
            controller: emailController,
            validator: validateEmail,
          ),

          SizedBox(height: 20),
          TextFormField(
            decoration: InputDecoration(
              labelText: "Password",
              prefixIcon: Icon(Icons.lock),
            ),
            controller: passwordController,
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }
              return null;
            },
          ),
          SizedBox(height: 10),
          Container(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () => onTapTxtForgotPassword(context),
              child: Text("Forgot Password?",
                  style: CustomTextStyles.labelLargeBlueA700),
            ),
          ),
          SizedBox(height: 20),
          CustomElevatedButton(
            text: "LOG IN",
            onPressed: () => _onTapLOGIN(context),
            backgroundColor: Colors.blue,
          ),
          SizedBox(height: 10),
          Container(
            alignment: Alignment.center,
            child: GestureDetector(
              onTap: () => _onTapSignUp(context),
              child: Text("Don't have an account? Sign Up",
                  style: CustomTextStyles.labelLargeBlueA700),
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
            obscureText: isPassword ? _obscureTextPassword : false,
            style: TextStyle(fontSize: 16),
            validator: validator,
            decoration: InputDecoration(
              prefixIcon: Icon(
                prefixIcon,
                color: Colors.blue,
              ),
              suffixIcon: isPassword
                  ? IconButton(
                      icon: Icon(
                        _obscureTextPassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureTextPassword = !_obscureTextPassword;
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

  void _onTapLOGIN(BuildContext context) async {
    print('login clicked');
    if (_formKey.currentState?.validate() ?? false) {
      try {
        // Authenticate the user
        UserCredential userCredential =
            await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );

        // Check the user's role
        bool isAdmin = await checkUserRole(userCredential.user?.uid);

        // Navigate based on the user's role
        if (isAdmin) {
          // Navigate to admin home screen
          print("user is admin");
          Navigator.pushNamed(context, AppRoutes.homeScreen);
          print("After navigating to home screen");
        } else {
          print("user is not admin");
          // Navigate to regular user home screen
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.userhomeScreen,
            (route) => false,
          );
        }
      } on FirebaseAuthException catch (e) {
        // Authentication failed
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Login Failed'),
              content: Text(e.message ?? 'An error occurred.'),
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
    }
  }

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

  Future<bool> checkUserRole(String? userId) async {
    // check the user's role based on the UID
    return userId == "nMNTP9dnieM9zD1B9AcFMmN8T2v2";
  }

  void _onTapSignUp(BuildContext context) {
    print("Tapped SIGN UP button"); // Add this line for debugging
    // Implement your logic to navigate to the sign-up screen or perform sign-up actions
    // For example, you can use Navigator to navigate to a different screen for sign-up:
    Navigator.pushNamed(context, AppRoutes.signUpScreen);
  }

  void onTapTxtForgotPassword(BuildContext context) {
    // Navigate to the ForgotpasswordScreen
    Navigator.pushNamed(context, AppRoutes.forgotpasswordScreen);
  }
}
