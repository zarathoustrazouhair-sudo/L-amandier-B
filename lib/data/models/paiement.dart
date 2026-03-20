import 'package:freezed_annotation/freezed_annotation.dart';

part 'paiement.freezed.dart';
part 'paiement.g.dart';

enum PaymentStatus {
  pending,
  validated,
  rejected
}

enum PaymentMode {
  especes,
  virement,
  cheque,
  application
}

@freezed
class Paiement with _$Paiement {
  const factory Paiement({
    required String id,
    @JsonKey(name: 'appartement_id') required String appartementId,
    required String periode,
    @Default(250.00) double montant, // LAW-01
    @JsonKey(name: 'mode_paiement') required PaymentMode modePaiement,
    @JsonKey(name: 'date_paiement') required DateTime datePaiement,
    @JsonKey(name: 'reference_tx') String? referenceTx,
    @JsonKey(name: 'valide_par') String? validePar,
    @Default(PaymentStatus.pending) PaymentStatus statut,
    @JsonKey(name: 'created_by') required String createdBy,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _Paiement;

  factory Paiement.fromJson(Map<String, dynamic> json) => _$PaiementFromJson(json);
}
