import 'package:flutter/material.dart';
import 'marketplace_common.dart';

class AppFooter extends StatelessWidget {
  const AppFooter({super.key, this.onExplore, this.onStores, this.onDeals,
    this.onVendor, this.onTerms, this.onPrivacy, this.onDisputes, this.onLogo});
  final VoidCallback? onExplore, onStores, onDeals, onVendor, onTerms, onPrivacy, onDisputes, onLogo;

  @override
  Widget build(BuildContext context) => MarketplaceTheme(child: Container(
    color: const Color(0xFFF3F2FF), padding: const EdgeInsets.symmetric(vertical: 40),
    child: MarketplaceWidth(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      LayoutBuilder(builder: (context, c) => Wrap(spacing: 32, runSpacing: 32, alignment: WrapAlignment.spaceBetween, children: [
        SizedBox(width: c.maxWidth < 350 ? c.maxWidth : 350, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          MarketplaceLogo(onTap: onLogo), const SizedBox(height: 20),
          const Text('The multi-vendor marketplace connecting verified independent artisans, technology providers, and premium storefronts with unified logistics and split fulfillment.',
            style: TextStyle(fontSize: 14, height: 1.5, color: marketplaceMuted)),
          const SizedBox(height: 16), Wrap(spacing: 12, children: [
            for (final icon in [Icons.language, Icons.mail_outline, Icons.description_outlined, Icons.chat_bubble_outline])
              CircleAvatar(radius: 16, backgroundColor: const Color(0xFFDEE2FF), child: Icon(icon, size: 17, color: marketplaceMuted)),
          ]),
        ])),
        _group('Marketplace', [
          _entry('Explore Products', onExplore ?? () => marketplaceBrowse(context, 'catalog')),
          _entry('Stores Directory', onStores ?? () => marketplaceBrowse(context, 'stores')),
          _entry('Daily Flash Deals', onDeals ?? () => marketplaceBrowse(context, 'deals')),
          _entry('Track Multi-Order', () => marketplaceNotice(context, 'Track Multi-Order')),
        ]),
        _group('Seller Hub', [
          for (final label in ['Apply as Vendor', 'Merchant Portal', 'Fulfillment & APIs', 'Payout Guarantees'])
            _entry(label, onVendor ?? () => marketplaceNotice(context, label)),
        ]),
        SizedBox(width: c.maxWidth < 350 ? c.maxWidth : 350, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Security & Guarantee', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)), const SizedBox(height: 16),
          Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('◈  Decentralized Escrow Shield', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)), SizedBox(height: 6),
              Text('Payments are held secure until each individual vendor confirms dispatch and tracking delivery is stamped.',
                style: TextStyle(fontSize: 11, color: marketplaceMuted, height: 1.4)),
            ])), const SizedBox(height: 16),
          Wrap(spacing: 6, runSpacing: 6, children: [for (final label in ['Visa / MC', 'Apple Pay', 'Stripe Connect', 'USDC Escrow'])
            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5), color: const Color(0xFFE4E6FF),
              child: Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600)))]),
        ])),
      ])), const SizedBox(height: 64),
      Wrap(spacing: 60, runSpacing: 16, alignment: WrapAlignment.spaceBetween, children: [
        Text('© ${DateTime.now().year} EzyOrder. All rights reserved.', style: const TextStyle(fontSize: 10, color: marketplaceMuted)),
        Wrap(spacing: 24, runSpacing: 8, children: [
          _entry('Terms of Commerce', onTerms ?? () => marketplaceNotice(context, 'Terms of Commerce'), small: true),
          _entry('Privacy & Data Rights', onPrivacy ?? () => marketplaceNotice(context, 'Privacy & Data Rights'), small: true),
          _entry('Vendor Dispute Resolution', onDisputes ?? () => marketplaceNotice(context, 'Vendor Dispute Resolution'), small: true),
        ]),
      ]),
    ]))));

  Widget _group(String title, List<Widget> entries) => SizedBox(width: 160,
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      const SizedBox(height: 16), ...entries,
    ]));
  Widget _entry(String label, VoidCallback tap, {bool small = false}) => Padding(
    padding: EdgeInsets.only(bottom: small ? 0 : 12), child: InkWell(onTap: tap,
      child: Text(label, style: TextStyle(fontSize: small ? 11 : 14, color: marketplaceMuted))));
}
