# Sehat Bersama Smart Village

Aplikasi mobile Flutter untuk pencarian lokasi Rumah Sakit, Puskesmas, dan Klinik dengan **LBS** dan **Geofencing**.

Dokumen analisis kebutuhan, UML, dan arsitektur: [`docs/ANALISIS_DAN_DESAIN.md`](docs/ANALISIS_DAN_DESAIN.md)

## Fitur (sesuai 10 layar desain)
1. Welcome (Mulai / Masuk)
2. Beranda: pencarian, kategori, layanan terdekat
3. Peta Lokasi: marker, posisi pengguna, lingkaran geofence, filter
4. Daftar Lokasi: filter kategori (Semua, Rumah Sakit, Puskesmas, Klinik)
5. Detail Fasilitas: rating, status buka, alamat, jenis pelayanan, favorit
6. Rute: jalur, estimasi mobil / jalan / motor, Mulai Navigasi
7. Favorit
8. Profil: Lokasi Saya, Notifikasi (on/off + radius), Bahasa, Bantuan, Tentang, Keluar
9. Layar "Anda Masuk Area Geofencing" (peta + radius + kartu)
10. Notifikasi lokal saat masuk area (tampil di lock screen)

## Cara menjalankan
Prasyarat: Flutter 3.27 atau lebih baru.

```bash
# 1. Buat folder platform (android/ ios/) di dalam folder proyek ini
flutter create . --project-name sehat_bersama --org com.example

# 2. Pasang dependensi
flutter pub get

# 3. Jalankan
flutter run
```

### Konfigurasi Android
`android/app/src/main/AndroidManifest.xml` (di dalam `<manifest>`, sebelum `<application>`):
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
```
Dan di dalam `<manifest>` tambahkan agar tautan navigasi dapat dibuka:
```xml
<queries>
  <intent>
    <action android:name="android.intent.action.VIEW"/>
    <data android:scheme="https"/>
  </intent>
</queries>
```
`android/app/build.gradle` (atau `build.gradle.kts`): aktifkan *core library desugaring* (dibutuhkan `flutter_local_notifications`):
```gradle
android {
    compileOptions {
        coreLibraryDesugaringEnabled true
        sourceCompatibility JavaVersion.VERSION_1_8
        targetCompatibility JavaVersion.VERSION_1_8
    }
}
dependencies {
    coreLibraryDesugaring 'com.android.tools:desugar_jdk_libs:2.1.4'
}
```
Pastikan `minSdkVersion` minimal 21 dan `compileSdk` 34 ke atas.

### Konfigurasi iOS
`ios/Runner/Info.plist`:
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Lokasi digunakan untuk mencari fasilitas kesehatan terdekat dan geofencing.</string>
<key>LSApplicationQueriesSchemes</key>
<array><string>https</string></array>
```

## Menguji Geofencing
Data fasilitas berada di sekitar titik pusat desa (-6.5944, 106.7892).
1. Buka tab **Peta**.
2. **Tekan lama** pada peta di dekat sebuah marker (jarak ≤ radius, default 500 m). Posisi pengguna berpindah (mode simulasi).
3. Layar **Anda Masuk Area Geofencing** muncul dan notifikasi lokal dikirim.
4. Atur radius/notifikasi di **Profil → Notifikasi**. Ketuk label oranye pada peta atau tombol *Gunakan GPS* untuk kembali ke GPS asli.

Emulator Android: gunakan *Extended controls → Location* untuk menggeser posisi GPS.

## Unit test
```bash
flutter test
```

## Catatan
- Peta memakai tile OpenStreetMap (butuh internet, tanpa API key). Untuk produksi, ikuti kebijakan penggunaan tile OSM atau gunakan penyedia tile sendiri.
- Rute memakai server demo OSRM; bila gagal, garis lurus perkiraan ditampilkan.
- Data fasilitas berupa data dummy di `lib/data/facility_data.dart`, mudah diganti dengan API.
