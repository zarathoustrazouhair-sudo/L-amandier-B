import 'package:freezed_annotation/freezed_annotation.dart';

part 'appartement.freezed.dart';
part 'appartement.g.dart';

enum ApartmentFinancialStatus {
  equilibre,
  dette,
  vacant,
  unknown
}

@freezed
class Appartement with _$Appartement {
  const factory Appartement({
    required String id,
    required String numero,
    required int etage,
    required int colonne,
    @JsonKey(name: 'statut_occupation') @Default('vacant') String statutOccupation,
    @JsonKey(name: 'surface_m2') double? surfaceM2,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    // Derived field not mapped to DB json automatically unless added
    @Default(ApartmentFinancialStatus.unknown) @JsonKey(includeFromJson: false, includeToJson: false) ApartmentFinancialStatus financialStatus,
  }) = _Appartement;

  factory Appartement.fromJson(Map<String, dynamic> json) => _$AppartementFromJson(json);
}
