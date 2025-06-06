import 'package:flutter/material.dart';

class ShipmentItem {
  final int productId;
  final String productName;
  final int quantity;
  final bool constraintsViolated;
  final String imagePath;
  final DateTime shippingDate;
  final String recipientAddress;
  final String? deliveryDate;
  final String recipientName;
  final String recipientPhone;
  final String status;

  ShipmentItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.shippingDate,
    required this.constraintsViolated,
    required this.recipientAddress,
    required this.deliveryDate,
    required this.recipientName,
    required this.recipientPhone,
    required this.status,
    this.imagePath = 'assets/images/drug.png',
  });

  factory ShipmentItem.fromJson(
    Map<String, dynamic> json,
    DateTime shipmentDate,
    String recipientAddress,
    String? deliveryDate,
    String recipientName,
    String recipientPhone,
    String status,
  ) {
    return ShipmentItem(
      productId: json['product_id'] as int,
      productName: json['product_name'] as String,
      quantity: json['quantity'] as int,
      constraintsViolated: json['constraints_violated'] as bool,
      shippingDate: shipmentDate,
      recipientAddress: recipientAddress,
      deliveryDate: deliveryDate,
      recipientName: recipientName,
      recipientPhone: recipientPhone,
      status: status,
    );
  }
}

class Shipment {
  final String shipmentCode;
  final String shippingDateString;
  final DateTime shippingDate;
  final String? deliveryDate;
  final String recipientName;
  final String recipientAddress;
  final String recipientPhone;
  final String status;
  final bool constraintsViolated;
  final List<ShipmentItem> items;
  final String additionalInfo;

  Shipment({
    required this.shipmentCode,
    required this.shippingDate,
    required this.shippingDateString,
    this.deliveryDate,
    required this.recipientName,
    required this.recipientAddress,
    required this.recipientPhone,
    required this.status,
    required this.constraintsViolated,
    required this.items,
    required this.additionalInfo,
  });

  factory Shipment.fromJson(Map<String, dynamic> json) {
    String dateString = json['shipping_date'] as String;
    DateTime parsedShippingDate;

    try {
      parsedShippingDate = DateTime.parse(dateString);
    } catch (e) {
      parsedShippingDate = DateTime.now();
    }

    var itemsList = json['items'] as List;
    List<ShipmentItem> parsedItems =
        itemsList
            .map(
              (i) => ShipmentItem.fromJson(
                i,
                parsedShippingDate,
                json['recipient_address'] as String,
                json['delivery_date'] as String?,
                json['recipient_name'] as String,
                json['recipient_phone'] as String,
                json['status'],
              ),
            )
            .toList();

    return Shipment(
      shipmentCode: json['shipment_code'] as String,
      shippingDateString: dateString,
      shippingDate: parsedShippingDate,
      deliveryDate: json['delivery_date'] as String?,
      recipientName: json['recipient_name'] as String,
      recipientAddress: json['recipient_address'] as String,
      recipientPhone: json['recipient_phone'] as String,
      status: json['status'] as String,
      constraintsViolated: json['constraints_violated'] as bool,
      items: parsedItems,
      additionalInfo: json['additional_info'] as String,
    );
  }
}
