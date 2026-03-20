import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:intl/intl.dart';
import '../../data/models/paiement.dart';
import '../../data/datasources/supabase_client.dart';

part 'paiement_provider.g.dart';

@riverpod
Stream<List<Paiement>> paiementList(PaiementListRef ref) {
  return supabase
      .from('paiements')
      .stream(primaryKey: ['id'])
      .order('created_at', ascending: false)
      .map((event) => event.map((e) => Paiement.fromJson(e)).toList());
}

@riverpod
List<Paiement> currentPeriodPayments(CurrentPeriodPaymentsRef ref) {
  final allPayments = ref.watch(paiementListProvider).valueOrNull ?? [];
  final now = DateTime.now();
  final currentPeriod = DateFormat('yyyy-MM').format(now);

  return allPayments.where((p) => p.periode == currentPeriod).toList();
}
