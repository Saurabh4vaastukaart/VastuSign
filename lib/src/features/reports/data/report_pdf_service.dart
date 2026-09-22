import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../domain/vastu_report.dart';

class ReportPdfService {
  const ReportPdfService();

  Future<File> generateAndSave(VastuReport report) async {
    final document = pw.Document(
      title: '${report.title} - ${report.propertyLabel}',
      author: 'VastuSign',
      creator: 'VastuSign Mobile',
    );
    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        header: (context) => pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('VastuSign', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.Text(report.id, style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
          ],
        ),
        footer: (context) => pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text('Page ${context.pageNumber} of ${context.pagesCount}', style: const pw.TextStyle(fontSize: 9)),
        ),
        build: (context) => [
          pw.SizedBox(height: 24),
          pw.Text(report.title, style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 5),
          pw.Text(report.propertyLabel, style: const pw.TextStyle(fontSize: 14, color: PdfColors.grey700)),
          pw.SizedBox(height: 20),
          pw.Container(
            padding: const pw.EdgeInsets.all(18),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromHex('#F3F6F4'),
              borderRadius: pw.BorderRadius.circular(10),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                  pw.Text('Overall Vastu score', style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey700)),
                  pw.Text('${report.overallScore}/100', style: pw.TextStyle(fontSize: 30, fontWeight: pw.FontWeight.bold)),
                ]),
                pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.end, children: [
                  pw.Text('${report.observations.length} areas analysed'),
                  pw.Text('Generated ${_date(report.generatedAt)}'),
                ]),
              ],
            ),
          ),
          pw.SizedBox(height: 24),
          pw.Text('Priority action plan', style: pw.TextStyle(fontSize: 19, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          ...report.observations.map((observation) {
            final item = observation.measurement;
            return pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 12),
              padding: const pw.EdgeInsets.all(14),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
                    pw.Text('${observation.priority}. ${item.category.name}', style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold)),
                    pw.Text('${item.direction} | ${item.angle.toStringAsFixed(1)} deg | ${item.score}/100'),
                  ]),
                  pw.SizedBox(height: 8),
                  pw.Text('Possible impact', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ...observation.effects.map((value) => pw.Bullet(text: value)),
                  pw.SizedBox(height: 6),
                  pw.Text('Recommended action', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ...observation.remedies.map((value) => pw.Bullet(text: value)),
                  pw.SizedBox(height: 6),
                  pw.Text('Correction difficulty: ${observation.difficulty.label}'),
                ],
              ),
            );
          }),
          pw.SizedBox(height: 12),
          pw.Divider(),
          pw.Text(
            'Important: This report is belief-based guidance produced from a versioned starter rule set. Confirm measurements and consult a qualified professional before structural, financial, health, or safety decisions.',
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
          ),
          pw.SizedBox(height: 6),
          pw.Text('Rule set: ${report.ruleSetVersion} | Template: ${report.templateVersion}', style: const pw.TextStyle(fontSize: 9)),
        ],
      ),
    );

    final directory = await getApplicationDocumentsDirectory();
    final reports = Directory(p.join(directory.path, 'reports'));
    await reports.create(recursive: true);
    final file = File(p.join(reports.path, '${report.id}.pdf'));
    await file.writeAsBytes(await document.save(), flush: true);
    return file;
  }

  String _date(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    return '$day/$month/${value.year}';
  }
}
