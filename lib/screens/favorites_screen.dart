import 'package:flutter/material.dart';
import '../models/product.dart';
import '../widgets/product_card.dart';

class FavoritesScreen extends StatefulWidget {
  final List<Product> allProducts;
  final List<Product> cartItems;
  final Future<void> Function(Product) onAddToCart;
  final Future<void> Function(Product) onToggleFavorite;

  const FavoritesScreen({
    super.key,
    required this.allProducts,
    required this.cartItems,
    required this.onAddToCart,
    required this.onToggleFavorite,
  });

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<Product> get _favorites =>
      widget.allProducts.where((p) => p.isFavorite).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sevimlilar'),
        automaticallyImplyLeading: false,
      ),
      body: _favorites.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text('Sevimlilar bo\'sh', style: TextStyle(fontSize: 18, color: Colors.grey[600])),
                  const SizedBox(height: 8),
                  Text(
                    'Mahsulot ustidagi ❤️ belgisini\nbosib sevimlilarga qo\'shing',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.70,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: _favorites.length,
              itemBuilder: (_, i) => ProductCard(
                product: _favorites[i],
                cartItems: widget.cartItems,
                onAddToCart: widget.onAddToCart,
                onToggleFavorite: (product) async {
                  await widget.onToggleFavorite(product);
                  setState(() {});
                },
              ),
            ),
    );
  }
}