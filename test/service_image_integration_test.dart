import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simaul_mobile/core/constants/api_endpoints.dart';
import 'package:simaul_mobile/models/service_model.dart';
import 'package:simaul_mobile/widgets/service_image.dart';

void main() {
  group('ServiceModel & Image Parsing Tests', () {
    test('parses image_url and images array correctly', () {
      final json = {
        'id': 1,
        'name': 'Potong Rambut Pria',
        'price': 95000,
        'unit': 'sesi',
        'image_url': '/storage/services/barbershop/potong-rambut-pria-1.png',
        'images': [
          {
            'id': 1,
            'image_url': '/storage/services/barbershop/potong-rambut-pria-1.png',
            'sort_order': 1,
          },
          {
            'id': 2,
            'image_url': '/storage/services/barbershop/potong-rambut-pria-2.png',
            'sort_order': 2,
          },
          {
            'id': 3,
            'image_url': '/storage/services/barbershop/potong-rambut-pria-3.jpg',
            'sort_order': 3,
          },
        ],
      };

      final service = ServiceModel.fromJson(json);

      expect(service.id, 1);
      expect(service.name, 'Potong Rambut Pria');
      expect(service.imageUrl, '/storage/services/barbershop/potong-rambut-pria-1.png');
      expect(service.images.length, 3);
      expect(service.images[0], '/storage/services/barbershop/potong-rambut-pria-1.png');
      expect(service.images[1], '/storage/services/barbershop/potong-rambut-pria-2.png');
      expect(service.images[2], '/storage/services/barbershop/potong-rambut-pria-3.jpg');
      expect(service.primaryImageUrl, '/storage/services/barbershop/potong-rambut-pria-1.png');
    });

    test('primaryImageUrl falls back to first of images when image_url is null', () {
      final json = {
        'id': 2,
        'name': 'Laundry Express',
        'price': 15000,
        'unit': 'kg',
        'image_url': null,
        'images': [
          {'id': 10, 'image_url': '/storage/services/laundry/01.webp', 'sort_order': 1},
          {'id': 11, 'image_url': '/storage/services/laundry/02.png', 'sort_order': 2},
          {'id': 12, 'image_url': '/storage/services/laundry/03.jpg', 'sort_order': 3},
        ],
      };

      final service = ServiceModel.fromJson(json);

      expect(service.imageUrl, isNull);
      expect(service.images.length, 3);
      expect(service.primaryImageUrl, '/storage/services/laundry/01.webp');
    });

    test('primaryImageUrl returns null and does not crash when no images provided', () {
      final json = {
        'id': 3,
        'name': 'Layanan Polos',
        'price': 50000,
      };

      final service = ServiceModel.fromJson(json);

      expect(service.imageUrl, isNull);
      expect(service.images, isEmpty);
      expect(service.primaryImageUrl, isNull);
      expect(service.normalizedPrimaryImageUrl, isNull);
      expect(service.normalizedImages, isEmpty);
    });

    test('parses images when provided as string list', () {
      final json = {
        'id': 4,
        'name': 'Cuci Helm',
        'price': 25000,
        'images': [
          '/storage/services/auto-care/cuci-helm-1.png',
          '/storage/services/auto-care/cuci-helm-2.png',
        ],
      };

      final service = ServiceModel.fromJson(json);
      expect(service.images.length, 2);
      expect(service.primaryImageUrl, '/storage/services/auto-care/cuci-helm-1.png');
    });
  });

  group('URL Normalization Tests', () {
    test('normalizes relative path using active baseUrl', () {
      ApiEndpoints.setBaseUrl('http://10.0.2.2:8000');
      final normalized = ApiEndpoints.normalizeImageUrl('/storage/services/barbershop/sample.png');
      expect(normalized, 'http://10.0.2.2:8000/storage/services/barbershop/sample.png');
    });

    test('replaces localhost / 127.0.0.1 with active baseUrl for emulator support', () {
      ApiEndpoints.setBaseUrl('http://10.0.2.2:8000');
      final fromLocalhost = ApiEndpoints.normalizeImageUrl('http://localhost/storage/services/photo.jpg');
      expect(fromLocalhost, 'http://10.0.2.2:8000/storage/services/photo.jpg');

      final from127 = ApiEndpoints.normalizeImageUrl('http://127.0.0.1:8000/storage/services/photo.jpg');
      expect(from127, 'http://10.0.2.2:8000/storage/services/photo.jpg');
    });

    test('normalizes when baseUrl is Windows localhost', () {
      ApiEndpoints.setBaseUrl('http://127.0.0.1:8000');
      final normalized = ApiEndpoints.normalizeImageUrl('/storage/services/auto.jpg');
      expect(normalized, 'http://127.0.0.1:8000/storage/services/auto.jpg');
    });

    test('keeps external https URLs unchanged', () {
      const ext = 'https://cdn.example.com/images/banner.png';
      expect(ApiEndpoints.normalizeImageUrl(ext), ext);
    });

    test('returns null for empty or null inputs', () {
      expect(ApiEndpoints.normalizeImageUrl(null), isNull);
      expect(ApiEndpoints.normalizeImageUrl('   '), isNull);
    });
  });

  group('Reusable ServiceImage Widget Tests', () {
    testWidgets('renders fallback placeholder cleanly when imageUrl is null', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ServiceImage(imageUrl: null, width: 80, height: 80),
          ),
        ),
      );

      expect(find.byIcon(Icons.image_outlined), findsOneWidget);
    });

    testWidgets('renders fallback placeholder cleanly when imageUrl is empty', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ServiceImage(imageUrl: '', width: 80, height: 80),
          ),
        ),
      );

      expect(find.byIcon(Icons.image_outlined), findsOneWidget);
    });
  });

  group('Katalog & Service Dataset Integrity Verification', () {
    test('18 services in 3 categories with exactly 3 images each (total 54 images)', () {
      final categories = {
        'Barbershop': [
          'Potong Rambut Pria',
          'Potong Rambut & Styling',
          'Cukur & Rapikan Jenggot',
          'Perawatan Kulit Kepala',
          'Pewarnaan Rambut',
          'Paket Grooming Lengkap',
        ],
        'Laundry': [
          'Cuci Kering Setrika',
          'Laundry Express',
          'Deep Clean Sepatu',
          'Dry Clean Jas & Kebaya',
          'Cuci Bed Cover',
          'Cuci Karpet',
        ],
        'Auto Care': [
          'Cuci Mobil Premium',
          'Detailing Mobil Lengkap',
          'Detailing Interior',
          'Nano Ceramic Coating',
          'Cuci Helm',
          'Perawatan Eksterior Mobil',
        ],
      };

      int totalServices = 0;
      int totalImages = 0;

      for (final entry in categories.entries) {
        final categoryName = entry.key;
        final serviceNames = entry.value;

        expect(serviceNames.length, 6, reason: '$categoryName harus memiliki tepat 6 layanan.');

        for (final name in serviceNames) {
          totalServices++;
          final slug = name.toLowerCase().replaceAll(' ', '-').replaceAll('&', 'dan');

          final rawImages = [
            {'id': totalImages + 1, 'image_url': '/storage/services/$slug/01.webp', 'sort_order': 1},
            {'id': totalImages + 2, 'image_url': '/storage/services/$slug/02.png', 'sort_order': 2},
            {'id': totalImages + 3, 'image_url': '/storage/services/$slug/03.jpg', 'sort_order': 3},
          ];

          final service = ServiceModel.fromJson({
            'id': totalServices,
            'name': name,
            'category': {'name': categoryName},
            'price': 50000,
            'image_url': rawImages[0]['image_url'],
            'images': rawImages,
          });

          expect(service.imageUrl, isNotNull);
          expect(service.primaryImageUrl, isNotNull);
          expect(service.images.length, 3);
          expect(service.primaryImageUrl, contains(slug));

          totalImages += service.images.length;
        }
      }

      expect(totalServices, 18, reason: 'Total layanan harus tepat 18');
      expect(totalImages, 54, reason: 'Total gambar harus tepat 54');
    });
  });
}