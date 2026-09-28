import 'package:baseline/router/app_router.dart';
import 'package:baseline/theme/baseline_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BaselineApp extends ConsumerWidget {
  const BaselineApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'Baseline',
      theme: buildBaselineTheme(),
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        final media = MediaQuery.of(context);
        // Keep the system text scale. Do not clamp it.
        return MediaQuery(
          data: media.copyWith(textScaler: media.textScaler),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
