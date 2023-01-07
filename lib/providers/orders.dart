import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import './cart.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  const OrderItem({
    required this.id,
    required this.amount,
    required this.products,
    required this.dateTime,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];
  String? authToken;

  void updateToken(String token){
    authToken = token;
  }

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> fetchAndSetOrders() async {
    List<OrderItem> loadedOrders = [];
    final url = Uri.parse(
        'https://shop-92b22-default-rtdb.europe-west1.firebasedatabase.app/orders.json?auth=$authToken');
    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      extractedData.forEach((key, value) {
        loadedOrders.add(OrderItem(
          id: key,
          amount: value['amount'],
          dateTime: DateTime.parse(value['dateTime']),
          products: (value['products'] as List<dynamic>).map((e) {
            return CartItem(
              id: e['id'],
              title: e['title'],
              quantity: e['quantity'],
              price: e['price'],
            );
          }).toList(),
        ));
        _orders = loadedOrders.reversed.toList();
        notifyListeners();
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final orderDate = DateTime.now();
    final url = Uri.parse(
        'https://shop-92b22-default-rtdb.europe-west1.firebasedatabase.app/orders.json?auth=$authToken');
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'amount': total,
          'dateTime': orderDate.toIso8601String(),
          'products': cartProducts
              .map((e) => {
                    'id': e.id,
                    'title': e.title,
                    'quantity': e.quantity,
                    'price': e.price
                  })
              .toList(),
        }),
      );
      _orders.add(OrderItem(
        id: json.decode(response.body)['name'],
        amount: total,
        products: cartProducts,
        dateTime: orderDate,
      ));
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
}
