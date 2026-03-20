import 'package:freezed_annotation/freezed_annotation.dart';

part 'treasury_summary.freezed.dart';
part 'treasury_summary.g.dart';

enum RunwayStatus {
  green,
  orange,
  red
}

@freezed
class TreasurySummary with _$TreasurySummary {
  const factory TreasurySummary({
    @JsonKey(name: 'solde_total') required double soldeTotal,
    @JsonKey(name: 'solde_caisse') required double soldeCaisse,
    @JsonKey(name: 'solde_banque') required double soldeBanque,
    @JsonKey(name: 'total_entrees') required double totalEntrees,
    @JsonKey(name: 'total_sorties') required double totalSorties,
    @JsonKey(name: 'impayes_count') required int impayesCount,
    @JsonKey(name: 'impayes_montant') required double impayesMontant,
    @JsonKey(name: 'taux_recouvrement') required double tauxRecouvrement,
    @JsonKey(name: 'runway_mois') required double runwayMois,
    @JsonKey(name: 'runway_status') @Default(RunwayStatus.red) RunwayStatus runwayStatus,
  }) = _TreasurySummary;

  factory TreasurySummary.fromJson(Map<String, dynamic> json) => _$TreasurySummaryFromJson(json);
}
