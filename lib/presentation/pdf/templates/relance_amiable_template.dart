import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'document_dtos.dart';
import '../pdf_integrity_service.dart';

Future<Uint8List> generateRelanceAmiable(RelanceAmiableData data) async {
  final pdf = pw.Document();

  final hashPrefix = PdfIntegrityService.computeCanonicalHash(
    serialId: data.serialId,
    residentNom: data.nomCoproprietaire,
    appartementNum: data.numeroLotAppartement,
    periode: '${data.anneeCiblePaiement}-${data.moisCiblePaiement}',
    datePaiementIso: 'none',
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
            pw.Center(
              child: pw.Text("COMMUNICATION DE LA RÉSIDENCE L'AMANDIER B", style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
            ),
            pw.SizedBox(height: 20),
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text('Bouskoura, le ${data.dateGenerationSysteme}', style: mainTextStyle),
            ),
            pw.SizedBox(height: 20),
            pw.Text("À l'attention très cordiale de : ${data.nomCoproprietaire}", style: mainTextStyle),
            pw.Text('Résident(e) du lot : ${data.numeroLotAppartement}', style: mainTextStyle),
            pw.SizedBox(height: 10),
            pw.Text('Objet : Petit rappel amical concernant la cotisation du mois de ${data.moisCiblePaiement}', style: boldTextStyle),
            pw.SizedBox(height: 20),
            pw.Text('Chère voisine, cher voisin,', style: mainTextStyle),
            pw.SizedBox(height: 10),
            pw.Text("La Résidence l'Amandier B est bien plus qu'un simple ensemble immobilier ; c'est un véritable lieu de vie, de sérénité et de partage que nous avons la chance d'habiter. L'harmonie de nos espaces communs, la beauté de nos jardins, et la sécurité de nos familles sont le fruit de notre effort collectif et de notre esprit de famille.", style: mainTextStyle),
            pw.SizedBox(height: 10),
            pw.Text("C'est dans cet esprit d'entraide et de grande courtoisie que je me permets de vous adresser ce petit mot. En effectuant la mise à jour mensuelle de notre application de gestion, j'ai remarqué que votre participation forfaitaire aux charges de notre communauté, d'un montant de ${data.cotisationMensuelleNumerique} MAD, n'a pas encore été enregistrée pour la période de ${data.moisCiblePaiement} ${data.anneeCiblePaiement}.", style: mainTextStyle),
            pw.SizedBox(height: 10),
            pw.Text("Nous sommes tous conscients que la vie quotidienne est parfois très rythmée et qu'un simple oubli administratif est très vite arrivé. C'est précisément pour vous faciliter ces petites démarches que nous avons déployé cette application. À titre d'information, et pour assurer une gestion fluide de nos dépenses communes (notamment pour nos prestataires d'entretien), le Président de la résidence a instauré la bonne habitude de régler sa propre cotisation le premier jour de chaque mois. Cette dynamique nous aide énormément à planifier nos budgets.", style: mainTextStyle),
            pw.SizedBox(height: 10),
            pw.Text("Si vous avez déjà procédé au règlement entre le moment où ce document a été généré et sa réception, je vous prie de n'en tenir aucun compte et je vous remercie chaleureusement pour votre réactivité. Dans le cas contraire, je vous serais très reconnaissant de bien vouloir régulariser cette situation via l'application à votre meilleure convenance.", style: mainTextStyle),
            pw.SizedBox(height: 10),
            pw.Text("Je reste naturellement à votre entière disposition pour échanger, autour d'un café ou via la messagerie de l'application, si vous avez la moindre question ou suggestion pour améliorer notre beau cadre de vie.", style: mainTextStyle),
            pw.SizedBox(height: 20),
            pw.Text('Avec toute mon amitié et mes salutations les plus respectueuses,', style: mainTextStyle),
            pw.Text('Votre Syndic dévoué,', style: mainTextStyle),
            pw.Text(data.syndicIdentite, style: boldTextStyle),
            pw.Spacer(),
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
                    qrImage,
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

  return await pdf.save();
}
