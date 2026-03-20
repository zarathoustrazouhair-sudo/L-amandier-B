import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/errors/error_handler.dart';
import '../models/paiement.dart';

class PaiementRepository {
  final SupabaseClient _supabase;

  PaiementRepository(this._supabase);

  Future<bool> validatePayment(String paymentId, String validatorId, String compte) async {
    try {
      final response = await _supabase.rpc('validate_payment', params: {
        'p_payment_id': paymentId,
        'p_validator_id': validatorId,
        'p_compte': compte,
      });
      return response != null && response['success'] == true;
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  Stream<List<Paiement>> getPaiementsStream() {
    return _supabase
        .from('paiements')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((event) => event.map((e) => Paiement.fromJson(e)).toList());
  }
}
