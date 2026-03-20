import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfIntegrityService {
  static String computeCanonicalHash({
    required String serialId,
    required String residentNom,
    required String appartementNum,
    required String periode,
    required String datePaiementIso,
    required String timestampGenerationIso,
  }) {
    // LAW-07 Canonical String Construction
    final canonicalString = '$serialId|$residentNom|$appartementNum|$periode|250.00|$datePaiementIso|$timestampGenerationIso';
    final bytes = utf8.encode(canonicalString);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  static String buildQrPayloadUrl(String serialId, String hash) {
    return 'https://api.amandier-b.ma/verify/$serialId?h=${hash.substring(0, 16)}';
  }

  static Future<pw.ImageProvider> renderQrCodeForPdf(String qrUrl) async {
    // Return a dummy image provider to satisfy the exact template syntax for now,
    // since the standard `BarcodeWidget` doesn't fit `pw.Image(qrImage)`.
    return pw.MemoryImage(Uint8List.fromList([
        // 1x1 black pixel GIF
        0x47, 0x49, 0x46, 0x38, 0x39, 0x61, 0x01, 0x00, 0x01, 0x00, 0x80, 0x00,
        0x00, 0x00, 0x00, 0x00, 0xFF, 0xFF, 0xFF, 0x21, 0xF9, 0x04, 0x01, 0x00,
        0x00, 0x00, 0x00, 0x2C, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x01, 0x00,
        0x00, 0x02, 0x02, 0x44, 0x01, 0x00, 0x3B
    ]));
  }
}
