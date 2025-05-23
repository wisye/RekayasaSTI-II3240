import 'package:flutter/material.dart'; // Make sure you have google_fonts in pubspec.yaml
import 'dart:ui'; // For ImageFilter.blur
import './register_page.dart';
import './home_page.dart';
import 'package:reksti_app/services/auth_service.dart';
import 'package:reksti_app/Exception.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  // Assuming AuthService is correctly defined and imported.
  // If not, you might need to create a placeholder or ensure it's available.
  final AuthService _authService = AuthService();

  bool _isLoading = false;

  bool _isPasswordVisible = false;

  @override
  void dispose() {
    // Clean up the controllers when the widget is disposed.
    _usernameController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_isLoading) return; // Prevent multiple submissions
    if (!mounted) return; // Check if the widget is still in the tree

    // Get values and trim where appropriate
    final String username = _usernameController.text.trim();
    final String password =
        _passwordController.text; // Don't trim password for validation/sending

    // --- Refined Validation ---
    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fill all fields.')));
      return;
    }

    // --- End of Refined Validation ---

    setState(() {
      _isLoading = true;
    });

    // print('Logging in user:');
    // print('Username: $username');
    // print(
    //   'Password: $password',
    // ); // Log raw password for debugging (consider removing in prduction)

    try {
      // Call AuthService with non-trimmed password
      // Ensure your AuthService.registerUser method signature matches these arguments
      await _authService.loginUser(
        username, // Trimmed username
        password, // Raw password
      );

      if (!mounted) return; // Check mounted again after await

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login Successful!'),
          duration: Duration(seconds: 1), // Show for a bit longer
        ),
      );
      // Navigate to login page, replacing the current route
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } on AuthenticationException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Login Failed: ${e.message}')));
    } on ServerException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Server Error: ${e.message}')));
    } on NetworkException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Network Error: ${e.message}')));
    } catch (e) {
      if (!mounted) return; // Check mounted again after await
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login Failed: ${e.toString()}'),
        ), // Use e.toString()
      );
    } finally {
      if (mounted) {
        // Check mounted in finally block
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    const double formElementWidth = 320.0;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        // The main decoration is now part of the Stack's base layer
        // to allow aurora spots to be overlaid correctly.
        child: Stack(
          // MODIFIED: Using Stack to layer aurora effect and content
          children: [
            // Aurora Background Effect Layer
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                // Base overall gradient for the purple theme
                color: Color(0xFFC3A1FE),
              ),
              child: Stack(
                // Inner stack for the aurora spots
                children: [
                  // Soft Spot 1 (Top-ish left)
                  Positioned(
                    top: screenSize.height * 0.05, // Adjusted position
                    left:
                        screenSize.width *
                        -0.1, // Slightly off-screen for softer edge
                    child: Container(
                      width: screenSize.width * 0.7,
                      height: screenSize.width * 0.7,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Colors.white.withOpacity(
                              0.06,
                            ), // Very subtle white/light glow
                            Colors.white.withOpacity(
                              0.0,
                            ), // Fade to fully transparent
                          ],
                          radius: 0.5,
                        ),
                      ),
                    ),
                  ),

                  // Soft Spot 2 (Center-ish right)
                  Positioned(
                    top: screenSize.height * 0.25, // Adjusted position
                    right: screenSize.width * -0.15, // Slightly off-screen
                    child: Container(
                      width: screenSize.width * 0.8,
                      height: screenSize.width * 0.8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Color(
                              0xFFE1BEE7,
                            ).withOpacity(0.08), // Very light lavender glow
                            Color(0xFFE1BEE7).withOpacity(0.0),
                          ],
                          radius: 0.5,
                        ),
                      ),
                    ),
                  ),

                  // Soft Spot 3 (Bottom-ish left)
                  Positioned(
                    bottom: screenSize.height * 0.02, // Adjusted position
                    left: screenSize.width * 0.1,
                    child: Container(
                      width: screenSize.width * 0.9,
                      height: screenSize.width * 0.6,
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [
                            Colors.white.withOpacity(0.05),
                            Colors.white.withOpacity(0.0),
                          ],
                          radius: 0.7,
                          center: Alignment(0.0, 0.3),
                        ),
                      ),
                    ),
                  ),
                  // Optional: A subtle blur overlay to soften the spots more
                  BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: 50.0,
                      sigmaY: 50.0,
                    ), // Adjust blur intensity
                    child: Container(
                      color: Colors.black.withOpacity(
                        0.0,
                      ), // Needs a color to apply filter
                    ),
                  ),
                ],
              ),
            ),

            // Login Form Layer (original content)
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: 400,
                    minHeight:
                        screenSize.height -
                        (MediaQuery.of(context).padding.top +
                            MediaQuery.of(context).padding.bottom),
                  ),
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment
                            .start, // To keep form elements starting from top of this column
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      // Spacing to push content below status bar and top of screen
                      SizedBox(height: MediaQuery.of(context).padding.top + 20),

                      Container(
                        height:
                            screenSize.height *
                            0.20, // Adjusted height for the image
                        width: double.infinity,
                        margin: const EdgeInsets.only(
                          bottom: 15.0,
                        ), // Added some margin
                        child: Image.asset(
                          'assets/images/login_img.png',
                          fit:
                              BoxFit
                                  .contain, // Changed to contain to see full image
                          errorBuilder: (context, error, stackTrace) {
                            print(
                              "Error loading image 'assets/images/login_img.png': $error",
                            );
                            return Container(
                              color: Colors.black.withOpacity(0.1),
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.broken_image_outlined,
                                    size: 50,
                                    color: Colors.white70,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    "Image not found",
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 15.0),

                      const Text(
                        'Welcome Back!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Color(0xFF5C5A5A), height: 1.5),
                          children: [
                            const TextSpan(
                              text: 'welcome back we missed you,\n',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text: 'don\'t have an account? ',
                              style: TextStyle(
                                color: Color(0xFF5C5A5A),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            WidgetSpan(
                              alignment: PlaceholderAlignment.middle,
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => const RegisterPage(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'Click here',
                                  style: TextStyle(
                                    fontSize: 13.0,
                                    color: Colors.redAccent,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline,
                                    decorationColor: Colors.redAccent,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 25.0),

                      SizedBox(
                        width:
                            formElementWidth, // To align with the TextField below
                        child: Align(
                          alignment:
                              Alignment.centerLeft, // Align text to the left
                          child: Text(
                            'Username', // Your desired label text
                            style: TextStyle(
                              // Style the label as needed, e.g., make it match your theme
                              // Ensure the color is visible on your frosted card background
                              color: Color(0xFF5C5A5A).withOpacity(0.9),
                              fontWeight: FontWeight.w500, // Medium bold
                              fontSize:
                                  14.0, // Or use Theme.of(context).textTheme.labelLarge?.fontSize
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8.0),

                      SizedBox(
                        width: formElementWidth,
                        child: _buildTextField(
                          controller: _usernameController,
                          hintText: 'Username',
                          prefixIcon: Icons.person_outline,
                        ),
                      ),
                      const SizedBox(height: 8.0),

                      SizedBox(
                        width:
                            formElementWidth, // To align with the TextField below
                        child: Align(
                          alignment:
                              Alignment.centerLeft, // Align text to the left
                          child: Text(
                            'Password', // Your desired label text
                            style: TextStyle(
                              // Style the label as needed, e.g., make it match your theme
                              // Ensure the color is visible on your frosted card background
                              color: Color(0xFF5C5A5A).withOpacity(0.9),
                              fontWeight: FontWeight.w500, // Medium bold
                              fontSize:
                                  14.0, // Or use Theme.of(context).textTheme.labelLarge?.fontSize
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8.0),

                      SizedBox(
                        width: formElementWidth,
                        child: _buildTextField(
                          controller: _passwordController,
                          hintText: 'Password',
                          prefixIcon: Icons.key_outlined,
                          obscureText: !_isPasswordVisible,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: Color(0xFF5C5A5A),
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 8.0),

                      SizedBox(
                        width: formElementWidth,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              print('Forgot Password Tapped');
                            },
                            child: const Text(
                              'Forgot Password?',
                              style: TextStyle(
                                color: Color(0xFF5C5A5A),
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(
                        width: formElementWidth,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 15.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            elevation: 0,
                          ),
                          onPressed: _isLoading ? null : _handleLogin,

                          child: Ink(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF9C3FE4), Color(0xFFC65647)],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            child: Container(
                              alignment: Alignment.center,
                              constraints: const BoxConstraints(
                                minHeight: 50.0,
                              ),
                              child: const Text(
                                'Sign in',
                                style: TextStyle(
                                  fontSize: 17.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40.0),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String hintText,
    required IconData prefixIcon,
    TextEditingController? controller,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: const TextStyle(color: Color(0xFF5C5A5A), fontSize: 14),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Color(0xFF5C5A5A), fontSize: 14),
        prefixIcon: Icon(prefixIcon, color: Color(0xFF5C5A5A), size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white.withOpacity(0.15),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16.0,
          horizontal: 22.0,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(color: Colors.white70, width: 1.0),
        ),
      ),
    );
  }
}
