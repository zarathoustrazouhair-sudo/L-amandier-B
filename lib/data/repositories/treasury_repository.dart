import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/errors/error_handler.dart';
import '../models/treasury_summary.dart';

class TreasuryRepository {
  final SupabaseClient _supabase;

  TreasuryRepository(this._supabase);

  Future<TreasurySummary> getSummary() async {
    try {
      final response = await _supabase.rpc('get_treasury_summary');
      if (response == null || (response as List).isEmpty) {
        throw Exception('Invalid treasury summary response');
      }
      return TreasurySummary.fromJson(response.first as Map<String, dynamic>);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }
}
