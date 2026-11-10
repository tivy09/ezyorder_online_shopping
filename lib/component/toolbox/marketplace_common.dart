import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/app_routes.dart';

const marketplacePrimary = Color(0xFF3525CD);
const marketplaceInk = Color(0xFF131B2E);
const marketplaceMuted = Color(0xFF64748B);

/// Keeps shared chrome identical even inside a page-specific Theme.
class MarketplaceTheme extends StatelessWidget {
  const MarketplaceTheme({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Theme(
    data: ThemeData(useMaterial3: true, brightness: Brightness.light,
      fontFamily: 'Roboto', colorScheme: ColorScheme.fromSeed(seedColor: marketplacePrimary),
      textTheme: ThemeData.light().textTheme.apply(bodyColor: marketplaceInk, displayColor: marketplaceInk)),
    child: child,
  );
}

class MarketplaceWidth extends StatelessWidget {
  const MarketplaceWidth({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Center(child: ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 1280),
    child: Padding(padding: EdgeInsets.symmetric(horizontal: MediaQuery.sizeOf(context).width < 768 ? 16 : 32), child: child)));
}

class MarketplaceLogo extends StatelessWidget {
  const MarketplaceLogo({super.key, this.onTap});
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap ?? () => context.goNamed(AppRoutes.home),
    child: const Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.shopping_bag_outlined, color: marketplacePrimary, size: 26),
      SizedBox(width: 10),
      Text('EzyOrder', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, letterSpacing: -.8)),
    ]));
}

void marketplaceBrowse(BuildContext context, String action, {String? query, String? category}) {
  context.goNamed(AppRoutes.home, queryParameters: {
    'action': action,
    if (query != null && query.isNotEmpty) 'q': query,
    if (category != null) 'category': category,
  });
}

void marketplaceNotice(BuildContext context, String title) {
  showDialog<void>(context: context, builder: (ctx) => AlertDialog(
    title: Text(title), content: const Text('This service is not available yet.'),
    actions: [TextButton(onPressed: () => ctx.pop(), child: const Text('Close'))]));
}
