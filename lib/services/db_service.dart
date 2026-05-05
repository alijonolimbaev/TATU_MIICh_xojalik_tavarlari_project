import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/product.dart';

class DbService {
  static final DbService _instance = DbService._internal();
  factory DbService() => _instance;
  DbService._internal();

  Database? _db;

  Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'xojalik_tavarlari.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Sevimlilar jadvali
        await db.execute('''
          CREATE TABLE favorites (
            product_id INTEGER PRIMARY KEY,
            name TEXT NOT NULL,
            description TEXT,
            price REAL NOT NULL,
            category TEXT,
            image_url TEXT,
            rating REAL,
            quantity INTEGER DEFAULT 1
          )
        ''');

        // Savat jadvali
        await db.execute('''
          CREATE TABLE cart (
            product_id INTEGER PRIMARY KEY,
            name TEXT NOT NULL,
            description TEXT,
            price REAL NOT NULL,
            category TEXT,
            image_url TEXT,
            rating REAL,
            quantity INTEGER DEFAULT 1
          )
        ''');
      },
    );
  }

  // ══════════════════════════════════════
  // SEVIMLILAR — CRUD
  // ══════════════════════════════════════

  Future<void> addFavorite(Product product) async {
    final db = await database;
    await db.insert(
      'favorites',
      product.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> removeFavorite(int productId) async {
    final db = await database;
    await db.delete(
      'favorites',
      where: 'product_id = ?',
      whereArgs: [productId],
    );
  }

  Future<List<Product>> getFavorites() async {
    final db = await database;
    final maps = await db.query('favorites');
    return maps
        .map((m) => Product.fromMap(m, isFavorite: true))
        .toList();
  }

  Future<Set<int>> getFavoriteIds() async {
    final db = await database;
    final maps = await db.query('favorites', columns: ['product_id']);
    return maps.map((m) => m['product_id'] as int).toSet();
  }

  // ══════════════════════════════════════
  // SAVAT — CRUD
  // ══════════════════════════════════════

  Future<void> addToCart(Product product) async {
    final db = await database;
    await db.insert(
      'cart',
      product.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateCartQuantity(int productId, int quantity) async {
    final db = await database;
    await db.update(
      'cart',
      {'quantity': quantity},
      where: 'product_id = ?',
      whereArgs: [productId],
    );
  }

  Future<void> removeFromCart(int productId) async {
    final db = await database;
    await db.delete(
      'cart',
      where: 'product_id = ?',
      whereArgs: [productId],
    );
  }

  Future<void> clearCart() async {
    final db = await database;
    await db.delete('cart');
  }

  Future<List<Product>> getCartItems() async {
    final db = await database;
    final maps = await db.query('cart');
    return maps.map((m) => Product.fromMap(m)).toList();
  }

  // DB yopish (ihtiyojga qarab)
  Future<void> close() async {
    final db = await database;
    await db.close();
    _db = null;
  }
}