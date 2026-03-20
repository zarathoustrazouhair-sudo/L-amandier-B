import 'package:freezed_annotation/freezed_annotation.dart';

part 'recu_paiement_data.freezed.dart';

@freezed
class RecuPaiementData with _$RecuPaiementData {
  const factory RecuPaiementData({
    required String serialId,
    required String syndicIdentite,
    required String nomCoproprietaire,
    required String numeroLotAppartement,
    required String dateGenerationSysteme,
    required String dateEncaissement,
    required String moisCiblePaiement,
    required String anneeCiblePaiement,
    required String modePaiementSelectionne,
    required String referenceBancaireOuCheque,
    required String cotisationMensuelleLitterale,
  }) = _RecuPaiementData;
}
