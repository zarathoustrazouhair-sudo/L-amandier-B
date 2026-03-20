import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/datasources/supabase_client.dart';
import '../../data/datasources/fcm_token_datasource.dart';

part 'fcm_provider.g.dart';

@Riverpod(keepAlive: true)
FcmTokenDatasource fcmTokenDatasource(FcmTokenDatasourceRef ref) {
  return FcmTokenDatasource(supabase);
}

@Riverpod(keepAlive: true)
Future<void> fcmInitialization(FcmInitializationRef ref) async {
  // LAW-04: ZERO notification dispatch logic in the client. Token collection only.
  final datasource = ref.watch(fcmTokenDatasourceProvider);
  final messaging = FirebaseMessaging.instance;

  // Listen to token refresh
  messaging.onTokenRefresh.listen((newToken) {
    datasource.upsertToken(newToken);
  });

  // Get initial token
  try {
    final initialToken = await messaging.getToken();
    if (initialToken != null) {
      await datasource.upsertToken(initialToken);
    }
  } catch (e) {
    // Log token fetch error, non-blocking
    // print('Error fetching FCM token: $e');
  }
}
