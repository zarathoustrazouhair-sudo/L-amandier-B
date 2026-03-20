import 'package:freezed_annotation/freezed_annotation.dart';

part 'presence_ag.freezed.dart';
part 'presence_ag.g.dart';

@freezed
class PresenceAg with _$PresenceAg {
  const factory PresenceAg({
    required String id,
    @JsonKey(name: 'ag_id') required String agId,
    @JsonKey(name: 'resident_id') required String residentId,
    @Default(false) bool present,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _PresenceAg;

  factory PresenceAg.fromJson(Map<String, dynamic> json) => _$PresenceAgFromJson(json);
}
