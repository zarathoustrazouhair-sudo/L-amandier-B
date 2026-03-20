import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'document_dtos.dart';
import '../pdf_integrity_service.dart';

Future<Uint8List> generatePvAg(PvAgData data) async {
  final pdf = pw.Document();

  final hashPrefix = PdfIntegrityService.computeCanonicalHash(
    serialId: data.serialId,
    residentNom: 'AG',
    appartementNum: 'ALL',
    periode: data.dateAssembleeGenerale,
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
            child: pw.Text("PROCÈS-VERBAL DES DÉLIBÉRATIONS DE L'ASSEMBLÉE GÉNÉRALE", style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
          ),
          pw.SizedBox(height: 10),
          pw.Center(
            child: pw.Text("Résidence l'Amandier B", style: mainTextStyle),
          ),
          pw.SizedBox(height: 20),
          pw.Text('Date de la séance : ${data.dateAssembleeGenerale}', style: mainTextStyle),
          pw.Text('Lieu de tenue : ${data.lieuAssembleeGenerale}', style: mainTextStyle),
          pw.Text("Heure d'ouverture de la séance : ${data.heureDebutAssemblee}", style: mainTextStyle),
          pw.Text('Président de séance élu : ${data.nomPresidentSeance}', style: mainTextStyle),
          pw.Text('Secrétaire de séance (Syndic) : ${data.syndicIdentite}', style: mainTextStyle),
          pw.SizedBox(height: 20),
          pw.Text('1. Constat de quorum et ouverture', style: boldTextStyle),
          pw.SizedBox(height: 10),
          pw.Text("Le Président de séance prend la parole pour remercier l'ensemble des résidents de l'Amandier B pour leur présence chaleureuse, rappelant l'importance de ce rendez-vous annuel pour entretenir l'esprit familial et le haut standing de notre lieu de vie. Après examen de la feuille de présence générée et signée électroniquement, le secrétariat constate que les copropriétaires présents ou représentés totalisent ${data.sommeTantiemes} / 1000 des quotes-parts. Le quorum légal étant valablement atteint, l'Assemblée Générale est déclarée régulièrement constituée et peut délibérer sur l'ordre du jour.", style: mainTextStyle),
          pw.SizedBox(height: 20),
          pw.Text('2. Délibérations et Résolutions', style: boldTextStyle),
          pw.SizedBox(height: 10),
          ...data.resolutions.map((res) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Résolution N° ${res.numero} : ${res.titre}', style: boldTextStyle),
              pw.SizedBox(height: 5),
              pw.Text('Exposé des discussions : ${res.resumeDiscussions}', style: mainTextStyle),
              pw.SizedBox(height: 5),
              pw.Text('Résultat des suffrages calculé par le système :', style: mainTextStyle),
              pw.Text('• Voix POUR : ${res.voixPour} tantièmes', style: mainTextStyle),
              pw.Text('• Voix CONTRE : ${res.voixContre} tantièmes', style: mainTextStyle),
              pw.Text('• Abstentions : ${res.abstentions} tantièmes', style: mainTextStyle),
              pw.SizedBox(height: 5),
              pw.Text('Décision officielle : La résolution est ${res.resultat}.', style: boldTextStyle),
              pw.SizedBox(height: 15),
            ],
          )).toList(),
          pw.Text('3. Clôture de la séance', style: boldTextStyle),
          pw.SizedBox(height: 10),
          pw.Text("L'ordre du jour étant intégralement épuisé, et aucun autre point n'ayant été soulevé par l'assemblée dans un esprit d'intérêt général, le Président remercie chaleureusement les participants pour la courtoisie des échanges et leur dévouement envers la communauté. La séance est officiellement levée à ${data.heureFinAssemblee}.", style: mainTextStyle),
          pw.SizedBox(height: 20),
          pw.Text('4. Mentions légales et notification', style: boldTextStyle),
          pw.SizedBox(height: 10),
          pw.Text("Conformément aux dispositions de l'article 16 nonies de la loi 106-12, le présent procès-verbal est généré et notifié électroniquement à l'ensemble des copropriétaires de la résidence dans le délai légal de huit jours. Il est rappelé à toutes fins utiles, et bien que notre communauté privilégie systématiquement la conciliation amiable et bienveillante, qu'en cas de litige relatif à l'interprétation des présentes décisions ou au fonctionnement de la copropriété sise à Bouskoura, le Tribunal compétent est le Tribunal de Première Instance de Casablanca.", style: mainTextStyle),
          pw.SizedBox(height: 20),
          pw.Text('Fait et validé électroniquement le ${data.dateGenerationSysteme}.', style: mainTextStyle),
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
