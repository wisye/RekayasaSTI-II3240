import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:reksti_app/screens/home_page.dart';
import 'package:reksti_app/screens/profile_page.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  // Set initial index to 1 for Scan page
  int _bottomNavIndex = 1;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF), // To see the Stack background

      body: Stack(
        // Stack is the direct child of the Scaffold's body
        children: <Widget>[
          // 1. Your Decorative Background Image (Bottom Layer)
          Positioned(
            top: 0, // Align to the top
            left: 0, // Align to the left
            child: Opacity(
              // Optional: if you want it to be slightly transparent
              opacity: 0.5, // Adjust opacity value (0.0 to 1.0)
              child: Image.asset(
                'assets/images/home_img1.png', // YOUR IMAGE PATH
                width: screenSize.width * 0.6, // Example: 60% of screen width
                // height: screenSize.height * 0.4, // Example: 40% of screen height
                fit: BoxFit.contain,
                alignment: Alignment.topLeft,
                errorBuilder: (context, error, stackTrace) {
                  return const SizedBox.shrink(); // Don't show anything if image fails to load
                },
              ),
            ),
          ),

          SafeArea(
            child: LayoutBuilder(
              builder: (
                BuildContext context,
                BoxConstraints viewportConstraints,
              ) {
                return SingleChildScrollView(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight:
                            viewportConstraints
                                .maxHeight, // Ensure content area can be at least as tall as viewport
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical: 20.0,
                        ), // Adjusted vertical padding
                        child: Column(
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .center, // Vertically center the content
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .center, // Horizontally center children
                          children: [
                            // SizedBox(height: screenSize.height * 0.05), // Top space, can be adjusted or removed
                            Text(
                              'Panduan Melakukan\nPindahan Tags NFC',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                height: 1.3,
                              ),
                            ),
                            SizedBox(
                              height: screenSize.height * 0.04,
                            ), // Space between title and card
                            _buildInstructionCard(),
                            // SizedBox(height: screenSize.height * 0.1), // Bottom space, can be adjusted or removed
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildInstructionCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
      decoration: BoxDecoration(
        color: Color(0xFFE8CDFD).withOpacity(0.10), // Semi-transparent white
        borderRadius: BorderRadius.circular(25.0),
      ),
      child: Column(
        children: [
          _buildInstructionStep(
            icon: Icons.nfc, // Material icon for NFC
            text: 'Aktifkan NFC pada perangkat \nAnda lewat Settings',
          ),
          SizedBox(height: 30),
          _buildInstructionStep(
            icon: Icons.discount, // Material icon for Tag
            text:
                'Letakkan bagian belakang \nperangkat pada tag NFC \nyang ingin dibaca.',
          ),
          SizedBox(height: 30),
          _buildInstructionStep(
            icon: Icons.article, // Material icon for Document/List
            text: 'Baca informasi yang \nterkandung dalam tag \ntersebut',
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionStep({required IconData icon, required String text}) {
    return Column(
      children: [
        Icon(
          icon,
          size: 48,
          color: Color(0xFFB379DF), // Light purple icon color from image
        ),
        const SizedBox(height: 12),
        Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            color: Color(0xFF594A75), // Darker purple text for instructions
            height: 1.4,
          ),
        ),
      ],
    );
  }

  // --- Reusing Bottom Navigation Bar from HomePage ---
  Widget _buildBottomNavigationBar() {
    const double barHeight = 160; // Adjust to the actual height of your images
    String currentNavBarImage;

    switch (_bottomNavIndex) {
      case 0: // Home selected
        currentNavBarImage = 'assets/images/navbar1.png';
        break;
      case 1: // Scan selected
        currentNavBarImage = 'assets/images/navbar2.png';
        break;
      case 2: // Profile selected
        currentNavBarImage = 'assets/images/navbar3.png';
        break;
      default:
        currentNavBarImage = 'assets/images/navbar3.png'; // Default
    }

    return Container(
      height: barHeight,
      width: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(currentNavBarImage),
          fit: BoxFit.cover, // Or BoxFit.fill, BoxFit.fitWidth
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment:
            CrossAxisAlignment.stretch, // Make InkWells fill height
        children: <Widget>[
          Expanded(
            child: InkWell(
              onTap: () {
                // setState(() => _bottomNavIndex = 0);
                Navigator.push(
                  // Or Navigator.push if you want 'back' functionality
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HomePage(),
                  ), // Navigate to your actual HomePage
                );
              },
              splashColor: Colors.white.withOpacity(
                0.1,
              ), // Optional visual feedback
              highlightColor: Colors.white.withOpacity(0.05),
              child:
                  Container(), // Empty container, tap area is the Expanded widget
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () {
                setState(() => _bottomNavIndex = 1);
              },
              splashColor: Colors.white.withOpacity(0.1),
              highlightColor: Colors.white.withOpacity(0.05),
              child: Container(),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () {
                // setState(() => _bottomNavIndex = 2);
                Navigator.push(
                  // Or Navigator.push if you want 'back' functionality
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfilePage(),
                  ), // Navigate to your actual ProfilePage
                );
              },
              splashColor: Colors.white.withOpacity(0.1),
              highlightColor: Colors.white.withOpacity(0.05),
              child: Container(),
            ),
          ),
        ],
      ),
    );
  }
}
