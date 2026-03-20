import 'package:freezed_annotation/freezed_annotation.dart';

part 'flux_tresorerie.freezed.dart';
part 'flux_tresorerie.g.dart';

enum FluxType {
  entree,
  sortie
}

@freezed
class FluxTresorerie with _$FluxTresorerie {
  const factory FluxTresorerie({
    required String id,
    required FluxType type,
    required String categorie,
    required double montant,
    @JsonKey(name: 'date_flux') required DateTime dateFlux,
    String? source,
    String? reference,
    @Default('caisse') String compte,
    @JsonKey(name: 'created_by') required String createdBy,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _FluxTresorerie;

  factory FluxTresorerie.fromJson(Map<String, dynamic> json) => _$FluxTresorerieFromJson(json);
}
