import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/errors/error_handler.dart';

class FcmTokenDatasource {
  final SupabaseClient _supabase;

  FcmTokenDatasource(this._supabase);

  Future<void> upsertToken(String token) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      await _supabase.from('fcm_tokens').upsert(
        {
          'user_id': userId,
          'token': token,
          'updated_at': DateTime.now().toIso8601String(),
        },
        onConflict: 'user_id, token',
      );
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }
}
