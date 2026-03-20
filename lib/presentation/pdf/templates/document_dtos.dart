import 'package:freezed_annotation/freezed_annotation.dart';
import 'dart:typed_data';
part 'document_dtos.freezed.dart';

@freezed
class RelanceAmiableData with _$RelanceAmiableData {
  const factory RelanceAmiableData({
    required String serialId, required String dateGenerationSysteme,
    required String nomCoproprietaire, required String numeroLotAppartement,
    required String moisCiblePaiement, required String anneeCiblePaiement,
    required String cotisationMensuelleNumerique, required String syndicIdentite,
  }) = _RelanceAmiableData;
}

@freezed
class ConvocationAgData with _$ConvocationAgData {
  const factory ConvocationAgData({
    required String serialId, required String dateGenerationSysteme,
    required String nomCoproprietaire, required String numeroLotAppartement,
    required String dateAssembleeGenerale, required String heureDebutAssemblee,
    required String lieuAssembleeGenerale, required List<String> ordreDuJour,
    required String syndicIdentite,
  }) = _ConvocationAgData;
}

@freezed
class PresenceAgRow with _$PresenceAgRow {
  const factory PresenceAgRow({
    required String lotId, required String nomProprietaire,
    required int tantiemes, required String statut, required String mandataire,
    Uint8List? signatureB64,
  }) = _PresenceAgRow;
}

@freezed
class FeuillePresenceData with _$FeuillePresenceData {
  const factory FeuillePresenceData({
    required String serialId, required String dateAssembleeGenerale,
    required String heureDebutAssemblee, required List<PresenceAgRow> residents,
    required int compteTotal, required int comptePresents,
    required int compteRepresentes, required int sommeTantiemes,
    required String statusQuorum, Uint8List? signaturePresident, Uint8List? signatureSyndic,
  }) = _FeuillePresenceData;
}

@freezed
class ResolutionVote with _$ResolutionVote {
  const factory ResolutionVote({
    required int numero, required String titre, required String resumeDiscussions,
    required int voixPour, required int voixContre, required int abstentions,
    required String resultat,
  }) = _ResolutionVote;
}

@freezed
class PvAgData with _$PvAgData {
  const factory PvAgData({
    required String serialId, required String dateAssembleeGenerale,
    required String lieuAssembleeGenerale, required String heureDebutAssemblee,
    required String nomPresidentSeance, required String syndicIdentite,
    required int sommeTantiemes, required List<ResolutionVote> resolutions,
    required String heureFinAssemblee, required String dateGenerationSysteme,
    Uint8List? signaturePresident, Uint8List? signatureSyndic,
  }) = _PvAgData;
}

@freezed
class BonInterventionData with _$BonInterventionData {
  const factory BonInterventionData({
    required String serialId, required String dateGenerationSysteme,
    required String nomEntreprisePrestataire, required String nomTechnicienIntervenant,
    required String telephonePrestataire, required String domaineIntervention,
    required String lieuExactDansResidence, required String descriptionDetailleeMission,
    required String horodatageArrivee, required String horodatageDepart,
    required String dureeTotaleCalculee, required String descriptionTravauxRealises,
    required String listePiecesRemplacees, required String recommandationsPreventives,
    Uint8List? signatureTechnicien, Uint8List? signatureSyndic,
  }) = _BonInterventionData;
}
