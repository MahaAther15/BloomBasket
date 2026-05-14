import 'package:flutter/material.dart';

import 'cart_item.dart';

enum OrderStatus {
  pending,
  confirmed,
  prepared,
  shipped,
  outForDelivery,
  delivered,
  cancelled,
}

// Extension for OrderStatus to get display text and other utilities
extension OrderStatusExtension on OrderStatus {
  String get displayText {
    switch (this) {
      case OrderStatus.pending:
        return 'PENDING';
      case OrderStatus.confirmed:
        return 'CONFIRMED';
      case OrderStatus.prepared:
        return 'PREPARED';
      case OrderStatus.shipped:
        return 'SHIPPED';
      case OrderStatus.outForDelivery:
        return 'OUT FOR DELIVERY';
      case OrderStatus.delivered:
        return 'DELIVERED';
      case OrderStatus.cancelled:
        return 'CANCELLED';
    }
  }

  String get description {
    switch (this) {
      case OrderStatus.pending:
        return 'Your order is pending confirmation';
      case OrderStatus.confirmed:
        return 'Your order has been confirmed';
      case OrderStatus.prepared:
        return 'Your arrangement is being prepared with care';
      case OrderStatus.shipped:
        return 'Your order has been shipped';
      case OrderStatus.outForDelivery:
        return 'Your order is out for delivery';
      case OrderStatus.delivered:
        return 'Your order has been delivered';
      case OrderStatus.cancelled:
        return 'Your order has been cancelled';
    }
  }

  IconData get icon {
    switch (this) {
      case OrderStatus.pending:
        return Icons.pending_outlined;
      case OrderStatus.confirmed:
        return Icons.check_circle_outline;
      case OrderStatus.prepared:
        return Icons.spa;
      case OrderStatus.shipped:
        return Icons.local_shipping;
      case OrderStatus.outForDelivery:
        return Icons.delivery_dining;
      case OrderStatus.delivered:
        return Icons.home;
      case OrderStatus.cancelled:
        return Icons.cancel_outlined;
    }
  }

  Color get color {
    switch (this) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.confirmed:
        return Colors.purple;
      case OrderStatus.prepared:
        return Colors.amber;
      case OrderStatus.shipped:
        return Colors.blue;
      case OrderStatus.outForDelivery:
        return Colors.indigo;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }
}

class BBOrder {
  final String id;
  final List<CartItem> items;
  final double totalAmount;
  final DateTime orderDate;
  final OrderStatus status;
  final String deliveryAddress;
  final String? trackingNumber;
  final DateTime? estimatedDeliveryDate;
  final String? specialInstructions;

  BBOrder({
    required this.id,
    required this.items,
    required this.totalAmount,
    required this.orderDate,
    required this.status,
    required this.deliveryAddress,
    this.trackingNumber,
    this.estimatedDeliveryDate,
    this.specialInstructions,
  });

  // Calculate order summary
  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  String get formattedOrderDate {
    return '${orderDate.day}/${orderDate.month}/${orderDate.year}';
  }

  String get formattedTotalAmount {
    return '\$${totalAmount.toStringAsFixed(2)}';
  }

  // Check if order is cancellable (only within 30 minutes)
  bool get isCancellable {
    if (status != OrderStatus.confirmed) return false;
    final difference = DateTime.now().difference(orderDate);
    return difference.inMinutes <= 30;
  }

  // Get estimated delivery time as string
  String get estimatedDeliveryText {
    if (estimatedDeliveryDate != null) {
      final date = estimatedDeliveryDate!;
      return '${date.day}/${date.month}/${date.year}';
    }

    // Default estimated delivery (3-5 days from order date)
    final estimated = orderDate.add(const Duration(days: 3));
    return '${estimated.day}/${estimated.month}/${estimated.year}';
  }

  // Convert to JSON for local storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'items': items
          .map((item) => {
                'productId': item.product.id,
                'productName': item.product.name,
                'productPrice': item.product.price,
                'quantity': item.quantity,
                'productImageUrl': item.product.imageUrl,
              })
          .toList(),
      'totalAmount': totalAmount,
      'orderDate': orderDate.toIso8601String(),
      'status': status.toString(),
      'deliveryAddress': deliveryAddress,
      'trackingNumber': trackingNumber,
      'estimatedDeliveryDate': estimatedDeliveryDate?.toIso8601String(),
      'specialInstructions': specialInstructions,
    };
  }

  // Create from JSON (for loading from local storage)
  factory BBOrder.fromJson(Map<String, dynamic> json, List<CartItem> items) {
    return BBOrder(
      id: json['id'],
      items: items,
      totalAmount: json['totalAmount'].toDouble(),
      orderDate: DateTime.parse(json['orderDate']),
      status: _parseOrderStatus(json['status']),
      deliveryAddress: json['deliveryAddress'],
      trackingNumber: json['trackingNumber'],
      estimatedDeliveryDate: json['estimatedDeliveryDate'] != null
          ? DateTime.parse(json['estimatedDeliveryDate'])
          : null,
      specialInstructions: json['specialInstructions'],
    );
  }

  // Helper method to parse order status from string
  static OrderStatus _parseOrderStatus(String status) {
    switch (status) {
      case 'OrderStatus.pending':
        return OrderStatus.pending;
      case 'OrderStatus.confirmed':
        return OrderStatus.confirmed;
      case 'OrderStatus.prepared':
        return OrderStatus.prepared;
      case 'OrderStatus.shipped':
        return OrderStatus.shipped;
      case 'OrderStatus.outForDelivery':
        return OrderStatus.outForDelivery;
      case 'OrderStatus.delivered':
        return OrderStatus.delivered;
      case 'OrderStatus.cancelled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.confirmed;
    }
  }

  // Create a copy with updated status
  BBOrder copyWith({
    String? id,
    List<CartItem>? items,
    double? totalAmount,
    DateTime? orderDate,
    OrderStatus? status,
    String? deliveryAddress,
    String? trackingNumber,
    DateTime? estimatedDeliveryDate,
    String? specialInstructions,
  }) {
    return BBOrder(
      id: id ?? this.id,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      orderDate: orderDate ?? this.orderDate,
      status: status ?? this.status,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      estimatedDeliveryDate:
          estimatedDeliveryDate ?? this.estimatedDeliveryDate,
      specialInstructions: specialInstructions ?? this.specialInstructions,
    );
  }

  @override
  String toString() {
    return 'BBOrder(id: $id, status: ${status.displayText}, total: $formattedTotalAmount)';
  }
}
