import 'package:flutter/material.dart';
import 'models/product.dart';
import 'services/api_service.dart';
import 'services/db_service.dart';
import 'services/notification_service.dart';
import 'screens/home_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/favorites_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  List<Product> _allProducts = [];
  List<Product> _cartItems = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  // ── Ilovani ishga tushirishda DB va API dan yuklash ──
  Future<void> _initialize() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 1. SQLite dan savatni yuklash
      final cartFromDb = await DbService().getCartItems();

      // 2. SQLite dan sevimlilar ID larini yuklash
      final favoriteIds = await DbService().getFavoriteIds();

      // 3. API dan mahsulotlarni yuklash
      List<Product> products;
      try {
        products = await ApiService().fetchProducts(limit: 30);
      } catch (_) {
        // Internet bo'lmasa — zaxira ma'lumotlar
        products = Product.getMockProducts();
      }

      // 4. Sevimlilarga belgilash
      for (final p in products) {
        if (favoriteIds.contains(p.id)) {
          p.isFavorite = true;
        }
      }

      setState(() {
        _allProducts = products;
        _cartItems = cartFromDb;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  // ── Sevimlilar ──
  Future<void> _toggleFavorite(Product product) async {
    product.isFavorite = !product.isFavorite;
    if (product.isFavorite) {
      await DbService().addFavorite(product);
      await NotificationService().showFavoriteNotification(product.name);
    } else {
      await DbService().removeFavorite(product.id);
    }
    setState(() {});
  }

  // ── Savat: qo'shish ──
  Future<void> _addToCart(Product product) async {
    final exists = _cartItems.any((p) => p.id == product.id);
    if (!exists) {
      _cartItems.add(product);
      await DbService().addToCart(product);
      await NotificationService().showCartNotification(product.name);
    }
    setState(() {});
  }

  // ── Savat: o'chirish ──
  Future<void> _removeFromCart(Product product) async {
    _cartItems.removeWhere((p) => p.id == product.id);
    await DbService().removeFromCart(product.id);
    setState(() {});
  }

  // ── Savat: miqdor yangilash ──
  Future<void> _updateQuantity(Product product, int quantity) async {
    final index = _cartItems.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      _cartItems[index].quantity = quantity;
      await DbService().updateCartQuantity(product.id, quantity);
      setState(() {});
    }
  }

  // ── Buyurtma berish ──
  Future<void> _onOrderPlaced() async {
    final count = _cartItems.length;
    final total = _formatPrice(
      _cartItems.fold(0.0, (sum, p) => sum + p.price * p.quantity),
    );
    await NotificationService().showOrderNotification(count, total);
    _cartItems.clear();
    await DbService().clearCart();
    setState(() {});
  }

  String _formatPrice(double price) {
    return price.toInt().toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]} ',
        );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      HomeScreen(
        allProducts: _allProducts,
        cartItems: _cartItems,
        isLoading: _isLoading,
        errorMessage: _errorMessage,
        onAddToCart: _addToCart,
        onToggleFavorite: _toggleFavorite,
        onRefresh: _initialize,
        onTabChange: (i) => setState(() => _currentIndex = i),
      ),
      CartScreen(
        cartItems: _cartItems,
        onRemove: _removeFromCart,
        onUpdateQuantity: _updateQuantity,
        onOrderPlaced: _onOrderPlaced,
        onClearCart: () async {
          _cartItems.clear();
          await DbService().clearCart();
          setState(() {});
        },
      ),
      FavoritesScreen(
        allProducts: _allProducts,
        cartItems: _cartItems,
        onAddToCart: _addToCart,
        onToggleFavorite: _toggleFavorite,
      ),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        backgroundColor: Colors.white,
        elevation: 8,
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Bosh sahifa',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: _cartItems.isNotEmpty,
              label: Text('${_cartItems.length}'),
              child: const Icon(Icons.shopping_cart_outlined),
            ),
            selectedIcon: Badge(
              isLabelVisible: _cartItems.isNotEmpty,
              label: Text('${_cartItems.length}'),
              child: const Icon(Icons.shopping_cart),
            ),
            label: 'Savat',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: _allProducts.any((p) => p.isFavorite),
              child: const Icon(Icons.favorite_outline),
            ),
            selectedIcon: Badge(
              isLabelVisible: _allProducts.any((p) => p.isFavorite),
              child: const Icon(Icons.favorite),
            ),
            label: 'Sevimlilar',
          ),
        ],
      ),
    );
  }
}