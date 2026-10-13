class ApiEndpoints {
  static const String defaultEmulatorUrl = 'http://10.0.2.2:8000';
  static const String defaultLocalhostUrl = 'http://127.0.0.1:8000';

  static String baseUrl = defaultEmulatorUrl;

  static void setBaseUrl(String url) {
    if (url.endsWith('/')) {
      baseUrl = url.substring(0, url.length - 1);
    } else {
      baseUrl = url;
    }
  }

  /// Normalisasi URL gambar backend (localhost / 127.0.0.1 / path relatif)
  /// agar dapat diakses dari Android Emulator maupun Windows/Device.
  static String? normalizeImageUrl(String? rawUrl) {
    if (rawUrl == null || rawUrl.trim().isEmpty) return null;
    final trimmed = rawUrl.trim();

    try {
      final uri = Uri.parse(trimmed);
      final currentBase = Uri.parse(baseUrl);

      if (uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https')) {
        if (uri.host == 'localhost' || uri.host == '127.0.0.1' || uri.host == '10.0.2.2') {
          return Uri(
            scheme: currentBase.scheme,
            userInfo: currentBase.userInfo.isNotEmpty ? currentBase.userInfo : null,
            host: currentBase.host,
            port: currentBase.hasPort ? currentBase.port : null,
            path: uri.path,
            query: uri.hasQuery ? uri.query : null,
            fragment: uri.hasFragment ? uri.fragment : null,
          ).toString();
        }
        return trimmed;
      }

      final cleanPath = trimmed.startsWith('/') ? trimmed : '/$trimmed';
      return '$baseUrl$cleanPath';
    } catch (_) {
      return trimmed;
    }
  }

  static String get login => '$baseUrl/api/mobile/login';
  static String get logout => '$baseUrl/api/mobile/logout';
  static String get me => '$baseUrl/api/mobile/me';
  static String get branches => '$baseUrl/api/mobile/branches';
  static String get services => '$baseUrl/api/mobile/services';

  // Customer
  static String get customerBookings => '$baseUrl/api/mobile/customer/bookings';
  static String customerBookingDetail(int id) => '$baseUrl/api/mobile/customer/bookings/$id';

  static String get customerOrders => '$baseUrl/api/mobile/customer/orders';
  static String customerOrderDetail(int id) => '$baseUrl/api/mobile/customer/orders/$id';

  static String get customerPromos => '$baseUrl/api/mobile/customer/promos';
  static String get customerMembership => '$baseUrl/api/mobile/customer/membership';
  static String get customerMembershipRegister => '$baseUrl/api/mobile/customer/membership/register';

  static String get customerPayments => '$baseUrl/api/mobile/customer/payments';
  static String customerPaymentDetail(int id) => '$baseUrl/api/mobile/customer/payments/$id';
  static String customerPaymentStatus(int id) => '$baseUrl/api/mobile/customer/payments/$id/status';
  static String customerPaymentSimulate(int id) => '$baseUrl/api/mobile/customer/payments/$id/simulate';

  // Employee
  static String get employeeDashboard => '$baseUrl/api/mobile/employee/dashboard';
  static String get employeeTasks => '$baseUrl/api/mobile/employee/tasks';
  static String employeeTaskDetail(int id) => '$baseUrl/api/mobile/employee/tasks/$id';
  static String employeeTaskStatus(int id) => '$baseUrl/api/mobile/employee/tasks/$id/status';
}