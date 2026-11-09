import 'package:flutter/foundation.dart';

enum AuthMode { signIn, register, resetPassword }

typedef SignInAction = Future<void> Function(String email, String password);
typedef RegisterAction = Future<void> Function(
  String name,
  String email,
  String password,
);
typedef ResetPasswordAction = Future<void> Function(String email);

/// Throw this from your API adapter with a safe, user-facing error message.
class AuthFailure implements Exception {
  const AuthFailure(this.message);
  final String message;
}

class AuthViewModel extends ChangeNotifier {
  AuthViewModel({
    this.signInAction,
    this.registerAction,
    this.resetPasswordAction,
    AuthMode initialMode = AuthMode.signIn,
  }) : mode = initialMode;

  final SignInAction? signInAction;
  final RegisterAction? registerAction;
  final ResetPasswordAction? resetPasswordAction;
  AuthMode mode;
  bool busy = false;
  bool hidePassword = true;
  bool hideConfirmation = true;
  bool acceptedTerms = false;
  String? error;
  String? notice;
  bool _disposed = false;

  bool get isRegister => mode == AuthMode.register;
  bool get isReset => mode == AuthMode.resetPassword;
  String get title => isReset
      ? 'Forgot your password?'
      : isRegister ? 'Create your account' : 'Welcome back.';
  String get subtitle => isReset
      ? 'Enter your email and we’ll help you get back to shopping.'
      : isRegister
          ? 'Discover independent stores. Find your next favorite.'
          : 'Sign in to your EzyOrder account and pick up where you left off.';
  String get buttonLabel => isReset
      ? 'Send reset link'
      : isRegister ? 'Create account' : 'Sign in';

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  void setMode(AuthMode value) {
    if (busy) return;
    mode = value;
    error = null;
    notice = null;
    acceptedTerms = false;
    hidePassword = true;
    hideConfirmation = true;
    _notify();
  }

  void togglePassword() {
    hidePassword = !hidePassword;
    _notify();
  }

  void toggleConfirmation() {
    hideConfirmation = !hideConfirmation;
    _notify();
  }

  void setAcceptedTerms(bool value) {
    acceptedTerms = value;
    error = null;
    _notify();
  }

  static String? validateName(String? value) {
    if ((value ?? '').trim().length < 2) return 'Enter your full name.';
    return null;
  }

  static String? validateEmail(String? value) {
    final email = (value ?? '').trim();
    if (email.isEmpty) return 'Enter your email address.';
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
      return 'Enter a valid email address.';
    }
    return null;
  }

  String? validatePassword(String? value) {
    final password = value ?? '';
    if (password.isEmpty) return 'Enter your password.';
    // Align this registration rule with your backend's password policy.
    if (isRegister && password.length < 8) {
      return 'Use at least 8 characters.';
    }
    return null;
  }

  /// True only after a supplied API callback completes successfully.
  Future<bool> submit({
    required String name,
    required String email,
    required String password,
  }) async {
    if (busy || _disposed) return false;
    error = null;
    notice = null;
    if (isRegister && !acceptedTerms) {
      error = 'Please accept the Terms of Service and Privacy Policy.';
      _notify();
      return false;
    }
    final configured = switch (mode) {
      AuthMode.signIn => signInAction != null,
      AuthMode.register => registerAction != null,
      AuthMode.resetPassword => resetPasswordAction != null,
    };
    if (!configured) {
      error = 'This action is not available yet. Please try again later.';
      _notify();
      return false;
    }
    busy = true;
    _notify();
    try {
      switch (mode) {
        case AuthMode.signIn:
          await signInAction!(email.trim(), password);
          break;
        case AuthMode.register:
          await registerAction!(name.trim(), email.trim(), password);
          notice = 'Your registration was submitted. Follow any verification instructions sent to your email.';
          break;
        case AuthMode.resetPassword:
          await resetPasswordAction!(email.trim());
          notice = 'If an account exists for this email, you’ll receive password reset instructions.';
          break;
      }
      return !_disposed;
    } on AuthFailure catch (failure) {
      error = failure.message;
      return false;
    } catch (_) {
      error = 'We couldn’t complete your request. Please try again.';
      return false;
    } finally {
      busy = false;
      _notify();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
