import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/errors/error_handler.dart';
import '../models/assemblee_generale.dart';

class AgRepository {
  final SupabaseClient _supabase;

  AgRepository(this._supabase);

  Stream<List<AssembleeGenerale>> getAgStream() {
    return _supabase
        .from('assemblees_generales')
        .stream(primaryKey: ['id'])
        .order('date_ag', ascending: false)
        .map((event) => event.map((e) => AssembleeGenerale.fromJson(e)).toList());
  }
}
