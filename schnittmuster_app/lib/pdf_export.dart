import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PatternPdfExporter {
  static const double _mmToPt = 72.0 / 25.4;

  static double mm(double value) => value * _mmToPt;

  Future<Uint8List> buildCalibrationPage() async {
    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(mm(15)),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Schnittmuster-App – Drucktest 1:1',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: mm(6)),
              pw.Text(
                'Bitte beim Drucken 100 % / Tatsächliche Größe wählen. Keine Seitenanpassung verwenden.',
                style: const pw.TextStyle(fontSize: 10),
              ),
              pw.SizedBox(height: mm(12)),
              pw.Text('Kontrollquadrat 100 × 100 mm', style: const pw.TextStyle(fontSize: 10)),
              pw.SizedBox(height: mm(3)),
              pw.Container(
                width: mm(100),
                height: mm(100),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(width: 0.8),
                ),
                child: pw.Center(
                  child: pw.Text('100 mm × 100 mm', style: const pw.TextStyle(fontSize: 11)),
                ),
              ),
              pw.SizedBox(height: mm(12)),
              pw.Text('Kontrolllinie 200 mm', style: const pw.TextStyle(fontSize: 10)),
              pw.SizedBox(height: mm(3)),
              pw.Container(
                width: mm(200),
                height: 1,
                color: PdfColors.black,
              ),
              pw.SizedBox(height: mm(2)),
              pw.Text('200 mm', style: const pw.TextStyle(fontSize: 9)),
            ],
          );
        },
      ),
    );

    return doc.save();
  }
}
