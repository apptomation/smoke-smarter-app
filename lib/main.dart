import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smoke_smarter_app/core/router/app_router.dart';
import 'package:smoke_smarter_app/core/theme/app_theme.dart';

void main() {
  runApp(const ProviderScope(child: SmokeSmarterApp()));
}

class SmokeSmarterApp extends StatelessWidget {
  const SmokeSmarterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Smoke Smarter',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: appRouter,
    );
  }
}
