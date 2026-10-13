import 'package:flutter/material.dart';
import '../core/constants/api_endpoints.dart';
import '../core/constants/app_colors.dart';

class ServiceImage extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;

  const ServiceImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    final normalized = ApiEndpoints.normalizeImageUrl(imageUrl);
    final radius = borderRadius ?? BorderRadius.circular(8);

    Widget defaultFallback() {
      return errorWidget ??
          Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: radius,
              border: Border.all(color: AppColors.border),
            ),
            child: const Center(
              child: Icon(
                Icons.image_outlined,
                color: AppColors.textSecondary,
                size: 24,
              ),
            ),
          );
    }

    if (normalized == null || normalized.isEmpty) {
      return defaultFallback();
    }

    return ClipRRect(
      borderRadius: radius,
      child: Image.network(
        normalized,
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return placeholder ??
              Container(
                width: width,
                height: height,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: radius,
                ),
                child: const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              );
        },
        errorBuilder: (context, error, stackTrace) => defaultFallback(),
      ),
    );
  }
}
