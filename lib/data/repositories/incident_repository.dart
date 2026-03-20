import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/errors/error_handler.dart';
import '../models/incident.dart';

class IncidentRepository {
  final SupabaseClient _supabase;

  IncidentRepository(this._supabase);

  Future<void> transition(String incidentId, String newStatus, String comment, String actorId) async {
    try {
      await _supabase.rpc('transition_incident', params: {
        'p_incident_id': incidentId,
        'p_new_status': newStatus,
        'p_commentaire': comment,
        'p_actor_id': actorId,
      });
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  Stream<List<Incident>> getIncidentsStream() {
    return _supabase
        .from('incidents')
        .stream(primaryKey: ['id'])
        .order('updated_at', ascending: false)
        .map((event) => event.map((e) => Incident.fromJson(e)).toList());
  }
}
