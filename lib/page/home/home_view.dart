import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../component/toolbox/app_header.dart';
import '../../component/toolbox/app_footer.dart';
import 'home_viewmodel.dart';

const _purple = Color(0xFF3925DF);
const _ink = Color(0xFF182138);
const _muted = Color(0xFF6D7184);
const _pale = Color(0xFFEFEDFF);
const _line = Color(0xFFF0EFF8);

class HomeView extends StatefulWidget {
  const HomeView({super.key});
  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final model = HomeViewModel();
  final search = TextEditingController();
  final scroll = ScrollController();
  final catalogKey = GlobalKey();
  final storesKey = GlobalKey();

  String? _lastBrowseUri;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final uri = GoRouterState.of(context).uri;
    if (_lastBrowseUri == uri.toString()) return;
    _lastBrowseUri = uri.toString();
    final action = uri.queryParameters['action'];
    if (action == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      model.clearFilters();
      search.text = uri.queryParameters['q'] ?? '';
      model.update(() {
        model.query = search.text;
        final category = uri.queryParameters['category'];
        if (category != null && AppHeader.categories.contains(category)) {
          model.category = category;
        }
        model.dealsOnly = action == 'deals';
        model.favoritesOnly = action == 'wishlist';
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (action == 'cart') {
          _cart();
        } else if (action == 'stores') {
          jump(storesKey);
        } else {
          jump(catalogKey);
        }
      });
    });
  }

  @override
  void dispose() {
    model.dispose();
    search.dispose();
    scroll.dispose();
    super.dispose();
  }

  void jump(GlobalKey key) {
    final target = key.currentContext;
    if (target != null) {
      Scrollable.ensureVisible(
        target,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOut,
      );
    }
  }

  void clear() {
    search.clear();
    model.clearFilters();
  }

  void info(String title, String body) => showDialog<void>(
    context: context,
    builder: (c) => AlertDialog(
      title: Text(title),
      content: Text(body),
      actions: [
        TextButton(onPressed: () => c.pop(), child: const Text('Close')),
      ],
    ),
  );

  void _openVendor(int storeIndex) {
    context.pushNamed(
      'vendor',
      pathParameters: {'vendorId': storeIndex.toString()},
    );
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: model,
    builder: (context, _) => Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final mobile = constraints.maxWidth < 700;
          return CustomScrollView(
            controller: scroll,
            slivers: [
              SliverToBoxAdapter(
                child: AppHeader(
                  searchController: search,
                  selectedCategory: model.category,
                  cartCount: model.cartCount,
                  wishlistSelected: model.favoritesOnly,
                  onSearchChanged: (value) =>
                      model.update(() => model.query = value),
                  onSearchSubmitted: (value) {
                    model.update(() => model.query = value);
                    jump(catalogKey);
                  },
                  onCategorySelected: (value) {
                    model.update(() => model.category = value);
                    jump(catalogKey);
                  },
                  onStores: () => jump(storesKey),
                  onDeals: () {
                    model.update(() => model.dealsOnly = true);
                    jump(catalogKey);
                  },
                  onWishlist: () {
                    model.update(
                      () => model.favoritesOnly = !model.favoritesOnly,
                    );
                    jump(catalogKey);
                  },
                  onCart: _cart,
                  onLogo: () => scroll.animateTo(
                    0,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1280),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: mobile ? 16 : 32,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 24),
                          _hero(mobile),
                          const SizedBox(height: 38),
                          _stores(mobile),
                          const SizedBox(height: 38),
                          _bundle(mobile),
                          const SizedBox(height: 40),
                          _catalog(mobile),
                          const SizedBox(height: 40),
                          _trust(mobile),
                          const SizedBox(height: 76),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: AppFooter(
                  onExplore: () => jump(catalogKey),
                  onStores: _directory,
                  onDeals: () {
                    model.update(() => model.dealsOnly = true);
                    jump(catalogKey);
                  },
                  onLogo: () => scroll.animateTo(
                    0,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    ),
  );

  Widget _text(
    String text, {
    double size = 14,
    Color color = _ink,
    FontWeight weight = FontWeight.normal,
    int? lines,
  }) => Text(
    text,
    maxLines: lines,
    overflow: lines == null ? null : TextOverflow.ellipsis,
    style: TextStyle(
      fontSize: size,
      color: color,
      fontWeight: weight,
      height: 1.3,
    ),
  );
  Widget _label(String text, {Color color = _purple}) => Text(
    text,
    style: TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w700,
      color: color,
      letterSpacing: 1,
    ),
  );
  Widget _photo(
    String id, {
    double? height,
    double? width,
    double radius = 8,
  }) => ClipRRect(
    borderRadius: BorderRadius.circular(radius),
    child: Image.network(
      'https://images.unsplash.com/$id?auto=format&fit=crop&w=1000&q=85',
      height: height,
      width: width,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => Container(
        height: height,
        width: width,
        color: const Color(0xFFE4E0DB),
        alignment: Alignment.center,
        child: const Icon(Icons.image_outlined, color: _muted, size: 36),
      ),
    ),
  );
  Widget _button(
    String title,
    VoidCallback onTap, {
    bool pale = false,
    bool white = false,
    IconData? icon,
  }) => FilledButton(
    style: FilledButton.styleFrom(
      backgroundColor: white
          ? Colors.white
          : pale
          ? _pale
          : _purple,
      foregroundColor: pale || white ? _purple : Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
    ),
    onPressed: onTap,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[Icon(icon, size: 17), const SizedBox(width: 8)],
        Flexible(
          child: Text(
            title,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    ),
  );
  Widget _link(String label, VoidCallback tap) => TextButton(
    onPressed: tap,
    child: Text(label, style: const TextStyle(fontSize: 12, color: _purple)),
  );
  Widget _boxed(
    Widget child, {
    EdgeInsets padding = const EdgeInsets.all(16),
    Color color = Colors.white,
  }) => Container(
    padding: padding,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: _line),
    ),
    child: child,
  );
  Widget _hero(bool mobile) => Container(
    padding: EdgeInsets.all(mobile ? 24 : 40),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(10),
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF30315F), Color(0xFF252E40), Color(0xFF432D4C)],
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: .13),
          blurRadius: 18,
          offset: const Offset(0, 10),
        ),
      ],
    ),
    child: LayoutBuilder(
      builder: (context, c) {
        final intro = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: _label(
                    '● CURATED VENDOR COLLECTIVE',
                    color: const Color(0xFFE3DFFF),
                  ),
                ),
                _text(
                  'Vol. 28 Editorial',
                  size: 11,
                  color: const Color(0xFFD1D0E6),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _text(
              'Precision Acoustics,\nHand-Crafted Living.',
              size: mobile ? 34 : 46,
              weight: FontWeight.w800,
              color: const Color(0xFFEEECFF),
            ),
            const SizedBox(height: 12),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 490),
              child: _text(
                'Support 450+ verified independent boutiques. Direct artisan studio shipping with unified multi-vendor escrow security.',
                size: 18,
                color: const Color(0xFFBBBFD1),
              ),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _button(
                  'Explore 450+ Independent Boutiques →',
                  () => jump(catalogKey),
                ),
                _button(
                  'View Top Verified Stores',
                  () => jump(storesKey),
                  pale: true,
                ),
              ],
            ),
            const SizedBox(height: 18),
            const Divider(color: Color(0xFF41475D)),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _stat('450+', 'Vetted Boutiques'),
                _stat('99.4%', 'Dispatched in 24h'),
                _stat('RM 0', 'Split Checkout Fee'),
              ],
            ),
          ],
        );
        final visual = Container(
          height: mobile ? 320 : 440,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .16),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              _photo('photo-1546435770-a3e426bf472b'),
              Positioned(
                bottom: 10,
                left: 10,
                right: 10,
                child: _boxed(
                  Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: Color(0xFFDFDAFF),
                        child: Text('AA', style: TextStyle(color: _purple)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _text(
                              'Aura Audio Labs ✿',
                              size: 13,
                              weight: FontWeight.w700,
                            ),
                            _text('Kyoto · 9.9k Orders · 4.97 ★', size: 10),
                          ],
                        ),
                      ),
                      if (!mobile)
                        _text('Top Seller', size: 10, color: _purple),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
        if (mobile) {
          return Column(children: [intro, const SizedBox(height: 28), visual]);
        }
        return Row(
          children: [
            Expanded(flex: 6, child: intro),
            const SizedBox(width: 36),
            Expanded(flex: 4, child: visual),
          ],
        );
      },
    ),
  );
  Widget _stat(String value, String label) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _text(
        value,
        size: 20,
        color: const Color(0xFFE8E7F5),
        weight: FontWeight.w600,
      ),
      _text(label, size: 10, color: const Color(0xFFB6B7CC)),
    ],
  );

  Widget _stores(bool mobile) => Column(
    key: storesKey,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _label('▣  VERIFIED MERCHANT COLLECTIVE'),
      const SizedBox(height: 6),
      Row(
        children: [
          Expanded(
            child: _text(
              'Top Certified Boutiques',
              size: mobile ? 25 : 30,
              weight: FontWeight.w700,
            ),
          ),
          if (!mobile) _link('Explore All Directory ›', _directory),
        ],
      ),
      const SizedBox(height: 16),
      LayoutBuilder(
        builder: (context, c) {
          final columns = c.maxWidth < 550
              ? 1
              : c.maxWidth < 850
              ? 2
              : 4;
          return Wrap(
            spacing: 20,
            runSpacing: 20,
            children: List.generate(4, (i) {
              final s = HomeViewModel.stores[i];
              return SizedBox(
                width: (c.maxWidth - (columns - 1) * 20) / columns,
                child: _boxed(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Stack(
                        children: [
                          _photo(s.image, height: 98, width: double.infinity),
                          Positioned(
                            top: 6,
                            right: 6,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: _text(
                                '★ ${s.rating}',
                                size: 10,
                                weight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 21,
                            backgroundColor: [
                              const Color(0xFFFFDDB7),
                              const Color(0xFFE0DAFF),
                              const Color(0xFFFFD9E8),
                              const Color(0xFFFFC36D),
                            ][i],
                            child: _text(s.initials, size: 15),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _text(
                                  '${s.name} ✿',
                                  size: 15,
                                  weight: FontWeight.w600,
                                ),
                                _text(
                                  '${s.location} · ${s.category}',
                                  size: 10,
                                  color: _muted,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(6),
                        color: const Color(0xFFF5F3FF),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _text('${s.followers} Followers', size: 10),
                            _text('${s.products} Products', size: 10),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      // _button('Visit Storefront', () {
                      //   model.update(() {
                      //     model.selectedStores.clear();
                      //     model.selectedStores.add(i);
                      //   });
                      //   jump(catalogKey);
                      // }, pale: true),
                      _button(
                        'Visit Storefront',
                        () => _openVendor(i),
                        pale: true,
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(14),
                ),
              );
            }),
          );
        },
      ),
    ],
  );

  Widget _bundle(bool mobile) => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(10),
      gradient: const LinearGradient(colors: [_purple, Color(0xFF6256E9)]),
    ),
    child: LayoutBuilder(
      builder: (context, c) {
        final title = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label('ϟ  MULTI-SELLER CURATED BUNDLE', color: Colors.white70),
            const SizedBox(height: 12),
            _text(
              'The Nordic Workspace\nStudio Set',
              size: 30,
              weight: FontWeight.w700,
              color: Colors.white,
            ),
            const SizedBox(height: 8),
            _text(
              'Combine 3 independent workshops into one single payment with coordinated 48-hour split logistics.',
              size: 13,
              color: Colors.white70,
            ),
            const SizedBox(height: 12),
            _text(
              'CURATED COLLECTION  ·  3 STORES',
              size: 11,
              color: Colors.white70,
            ),
          ],
        );
        final items = Row(
          children: [
            for (final data in [
              [
                'photo-1496181133206-80ce9b88a853',
                'Walnut Stand',
                'Aura Audio',
              ],
              [
                'photo-1495474472287-4d71bcdd2085',
                'Artisan Dripper',
                'Nordic Clay',
              ],
              [
                'photo-1518455027359-f3f8164ba6bd',
                'Desk Pad 400',
                'Tanner & Forge',
              ],
            ])
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .16),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Column(
                    children: [
                      _photo(
                        data[0],
                        height: 80,
                        width: double.infinity,
                        radius: 4,
                      ),
                      const SizedBox(height: 7),
                      _text(data[1], size: 10, color: Colors.white),
                      _text(data[2], size: 9, color: Colors.white70),
                    ],
                  ),
                ),
              ),
          ],
        );
        final price = Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _text('RM 248.00', size: 13, color: Colors.white60),
            _text(
              'RM 174.00',
              size: 30,
              weight: FontWeight.bold,
              color: const Color(0xFFFFE27A),
            ),
            _text(
              'Save RM 74 · 3 Stores · 1 Cart',
              size: 10,
              color: Colors.white70,
            ),
            const SizedBox(height: 12),
            _button(
              'View 3-Way Bundle',
              () => info(
                'The Nordic Workspace Studio Set',
                'Demo curated bundle: Walnut Stand, Artisan Dripper and Desk Pad 400 for RM 174.00. Connect your bundle API to enable purchases.',
              ),
              white: true,
              icon: Icons.shopping_cart_outlined,
            ),
          ],
        );
        if (c.maxWidth < 900) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              title,
              const SizedBox(height: 24),
              items,
              const SizedBox(height: 20),
              price,
            ],
          );
        }
        return Row(
          children: [
            Expanded(flex: 4, child: title),
            const SizedBox(width: 20),
            Expanded(flex: 5, child: items),
            const SizedBox(width: 24),
            Expanded(flex: 3, child: price),
          ],
        );
      },
    ),
  );

  Widget _catalog(bool mobile) => LayoutBuilder(
    key: catalogKey,
    builder: (context, c) {
      final sidebar = c.maxWidth >= 900;
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (sidebar) ...[
            SizedBox(
              width: 268,
              child: Column(
                children: [
                  _filters(),
                  const SizedBox(height: 20),
                  _boxed(
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _text(
                          '◈  Split Payment Safeguard',
                          color: _purple,
                          size: 12,
                          weight: FontWeight.w600,
                        ),
                        const SizedBox(height: 8),
                        _text(
                          "Each merchant’s payout is unlocked only when you confirm final courier transit delivery.",
                          size: 13,
                          color: _muted,
                        ),
                      ],
                    ),
                    color: _pale,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 24),
          ],
          Expanded(
            child: Column(
              children: [
                _boxed(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          _text(
                            'Discover Direct Artifacts',
                            size: 20,
                            weight: FontWeight.w600,
                          ),
                          _text(
                            'Showing ${model.visibleProducts.length} demo products across 5 vendors',
                            size: 10,
                            color: _muted,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 10,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          _text(
                            model.favoritesOnly
                                ? '♥ Your Wishlist'
                                : 'Verified Stores Only',
                            size: 11,
                            color: _purple,
                          ),
                          if (!sidebar)
                            _link(
                              '☷ Filters',
                              () => showModalBottomSheet<void>(
                                context: context,
                                isScrollControlled: true,
                                builder: (ctx) => SafeArea(
                                  child: SizedBox(
                                    height: MediaQuery.sizeOf(ctx).height * .8,
                                    child: AnimatedBuilder(
                                      animation: model,
                                      builder: (_, _) => ListView(
                                        padding: const EdgeInsets.all(20),
                                        children: [_filters()],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          _text('Sort By:', size: 10, color: _muted),
                          DropdownButton<String>(
                            value: model.sort,
                            underline: const SizedBox.shrink(),
                            style: const TextStyle(fontSize: 11, color: _ink),
                            items:
                                [
                                      'Highest Rated Merchants',
                                      'Price: Low to High',
                                      'Price: High to Low',
                                    ]
                                    .map(
                                      (s) => DropdownMenuItem(
                                        value: s,
                                        child: Text(s),
                                      ),
                                    )
                                    .toList(),
                            onChanged: (s) {
                              if (s != null) model.update(() => model.sort = s);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                LayoutBuilder(
                  builder: (context, grid) {
                    final columns = grid.maxWidth >= 780
                        ? 3
                        : grid.maxWidth >= 440
                        ? 2
                        : 1;
                    final products = model.visibleProducts;
                    if (products.isEmpty) {
                      return _boxed(
                        SizedBox(
                          width: double.infinity,
                          child: Column(
                            children: [
                              const SizedBox(height: 32),
                              const Icon(
                                Icons.search_off,
                                size: 40,
                                color: _muted,
                              ),
                              const SizedBox(height: 12),
                              _text('No products match your filters.'),
                              _link('Clear all filters', clear),
                              const SizedBox(height: 32),
                            ],
                          ),
                        ),
                      );
                    }
                    return Wrap(
                      spacing: 18,
                      runSpacing: 24,
                      children: [
                        for (final product in products)
                          SizedBox(
                            width:
                                (grid.maxWidth - (columns - 1) * 18) / columns,
                            child: _product(product),
                          ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),
                _boxed(
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _text(
                        'Showing ${model.visibleProducts.length} products',
                        size: 11,
                        color: _muted,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 13,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: _purple,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: _text('1', color: Colors.white, size: 12),
                      ),
                      _text('Page 1 of 1', size: 11, color: _muted),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    },
  );
  Widget _filters() => _boxed(
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.tune, size: 18),
            const SizedBox(width: 6),
            Expanded(
              child: _text('Filter Matrix', size: 18, weight: FontWeight.w600),
            ),
            _link('Clear All', clear),
          ],
        ),
        const Divider(color: _line),
        _text('Verified Storefronts', size: 12, weight: FontWeight.w600),
        const SizedBox(height: 8),
        for (var i = 0; i < HomeViewModel.stores.length; i++)
          _check(
            HomeViewModel.stores[i].name,
            model.selectedStores.contains(i),
            (_) => model.toggleStore(i),
            trailing: '${HomeViewModel.stores[i].products}',
          ),
        const Divider(color: _line),
        _text('Multi-Vendor Fulfillment', size: 12, weight: FontWeight.w600),
        _check(
          'ϟ Ships in 24 Hours',
          model.fastOnly,
          (v) => model.update(() => model.fastOnly = v),
        ),
        _check(
          'Sale items only',
          model.dealsOnly,
          (v) => model.update(() => model.dealsOnly = v),
        ),
        const Divider(color: _line),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _text('Price Range', size: 12, weight: FontWeight.w600),
            _text('RM 0 – ${model.maxPrice.round()}', size: 11, color: _purple),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 3,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
          ),
          child: Slider(
            value: model.maxPrice,
            min: 0,
            max: 800,
            divisions: 80,
            activeColor: _purple,
            onChanged: (v) => model.update(() => model.maxPrice = v),
          ),
        ),
        const Divider(color: _line),
        _text('Vendor Trust Rating', size: 12, weight: FontWeight.w600),
        _check(
          '★★★★★ 4.5 & above',
          model.minRating == 4.5,
          (v) => model.update(() => model.minRating = v ? 4.5 : 0),
        ),
        _check(
          '★★★★ 4.0 & above',
          model.minRating == 4,
          (v) => model.update(() => model.minRating = v ? 4 : 0),
        ),
      ],
    ),
  );
  Widget _check(
    String label,
    bool checked,
    ValueChanged<bool> onChanged, {
    String? trailing,
  }) => InkWell(
    onTap: () => onChanged(!checked),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          SizedBox(
            width: 17,
            height: 17,
            child: Checkbox(
              value: checked,
              activeColor: _purple,
              onChanged: (v) => onChanged(v ?? false),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              side: const BorderSide(color: _muted, width: 1),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: _text(label, size: 12)),
          if (trailing != null) _text(trailing, size: 10, color: _muted),
        ],
      ),
    ),
  );
  Widget _product(ShopProduct p) => _boxed(
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: 1.02,
          child: Stack(
            fit: StackFit.expand,
            children: [
              InkWell(onTap: () => _detail(p), child: _photo(p.image)),
              Positioned(
                top: 9,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: p.fast
                        ? _purple
                        : p.stock == 1
                        ? const Color(0xFFAC1678)
                        : const Color(0xFF956108),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: _text(
                    p.badge,
                    size: 10,
                    weight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              Positioned(
                top: 5,
                right: 5,
                child: SizedBox(
                  width: 32,
                  height: 32,
                  child: IconButton.filledTonal(
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: .9),
                    ),
                    padding: EdgeInsets.zero,
                    tooltip: 'Save ${p.name}',
                    onPressed: () => model.favorite(p.id),
                    icon: Icon(
                      model.favorites.contains(p.id)
                          ? Icons.favorite
                          : Icons.favorite_border,
                      size: 18,
                      color: _ink,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _text(
                '✿ By ${HomeViewModel.stores[p.store].name}',
                size: 9,
                weight: FontWeight.w600,
              ),
            ),
            _text(
              '${p.stock} in stock',
              size: 9,
              color: p.stock < 5
                  ? const Color(0xFFAB1263)
                  : const Color(0xFF926000),
            ),
          ],
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 48,
          child: InkWell(
            onTap: () => _detail(p),
            child: _text(p.name, size: 16, weight: FontWeight.w500, lines: 2),
          ),
        ),
        Row(
          children: [
            _text('★★★★★', size: 12, color: const Color(0xFF956108)),
            _text(
              ' ${p.rating.toStringAsFixed(1)} (${p.reviews} reviews)',
              size: 10,
              color: _muted,
            ),
          ],
        ),
        const Divider(color: _line, height: 16),
        Row(
          children: [
            Expanded(
              child: Wrap(
                spacing: 7,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  _text(
                    'RM ${p.price.toStringAsFixed(2)}',
                    size: 19,
                    weight: FontWeight.w700,
                  ),
                  if (p.oldPrice > 0)
                    Text(
                      'RM ${p.oldPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: _muted,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                ],
              ),
            ),
            IconButton.filled(
              style: IconButton.styleFrom(
                backgroundColor: _purple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7),
                ),
              ),
              tooltip: 'Add ${p.name} to cart',
              icon: const Icon(Icons.add_shopping_cart, size: 19),
              onPressed: () {
                model.addToCart(p.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${p.name} added to cart'),
                    duration: const Duration(seconds: 2),
                    action: SnackBarAction(label: 'View', onPressed: _cart),
                  ),
                );
              },
            ),
          ],
        ),
        _text(p.shipping, size: 9, color: _muted),
      ],
    ),
    padding: const EdgeInsets.all(8),
  );

  Widget _trust(bool mobile) => Container(
    padding: EdgeInsets.all(mobile ? 22 : 40),
    decoration: BoxDecoration(
      color: const Color(0xFFF1F0FF),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Column(
      children: [
        _label('ARCHITECTED FOR TRUST'),
        const SizedBox(height: 10),
        _text(
          'The EzyOrder Direct Commerce Standard',
          size: mobile ? 25 : 32,
          weight: FontWeight.w700,
        ),
        const SizedBox(height: 10),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 650),
          child: Text(
            'Unified checkout across hundreds of independent creators without logistical friction or payment risk.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 15, color: _muted, height: 1.5),
          ),
        ),
        const SizedBox(height: 36),
        LayoutBuilder(
          builder: (context, c) {
            final cols = c.maxWidth < 700 ? 1 : 3;
            return Wrap(
              spacing: 24,
              runSpacing: 20,
              children: [
                for (final item in [
                  [
                    Icons.payments_outlined,
                    'Single Cart Split Payout',
                    'Purchase from 5 distinct stores in one instant transaction. Our automated routing system disperses funds directly to individual merchant ledgers with zero manual split fees.',
                    'Learn about split billing →',
                  ],
                  [
                    Icons.shield_outlined,
                    'Escrow Delivery Guarantee',
                    'Your payment is held protected in smart escrow. Funds release to independent vendors only after carrier tracking confirms safe doorstep arrival.',
                    'Escrow Shield Protocol →',
                  ],
                  [
                    Icons.swap_horiz,
                    'Unified Returns Portal',
                    'Need to return an item from one seller while keeping the rest? Print individual return waybills directly from your unified order history dashboard in two clicks.',
                    '30-Day Resolution Policy →',
                  ],
                ])
                  SizedBox(
                    width: (c.maxWidth - (cols - 1) * 24) / cols,
                    child: _boxed(
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _pale,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(item[0] as IconData, color: _purple),
                          ),
                          const SizedBox(height: 16),
                          _text(
                            item[1] as String,
                            size: 17,
                            weight: FontWeight.w600,
                          ),
                          const SizedBox(height: 8),
                          _text(item[2] as String, size: 14, color: _muted),
                          const SizedBox(height: 15),
                          _link(
                            item[3] as String,
                            () => info(
                              item[1] as String,
                              'This is reference design content. Configure your actual EzyOrder payment, delivery and returns policies before launch.',
                            ),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(24),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    ),
  );

  void _detail(ShopProduct p) => showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(p.name),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _photo(p.image, height: 200, width: double.infinity),
            const SizedBox(height: 16),
            _text('By ${HomeViewModel.stores[p.store].name} · ${p.rating} ★'),
            const SizedBox(height: 8),
            _text(
              'RM ${p.price.toStringAsFixed(2)}',
              size: 24,
              weight: FontWeight.bold,
            ),
            const SizedBox(height: 8),
            _text('${p.stock} in stock · ${p.shipping}', color: _muted),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => ctx.pop(), child: const Text('Close')),
        FilledButton(
          onPressed: () {
            model.addToCart(p.id);
            ctx.pop();
          },
          child: const Text('Add to cart'),
        ),
      ],
    ),
  );
  void _directory() => showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Verified Store Directory'),
      content: SizedBox(
        width: 440,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(HomeViewModel.stores.length, (i) {
            final s = HomeViewModel.stores[i];
            return ListTile(
              leading: CircleAvatar(child: Text(s.initials)),
              title: Text(s.name),
              subtitle: Text('${s.location} · ${s.category}'),
              trailing: const Icon(Icons.chevron_right),
              // onTap: () {
              //   model.update(() {
              //     model.selectedStores.clear();
              //     model.selectedStores.add(i);
              //   });
              //   ctx.pop();
              //   jump(catalogKey);
              // },
              onTap: () {
                ctx.pop();
                _openVendor(i);
              },
            );
          }),
        ),
      ),
      actions: [
        TextButton(onPressed: () => ctx.pop(), child: const Text('Close')),
      ],
    ),
  );
  void _cart() => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => SafeArea(
      child: SizedBox(
        height: MediaQuery.sizeOf(ctx).height * .75,
        child: AnimatedBuilder(
          animation: model,
          builder: (_, _) => Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _text(
                        'Your Shopping Cart (${model.cartCount})',
                        size: 24,
                        weight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => ctx.pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: model.cart.isEmpty
                      ? const Center(
                          child: Text(
                            'Your cart is empty. Discover something special.',
                          ),
                        )
                      : ListView(
                          children: model.cart.entries.map((e) {
                            final p = HomeViewModel.products.firstWhere(
                              (p) => p.id == e.key,
                            );
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: _text(p.name, size: 14),
                              subtitle: _text(
                                'RM ${p.price.toStringAsFixed(2)} × ${e.value}',
                                size: 12,
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    tooltip: 'Remove one',
                                    onPressed: () => model.removeFromCart(p.id),
                                    icon: const Icon(
                                      Icons.remove_circle_outline,
                                    ),
                                  ),
                                  Text('${e.value}'),
                                  IconButton(
                                    tooltip: 'Add one',
                                    onPressed: () => model.addToCart(p.id),
                                    icon: const Icon(Icons.add_circle_outline),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                ),
                const Divider(),
                _text(
                  'Total: RM ${model.cartTotal.toStringAsFixed(2)}',
                  size: 24,
                  weight: FontWeight.bold,
                ),
                const SizedBox(height: 12),
                _text(
                  'Demo cart — connect your checkout API to accept orders. Cart and wishlist reset when this page closes.',
                  size: 12,
                  color: _muted,
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
