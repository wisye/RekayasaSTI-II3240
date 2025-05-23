import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:reksti_app/model/Shipment.dart';
import 'package:reksti_app/services/logic_service.dart';
import 'package:reksti_app/Exception.dart';
import 'package:reksti_app/services/token_service.dart';
import 'package:reksti_app/screens/historidetail_page.dart';
// http and dart:convert are removed as we are omitting API calls for this version

// Model for an order item
// class OrderItem {
//   final String id;
//   final String productName;
//   final DateTime orderDate;

//   OrderItem({
//     required this.id,
//     required this.productName,
//     required this.orderDate,
//   });
// }

class HistoriPesananPage extends StatefulWidget {
  const HistoriPesananPage({super.key});

  @override
  State<HistoriPesananPage> createState() => _HistoriPesananPageState();
}

class _HistoriPesananPageState extends State<HistoriPesananPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final TextEditingController _dateController = TextEditingController();
  final _logicService = LogicService();

  List<ShipmentItem> _ordersList = [];
  bool _isLoading = false; // Changed from _isLoadingOrders
  String _errorMessage = ''; // Changed from _orderErrorMessage

  final TokenStorageService tokenStorage = TokenStorageService();

  @override
  void initState() {
    super.initState();
    if (_selectedDay == null) {
      _dateController.text = 'Choose Date';
    }
    // Optionally, fetch orders for the initial selected day (e.g., today)
    // _selectedDay = _focusedDay;
    // _updateDateController(_selectedDay!);
    // _fetchOrdersForDate(_selectedDay!);
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  void _updateDateController(DateTime? date) {
    if (date != null) {
      _dateController.text = DateFormat('dd/MM/yyyy').format(date);
    } else {
      _dateController.text = 'Choose Date';
    }
  }

  // Simplified: This function will just update the date state.
  // The actual date picker UI will be triggered by tapping the TextField.
  Future<void> _handleDateInputTap() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDay ?? _focusedDay,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.deepPurple[300]!, // Header background color
              onPrimary: Colors.white, // Header text color
              onSurface: Colors.black87, // Body text color
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      _onDateSelected(picked, picked);
    }
  }

  Future<void> _fetchOrdersForDate(DateTime date) async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _ordersList = [];
    });

    try {
      // --- REPLACE WITH YOUR ACTUAL SERVICE CALL ---
      // final List<dynamic> rawShipmentData = await _logicService.getOrder(date);
      // Note: You might need to pass the 'date' to your getOrder method
      // For now, using the mock JSON structure you provided, filtered by the selected date conceptually.

      print(
        "Fetching orders for date: ${DateFormat('yyyy-MM-dd').format(date)}",
      );
      // This is where you'd call your actual _logicService.getOrder()
      // The response should be List<dynamic> as per your JSON.

      // Simulating what your _logicService.getOrder() might do,
      // including the JSON structure and a slight delay.

      List<dynamic> rawShipmentData = await _logicService.getOrder();

      // Filter mock data by the selected date (for simulation purposes)
      // In a real scenario, your API would handle this filtering.
      final String formattedSelectedDate = DateFormat(
        'yyyy-MM-dd',
      ).format(date);
      rawShipmentData =
          rawShipmentData
              .where(
                (shipment) =>
                    shipment['shipping_date'] == formattedSelectedDate,
              )
              .toList();

      if (!mounted) return;

      final List<Shipment> shipments =
          rawShipmentData.map((data) => Shipment.fromJson(data)).toList();

      List<ShipmentItem> allItems = [];
      for (var shipment in shipments) {
        allItems.addAll(shipment.items);
      }

      setState(() {
        _ordersList = allItems;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      print(
        "Error fetching/processing orders for date ${DateFormat('yyyy-MM-dd').format(date)}: $e",
      );
      setState(() {
        _errorMessage = "Gagal memuat pesanan: ${e.toString()}";
        _isLoading = false;
      });
    }
  }

  // This function will now just load mock data based on the selected date

  void _onDateSelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _updateDateController(selectedDay);
      });
      _fetchOrdersForDate(selectedDay);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Stack(
      children: <Widget>[
        // 1. Your Decorative Background Image (Bottom Layer of the root Stack)
        Container(
          color: Color(0xFFFFFFFF), // Your desired page background color
        ),

        Positioned(
          top: 0,
          left: 0,
          child: Opacity(
            opacity: 0.5, // Adjust opacity as desired
            child: Image.asset(
              'assets/images/home_img1.png', // YOUR DECORATIVE IMAGE PATH
              width: screenSize.width * 0.7,
              height: screenSize.height * 0.4,
              fit: BoxFit.contain,
              alignment: Alignment.topLeft,
              errorBuilder: (context, error, stackTrace) {
                return const SizedBox.shrink();
              },
            ),
          ),
        ),

        // 2. Scaffold is now a child of the Stack (Top Layer)
        Scaffold(
          backgroundColor:
              Colors.transparent, // Make Scaffold background transparent
          appBar: AppBar(
            backgroundColor:
                Colors.transparent, // Make AppBar background transparent
            elevation: 0, // Remove AppBar shadow
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new, color: Colors.black),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              'Histori Pesanan',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
          body: SafeArea(
            // SafeArea for the main scrollable content
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 10.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _dateController,
                    readOnly: true,
                    style: TextStyle(fontSize: 14, color: Colors.black),
                    decoration: InputDecoration(
                      hintText: 'Choose Date',
                      hintStyle: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      prefixIcon: Icon(
                        Icons.calendar_month,
                        color: Colors.grey,
                        size: 20,
                      ),
                      suffixIcon:
                          _selectedDay != null
                              ? IconButton(
                                icon: Icon(
                                  Icons.close,
                                  color: Colors.grey[500],
                                  size: 20,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _selectedDay = null;
                                    _focusedDay = DateTime.now();
                                    _updateDateController(null);
                                    _ordersList = [];
                                  });
                                },
                              )
                              : null,
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 14.0,
                        horizontal: 16.0,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide(color: Color(0xFFCBC6F0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide(
                          color: Color(0xFFCBC6F0),
                          width: 1.5,
                        ),
                      ),
                    ),
                    onTap: _handleDateInputTap,
                  ),
                  const SizedBox(height: 20),

                  Card(
                    elevation: 3.0,
                    shadowColor: Colors.black.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      side: BorderSide(
                        // Use 'side' and provide a BorderSide
                        color: Color(
                          0xFFCBC6F0,
                        ), // Example: Using the first color from your gradient
                        width: 2.0, // You can adjust the border width
                      ),
                    ),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        bottom: 8.0,
                        left: 8.0,
                        right: 8.0,
                      ),
                      child: TableCalendar<ShipmentItem>(
                        locale: 'id_ID',
                        firstDay: DateTime.utc(2010, 1, 1),
                        lastDay: DateTime.utc(2035, 12, 31),
                        focusedDay: _focusedDay,
                        calendarFormat: _calendarFormat,
                        selectedDayPredicate:
                            (day) => isSameDay(_selectedDay, day),
                        onDaySelected: _onDateSelected,
                        onFormatChanged: (format) {
                          if (_calendarFormat != format) {
                            setState(() {
                              _calendarFormat = format;
                            });
                          }
                        },
                        onPageChanged: (focusedDay) {
                          _focusedDay = focusedDay;
                        },
                        calendarStyle: CalendarStyle(
                          outsideDaysVisible: false,
                          todayDecoration: BoxDecoration(
                            color: Color(0xFFF2CBEF),
                            shape: BoxShape.circle,
                          ),
                          selectedDecoration: BoxDecoration(
                            color: Color(0xFFF2CBEF),
                            shape: BoxShape.circle,
                          ),
                          selectedTextStyle: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                          defaultTextStyle: TextStyle(color: Colors.black87),
                          weekendTextStyle: TextStyle(
                            color: Colors.pinkAccent[100],
                          ),
                        ),
                        headerStyle: HeaderStyle(
                          formatButtonVisible: false,
                          titleCentered: true,
                          titleTextStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                            color: Colors.black,
                          ),
                          leftChevronIcon: Icon(
                            Icons.keyboard_double_arrow_left_outlined,
                            color: Colors.black,
                            size: 28,
                          ),
                          rightChevronIcon: Icon(
                            Icons.keyboard_double_arrow_right_outlined,
                            color: Colors.black,
                            size: 28,
                          ),
                          headerPadding: const EdgeInsets.symmetric(
                            vertical: 10.0,
                          ),
                        ),
                        daysOfWeekStyle: DaysOfWeekStyle(
                          weekdayStyle: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.black54,
                            fontSize: 13,
                          ),
                          weekendStyle: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.pinkAccent[200],
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Text(
                    'Pesananmu',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildOrdersList(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrdersList() {
    if (_isLoading) {
      // Changed from _isLoadingOrders
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: CircularProgressIndicator(),
        ),
      );
    }
    if (_errorMessage.isNotEmpty) {
      // Changed from _orderErrorMessage
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(_errorMessage, style: TextStyle(color: Colors.red)),
        ),
      );
    }
    if (_selectedDay == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 30.0),
          child: Text(
            'Pilih tanggal terlebih dahulu',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
        ),
      );
    }
    if (_ordersList.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 30.0),
          child: Text(
            'Tidak ada pesanan pada tanggal ini.',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _ordersList.length,
      itemBuilder: (context, index) {
        final order = _ordersList[index];
        return _buildOrderListItem(order);
      },
    );
  }

  Widget _buildOrderListItem(ShipmentItem order) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      elevation: 1.5,
      shadowColor: Colors.deepPurple.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 12.0,
        ),
        title: Text(
          order.productName,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          'Dipesan : ${DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(order.shippingDate)}',
          style: TextStyle(fontSize: 12, color: Colors.grey[700]),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Color(0xFF7B61FF),
        ),
        onTap: () {
          // TODO: Navigate to order details page with order.id
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HistoriDetailPage(item: order),
            ),
          );
        },
      ),
    );
  }
}
