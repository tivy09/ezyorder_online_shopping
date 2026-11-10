// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stacked/stacked.dart';

import 'vendor_viewmodel.dart';

/// Vendor storefront, using the same optional header/footer as other pages.
/// The vertical page is a CustomScrollView (no SingleChildScrollView).
class VendorView extends StackedView<VendorViewModel> {
  const VendorView({
    super.key,
    required this.vendorId,
    this.headerBuilder,
    this.footerBuilder,
  });

  final String vendorId;
  final WidgetBuilder? headerBuilder;
  final WidgetBuilder? footerBuilder;

  static const Color primary = Color(0xFF0656A0);
  static const Color ink = Color(0xFF18233B);
  static const Color muted = Color(0xFF667085);
  static const Color surface = Color(0xFFF6F7FC);

  static const List<String> _categories = <String>[
    'All Products',
    'Furniture',
    'Kitchen',
    'Home & Living',
  ];

  static const List<String> _sortOptions = <String>[
    'Featured',
    'Top Rated',
    'Price: Low to High',
    'Price: High to Low',
  ];

  @override
  VendorViewModel viewModelBuilder(BuildContext context) => VendorViewModel();

  @override
  Widget builder(BuildContext context, VendorViewModel model, Widget? child) {
    final width = MediaQuery.sizeOf(context).width;
    final isMobile = width < 600;
    final isCompact = width < 1024;

    return Scaffold(
      backgroundColor: surface,
      body: CustomScrollView(
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: headerBuilder?.call(context) ?? const SizedBox.shrink(),
          ),
          SliverToBoxAdapter(child: _hero(context, model, isMobile)),
          SliverToBoxAdapter(child: _contained(_stats(isCompact))),
          SliverToBoxAdapter(child: _contained(_promo(context))),
          SliverToBoxAdapter(child: _contained(_tabs(context, model))),
          SliverToBoxAdapter(
            child: _contained(_catalog(context, model, isCompact)),
          ),
          SliverToBoxAdapter(child: _story(isCompact)),
          SliverToBoxAdapter(child: _contained(_policies())),
          SliverToBoxAdapter(
            child: footerBuilder?.call(context) ?? const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _contained(Widget child) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: SizedBox(width: double.infinity, child: child),
      ),
    );
  }

  Widget _hero(BuildContext context, VendorViewModel model, bool isMobile) {
    return Container(
      constraints: BoxConstraints(minHeight: isMobile ? 310 : 360),
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(
            'https://images.unsplash.com/photo-1504917595217-d4dc5ebe6122?w=1800',
          ),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        constraints: BoxConstraints(minHeight: isMobile ? 310 : 360),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[Colors.transparent, Color(0xDD111827)],
          ),
        ),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: _contained(
            Padding(
              padding: EdgeInsets.all(isMobile ? 18 : 28),
              child: isMobile
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        _heroIdentity(isMobile),
                        const SizedBox(height: 16),
                        _heroActions(context, model),
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Expanded(child: _heroIdentity(isMobile)),
                        const SizedBox(width: 16),
                        _heroActions(context, model),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _heroIdentity(bool isMobile) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Container(
          width: isMobile ? 64 : 86,
          height: isMobile ? 64 : 86,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 3),
            borderRadius: BorderRadius.circular(12),
            image: const DecorationImage(
              image: NetworkImage(
                'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=300',
              ),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                'Nordic Crafts Co.',
                style: TextStyle(
                  fontSize: isMobile ? 21 : 29,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 5,
                children: <Widget>[
                  _pill(
                    '★ VERIFIED SELLER',
                    const Color(0xFFFFC85A),
                    Colors.black87,
                  ),
                  const Text(
                    'Stockholm, Sweden · Ships Worldwide',
                    style: TextStyle(color: Colors.white, fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _heroActions(BuildContext context, VendorViewModel model) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: <Widget>[
        FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: ink,
          ),
          onPressed: model.toggleFollow,
          icon: Icon(
            model.following ? Icons.favorite : Icons.favorite_border,
            size: 18,
          ),
          label: Text(model.following ? 'Following' : 'Follow Store'),
        ),
        FilledButton.icon(
          style: FilledButton.styleFrom(backgroundColor: primary),
          onPressed: () =>
              _snack(context, 'Connect your messaging route here.'),
          icon: const Icon(Icons.chat_bubble_outline, size: 17),
          label: const Text('Message Seller'),
        ),
      ],
    );
  }

  Widget _pill(String label, Color background, Color foreground) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          color: foreground,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _stats(bool isCompact) {
    const items = <({String icon, String value, String label})>[
      (icon: '⭐', value: '4.95', label: 'Excellent Buyer Trust'),
      (icon: '🚚', value: '99.4%', label: 'On-Time Dispatch'),
      (icon: '👥', value: '15,480', label: 'Store Followers'),
      (icon: '◷', value: '< 1.8 hrs', label: 'Avg. Response Time'),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columns = isCompact ? 2 : 4;
          final cardWidth =
              (constraints.maxWidth - (columns - 1) * 12) / columns;
          return Wrap(
            spacing: 12,
            runSpacing: 12,
            children: items.map((item) {
              return SizedBox(
                width: cardWidth,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: <Widget>[
                      Text(item.icon, style: const TextStyle(fontSize: 19)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              item.value,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              item.label,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 10,
                                color: muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  Widget _promo(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(18, 12, 18, 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: <Color>[primary, Color(0xFF4186DB)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 16,
        runSpacing: 12,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Text(
                'LIMITED STORE OFFER',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 10,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Spend RM100, receive RM15 off your order',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 8,
            children: <Widget>[
              const Text(
                'NORDIC15',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: primary,
                ),
                onPressed: () async {
                  await Clipboard.setData(
                    const ClipboardData(text: 'NORDIC15'),
                  );
                  if (context.mounted) _snack(context, 'Promo code copied');
                },
                child: const Text('Copy Code'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tabs(BuildContext context, VendorViewModel model) {
    const tabs = <String>[
      'All Products',
      'Furniture',
      'Kitchen',
      'Home & Living',
      'About Seller',
      'Policies & Shipping',
      'Customer Reviews',
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 5),
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: tabs.map((name) {
            final selected = model.category == name;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: selected ? primary : null,
                  foregroundColor: selected ? Colors.white : ink,
                ),
                onPressed: () {
                  if (_categories.contains(name)) {
                    model.setCategory(name);
                  } else {
                    _snack(context, 'The $name section is below.');
                  }
                },
                child: Text(name, style: const TextStyle(fontSize: 12)),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _catalog(BuildContext context, VendorViewModel model, bool isCompact) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 36),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (!isCompact) ...<Widget>[
            SizedBox(width: 240, child: _filters(model)),
            const SizedBox(width: 18),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        onChanged: model.setQuery,
                        decoration: InputDecoration(
                          hintText: 'Search in shop',
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: Colors.white,
                          isDense: true,
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    if (isCompact) ...<Widget>[
                      const SizedBox(width: 8),
                      IconButton.filledTonal(
                        onPressed: () => _showFilters(context, model),
                        icon: const Icon(Icons.tune),
                        tooltip: 'Shop filters',
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: <Widget>[
                    Text(
                      '${model.filtered.length} products',
                      style: const TextStyle(fontSize: 12, color: muted),
                    ),
                    DropdownButton<String>(
                      value: model.sort,
                      underline: const SizedBox.shrink(),
                      items: _sortOptions.map((option) {
                        return DropdownMenuItem<String>(
                          value: option,
                          child: Text(
                            option,
                            style: const TextStyle(fontSize: 12),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) model.setSort(value);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (model.filtered.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 60),
                    child: Center(
                      child: Text('No products match your filters.'),
                    ),
                  )
                else
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth;
                      final columns = width >= 670
                          ? 3
                          : width >= 240
                          ? 2
                          : 1;
                      final gap = width < 400 ? 8.0 : 12.0;
                      final itemWidth = (width - (columns - 1) * gap) / columns;
                      // Fixed extent avoids overflowing price/actions on phones.
                      final itemHeight =
                          itemWidth * 0.82 + (width < 400 ? 198 : 185);

                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: model.filtered.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          crossAxisSpacing: gap,
                          mainAxisSpacing: gap,
                          mainAxisExtent: itemHeight,
                        ),
                        itemBuilder: (context, index) => _productCard(
                          context,
                          model,
                          model.filtered[index],
                          itemWidth < 190,
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showFilters(BuildContext context, VendorViewModel model) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => SafeArea(
        child: FractionallySizedBox(
          heightFactor: 0.72,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              AnimatedBuilder(
                animation: model,
                builder: (context, child) => _filters(model),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _filters(VendorViewModel model) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Text(
            'Shop Filters',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 16),
          const Text(
            'CATEGORY',
            style: TextStyle(
              fontSize: 11,
              color: muted,
              fontWeight: FontWeight.bold,
            ),
          ),
          ..._categories.map((name) {
            return RadioListTile<String>(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text(name, style: const TextStyle(fontSize: 12)),
              value: name,
              groupValue: model.category,
              onChanged: (value) {
                if (value != null) model.setCategory(value);
              },
            );
          }),
          const Divider(),
          const Text(
            'STOCK AVAILABILITY',
            style: TextStyle(
              fontSize: 11,
              color: muted,
              fontWeight: FontWeight.bold,
            ),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            title: const Text(
              'Ready to Dispatch',
              style: TextStyle(fontSize: 12),
            ),
            value: model.onlyReadyToShip,
            onChanged: model.setOnlyReadyToShip,
          ),
          const Divider(),
          const Text(
            'Sustainable Origin',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 7),
          const Text(
            'Hand-finished Scandinavian craftsmanship, responsibly sourced '
            'timber, and low-waste packaging.',
            style: TextStyle(fontSize: 12, color: muted),
          ),
        ],
      ),
    );
  }

  Widget _productCard(
    BuildContext context,
    VendorViewModel model,
    VendorProduct product,
    bool compact,
  ) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                Image.network(
                  product.image,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const ColoredBox(
                      color: Color(0xFFE8EAF1),
                      child: Icon(Icons.image_outlined, size: 44),
                    );
                  },
                ),
                if (product.badge.isNotEmpty)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: _pill(product.badge, primary, Colors.white),
                  ),
                Positioned(
                  top: 5,
                  right: 5,
                  child: IconButton.filledTonal(
                    iconSize: 18,
                    onPressed: () => model.toggleFavorite(product),
                    icon: Icon(
                      model.favorites.contains(product)
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: model.favorites.contains(product)
                          ? Colors.red
                          : ink,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(compact ? 8 : 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '⭐ ${product.rating.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 10),
                ),
                const SizedBox(height: 4),
                Text(
                  product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: compact ? 12 : 13,
                    fontWeight: FontWeight.w700,
                    color: ink,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  product.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11, color: muted),
                ),
                const SizedBox(height: 9),
                Text(
                  '\$${product.price.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: compact ? 15 : 17,
                    fontWeight: FontWeight.bold,
                    color: ink,
                  ),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: primary,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      visualDensity: VisualDensity.compact,
                    ),
                    onPressed: () {
                      model.addToCart(product);
                      _snack(context, '${product.name} added to demo cart');
                    },
                    icon: const Icon(Icons.add_shopping_cart, size: 15),
                    label: Text(
                      'Add to Cart',
                      style: TextStyle(fontSize: compact ? 10 : 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _story(bool isCompact) {
    final image = ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Image.network(
        'https://images.unsplash.com/photo-1452860606245-08befc0ff44b?w=1000',
        fit: BoxFit.cover,
        height: isCompact ? 230 : 340,
        width: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return const SizedBox(
            height: 230,
            child: ColoredBox(
              color: surface,
              child: Center(child: Icon(Icons.handyman_outlined, size: 50)),
            ),
          );
        },
      ),
    );

    const storyContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          "THE MAKER'S STORY",
          style: TextStyle(
            fontSize: 11,
            letterSpacing: 1.5,
            fontWeight: FontWeight.bold,
            color: primary,
          ),
        ),
        SizedBox(height: 12),
        Text(
          'Honoring slow Scandinavian craft in a disposable world.',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: ink,
          ),
        ),
        SizedBox(height: 15),
        Text(
          'Founded in 2021, Nordic Crafts Co. was born out of deep reverence '
          'for Sweden’s centuries-old woodworking tradition. Each piece is '
          'shaped individually with patience, natural materials and thoughtful '
          'design.',
          style: TextStyle(fontSize: 14, height: 1.7, color: muted),
        ),
        SizedBox(height: 20),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: <Widget>[
            _StoryStat('3,200+', 'Handcrafted pieces'),
            _StoryStat('0%', 'Plastic packaging'),
            _StoryStat('100 yr', 'Timber guarantee'),
          ],
        ),
      ],
    );

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 55, horizontal: 18),
      child: _contained(
        isCompact
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  image,
                  const SizedBox(height: 24),
                  storyContent,
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(child: image),
                  const SizedBox(width: 38),
                  const Expanded(child: storyContent),
                ],
              ),
      ),
    );
  }

  Widget _policies() {
    const policies = <String, String>{
      'Domestic & International Shipping Windows':
          'Shipping estimates depend on your delivery location and product availability.',
      'Zero-Waste Protective Packaging':
          'We use recyclable and low-waste protective packaging where possible.',
      '30-Day Happiness Guarantee & Return Handling':
          'Contact the seller within 30 days for eligible return requests.',
    };

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 35),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'PROVENANCE & FULFILLMENT',
            style: TextStyle(
              color: primary,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 7),
          const Text(
            'Store Policies & Split Delivery Guarantees',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: ink,
            ),
          ),
          const SizedBox(height: 16),
          ...policies.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ExpansionTile(
                key: PageStorageKey<String>(entry.key),
                backgroundColor: surface,
                collapsedBackgroundColor: surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9),
                ),
                collapsedShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9),
                ),
                title: Text(
                  entry.key,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(15),
                    child: Text(
                      entry.value,
                      style: const TextStyle(color: muted),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  void _snack(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _StoryStat extends StatelessWidget {
  const _StoryStat(this.value, this.label);

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: VendorView.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: <Widget>[
          Text(
            value,
            style: const TextStyle(
              color: VendorView.primary,
              fontWeight: FontWeight.bold,
              fontSize: 17,
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: VendorView.muted, fontSize: 10),
          ),
        ],
      ),
    );
  }
}
