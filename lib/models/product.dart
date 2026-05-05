class Product {
  final int id;
  final String name;
  final String description;
  final double price;
  final String category;
  final String imageUrl;
  final double rating;
  bool isFavorite;
  int quantity;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.imageUrl,
    required this.rating,
    this.isFavorite = false,
    this.quantity = 1,
  });

  // ── REST API dan kelgan JSON → Product ──
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      name: json['title'] as String,
      description: json['description'] as String? ?? '',
      price: ((json['price'] as num).toDouble() * 12000).roundToDouble(),
      category: _mapCategory(json['category'] as String? ?? ''),
      imageUrl: json['thumbnail'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
    );
  }

  // ── SQLite dan kelgan Map → Product ──
  factory Product.fromMap(Map<String, dynamic> map, {bool isFavorite = false}) {
    return Product(
      id: map['product_id'] as int,
      name: map['name'] as String,
      description: map['description'] as String? ?? '',
      price: (map['price'] as num).toDouble(),
      category: map['category'] as String? ?? 'Boshqa',
      imageUrl: map['image_url'] as String? ?? '',
      rating: (map['rating'] as num).toDouble(),
      quantity: (map['quantity'] as int?) ?? 1,
      isFavorite: isFavorite,
    );
  }

  // ── Product → SQLite Map ──
  Map<String, dynamic> toMap() {
    return {
      'product_id': id,
      'name': name,
      'description': description,
      'price': price,
      'category': category,
      'image_url': imageUrl,
      'rating': rating,
      'quantity': quantity,
    };
  }

  // DummyJSON kategoriyalarini o'zbekchaga moslashtirish
  static String _mapCategory(String apiCategory) {
    const Map<String, String> map = {
      'beauty': 'Hammom',
      'fragrances': 'Hammom',
      'skin-care': 'Hammom',
      'kitchen-accessories': 'Oshxona',
      'home-decoration': 'Uy bezagi',
      'furniture': 'Mebel',
      'groceries': 'Oziq-ovqat',
      'sports-accessories': 'Sport',
      'mobile-accessories': 'Elektronika',
      'laptops': 'Elektronika',
      'smartphones': 'Elektronika',
      'tablets': 'Elektronika',
      'mens-shirts': 'Kiyim',
      'mens-shoes': 'Kiyim',
      'womens-bags': 'Kiyim',
      'womens-dresses': 'Kiyim',
      'womens-shoes': 'Kiyim',
      'tops': 'Kiyim',
      'mens-watches': 'Aksessuarlar',
      'womens-watches': 'Aksessuarlar',
      'womens-jewellery': 'Aksessuarlar',
      'sunglasses': 'Aksessuarlar',
      'vehicle': 'Avto',
      'motorcycles': 'Avto',
    };
    return map[apiCategory] ?? 'Boshqa';
  }

  // ── Internet bo'lmasa fallback data ──
  static List<Product> getMockProducts() {
    return [
      Product(
        id: 1,
        name: 'Supurgi',
        description: 'Yuqori sifatli uy supurgisi.',
        price: 45000,
        category: 'Tozalash',
        imageUrl: 'https://sever.be/news/images/E2ybyAhB3y.jpg',
        rating: 4.5,
      ),
      Product(
        id: 2,
        name: 'Idish yuvish vositasi',
        description: 'Kuchli tozalovchi vosita.',
        price: 25000,
        category: 'Tozalash',
        imageUrl: 'https://aniq.uz/photos/news/Xy4ymmF16E6IdT2.jpeg',
        rating: 4.7,
      ),
      Product(
        id: 3,
        name: 'Qozon (5 litr)',
        description: 'Zanglamaydigan po\'latdan yasalgan.',
        price: 185000,
        category: 'Oshxona',
        imageUrl: 'https://cdn.asaxiy.uz/asaxiy-content/product/items/mobile/96a3be3cf272e017046d1b2674a52bd32024040614491431231NdYusxUTGt.jpg.webp',
        rating: 4.8,
      ),
      Product(
        id: 4,
        name: 'Chelak (10 litr)',
        description: 'Mustahkam plastik chelak.',
        price: 35000,
        category: 'Tozalash',
        imageUrl: 'https://images.uzum.uz/cu92t8dht56ksubf3ji0/t_product_low.jpg',
        rating: 4.2,
      ),
      Product(
        id: 5,
        name: 'Pichoq to\'plami',
        description: '6 ta pichoqdan iborat.',
        price: 120000,
        category: 'Oshxona',
        imageUrl: 'https://cdn.mediapark.uz/imgs/d08f40cb-5fb2-45f0-a378-afa302cafda3.webp',
        rating: 4.6,
      ),
      Product(
        id: 6,
        name: 'Yumshoq sochiq',
        description: '100% paxta sochiq.',
        price: 55000,
        category: 'Hammom',
        imageUrl: 'https://dam.thdstatic.com/content/production/6FTgjWbN68d1GGXIRJwDOQ.jpg',
        rating: 4.4,
      ),
      Product(
        id: 7,
        name: 'Pol yuvish vositasi',
        description: 'Lemon hidli pol tozalovchi.',
        price: 30000,
        category: 'Tozalash',
        imageUrl: 'https://m.media-amazon.com/images/I/61goZs2PDeL._AC_UF1000,1000_QL80_.jpg',
        rating: 4.3,
      ),
      Product(
        id: 8,
        name: 'Krujka to\'plami',
        description: 'Keramik krujkalar.',
        price: 75000,
        category: 'Oshxona',
        imageUrl: 'https://images.thdstatic.com/productImages/fd685f92-a8ae-4089-b23b-ac2fdec13c59.jpg',
        rating: 4.5,
      ),
      Product(
        id: 9,
        name: 'Rezina qo\'lqop',
        description: 'Himoya qo\'lqoplari.',
        price: 15000,
        category: 'Tozalash',
        imageUrl: 'https://www.gloves.co.uk/user/products/polyco-finite.jpg',
        rating: 4.1,
      ),
      Product(
        id: 10,
        name: 'Shampun',
        description: 'Tabiiy ingredientlar.',
        price: 40000,
        category: 'Hammom',
        imageUrl: 'https://media.allure.com/photos/68cadfb268429fb7c466d9cd.jpg',
        rating: 4.6,
      ),
      Product(
        id: 11,
        name: 'Stol dasturxoni',
        description: 'Yuviladigan dasturxon.',
        price: 65000,
        category: 'Oshxona',
        imageUrl: 'https://i5.walmartimages.com/seo/Mandala.jpg',
        rating: 4.3,
      ),
      Product(
        id: 12,
        name: 'Hammom ko\'zgusi',
        description: 'Devoriy ko\'zgu.',
        price: 95000,
        category: 'Hammom',
        imageUrl: 'https://t4.ftcdn.net/jpg/05/31/54/45.jpg',
        rating: 4.7,
      ),
    ];
  }

  static List<String> getCategories() {
    return ['Barchasi', 'Tozalash', 'Oshxona', 'Hammom'];
  }
}