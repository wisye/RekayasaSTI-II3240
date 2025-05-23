import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:reksti_app/model/Shipment.dart';
import 'package:reksti_app/services/logic_service.dart';
import 'package:reksti_app/screens/historipesanan_page.dart';

class HistoriDetailPage extends StatefulWidget {
  // In a real app, you'd pass the actual Shipment object or its ID
  final ShipmentItem item;

  const HistoriDetailPage({super.key, required this.item});

  @override
  State<HistoriDetailPage> createState() => _HistoriDetailPageState();
}

class _HistoriDetailPageState extends State<HistoriDetailPage> {
  late DateTime _estimatedArrivalDate;
  late DateTime? _actualOrEstimatedDeliveryDateInfo;

  @override
  void initState() {
    super.initState();
    _estimatedArrivalDate = widget.item.shippingDate.add(
      const Duration(days: 7),
    );
    // Assuming the page details are for the first item in the shipment
    // In a real scenario, you might pass a specific item or the page focuses on the whole shipment
    if (widget.item.deliveryDate != null &&
        widget.item.deliveryDate!.isNotEmpty) {
      try {
        _actualOrEstimatedDeliveryDateInfo = DateTime.parse(
          widget.item.deliveryDate!,
        );
      } catch (e) {
        // If parsing actual delivery date fails, fall back to estimated
        _actualOrEstimatedDeliveryDateInfo = _estimatedArrivalDate;
        print(
          "Error parsing actual delivery date: ${widget.item.deliveryDate}. Using estimated.",
        );
      }
    } else {
      // If no actual delivery date, use the estimated one for info section as well
      _actualOrEstimatedDeliveryDateInfo = _estimatedArrivalDate;
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[700])),
          Text(':', style: TextStyle(fontSize: 13, color: Colors.grey[700])),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 13,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final DateFormat dateFormat = DateFormat('EEEE, d MMM yyyy', 'id_ID');
    final DateFormat shortDateFormat = DateFormat('d MMM', 'id_ID');

    return Stack(
      children: [
        Container(color: const Color(0xFFFDF6F9)), // Light pinkish background
        Positioned(
          top: -screenSize.height * 0.1,
          left: -screenSize.width * 0.2,
          child: Opacity(
            opacity: 0.6,
            child: Image.asset(
              'assets/images/home_img1.png', // Your decorative ellipse
              width: screenSize.width * 0.9,
              height: screenSize.height * 0.5,
              fit: BoxFit.contain,
              errorBuilder:
                  (context, error, stackTrace) => const SizedBox.shrink(),
            ),
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new,
                color: Colors.deepPurple[400],
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              widget.item.productName, // Product name as title
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 10.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Product Image
                Center(
                  child: Container(
                    height: screenSize.height * 0.25,
                    margin: const EdgeInsets.symmetric(vertical: 20.0),
                    child: Image.asset(
                      widget.item.imagePath, // Use drug.png or path from item
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.medication_liquid,
                          size: 100,
                          color: Colors.grey[400],
                        );
                      },
                    ),
                  ),
                ),

                // Arrival Banner
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12.0,
                    horizontal: 16.0,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFCE0E8), // Light pink from image
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Center(
                    child: Text(
                      'Pesanan akan tiba pada ${shortDateFormat.format(_estimatedArrivalDate)}',
                      style: TextStyle(
                        color: const Color(0xFF8C5B7B), // Darker pink text
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Info Produk Section
                Text(
                  'Info Produk',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildInfoRow('No Pesanan', '0001234567'),
                      _buildInfoRow(
                        'Tanggal Pemesanan',
                        dateFormat.format(widget.item.shippingDate),
                      ),
                      _buildInfoRow(
                        'Tanggal Tiba',
                        dateFormat.format(_estimatedArrivalDate),
                      ),
                      _buildInfoRow(
                        'Alamat Perusahaan',
                        widget.item.recipientAddress,
                      ),
                      _buildInfoRow(
                        'Total Produk',
                        '${widget.item.quantity} ${widget.item.productName.contains("Kardus") ? "" : (widget.item.quantity > 1 ? "pcs" : "pc")}',
                      ), // Example logic for units
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Status Pengiriman Section
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.local_shipping_outlined,
                        color: Colors.green[600],
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "Dalam Perjalanan",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.green[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Alamat Pengiriman Section
                Text(
                  'Alamat Pengiriman',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.location_on,
                        color: Colors.deepPurple[400],
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.item.recipientName,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              widget.item.recipientPhone,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.item.recipientAddress,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[700],
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30), // Space for bottom nav
              ],
            ),
          ),
        ),
      ],
    );
  }
}
