import 'package:freezed_annotation/freezed_annotation.dart';

part 'incident.freezed.dart';
part 'incident.g.dart';

enum IncidentStatus {
  ouvert,
  assigne,
  resolu,
  clos
}

enum IncidentPriority {
  low,
  medium,
  high,
  critical
}

@freezed
class Incident with _$Incident {
  const factory Incident({
    required String id,
    required String titre,
    String? description,
    @Default(IncidentStatus.ouvert) IncidentStatus statut,
    @Default(IncidentPriority.low) IncidentPriority priorite, // Added priorite for incident provider
    @JsonKey(name: 'appartement_id') String? appartementId,
    @JsonKey(name: 'assigne_a') String? assigneA,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _Incident;

  factory Incident.fromJson(Map<String, dynamic> json) => _$IncidentFromJson(json);
}
