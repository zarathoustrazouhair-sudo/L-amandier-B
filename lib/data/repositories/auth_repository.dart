import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/errors/error_handler.dart';
import '../models/profile.dart';

class AuthRepository {
  final SupabaseClient _supabase;

  AuthRepository(this._supabase);

  Future<void> signIn(String email, String password) async {
    try {
      await _supabase.auth.signInWithPassword(email: email, password: password);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  Stream<Profile?> get profileStream {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return Stream.value(null);

    return _supabase
        .from('profiles')
        .stream(primaryKey: ['id'])
        .eq('id', userId)
        .map((event) => event.isEmpty ? null : Profile.fromJson(event.first));
  }
}
