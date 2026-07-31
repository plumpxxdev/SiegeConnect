import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/deeplink/application/startup_deep_links.dart';
import 'features/app/presentation/pxx_app.dart';

void main(List<String> args) {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ProviderScope(
      overrides: [
        startupDeepLinksProvider.overrideWithValue(args),
      ],
      child: const PxxApp(),
    ),
  );
}
