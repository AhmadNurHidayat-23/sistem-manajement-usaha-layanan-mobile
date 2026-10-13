import '../core/constants/api_endpoints.dart';

class ServiceModel {
  final int id;
  final String name;
  final String? description;
  final double price;
  final String unit;
  final int? estimatedDuration;
  final String? durationFormatted;
  final String? serviceType;
  final bool isWeightBased;
  final int? branchId;
  final String? categoryName;
  final String? branchName;
  final String? imageUrl;
  final List<String> images;

  ServiceModel({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    this.unit = 'sesi',
    this.estimatedDuration,
    this.durationFormatted,
    this.serviceType,
    this.isWeightBased = false,
    this.branchId,
    this.categoryName,
    this.branchName,
    this.imageUrl,
    this.images = const [],
  });

  /// Mengambil URL thumbnail utama (imageUrl jika tersedia, atau gambar pertama dari images).
  String? get primaryImageUrl {
    if (imageUrl != null && imageUrl!.trim().isNotEmpty) {
      return imageUrl;
    }
    if (images.isNotEmpty) {
      return images.first;
    }
    return null;
  }

  /// URL thumbnail utama yang sudah dinormalisasi dengan baseUrl aktif.
  String? get normalizedPrimaryImageUrl => ApiEndpoints.normalizeImageUrl(primaryImageUrl);

  /// Daftar URL images yang sudah dinormalisasi dengan baseUrl aktif.
  List<String> get normalizedImages =>
      images.map((img) => ApiEndpoints.normalizeImageUrl(img) ?? img).toList();

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    final unitStr = json['unit']?.toString() ?? 'sesi';
    final weightBased = json['is_weight_based'] == true ||
        unitStr.toLowerCase() == 'kg' ||
        unitStr.toLowerCase() == 'kilogram';

    // Parsing daftar images (mendukung List<Map> dengan key image_url atau List<String>)
    final rawImages = json['images'];
    final List<String> parsedImages = [];
    if (rawImages is List) {
      for (final item in rawImages) {
        if (item is Map) {
          final url = item['image_url']?.toString();
          if (url != null && url.trim().isNotEmpty) {
            parsedImages.add(url.trim());
          }
        } else if (item is String && item.trim().isNotEmpty) {
          parsedImages.add(item.trim());
        }
      }
    }

    return ServiceModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      price: (json['price'] != null) ? double.tryParse(json['price'].toString()) ?? 0.0 : 0.0,
      unit: unitStr,
      estimatedDuration: json['estimated_duration'] as int?,
      durationFormatted: json['duration_formatted']?.toString(),
      serviceType: json['service_type']?.toString(),
      isWeightBased: weightBased,
      branchId: json['branch']?['id'] as int? ?? json['branch_id'] as int?,
      categoryName: json['category']?['name']?.toString(),
      branchName: json['branch']?['name']?.toString(),
      imageUrl: json['image_url']?.toString(),
      images: parsedImages,
    );
  }
}
