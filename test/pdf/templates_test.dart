import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:amandier_b_syndic/presentation/pdf/templates/document_dtos.dart';
import 'package:amandier_b_syndic/presentation/pdf/templates/relance_amiable_template.dart';
import 'package:amandier_b_syndic/presentation/pdf/templates/convocation_ag_template.dart';
import 'package:amandier_b_syndic/presentation/pdf/templates/feuille_presence_template.dart';
import 'package:amandier_b_syndic/presentation/pdf/templates/pv_ag_template.dart';
import 'package:amandier_b_syndic/presentation/pdf/templates/bon_intervention_template.dart';

void main() {
  test('Generate All 5 PDF Templates', () async {
    final d1 = RelanceAmiableData(
      serialId: 'REL-001', dateGenerationSysteme: '2026-03-20', nomCoproprietaire: 'A', numeroLotAppartement: '1', moisCiblePaiement: 'Mars', anneeCiblePaiement: '2026', cotisationMensuelleNumerique: '250', syndicIdentite: 'S',
    );
    final b1 = await generateRelanceAmiable(d1);
    await File('/tmp/relance.pdf').writeAsBytes(b1);

    final d2 = ConvocationAgData(
      serialId: 'CONV-001', dateGenerationSysteme: '2026-03-20', nomCoproprietaire: 'A', numeroLotAppartement: '1', dateAssembleeGenerale: '2026-04-01', heureDebutAssemblee: '10:00', lieuAssembleeGenerale: 'Hall', ordreDuJour: ['Point 1'], syndicIdentite: 'S',
    );
    final b2 = await generateConvocationAg(d2);
    await File('/tmp/conv.pdf').writeAsBytes(b2);

    final d3 = FeuillePresenceData(
      serialId: 'FEUILLE-001', dateAssembleeGenerale: '2026-04-01', heureDebutAssemblee: '10:00', residents: [PresenceAgRow(lotId: '1', nomProprietaire: 'A', tantiemes: 100, statut: 'P', mandataire: '')], compteTotal: 1, comptePresents: 1, compteRepresentes: 0, sommeTantiemes: 100, statusQuorum: 'Atteint',
    );
    final b3 = await generateFeuillePresence(d3);
    await File('/tmp/feuille.pdf').writeAsBytes(b3);

    final d4 = PvAgData(
      serialId: 'PV-001', dateAssembleeGenerale: '2026-04-01', lieuAssembleeGenerale: 'Hall', heureDebutAssemblee: '10:00', nomPresidentSeance: 'P', syndicIdentite: 'S', sommeTantiemes: 100, resolutions: [ResolutionVote(numero: 1, titre: 'R1', resumeDiscussions: 'D1', voixPour: 100, voixContre: 0, abstentions: 0, resultat: 'Adoptée')], heureFinAssemblee: '12:00', dateGenerationSysteme: '2026-04-02',
    );
    final b4 = await generatePvAg(d4);
    await File('/tmp/pv.pdf').writeAsBytes(b4);

    final d5 = BonInterventionData(
      serialId: 'BON-001', dateGenerationSysteme: '2026-03-20', nomEntreprisePrestataire: 'E', nomTechnicienIntervenant: 'T', telephonePrestataire: '000', domaineIntervention: 'D', lieuExactDansResidence: 'L', descriptionDetailleeMission: 'M', horodatageArrivee: '10', horodatageDepart: '11', dureeTotaleCalculee: '1', descriptionTravauxRealises: 'R', listePiecesRemplacees: 'P', recommandationsPreventives: 'Rec',
    );
    final b5 = await generateBonIntervention(d5);
    await File('/tmp/bon.pdf').writeAsBytes(b5);

    print('All 5 PDFs generated successfully.');
  });
}
