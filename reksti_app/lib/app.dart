// lib/app.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // If you're using it
// Import your initial screen (e.g., login screen or home screen)
import 'package:reksti_app/screens/login_page.dart'; // Adjust path
//import 'package:reksti_app/screens/profile_page.dart'; // Adjust path
// Or, if you have a splash screen or home screen as initial:
// import 'package:your_flutter_project/features/home/screens/home_screen.dart';
// Import your theme if it's in a separate file
// import 'package:your_flutter_project/core/theme/app_theme.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'REKSTI APP', // Replace with your app title
      theme: ThemeData(
        // Or use your custom theme from app_theme.dart
        primarySwatch: Colors.purple, // Example
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
      ),
      // Define your initial route or home screen
      home: const LoginPage(), // Replace with your app's starting screen
      //home: const ProfilePage(),
      // You might also set up named routes here if you're using them:
      // routes: AppRoutes.routes, // Assuming AppRoutes is defined in core/navigation/
      // initialRoute: RouteNames.splash, // Or your initial route name
      debugShowCheckedModeBanner: false,
    );
  }
}
