import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class WidgetToPdfService {
  Future<Uint8List> captureAndGeneratePdf(GlobalKey key) async {
    try {
      // 1. Capture the Widget
      final context = key.currentContext;
      if (context == null) {
        throw StateError('Widget is not mounted. Cannot capture.');
      }
      RenderRepaintBoundary boundary =
          context.findRenderObject() as RenderRepaintBoundary;

      // High-resolution capture (3.0 ratio = 300+ DPI equivalent)
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);

      ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      if (byteData == null) {
        throw StateError('Failed to convert widget image to byte data.');
      }
      Uint8List pngBytes = byteData.buffer.asUint8List();

      // 2. Define Custom Size
      // We match the exact dimensions used in your IdCardWidget (320 width)
      final double width = 320;
      final double height = 520;

      final pdf = pw.Document();
      final pdfImage = pw.MemoryImage(pngBytes);

      pdf.addPage(
        pw.Page(
          // Set custom format with zero margins
          pageFormat: PdfPageFormat(width, height, marginAll: 0),
          build: (pw.Context context) {
            return pw.FullPage(
              ignoreMargins: true,
              child: pw.Image(pdfImage, fit: pw.BoxFit.fill),
            );
          },
        ),
      );

      return pdf.save();
    } catch (e) {
      debugPrint("Capture Error: $e");
      rethrow;
    }
  }
}
