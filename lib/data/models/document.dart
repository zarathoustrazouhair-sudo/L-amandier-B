import 'package:freezed_annotation/freezed_annotation.dart';

part 'document.freezed.dart';
part 'document.g.dart';

enum DocumentType {
  recu_paiement,
  relance_amiable,
  convocation_ag,
  feuille_presence_ag,
  pv_ag,
  bon_intervention,
  decharge_employe
}

@freezed
class Document with _$Document {
  const factory Document({
    required String id,
    @JsonKey(name: 'serial_id') String? serialId,
    required String titre,
    required DocumentType type,
    String? url,
    @JsonKey(name: 'genere_par') required String generePar,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'date_generation') DateTime? dateGeneration,
    @JsonKey(name: 'reference_id') String? referenceId,
    @JsonKey(name: 'sha256_hash') String? sha256Hash,
    Map<String, dynamic>? metadata,
    @JsonKey(name: 'storage_path') String? storagePath,
  }) = _Document;

  factory Document.fromJson(Map<String, dynamic> json) => _$DocumentFromJson(json);
}
