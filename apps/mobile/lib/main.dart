import 'package:baseline/app.dart';
import 'package:baseline/state/session_controller.dart';
import 'package:baseline/state/session_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final saved = await SessionStore.load();
  runApp(
    ProviderScope(
      overrides: [
        sessionProvider.overrideWith(() => SessionController(initial: saved)),
      ],
      child: const BaselineApp(),
    ),
  );
}
