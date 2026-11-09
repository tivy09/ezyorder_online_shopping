import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../page/auth/auth_view.dart';
import '../../page/auth/auth_viewmodel.dart';
import '../../page/home/home_view.dart';
import 'app_routes.dart';

abstract final class AppRouter {
  static GoRouter create({
    SignInAction? signInAction,
    RegisterAction? registerAction,
    ResetPasswordAction? resetPasswordAction,
  }) {
    Widget authPage(BuildContext context, GoRouterState state, AuthMode mode) {
      return AuthView(
        key: ValueKey(mode),
        initialMode: mode,
        signInAction: signInAction,
        registerAction: registerAction,
        resetPasswordAction: resetPasswordAction,
        onSignedIn: () => context.goNamed(AppRoutes.home),
        onBackToShop: () => context.goNamed(AppRoutes.home),
      );
    }

    return GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          name: AppRoutes.home,
          builder: (context, state) => const HomeView(),
        ),
        GoRoute(
          path: '/auth',
          name: AppRoutes.auth,
          builder: (context, state) =>
              authPage(context, state, AuthMode.signIn),
        ),
        GoRoute(
          path: '/auth/register',
          name: AppRoutes.register,
          builder: (context, state) =>
              authPage(context, state, AuthMode.register),
        ),
        GoRoute(
          path: '/auth/forgot-password',
          name: AppRoutes.forgotPassword,
          builder: (context, state) =>
              authPage(context, state, AuthMode.resetPassword),
        ),
      ],
      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Page not found', style: TextStyle(fontSize: 24)),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => context.goNamed(AppRoutes.home),
                child: const Text('Back to shopping'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
