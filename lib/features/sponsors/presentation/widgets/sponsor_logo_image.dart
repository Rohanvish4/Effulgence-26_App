import 'dart:convert';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:effulgence26_mobile_app/core/utils/url_utils.dart';
import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';

class SponsorLogoImage extends StatelessWidget {
  final String logoUrl;
  final double height;
  final double width;
  final double fallbackIconSize;

  const SponsorLogoImage({
    super.key,
    required this.logoUrl,
    required this.height,
    required this.width,
    this.fallbackIconSize = 64,
  });

  bool get _isDataUri =>
      logoUrl.startsWith('data:image/') && logoUrl.contains('base64,');

  Uint8List? get _decodedBytes {
    if (!_isDataUri) {
      return null;
    }

    try {
      return base64Decode(logoUrl.substring(logoUrl.indexOf(',') + 1));
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bytes = _decodedBytes;
    if (bytes != null) {
      return Image.memory(
        bytes,
        height: height,
        width: width,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.medium,
      );
    }

    if (UrlUtils.isValidUrl(logoUrl)) {
      return CachedNetworkImage(
        imageUrl: logoUrl,
        height: height,
        width: width,
        fit: BoxFit.contain,
        errorWidget: (context, url, error) => Icon(
          Icons.business,
          size: fallbackIconSize,
          color: AppColors.textSecondary,
        ),
        placeholder: (context, url) => Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.primary,
          ),
        ),
      );
    }

    return Icon(
      Icons.business,
      size: fallbackIconSize,
      color: AppColors.textSecondary,
    );
  }
}