import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/app_routes.dart';
import 'marketplace_common.dart';

class AppHeader extends StatefulWidget {
  const AppHeader({
    super.key,
    this.searchController,
    this.onSearchChanged,
    this.onSearchSubmitted,
    this.onCategorySelected,
    this.onStores,
    this.onDeals,
    this.onWishlist,
    this.onCart,
    this.onVendor,
    this.onLogo,
    this.cartCount = 0,
    this.wishlistSelected = false,
    this.selectedCategory = 'All Departments',
  });

  final TextEditingController? searchController;
  final ValueChanged<String>? onSearchChanged,
      onSearchSubmitted,
      onCategorySelected;
  final VoidCallback? onStores, onDeals, onWishlist, onCart, onVendor, onLogo;
  final int cartCount;
  final bool wishlistSelected;
  final String selectedCategory;
  static const categories = [
    'All Departments',
    'Electronics & Audio',
    'Artisan Home',
    'Fashion & Apparel',
    'Health & Wellness',
  ];

  @override
  State<AppHeader> createState() => _AppHeaderState();
}

class _AppHeaderState extends State<AppHeader> {
  final _localSearch = TextEditingController();
  TextEditingController get search => widget.searchController ?? _localSearch;
  @override
  void dispose() {
    _localSearch.dispose();
    super.dispose();
  }

  void _submit(String query) {
    if (widget.onSearchSubmitted != null) {
      widget.onSearchSubmitted!(query);
    } else {
      marketplaceBrowse(context, 'catalog', query: query);
    }
  }

  void _stores() => widget.onStores != null
      ? widget.onStores!()
      : marketplaceBrowse(context, 'stores');
  void _deals() => widget.onDeals != null
      ? widget.onDeals!()
      : marketplaceBrowse(context, 'deals');
  void _vendor() => widget.onVendor != null
      ? widget.onVendor!()
      : marketplaceNotice(context, 'Vendor portal');

  Widget _link(String text, VoidCallback tap) => TextButton(
    onPressed: tap,
    child: Text(
      text,
      style: const TextStyle(fontSize: 12, color: marketplacePrimary),
    ),
  );

  @override
  Widget build(BuildContext context) => MarketplaceTheme(
    child: LayoutBuilder(
      builder: (context, c) {
        final mobile = c.maxWidth < 768;
        final wide = c.maxWidth >= 1100;
        return Column(
          children: [
            Container(
              color: const Color(0xFFF2F1FF),
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: MarketplaceWidth(
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Free verified logistics & split-order delivery on orders over RM 50',
                        style: TextStyle(fontSize: 11, color: marketplaceMuted),
                      ),
                    ),
                    if (!mobile) ...[
                      _link('Become a Vendor', _vendor),
                      const SizedBox(width: 18),
                      const Text(
                        'MYR (RM)  ⌄    EN  ⌄',
                        style: TextStyle(fontSize: 11),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Container(
              color: Colors.white,
              child: MarketplaceWidth(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        if (mobile)
                          SizedBox(
                            width: 120,
                            child: FittedBox(
                              child: MarketplaceLogo(onTap: widget.onLogo),
                            ),
                          )
                        else
                          MarketplaceLogo(onTap: widget.onLogo),
                        SizedBox(width: mobile ? 4 : 24),
                        if (c.maxWidth >= 1250) ...[
                          const Icon(
                            Icons.location_on_outlined,
                            color: marketplacePrimary,
                            size: 20,
                          ),
                          const Text(
                            'Deliver to\nMalaysia',
                            style: TextStyle(fontSize: 11),
                          ),
                          const SizedBox(width: 24),
                        ],
                        if (!mobile) Expanded(child: _search(wide)),
                        if (mobile) const Spacer(),
                        if (wide) _link('Stores & Vendors', _stores),
                        IconButton(
                          tooltip: 'Your wishlist',
                          onPressed:
                              widget.onWishlist ??
                              () => marketplaceBrowse(context, 'wishlist'),
                          icon: Icon(
                            widget.wishlistSelected
                                ? Icons.favorite
                                : Icons.favorite_border,
                            size: 22,
                          ),
                        ),
                        Badge(
                          isLabelVisible: widget.cartCount > 0,
                          label: Text('${widget.cartCount}'),
                          child: IconButton(
                            tooltip: 'Shopping cart',
                            onPressed:
                                widget.onCart ??
                                () => marketplaceBrowse(context, 'cart'),
                            icon: const Icon(
                              Icons.shopping_bag_outlined,
                              size: 22,
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Sign in or create an account',
                          onPressed: () => context.goNamed(AppRoutes.auth),
                          icon: const Icon(
                            Icons.person_outline,
                            color: marketplacePrimary,
                            size: 23,
                          ),
                        ),
                        if (wide)
                          _link(
                            'Sign in',
                            () => context.goNamed(AppRoutes.auth),
                          ),
                      ],
                    ),
                    if (mobile) ...[const SizedBox(height: 16), _search(false)],
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 40,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          for (final category in AppHeader.categories)
                            Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: TextButton(
                                style: TextButton.styleFrom(
                                  backgroundColor:
                                      widget.selectedCategory == category
                                      ? marketplacePrimary
                                      : Colors.transparent,
                                  foregroundColor:
                                      widget.selectedCategory == category
                                      ? Colors.white
                                      : marketplaceInk,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () {
                                  if (widget.onCategorySelected != null) {
                                    widget.onCategorySelected!(category);
                                  } else {
                                    marketplaceBrowse(
                                      context,
                                      'catalog',
                                      category: category,
                                    );
                                  }
                                },
                                child: Text(
                                  category,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                            ),
                          _link('Featured Vendors', _stores),
                          _link('Flash Deals', _deals),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    ),
  );

  Widget _search(bool wide) => Container(
    height: 42,
    decoration: BoxDecoration(
      color: const Color(0xFFF3F2FF),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        const SizedBox(width: 12),
        if (wide) ...[
          const Text(
            'All Categories ⌄',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: TextField(
            controller: search,
            onChanged: widget.onSearchChanged,
            onSubmitted: _submit,
            textInputAction: TextInputAction.search,
            style: const TextStyle(fontSize: 12, color: marketplaceInk),
            decoration: const InputDecoration(
              hintText: 'Search verified vendors, handcrafted goods…',
              hintStyle: TextStyle(color: marketplaceMuted, fontSize: 12),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
        IconButton(
          tooltip: 'Search products',
          onPressed: () => _submit(search.text),
          icon: const Icon(Icons.search, color: marketplacePrimary, size: 22),
        ),
      ],
    ),
  );
}
