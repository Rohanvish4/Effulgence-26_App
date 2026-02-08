import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import '../../features/auth/domain/entity/user_entity.dart';

class PdfGeneratorService {
  Future<Uint8List> generateIdCardPdf(UserEntity user) async {
    final pdf = pw.Document();

    // Load Profile Image
    pw.MemoryImage? profileImage;
    if (user.imageUrl != null && user.imageUrl!.isNotEmpty) {
      try {
        final response = await http.get(Uri.parse(user.imageUrl!));
        if (response.statusCode == 200) {
          profileImage = pw.MemoryImage(response.bodyBytes);
        }
      } catch (e) {
        // Fallback to placeholder if net fail
      }
    }

    // Colors (Mapped from AppColors)
    final bgSecondary = PdfColor.fromInt(0xFF16181D);
    final primary = PdfColor.fromInt(0xFF2DD4BF);
    final error = PdfColor.fromInt(0xFFFB7185);
    final success = PdfColor.fromInt(0xFF2DD4BF);
    final surface = PdfColor.fromInt(0xFF16181D);
    final textSecondary = PdfColor.fromInt(0xFF94A3B8);
    final textMuted = PdfColor.fromInt(0xFF64748B);
    final white = PdfColor.fromInt(0xFFFFFFFF);
    final black = PdfColor.fromInt(0xFF000000);

    // Helper to add opacity
    PdfColor withOpacity(PdfColor color, double opacity) {
      return PdfColor(color.red, color.green, color.blue, opacity);
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Container(
              width: 320,
              decoration: pw.BoxDecoration(
                color: bgSecondary,
                borderRadius: pw.BorderRadius.circular(28),
                border: pw.Border.all(
                  color: withOpacity(primary, 0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  pw.BoxShadow(
                    color: withOpacity(primary, 0.15),
                    blurRadius: 30,
                    spreadRadius: -10,
                  ),
                ],
              ),
              child: pw.Stack(
                children: [
                  // Grid Background
                  pw.Positioned.fill(
                    child: pw.Opacity(
                      opacity: 0.05,
                      child: pw.CustomPaint(
                        painter: (canvas, size) {
                          canvas.setStrokeColor(primary);
                          canvas.setLineWidth(0.5);
                          for (double i = 0; i < size.x; i += 20) {
                            canvas.moveTo(i, 0);
                            canvas.lineTo(i, size.y);
                          }
                          for (double i = 0; i < size.y; i += 20) {
                            canvas.moveTo(0, i);
                            canvas.lineTo(size.x, i);
                          }
                          canvas.strokePath();
                        },
                      ),
                    ),
                  ),
                  pw.Column(
                    mainAxisSize: pw.MainAxisSize.min,
                    children: [
                      // Header
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 20,
                        ),
                        decoration: pw.BoxDecoration(
                          color: withOpacity(primary, 0.05),
                          border: pw.Border(
                            bottom: pw.BorderSide(
                              color: withOpacity(primary, 0.1),
                            ),
                          ),
                        ),
                        child: pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text(
                                  'OFFICIAL_PASS',
                                  style: pw.TextStyle(
                                    color: primary,
                                    letterSpacing: 2,
                                    fontSize: 8,
                                  ),
                                ),
                                pw.Text(
                                  "EFFULGENCE'26",
                                  style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    color: white,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            // Security Badge
                            pw.Container(
                              padding: const pw.EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: pw.BoxDecoration(
                                color: withOpacity(error, 0.1),
                                borderRadius: pw.BorderRadius.circular(4),
                                border: pw.Border.all(
                                  color: withOpacity(error, 0.3),
                                ),
                              ),
                              child: pw.Text(
                                user.role.toUpperCase(),
                                style: pw.TextStyle(
                                  color: error,
                                  fontSize: 8,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      pw.SizedBox(height: 20),

                      // Profile Section
                      pw.Padding(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 24),
                        child: pw.Row(
                          children: [
                            pw.Container(
                              padding: const pw.EdgeInsets.all(2),
                              width: 74, // Radius 35 * 2 + padding
                              height: 74,
                              decoration: pw.BoxDecoration(
                                shape: pw.BoxShape.circle,
                                border: pw.Border.all(color: primary, width: 1),
                              ),
                              child: pw.Container(
                                decoration: pw.BoxDecoration(
                                  shape: pw.BoxShape.circle,
                                  color: surface,
                                  image: profileImage != null
                                      ? pw.DecorationImage(
                                          image: profileImage,
                                          fit: pw.BoxFit.cover,
                                        )
                                      : null,
                                ),
                              ),
                            ),
                            pw.SizedBox(width: 16),
                            pw.Expanded(
                              child: pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Text(
                                    user.name.toUpperCase(),
                                    style: pw.TextStyle(
                                      color: white,
                                      fontWeight: pw.FontWeight.bold,
                                      fontSize: 16,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  pw.Text(
                                    user.collegeName ?? 'EXTERNAL_INSTITUTE',
                                    style: pw.TextStyle(
                                      color: textSecondary,
                                      fontSize: 10,
                                    ),
                                  ),
                                  pw.SizedBox(height: 4),
                                  pw.Row(
                                    children: [
                                      pw.Container(
                                        width: 6,
                                        height: 6,
                                        decoration: pw.BoxDecoration(
                                          color: success,
                                          shape: pw.BoxShape.circle,
                                        ),
                                      ),
                                      pw.SizedBox(width: 6),
                                      pw.Text(
                                        "VERIFIED_ACCESS",
                                        style: pw.TextStyle(
                                          color: success,
                                          fontSize: 8,
                                          fontWeight: pw.FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      pw.SizedBox(height: 20),

                      // QR Section
                      pw.Container(
                        padding: const pw.EdgeInsets.all(12),
                        decoration: pw.BoxDecoration(
                          color: white,
                          borderRadius: pw.BorderRadius.circular(16),
                          boxShadow: [
                            pw.BoxShadow(
                              color: withOpacity(primary, 0.2),
                              blurRadius: 15,
                            ),
                          ],
                        ),
                        child: pw.BarcodeWidget(
                          color: black,
                          barcode: pw.Barcode.qrCode(),
                          data: user.effulgenceId ?? 'NO_DATA',
                          width: 140,
                          height: 140,
                        ),
                      ),
                      pw.SizedBox(height: 20),

                      // Info Grid
                      pw.Padding(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 24),
                        child: pw.Column(
                          children: [
                            pw.Row(
                              children: [
                                _buildDataField(
                                  "REGISTRATION_ID",
                                  user.effulgenceId ?? 'PENDING',
                                  labelColor: textMuted,
                                  valueColor: primary,
                                ),
                                _buildDataField(
                                  "USER_CLASS",
                                  user.isInternalUser
                                      ? "INTERNAL"
                                      : "OUTSTATION",
                                  labelColor: textMuted,
                                  valueColor: primary,
                                ),
                              ],
                            ),
                            pw.SizedBox(height: 12),
                            pw.Row(
                              children: [
                                _buildDataField(
                                  "VALID_UNTIL",
                                  "18 March 2026",
                                  labelColor: textMuted,
                                  valueColor: primary,
                                ),
                                _buildDataField(
                                  "SECTOR",
                                  "ALL_ACCESS",
                                  labelColor: textMuted,
                                  valueColor: primary,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      pw.SizedBox(height: 24),

                      // Footer Badge
                      pw.Container(
                        width: double.infinity,
                        padding: const pw.EdgeInsets.symmetric(vertical: 12),
                        decoration: pw.BoxDecoration(
                          color: withOpacity(black, 0.4),
                        ),
                        child: pw.Center(
                          child: pw.Text(
                            "AUTHENTICATED_BY_SYSTEM_EFFULGENCE",
                            style: pw.TextStyle(
                              fontSize: 7,
                              color: textMuted,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildDataField(
    String label,
    String value, {
    required PdfColor labelColor,
    required PdfColor valueColor,
  }) {
    return pw.Expanded(
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 7,
              color: labelColor,
              letterSpacing: 1,
            ),
          ),
          pw.Text(
            value.toUpperCase(),
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
