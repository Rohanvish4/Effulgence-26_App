
import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:effulgence26_mobile_app/core/theme/app_colors.dart';

class PDFViewerPage extends StatelessWidget {
  final String url;
  final String title;

  const PDFViewerPage({super.key, required this.url, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: const TextStyle(color: Colors.white)),
        backgroundColor: AppColors.bgPrimary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: const PDF().fromUrl(
        url,
        placeholder: (progress) => Center(child: Text('$progress %')),
        errorWidget: (error) => Center(child: Text("Failed to load PDF: $error")),
      ),
    );
  }
}
