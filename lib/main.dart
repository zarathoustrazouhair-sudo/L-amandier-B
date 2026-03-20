import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/network/lkgc_cache.dart';
import 'data/datasources/supabase_client.dart';
import 'core/routing/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  await LkgcCache.init();
  await SupabaseService.initialize();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Amandier B Syndic',
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF8FAF72),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}
