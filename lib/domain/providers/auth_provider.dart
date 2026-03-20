import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/datasources/supabase_client.dart';

part 'auth_provider.g.dart';

@riverpod
Stream<AuthState> authState(AuthStateRef ref) {
  return supabase.auth.onAuthStateChange;
}

@riverpod
Future<String?> currentUserRole(CurrentUserRoleRef ref) async {
  final session = supabase.auth.currentSession;
  if (session == null) return null;

  final appMetadata = session.user.appMetadata;
  return appMetadata['role'] as String?;
}
