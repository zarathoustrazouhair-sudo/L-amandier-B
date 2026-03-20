import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'document_dtos.dart';
import '../pdf_integrity_service.dart';

Future<Uint8List> generateBonIntervention(BonInterventionData data) async {
  final pdf = pw.Document();

  final hashPrefix = PdfIntegrityService.computeCanonicalHash(
    serialId: data.serialId,
    residentNom: data.nomEntreprisePrestataire,
    appartementNum: 'INTERV',
    periode: data.dateGenerationSysteme,
    datePaiementIso: 'none',
    timestampGenerationIso: data.dateGenerationSysteme,
  );

  final qrUrl = PdfIntegrityService.buildQrPayloadUrl(data.serialId, hashPrefix);
  final qrImage = await PdfIntegrityService.renderQrCodeForPdf(qrUrl);

  final mainTextStyle = const pw.TextStyle(fontSize: 11);
  final boldTextStyle = pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold);

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(2.0 * PdfPageFormat.cm),
      build: (pw.Context context) {
        return [
          pw.Center(
            child: pw.Text("FICHE D'INTERVENTION TECHNIQUE DE PRESTATAIRE", style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
          ),
          pw.SizedBox(height: 10),
          pw.Text("Site de l'intervention : 225 lotissement Perla, Résidence l'Amandier B, Bouskoura", style: mainTextStyle),
          pw.SizedBox(height: 20),
          pw.Text("Numéro de suivi d'intervention : ${data.serialId}", style: mainTextStyle),
          pw.Text("Date d'émission : ${data.dateGenerationSysteme}", style: mainTextStyle),
          pw.SizedBox(height: 20),
          pw.Text('1. Identification du Prestataire Intervenant', style: boldTextStyle),
          pw.SizedBox(height: 10),
          pw.Text('• Raison Sociale ou Nom de l\'Artisan : ${data.nomEntreprisePrestataire}', style: mainTextStyle),
          pw.Text('• Nom du Technicien sur site : ${data.nomTechnicienIntervenant}', style: mainTextStyle),
          pw.Text('• Coordonnées de contact : ${data.telephonePrestataire}', style: mainTextStyle),
          pw.SizedBox(height: 20),
          pw.Text('2. Nature et Localisation de la Mission', style: boldTextStyle),
          pw.SizedBox(height: 10),
          pw.Text('• Domaine d\'intervention : ${data.domaineIntervention}', style: mainTextStyle),
          pw.Text('• Localisation précise : ${data.lieuExactDansResidence}', style: mainTextStyle),
          pw.Text('• Description du problème signalé ou de la mission : ${data.descriptionDetailleeMission}', style: mainTextStyle),
          pw.SizedBox(height: 20),
          pw.Text('3. Chronologie et Réalisations', style: boldTextStyle),
          pw.SizedBox(height: 10),
          pw.Text('• Date et Heure d\'arrivée sur site : ${data.horodatageArrivee}', style: mainTextStyle),
          pw.Text('• Date et Heure de fin des travaux : ${data.horodatageDepart}', style: mainTextStyle),
          pw.Text('• Durée totale de l\'intervention facturable : ${data.dureeTotaleCalculee} heures', style: mainTextStyle),
          pw.Text('• Détail des travaux effectivement accomplis : ${data.descriptionTravauxRealises}', style: mainTextStyle),
          pw.Text('• Inventaire des fournitures et pièces utilisées : ${data.listePiecesRemplacees}', style: mainTextStyle),
          pw.Text('• Recommandations préventives du technicien : ${data.recommandationsPreventives}', style: mainTextStyle),
          pw.SizedBox(height: 20),
          pw.Text('4. Validation et Signatures', style: boldTextStyle),
          pw.SizedBox(height: 10),
          pw.Text("Le prestataire technique soussigné certifie sur l'honneur avoir exécuté les travaux détaillés ci-dessus dans le strict respect des règles de l'art, des normes de sécurité en vigueur, et en ayant veillé à perturber le moins possible la tranquillité des résidents de l'Amandier B. Le représentant de la copropriété valide par la présente l'achèvement des travaux et la remise en état des lieux.", style: mainTextStyle),
          pw.SizedBox(height: 10),
          pw.Text("Avis comptable : Ce document a valeur de preuve de réalisation de la prestation. Toute facturation adressée à la copropriété devra impérativement faire référence au numéro de suivi de cette intervention.", style: pw.TextStyle(fontSize: 11, fontStyle: pw.FontStyle.italic)),
          pw.SizedBox(height: 30),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
            children: [
              pw.Column(
                children: [
                  pw.Text('Le Technicien / Prestataire', style: boldTextStyle),
                  pw.SizedBox(height: 10),
                  if (data.signatureTechnicien != null)
                    pw.Image(pw.MemoryImage(data.signatureTechnicien!), height: 40)
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
