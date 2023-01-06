import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavourite;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.isFavourite = false,
  });

  Future<void> toogleFavourite() async {
    isFavourite = !isFavourite;
    notifyListeners();
    final url = Uri.parse(
        'https://shop-92b22-default-rtdb.europe-west1.firebasedatabase.app/products/$id.json');
    final response = await http.patch(
      url,
      body: json.encode({'isFavourite': isFavourite}),
    );
    if (response.statusCode >= 400){
      isFavourite = !isFavourite;
      notifyListeners();
    }
  }
}
