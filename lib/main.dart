import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/errors/logger_service.dart';
import 'core/theme/app_theme.dart';
import 'presentation/screens/auth/login_screen.dart';

void main() {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      await Hive.initFlutter();
      await LoggerService.instance.init();

      // await Firebase.initializeApp(); ...
      // await Supabase.initialize(...); ...

      ErrorWidget.builder = (FlutterErrorDetails details) {
        LoggerService.instance.logError(details.exception, details.stack, context: 'ErrorWidget.builder');
        return const _BrandedErrorPlaceholder();
      };

      runApp(const ProviderScope(child: AmandierApp()));
    },
    (error, stack) {
      LoggerService.instance.logError(error, stack, context: 'runZonedGuarded');
    },
  );
}

class AmandierApp extends StatelessWidget {
  const AmandierApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Amandier B Syndic',
      theme: AppTheme.light,
      home: const LoginScreen(), // Assuming this is the initial route
      debugShowCheckedModeBanner: false,
    );
  }
}

class _BrandedErrorPlaceholder extends StatelessWidget {
  const _BrandedErrorPlaceholder();
  @override
  Widget build(BuildContext context) {
    return const Material(
      color: Color(0xFFF5F1E7), // AppColors.parchmentBg
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.home_work_outlined, color: Color(0xFFC5A059), size: 48), // AppColors.accentGold
            SizedBox(height: 12),
            Text('Résidence L\'Amandier B', style: TextStyle(color: Color(0xFF1A365D), fontWeight: FontWeight.w600)),
            SizedBox(height: 4),
            Text('Synchronisation en cours...', style: TextStyle(color: Color(0xFF1A365D), fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
