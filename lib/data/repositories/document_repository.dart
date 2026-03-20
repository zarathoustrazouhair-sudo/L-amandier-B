import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/errors/error_handler.dart';
import '../models/document.dart';

class DocumentRepository {
  final SupabaseClient _supabase;

  DocumentRepository(this._supabase);

  Stream<List<Document>> getDocumentsStream() {
    return _supabase
        .from('documents')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((event) => event.map((e) => Document.fromJson(e)).toList());
  }
}
