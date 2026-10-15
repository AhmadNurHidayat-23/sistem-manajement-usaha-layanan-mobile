# SIMAUL Mobile

Aplikasi mobile berbasis Flutter untuk **SIMAUL (Sistem Manajemen Usaha Layanan)**. Aplikasi ini dirancang untuk memudahkan operasional dan interaksi dua role pengguna: **Pelanggan** dan **Karyawan (Petugas Layanan)**, yang terhubung langsung dengan backend REST API SIMAUL Web (Laravel).

---

## 1. Fitur Utama yang Tersedia

### A. Fitur Pelanggan (`customer`)
- **Katalog Layanan & Cabang**: Informasi lengkap layanan usaha dan cabang operasional yang tersedia.
- **Booking Janji Temu**: Reservasi layanan terjadwal dengan memilih cabang, tanggal, waktu, serta penggunaan kupon promo.
- **Pesanan Drop-off**: Pembuatan pesanan langsung (seperti laundry atau cuci kendaraan) dengan rincian biaya yang transparan.
- **Pemantauan Pesanan**: Pelacakan status pengerjaan pesanan dan reservasi janji temu melalui aplikasi.
- **Pembayaran Digital**: Pembayaran pesanan melalui simulasi QRIS interaktif yang dilengkapi batas waktu pembayaran (*countdown timer*).
- **Membership & Poin Loyalty**: Informasi tier keanggotaan loyalty, riwayat perolehan/penggunaan poin reward, serta aktivasi keanggotaan.

### B. Fitur Karyawan (`employee`)
- **Dashboard Operasional**: Ringkasan statistik tugas harian (total tugas, menunggu, dalam pengerjaan, dan selesai).
- **Manajemen Tugas**: Memeriksa antrean pekerjaan yang ditugaskan serta memperbarui status progres pengerjaan (*Pending* -> *In Progress* -> *Completed*).
- **Jadwal Shift**: Informasi jadwal shift kerja aktif hari ini dan jadwal shift mendatang.
- **Komisi & Performa**: Informasi akumulasi komisi bulanan serta metrik kehadiran kerja.

> **Catatan Akses:** Fitur administratif seperti pengelolaan data master usaha, laporan keuangan, dan inventaris untuk role Owner, Manajer, dan Kasir dikelola terpusat melalui portal **SIMAUL Web**.

---

## 2. Teknologi yang Digunakan

- **Framework**: [Flutter](https://flutter.dev) (Dart SDK >=3.0)
- **Komunikasi Jaringan**: Package `http` untuk permintaan data REST API
- **Penyimpanan Lokal**: Package `shared_preferences` untuk token sesi dan profil pengguna
- **Format Tanggal & Angka**: Package `intl` untuk format mata uang Rupiah (`id_ID`) dan penanggalan lokal

---

## 3. Integrasi API SIMAUL Web

Aplikasi berkomunikasi langsung dengan backend Laravel melalui protokol REST API:

1. **Konfigurasi Base URL**:
   - URL default diarahkan ke `http://10.0.2.2:8000` untuk kompatibilitas langsung dengan Android Emulator.
   - Tersedia menu **Konfigurasi Server API** pada aplikasi untuk menyesuaikan alamat IP server lokal (LAN) sesuai kebutuhan.
2. **Autentikasi Bearer Token**:
   - Berbasis Laravel Sanctum.
   - Token disimpan secara lokal di perangkat melalui `SessionManager`.
   - Setiap permintaan API menyertakan header `Authorization: Bearer <token>`.
   - Jika menerima respon `401 Unauthorized`, sesi lokal dibersihkan otomatis dan pengguna diarahkan ke layar login.
3. **Penyesuaian Media URL**:
   - URL gambar aset dan foto layanan disesuaikan secara otomatis melalui `ApiEndpoints.normalizeImageUrl()` agar dapat dimuat dengan tepat di lingkungan emulator maupun perangkat fisik.

---

## 4. Cara Menjalankan Aplikasi

Pastikan Flutter SDK telah terpasang dan lingkungan pengembangan siap digunakan.

```bash
# 1. Mengunduh dependensi proyek
flutter pub get

# 2. Menjalankan analisis kode statis
flutter analyze

# 3. Menjalankan pengujian otomatis (unit & widget tests)
flutter test

# 4. Menjalankan aplikasi pada perangkat / emulator aktif
flutter run

# 5. Membangun paket APK Debug
flutter build apk --debug
```

> **Catatan Pengujian:** Pengujian unit dan alur widget telah terotomatisasi. Verifikasi alur transaksi end-to-end secara langsung tetap disarankan menggunakan Android Emulator atau perangkat fisik yang terhubung ke server backend lokal.
