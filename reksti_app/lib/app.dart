import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:reksti_app/screens/login_page.dart';
import 'package:provider/provider.dart';
import 'package:reksti_app/user_provider.dart';
import 'package:reksti_app/screens/login_page.dart';
import 'package:reksti_app/screens/home_page.dart';
import 'package:reksti_app/screens/profile_page.dart';
import 'package:reksti_app/screens/scan_page.dart';

class MyApp extends StatefulWidget {
  final String initialRoute;
  final String? sessionUsername;

  const MyApp({super.key, required this.initialRoute, this.sessionUsername});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    if (widget.sessionUsername != null && widget.sessionUsername!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<UserProvider>(context, listen: false).initializeSession();
        print(
          "MyApp initState: User session detected for ${widget.sessionUsername}. UserProvider initializing session.",
        );
      });
    } else {
      print(
        "MyApp initState: No initial user session. UserProvider will load on demand after login.",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reksti App',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: widget.initialRoute,
      routes: {
        '/login': (context) => const LoginPage(),
        '/home': (context) => const HomePage(),
        '/profile': (context) => const ProfilePage(),
        '/scan': (context) => const ScanPage(),
      },
    );
  }
}
