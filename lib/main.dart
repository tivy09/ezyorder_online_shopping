import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import 'core/router/app_router.dart';

void main() => runApp(const EzyOrderApp());

class EzyOrderApp extends StatefulWidget {
  const EzyOrderApp({super.key});

  @override
  State<EzyOrderApp> createState() => _EzyOrderAppState();
}

class _EzyOrderAppState extends State<EzyOrderApp> {
  // Create once. Supply real auth API callbacks here when available.
  late final GoRouter _router = AppRouter.create();

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GetMaterialApp.router(
    title: 'EzyOrder • Discover Independent Stores',
    debugShowCheckedModeBanner: false,
    routeInformationProvider: _router.routeInformationProvider,
    routeInformationParser: _router.routeInformationParser,
    routerDelegate: _router.routerDelegate,
    backButtonDispatcher: _router.backButtonDispatcher,
    theme: ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFFF9F8FF),
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3925DF)),
      fontFamily: 'Roboto',
      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: Color(0xFF182138)),
      ),
    ),
  );
}
