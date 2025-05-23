import 'package:flutter/material.dart';
import 'package:reksti_app/screens/historipesanan_page.dart';
import 'package:reksti_app/screens/scan_page.dart';
import 'package:reksti_app/screens/profile_page.dart';
import 'package:reksti_app/services/logic_service.dart';
import 'package:reksti_app/model/Shipment.dart';
import 'package:reksti_app/Exception.dart';
import 'package:reksti_app/services/token_service.dart';

// Placeholder data for products
class Product {
  final String name;
  final String imagePath;

  Product({required this.name, required this.imagePath});
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _bottomNavIndex = 0; // To track selected bottom nav item
  String? _displayedUsername;
  bool _isLoadingOrders = true;
  bool _isLoadingUsername = true;
  final TokenStorageService tokenStorage = TokenStorageService();
  String _orderErrorMessage = '';
  List<ShipmentItem> _processedTodayOrders = [];

  final _logicService = LogicService();

  @override
  void initState() {
    super.initState();
    _handleLoadOrders(); // Call the method to load and process orders
  }

  Future<void> _handleLoadOrders() async {
    String? username = await tokenStorage.getUsername();
    if (!mounted) return;
    setState(() {
      _isLoadingOrders = true;
      _displayedUsername = username ?? "Default"; // Default if not found
      _isLoadingUsername = false;
      _orderErrorMessage = '';
    });

    try {
      final List<dynamic> rawShipmentData = await _logicService.getOrder();

      final List<Shipment> shipments =
          rawShipmentData.map((data) => Shipment.fromJson(data)).toList();

      if (!mounted) return;

      List<ShipmentItem> allItems = [];
      for (var shipment in shipments) {
        allItems.addAll(shipment.items);
      }

      setState(() {
        _processedTodayOrders = allItems;
        _isLoadingOrders = false;
      });
    } catch (e) {
      if (!mounted) return; // Check mounted again after await
      setState(() {
        _orderErrorMessage = "Gagal memuat pesanan: ${e.toString()}";
        _isLoadingOrders = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(' Get Order Failed: ${e.toString()}'),
        ), // Use e.toString()
      );
    }
  }

  // Placeholder widget for image assets
  Widget _buildImagePlaceholder({
    double? width,
    double? height,
    IconData icon = Icons.image,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: Colors.grey[600], size: (width ?? 50) / 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF), // Light background color
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

          // 2. Your Main Page Content, wrapped in SafeArea (Top Layer)
          // This SafeArea is now correctly placed as a child of the Stack
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 10.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Assuming these methods are defined in your State class
                    _buildTopHeader(),
                    const SizedBox(height: 25),
                    _buildWelcomeSection(),
                    const SizedBox(height: 25),
                    _buildHistoryCard(),
                    const SizedBox(height: 30),
                    _buildTodayOrdersSection(),
                    const SizedBox(
                      height: 20,
                    ), // Space for bottom nav bar if content is short
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar:
          _buildBottomNavigationBar(), // Correctly placed as a property of Scaffold
    );
  }

  Widget _buildTopHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Home',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Row(
          children: [
            IconButton(
              icon: Icon(
                Icons.notifications_outlined,
                color: Colors.grey[700],
                size: 28,
              ),

              // onPressed: () { /* TODO: Notification action */ },
              // OR using an image asset:
              // child: Image.asset('assets/images/icon_bell.png', width: 28, height: 28),
              onPressed: () {},
            ),
            const SizedBox(width: 10),
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.grey[300],
              child: Icon(Icons.person, color: Colors.grey[700]),
            ),

            // User Profile Avatar
            // IMPORTANT: Replace with your user profile image
          ],
        ),
      ],
    );
  }

  Widget _buildWelcomeSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Selamat datang',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Text(
              _displayedUsername ??
                  "Pengguna", // Replace with dynamic data if needed
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
        // Waving Hand Image
        // IMPORTANT: Replace with your waving hand image/emoji
        // For example, an Image.asset or a Text widget with an emoji
        // Image.asset('assets/images/waving_hand.png', width: 40, height: 40),
        Text(
          '👋', // Emoji placeholder
          style: TextStyle(fontSize: 36),
        ),
      ],
    );
  }

  Widget _buildHistoryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
        gradient: LinearGradient(
          colors: [Color(0xFFF2CBEF), Color(0xFFE8CDFD), Color(0XFFF2CBEF)],
          stops: [0.0, 0.48, 1],
          begin: Alignment.topLeft,

          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Row(
            children: [
              Expanded(
                flex: 3, // Give more space to text content
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Histori Pesananmu',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF571589),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Cek hasil pesanan yang \nsudah Anda pindaiin',
                      style: TextStyle(fontSize: 13, color: Colors.purple[700]),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HistoriPesananPage(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        elevation: 8.0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 25,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                      ),
                      child: Text(
                        'Lihat Histori',
                        style: TextStyle(
                          color: Colors.purple[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(
                flex: 1,
              ), // Spacer to push illustration to the right if needed
            ],
          ),
          Positioned(
            right: -20, // Adjust as needed to position illustration
            top: -10,
            bottom: -10,
            width: MediaQuery.of(context).size.width * 0.25, // Adjust width
            child: Opacity(
              opacity:
                  0.8, // Illustration seems a bit transparent or softly blended
              // IMPORTANT: Replace with your history card illustration
              child: Image.asset(
                'assets/images/home_img.png',
                fit: BoxFit.contain, // or BoxFit.fitHeight
                errorBuilder:
                    (context, error, stacktrace) =>
                        _buildImagePlaceholder(icon: Icons.medical_services),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayOrdersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              'Pesananmu',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            if (!_isLoadingOrders && _processedTodayOrders.isNotEmpty)
              Text(
                '${_processedTodayOrders.length} Item${_processedTodayOrders.length == 1 ? "" : "s"}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
        const SizedBox(height: 15),
        if (_isLoadingOrders)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: CircularProgressIndicator(),
            ),
          )
        else if (_orderErrorMessage.isNotEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                _orderErrorMessage,
                style: TextStyle(color: Colors.red),
              ),
            ),
          )
        else if (_processedTodayOrders.isEmpty)
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Center(
              child: Text(
                "Tidak ada pesanan untuk hari ini.",
                style: TextStyle(),
              ),
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _processedTodayOrders.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12.0,
              mainAxisSpacing: 12.0,
              childAspectRatio: 0.85,
            ),
            itemBuilder: (context, index) {
              final item = _processedTodayOrders[index];
              return _buildProductCard(item);
            },
          ),
      ],
    );
  }

  Widget _buildProductCard(ShipmentItem item) {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Image.asset(
                  item.imagePath,
                  fit: BoxFit.contain,
                  errorBuilder:
                      (context, error, stacktrace) =>
                          _buildImagePlaceholder(icon: Icons.medication),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              item.productName,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              "Qty: ${item.quantity}",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  // --- DYNAMIC CUSTOM BOTTOM NAVIGATION BAR ---
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
        currentNavBarImage = 'assets/images/navbar1.png'; // Default
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
                setState(() => _bottomNavIndex = 0);
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
