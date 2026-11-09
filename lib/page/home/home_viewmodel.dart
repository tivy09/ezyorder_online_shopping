import 'package:flutter/foundation.dart';

class Store {
  const Store(this.name, this.location, this.category, this.initials,
      this.image, this.followers, this.products, this.rating);
  final String name, location, category, initials, image, followers;
  final int products;
  final double rating;
}

class ShopProduct {
  const ShopProduct(this.id, this.name, this.store, this.category, this.image,
      this.price, this.oldPrice, this.rating, this.reviews, this.stock,
      this.badge, this.shipping, {this.fast = false});
  final int id, store, reviews, stock;
  final String name, category, image, badge, shipping;
  final double price, oldPrice, rating;
  final bool fast;
}

// Demo catalog. Replace with API data when integrating your marketplace.
class HomeViewModel extends ChangeNotifier {
  static const stores = <Store>[
    Store('Nordic Clay Studio', 'Stockholm', 'Ceramics & Tableware', 'NC',
      'photo-1495474472287-4d71bcdd2085', '1,420', 84, 4.98),
    Store('Aura Audio Labs', 'Kyoto', 'Hi-Fi Electronics', 'AA',
      'photo-1498049794561-7780e7231661', '5,880', 32, 4.99),
    Store('Tanner & Forge', 'Portland', 'Goods & Carry', 'TF',
      'photo-1504148455328-c376907d081c', '3,110', 59, 4.92),
    Store('Solace Botanica', 'Lyon', 'Organic Apothecary', 'SB',
      'photo-1416879595882-3373a0480b5b', '4,750', 46, 4.98),
    Store('Kuro Studio Steel', 'Osaka', 'Artisan Tools', 'KS',
      'photo-1556911220-bff31c812dba', '980', 19, 4.96),
  ];
  static const products = <ShopProduct>[
    ShopProduct(1, 'Studio Monitor Walnut Open-Back Headphones', 1,
      'Electronics & Audio', 'photo-1546435770-a3e426bf472b', 289, 320, 4.9,
      128, 4, '24h Dispatch', 'Free verified split ship', fast: true),
    ShopProduct(2, 'Kura Matte Sand Speckled Stoneware Teapot', 0,
      'Artisan Home', 'photo-1578749556568-bc2c40e68b61', 78, 0, 5.0,
      64, 11, 'Boutique Handcraft', 'Ships from Stockholm'),
    ShopProduct(3, 'Field Minimalist Leather Bifold Folio', 2,
      'Fashion & Apparel', 'photo-1627123424574-724758594e93', 64, 85,
      4.8, 92, 2, '24h Dispatch', 'Portland Studio Direct', fast: true),
    ShopProduct(4, 'Nocturne Ceramic Ultrasonic Mist Diffuser', 3,
      'Health & Wellness', 'photo-1608571423902-eed4a5ad8108', 115, 0,
      4.9, 210, 18, '24h Dispatch', 'Lyon Apothecary Direct', fast: true),
    ShopProduct(5, 'Gyuto 210mm Damascus Forged Carbon Knife', 4,
      'Artisan Home', 'photo-1593618998160-e34014e67546', 340, 0,
      5.0, 41, 1, 'Masterpiece', 'Secured Escrow Transit'),
    ShopProduct(6, 'MagDock 3-in-1 Milled Billet Brass Hub', 1,
      'Electronics & Audio', 'photo-1496181133206-80ce9b88a853', 129, 149,
      4.7, 342, 27, '24h Dispatch', 'Kyoto Express Logistics', fast: true),
  ];
  String query = '', category = 'All Departments', sort = 'Highest Rated Merchants';
  final Set<int> selectedStores = {}, favorites = {};
  final Map<int, int> cart = {};
  bool fastOnly = false, favoritesOnly = false, dealsOnly = false;
  double maxPrice = 800, minRating = 0;
  int get cartCount => cart.values.fold(0, (a, b) => a + b);
  double get cartTotal => cart.entries.fold(0.0,
      (a, e) => a + products.firstWhere((p) => p.id == e.key).price * e.value);
  List<ShopProduct> get visibleProducts {
    final result = products.where((p) =>
      (query.isEmpty || '${p.name} ${stores[p.store].name}'.toLowerCase().contains(query.toLowerCase())) &&
      (category == 'All Departments' || p.category == category) &&
      (selectedStores.isEmpty || selectedStores.contains(p.store)) &&
      (!fastOnly || p.fast) && (!favoritesOnly || favorites.contains(p.id)) &&
      (!dealsOnly || p.oldPrice > p.price) && p.price <= maxPrice && p.rating >= minRating
    ).toList();
    if (sort == 'Price: Low to High') {
      result.sort((a, b) => a.price.compareTo(b.price));
    } else if (sort == 'Price: High to Low') {
      result.sort((a, b) => b.price.compareTo(a.price));
    } else {
      result.sort((a, b) => stores[b.store].rating.compareTo(stores[a.store].rating));
    }
    return result;
  }
  void update(VoidCallback change) { change(); notifyListeners(); }
  void toggleStore(int index) => update(() {
    if (!selectedStores.add(index)) selectedStores.remove(index);
  });
  void favorite(int id) => update(() {
    if (!favorites.add(id)) favorites.remove(id);
  });
  void addToCart(int id) => update(() => cart[id] = (cart[id] ?? 0) + 1);
  void removeFromCart(int id) => update(() {
    final count = cart[id] ?? 0;
    if (count <= 1) { cart.remove(id); } else { cart[id] = count - 1; }
  });
  void clearFilters() => update(() {
    selectedStores.clear(); fastOnly = false; favoritesOnly = false;
    dealsOnly = false; maxPrice = 800; minRating = 0;
    query = ''; category = 'All Departments';
  });
}
