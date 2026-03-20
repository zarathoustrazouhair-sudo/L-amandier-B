import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:amandier_b_syndic/presentation/pdf/templates/recu_paiement_data.dart';
import 'package:amandier_b_syndic/presentation/pdf/templates/recu_paiement_template.dart';

void main() {
  test('Generate Recu Paiement PDF', () async {
    final data = RecuPaiementData(
      serialId: 'REC-2026-03-0001',
      syndicIdentite: 'Jean Dupont',
      nomCoproprietaire: 'Marie Curie',
      numeroLotAppartement: 'A12',
      dateGenerationSysteme: '2026-03-20T10:00:00Z',
      dateEncaissement: '2026-03-15T14:30:00Z',
      moisCiblePaiement: 'Mars',
      anneeCiblePaiement: '2026',
      modePaiementSelectionne: 'Virement bancaire',
      referenceBancaireOuCheque: 'VIR-987654321',
      cotisationMensuelleLitterale: 'Deux cent cinquante dirhams',
    );

    final bytes = await generateRecuPaiement(data);

    // Save to tmp file
    final file = File('/tmp/test_recu_paiement.pdf');
    await file.writeAsBytes(bytes);

    final length = await file.length();
    print('Generated PDF Size: $length bytes');
    expect(length, greaterThan(10000)); // Must be > 10KB
  });
}
