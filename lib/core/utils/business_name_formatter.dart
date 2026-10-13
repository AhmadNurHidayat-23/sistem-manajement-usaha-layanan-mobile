class BusinessNameFormatter {
  /// Format nama usaha menjadi nama resmi yang disepakati:
  /// - Barbershop & Studio
  /// - Laundry & Shoe Care
  /// - Auto Care & Detailing
  ///
  /// Tanpa prefix SIMAUL dan tanpa suffix Cabang Pusat/Barat/Selatan.
  static String format(String? rawName) {
    if (rawName == null || rawName.trim().isEmpty) return '';
    final trimmed = rawName.trim();
    final lower = trimmed.toLowerCase();

    if (lower.contains('barber')) {
      return 'Barbershop & Studio';
    } else if (lower.contains('laundry') || lower.contains('shoe')) {
      return 'Laundry & Shoe Care';
    } else if (lower.contains('auto') || lower.contains('detail')) {
      return 'Auto Care & Detailing';
    }

    // Fallback: hapus prefix SIMAUL dan suffix (Cabang ...)
    String cleaned = trimmed.replaceAll(RegExp(r'^SIMAUL\s+', caseSensitive: false), '');
    cleaned = cleaned.replaceAll(RegExp(r'\s*\([^)]*Cabang[^)]*\)', caseSensitive: false), '');
    return cleaned.trim();
  }
}
