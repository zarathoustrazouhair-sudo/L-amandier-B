import 'package:freezed_annotation/freezed_annotation.dart';

part 'assemblee_generale.freezed.dart';
part 'assemblee_generale.g.dart';

enum AgStatus {
  planifiee,
  ouverte,
  close
}

@freezed
class AssembleeGenerale with _$AssembleeGenerale {
  const factory AssembleeGenerale({
    required String id,
    required String titre,
    @JsonKey(name: 'date_ag') required DateTime dateAg,
    @Default(AgStatus.planifiee) AgStatus statut,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _AssembleeGenerale;

  factory AssembleeGenerale.fromJson(Map<String, dynamic> json) => _$AssembleeGeneraleFromJson(json);
}
