import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/app_routes.dart';
import 'auth_viewmodel.dart';

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

  @override
  void initState() {
    super.initState();
    model = AuthViewModel(
      initialMode: widget.initialMode,
      signInAction: widget.signInAction,
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
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: _border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: _primaryContainer, width: 1.5),
          ),
          errorMaxLines: 3,
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: _primaryContainer,
            foregroundColor: Colors.white,
            minimumSize: const Size(0, 52),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
                  final desktop = constraints.maxWidth >= 1024;
                  final mobile = constraints.maxWidth < 768;
                  return CustomScrollView(
                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                    slivers: [
                      SliverToBoxAdapter(child: _header(mobile)),
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Column(
                          children: [
                            Expanded(
                              child: Center(
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(maxWidth: 1200),
                                  child: Padding(
                                    padding: EdgeInsets.fromLTRB(
                                      mobile ? 16 : 32, 24, mobile ? 16 : 32, 40,
                                    ),
                                    child: desktop
                                        ? Row(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Expanded(child: _story()),
                                              const SizedBox(width: 64),
                                              Expanded(child: _formCard(mobile)),
                                            ],
                                          )
                                        : Center(
                                            child: ConstrainedBox(
                                              constraints: const BoxConstraints(maxWidth: 520),
                                              child: _formCard(mobile),
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                            ),
                            _footer(mobile),
                          ],
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

  Widget _header(bool mobile) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 1440),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: mobile ? 16 : 32, vertical: 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 10),
              const Text('EzyOrder', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -.6)),
            ]),
              TextButton.icon(
                onPressed: model.busy ? null : _back,
                icon: const Icon(Icons.arrow_back, size: 16),
                label: Text(mobile ? 'Shop' : 'Back to shopping'),
              ),
          ],
        ),
      ),
    ),
  );

  Widget _story() => Container(
    padding: const EdgeInsets.all(40),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(24),
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF252148), Color(0xFF3525CD), Color(0xFF665AE8)],
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .12),
            borderRadius: BorderRadius.circular(99),
            border: Border.all(color: Colors.white.withValues(alpha: .18)),
          ),
          child: const Text('INDEPENDENT STORES. ENDLESS FINDS.',
            style: TextStyle(color: Color(0xFFE2DFFF), fontSize: 10, letterSpacing: 1.1, fontWeight: FontWeight.w700)),
        ),
        const SizedBox(height: 32),
        const Text('Good finds.\nGreat connections.',
          style: TextStyle(fontSize: 44, height: 1.15, letterSpacing: -1.3, fontWeight: FontWeight.w800, color: Colors.white)),
        const SizedBox(height: 20),
        const Text('Your favorite stores, thoughtful creations, and everyday essentials — together in one place.',
          style: TextStyle(fontSize: 16, height: 1.65, color: Color(0xFFDAD7FF))),
        const SizedBox(height: 36),
        _benefit(Icons.storefront_outlined, 'Discover something different', 'Explore products from independent stores.'),
        const SizedBox(height: 24),
        _benefit(Icons.favorite_border, 'Keep your favorites close', 'Save the finds you want to come back to.'),
        const SizedBox(height: 24),
        _benefit(Icons.inventory_2_outlined, 'Make shopping simpler', 'Keep your orders together in your account.'),
        const SizedBox(height: 40),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .10),
            border: Border.all(color: Colors.white.withValues(alpha: .15)),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Row(children: [
            Icon(Icons.auto_awesome, color: Color(0xFFFFDDB8), size: 28),
            SizedBox(width: 16),
            Expanded(child: Text('A little discovery.\nSomething to make your day.',
              style: TextStyle(color: Colors.white, fontSize: 14, height: 1.6))),
          ]),
        ),
      ],
    ),
  );

  Widget _benefit(IconData icon, String title, String description) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: .12), borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, size: 21, color: const Color(0xFFE2DFFF)),
      ),
      const SizedBox(width: 16),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
        const SizedBox(height: 5),
        Text(description, style: const TextStyle(color: Color(0xFFDAD7FF), fontSize: 13, height: 1.5)),
      ])),
    ],
  );

  Widget _formCard(bool mobile) => Container(
    padding: EdgeInsets.all(mobile ? 24 : 32),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: _border),
      boxShadow: [BoxShadow(color: _ink.withValues(alpha: .04), blurRadius: 28, offset: const Offset(0, 8))],
    ),
    child: AutofillGroup(
      child: Form(
        key: _formKey,
        autovalidateMode: _validate ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFFEEEDFF), borderRadius: BorderRadius.circular(12)),
                child: Icon(model.isReset ? Icons.lock_reset : model.isRegister ? Icons.person_add_alt : Icons.waving_hand_outlined,
                  color: _primaryContainer, size: 26),
              ),
            ),
            const SizedBox(height: 24),
            Text(model.title, style: TextStyle(fontSize: mobile ? 28 : 32, height: 1.25, fontWeight: FontWeight.w700, letterSpacing: -.8)),
            const SizedBox(height: 12),
            Text(model.subtitle, style: const TextStyle(fontSize: 14, color: _muted, height: 1.6)),
            const SizedBox(height: 24),
            if (!model.isReset) ...[
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: const Color(0xFFF2F3FF), borderRadius: BorderRadius.circular(10)),
                child: Row(children: [
                  _tab('Sign in', AuthMode.signIn),
                  _tab('Create account', AuthMode.register),
                ]),
              ),
              const SizedBox(height: 24),
            ],
            if (model.isRegister) ...[
              _field(
                label: 'Full name', hint: 'Your full name', controller: _name,
                icon: Icons.person_outline, autofillHints: const [AutofillHints.name],
                validator: AuthViewModel.validateName,
              ),
              const SizedBox(height: 20),
            ],
            _field(
              label: 'Email address', hint: 'you@example.com', controller: _email,
              icon: Icons.mail_outline, keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email], validator: AuthViewModel.validateEmail,
              last: model.isReset,
            ),
            if (!model.isReset) ...[
              const SizedBox(height: 20),
              _field(
                label: 'Password', hint: model.isRegister ? 'Create a password' : 'Enter your password',
                controller: _password, icon: Icons.lock_outline,
                obscure: model.hidePassword, passwordField: true,
                autofillHints: [model.isRegister ? AutofillHints.newPassword : AutofillHints.password],
                validator: model.validatePassword,
                last: !model.isRegister,
                suffix: IconButton(
                  tooltip: model.hidePassword ? 'Show password' : 'Hide password',
                  onPressed: model.togglePassword,
                  icon: Icon(model.hidePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 20),
                ),
              ),
              if (model.isRegister) ...[
                const SizedBox(height: 8),
                const Text('Use at least 8 characters.', style: TextStyle(color: _muted, fontSize: 12)),
                const SizedBox(height: 20),
                _field(
                  label: 'Confirm password', hint: 'Re-enter your password',
                  controller: _confirmation, icon: Icons.lock_outline,
                  obscure: model.hideConfirmation, passwordField: true, last: true,
                  validator: (value) => value == null || value.isEmpty
                      ? 'Confirm your password.'
                      : value != _password.text ? 'Passwords do not match.' : null,
                  suffix: IconButton(
                    tooltip: model.hideConfirmation ? 'Show confirmation' : 'Hide confirmation',
                    onPressed: model.toggleConfirmation,
                    icon: Icon(model.hideConfirmation ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 20),
                  ),
                ),
                const SizedBox(height: 16),
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Checkbox(
                    value: model.acceptedTerms,
                    onChanged: model.busy ? null : (value) => model.setAcceptedTerms(value ?? false),
                  ),
                  Expanded(child: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Wrap(crossAxisAlignment: WrapCrossAlignment.center, children: [
                      const Text('I agree to the ', style: TextStyle(fontSize: 12, color: _muted)),
                      _legalLink('Terms of Service', widget.onTerms),
                      const Text(' and ', style: TextStyle(fontSize: 12, color: _muted)),
                      _legalLink('Privacy Policy', widget.onPrivacy),
                      const Text('.', style: TextStyle(fontSize: 12, color: _muted)),
                    ]),
                  )),
                ]),
              ] else
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: model.busy ? null : () => _changeMode(AuthMode.resetPassword),
                    child: const Text('Forgot password?', style: TextStyle(fontSize: 13)),
                  ),
                ),
            ],
            const SizedBox(height: 20),
            if (model.error != null) ...[_message(model.error!, isError: true), const SizedBox(height: 16)],
            if (model.notice != null) ...[_message(model.notice!), const SizedBox(height: 16)],
            FilledButton(
              onPressed: model.busy ? null : _submit,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: model.busy
                    ? const SizedBox(width: 22, height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2, color: _primaryContainer))
                    : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Flexible(child: Text(model.buttonLabel, style: const TextStyle(fontWeight: FontWeight.w600))),
                        const SizedBox(width: 12), const Icon(Icons.arrow_forward, size: 18),
                      ]),
              ),
            ),
            const SizedBox(height: 20),
            Wrap(alignment: WrapAlignment.center, crossAxisAlignment: WrapCrossAlignment.center, children: [
              Text(model.isReset ? 'Remember your password?' : model.isRegister ? 'Already have an account?' : 'New to EzyOrder?',
                style: const TextStyle(color: _muted, fontSize: 13)),
              TextButton(
                onPressed: model.busy ? null : () => _changeMode(model.isRegister || model.isReset ? AuthMode.signIn : AuthMode.register),
                child: Text(model.isRegister || model.isReset ? 'Sign in' : 'Create an account', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              ),
            ]),
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
      child: Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
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
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
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
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(isError ? Icons.error_outline : Icons.check_circle_outline,
          size: 18, color: isError ? const Color(0xFFBA1A1A) : const Color(0xFF047857)),
        const SizedBox(width: 10),
        Expanded(child: Text(message, style: TextStyle(fontSize: 13, height: 1.5,
          color: isError ? const Color(0xFFBA1A1A) : const Color(0xFF047857)))),
      ]),
    ),
  );

  Widget _legalLink(String label, VoidCallback? action) => InkWell(
    onTap: () {
      if (action != null) {
        action();
      } else {
        _showMessage(label, 'This policy is not available yet. Please contact EzyOrder support.');
      }
    },
    borderRadius: BorderRadius.circular(4),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(label, style: const TextStyle(fontSize: 12, color: _primary, fontWeight: FontWeight.w600)),
    ),
  );

  Widget _footer(bool mobile) => Padding(
    padding: EdgeInsets.symmetric(horizontal: mobile ? 16 : 32, vertical: 24),
    child: Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 24,
      runSpacing: 8,
      children: [
        Text('© ${DateTime.now().year} EzyOrder. All rights reserved.', style: const TextStyle(fontSize: 12, color: _muted)),
        _legalLink('Privacy Policy', widget.onPrivacy),
        _legalLink('Terms of Service', widget.onTerms),
      ],
    ),
  );
}
