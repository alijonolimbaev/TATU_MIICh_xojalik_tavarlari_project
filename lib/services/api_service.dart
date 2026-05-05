import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ApiService {
  static const String _baseUrl = 'https://dummyjson.com';

  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // Barcha mahsulotlarni yuklash
  Future<List<Product>> fetchProducts({int limit = 30}) async {
    final uri = Uri.parse('$_baseUrl/products?limit=$limit');

    final response = await http
        .get(uri, headers: {'Content-Type': 'application/json'})
        .timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final List products = data['products'] as List;
      return products
          .map((json) => Product.fromJson(json as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Xatolik: ${response.statusCode}');
    }
  }

  // ID bo'yicha bitta mahsulot yuklash
  Future<Product> fetchProductById(int id) async {
    final uri = Uri.parse('$_baseUrl/products/$id');
    final response = await http
        .get(uri)
        .timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      return Product.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      throw Exception('Mahsulot topilmadi');
    }
  }

  // Qidiruv
  Future<List<Product>> searchProducts(String query) async {
    final uri =
        Uri.parse('$_baseUrl/products/search?q=${Uri.encodeComponent(query)}');
    final response = await http
        .get(uri)
        .timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final List products = data['products'] as List;
      return products
          .map((json) => Product.fromJson(json as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Qidirishda xatolik');
    }
  }
}