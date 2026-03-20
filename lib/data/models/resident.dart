import 'package:freezed_annotation/freezed_annotation.dart';

part 'resident.freezed.dart';
part 'resident.g.dart';

@freezed
class Resident with _$Resident {
  const factory Resident({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'appartement_id') required String appartementId,
    required String type,
    @JsonKey(name: 'date_entree') required DateTime dateEntree,
    @JsonKey(name: 'date_sortie') DateTime? dateSortie,
    @Default(true) bool actif,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _Resident;

  factory Resident.fromJson(Map<String, dynamic> json) => _$ResidentFromJson(json);
}
