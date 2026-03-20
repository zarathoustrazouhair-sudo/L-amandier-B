import 'package:freezed_annotation/freezed_annotation.dart';

part 'vote_ag.freezed.dart';
part 'vote_ag.g.dart';

@freezed
class VoteAg with _$VoteAg {
  const factory VoteAg({
    required String id,
    @JsonKey(name: 'ag_id') required String agId,
    @JsonKey(name: 'resident_id') required String residentId,
    required String choix,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _VoteAg;

  factory VoteAg.fromJson(Map<String, dynamic> json) => _$VoteAgFromJson(json);
}
