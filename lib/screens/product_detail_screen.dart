import 'package:flutter/material.dart';
import '../models/product.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  final List<Product> cartItems;
  final Future<void> Function(Product) onAddToCart;
  final Future<void> Function(Product) onToggleFavorite;

  const ProductDetailScreen({
    super.key,
    required this.product,
    required this.cartItems,
    required this.onAddToCart,
    required this.onToggleFavorite,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;

  bool get _inCart => widget.cartItems.any((p) => p.id == widget.product.id);

  String _formatPrice(double price) {
    return price.toInt().toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]} ',
        );
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product.name),
        actions: [
          IconButton(
            icon: Icon(
              widget.product.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: widget.product.isFavorite ? Colors.red[200] : Colors.white,
            ),
            onPressed: () async {
              await widget.onToggleFavorite(widget.product);
              setState(() {});
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Rasm
            Image.network(
              widget.product.imageUrl,
              width: double.infinity,
              height: 280,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(height: 280, color: Colors.grey[200], child: const Icon(Icons.image, size: 80, color: Colors.grey)),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Kategoriya + reyting
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Chip(
                        label: Text(widget.product.category, style: TextStyle(color: primary)),
                        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                      ),
                      Row(children: [
                        const Icon(Icons.star, color: Colors.amber, size: 20),
                        Text(' ${widget.product.rating.toStringAsFixed(1)} / 5.0', style: const TextStyle(fontSize: 15)),
                      ]),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Nom
                  Text(widget.product.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  // Narx
                  Text("${_formatPrice(widget.product.price)} so'm", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: primary)),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 12),
                  // Tavsif
                  const Text('Mahsulot haqida', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(widget.product.description, style: const TextStyle(fontSize: 15, height: 1.6, color: Colors.black87)),
                  const SizedBox(height: 24),
                  // Miqdor
                  Row(
                    children: [
                      const Text('Miqdor:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                      const SizedBox(width: 16),
                      Container(
                        decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(10)),
                        child: Row(children: [
                          IconButton(icon: const Icon(Icons.remove), onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null),
                          Text('$_quantity', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          IconButton(icon: const Icon(Icons.add), onPressed: () => setState(() => _quantity++)),
                        ]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Savatga qo'shish
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: _inCart ? null : () async {
                        widget.product.quantity = _quantity;
                        await widget.onAddToCart(widget.product);
                        setState(() {});
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text("${widget.product.name} savatga qo'shildi!"),
                            backgroundColor: primary,
                            behavior: SnackBarBehavior.floating,
                          ));
                        }
                      },
                      icon: const Icon(Icons.shopping_cart),
                      label: Text(_inCart ? 'Savatda mavjud' : "Savatga qo'shish", style: const TextStyle(fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _inCart ? Colors.grey : primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
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