import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/errors/error_handler.dart';
import '../models/appartement.dart';

class AppartementRepository {
  final SupabaseClient _supabase;

  AppartementRepository(this._supabase);

  Stream<List<Appartement>> getAppartementsStream() {
    return _supabase
        .from('appartements')
        .stream(primaryKey: ['id'])
        .order('numero', ascending: true)
        .map((event) => event.map((e) => Appartement.fromJson(e)).toList());
  }
}
