import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'document_dtos.dart';
import '../pdf_integrity_service.dart';

Future<Uint8List> generateFeuillePresence(FeuillePresenceData data) async {
  final pdf = pw.Document();

  final hashPrefix = PdfIntegrityService.computeCanonicalHash(
    serialId: data.serialId,
    residentNom: 'AG',
    appartementNum: 'ALL',
    periode: data.dateAssembleeGenerale,
    datePaiementIso: 'none',
    timestampGenerationIso: data.dateAssembleeGenerale,
  );

  final qrUrl = PdfIntegrityService.buildQrPayloadUrl(data.serialId, hashPrefix);
  final qrImage = await PdfIntegrityService.renderQrCodeForPdf(qrUrl);

  final mainTextStyle = const pw.TextStyle(fontSize: 10);
  final boldTextStyle = pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold);

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(2.0 * PdfPageFormat.cm),
      build: (pw.Context context) {
        return [
          pw.Center(
            child: pw.Text("FEUILLE DE PRÉSENCE OFFICIELLE - ASSEMBLÉE GÉNÉRALE", style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
          ),
          pw.SizedBox(height: 10),
          pw.Text("Résidence : l'Amandier B", style: mainTextStyle),
          pw.Text('Date de la séance : ${data.dateAssembleeGenerale} à ${data.heureDebutAssemblee}', style: mainTextStyle),
          pw.SizedBox(height: 20),
          pw.Text("Conformément aux dispositions de l'article 16 nonies de la loi n° 106-12 relative à la copropriété des immeubles bâtis au Maroc, la présente feuille recense les copropriétaires présents ou dûment représentés lors de l'Assemblée Générale, certifiant ainsi la régularité du quorum.", style: mainTextStyle),
          pw.SizedBox(height: 20),
          pw.TableHelper.fromTextArray(
            headers: ['N° Lot', 'Identité Copropriétaire', 'Tantièmes (/1000)', 'Statut', 'Mandataire', 'Signature'],
            data: data.residents.map((row) {
              return [
                row.lotId,
                row.nomProprietaire,
                row.tantiemes.toString(),
                row.statut,
                row.mandataire,
                '' // Placeholder for signature image if B64 is present
              ];
            }).toList(),
            headerStyle: boldTextStyle,
            cellStyle: mainTextStyle,
            cellAlignment: pw.Alignment.centerLeft,
            border: pw.TableBorder.all(),
          ),
          // Handle signatures within the table is tricky with text arrays, but we map simple text here for the mock.
          pw.SizedBox(height: 20),
          pw.Text("Synthèse Automatisée de l'Assemblée :", style: boldTextStyle),
          pw.Text('• Nombre total de copropriétaires dans la résidence : ${data.compteTotal}', style: mainTextStyle),
          pw.Text('• Nombre de copropriétaires physiquement présents : ${data.comptePresents}', style: mainTextStyle),
          pw.Text('• Nombre de copropriétaires représentés par procuration : ${data.compteRepresentes}', style: mainTextStyle),
          pw.Text('• Total des tantièmes validés pour le vote : ${data.sommeTantiemes} / 1000', style: mainTextStyle),
          pw.Text('• Constat de Quorum : ${data.statusQuorum}', style: mainTextStyle),
          pw.SizedBox(height: 20),
          pw.Text("Arrêté, certifié exact et scellé électroniquement à Bouskoura, le ${data.dateAssembleeGenerale}.", style: mainTextStyle),
          pw.SizedBox(height: 30),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
            children: [
              pw.Column(
                children: [
                  pw.Text('Le Président de Séance', style: boldTextStyle),
                  pw.SizedBox(height: 10),
                  if (data.signaturePresident != null)
                    pw.Image(pw.MemoryImage(data.signaturePresident!), height: 40)
                  else
                    pw.SizedBox(height: 40),
                ]
              ),
              pw.Column(
                children: [
                  pw.Text('Le Syndic', style: boldTextStyle),
                  pw.SizedBox(height: 10),
                  if (data.signatureSyndic != null)
                    pw.Image(pw.MemoryImage(data.signatureSyndic!), height: 40)
                  else
                    pw.SizedBox(height: 40),
                ]
              )
            ]
          )
        ];
      },
      footer: (pw.Context context) {
        return pw.Row(
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
                qrImage,
                pw.SizedBox(height: 4),
                pw.Text(data.serialId, style: pw.TextStyle(font: pw.Font.courier(), fontSize: 6)),
              ]
            )
          ]
        );
      },
    ),
  );

  return await pdf.save();
}
