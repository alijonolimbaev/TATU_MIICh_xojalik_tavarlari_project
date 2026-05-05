import 'package:flutter/material.dart';
import '../models/product.dart';
import '../screens/product_detail_screen.dart';

class ProductCard extends StatefulWidget {
  final Product product;
  final List<Product> cartItems;
  final Future<void> Function(Product) onAddToCart;
  final Future<void> Function(Product) onToggleFavorite;

  const ProductCard({
    super.key,
    required this.product,
    required this.cartItems,
    required this.onAddToCart,
    required this.onToggleFavorite,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  String _formatPrice(double price) {
    return price.toInt().toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]} ',
        );
  }

  @override
  Widget build(BuildContext context) {
    final inCart = widget.cartItems.any((p) => p.id == widget.product.id);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailScreen(
              product: widget.product,
              cartItems: widget.cartItems,
              onAddToCart: widget.onAddToCart,
              onToggleFavorite: widget.onToggleFavorite,
            ),
          ),
        );
      },
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Rasm
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                widget.product.imageUrl,
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 120,
                  color: Colors.grey[200],
                  child: const Icon(Icons.image, size: 48, color: Colors.grey),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Kategoriya
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(widget.product.category, style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.primary)),
                  ),
                  const SizedBox(height: 4),
                  // Nom
                  Text(widget.product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  // Reyting
                  Row(children: [
                    const Icon(Icons.star, size: 13, color: Colors.amber),
                    Text(' ${widget.product.rating.toStringAsFixed(1)}', style: const TextStyle(fontSize: 11)),
                  ]),
                  const SizedBox(height: 6),
                  // Narx + tugmalar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          "${_formatPrice(widget.product.price)} so'm",
                          style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                      Row(children: [
                        // Sevimlilar
                        GestureDetector(
                          onTap: () async {
                            await widget.onToggleFavorite(widget.product);
                            setState(() {});
                          },
                          child: Icon(
                            widget.product.isFavorite ? Icons.favorite : Icons.favorite_border,
                            size: 18,
                            color: widget.product.isFavorite ? Colors.red : Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Savat
                        GestureDetector(
                          onTap: inCart ? null : () async {
                            await widget.onAddToCart(widget.product);
                            setState(() {});
                          },
                          child: Icon(
                            inCart ? Icons.shopping_cart : Icons.add_shopping_cart,
                            size: 18,
                            color: inCart ? Theme.of(context).colorScheme.primary : Colors.grey,
                          ),
                        ),
                      ]),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}