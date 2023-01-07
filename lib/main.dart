import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/screens/products_overview_screen.dart';

import './screens/cart_screen.dart';
// import './screens/products_overview_screen.dart';
import './screens/product_detail_screen.dart';
import './screens/orders_screen.dart';
import './screens/user_products_screen.dart';
import './screens/edit_product_screen.dart';
import './screens/auth_screen.dart';
import './providers/products.dart';
import './providers/cart.dart';
import './providers/orders.dart';
import './providers/auth.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => Auth()),
          ChangeNotifierProxyProvider<Auth, Products>(
            create: (context) => Products(),
            update: (_, value, previous) => previous!..update(value.token as String),
          ),
          ChangeNotifierProvider(create: (_) => Cart()),
          ChangeNotifierProxyProvider<Auth, Orders>(
            create: (_) => Orders(),
            update: (_, value, previous) => previous!..updateToken(value.token as String),
          )
        ],
        child: Consumer<Auth>(
          builder: (context, value, _) {
            return MaterialApp(
              title: 'MyShop',
              theme: ThemeData(
                colorScheme: ColorScheme.fromSwatch(
                  primarySwatch: Colors.purple,
                ).copyWith(
                  secondary: Colors.grey,
                ),
                fontFamily: 'Lato',
              ),
              debugShowCheckedModeBanner: false,
              home: value.isAuth
                  ? const ProductsOverviewScreen()
                  : const AuthScreen(),
              routes: {
                ProductDetailScreen.routeName: (context) =>
                    const ProductDetailScreen(),
                CartScreen.routeName: (context) => const CartScreen(),
                OrdersScreen.routeName: (context) => const OrdersScreen(),
                UserProductsScreen.routeName: (context) =>
                    const UserProductsScreen(),
                EditProductScreen.routeName: (context) =>
                    const EditProductScreen(),
              },
            );
          },
        ));
  }
}
