import 'package:stacked/stacked.dart';

class VendorProduct {
  const VendorProduct({
    required this.name,
    required this.description,
    required this.price,
    required this.image,
    required this.category,
    this.rating = 4.9,
    this.badge = '',
    this.readyToShip = true,
  });

  final String name;
  final String description;
  final String image;
  final String category;
  final String badge;
  final double price;
  final double rating;
  final bool readyToShip;
}

class VendorViewModel extends BaseViewModel {
  String query = '';
  String category = 'All Products';
  String sort = 'Featured';
  bool onlyReadyToShip = false;
  bool following = false;

  final Set<VendorProduct> favorites = <VendorProduct>{};
  final Set<VendorProduct> cart = <VendorProduct>{};

  final List<VendorProduct> products = const <VendorProduct>[
    VendorProduct(
      name: 'Skåne Hand-Turned Birch Bowl',
      description: 'Hand-turned solid birch bowl with natural finish.',
      price: 88,
      image:
          'https://images.unsplash.com/photo-1490312278390-ab64016e0aa9?w=800',
      category: 'Home & Living',
      badge: 'Artisan Pick',
    ),
    VendorProduct(
      name: 'Fjord Smoked Oak Prep Boards',
      description: 'End-grain European smoked oak board set.',
      price: 120,
      image:
          'https://images.unsplash.com/photo-1600489000022-c2086d79f9d4?w=800',
      category: 'Kitchen',
      badge: 'Best Seller',
    ),
    VendorProduct(
      name: 'Visby Ash Meditation Stool',
      description: 'Traditional low-profile Scandinavian stool.',
      price: 245,
      image:
          'https://images.unsplash.com/photo-1503602642458-232111445657?w=800',
      category: 'Furniture',
      badge: 'Custom Craft',
      readyToShip: false,
    ),
    VendorProduct(
      name: 'Dalar Slöjd Tasting Spoons',
      description: 'Hand-carved cherry wood tasting spoons.',
      price: 54,
      image: 'https://images.unsplash.com/photo-1547592180-85f173990554?w=800',
      category: 'Kitchen',
    ),
    VendorProduct(
      name: 'Nordic Solstice Candle Holders',
      description: 'Turned walnut pillars with solid brass cups.',
      price: 72,
      image:
          'https://images.unsplash.com/photo-1603006905003-be475563bc59?w=800',
      category: 'Home & Living',
    ),
    VendorProduct(
      name: 'Gotland Oak Peg Rail',
      description: 'Hand-finished oak wall rail with shaker pegs.',
      price: 160,
      image:
          'https://images.unsplash.com/photo-1600210492486-724fe5c67fb0?w=800',
      category: 'Furniture',
      readyToShip: false,
    ),
  ];

  List<VendorProduct> get filtered {
    final searchText = query.trim().toLowerCase();
    final result = products.where((product) {
      final matchesCategory =
          category == 'All Products' || product.category == category;
      final matchesSearch = '${product.name} ${product.description}'
          .toLowerCase()
          .contains(searchText);
      final matchesStock = !onlyReadyToShip || product.readyToShip;
      return matchesCategory && matchesSearch && matchesStock;
    }).toList();

    switch (sort) {
      case 'Price: Low to High':
        result.sort((a, b) => a.price.compareTo(b.price));
      case 'Price: High to Low':
        result.sort((a, b) => b.price.compareTo(a.price));
      case 'Top Rated':
        result.sort((a, b) => b.rating.compareTo(a.rating));
    }

    return result;
  }

  void setQuery(String value) {
    query = value;
    notifyListeners();
  }

  void setCategory(String value) {
    category = value;
    notifyListeners();
  }

  void setSort(String value) {
    sort = value;
    notifyListeners();
  }

  void setOnlyReadyToShip(bool value) {
    onlyReadyToShip = value;
    notifyListeners();
  }

  void toggleFavorite(VendorProduct product) {
    if (!favorites.add(product)) favorites.remove(product);
    notifyListeners();
  }

  void addToCart(VendorProduct product) {
    cart.add(product);
    notifyListeners();
  }

  void toggleFollow() {
    following = !following;
    notifyListeners();
  }
}
