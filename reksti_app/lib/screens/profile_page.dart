import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math; // For PI

import 'package:reksti_app/screens/home_page.dart';
import 'package:reksti_app/screens/scan_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Set initial index to 2 for Profile page
  int _bottomNavIndex = 2;

  Widget _buildImagePlaceholder({
    double? width,
    double? height,
    IconData icon = Icons.image,
    Color backgroundColor = const Color(0xFFE0E0E0), // Slightly darker grey
    Color iconColor = const Color(0xFF9E9E9E),
  }) {
    double concreteIconSize;

    // Determine a finite size for the icon
    if (width != null && width.isFinite && width > 0) {
      concreteIconSize = width / 3.5; // Make icon smaller relative to width
    } else if (height != null && height.isFinite && height > 0) {
      concreteIconSize = height / 3.5; // Or base it on height
    } else {
      concreteIconSize = 24.0; // Default fallback size
    }
    // Ensure the icon size is not excessively large if container is huge but unconstrained
    concreteIconSize = math.min(concreteIconSize, 48.0); // Max icon size
    concreteIconSize = math.max(16.0, concreteIconSize); // Min icon size

    return Container(
      width: width, // Container can still try to match the requested width
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: iconColor, size: concreteIconSize),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return
    // 3. Main Scaffold (Top Layer)
    Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF1C4E4), Color(0xFFFFFFFF)],
          stops: [0.4, 0.8],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent, // To see the Stack background
        appBar: PreferredSize(
          // Use PreferredSize to remove AppBar but keep height for status bar
          preferredSize: Size.fromHeight(0),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            systemOverlayStyle:
                SystemUiOverlayStyle.dark, // For status bar icons
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildProfileHeader(screenSize),
                _buildProfileMenuList(),
              ],
            ),
          ),
        ),
        bottomNavigationBar: _buildBottomNavigationBar(),
      ),
    );
  }

  Widget _buildProfileHeader(Size screenSize) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        // Banner Image
        Container(
          height: screenSize.height * 0.22, // Adjust height as needed
          width: double.infinity,
          child: Image.asset(
            // IMPORTANT: Replace with your banner image
            'assets/images/profile_banner.jpg',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stacktrace) {
              return _buildImagePlaceholder(
                width: double.infinity,
                height: screenSize.height * 0.22,
                icon: Icons.medical_services_outlined,
              );
            },
          ),
        ),
        // Edit Icon Button
        Positioned(
          top: 10,
          right: 10,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                Icons.edit_outlined,
                color: Colors.deepPurple[400],
                size: 20,
              ),
              onPressed: () {
                // TODO: Navigate to Edit Profile Page
                print("Edit profile tapped");
              },
            ),
          ),
        ),
        // Profile Avatar, Name, and Address
        Positioned(
          top:
              screenSize.height * 0.22 -
              50, // (Banner Height - Half of Avatar Height)
          child: Column(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.deepPurple[400], // Color from image
                child: Text(
                  'R', // Initial or from user data
                  style: GoogleFonts.poppins(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Rs. Sadikin', // Replace with dynamic user name
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    color: Colors.grey[600],
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    // To prevent overflow if address is long
                    child: Text(
                      'Jl. Pasteur No.38, Pasteur, Kec. Sukajadi,\nKota Bandung, Jawa Barat 40161', // Replace
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileMenuList() {
    return Padding(
      padding: const EdgeInsets.only(
        top: 70.0,
        left: 20.0,
        right: 20.0,
        bottom: 20.0,
      ), // Added top padding
      child: Column(
        children: [
          _buildProfileMenuItem(
            icon: Icons.notifications_none_outlined,
            text: 'Notifikasi',
            onTap: () {
              // TODO: Navigate to Notifikasi page
              print("Notifikasi tapped");
            },
          ),
          _buildProfileMenuItem(
            icon: Icons.article_outlined, // Or a custom icon
            text: 'Syarat dan Ketentuan',
            onTap: () {
              // TODO: Navigate to Syarat dan Ketentuan page
              print("Syarat dan Ketentuan tapped");
            },
          ),
          _buildProfileMenuItem(
            icon: Icons.shield_outlined, // Or a custom icon
            text: 'Privacy Policy',
            onTap: () {
              // TODO: Navigate to Privacy Policy page
              print("Privacy Policy tapped");
            },
          ),
          const SizedBox(height: 10), // Spacer
          _buildProfileMenuItem(
            icon: Icons.logout,
            text: 'Keluar',
            isLogout: true, // Special styling for logout
            onTap: () {
              // TODO: Implement logout functionality
              print("Keluar tapped");
              // Example: show confirmation dialog
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text("Konfirmasi Keluar"),
                    content: Text("Apakah Anda yakin ingin keluar?"),
                    actions: <Widget>[
                      TextButton(
                        child: Text("Batal"),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      TextButton(
                        child: Text(
                          "Keluar",
                          style: TextStyle(color: Colors.red),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop(); // Close dialog
                          // Perform logout action
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProfileMenuItem({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color:
            isLogout
                ? Color(0xFFE8DAFF)
                : Colors.white, // Light purple for logout, white for others
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        // Added Material for InkWell splash effect
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 14.0,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color:
                      isLogout
                          ? Colors.deepPurple[600]
                          : Colors.deepPurple[400],
                  size: 22,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    text,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: isLogout ? Colors.deepPurple[700] : Colors.black87,
                    ),
                  ),
                ),
                if (!isLogout)
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey[400],
                    size: 16,
                  ),
              ],
            ),
          ),
        ),
      ),
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
                //setState(() => _bottomNavIndex = 1);
                Navigator.push(
                  // Or Navigator.push if you want 'back' functionality
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ScanPage(),
                  ), // Navigate to your actual ScanPage
                );
              },
              splashColor: Colors.white.withOpacity(0.1),
              highlightColor: Colors.white.withOpacity(0.05),
              child: Container(),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () {
                setState(() => _bottomNavIndex = 2);
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
