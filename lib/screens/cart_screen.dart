import 'package:flutter/material.dart';
import '../models/product.dart';

class CartScreen extends StatefulWidget {
  final List<Product> cartItems;
  final Future<void> Function(Product) onRemove;
  final Future<void> Function(Product, int) onUpdateQuantity;
  final Future<void> Function() onOrderPlaced;
  final Future<void> Function() onClearCart;

  const CartScreen({
    super.key,
    required this.cartItems,
    required this.onRemove,
    required this.onUpdateQuantity,
    required this.onOrderPlaced,
    required this.onClearCart,
  });

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  String _formatPrice(double price) {
    return price.toInt().toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]} ',
        );
  }

  double get _total =>
      widget.cartItems.fold(0, (sum, p) => sum + p.price * p.quantity);

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Savat'),
        automaticallyImplyLeading: false,
        actions: [
          if (widget.cartItems.isNotEmpty)
            TextButton(
              onPressed: () async {
                await widget.onClearCart();
                setState(() {});
              },
              child: const Text('Tozalash', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: widget.cartItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text('Savat bo\'sh', style: TextStyle(fontSize: 18, color: Colors.grey[600])),
                  const SizedBox(height: 8),
                  Text('Mahsulotlarni qo\'shing', style: TextStyle(color: Colors.grey[400])),
                ],
              ),
            )
          : Column(
              children: [
                // Mahsulotlar ro'yxati
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: widget.cartItems.length,
                    itemBuilder: (context, i) {
                      final p = widget.cartItems[i];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            children: [
                              // Rasm
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  p.imageUrl,
                                  width: 65, height: 65, fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(width: 65, height: 65, color: Colors.grey[200], child: const Icon(Icons.image)),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Ma'lumot
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
                                    const SizedBox(height: 4),
                                    Text("${_formatPrice(p.price)} so'm", style: TextStyle(color: primary, fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 8),
                                    // Miqdor
                                    Row(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(8)),
                                          child: Row(children: [
                                            InkWell(
                                              onTap: p.quantity > 1
                                                  ? () async {
                                                      await widget.onUpdateQuantity(p, p.quantity - 1);
                                                      setState(() {});
                                                    }
                                                  : null,
                                              child: const Padding(padding: EdgeInsets.all(4), child: Icon(Icons.remove, size: 16)),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 10),
                                              child: Text('${p.quantity}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                            ),
                                            InkWell(
                                              onTap: () async {
                                                await widget.onUpdateQuantity(p, p.quantity + 1);
                                                setState(() {});
                                              },
                                              child: const Padding(padding: EdgeInsets.all(4), child: Icon(Icons.add, size: 16)),
                                            ),
                                          ]),
                                        ),
                                        const Spacer(),
                                        Text("${_formatPrice(p.price * p.quantity)} so'm", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              // O'chirish
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.red),
                                onPressed: () async {
                                  await widget.onRemove(p);
                                  setState(() {});
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Jami va buyurtma
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.15), blurRadius: 10, offset: const Offset(0, -4))],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${widget.cartItems.length} ta mahsulot:', style: const TextStyle(fontSize: 15, color: Colors.grey)),
                          Text("${_formatPrice(_total)} so'm", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primary)),
                        ],
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () async {
                            await widget.onOrderPlaced();
                            if (mounted) {
                              showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text('✅ Buyurtma qabul qilindi!'),
                                  content: const Text('Tez orada siz bilan bog\'lanamiz.'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('OK'),
                                    ),
                                  ],
                                ),
                              );
                            }
                          },
                          child: const Text('Buyurtma berish', style: TextStyle(fontSize: 16)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}