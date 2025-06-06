import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'dart:math' as math;
import 'dart:io';
import 'package:reksti_app/user_provider.dart';

import 'package:reksti_app/services/token_service.dart';

import 'package:reksti_app/screens/login_page.dart';
import 'package:reksti_app/screens/home_page.dart';
import 'package:reksti_app/screens/scan_page.dart';
import 'package:reksti_app/screens/syarat_page.dart';
import 'package:reksti_app/screens/privacy_page.dart';
import 'package:reksti_app/screens/notification_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _bottomNavIndex = 2;

  final TokenStorageService tokenStorage = TokenStorageService();

  @override
  void initState() {
    super.initState();
  }

  Future<void> _triggerPickProfileImage() async {
    await Provider.of<UserProvider>(
      context,
      listen: false,
    ).pickAndSaveProfileImage();
  }

  Widget _buildImagePlaceholder({
    double? width,
    double? height,
    IconData icon = Icons.image,
    Color backgroundColor = const Color(0xFFE0E0E0),
    Color iconColor = const Color(0xFF9E9E9E),
  }) {
    double concreteIconSize;

    if (width != null && width.isFinite && width > 0) {
      concreteIconSize = width / 3.5;
    } else if (height != null && height.isFinite && height > 0) {
      concreteIconSize = height / 3.5;
    } else {
      concreteIconSize = 24.0;
    }

    concreteIconSize = math.min(concreteIconSize, 48.0);
    concreteIconSize = math.max(16.0, concreteIconSize);

    return Container(
      width: width,
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
    final topSafeAreaPadding = MediaQuery.of(context).padding.top;

    final userProvider = Provider.of<UserProvider>(context);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFAF4F5), Color(0xFFFFFFFF)],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(0),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            systemOverlayStyle: SystemUiOverlayStyle.dark,
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              _buildProfileHeader(
                screenSize,
                topSafeAreaPadding,
                userProvider.isLoadingProfile,
                userProvider.profileRecipientName,
                userProvider.profileRecipientAddress,
                userProvider.profileImageFile,
                userProvider.profileError,
              ),
              _buildProfileMenuList(userProvider),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomNavigationBar(),
      ),
    );
  }

  Widget _buildProfileHeader(
    Size screenSize,
    double topSafeArea,
    bool isLoading,
    String? recipientName,
    String? recipientAddress,
    File? profileImageFile,
    String profileError,
  ) {
    String displayName =
        isLoading && recipientName == null
            ? ""
            : (recipientName ?? "Nama tidak tersedia");
    String displayAddress =
        isLoading && recipientAddress == null
            ? ""
            : (recipientAddress ?? "Alamat tidak tersedia");
    String avatarLetter =
        isLoading || recipientName == null || recipientName.isEmpty
            ? "X"
            : recipientName[0].toUpperCase();

    if (profileError.isNotEmpty && !isLoading) {
      displayName = "Error";
      displayAddress = "Gagal memuat data";
    }

    return Stack(
      clipBehavior: Clip.none,

      children: [
        Container(
          height: screenSize.height * 0.22,
          width: double.infinity,
          child: Image.asset(
            'assets/images/profile_banner.png',
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

        Positioned(
          top: screenSize.height * 0.22 - 50,
          left: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.deepPurple[400],
                backgroundImage:
                    profileImageFile != null && profileImageFile.existsSync()
                        ? FileImage(profileImageFile)
                        : null,
                child:
                    profileImageFile == null
                        ? Text(
                          avatarLetter,
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        )
                        : null,
              ),
              const SizedBox(height: 12),
              if (isLoading && recipientName == null)
                CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black87),
                )
              else
                Text(
                  displayName,
                  style: TextStyle(
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
                    child: Text(
                      displayAddress,
                      textAlign: TextAlign.left,
                      style: TextStyle(fontSize: 11, color: Colors.grey[700]),
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

  Widget _buildProfileMenuList(UserProvider userProvider) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            top: 145.0,
            left: 20.0,
            right: 20.0,
            bottom: 20.0,
          ),
          child: Column(
            children: [
              _buildProfileMenuItem(
                icon: Icons.notifications_none_outlined,
                text: 'Notifikasi',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationPage(),
                    ),
                  );
                },
              ),
              _buildProfileMenuItem(
                icon: Icons.article_outlined,
                text: 'Syarat dan Ketentuan',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SyaratPage()),
                  );
                },
              ),
              _buildProfileMenuItem(
                icon: Icons.shield_outlined,
                text: 'Privacy Policy',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PrivacyPage(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
              _buildProfileMenuItem(
                icon: Icons.logout,
                text: 'Keluar',
                isLogout: true,
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext dialogContext) {
                      return AlertDialog(
                        title: Text("Konfirmasi Keluar"),
                        content: Text(
                          "Apakah Anda yakin ingin log out dari aplikasi ?",
                        ),
                        actions: <Widget>[
                          TextButton(
                            child: Text("Batal"),
                            onPressed: () {
                              Navigator.of(dialogContext).pop();
                            },
                          ),
                          TextButton(
                            child: Text(
                              "Keluar",
                              style: TextStyle(color: Colors.red),
                            ),
                            onPressed: () async {
                              Navigator.of(dialogContext).pop();

                              await userProvider.clearProfileDataOnLogout();

                              if (mounted) {
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                    builder: (context) => LoginPage(),
                                  ),
                                  (Route<dynamic> route) => false,
                                );
                              }
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
        ),
        Positioned(
          top: 10,
          right: 10,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 5,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(
                Icons.edit_outlined,
                color: Colors.deepPurple[400],
                size: 22,
              ),
              onPressed: () async {
                await _triggerPickProfileImage();
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileMenuItem({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    final double borderRadiusValue = 12.0;
    final double borderWidth = 1.5;

    final EdgeInsets contentPadding = const EdgeInsets.symmetric(
      horizontal: 16.0,
      vertical: 14.0,
    );

    Widget itemContent = Padding(
      padding: contentPadding,
      child: Row(
        children: [
          Icon(
            icon,
            color: isLogout ? Colors.deepPurple[700] : Colors.deepPurple[400],
            size: 22,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: isLogout ? Colors.deepPurple[700] : Colors.black87,
              ),
            ),
          ),
          if (!isLogout)
            Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
        ],
      ),
    );

    if (isLogout) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFCBC6F0), Color(0xFFF1C4E4)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(borderRadiusValue),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              spreadRadius: 1,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(borderRadiusValue),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(borderRadiusValue),
            child: itemContent,
          ),
        ),
      );
    } else {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        padding: EdgeInsets.all(borderWidth),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFCBC6F0), Color(0xFFF1C4E4)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(borderRadiusValue),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              spreadRadius: 1,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(
              borderRadiusValue - borderWidth,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(
              borderRadiusValue - borderWidth,
            ),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(
                borderRadiusValue - borderWidth,
              ),
              child: itemContent,
            ),
          ),
        ),
      );
    }
  }

  Widget _buildBottomNavigationBar() {
    const double barHeight = 160;
    String currentNavBarImage;

    switch (_bottomNavIndex) {
      case 0:
        currentNavBarImage = 'assets/images/navbar1.png';
        break;
      case 1:
        currentNavBarImage = 'assets/images/navbar2.png';
        break;
      case 2:
        currentNavBarImage = 'assets/images/navbar3.png';
        break;
      default:
        currentNavBarImage = 'assets/images/navbar3.png';
    }

    return Container(
      height: barHeight,
      width: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(currentNavBarImage),
          fit: BoxFit.cover,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HomePage()),
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
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ScanPage()),
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
