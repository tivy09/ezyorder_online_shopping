import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/app_routes.dart';
import 'auth_viewmodel.dart';
import '../../component/toolbox/app_header.dart';
import '../../component/toolbox/app_footer.dart';

const _primary = Color(0xFF3525CD);
const _primaryContainer = Color(0xFF4F46E5);
const _canvas = Color(0xFFFAF8FF);
const _ink = Color(0xFF131B2E);
const _muted = Color(0xFF64748B);
const _border = Color(0xFFE2E8F0);

class AuthView extends StatefulWidget {
  const AuthView({
    super.key,
    this.initialMode = AuthMode.signIn,
    this.signInAction,
    this.registerAction,
    this.resetPasswordAction,
    this.onSignedIn,
    this.onRegistered,
    this.onBackToShop,
    this.onTerms,
    this.onPrivacy,
    this.signInWithPersistenceAction,
    this.onSocialSignIn,
    this.onGuestCheckout,
    this.onVendorPortal,
  });

  final AuthMode initialMode;
  final SignInAction? signInAction;
  final RegisterAction? registerAction;
  final ResetPasswordAction? resetPasswordAction;
  final VoidCallback? onSignedIn;
  final VoidCallback? onRegistered;
  final VoidCallback? onBackToShop;
  final VoidCallback? onTerms;
  final VoidCallback? onPrivacy;
  final Future<void> Function(String email, String password, bool staySignedIn)?
  signInWithPersistenceAction;
  final void Function(String provider)? onSocialSignIn;
  final VoidCallback? onGuestCheckout;
  final VoidCallback? onVendorPortal;

  @override
  State<AuthView> createState() => _AuthViewState();
}

class _AuthViewState extends State<AuthView> {
  late final AuthViewModel model;
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmation = TextEditingController();
  bool _validate = false;
  bool _staySignedIn = true;

  @override
  void initState() {
    super.initState();
    model = AuthViewModel(
      initialMode: widget.initialMode,
      signInAction: widget.signInWithPersistenceAction == null
          ? widget.signInAction
          : (email, password) => widget.signInWithPersistenceAction!(
              email,
              password,
              _staySignedIn,
            ),
      registerAction: widget.registerAction,
      resetPasswordAction: widget.resetPasswordAction,
    );
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirmation.dispose();
    model.dispose();
    super.dispose();
  }

  void _changeMode(AuthMode mode) {
    if (model.busy) return;
    FocusScope.of(context).unfocus();
    final routeName = switch (mode) {
      AuthMode.signIn => AppRoutes.auth,
      AuthMode.register => AppRoutes.register,
      AuthMode.resetPassword => AppRoutes.forgotPassword,
    };
    context.goNamed(routeName);
  }

  Future<void> _submit() async {
    if (model.busy) return;
    setState(() => _validate = true);
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    final submittedMode = model.mode;
    final success = await model.submit(
      name: _name.text,
      email: _email.text,
      password: _password.text,
    );
    if (!mounted || !success) return;
    setState(() => _validate = false);
    _password.clear();
    _confirmation.clear();
    if (submittedMode == AuthMode.signIn) {
      if (widget.onSignedIn != null) {
        widget.onSignedIn!();
      } else {
        context.goNamed(AppRoutes.home);
      }
    } else if (submittedMode == AuthMode.register) {
      widget.onRegistered?.call();
    }
  }

  void _back() {
    if (model.busy) return;
    if (widget.onBackToShop != null) {
      widget.onBackToShop!();
    } else {
      context.goNamed(AppRoutes.home);
    }
  }

  void _showMessage(String title, String message) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => ctx.pop(), child: const Text('Close')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context);
    return Theme(
      data: base.copyWith(
        scaffoldBackgroundColor: _canvas,
        colorScheme: ColorScheme.fromSeed(seedColor: _primary).copyWith(
          primary: _primary,
          onPrimary: Colors.white,
          surface: Colors.white,
          onSurface: _ink,
        ),
        textTheme: base.textTheme.apply(bodyColor: _ink, displayColor: _ink),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF3F2FF),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
          hintStyle: const TextStyle(color: _muted, fontSize: 14),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: _primary, width: 1.5),
          ),
          errorMaxLines: 3,
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: _primary,
            foregroundColor: Colors.white,
            minimumSize: const Size(0, 44),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      child: AnimatedBuilder(
        animation: model,
        builder: (context, _) => PopScope(
          canPop: !model.busy,
          child: Scaffold(
            body: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final mobile = constraints.maxWidth < 768;
                  final desktop = constraints.maxWidth >= 1024;
                  return CustomScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    slivers: [
                      SliverToBoxAdapter(
                        child: RepaintBoundary(
                          child: AppHeader(onVendor: _vendor, onLogo: _back),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: _width(
                          Padding(
                            padding: const EdgeInsets.only(top: 48, bottom: 40),
                            child: desktop
                                ? Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: RepaintBoundary(child: _story()),
                                      ),
                                      const SizedBox(width: 24),
                                      Expanded(child: _formCard(false)),
                                    ],
                                  )
                                : Column(
                                    children: [
                                      _formCard(mobile),
                                      const SizedBox(height: 24),
                                      RepaintBoundary(child: _story()),
                                    ],
                                  ),
                          ),
                          mobile,
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: _width(
                          RepaintBoundary(child: _trending()),
                          mobile,
                        ),
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: 80)),
                      SliverToBoxAdapter(
                        child: RepaintBoundary(
                          child: AppFooter(
                            onVendor: _vendor,
                            onTerms: widget.onTerms,
                            onPrivacy: widget.onPrivacy,
                            onLogo: _back,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _width(Widget child, bool mobile) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 1280),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: mobile ? 16 : 32),
        child: child,
      ),
    ),
  );

  Widget _caption(String text, {Color color = _muted}) => Text(
    text,
    style: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      letterSpacing: .5,
      color: color,
    ),
  );

  Widget _link(String text, VoidCallback tap) => InkWell(
    onTap: model.busy ? null : tap,
    borderRadius: BorderRadius.circular(4),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          color: _primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );

  void _vendor() {
    if (widget.onVendorPortal != null) {
      widget.onVendorPortal!();
    } else {
      _showMessage('Vendor portal', 'The vendor portal is not available yet.');
    }
  }

  Widget _story() => Container(
    padding: EdgeInsets.all(MediaQuery.sizeOf(context).width < 768 ? 24 : 40),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(14),
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFE6E4FF), Color(0xFFF3F2FF), Color(0xFFF7EBE4)],
        stops: [0, .7, 1],
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              child: _caption('● UNIVERSAL BUYER SHIELD', color: _primary),
            ),
            const Text(
              'v4.8 Decentralized Auth',
              style: TextStyle(fontSize: 11, color: _muted),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const Text(
          'One passport for',
          style: TextStyle(
            fontSize: 32,
            height: 1.3,
            fontWeight: FontWeight.w700,
            letterSpacing: -1,
          ),
        ),
        const Text(
          '450+ verified',
          style: TextStyle(
            fontSize: 48,
            height: 1.25,
            fontWeight: FontWeight.w800,
            color: _primary,
            letterSpacing: -1.5,
          ),
        ),
        const Text(
          'independent makers.',
          style: TextStyle(
            fontSize: 32,
            height: 1.3,
            fontWeight: FontWeight.w700,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Shop across diverse studios, artisan tech fabricators, and boutique workshops in a single cart. Unified checkout with escrow logistics and synchronized multi-carrier tracking.',
          style: TextStyle(
            fontSize: 16,
            height: 1.65,
            color: Color(0xFF464555),
          ),
        ),
        const SizedBox(height: 40),
        LayoutBuilder(
          builder: (context, c) {
            final narrow = c.maxWidth < 400;
            final first = _benefit(
              Icons.call_split,
              'AUTOMATED',
              'Split-Order Logistics',
              'Independent dispatch schedules tracked seamlessly under one unified receipt.',
            );
            final second = _benefit(
              Icons.verified_user,
              '100% Insured',
              'Smart Escrow Release',
              'Funds are guarded and dispersed only upon confirmed carrier delivery milestones.',
            );
            return narrow
                ? Column(children: [first, const SizedBox(height: 16), second])
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: first),
                      const SizedBox(width: 16),
                      Expanded(child: second),
                    ],
                  );
          },
        ),
        const SizedBox(height: 56),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: Color(0xFFF1E3CE),
                    child: Text(
                      'ML',
                      style: TextStyle(color: Color(0xFF855300)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Maya Lindqvist ✿',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Verified Collector • 34 multi-store orders',
                          style: TextStyle(fontSize: 10, color: _muted),
                        ),
                      ],
                    ),
                  ),
                  const Text(
                    '★★★★★',
                    style: TextStyle(color: Color(0xFF855300), fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                '“Consolidating ceramic orders from Kyoto and custom keyboards from Zurich into one single payment without exchange fees transformed how I discover makers.”',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  fontSize: 14,
                  height: 1.5,
                  color: Color(0xFF464555),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 10,
          children: [
            _tinyIcon(Icons.local_shipping_outlined, 'Avg. Dispatch: 18 Hours'),
            _tinyIcon(Icons.lock_outline, 'End-to-End Escrowed'),
            _tinyIcon(Icons.currency_exchange, '0% Split Surcharges'),
          ],
        ),
      ],
    ),
  );

  Widget _benefit(IconData icon, String badge, String title, String body) =>
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E5FF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 20, color: _primary),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    badge,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 10,
                      color: _muted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                letterSpacing: -.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              body,
              style: const TextStyle(
                fontSize: 14,
                height: 1.45,
                color: Color(0xFF464555),
              ),
            ),
          ],
        ),
      );

  Widget _tinyIcon(IconData icon, String text) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 14, color: _primary),
      const SizedBox(width: 5),
      Flexible(
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 10,
            color: _muted,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ],
  );

  Widget _social(String name, Widget icon) => Expanded(
    child: TextButton(
      style: TextButton.styleFrom(
        backgroundColor: const Color(0xFFF3F2FF),
        foregroundColor: _ink,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: model.busy
          ? null
          : () {
              if (widget.onSocialSignIn != null) {
                widget.onSocialSignIn!(name.toLowerCase());
              } else {
                _showMessage(
                  '$name sign in',
                  '$name sign in is not available yet. Please use email when account access is enabled.',
                );
              }
            },
      child: Wrap(
        spacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        alignment: WrapAlignment.center,
        children: [
          icon,
          Text(
            name,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    ),
  );

  Widget _trending() => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: _border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          spacing: 32,
          runSpacing: 12,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _caption('NOW TRENDING ACROSS STOREFRONTS', color: _primary),
                const SizedBox(height: 8),
                const Text(
                  'Popular multi-vendor picks ready to bundle',
                  style: TextStyle(fontSize: 21, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            _link('Explore 450+ Studios →', _back),
          ],
        ),
        const SizedBox(height: 24),
        LayoutBuilder(
          builder: (context, c) {
            final columns = c.maxWidth >= 900
                ? 4
                : c.maxWidth >= 500
                ? 2
                : 1;
            const items = [
              [
                'Nordic Keys',
                'Nordic Split 65% Mechanical Board',
                '189.00',
                '4.9',
                '184',
                'Free unified ship',
                'photo-1587829741301-dc798b83add3',
              ],
              [
                'Kanso Ceramics',
                'Speckled Stoneware Dripper Set',
                '64.00',
                '5.0',
                '92',
                'Ships from Kyoto',
                'photo-1495474472287-4d71bcdd2085',
              ],
              [
                'Atelier Bastion',
                'Field Day Roll-Top Canvas 22L',
                '145.00',
                '4.8',
                '310',
                'Split-ready',
                'photo-1553062407-98eeb64c6a62',
              ],
              [
                'Lumen Workshop',
                'Milled Brass Kinetic Reading Lamp',
                '230.00',
                '4.9',
                '64',
                'Low stock (3)',
                'photo-1507473885765-e6ed057f782c',
              ],
            ];
            return Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                for (final p in items)
                  SizedBox(
                    width: (c.maxWidth - (columns - 1) * 16) / columns,
                    child: InkWell(
                      onTap: () => _showMessage(
                        p[1],
                        'By ${p[0]} · RM ${p[2]}. This is a demo product. Browse the shop for available items.',
                      ),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F2FF),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AspectRatio(
                              aspectRatio: 1,
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      'https://images.unsplash.com/${p[6]}?auto=format&fit=crop&w=600&q=75',
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, _, _) =>
                                          const ColoredBox(
                                            color: Color(0xFFE6E3DE),
                                            child: Center(
                                              child: Icon(
                                                Icons.image_outlined,
                                                color: _muted,
                                              ),
                                            ),
                                          ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 8,
                                    left: 8,
                                    right: 8,
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: Text(
                                          p[0],
                                          style: const TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '★ ${p[3]} (${p[4]})',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF855300),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              p[1],
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 18,
                                height: 1.35,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 16,
                              runSpacing: 5,
                              children: [
                                Text(
                                  'RM ${p[2]}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  p[5],
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: _primary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    ),
  );

  Widget _formCard(bool mobile) => Container(
    padding: EdgeInsets.all(mobile ? 20 : 40),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: _border),
      boxShadow: [
        BoxShadow(
          color: _ink.withValues(alpha: .04),
          blurRadius: 28,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: AutofillGroup(
      child: Form(
        key: _formKey,
        autovalidateMode: _validate
            ? AutovalidateMode.onUserInteraction
            : AutovalidateMode.disabled,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              spacing: 16,
              runSpacing: 12,
              children: [
                _caption('ACCOUNT PORTAL'),
                _link('Are you a seller? Vendor Portal →', _vendor),
              ],
            ),
            const SizedBox(height: 32),
            if (model.isReset) ...[
              Text(
                model.title,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                model.subtitle,
                style: const TextStyle(color: _muted, height: 1.5),
              ),
              const SizedBox(height: 24),
            ],
            if (!model.isReset) ...[
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F3FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    _tab('Sign in', AuthMode.signIn),
                    _tab('Create account', AuthMode.register),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
            if (!model.isReset) ...[
              Row(
                children: [
                  _social(
                    'Google',
                    const Text(
                      'G',
                      style: TextStyle(
                        color: Color(0xFF4285F4),
                        fontWeight: FontWeight.w800,
                        fontSize: 17,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _social('Apple', const Icon(Icons.apple, size: 17)),
                  const SizedBox(width: 8),
                  _social('GitHub', const Icon(Icons.code, size: 17)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Expanded(child: Divider(color: _border)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: _caption('OR CONTINUE WITH EMAIL'),
                  ),
                  const Expanded(child: Divider(color: _border)),
                ],
              ),
              const SizedBox(height: 12),
            ],
            if (model.isRegister) ...[
              _field(
                label: 'Full name',
                hint: 'Your full name',
                controller: _name,
                icon: Icons.person_outline,
                autofillHints: const [AutofillHints.name],
                validator: AuthViewModel.validateName,
              ),
              const SizedBox(height: 20),
            ],
            _field(
              label: 'Email address',
              hint: 'you@example.com',
              controller: _email,
              icon: Icons.mail_outline,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              validator: AuthViewModel.validateEmail,
              last: model.isReset,
            ),
            if (!model.isReset) ...[
              const SizedBox(height: 20),
              _field(
                labelAction: model.isRegister
                    ? null
                    : _link(
                        'Forgot password?',
                        () => _changeMode(AuthMode.resetPassword),
                      ),
                label: 'Password',
                hint: model.isRegister
                    ? 'Create a password'
                    : 'Enter your password',
                controller: _password,
                icon: Icons.lock_outline,
                obscure: model.hidePassword,
                passwordField: true,
                autofillHints: [
                  model.isRegister
                      ? AutofillHints.newPassword
                      : AutofillHints.password,
                ],
                validator: model.validatePassword,
                last: !model.isRegister,
                suffix: IconButton(
                  tooltip: model.hidePassword
                      ? 'Show password'
                      : 'Hide password',
                  onPressed: model.togglePassword,
                  icon: Icon(
                    model.hidePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    size: 20,
                  ),
                ),
              ),
              if (model.isRegister) ...[
                const SizedBox(height: 8),
                const Text(
                  'Use at least 8 characters.',
                  style: TextStyle(color: _muted, fontSize: 12),
                ),
                const SizedBox(height: 20),
                _field(
                  label: 'Confirm password',
                  hint: 'Re-enter your password',
                  controller: _confirmation,
                  icon: Icons.lock_outline,
                  obscure: model.hideConfirmation,
                  passwordField: true,
                  last: true,
                  validator: (value) => value == null || value.isEmpty
                      ? 'Confirm your password.'
                      : value != _password.text
                      ? 'Passwords do not match.'
                      : null,
                  suffix: IconButton(
                    tooltip: model.hideConfirmation
                        ? 'Show confirmation'
                        : 'Hide confirmation',
                    onPressed: model.toggleConfirmation,
                    icon: Icon(
                      model.hideConfirmation
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: model.acceptedTerms,
                      onChanged: model.busy
                          ? null
                          : (value) => model.setAcceptedTerms(value ?? false),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            const Text(
                              'I agree to the ',
                              style: TextStyle(fontSize: 12, color: _muted),
                            ),
                            _legalLink('Terms of Service', widget.onTerms),
                            const Text(
                              ' and ',
                              style: TextStyle(fontSize: 12, color: _muted),
                            ),
                            _legalLink('Privacy Policy', widget.onPrivacy),
                            const Text(
                              '.',
                              style: TextStyle(fontSize: 12, color: _muted),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    SizedBox(
                      width: 24,
                      child: Checkbox(
                        value: _staySignedIn,
                        onChanged: model.busy
                            ? null
                            : (v) => setState(() => _staySignedIn = v ?? false),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Stay signed in on this device',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ],
            ],
            const SizedBox(height: 20),
            if (model.error != null) ...[
              _message(model.error!, isError: true),
              const SizedBox(height: 16),
            ],
            if (model.notice != null) ...[
              _message(model.notice!),
              const SizedBox(height: 16),
            ],
            FilledButton(
              onPressed: model.busy ? null : _submit,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: model.busy
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: _primaryContainer,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              model.mode == AuthMode.signIn
                                  ? 'Sign In to EzyOrder'
                                  : model.buttonLabel,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Icon(Icons.arrow_forward, size: 18),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 16),
            if (!model.isReset)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F7FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Purchasing items without saving payment profiles?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: _muted,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: model.busy
                          ? null
                          : () => widget.onGuestCheckout != null
                                ? widget.onGuestCheckout!()
                                : _showMessage(
                                    'Guest checkout',
                                    'Guest checkout is not available yet. You can continue browsing the shop.',
                                  ),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: _ink,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: const Icon(
                        Icons.bolt,
                        size: 18,
                        color: Color(0xFF855300),
                      ),
                      label: const Text(
                        'Instant Checkout as Guest',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            if (model.isReset)
              _link('← Back to sign in', () => _changeMode(AuthMode.signIn)),
            const SizedBox(height: 36),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 16,
              runSpacing: 8,
              children: [
                _tinyIcon(Icons.shield_outlined, 'Buyer account protection'),
                _tinyIcon(Icons.lock_outline, 'One account. More discoveries.'),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const Text(
                  'By proceeding, you agree to the EzyOrder ',
                  style: TextStyle(fontSize: 11, color: _muted),
                ),
                _legalLink('Terms of Commerce', widget.onTerms),
                const Text(
                  ' and acknowledge our ',
                  style: TextStyle(fontSize: 11, color: _muted),
                ),
                _legalLink('Privacy Policy.', widget.onPrivacy),
              ],
            ),
          ],
        ),
      ),
    ),
  );

  Widget _tab(String label, AuthMode mode) => Expanded(
    child: TextButton(
      onPressed: model.busy ? null : () => _changeMode(mode),
      style: TextButton.styleFrom(
        backgroundColor: model.mode == mode ? Colors.white : Colors.transparent,
        foregroundColor: model.mode == mode ? _primary : _muted,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
    ),
  );

  Widget _field({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    String? Function(String?)? validator,
    List<String>? autofillHints,
    TextInputType? keyboardType,
    bool obscure = false,
    bool passwordField = false,
    bool last = false,
    Widget? suffix,
    Widget? labelAction,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 13))),
          ?labelAction,
        ],
      ),
      const SizedBox(height: 8),
      TextFormField(
        controller: controller,
        enabled: !model.busy,
        obscureText: obscure,
        autocorrect: false,
        enableSuggestions: !passwordField,
        keyboardType: keyboardType,
        autofillHints: autofillHints,
        validator: validator,
        textInputAction: last ? TextInputAction.done : TextInputAction.next,
        onFieldSubmitted: last ? (_) => _submit() : null,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, size: 20, color: _muted),
          suffixIcon: suffix,
        ),
      ),
    ],
  );

  Widget _message(String message, {bool isError = false}) => Semantics(
    liveRegion: true,
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isError ? const Color(0xFFFFF1F2) : const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isError ? Icons.error_outline : Icons.check_circle_outline,
            size: 18,
            color: isError ? const Color(0xFFBA1A1A) : const Color(0xFF047857),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color: isError
                    ? const Color(0xFFBA1A1A)
                    : const Color(0xFF047857),
              ),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _legalLink(String label, VoidCallback? action) => InkWell(
    onTap: () {
      if (action != null) {
        action();
      } else {
        _showMessage(
          label,
          'This policy is not available yet. Please contact EzyOrder support.',
        );
      }
    },
    borderRadius: BorderRadius.circular(4),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          color: _primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );
}
