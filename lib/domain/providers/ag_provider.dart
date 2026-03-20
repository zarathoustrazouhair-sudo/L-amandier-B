import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/models/assemblee_generale.dart';
import '../../data/datasources/supabase_client.dart';

part 'ag_provider.g.dart';

@riverpod
Stream<List<AssembleeGenerale>> agList(AgListRef ref) {
  return supabase
      .from('assemblees_generales')
      .stream(primaryKey: ['id'])
      .order('date_ag', ascending: false)
      .map((event) => event.map((e) => AssembleeGenerale.fromJson(e)).toList());
}

@riverpod
AssembleeGenerale? activeAg(ActiveAgRef ref) {
  final ags = ref.watch(agListProvider).valueOrNull ?? [];
  for (final ag in ags) {
    if (ag.statut == AgStatus.ouverte) return ag;
  }
  return null;
}
