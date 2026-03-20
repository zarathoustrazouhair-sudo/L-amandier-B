import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/models/appartement.dart';
import '../../data/models/paiement.dart';
import '../../data/datasources/supabase_client.dart';
import 'paiement_provider.dart';

part 'appartement_provider.g.dart';

@riverpod
Stream<List<Appartement>> appartementList(AppartementListRef ref) {
  return supabase
      .from('appartements')
      .stream(primaryKey: ['id'])
      .order('numero', ascending: true)
      .map((event) => event.map((e) => Appartement.fromJson(e)).toList());
}

@riverpod
Stream<List<Appartement>> appartementListWithStatus(AppartementListWithStatusRef ref) async* {
  final appartementsStream = ref.watch(appartementListProvider.stream);

  await for (final appartements in appartementsStream) {
    final currentPeriodPayments = ref.watch(currentPeriodPaymentsProvider);

    final mappedAppartements = appartements.map((apt) {
      final paymentsForApt = currentPeriodPayments.where((p) => p.appartementId == apt.id).toList();
      final hasValidatedPayment = paymentsForApt.any((p) => p.statut == PaymentStatus.validated);

      ApartmentFinancialStatus status;
      if (hasValidatedPayment) {
        status = ApartmentFinancialStatus.equilibre;
      } else if (apt.statutOccupation != 'vacant') {
        status = ApartmentFinancialStatus.dette;
      } else {
        status = ApartmentFinancialStatus.vacant;
      }

      return apt.copyWith(financialStatus: status);
    }).toList();

    yield mappedAppartements;
  }
}
