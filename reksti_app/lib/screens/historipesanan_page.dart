import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:reksti_app/model/Shipment.dart';
import 'package:reksti_app/services/logic_service.dart';
import 'package:reksti_app/Exception.dart';
import 'package:reksti_app/services/token_service.dart';
import 'package:reksti_app/screens/historidetail_page.dart';

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
  bool _isLoading = false;
  String _errorMessage = '';

  final TokenStorageService tokenStorage = TokenStorageService();

  @override
  void initState() {
    super.initState();
    if (_selectedDay == null) {
      _dateController.text = 'Choose Date';
    }
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
              primary: Colors.deepPurple[300]!,
              onPrimary: Colors.white,
              onSurface: Colors.black87,
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
      List<dynamic> rawShipmentData = await _logicService.getOrder();

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

      setState(() {
        _errorMessage = "Gagal memuat pesanan: ${e.toString()}";
        _isLoading = false;
      });
    }
  }

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
        Container(color: Color(0xFFFFFFFF)),

        Positioned(
          top: 0,
          left: 0,
          child: Opacity(
            opacity: 0.5,
            child: Image.asset(
              'assets/images/home_img1.png',
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

        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
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
                      side: BorderSide(color: Color(0xFFCBC6F0), width: 2.0),
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
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: CircularProgressIndicator(),
        ),
      );
    }
    if (_errorMessage.isNotEmpty) {
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
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black),
        onTap: () {
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
