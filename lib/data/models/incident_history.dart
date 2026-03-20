import 'package:freezed_annotation/freezed_annotation.dart';
import 'incident.dart'; // import status enum

part 'incident_history.freezed.dart';
part 'incident_history.g.dart';

@freezed
class IncidentHistory with _$IncidentHistory {
  const factory IncidentHistory({
    required String id,
    @JsonKey(name: 'incident_id') required String incidentId,
    @JsonKey(name: 'ancien_statut') required IncidentStatus ancienStatut,
    @JsonKey(name: 'nouveau_statut') required IncidentStatus nouveauStatut,
    String? commentaire,
    @JsonKey(name: 'changed_by') required String changedBy,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _IncidentHistory;

  factory IncidentHistory.fromJson(Map<String, dynamic> json) => _$IncidentHistoryFromJson(json);
}
