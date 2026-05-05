import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/notification_service.dart';
import '../widgets/product_card.dart';

class HomeScreen extends StatefulWidget {
  final List<Product> allProducts;
  final List<Product> cartItems;
  final bool isLoading;
  final String? errorMessage;
  final Future<void> Function(Product) onAddToCart;
  final Future<void> Function(Product) onToggleFavorite;
  final Future<void> Function() onRefresh;
  final Function(int) onTabChange;

  const HomeScreen({
    super.key,
    required this.allProducts,
    required this.cartItems,
    required this.isLoading,
    this.errorMessage,
    required this.onAddToCart,
    required this.onToggleFavorite,
    required this.onRefresh,
    required this.onTabChange,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedCategory = 'Barchasi';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // Mavjud kategoriyalar (API dan dinamik)
  List<String> get _categories {
    if (widget.allProducts.isEmpty) return ['Barchasi'];
    final cats = widget.allProducts.map((p) => p.category).toSet().toList()..sort();
    return ['Barchasi', ...cats];
  }

  List<Product> get _filtered => widget.allProducts.where((p) {
        final catMatch = _selectedCategory == 'Barchasi' || p.category == _selectedCategory;
        final searchMatch = p.name.toLowerCase().contains(_searchQuery.toLowerCase());
        return catMatch && searchMatch;
      }).toList();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF2E7D32)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  width: 60, height: 60,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                  child: const Icon(Icons.store, size: 36, color: Color(0xFF2E7D32)),
                ),
                const SizedBox(height: 10),
                const Text("Xo'jalik Tavarlari", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const Text('Sifatli mahsulotlar', style: TextStyle(color: Colors.white70, fontSize: 13)),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('KATEGORIYALAR', style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                ..._categories.map((cat) {
                  const iconMap = {
                    'Barchasi': Icons.grid_view,
                    'Hammom': Icons.shower,
                    'Oshxona': Icons.kitchen,
                    'Uy bezagi': Icons.weekend,
                    'Mebel': Icons.chair,
                    'Oziq-ovqat': Icons.fastfood,
                    'Sport': Icons.sports,
                    'Elektronika': Icons.devices,
                    'Kiyim': Icons.checkroom,
                    'Aksessuarlar': Icons.watch,
                    'Avto': Icons.directions_car,
                    'Tozalash': Icons.cleaning_services,
                  };
                  final count = cat == 'Barchasi'
                      ? widget.allProducts.length
                      : widget.allProducts.where((p) => p.category == cat).length;
                  final icon = iconMap[cat] ?? Icons.category;
                  final selected = _selectedCategory == cat;

                  return ListTile(
                    leading: Icon(icon, color: selected ? const Color(0xFF2E7D32) : Colors.grey[600]),
                    title: Text(cat),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: selected ? const Color(0xFF2E7D32) : Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text('$count', style: TextStyle(fontSize: 12, color: selected ? Colors.white : Colors.black54)),
                    ),
                    selected: selected,
                    selectedTileColor: const Color(0xFFE8F5E9),
                    onTap: () {
                      setState(() => _selectedCategory = cat);
                      Navigator.pop(context);
                    },
                  );
                }),
                const Divider(),
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 4, 16, 4),
                  child: Text('MENYU', style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                ),
                ListTile(
                  leading: const Icon(Icons.shopping_cart_outlined),
                  title: const Text('Savat'),
                  trailing: widget.cartItems.isNotEmpty
                      ? CircleAvatar(radius: 10, backgroundColor: const Color(0xFF2E7D32), child: Text('${widget.cartItems.length}', style: const TextStyle(color: Colors.white, fontSize: 11)))
                      : null,
                  onTap: () { Navigator.pop(context); widget.onTabChange(1); },
                ),
                ListTile(
                  leading: const Icon(Icons.favorite_outline),
                  title: const Text('Sevimlilar'),
                  onTap: () { Navigator.pop(context); widget.onTabChange(2); },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.notifications_outlined, color: Color(0xFF2E7D32)),
                  title: const Text('Test bildirishnoma'),
                  onTap: () async {
                    Navigator.pop(context);
                    await NotificationService().showWelcomeNotification();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Bildirishnoma yuborildi!'), backgroundColor: Color(0xFF2E7D32), behavior: SnackBarBehavior.floating),
                      );
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.refresh, color: Color(0xFF2E7D32)),
                  title: const Text('Yangilash'),
                  subtitle: const Text('API dan qayta yuklash'),
                  onTap: () { Navigator.pop(context); widget.onRefresh(); },
                ),
                const SizedBox(height: 16),
                Center(child: Text('Versiya 1.0.0', style: TextStyle(color: Colors.grey[400], fontSize: 12))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildDrawer(),
      appBar: AppBar(
        title: const Text("Xo'jalik Tavarlari"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Yangilash',
            onPressed: widget.onRefresh,
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () async {
              await NotificationService().showWelcomeNotification();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Bildirishnoma yuborildi!'), behavior: SnackBarBehavior.floating, backgroundColor: Color(0xFF2E7D32)),
                );
              }
            },
          ),
        ],
      ),
      body: widget.isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFF2E7D32)),
                  SizedBox(height: 16),
                  Text('Mahsulotlar yuklanmoqda...', style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : widget.errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.wifi_off, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text('Internet aloqasi yo\'q', style: TextStyle(fontSize: 16, color: Colors.grey)),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: widget.onRefresh,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Qayta urinish'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Qidiruv
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (v) => setState(() => _searchQuery = v),
                        decoration: InputDecoration(
                          hintText: 'Mahsulot qidirish...',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(icon: const Icon(Icons.clear), onPressed: () { _searchController.clear(); setState(() => _searchQuery = ''); })
                              : null,
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          contentPadding: const EdgeInsets.symmetric(vertical: 0),
                        ),
                      ),
                    ),
                    // Kategoriya chiplar
                    SizedBox(
                      height: 46,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemCount: _categories.length,
                        itemBuilder: (context, i) {
                          final cat = _categories[i];
                          final selected = _selectedCategory == cat;
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: ChoiceChip(
                              label: Text(cat),
                              selected: selected,
                              onSelected: (_) => setState(() => _selectedCategory = cat),
                              selectedColor: Theme.of(context).colorScheme.primary,
                              labelStyle: TextStyle(color: selected ? Colors.white : Colors.black87, fontWeight: selected ? FontWeight.bold : FontWeight.normal),
                            ),
                          );
                        },
                      ),
                    ),
                    // Natija soni
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 6, 16, 4),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text('${_filtered.length} ta mahsulot', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                      ),
                    ),
                    // Grid
                    Expanded(
                      child: _filtered.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                                  const SizedBox(height: 12),
                                  Text('Mahsulot topilmadi', style: TextStyle(color: Colors.grey[600])),
                                ],
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: widget.onRefresh,
                              color: const Color(0xFF2E7D32),
                              child: GridView.builder(
                                padding: const EdgeInsets.all(12),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 0.70,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                ),
                                itemCount: _filtered.length,
                                itemBuilder: (context, i) => ProductCard(
                                  product: _filtered[i],
                                  cartItems: widget.cartItems,
                                  onAddToCart: widget.onAddToCart,
                                  onToggleFavorite: widget.onToggleFavorite,
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
    );
  }
}