import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pethub_admin/admin_module/login_screen.dart';
import 'package:pethub_admin/routes/app_routes.dart';
import 'package:pethub_admin/theme/theme_helper.dart';
import 'package:pethub_admin/user_module/wishlist_item.dart';
import 'package:pethub_admin/user_module/order_item.dart';

bool isAuthenticated = false;

var globalMessengerKey = GlobalKey<ScaffoldMessengerState>();

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

// Initialize Hive
  await Hive.initFlutter();
  Hive.registerAdapter(WishlistAdapter());
  Hive.registerAdapter(OrderAdapter());

  if (!Hive.isBoxOpen('orderBox')) {
    await Hive.openBox<OrderItem>('orderBox');
  }

// Open wishlist box only if it's not already open
  if (!Hive.isBoxOpen('wishlistBox')) {
    await Hive.openBox<WishlistItem>('wishlistBox');
  }

  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyB9QPnKjq9LFYgSiUN1ZvBSSHN87fkmmzI",
      appId: "1:710740617944:android:edd4c799f568e82325c5ad",
      messagingSenderId: "710740617944",
      projectId: "pethub-4694f",
      storageBucket: "gs://pethub-4694f.appspot.com",
    ),
  );
  await FirebaseAppCheck.instance.activate();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  ThemeHelper().changeTheme('primary');

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Hive.openBox<User>('userBox');
    return MaterialApp(
      theme: theme,
      title: 'petadoption',
      debugShowCheckedModeBanner: false,
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            User? user = snapshot.data as User?;
            isAuthenticated = user != null;

            if (isAuthenticated) {
              // Check the user's role and route accordingly
              checkUserRole(user?.uid).then((isAdmin) {
                if (isAdmin) {
                  Navigator.of(context)
                      .pushReplacementNamed(AppRoutes.homeScreen);
                } else {
                  Navigator.of(context)
                      .pushReplacementNamed(AppRoutes.userhomeScreen);
                }
              });
            } else {
              // User is not authenticated, show the login screen
              return LoginScreen();
            }
          }

          // Return a loading screen while checking authentication state
          return LoadingScreen();
        },
      ),
      routes: AppRoutes.routes,
    );
  }

  Future<bool> checkUserRole(String? userId) async {
    // Implement your logic to check the user's role based on the UID
    // and check a field like 'isAdmin'
    // This is just a placeholder, modify it according to your data structure.
    return userId == "nMNTP9dnieM9zD1B9AcFMmN8T2v2";
  }
}

class LoadingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
