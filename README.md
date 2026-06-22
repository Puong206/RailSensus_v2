# 🚂 RailSensus — Platform Crowdsourcing Sensus Kereta Api

<p align="center">
  <img src="frontend/assets/images/RailSensus_Logo.png" alt="RailSensus Logo" width="200"/>
</p>

**RailSensus** adalah aplikasi mobile berbasis crowdsourcing yang memungkinkan pengguna untuk melakukan sensus dan pelaporan kondisi sarana perkeretaapian di Indonesia secara kolaboratif dan real-time.

---

## 📋 Problem Statement

Komunitas pecinta kereta api (Railfans) di Indonesia memiliki antusiasme yang sangat tinggi dalam memantau dan mencatat pergerakan sarana lokomotif dan kereta api (*train spotting* atau *dinasan harian*). Namun, aktivitas pendataan yang dilakukan oleh komunitas saat ini masih menghadapi kendala utama:

1. **Data Sporadis & Tidak Terstruktur** — Informasi mengenai lokomotif apa yang menarik rangkaian kereta tertentu saat ini hanya dibagikan secara manual melalui grup obrolan (WhatsApp/Telegram) atau media sosial. Laporan ini dengan cepat tenggelam oleh tumpukan pesan lain dan sangat sulit untuk diarsip atau dicari kembali.
2. **Rawan Misinformasi (Tidak Ada Validasi)** — Laporan pandangan mata yang beredar seringkali tidak disertai bukti, sehingga rawan terjadi misinformasi, salah identifikasi nomor sarana, atau bahkan laporan fiktif (hoaks) tanpa ada cara untuk memverifikasinya.
3. **Pencatatan Geografis yang Manual** — Saat melaporkan pergerakan kereta, railfans harus mengetik lokasi stasiun secara manual yang rentan terhadap typo, tidak presisi, dan tidak standar.

**RailSensus** hadir sebagai solusi inovatif untuk mendigitalisasi hobi *train spotting* ini ke dalam sebuah platform terstruktur. Menggunakan pendekatan **crowdsourcing**, RailSensus memusatkan pelaporan dinasan kereta secara real-time dengan dukungan penarikan lokasi otomatis terintegrasi, menyehatkan ekosistem informasi komunitas dengan sistem **Trust Score** (voting validitas), serta membersihkan data usang secara otomatis setelah 12 jam untuk memastikan informasi yang disajikan selalu *fresh* dan akurat.

---

## ✨ Daftar Fitur

### 🔐 Autentikasi & Profil Dinamis
- Registrasi dan login pengguna dengan perlindungan JWT & bcrypt.
- Manajemen profil (edit username, email, password).
- Upload foto profil dengan fitur fallback ke Default Avatar lokal jika foto dihapus.
- Halaman "Galeri Kontribusi" yang memuat seluruh portofolio foto pengguna.

### 🚄 Manajemen Sarana Lokomotif (CRUDS)
- Daftar ensiklopedia lokomotif dengan pencarian dan paginasi.
- Informasi detail sarana: Depo induk, livery, sumber tenaga, dan status operasi.
- Otorisasi kepemilikan: Pengguna dapat mengedit/menghapus data & foto yang mereka unggah sendiri.
- Galeri kolaboratif: Semua pengguna dapat menambahkan foto pada sarana lokomotif yang ada.

### 📋 Sensus Kereta Api & Hybrid Geolocation
- Form pelaporan dinasan kereta dengan validasi status (lokomotif Tidak Siap Operasi otomatis ditolak).
- Cascading Dropdown untuk pemilihan Nama dan Nomor Kereta Api.
- Smart Geolocation: Penarikan lokasi otomatis menggunakan Overpass API (radius 10KM untuk mendeteksi nama stasiun terdekat), dengan fallback ke Nominatim API (mendeteksi nama daerah) jika berada di jalur terpencil.
- Fallback foto bukti pengamatan otomatis menggunakan foto dari master lokomotif jika user tidak mengunggah foto lapangan.
- Data Expiry: Sensus otomatis kedaluwarsa dan terhapus setelah 12 jam via Cron Job.

### 🛡️ Moderasi Komunitas & Panel Admin
- Trust Voting: Mekanisme Valid/Invalid oleh komunitas untuk menentukan keakuratan laporan sensus.
- Sistem Pelaporan (Report): Pengguna dapat melaporkan (Ajukan Hapus) data/foto yang melanggar milik orang lain.
- Dashboard Admin bergaya Bento UI dengan statistik komprehensif.
- Manajemen Master Data (Depo & Kereta) dan persetujuan penolakan/penghapusan data dari laporan user.

### 🎨 UI/UX & Testing
- Desain antarmuka Material modern dengan color palette khas Navy (#153D77).
- Efek visual responsif: Shimmer loading, kustomisasi Snackbar & Dialog, serta transisi Splash Screen.
- Didukung oleh 58 Test Cases komprehensif (Backend CRUD, Autentikasi, dan Error Handling).

---

## 🛠️ Teknologi yang Digunakan

| Komponen | Teknologi |
|----------|-----------|
| **Frontend** | Flutter (Dart), BLoC Pattern (State Management), GoRouter, Dio |
| **Backend** | Node.js, Express.js |
| **Database** | MySQL, Sequelize ORM |
| **Keamanan** | JWT (JSON Web Token), bcrypt, Joi (Validasi) |
| **File Handling** | Multer |
| **Geocoding API** | Overpass API & Nominatim API (OpenStreetMap) |
| **Task Scheduler** | node-cron |

---

## 📅 Progress Mingguan

### Minggu 1 (1 – 7 Mei 2026)
> Perencanaan dan perancangan arsitektur aplikasi

- Perancangan arsitektur sistem (backend REST API + frontend Flutter)
- Perancangan skema database (User, Lokomotif, Kereta, Sensus, Vote, Depo)
- Membuat dokumen kebutuhan fungsional dan non-fungsional

### Minggu 2 (8 – 14 Mei 2026)
> Setup proyek dan implementasi backend dasar

- Inisialisasi proyek backend Node.js dengan Express
- Konfigurasi Sequelize ORM dan koneksi database MySQL
- Membuat model dan migrasi database
- Implementasi sistem autentikasi (register/login) dengan JWT dan bcrypt

### Minggu 3 (15 – 21 Mei 2026)
> Implementasi CRUD backend dan fondasi frontend

- Membuat CRUD API lokomotif dengan upload foto
- Membuat CRUD API sensus dan voting trust score
- Inisialisasi proyek Flutter dengan arsitektur BLoC
- Membuat halaman splash, landing, login, dan register
- Implementasi navigasi GoRouter dan bottom navigation bar
- Membuat halaman daftar & detail lokomotif
- Membuat halaman daftar & detail sensus (dengan form bertingkat)

### Minggu 4 (22 – 28 Mei 2026)
> Fitur admin, profil, dan pelaporan

- Membuat halaman profil pengguna (dengan avatar default lokal)
- Membuat dashboard admin dengan statistik Bento UI
- Membuat CRUD master data (kereta, depo) dan manajemen pengguna
- Mengimplementasikan logika Self-Delete vs Report
- Integrasi Overpass API & Nominatim API untuk Hybrid Geocoding
- Implementasi cron job pembersihan data sensus 12 jam

### Minggu 5 (29 Mei – 4 Juni 2026)
> Perbaikan UI card dan detail page

- Redesign UI card lokomotif dan sensus menjadi lebih premium
- Penerapan font Plus Jakarta Sans secara konsisten
- Penambahan galeri kontribusi pada halaman Profil

### Minggu 6 (5 – 11 Juni 2026)
> Perbaikan bug dan stabilitas

- Perbaikan bug rate limiting dan state management sensus
- Perbaikan validasi status lokomotif (Siap Operasi)

### Minggu 7 (12 – 18 Juni 2026)
> Maintenance dan penyesuaian jaringan

- Penyesuaian konfigurasi base URL untuk testing di berbagai jaringan
- Perbaikan paginasi pencarian lokomotif

### Minggu 8 (19 – 21 Juni 2026)
> Polish final, validasi, dan testing

- Implementasi custom dialog dan snackbar yang konsisten
- Validasi duplikasi pada master kereta dan depo
- Pembersihan file frontend & backend
- Eksekusi Test Suite komprehensif (58 test cases)

---

## 🚀 Cara Menjalankan

### Prasyarat
- Node.js v18+
- MySQL
- Flutter SDK v3.x
- Android SDK / Emulator

### Backend
```bash
cd backend
npm install
# Konfigurasi file .env (sesuaikan DB_USERNAME, DB_PASSWORD, dll.)
npm run dev
```

### Frontend
```bash
cd frontend
flutter pub get
# Konfigurasi file .env (sesuaikan API_BASE_URL)
flutter run
```

### Testing
```bash
cd backend
node tests/crud_test.js
```

---

## 👤 Pengembang

**Arya Bagas Saputra** (20230140029)

---

## 📄 Lisensi

Proyek ini dibuat untuk keperluan tugas mata kuliah **Pengembangan Aplikasi Mobile Lanjut (PAML)**.
