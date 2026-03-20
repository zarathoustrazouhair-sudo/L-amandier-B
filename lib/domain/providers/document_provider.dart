import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/models/document.dart';
import '../../data/datasources/supabase_client.dart';

part 'document_provider.g.dart';

@riverpod
Future<List<Document>> documentList(DocumentListRef ref) async {
  final response = await supabase
      .from('documents')
      .select()
      .order('date_generation', ascending: false);

  return (response as List).map((e) => Document.fromJson(e)).toList();
}
