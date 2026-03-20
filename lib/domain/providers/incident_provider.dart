import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/models/incident.dart';
import '../../data/datasources/supabase_client.dart';

part 'incident_provider.g.dart';

@riverpod
Stream<List<Incident>> incidentList(IncidentListRef ref) {
  return supabase
      .from('incidents')
      .stream(primaryKey: ['id'])
      .order('updated_at', ascending: false)
      .map((event) => event.map((e) => Incident.fromJson(e)).toList());
}

@riverpod
List<Incident> criticalIncidents(CriticalIncidentsRef ref) {
  final allIncidents = ref.watch(incidentListProvider).valueOrNull ?? [];
  return allIncidents.where((i) {
    return (i.priorite == IncidentPriority.high || i.priorite == IncidentPriority.critical) &&
           i.statut != IncidentStatus.clos;
  }).toList();
}
