import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import './product.dart';
import '../models/http_exception.dart';

class Products with ChangeNotifier {
  List<Product> _items = [];

  String? authToken;
  String? userId;

  void update(String? token, String? id) {
    authToken = token;
    userId = id;
  }

  List<Product> get items {
    return [..._items];
  }

  List<Product> get favouriteItems {
    return _items.where((element) => element.isFavourite).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((element) => element.id == id);
  }

  Future<void> addProduct(Product product) async {
    final url = Uri.parse(
        'https://shop-92b22-default-rtdb.europe-west1.firebasedatabase.app/products.json?auth=$authToken');
    try {
      final response = await http.post(
        url,
        body: json.encode(
          {
            'title': product.title,
            'description': product.description,
            'price': product.price,
            'imageUrl': product.imageUrl,
            'owner': userId,
          },
        ),
      );
      final newProduct = Product(
        id: json.decode(response.body)['name'],
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
      );
      _items.add(newProduct);
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    final filterString = filterByUser ? 'orderBy="owner"&equalTo="$userId"' : '';
    final url = Uri.parse(
        'https://shop-92b22-default-rtdb.europe-west1.firebasedatabase.app/products.json?auth=$authToken&$filterString');
    final url2 = Uri.parse(
        'https://shop-92b22-default-rtdb.europe-west1.firebasedatabase.app/userFavourites/$userId.json?auth=$authToken');
    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      final favouriteResponse = await http.get(url2);
      final favouriteData = json.decode(favouriteResponse.body);

      final List<Product> helper = [];
      extractedData.forEach((key, value) {
        helper.add(Product(
          id: key,
          title: value['title'],
          description: value['description'],
          price: value['price'],
          imageUrl: value['imageUrl'],
          isFavourite: favouriteData == null ? false : favouriteData[key] ?? false,
        ));
        _items = helper;
        notifyListeners();
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final index = _items.indexWhere((element) => element.id == id);
    if (index >= 0) {
      try {
        final url = Uri.parse(
            'https://shop-92b22-default-rtdb.europe-west1.firebasedatabase.app/products/$id.json?auth=$authToken');
        await http.patch(
          url,
          body: json.encode({
            'title': newProduct.title,
            'description': newProduct.description,
            'price': newProduct.price,
            'imageUrl': newProduct.imageUrl,
          }),
        );
      } catch (e) {
        rethrow;
      }
      _items[index] = newProduct;
      notifyListeners();
    }
  }

  Future<void> deleteProduct(String id) async {
    final url = Uri.parse(
        'https://shop-92b22-default-rtdb.europe-west1.firebasedatabase.app/products/$id.json?auth=$authToken');
    final exisitngProductIndex =
        _items.indexWhere((element) => element.id == id);
    Product? existingProduct = _items[exisitngProductIndex];
    _items.removeAt(exisitngProductIndex);
    notifyListeners();
    final response = await http.delete(url);

    if (response.statusCode >= 400) {
      _items.insert(exisitngProductIndex, existingProduct);
      notifyListeners();
      throw HttpException('Could not delete product.');
    }
    existingProduct = null;
  }
}
