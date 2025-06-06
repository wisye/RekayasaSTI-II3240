import 'package:flutter/material.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:reksti_app/screens/historipesanan_page.dart';
import 'package:reksti_app/screens/historidetail_page.dart';
import 'package:reksti_app/screens/notification_page.dart';
import 'package:reksti_app/screens/scan_page.dart';
import 'package:reksti_app/screens/profile_page.dart';
import 'package:reksti_app/services/logic_service.dart';
import 'package:reksti_app/model/Shipment.dart';
import 'package:reksti_app/user_provider.dart';
import 'package:reksti_app/services/token_service.dart';

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
  int _bottomNavIndex = 0;
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
    _handleLoadOrders();
  }

  Future<void> _handleLoadOrders() async {
    String? username = await tokenStorage.getUsername();
    if (!mounted) return;
    setState(() {
      _isLoadingOrders = true;
      _displayedUsername = username;
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
      if (!mounted) return;
      setState(() {
        _orderErrorMessage = "Gagal memuat pesanan: ${e.toString()}";
        _isLoadingOrders = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(' Get Order Failed: ${e.toString()}')),
      );
    }
  }

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

    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      body: Stack(
        children: <Widget>[
          Positioned(
            top: 0,
            left: 0,
            child: Opacity(
              opacity: 0.5,
              child: Image.asset(
                'assets/images/home_img1.png',
                width: screenSize.width * 0.6,

                fit: BoxFit.contain,
                alignment: Alignment.topLeft,
                errorBuilder: (context, error, stackTrace) {
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),

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
                    _buildTopHeader(
                      userProvider.isLoadingProfile,
                      userProvider.profileRecipientName,
                      userProvider.profileImageFile,
                    ),
                    const SizedBox(height: 25),
                    _buildWelcomeSection(),
                    const SizedBox(height: 25),
                    _buildHistoryCard(),
                    const SizedBox(height: 30),
                    _buildTodayOrdersSection(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildTopHeader(
    bool isLoading,
    String? recipientName,
    File? profileImageFile,
  ) {
    String avatarLetter =
        isLoading || recipientName == null || recipientName.isEmpty
            ? "X"
            : recipientName[0].toUpperCase();

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

              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NotificationPage()),
                );
              },
            ),
            const SizedBox(width: 10),
            CircleAvatar(
              radius: 20,
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
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      )
                      : null,
            ),
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
              _displayedUsername ?? "Pengguna",
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),

        Text('👋', style: TextStyle(fontSize: 36)),
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
                flex: 3,
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
              const Spacer(flex: 1),
            ],
          ),
          Positioned(
            right: -20,
            top: -10,
            bottom: -10,
            width: MediaQuery.of(context).size.width * 0.25,
            child: Opacity(
              opacity: 0.8,

              child: Image.asset(
                'assets/images/home_img.png',
                fit: BoxFit.contain,
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
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HistoriDetailPage(item: item),
          ),
        );
      },
      child: Card(
        elevation: 2.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
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
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    const double barHeight = 150;
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
        currentNavBarImage = 'assets/images/navbar1.png';
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
                setState(() => _bottomNavIndex = 0);
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
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
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
