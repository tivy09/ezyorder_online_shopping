# EzyOrder Online Shopping — Home page

Flutter translation of the supplied marketplace HTML. Keeps the indigo palette,
dark editorial hero, merchant cards, bundle promotion, desktop filter sidebar,
product cards, commerce information, and footer. Branding is EzyOrder and sample
prices are displayed in RM (original numeric values retained, not converted).

## Run 

- flutter run -d web-server --release --web-hostname=0.0.0.0 --web-port=8080
- flutter run -d web-server --web-hostname=0.0.0.0 --web-port=8080 

## Install into your project

From the root of your existing ezyorder_online_shopping project:

```cmd
flutter pub add stacked
```

Copy this package's `lib/ui/views/home` folder into your project's `lib/ui/views`.
Use the included `lib/main.dart` for a fresh project. If you already have an app
and router, preserve them and route to `const HomeView()` instead:

```dart
import 'ui/views/home/home_view.dart';
// MaterialApp:
home: const HomeView(),
```

Then run:

```cmd
dart format lib
flutter analyze
flutter run -d chrome
```

This is a source overlay, not a complete `flutter create` project. If needed:

```cmd
flutter create --platforms=web --project-name ezyorder_online_shopping ezyorder_online_shopping
cd ezyorder_online_shopping
flutter pub add stacked
```

Requires Dart 3 for records used in the commerce information section.
No generated Stacked services, routes, assets declarations, or build_runner needed.

## Included files

- lib/main.dart — demo app and theme
- lib/ui/views/home/home_view.dart — responsive home page
- lib/ui/views/home/home_viewmodel.dart — Stacked state, models, and sample data

## Working demo interactions

- Search by product or merchant; search updates immediately
- Category, vendor, maximum price, minimum rating, and 24-hour dispatch filters
- Sort by rating or price; newest uses the sample catalogue's supplied order
- Toggle favourites and view favourites from the header
- Add products to bag up to sample stock quantities
- Bag sheet with quantity controls and computed total
- Clear filters, empty search state, back to top, and section navigation
- Image loading and failure placeholders

## Responsive behavior

- Below 600 px: search below brand/actions; filter bottom sheet
- 600–1099 px: search in header; filter bottom sheet
- 1100 px and wider: desktop sidebar and expanded header
- Content capped at 1280 px including outer padding, as in the supplied reference
- Vendor and product columns adapt to their actual available space
- Single CustomScrollView; no SingleChildScrollView

## Deliberate demo boundaries

Sample merchant, rating, stock, and product data are in the ViewModel. State lives
only for this page instance. No API, authentication, payment, vendor verification,
shipping guarantee, persistence, or production checkout is implemented. Bundle
promotion is labelled coming soon; no fake bundle checkout or countdown is shown.
Hero is one static editorial panel because the supplied HTML contains one slide.
Pagination is omitted for the six-item sample catalogue. Product detail routes
and seller onboarding are not included. No production protection claims are made.

Images reuse the supplied HTML's external Google-hosted URLs. Availability and
Flutter Web browser CORS behavior have not been verified here. For deployment,
replace URLs with owned assets or a configured image CDN. No additional font
package is required; Flutter's default font is used instead of the HTML web fonts.

## Validation status / checklist

Flutter/Dart SDK are unavailable in the generation environment. The source has
not been compiled, analyzed, or visually rendered here. Run the commands above
and check browser widths 360, 390, 600, 768, 1024, 1280, and 1440 px. Verify:

1. Search and combined filters, then clear filters.
2. Each sort order and the empty result state.
3. Toggle favourites and switch favourites-only mode off again.
4. Add the knife twice: the second addition must hit the stock limit.
5. Remove quantities in the bag; verify count and total update.
6. Open mobile filters, change values, close and reopen.
7. Block image requests and confirm placeholders.
8. Increase browser text size and inspect wrapping and horizontal overflow.

`DropdownButtonFormField.value` is retained for compatibility; newer Flutter
versions may report a deprecation notice. Migrate to `initialValue` if your SDK
requires it, ensuring programmatic selection updates still rebuild correctly.
