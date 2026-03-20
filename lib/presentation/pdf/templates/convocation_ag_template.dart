import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'document_dtos.dart';
import '../pdf_integrity_service.dart';

Future<Uint8List> generateConvocationAg(ConvocationAgData data) async {
  final pdf = pw.Document();

  final hashPrefix = PdfIntegrityService.computeCanonicalHash(
    serialId: data.serialId,
    residentNom: data.nomCoproprietaire,
    appartementNum: data.numeroLotAppartement,
    periode: 'AG-${data.dateAssembleeGenerale}',
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
      margin: const pw.EdgeInsets.all(2.5 * PdfPageFormat.cm),
      build: (pw.Context context) {
        return [
          pw.Center(
            child: pw.Text("CONVOCATION À L'ASSEMBLÉE GÉNÉRALE DES COPROPRIÉTAIRES", style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
          ),
          pw.SizedBox(height: 10),
          pw.Center(
            child: pw.Text("Résidence l'Amandier B", style: mainTextStyle),
          ),
          pw.SizedBox(height: 20),
          pw.Text('Document émis le : ${data.dateGenerationSysteme}', style: mainTextStyle),
          pw.SizedBox(height: 10),
          pw.Text("À l'attention exclusive de : ${data.nomCoproprietaire}", style: boldTextStyle),
          pw.Text('Propriétaire du lot : ${data.numeroLotAppartement}', style: mainTextStyle),
          pw.SizedBox(height: 20),
          pw.Text('Chère voisine, cher voisin,', style: mainTextStyle),
          pw.SizedBox(height: 10),
          pw.Text("La vitalité et l'excellence de notre Résidence l'Amandier B reposent sur la participation active, les idées et la voix de chacun d'entre nous. C'est le moment privilégié de l'année où notre grande famille se réunit pour échanger, partager nos visions d'avenir et prendre ensemble les décisions qui façonneront la qualité de notre cadre de vie pour les mois à venir.", style: mainTextStyle),
          pw.SizedBox(height: 10),
          pw.Text("J'ai l'immense plaisir de vous convier à la prochaine Assemblée Générale de notre copropriété, qui se tiendra dans un esprit de concertation et d'amitié :", style: mainTextStyle),
          pw.SizedBox(height: 10),
          pw.Text('Date de la réunion : ${data.dateAssembleeGenerale}', style: boldTextStyle),
          pw.Text("Heure d'accueil : ${data.heureDebutAssemblee}", style: boldTextStyle),
          pw.Text('Lieu de rencontre : ${data.lieuAssembleeGenerale}', style: boldTextStyle),
          pw.SizedBox(height: 10),
          pw.Text("Afin de structurer nos échanges et de respecter nos obligations de transparence, l'ordre du jour qui vous est proposé est le suivant :", style: mainTextStyle),
          pw.SizedBox(height: 10),
          ...data.ordreDuJour.map((point) => pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('• ', style: mainTextStyle),
              pw.Expanded(child: pw.Text(point, style: mainTextStyle)),
            ],
          )).toList(),
          pw.SizedBox(height: 10),
          pw.Text("Conformément à nos principes d'absolue transparence et aux directives légales, vous trouverez annexés à la présente convocation, directement téléchargeables depuis votre application, tous les documents comptables nécessaires (bilan, état de la trésorerie).", style: mainTextStyle),
          pw.SizedBox(height: 10),
          pw.Text("Votre présence est précieuse pour notre communauté. Toutefois, si vos obligations ne vous permettent pas de vous joindre à nous, vous avez la possibilité de vous faire représenter par un autre membre de la résidence. Il vous suffira pour cela de remplir le formulaire de procuration numérique disponible sur votre application.", style: mainTextStyle),
          pw.SizedBox(height: 10),
          pw.Text("Dans l'attente du grand plaisir de vous retrouver pour ce moment de convivialité et d'échange constructif, je vous prie d'agréer, chère voisine, cher voisin, l'expression de mes salutations les plus chaleureuses.", style: mainTextStyle),
          pw.SizedBox(height: 20),
          pw.Text('Le Syndic,', style: mainTextStyle),
          pw.Text(data.syndicIdentite, style: boldTextStyle),
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
