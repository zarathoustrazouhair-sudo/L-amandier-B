import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'recu_paiement_data.dart';
import '../pdf_integrity_service.dart';
import '../../core/utils/tone_validator.dart';

Future<Uint8List> generateRecuPaiement(RecuPaiementData data) async {
  final pdf = pw.Document(
    creator: 'Amandier B Syndic',
    title: 'REÇU-${data.serialId}',
    keywords: data.serialId,
  );

  // Generate QR Code image
  final hashPrefix = PdfIntegrityService.computeCanonicalHash(
    serialId: data.serialId,
    residentNom: data.nomCoproprietaire,
    appartementNum: data.numeroLotAppartement,
    periode: '${data.anneeCiblePaiement}-${data.moisCiblePaiement}',
    datePaiementIso: data.dateEncaissement, // Simplified for this template
    timestampGenerationIso: data.dateGenerationSysteme,
  );

  final qrUrl = PdfIntegrityService.buildQrPayloadUrl(data.serialId, hashPrefix);
  final qrImage = await PdfIntegrityService.renderQrCodeForPdf(qrUrl);

  final mainTextStyle = const pw.TextStyle(fontSize: 11);
  final boldTextStyle = pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold);

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(2.5 * PdfPageFormat.cm),
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // HEADER
            pw.Center(
              child: pw.Text('REÇU OFFICIEL DE COTISATION SYNDICALE',
                style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            ),
            pw.SizedBox(height: 8),
            pw.Center(
              child: pw.Text("Copropriété : Résidence l'Amandier B", style: mainTextStyle),
            ),
            pw.Center(
              child: pw.Text('Adresse : Bouskoura, Province de Nouaceur, Maroc', style: mainTextStyle),
            ),
            pw.Center(
              child: pw.Text('Syndic en exercice : ${data.syndicIdentite}', style: mainTextStyle),
            ),
            pw.SizedBox(height: 16),
            pw.Divider(),
            pw.SizedBox(height: 16),

            // METADATA
            pw.Text('QUITTANCE N° : ${data.serialId}',
              style: pw.TextStyle(font: pw.Font.courier(), fontSize: 10)),
            pw.SizedBox(height: 4),
            pw.Text('Date de validation du document : ${data.dateGenerationSysteme}', style: mainTextStyle),
            pw.Text('Date de réception effective du paiement : ${data.dateEncaissement}', style: mainTextStyle),
            pw.SizedBox(height: 24),

            // BODY 1
            pw.Text("Je soussigné, ${data.syndicIdentite}, agissant en qualité de Syndic de la Résidence l'Amandier B, reconnais avoir reçu avec mes remerciements de la part de :",
              style: mainTextStyle),
            pw.SizedBox(height: 16),
            pw.Text('Madame / Monsieur : ${data.nomCoproprietaire}', style: boldTextStyle),
            pw.Text('Résident(e) ou Propriétaire du lot N° : ${data.numeroLotAppartement}', style: boldTextStyle),
            pw.SizedBox(height: 16),

            // AMOUNT (LAW-01: Hardcoded to 250.00)
            pw.Text('La somme de : 250,00 MAD', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
            pw.Text('(En toutes lettres : ${data.cotisationMensuelleLitterale})',
              style: pw.TextStyle(fontSize: 11, fontStyle: pw.FontStyle.italic)),
            pw.SizedBox(height: 16),

            // PERIOD & METHOD
            pw.Text('Ce règlement intervient au titre de la participation aux charges communes de fonctionnement pour la période suivante :', style: mainTextStyle),
            pw.Text('Mois de règlement : ${data.moisCiblePaiement} ${data.anneeCiblePaiement}', style: boldTextStyle),
            pw.SizedBox(height: 12),
            pw.Text('Méthode de règlement : ${data.modePaiementSelectionne}', style: mainTextStyle),
            pw.Text('Référence de la transaction : ${data.referenceBancaireOuCheque}', style: mainTextStyle),
            pw.SizedBox(height: 24),

            // COMMUNITY NOTE (LAW-08: Amiable Tone)
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
              ),
              child: pw.Text(
                "Note de la communauté : Nous profitons de ce récépissé pour vous remercier de votre contribution à la beauté et à la sérénité de notre lieu de vie. Conformément à la tradition établie au sein de notre résidence, nous rappelons que le Résident de notre copropriété s'acquitte de sa cotisation dès le premier jour de chaque mois, donnant ainsi une belle impulsion solidaire pour la couverture de nos frais de fonctionnement mensuels.",
                style: pw.TextStyle(fontSize: 10, fontStyle: pw.FontStyle.italic, color: PdfColors.grey700),
              ),
            ),
            pw.SizedBox(height: 24),

            // FOOTER & SIGNATURE
            pw.Text("Ce document électronique est généré de manière sécurisée par l'application officielle de la résidence. Son numéro de série est inaltérable.",
              style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
            pw.SizedBox(height: 24),
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text('Le Syndic de Copropriété', style: boldTextStyle),
            ),
            pw.Spacer(),

            // QR CODE (LAW-07)
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Expanded(
                  child: pw.Text("Vérification de l'Intégrité Documentaire :\n(Scannez ce code QR via l'appareil photo de votre smartphone pour vérifier l'authenticité de ce reçu directement sur le serveur sécurisé de la copropriété.)",
                    style: pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
                ),
                pw.SizedBox(width: 16),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Image(qrImage, width: 60, height: 60),
                    pw.SizedBox(height: 4),
                    pw.Text(data.serialId, style: pw.TextStyle(font: pw.Font.courier(), fontSize: 6)),
                  ]
                )
              ]
            ),
          ],
        );
      },
    ),
  );

  final bytes = await pdf.save();
  return bytes;
}
